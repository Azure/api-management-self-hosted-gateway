# Azure Pipelines CI

The migration is additive: the existing GitHub Actions workflows and required
checks remain active until Azure Pipelines has been configured and exercised.
This change does not create Azure DevOps resources or switch branch protection.

## Pipeline definitions

Create two pipelines using the Azure Pipelines GitHub app and the existing YAML
file option:

| Definition | Trigger | Coverage |
| --- | --- | --- |
| `.azure-pipelines/ci-pr.yml` | PRs targeting `main`, or manual runs | Documentation, GatewayToken/AzureAdApp lint, 16 GatewayToken deployments: four Kubernetes versions, HA on/off, AMD64/ARM64. |
| `.azure-pipelines/ci-main.yml` | Pushes to `main`, or manual runs | Documentation, GatewayToken/AzureAdApp lint, 16 authenticated AMD64 deployments: four Kubernetes versions, HA on/off, both authentication types. |

Both use shared templates, Helm 3.19.0, helm-docs 1.14.2, Kind v0.32.0, and
digest-pinned Kind node images. The weekly GitHub Actions image updater keeps
both systems synchronized during the transition. Deployment jobs depend on
documentation and lint validation, run independently of one another, show
resources and gateway logs even after failure, and always attempt cluster cleanup.
Log collection failures are reported as warnings, since credential-free pods
may not have started yet; deployment and cleanup failures still fail the job.

PR runs intentionally never use Azure credentials, including same-repository
PRs. They render the chart with dummy values, hide Kubernetes Secrets in dry-run
output, install resources into Kind, and verify that the Deployment exists.
They do **not** wait for gateway readiness: dummy credentials cannot establish
a real gateway configuration connection. Main runs retain the authenticated
`--wait --timeout 10m0s` readiness check. The chart-default image is used in both.

Main deployment jobs are restricted to `refs/heads/main` and non-PR builds.
Manually queuing main CI on another branch runs validation only; it does not
fall back to dummy credentials or attempt Azure authentication.

## Agents and fork builds

AMD64 jobs use Microsoft-hosted `ubuntu-24.04` agents. ARM64 PR jobs use the
`arm64Pool` pipeline parameter, defaulting to `apim-gateway-linux-arm64`.
Configure that pool before enabling PR validation; ARM64 jobs are not silently
skipped if the pool is unavailable. Agents must advertise Linux/ARM64
capabilities and have Bash, curl, tar, sha256sum, and a working Docker daemon
accessible to the agent user. Helm, Kind, and kubectl are installed per job
under the agent temporary directory, with download checksum verification.

Use isolated, disposable ARM64 agents with no credentials, access to internal
networks, or shared Docker state. Never run untrusted PR code on persistent
internal agents. Limit pool authorization to the PR pipeline, provision enough
capacity for eight ARM64 jobs, and recreate agents after each job. Cluster
cleanup alone is not isolation from malicious PR code.

In the PR pipeline's **Triggers / Pull request validation** settings, review
the GitHub fork settings: do not make secrets available to fork builds or
grant fork builds regular-build permissions, and require a team member's
comment before building external contributors' PRs. If a safe ARM64 pool is
not available, keep using the existing GitHub checks rather than enabling
the Azure PR pipeline on an internal pool.

## Azure service connection and variables

For main CI, select an existing approved Azure Resource Manager service
connection through the `azureServiceConnection` parameter. The default name,
`apim-gateway-ci`, is a placeholder, not a provisioned connection. The connection
must be available in the Azure DevOps project hosting these pipelines and
authorized for the main pipeline; a connection in another project is not
automatically available here.

Use **workload identity federation** with an app registration or user-assigned
managed identity. Azure tasks authenticate through the service connection;
there is no separate `az login`, GitHub OIDC login, or CI client secret to
configure in the YAML. `AzureKeyVault@2` consumes the connection directly.
If a new connection is required, use the issuer, subject, and audience provided
by Azure DevOps when configuring its Entra federated credential; do not copy
the GitHub OIDC claims from the existing setup.

Grant the connection's identity read/list access to the required Key Vault
secrets (for example, **Key Vault Secrets User** with an RBAC-enabled vault),
and permit network access from the hosted agents. Authorize only the main
pipeline to use this connection; do not enable access for all pipelines.
Add a **Branch control** check to the connection allowing only
`refs/heads/main`, requiring branch protection, and failing if protection
cannot be determined. YAML conditions are defense in depth, not a substitute
for resource permissions and checks configured outside the repository.

Configure these variables on the main pipeline, or in existing Azure DevOps
Library variable groups selected through the `variableGroups` object parameter:

| Variable | Purpose |
| --- | --- |
| `AZURE_KEY_VAULT_NAME` | Vault containing `Gateway-Configuration-Url`, `Gateway-Token`, and `Azure-Ad-App-Secret`. |
| `GATEWAY_NAME` | APIM self-hosted gateway name for AzureAdApp tests. |
| `AZURE_TENANT_ID` | Tenant of the application used by the gateway's AzureAdApp test. |
| `AZURE_GATEWAY_CLIENT_ID` | Application ID matching `Azure-Ad-App-Secret`, authorized to access the APIM gateway configuration. |

For a fixed configuration, set the parameter defaults in the main pipeline
definition to the approved service connection and a list of configuration group
names. Neither the service connection name nor variable-group names belong in
runtime macro expressions: Azure DevOps must resolve these protected resources
when expanding the pipeline.

Variable groups are imported only into the authenticated `Deploy` stage, not
the validation stage or PR pipeline. Authorize the selected groups only for the
main pipeline, and apply the same branch control checks to secret-bearing
groups as to the service connection. Gateway credentials continue to be fetched
from Key Vault rather than being supplied as queue-time parameters.

The gateway application may be the existing `AZURE_CI_CLIENT_ID` application,
but need not be the pipeline service connection's identity. CI authentication
does not require that application's client secret. `AzureKeyVault@2` retrieves
only the secrets required by each authentication mode and exposes them as
secret task variables. Secrets are mapped explicitly into the deployment
step's environment, validated as non-empty single-line values, and passed to
Helm using private temporary files so commas and backslashes are preserved.
The temporary files are removed on exit; secret manifests are hidden in the
dry run. Missing credentials fail the job rather than selecting dummy values.

These are standard Azure Pipelines definitions, not OneBranch pipelines.
OneBranch-specific `extends` templates, `pool.type`/`hostArchitecture` settings,
and `ob_*` variables are not interchangeable with standard agent pool syntax.
Using an existing service connection or variable group does not require adopting
OneBranch or depending on an internal source repository.

## Cutover

1. Register both pipelines, configure the ARM64 pool, main service connection,
   resource checks, and variables. Keep the existing GitHub Actions checks.
2. Queue PR validation and verify all 16 deployment combinations, including
   ARM64 and fork approval behavior. Queue main CI on `main` and verify both
   authentication modes with real gateway readiness.
3. After successful runs, replace the GitHub Actions required checks in the
   repository ruleset with the actual Azure Pipelines check names. Update the
   README CI badge using the real Azure DevOps organization, project, and
   pipeline ID.
4. Disable or remove only `.github/workflows/ci-pr.yml` and `ci-main.yml` after
   the new required checks are active. Keep the image-update and Copilot setup
   workflows; remove GitHub CI federation credentials only when nothing uses
   them. Update the image updater to stop editing the retired workflows.

For local checks, run the two Helm lint commands from the contributor
instructions, `bash -n .azure-pipelines/scripts/deploy.sh`, and
`bash testing/test-pipeline-deploy.sh`. Azure DevOps template expansion and real
Key Vault/Kind deployments must also be verified in the configured pipelines.

References: [GitHub integration and fork settings](https://learn.microsoft.com/azure/devops/pipelines/repos/github),
[resource approvals and branch control](https://learn.microsoft.com/azure/devops/pipelines/process/approvals),
and [Azure Key Vault task](https://learn.microsoft.com/azure/devops/pipelines/tasks/reference/azure-key-vault-v2).
