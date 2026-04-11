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
    minijinja-cli "{{ file }}" {{ args }} | ./az-inject.sh

# --- PikVM Backup ---
[doc('Backup PiKVM Override File')]
pikvm-backup:
    scp root@10.0.30.5:/etc/kvmd/override.yaml ./resources/pikvm/override.yaml

# --- Configuration Backups ---
[doc('Backup Configuration Files')]
configuration-backup backup_datetime=`date +%Y%m%d-%H%M`:
    mkdir -p ./.private/backups/"{{backup_datetime}}"
    cp -r ./talos/ ./.private/backups/"{{backup_datetime}}"/
    cp ./kubeconfig ./.private/backups/"{{backup_datetime}}"/
    cp ./age.key ./.private/backups/"{{backup_datetime}}"/

# --- ArgoCD Management ---
[doc('Sync all ArgoCD applications')]
argocd-sync-all:
    argocd app sync -l argocd.argoproj.io/instance=argocd

[doc('Get status of all ArgoCD applications')]
argocd-status:
    argocd app list

[doc('Sync a specific ArgoCD application')]
argocd-app-sync namespace name:
    argocd app sync "{{name}}"

[doc('Get status of a specific ArgoCD application')]
argocd-app-status namespace name:
    argocd app get "{{name}}"

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

# --- Fish ---
[doc('Backup current config.fish to repo')]
fish-backup:
    mkdir -p ./resources/fish
    cp ~/.config/fish/config.fish ./resources/fish/config.fish

[doc('Restore config.fish to system')]
fish-restore:
    mkdir -p ~/.config/fish
    cp ./resources/fish/config.fish ~/.config/fish/config.fish

# --- Gemini ---
[doc('Open Gemini Settings Json in Editor')]
gemini-settings:
    nano "~/.gemini/settings.json"

[doc('Report Key Vault secret usage in repo')]
kv-usage-report vault_name="K8sHomeOpsKeyVault":
    ./scripts/kv_usage_report.sh "{{vault_name}}"
