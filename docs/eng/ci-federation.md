# CI Federation Setup

The main CI workflow and trusted PR deployments use GitHub Actions OIDC to
authenticate to Azure without a CI client secret. Both main deployment matrices
and the PR deployment matrix use the same federated identity to read gateway
credentials from Key Vault. The gateway's `AzureAdApp` authentication is separate
and still uses the `Azure-Ad-App-Secret` secret.

Configure these repository Actions variables before running the workflows:

| Variable | Purpose |
| --- | --- |
| `AZURE_TENANT_ID` | Entra tenant containing the CI identity. |
| `AZURE_SUBSCRIPTION_ID` | Subscription accessible to the CI identity, containing the Key Vault. |
| `AZURE_CI_CLIENT_ID` | Application (client) ID of the CI app registration or user-assigned managed identity. |
| `AZURE_KEY_VAULT_NAME` | Vault containing `Gateway-Configuration-Url`, `Gateway-Token`, and `Azure-Ad-App-Secret`. |
| `GATEWAY_NAME` | APIM self-hosted gateway name. |
| `GATEWAY_AZURE_AD_TENANT_ID` | Tenant used by the gateway's Azure AD application, independent of the CI tenant. |
| `GATEWAY_AZURE_AD_CLIENT_ID` | Gateway application's client ID matching `Azure-Ad-App-Secret`, independent of the CI identity. |

When moving only CI to another tenant, keep the gateway tenant, application,
and gateway credentials unchanged. Previously, CI and gateway authentication
shared tenant `72f988bf-86f1-41af-91ab-2d7cd011db47` and client ID
`359b42a2-78a3-49e7-9be3-6ddfd1a27329`; use these for the two gateway variables
when retaining that gateway application.

## Configure the Main Federated Credential

In the destination tenant, create the CI identity and configure this federated
credential on it:

```json
{
  "name": "github-main-ci",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repository_owner_id:6844498:repository_id:250428523:ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}
```

For an app registration, save this JSON as `credential.json`, sign in to the
destination tenant with permission to manage the application, and run:

```bash
az ad app federated-credential create \
  --id <CI-APPLICATION-CLIENT-ID> \
  --parameters credential.json
```

For a user-assigned managed identity, configure the same issuer, subject, and
audience on its federated identity credential instead.

This repository uses a custom OIDC subject with `repository_owner_id`,
`repository_id`, and `context` claims. Do not use the default name-based
`repo:Azure/api-management-self-hosted-gateway:ref:refs/heads/main` subject.
Inspect the current configuration with:

```bash
gh api repos/Azure/api-management-self-hosted-gateway/actions/oidc/customization/sub
```

The subject above covers pushes to `main` and manual dispatches targeting `main`,
including every Kubernetes and HA matrix combination. Dispatches on another
branch require a separate, explicitly trusted branch credential.

## Configure PR Federation

Add a second federated credential to the same CI identity, keeping the main
credential:

```json
{
  "name": "github-pr-ci",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repository_owner_id:6844498:repository_id:250428523:pull_request",
  "audiences": ["api://AzureADTokenExchange"]
}
```

For an app registration, save the JSON as `pr-credential.json` and run:

```bash
az ad app federated-credential create \
  --id <CI-APPLICATION-CLIENT-ID> \
  --parameters pr-credential.json
```

For a user-assigned managed identity, add a credential with the same issuer,
subject, and audience on that identity instead.

The PR workflow uses the same Azure login action and repository variables as
main CI. It reads only `Gateway-Configuration-Url` and `Gateway-Token` and passes
them to Helm through step outputs; its lint checks continue using dummy
credentials. Secret retrieval uses the runner's Azure CLI on both architectures.
No additional repository variables or CI client secret are required.

Azure login and secret retrieval run only for same-repository PRs (excluding
Dependabot) and manual dispatches on `main`. Fork PRs, Dependabot runs, and
dispatches on other branches retain the existing credential-free deployment
tests. All architectures, Kubernetes versions, and HA configurations use the
same PR credential. Manual dispatches on `main` use the main credential instead.

The PR subject does not distinguish forks from same-repository PRs; the workflow
gate is essential. Treat same-repository PR authors as trusted with the CI
identity's vault permissions. Do not enable Azure access for fork PRs or switch
to `pull_request_target` to run untrusted chart changes with credentials.
After the workflow changes are available, open or update a same-repository PR
targeting `main` to exercise PR federation.

## Key Vault Access and Verification

Grant the CI identity permission to read the three secrets in the destination
Key Vault (for example, **Key Vault Secrets User** on an RBAC-enabled vault),
and ensure the vault permits network access from the hosted runners. If moving
the vault, securely provision the gateway credentials there; do not commit them.
Then set the repository variables and dispatch **Helm Chart CI (Main)** on `main`
after the workflow changes are merged.

`AADSTS70025` means the selected CI application has no federated credentials;
changing workflow variables alone cannot fix it. The credential must exist in
Entra before authentication can succeed.
