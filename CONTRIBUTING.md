# Contributing to Azure API Management Self-Hosted Gateway

This project welcomes contributions and suggestions. Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Updating Helm Chart Documentation

The Helm chart documentation in `helm-charts/azure-api-management-gateway/README.md` is automatically generated using [helm-docs](https://github.com/norwoodj/helm-docs).

### Pre-commit Hook (Recommended)

To ensure documentation is always up-to-date, we recommend setting up the pre-commit hook:

1. Install pre-commit: `pip install pre-commit` or follow the [installation instructions](https://pre-commit.com/#install)
2. Install the git hook scripts: `pre-commit install`
3. (Optional) Run against all files: `pre-commit run --all-files`

Once configured, the pre-commit hook will automatically regenerate the README whenever you commit changes to `values.yaml`, `Chart.yaml`, or `README.md.gotmpl`.

### Manual Documentation Update

If you prefer to update documentation manually:

1. Install helm-docs: Follow the [installation instructions](https://github.com/norwoodj/helm-docs#installation)
2. Update the comments in `values.yaml` using the `# --` format for descriptions
3. Run `helm-docs` in the `helm-charts/azure-api-management-gateway` directory
4. Commit both `values.yaml` and the generated `README.md`

The CI workflow will validate that the README is up-to-date with the values.yaml file.

## CI Federation Setup

The main CI workflow and trusted PR deployments use GitHub Actions OIDC to
authenticate to Azure without a CI client secret. Both main deployment matrices
and the PR deployment matrix use the same federated identity to
read gateway credentials from Key Vault. The gateway's `AzureAdApp` authentication
is separate and still uses the `Azure-Ad-App-Secret` secret.

Configure these repository Actions variables before running the workflow:

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

### Configure the Federated Credential

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

### Configure PR Federation

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

The PR workflow reuses `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`,
`AZURE_CI_CLIENT_ID`, and `AZURE_KEY_VAULT_NAME`. It reads only
`Gateway-Configuration-Url` and `Gateway-Token`; its existing lint checks continue
using dummy credentials. No additional repository variables or CI client secret
are required.

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

Grant the CI identity permission to read the three secrets in the destination
Key Vault (for example, **Key Vault Secrets User** on an RBAC-enabled vault),
and ensure the vault permits network access from the hosted runners. If moving
the vault, securely provision the gateway credentials there; do not commit them.
Then set the repository variables and dispatch **Helm Chart CI (Main)** on `main`
after the workflow changes are merged.

`AADSTS70025` means the selected CI application has no federated credentials;
changing workflow variables alone cannot fix it. The credential must exist in
Entra before authentication can succeed.

## Release Process

### Releasing a New Helm Chart Version

When releasing a new version of the Helm chart, follow these steps:

1. **Update Chart Version**: Update the `version` field in `helm-charts/azure-api-management-gateway/Chart.yaml`

2. **Update Documentation**: 
   - Ensure all changes to `values.yaml` are documented with `# --` comments
   - Run `helm-docs` in the `helm-charts/azure-api-management-gateway` directory to regenerate the README
   - Verify the generated `README.md` is accurate and complete

3. **Package and Index the Chart**: Navigate to the `helm-charts` directory and run:
   ```bash
   cd helm-charts
   helm package azure-api-management-gateway
   helm repo index . --url https://azure.github.io/api-management-self-hosted-gateway/helm-charts/
   ```

4. **Commit and Push Changes**: 
   ```bash
   git add .
   git commit -m "Release Helm chart version X.Y.Z"
   git push origin main
   ```

5. **Verify CI**: Ensure the `validate-helm-docs` job in the CI workflow passes, confirming documentation is synchronized
