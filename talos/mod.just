set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

# --- Private Recipes ---
[private]
default:
    just -l talos

[doc('Apply Talos config to a node')]
apply-node ip *args:
    talosctl -n "{{ ip }}" apply-config -f "./generated/{{ip}}.yaml" {{ args }}

[doc('Render Talos config for a node')]
render-config ip:
    mkdir -p ./generated
    just template talos/machineconfig.yaml.j2 | \
      yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' - "./nodes/{{ip}}.yaml.j2" | \
      yq 'select(documentIndex == 0) | with(.machine; sort_keys(.)) | with(.cluster; sort_keys(.))' > "./generated/{{ip}}.yaml"
    @echo "Rendered config for '{{ip}}' written to ./generated/{{ip}}.yaml"

[doc('Render Talos client config with secrets injected')]
render-talosconfig:
    just template talos/talosconfig.yaml.j2 > ./talosconfig
    @echo "Rendered Talos client config written to talos/talosconfig"

[doc('Backup the configuration spec from a node to a file')]
backup-config ip:
    @talosctl -n "{{ip}}" get mc -o yaml | yq eval '.spec' - > "{{ip}}-backup.yaml"
    @echo "Configuration spec for node '{{ip}}' has been backed up to '{{ip}}-backup.yaml'"

# --- Cluster and Node Upgrades ---
[doc('Upgrade Kubernetes version on the cluster')]
upgrade-k8s version:
    controller := `talosctl config info -o yaml | yq -e '.endpoints[0]'`
    talosctl -n "$controller" upgrade-k8s --to {{ version }}

[doc('Dryrun Upgrade Kubernetes version on the cluster')]
upgrade-k8s-dryrun version:
    controller := `talosctl config info -o yaml | yq -e '.endpoints[0]'`
    talosctl -n "$controller" upgrade-k8s --to {{ version }} --dry-run

[doc('Upgrade Talos version on a node')]
upgrade-node ip:
    talosctl -n "{{ ip }}" upgrade -i "$(just talos machine-image)" -m powercycle --timeout=10m

# --- Node Power Management ---
[doc('Reboot a node')]
reboot-node ip:
    @printf "Reboot node {{ip}}? [y/N] "
    @read -r response; \
    if [[ "$$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then \
        talosctl -n {{ ip }} reboot -m powercycle; \
    fi

[doc('Reset a node')]
reset-node ip:
    @printf "Reset node {{ip}}? [y/N] "
    @read -r response; \
    if [[ "$$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then \
        talosctl -n {{ ip }} reset --graceful=false; \
    fi

[doc('Shutdown a node')]
shutdown-node ip:
    @printf "Shutdown node {{ip}}? [y/N] "
    @read -r response; \
    if [[ "$$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then \
        talosctl -n {{ ip }} shutdown --force; \
    fi


# --- Private Helper Recipes ---
[private]
machine-image:
    just talos render-config fleetcom-node1 | yq -e 'select(.machine) | .machine.install.image'
