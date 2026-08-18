---
name: update-kubernetes-images
description: Update pinned Kind node images used by the Helm chart CI workflows.
user-invocable: true
---

# Update Kubernetes CI Images

Refresh the pinned Kind node images in `.github/workflows/ci-main.yml` and
`.github/workflows/ci-pr.yml` from the latest
[Kind release](https://github.com/kubernetes-sigs/kind/releases).

## Procedure

1. Read the latest Kind release notes and use the newest image available for
   each of the four currently supported Kubernetes minor versions.
2. Keep every image pinned by its `@sha256` digest. Do not use a mutable tag.
3. Keep the Kubernetes matrix and `include` entries synchronized in both CI
   workflows.
4. Update the Kind CLI version in both workflows when the release requires a
   newer version.
5. Verify the YAML structure and report the release, image tags, and digests.
6. Open a Conventional Commit PR only when at least one image or the Kind CLI
   version changed.

The weekly workflow
(`.github/workflows/update-kubernetes-images.yml`) performs this procedure
automatically and opens or updates a PR for the changes.
