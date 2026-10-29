#!/usr/bin/env bash
set -euo pipefail

test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT
export CALL_LOG="$test_dir/calls"
export GATEWAY_CONFIGURATION_URL=xyz.configuration.azure-api.net
export GATEWAY_CREDENTIAL='dummy,with\special=characters'
export AUTHENTICATION_TYPE=GatewayToken
export HIGH_AVAILABILITY=false
export USE_AZURE=false
export GATEWAY_NAME=gateway-name
export AZURE_TENANT_ID=tenant-id
export AZURE_GATEWAY_CLIENT_ID=application-id

helm() {
  printf '%s\n' "$*" >> "$CALL_LOG"
  local arg file
  for arg in "$@"; do
    case "$arg" in
      gateway.auth.key=*|gateway.auth.azureAd.app.secret=*)
        file="${arg#*=}"
        [[ "$(cat "$file")" == "$GATEWAY_CREDENTIAL" ]] || return 1
        printf 'credential-file=%s\n' "$file" >> "$CALL_LOG"
        ;;
    esac
  done
  if [[ "${FAIL_HELM:-false}" == true ]]; then
    return 1
  fi
}
kubectl() {
  printf 'kubectl %s\n' "$*" >> "$CALL_LOG"
}
export -f helm kubectl

run_deploy() {
  : > "$CALL_LOG"
  bash .azure-pipelines/scripts/deploy.sh > "$test_dir/output" 2>&1
}
assert_contains() {
  grep -q -- "$1" "$CALL_LOG"
}
assert_absent() {
  if grep -q -- "$1" "$CALL_LOG"; then
    echo "Unexpected command argument: $1" >&2
    exit 1
  fi
}

run_deploy
assert_contains '--dry-run --hide-secret'
assert_contains 'kubectl get deployment'
assert_absent '--wait'
credential_file="$(sed -n 's/^credential-file=//p' "$CALL_LOG" | head -n 1)"
[[ ! -e "$credential_file" ]]

export USE_AZURE=true
export HIGH_AVAILABILITY=true
for AUTHENTICATION_TYPE in GatewayToken AzureAdApp; do
  export AUTHENTICATION_TYPE
  run_deploy
  assert_contains '--wait --timeout 10m0s'
  assert_contains 'highAvailability.enabled=true'
  assert_absent 'kubectl get deployment'
  if [[ "$AUTHENTICATION_TYPE" == AzureAdApp ]]; then
    assert_contains 'gateway.auth.azureAd.app.secret='
    assert_contains 'gateway.auth.azureAd.app.id=application-id'
  fi
done

expect_failure() {
  if run_deploy; then
    echo "Expected deployment to reject invalid configuration" >&2
    exit 1
  fi
  [[ ! -s "$CALL_LOG" ]]
}

export GATEWAY_CREDENTIAL=''
expect_failure
export GATEWAY_CREDENTIAL='$(Gateway-Token)'
expect_failure
export GATEWAY_CREDENTIAL=$'invalid\ncredential'
expect_failure
export GATEWAY_CREDENTIAL=$'invalid\rcredential'
expect_failure
export GATEWAY_CREDENTIAL=valid
export AZURE_GATEWAY_CLIENT_ID=''
expect_failure
export AZURE_GATEWAY_CLIENT_ID=application-id
export AUTHENTICATION_TYPE=Unknown
expect_failure
export AUTHENTICATION_TYPE=GatewayToken
export USE_AZURE=unknown
expect_failure
export USE_AZURE=true
export HIGH_AVAILABILITY=unknown
expect_failure

export HIGH_AVAILABILITY=false
export FAIL_HELM=true
if run_deploy; then
  echo "Expected a Helm failure to fail the deployment" >&2
  exit 1
fi
assert_contains '--dry-run --hide-secret'
assert_absent '--wait'
credential_file="$(sed -n 's/^credential-file=//p' "$CALL_LOG" | head -n 1)"
[[ ! -e "$credential_file" ]]

echo "Pipeline deployment script checks passed."
