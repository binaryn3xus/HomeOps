# Cortana Runtime Tools

This instance uses a runtime tools bootstrap pattern to make CLI tools like `gh` and `kubectl` available without baking them into the base image.

## Pattern

1. **`mise.toml`**: Declarative tool configuration (managed by Renovate).
1. **`configMapGenerator`**: Converts `mise.toml` into a Kubernetes ConfigMap.
1. **`initContainer`**:

   - Uses a digest-pinned `mise` image for strict immutability.
   - Installs tools defined in `mise.toml` into a shared `emptyDir` volume (`/tools`).
   - Symlinks binaries into `/tools/bin`.

1. **Main Container**:

   - Mounts the `/tools` volume.
   - Prepends `/tools/bin` to the `PATH`.

## Networking

Egress to port `443` (HTTPS) is explicitly allowed in the `OpenClawInstance` spec to permit the `initContainer` to download tools from GitHub and other providers.

## Tools

Tool versions are pinned in `mise.toml`.

- `gh`: GitHub CLI
- `kubectl`: Kubernetes CLI
- `git`: Git (installed via `apt-get` in the `initContainer`)

## Lifecycle & Persistence

- Tools are reinstalled on pod restart by design (`emptyDir`).
- This avoids persistent tool drift and ensures the pod always starts from a known-good state.
- If startup time becomes an issue in the future, the `tools` volume can be migrated to a persistent cache (PVC).
