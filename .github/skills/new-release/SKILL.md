---
name: new-release
description: >-
  Skill for releasing a new Helm chart version for the Azure API Management Self-Hosted Gateway,
  optionally with a new container image version. Handles Chart.yaml updates, helm-docs regeneration,
  chart packaging, repo indexing, release notes preparation, PR creation, and draft GitHub release preparation.
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

## Prepare Helm Release Notes

Prepare release notes when creating the new Helm package, **before creating the release PR**. Do not wait for the PR to merge to prepare the notes.

1. Record the current chart `version` and `appVersion` before updating `Chart.yaml`. Use the chart version as `<previousHelmChartVersion>`; do not use a container release tag as the comparison baseline.
2. Review commits, merged PRs, and the chart diff from `v<previousHelmChartVersion>` to the release branch. Include chart changes shipped in this package, not unrelated repository maintenance or changes already released. If the previous tag or history is unavailable, retrieve it before comparing; if it cannot be retrieved, ask the user for the missing context rather than guessing.
3. Start with [`templates/helm-release.md`](templates/helm-release.md) and replace all version placeholders. Summarize user-visible changes under **Features**, **Fixes / Changes**, **Breaking Changes**, and **Removal**, linking to relevant PRs or commits. Include migration guidance for breaking changes and removals where applicable. Replace `TBD` entries with verified changes, or `None.` when the reviewed changes contain none.
4. If the container image changes, retain the container release-notes link and use verified container release information for any container-specific claims. Do not infer gateway features from the chart diff. If the image is unchanged, use `- Uses container image v<containerImageVersion> (unchanged)` instead.
5. Check that the versions match the packaged chart and that the full changelog compares `v<previousHelmChartVersion>...v<helmChartVersion>`. The new tag and any new container release link may not exist until publication; do not present them as already published.
6. Include the prepared Helm release notes in the release PR description for review and reuse them for the Helm draft release after merge. If a draft cannot be created, return the prepared title, tag, target, and body to the user without claiming it was created. Do not publish a release automatically.

## Draft GitHub Releases

After completing the Helm chart PR, prepare draft GitHub releases using the release notes reviewed in the PR.

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
- Reuse the prepared Helm release notes from the release PR, incorporating review feedback rather than leaving `TBD` entries in the draft.

## Summary Checklist

Present this checklist to the user after completing all steps:

- [ ] Chart.yaml updated (version + appVersion)
- [ ] README.md regenerated via helm-docs
- [ ] Helm lint passed
- [ ] Chart packaged (.tgz created)
- [ ] Repo index updated (index.yaml)
- [ ] Helm release notes prepared and included in the release PR description
- [ ] Branch pushed and PR created
- [ ] Container draft release created (if applicable)
- [ ] Helm chart draft release created (after PR merge)
