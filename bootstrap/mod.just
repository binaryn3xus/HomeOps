set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

bootstrap_dir := justfile_dir()

[private]
default:
    just -l bootstrap

[doc('Apply Kubernetes resources')]
resources:
    minijinja-cli resources.yaml.j2 | ../scripts/az-inject.sh | kubectl apply --server-side -f -

[doc('Apply Helmfile CRDs')]
crds:
    helmfile -f "{{ bootstrap_dir }}/helmfile.d/00-crds.yaml" template -q | kubectl apply --server-side -f -

[doc('Apply Helmfile Apps')]
apps:
    helmfile -f "{{ bootstrap_dir }}/helmfile.d/01-apps.yaml" sync --hide-notes
