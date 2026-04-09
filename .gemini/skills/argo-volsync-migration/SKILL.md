---
name: argo-volsync-migration
description: Guidance for migrating applications from Flux-based VolSync to an Argo CD managed structure with a centralized ClusterExternalSecret. Use when the user wants to transition an application to the new "Argo-native" VolSync pattern.
---

# Argo-VolSync Migration Guide

This skill provides the standard workflow for migrating applications to the new Argo CD and VolSync structure.

## Core Strategy
1. **Self-Contained Manifests**: Move VolSync logic (RS, RD, PVC) into the application's `app/` folder.
2. **Centralized Secret**: Rely on the `ClusterExternalSecret` (named `volsync-kopia-secret`) for all Kopia credentials.
3. **Argo Takeover**: Use the Argo CD registry to manage the application's lifecycle.

## Workflow

### 1. Research & Baseline
- Identify the app's name, namespace, and current VolSync capacity (check the existing Flux `ks.yaml`).
- Ensure the target namespace has the required label/annotation:
  - Label: `volsync.backube/privileged-movers: "true"`
  - Annotation: `volsync.backube/privileged-movers: "true"`

### 2. Prepare Manifests
- Create the following files in the application's `app/` folder:
  - `replicationsource.yaml`
  - `replicationdestination.yaml`
  - `pvc.yaml`
- Use the templates provided in `references/manifest-templates.md`.
- **CRITICAL**: Add the annotation `argocd.argoproj.io/sync-options: Prune=false` to the `ReplicationSource` to prevent accidental data loss.

### 3. Update Kustomization
- Update the app's `kustomization.yaml` to include the three new files in the `resources` list.

### 4. Flux Handover
- Update the app's Flux `ks.yaml`:
  - **Remove** the `components/volsync` reference.
  - **Remove** the `postBuild` variable substitutions (e.g., `VOLSYNC_CAPACITY`).
- **Safety Step**: Remind the user to run `flux suspend ks <app-name>` before pushing changes.

### 5. Argo CD Registration
- Add the app to `kubernetes/apps/argocd/registry/default.yaml` under the `generators.list.elements` section.

## Best Practices
- **Naming Consistency**: Always name the PVC the same as the app name.
- **Secret Reference**: Always use `repository: volsync-kopia-secret` in VolSync manifests.
- **Manual Restore**: Keep the `ReplicationDestination` in `manual: restore-once` mode for easy recovery.
