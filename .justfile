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

# --- PikVM Backup ---
[doc('Backup PiKVM Override File')]
pikvm-backup:
    scp root@10.0.30.5:/etc/kvmd/override.yaml ./docs/pikvm/override.yaml

# --- Configuration Backups ---
[doc('Backup Configuration Files')]
configuration-backup backup_datetime=`date +%Y%m%d-%H%M`:
    mkdir -p ./.private/backups/"{{backup_datetime}}"
    cp -r ./talos/ ./.private/backups/"{{backup_datetime}}"/
    cp ./kubeconfig ./.private/backups/"{{backup_datetime}}"/
    cp ./age.key ./.private/backups/"{{backup_datetime}}"/

# --- Flux Management ---
[doc('Force Flux reconcile Git repository changes')]
reconcile:
    flux --namespace flux-system reconcile kustomization flux-system --with-source

[doc('Force Flux to refresh a Kustomization')]
reconcile-app namespace name:
    flux --namespace "{{namespace}}" suspend kustomization "{{name}}"
    sleep 2
    flux --namespace "{{namespace}}" resume kustomization "{{name}}"

[doc('Force Flux to refresh all Kustomizations in the cluster')]
reconcile-all:
    kubectl get kustomizations --all-namespaces -o json | jq -r '.items[] | [.metadata.namespace, .metadata.name] | @tsv' | while IFS=$'\t' read ns name; do flux --namespace "$ns" suspend kustomization "$name"; done
    sleep 2
    kubectl get kustomizations --all-namespaces -o json | jq -r '.items[] | [.metadata.namespace, .metadata.name] | @tsv' | while IFS=$'\t' read ns name; do flux --namespace "$ns" resume kustomization "$name" --timeout=10s; done

[doc('List all Kustomizations with suspended and ready status')]
reconcile-status:
    kubectl get kustomizations --all-namespaces -o json | \
    jq -r '.items[] | "\(.metadata.namespace)\t\(.metadata.name)\tSuspended: \(.spec.suspend // false)\tReady: \(.status.conditions[]? | select(.type=="Ready") | .status // "Unknown")"' | \
    column -t

# --- Azure Key Vault Integration ---
[doc('Read a secret from Azure Key Vault')]
read-az-secret secret_name:
    @az keyvault secret show --vault-name "K8sHomeOpsKeyVault" --name "{{secret_name}}" --query 'value' -o tsv

# --- YAML Sorting ---
[doc('Sort a YAML file at .spec level')]
sort-spec file:
    yq -i '.spec |= sort_keys(..)' "{{ file }}"
    @echo "Sorted .spec keys in '{{ file }}'"

[doc('Sort a YAML file at .resource level')]
sort-resources file:
    yq '.resources |= sort' -i "{{ file }}"
    @echo "Sorted .resources keys in '{{ file }}'"
