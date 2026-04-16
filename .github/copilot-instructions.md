# Copilot Instructions

## Repository Overview

This repository maintains the **Helm chart** for the Azure API Management Self-Hosted Gateway and serves as the release announcement channel. It does not contain the gateway source code—only the Helm chart, packaged chart archives, CI workflows, and documentation.

The single Helm chart lives in `helm-charts/azure-api-management-gateway/`. Packaged `.tgz` releases and `index.yaml` sit alongside it in `helm-charts/`.

## Build, Lint, and Test

```bash
# Lint the chart (gateway token auth)
helm lint helm-charts/azure-api-management-gateway \
  --set gateway.configuration.uri="example.configuration.azure-api.net" \
  --set gateway.auth.key="GatewayKey xyz"

# Lint the chart (Azure AD auth)
helm lint helm-charts/azure-api-management-gateway \
  --set gateway.configuration.uri="example.configuration.azure-api.net" \
  --set gateway.auth.type="AzureAdApp" \
  --set gateway.name=gw \
  --set gateway.auth.azureAd.tenant.id=tid \
  --set gateway.auth.azureAd.app.id=aid \
  --set gateway.auth.azureAd.app.secret=xyz

# Dry-run template rendering
helm install test ./helm-charts/azure-api-management-gateway \
  --set gateway.configuration.uri="example.configuration.azure-api.net" \
  --set gateway.auth.key="GatewayKey xyz" \
  --dry-run

# Regenerate chart README from template
# Requires helm-docs v1.14.2 (https://github.com/norwoodj/helm-docs)
cd helm-charts/azure-api-management-gateway && helm-docs

# Run pre-commit hooks (includes helm-docs)
pre-commit run --all-files
```

CI (`ci-pr.yml`) runs three checks on PRs: `validate-helm-docs`, `lint-helm`, and `deploy-helm` (Kind cluster matrix across K8s versions × HA on/off).

## Key Conventions

### Helm Chart Documentation

`README.md` in the chart directory is **auto-generated** by [helm-docs](https://github.com/norwoodj/helm-docs) from `README.md.gotmpl` and `values.yaml` comments. Never edit `README.md` directly—edit the `.gotmpl` template or `values.yaml` `# --` comments instead. CI will fail if the generated README is stale.

### Values Documentation Format

Document values with `# --` comment lines immediately above the value in `values.yaml`. This is the helm-docs convention that drives README generation:

```yaml
# -- Description of the parameter.
parameterName: defaultValue
```

### PR Title Convention

PR titles must follow [Conventional Commits](https://www.conventionalcommits.org/) (enforced by the Semantic PRs GitHub app, title-only mode).

### Helm Chart Release Process

The full release process is documented in [CONTRIBUTING.md](../CONTRIBUTING.md#release-process). Invoke the `new-release` skill (`.github/skills/new-release/SKILL.md`) to walk through all release steps including Chart.yaml updates, helm-docs regeneration, chart packaging, repo indexing, PR creation, and draft GitHub release preparation.

### Authentication Modes

The chart supports three authentication types (`gateway.auth.type`):
- **GatewayToken** (default) — uses `gateway.auth.key`
- **AzureAdApp** — uses client secret/certificate via Azure AD
- **WorkloadIdentity** — uses managed identity via Workload Identity Federation

Template logic in `deployment.yaml` branches on `$authenticationType` to set environment variables and secret references accordingly.

### Pre-commit Hooks

A `.pre-commit-config.yaml` is configured with `helm-docs-container`. Install with:

```bash
pip install pre-commit
pre-commit install
```
