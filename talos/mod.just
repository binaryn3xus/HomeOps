set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

scripts_dir := justfile_dir() + '/scripts'
talos_dir := justfile_dir() + '/talos'
controller := `talosctl config info -o yaml | yq -e '.endpoints[0]'`

[private]
default:
    just -l talos

[doc('Apply Talos config to a node by name')]
apply-config node:
    talosctl apply-config -n "{{node}}" --file "./kubernetes/bootstrap/talos/clusterconfig/{{node}}.yaml"

[doc('Upgrade Kubernetes version on the cluster')]
upgrade-k8s version:
    talosctl -n "{{ controller }}" upgrade-k8s --to {{ version }}

[doc('Dryrun Upgrade Kubernetes version on the cluster')]
upgrade-k8s-dryrun version:
    talosctl -n "{{ controller }}" upgrade-k8s --to {{ version }} --dry-run
