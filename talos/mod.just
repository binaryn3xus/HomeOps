set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

talos_dir := justfile_dir() + '/talos'

# --- Private Recipes ---
[private]
default:
    just -l talos

[doc("Show Talos Dashboard")]
dashboard node:
    talosctl dashboard -n "{{ node }}"

[confirm('Apply Talos config to ' + node + ' [y|N] ?')]
[doc('Apply Talos config to a node')]
apply-node node *args:
    just talos render-config "{{ node }}" | talosctl -n "{{ node }}" apply-config -f /dev/stdin {{ args }}

[doc('Download Talos machine image ISO')]
download-image version node="":
    @schematic="$(just talos schematic-id "{{ node }}")"; \
    echo "Downloading Talos {{ version }} ISO (${schematic:0:8})..."; \
    curl -fL --remove-on-error --retry 5 --retry-delay 5 --retry-all-errors --progress-bar \
        -o "{{ talos_dir }}/talos-{{ version }}-${schematic:0:8}.iso" \
        "https://factory.talos.dev/image/${schematic}/{{ version }}/metal-amd64.iso"; \
    echo "Downloaded Talos {{ version }} ISO (${schematic:0:8}) to {{ talos_dir }}"

[doc('Render Talos config for a node')]
render-config node:
    @schematic="$(just talos schematic-id "{{ node }}")"; \
    node_file=""; \
    for f in "{{ talos_dir }}"/nodes/*/"{{ node }}".yaml.j2; do \
        [[ -f "$f" ]] && node_file="$f"; \
    done; \
    if [[ -z "$node_file" ]]; then \
        echo "Error: Node config not found for {{ node }}" >&2; \
        exit 1; \
    fi; \
    role="controlplane"; \
    [[ "$node_file" == *"/worker/"* ]] && role="worker"; \
    talosctl machineconfig patch <(just template "{{ talos_dir }}/cluster.yaml.j2" -D "schematic=${schematic}") \
        -p @<(just template "{{ talos_dir }}/${role}.yaml.j2") \
        -p @<(just template "${node_file}")

[doc('Render Talos client config with secrets injected')]
render-talosconfig:
    just template "{{ talos_dir }}/talosconfig.yaml.j2" > "{{ talos_dir }}/talosconfig"
    @echo "Rendered Talos client config written to {{ talos_dir }}/talosconfig"

[doc('Show talosconfig context and certificate expiration')]
config-info:
    talosctl --talosconfig "{{ talos_dir }}/talosconfig" config info

[confirm('Renew Talos client certificate and update talosconfig [y|N] ?')]
[doc('Renew Talos client certificate via controlplane node')]
renew-talosconfig node="10.0.30.11" ttl="8760h":
    #!/usr/bin/env bash
    set -euo pipefail
    tmp_dir=$(mktemp -d)
    trap 'rm -rf "$tmp_dir"' EXIT
    tmp_config="$tmp_dir/talosconfig"
    echo "Requesting new client certificate from {{ node }} (TTL: {{ ttl }})..."
    talosctl -n "{{ node }}" config new "$tmp_config" --roles os:admin --crt-ttl "{{ ttl }}"
    crt=$(yq eval '.contexts[].crt' "$tmp_config")
    key=$(yq eval '.contexts[].key' "$tmp_config")
    yq eval -i ".contexts.fleetcom.crt = \"$crt\" | .contexts.fleetcom.key = \"$key\"" "{{ talos_dir }}/talosconfig"
    echo "Updated {{ talos_dir }}/talosconfig with newly issued client certificate."
    echo ""
    talosctl --talosconfig "{{ talos_dir }}/talosconfig" config info
    echo ""
    echo "Run 'just talos backup-talosconfig' to push the renewed credentials to Azure Key Vault."

[confirm('Backup talosconfig to Azure Key Vault [y|N] ?')]
[doc('Backup talosconfig to Azure Key Vault')]
backup-talosconfig:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Uploading full talosconfig to Azure Key Vault (Talos-Config)..."
    az keyvault secret set --vault-name "K8sHomeOpsKeyVault" --name "Talos-Config" --file "{{ talos_dir }}/talosconfig" > /dev/null
    echo "Extracting crt and key to sync split secrets (Talos-Config-Crt, Talos-Config-Key)..."
    crt=$(yq eval '.contexts.fleetcom.crt // .contexts.kubernetes.crt' "{{ talos_dir }}/talosconfig")
    key=$(yq eval '.contexts.fleetcom.key // .contexts.kubernetes.key' "{{ talos_dir }}/talosconfig")
    az keyvault secret set --vault-name "K8sHomeOpsKeyVault" --name "Talos-Config-Crt" --value "$crt" > /dev/null
    az keyvault secret set --vault-name "K8sHomeOpsKeyVault" --name "Talos-Config-Key" --value "$key" > /dev/null
    echo "Successfully synced Talos-Config, Talos-Config-Crt, and Talos-Config-Key in Azure Key Vault."

[doc('Backup the configuration spec from a node to a file')]
backup-config ip:
    @talosctl -n "{{ip}}" get mc -o yaml | yq eval '.spec' - > "{{ip}}-backup.yaml"
    @echo "Configuration spec for node '{{ip}}' has been backed up to '{{ip}}-backup.yaml'"

[confirm('Upgrade Kubernetes to ' + version + ' [y|N] ?')]
[doc('Upgrade Kubernetes version on the cluster')]
upgrade-k8s ip version:
    talosctl -n "{{ ip }}" upgrade-k8s --to {{ version }}

[confirm('Upgrade Talos version on ' + node + ' [y|N] ?')]
[doc('Upgrade Talos version on a node')]
upgrade-node node *args:
    talosctl -n "{{ node }}" upgrade -i "$(just talos machine-image "{{ node }}")" -m powercycle --timeout=10m {{ args }}

# --- Node Power Management ---
[confirm('Reboot node ' + node + ' [y|N] ?')]
[doc('Reboot a node')]
reboot-node node:
    talosctl -n {{ node }} reboot -m powercycle

[confirm('Reset node ' + node + ' [y|N] ?')]
[doc('Reset a node')]
reset-node node *args:
    talosctl -n "{{ node }}" reset --graceful=false {{ args }}

[confirm('Shutdown node ' + node + ' [y|N] ?')]
[doc('Shutdown a node')]
shutdown-node node *args:
    talosctl -n "{{ node }}" shutdown --force {{ args }}

# --- Private Helper Recipes ---
[private]
schematic-file node="":
    #!/usr/bin/env bash
    file="{{ talos_dir }}/schematic.yaml.j2"
    if [[ -n "{{ node }}" ]]; then
        for f in "{{ talos_dir }}"/nodes/*/"{{ node }}".schematic.yaml.j2; do
            [[ -f "$f" ]] && file="$f"
        done
    fi
    echo "$file"

[private]
schematic-id node="":
    #!/usr/bin/env bash
    schematic_file="$(just talos schematic-file "{{ node }}")"
    curl -sX POST --data-binary @<(just template "$schematic_file") "https://factory.talos.dev/schematics" | jq -r '.id'

[private]
machine-image node="" version="":
    #!/usr/bin/env bash
    ver="{{ version }}"
    if [[ -z "$ver" ]]; then
        ver="$(grep -o 'factory.talos.dev/installer/.*:v[0-9.]\+' "{{ talos_dir }}/cluster.yaml.j2" | cut -d: -f2)"
    fi
    echo "factory.talos.dev/installer/$(just talos schematic-id "{{ node }}"):${ver}"
