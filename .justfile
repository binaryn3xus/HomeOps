
set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

mod bootstrap
mod kubernetes
mod talos

[private]
default:
    just -l

[doc('Force Flux to pull in changes from your Git repository')]
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

[doc('Force Flux to refresh all Kustomizations in the cluster (suspend all, wait, then resume all)')]
refresh-all:
    kubectl get kustomizations --all-namespaces -o json | jq -r '.items[] | [.metadata.namespace, .metadata.name] | @tsv' | while IFS=$'\t' read ns name; do flux --namespace "$ns" suspend kustomization "$name"; done
    sleep 3
    kubectl get kustomizations --all-namespaces -o json | jq -r '.items[] | [.metadata.namespace, .metadata.name] | @tsv' | while IFS=$'\t' read ns name; do flux --namespace "$ns" resume kustomization "$name" --timeout=10s; done
