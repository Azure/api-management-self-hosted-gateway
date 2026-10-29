#!/usr/bin/env bash
set -euo pipefail

require_value() {
  local name="$1"
  local value="${!name:-}"
  if [[ -z "$value" || "$value" == '$('* || "$value" == *$'\n'* || "$value" == *$'\r'* ]]; then
    echo "##vso[task.logissue type=error]$name must be configured with a non-empty, single-line value."
    exit 1
  fi
}

for name in GATEWAY_CONFIGURATION_URL GATEWAY_CREDENTIAL AUTHENTICATION_TYPE HIGH_AVAILABILITY USE_AZURE; do
  require_value "$name"
done
case "$USE_AZURE" in true|false) ;; *) echo "Invalid USE_AZURE" >&2; exit 1 ;; esac
case "$HIGH_AVAILABILITY" in true|false) ;; *) echo "Invalid HIGH_AVAILABILITY" >&2; exit 1 ;; esac

credentials_dir="$(mktemp -d)"
trap 'rm -rf "$credentials_dir"' EXIT
chmod 700 "$credentials_dir"
umask 077
printf '%s' "$GATEWAY_CREDENTIAL" > "$credentials_dir/credential"
args=(
  azure-api-management-gateway ./helm-charts/azure-api-management-gateway
  --namespace apim-gateway
  --set-string "gateway.configuration.uri=$GATEWAY_CONFIGURATION_URL"
  --set "highAvailability.enabled=$HIGH_AVAILABILITY"
  --set gateway.deployment.strategy.type=Recreate
  --values ./testing/test-config.yml
)
case "$AUTHENTICATION_TYPE" in
  GatewayToken)
    args+=(--set-file "gateway.auth.key=$credentials_dir/credential")
    ;;
  AzureAdApp)
    for name in GATEWAY_NAME AZURE_TENANT_ID AZURE_GATEWAY_CLIENT_ID; do
      require_value "$name"
    done
    args+=(
      --set gateway.auth.type=AzureAdApp
      --set-string "gateway.name=$GATEWAY_NAME"
      --set-string "gateway.auth.azureAd.tenant.id=$AZURE_TENANT_ID"
      --set-string "gateway.auth.azureAd.app.id=$AZURE_GATEWAY_CLIENT_ID"
      --set-file "gateway.auth.azureAd.app.secret=$credentials_dir/credential"
    )
    ;;
  *) echo "Unsupported authentication type: $AUTHENTICATION_TYPE" >&2; exit 1 ;;
esac

helm install "${args[@]}" --dry-run --hide-secret
if [[ "$USE_AZURE" == true ]]; then
  helm install "${args[@]}" --wait --timeout 10m0s
else
  echo "Credential-free PR test: installing resources without asserting gateway readiness."
  helm install "${args[@]}"
  kubectl get deployment azure-api-management-gateway --namespace apim-gateway
fi
