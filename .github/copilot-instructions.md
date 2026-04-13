# HomeOps Project Guidelines

## Code Style
- Follow .editorconfig formatting defaults: YAML/JSON use 2 spaces; Bash/Python use 4 spaces.
- Keep Kubernetes manifests declarative and idempotent under kubernetes/apps.
- Do not commit secrets, OAuth credentials, kubeconfigs, or private keys. Use Azure Key Vault and External Secrets patterns.

## Architecture
- This repo is a GitOps home-lab monorepo:
  - talos/: Talos OS and node configuration templates.
  - bootstrap/: cluster bootstrap sequence (namespaces, external-secrets, CRDs, core apps).
  - kubernetes/apps/: ArgoCD-managed application manifests by domain/namespace.
  - resources/: operational documentation and local tooling configs.
- ArgoCD App-of-Apps drives deployment from kubernetes/apps/argocd/registry.
- Prefer changing source manifests and letting ArgoCD reconcile, rather than relying on ad-hoc cluster mutations.

## Build and Test
- Tooling and task orchestration are primarily via just recipes.
- Common commands:
  - just -l
  - just bootstrap namespaces
  - just bootstrap resources
  - just bootstrap crds
  - just bootstrap apps
  - just argocd-sync-all
  - just kubernetes prune-pods
  - just talos dashboard NODE_IP
- Validation in CI uses kustomize build + kubeconform strict checks; preserve schema-valid manifests.

## Conventions
- Commit message style follows Semantic Commits in resources/SemanticCommits.md.
- App manifests usually follow a predictable directory pattern (kustomization + workload/service/route/volsync resources).
- For resource quantities like GPU/device counts, prefer quoted strings (for example "1") to avoid schema/type issues.
- When using read-only root filesystems, include required writable emptyDir mounts for app runtime paths.

## Pitfalls
- Kubernetes deployment selectors are effectively immutable once applied; changing selectors may require delete/recreate.
- GitOps controllers may revert manual kubectl edits that are not committed.
- During migrations, avoid controller overlap that can cause resource ownership races.

## References
- Primary overview and architecture: README.md
- Root and module commands: .justfile, kubernetes/mod.just, talos/mod.just
- Semantic commit conventions: resources/SemanticCommits.md
- Network and BGP details: kubernetes/apps/kube-system/cilium/README.md
- OIDC and app-specific setup gotchas: kubernetes/apps/default/audiobookshelf/README.md
- Teleport setup details: kubernetes/apps/teleport/README.md
