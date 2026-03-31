---
name: app-template-migration
description: Migrate Kubernetes applications from bjw-s/app-template Helm charts to native manifests (Deployment, Service, HTTPRoute). Use this skill when moving away from Helm to standard YAML while maintaining zero-downtime and Flux/Volsync integration.
---

# App Template Migration

## Overview

This skill provides a structured workflow for converting applications defined with the `bjw-s/app-template` Helm chart into native Kubernetes manifests. It ensures that critical configurations like immutable selectors, persistence mounts, and slow-startup probes are correctly preserved.

## Workflow

### 1. Research & Live State Discovery
Before implementing, you must discover the existing state to prevent immutability errors and adoption conflicts.

- **Immutable Selectors**: Identify the existing `matchLabels` used by the Helm-managed Deployment.
  ```bash
  kubectl get deployment <app> -n <namespace> -o jsonpath='{.spec.selector.matchLabels}'
  ```
- **Metadata Labels**: Match the existing metadata labels for a clean takeover. Pay attention to `app.kubernetes.io/instance` and `app.kubernetes.io/controller`.
  ```bash
  kubectl get deployment <app> -n <namespace> -o jsonpath='{.metadata.labels}'
  ```
- **Service Specs**: Check if the existing service uses named ports or integers for `targetPort`. Matching the current state exactly prevents "manager conflict" errors during Flux adoption.
- **Helm Values**: Read the existing `helmrelease.yaml` to extract:
  - Image repository and digest.
  - Environment variables (including app-specific UIDs like `AUDIOBOOKSHELF_UID`).
  - Resource requests and limits.
  - Persistence keys and their corresponding `globalMounts`.

### 2. Implementation Strategy

#### Deployment (`deployment.yaml`)
- **apiVersion**: `apps/v1`
- **Selector**: MUST exactly match the labels found in step 1.
- **Startup Probe**: ALWAYS include a `startupProbe` for applications with non-trivial initialization (e.g., DB migrations, heavy syncs).
  ```yaml
  startupProbe:
    httpGet:
      path: /health
      port: <port>
    failureThreshold: 30
    periodSeconds: 10
  ```
- **Persistence**: Explicitly map `volumes` to `volumeMounts`. If `globalMounts` was missing in the Helm chart, the volume was likely NOT mounted.

#### Service (`service.yaml`)
- **apiVersion**: `v1`
- **Selector**: Match the labels used in the Deployment.
- **TargetPort**: Use the container's port name OR match the existing integer port from the live state to avoid adoption friction.

#### HTTPRoute (`httproute.yaml`)
- **apiVersion**: `gateway.networking.k8s.io/v1`
- **Gatus**: Copy all `gatus.home-operations.com` annotations from the old `HelmRelease`.

### 3. GitOps & Execution
- **Kustomization**: Update `kustomization.yaml` to include the new files and remove the old `HelmRelease` and `OCIRepository`.
- **Git Mandate**: All changes must be committed. Never rely on `kubectl apply` for finality, as Flux will revert unsynced changes.
- **Race Conditions**: During the migration, the Helm controller might delete resources as Flux tries to adopt them. If resources go missing after reconciliation, a one-time manual `kubectl apply` of the native manifests will stabilize the state.
- **Validation**: After reconciliation, verify that the `HelmRelease` has been pruned and the new pod is `READY`.

## Common Pitfalls
- **Resource Limits**: Always define explicit `requests` and `limits` for both CPU and Memory. Omitting CPU limits can lead to process starvation on the node. Ensure suffixes are valid (e.g., `512Mi`, not `512MiGi`).
- **Quote Integer Quantities**: Resource quantities that are plain integers (e.g., `gpu.intel.com/i915: "1"`) MUST be quoted. Failure to do so causes a type mismatch error (`Expected "string"`) in Kubernetes schema validation.
- **Selector Immutability**: If the selector changes, the Deployment will fail to reconcile. The only fix is to delete the existing Deployment manually and let Flux recreate it.
- **Read-Only Root**: Ensure `readOnlyRootFilesystem: true` containers have `emptyDir` mounts for any writable directories (e.g., `/tmp`, `/config/cache`, `/.npm`). Some applications (e.g., Maintainerr) rewrite their own internal application files during startup and CANNOT use a read-only root filesystem at all.
- **Nginx Pitfalls**: Nginx-based containers (e.g., Dashboards, Proxies) often require the `CHOWN` capability during startup to initialize `/var/cache/nginx`. If the pod crashes with a `chown failed` error, do not drop `ALL` capabilities and ensure `emptyDir` volumes are mounted to `/var/cache/nginx` and `/var/run`.
- **Local Resources**: Check if the application directory contains a `resources/` folder. If it does, you must add a `configMapGenerator` or `secretGenerator` to your `kustomization.yaml` to ensure those files are available to the cluster. Use `disableNameSuffixHash: true` if your Deployment refers to them by a static name.
