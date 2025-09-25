set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

# --- Module Imports ---
mod bootstrap
mod kubernetes
mod talos

# --- Private Recipes ---
[private]
default:
    just -l

[private]
template file *args:
    minijinja-cli "{{ file }}" {{ args }} | ./scripts/az-inject.sh

# --- Utility Recipes ---
[doc('Force Flux reconcile Git repository changes')]
reconcile:
    flux --namespace flux-system reconcile kustomization flux-system --with-source

[doc('Backup PiKVM Override File')]
pikvm-backup:
    scp root@10.0.30.5:/etc/kvmd/override.yaml ./docs/pikvm/override.yaml

[doc('Backup Configuration Files')]
configuration-backup backup_datetime=`date +%Y%m%d-%H%M`:
    mkdir -p ./.private/backups/"{{backup_datetime}}"
    cp -r ./talos/clusterconfig/ ./.private/backups/"{{backup_datetime}}"/
    cp ./kubeconfig ./.private/backups/"{{backup_datetime}}"/
    cp ./age.key ./.private/backups/"{{backup_datetime}}"/

[doc('Force Flux to refresh a Kustomization')]
refresh namespace name:
    flux --namespace "{{namespace}}" suspend kustomization "{{name}}"
    sleep 3
    flux --namespace "{{namespace}}" resume kustomization "{{name}}"

[doc('Force Flux to refresh all Kustomizations in the cluster')]
refresh-all:
    kubectl get kustomizations --all-namespaces -o json | jq -r '.items[] | [.metadata.namespace, .metadata.name] | @tsv' | while IFS=$'\t' read ns name; do flux --namespace "$ns" suspend kustomization "$name"; done
    sleep 3
    kubectl get kustomizations --all-namespaces -o json | jq -r '.items[] | [.metadata.namespace, .metadata.name] | @tsv' | while IFS=$'\t' read ns name; do flux --namespace "$ns" resume kustomization "$name" --timeout=10s; done

[doc('Read a secret from Azure Key Vault')]
read-az-secret secret_name:
    @az keyvault secret show --vault-name "K8sHomeOpsKeyVault" --name "{{secret_name}}" --query 'value' -o tsv
