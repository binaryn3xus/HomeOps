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
    minijinja-cli -a none "{{ file }}" {{ args }} | ./az-inject.sh

# --- Quick Shortcuts ---
[doc('Force Flux to reconcile the cluster from Git')]
reconcile:
    flux --namespace flux-system reconcile kustomization flux-system --with-source

# --- Azure Key Vault Integration ---
[doc('Read a secret from Azure Key Vault')]
read-az-secret secret_name vault_name="K8sHomeOpsKeyVault":
    @az keyvault secret show --vault-name "{{ vault_name }}" --name "{{ secret_name }}" --query 'value' -o tsv

[doc('Write a secret to Azure Key Vault (handles multi-line)')]
write-az-secret secret_name file_path="" overwrite="false" vault_name="K8sHomeOpsKeyVault":
    #!/usr/bin/env bash
    set -euo pipefail
    EXISTS=$(az keyvault secret list --vault-name "{{ vault_name }}" --query "[?name=='{{ secret_name }}']" -o tsv)

    if [[ -n "$EXISTS" && "{{ overwrite }}" != "true" ]]; then
        echo "Error: Secret '{{ secret_name }}' already exists in {{ vault_name }}."
        echo "Use 'overwrite=true' to force update."
        exit 1
    fi

    if [[ -z "{{ file_path }}" ]]; then
        echo "Reading secret value from stdin (Ctrl+D to finish)..."
        VALUE=$(cat)
    else
        VALUE=$(cat "{{ file_path }}")
    fi

    echo "$VALUE" | az keyvault secret set --vault-name "{{ vault_name }}" --name "{{ secret_name }}" --file /dev/stdin > /dev/null
    echo "✔ Secret '{{ secret_name }}' successfully saved to {{ vault_name }}."

[doc('Report Key Vault secret usage in repo')]
kv-usage-report vault_name="K8sHomeOpsKeyVault":
    ./resources/scripts/kv_usage_report.sh "{{ vault_name }}"

# --- YAML Utilities ---
[doc('Sort a YAML file at .spec level')]
sort-spec file:
    yq -i '.spec |= sort_keys(..)' "{{ file }}"
    @echo "Sorted .spec keys in '{{ file }}'"

[doc('Sort a YAML file at .resources level')]
sort-resources file:
    yq -i '.resources |= sort' "{{ file }}"
    @echo "Sorted .resources keys in '{{ file }}'"

# --- Host & Device Backups ---
[doc('Backup PiKVM override.yaml to repo')]
pikvm-backup:
    scp root@10.0.30.5:/etc/kvmd/override.yaml ./resources/pikvm/override.yaml

[doc('Backup current config.fish to repo')]
fish-backup:
    mkdir -p ./resources/fish
    cp ~/.config/fish/config.fish ./resources/fish/config.fish

[doc('Restore config.fish to system')]
fish-restore:
    mkdir -p ~/.config/fish
    cp ./resources/fish/config.fish ~/.config/fish/config.fish

# --- Gaming (Satisfactory) ---
[doc('Import Satisfactory blueprints from .private/satisfactory/blueprints to server pod')]
import-satisfactory-blueprints source_dir="./.private/satisfactory/blueprints" session="Project-MJOLNIR":
    ./resources/scripts/import-satisfactory-blueprints.sh "{{ source_dir }}" "{{ session }}"

[doc('Download Satisfactory save file from server pod (defaults to latest save)')]
download-satisfactory-save save_name="" dest_dir="./.private/satisfactory/saves":
    ./resources/scripts/download-satisfactory-save.sh "{{ save_name }}" "{{ dest_dir }}"

# --- Help Docs ---
[doc('Serve help docs locally with live reload at http://localhost:8000')]
help-serve:
    docker run --rm -it -u $(id -u):$(id -g) -p 8000:8000 -v ./resources/help-docs:/docs squidfunk/mkdocs-material serve -a 0.0.0.0:8000

[doc('Build help docs locally with strict checking')]
help-build:
    docker run --rm -u $(id -u):$(id -g) -v ./resources/help-docs:/docs squidfunk/mkdocs-material build --strict
