---
name: new-release
description: >-
  Skill for releasing a new Helm chart version for the Azure API Management Self-Hosted Gateway,
  optionally with a new container image version. Handles Chart.yaml updates, helm-docs regeneration,
  chart packaging, repo indexing, PR creation, and draft GitHub release preparation.
user-invocable: true
---

# Releasing a New Helm Chart Version

This skill guides you through the full release process for the Azure API Management Self-Hosted Gateway Helm chart.

## Prerequisites

Before starting, confirm the user provides:

1. **Container image version** (required) — the new container image version being shipped (e.g. `2.12.0`)
2. **Helm chart version** — derived from the container image version bump and the current Helm chart version:
   - **Minor bump** (e.g. `2.11.x` → `2.12.0`): increment the Helm chart **minor** version (e.g. `1.15.x` → `1.16.0`)
   - **Patch bump** (e.g. `2.11.0` → `2.11.1`): increment the Helm chart **patch** version (e.g. `1.15.0` → `1.15.1`)

## Versioning Convention

The Helm chart version tracks the container image version bump type:

| Container image bump | Helm chart bump | Example (container) | Example (chart) |
|---|---|---|---|
| Minor (`X.Y.0`) | Minor | `2.11.0` → `2.12.0` | `1.15.x` → `1.16.0` |
| Patch (`X.Y.Z`) | Patch | `2.11.0` → `2.11.1` | `1.15.0` → `1.15.1` |

## Release Process

Follow the release process documented in [`CONTRIBUTING.md` § Release Process](../../CONTRIBUTING.md#release-process).

Key points:

- Read `helm-charts/azure-api-management-gateway/Chart.yaml` to get the current `version` and `appVersion`
- Determine the correct Helm chart version using the versioning convention above
- Validate that the new Helm chart version is greater than the current version
- Create a `release/<helmChartVersion>` branch from `main`
- Use `--no-verify` when committing (the pre-commit hook requires Docker for helm-docs-container, but we run helm-docs natively)
- PR title must follow Conventional Commits: `chore: Release Helm chart version <helmChartVersion>`
- `helm repo index` rewrites timestamps across ALL entries in `index.yaml`, creating a large diff — this is expected

## Draft GitHub Releases

After completing the Helm chart PR, prepare draft GitHub releases.

### Container Release (only if new container image version)

This draft release can be created **before** the Helm chart PR is merged.

- **Tag:** `Container-v<containerImageVersion>`
- **Title:** `Container v<containerImageVersion>`
- **Target:** `main`
- **Draft:** Yes
- **Body:** Use the template in [`templates/container-release.md`](templates/container-release.md), replacing `<containerImageVersion>` with the actual version

### Helm Chart Release

This draft release should be created **after** the Helm chart PR is merged.

- **Tag:** `v<helmChartVersion>`
- **Title:** `Helm chart v<helmChartVersion>`
- **Target:** `main`
- **Draft:** Yes
- **Body:** Use the template in [`templates/helm-release.md`](templates/helm-release.md), replacing placeholders:
  - `<helmChartVersion>` — new Helm chart version
  - `<containerImageVersion>` — container image version (new or current)
  - `<previousHelmChartVersion>` — previous Helm chart version (for the changelog link)
- If no new container image was released, replace the container feature line with: `- Uses container image v<containerImageVersion> (unchanged)`

## Summary Checklist

Present this checklist to the user after completing all steps:

- [ ] Chart.yaml updated (version + appVersion)
- [ ] README.md regenerated via helm-docs
- [ ] Helm lint passed
- [ ] Chart packaged (.tgz created)
- [ ] Repo index updated (index.yaml)
- [ ] Branch pushed and PR created
- [ ] Container draft release created (if applicable)
- [ ] Helm chart draft release created (after PR merge)
