set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

kubernetes_dir := justfile_dir() + '/kubernetes'

[private]
default:
    just -l kubernetes

[doc('Open a shell on a node')]
node-shell node:
    kubectl debug node/{{ node }} -n default -it --image="mirror.gcr.io/alpine:latest" --profile sysadmin
    kubectl delete pod -n default -l app.kubernetes.io/managed-by=kubectl-debug

[doc('Prune pods in Failed, Pending, or Succeeded state')]
prune-pods:
    for phase in Failed Pending Succeeded; do \
        kubectl delete pods -A --field-selector status.phase="$phase" --ignore-not-found=true; \
    done

[doc('Read secret value from secret in plaintext')]
read-secret namespace secret key:
    kubectl get secret '{{secret}}' -n '{{namespace}}' -o jsonpath='{.data.{{key}}}' | base64 --decode

[doc('Sync a single ExternalSecret')]
sync-es namespace secret:
    @kubectl -n '{{namespace}}' annotate externalsecret '{{secret}}' force-sync="$(date +%s)" --overwrite

[doc('Sync All ExternalSecrets')]
sync-all-es:
    kubectl get es --no-headers -A | while read -r ns name _; do \
        kubectl -n "$ns" annotate --field-manager flux-client-side-apply --overwrite es "$name" force-sync="$(date +%s)"; \
    done

[doc('Sync GitRepositories')]
sync-git:
    kubectl get gitrepo --no-headers -A | while read -r ns name _; do \
        kubectl -n "$ns" annotate --field-manager flux-client-side-apply --overwrite gitrepo "$name" reconcile.fluxcd.io/requestedAt="$(date +%s)"; \
    done

[doc('Sync HelmReleases')]
sync-hr:
    kubectl get hr --no-headers -A | while read -r ns name _; do \
        kubectl -n "$ns" annotate --field-manager flux-client-side-apply --overwrite hr "$name" reconcile.fluxcd.io/requestedAt="$(date +%s)" reconcile.fluxcd.io/forceAt="$(date +%s)"; \
    done

[doc('Sync Kustomizations')]
sync-ks:
    kubectl get ks --no-headers -A | while read -r ns name _; do \
        kubectl -n "$ns" annotate --field-manager flux-client-side-apply --overwrite ks "$name" reconcile.fluxcd.io/requestedAt="$(date +%s)"; \
    done

[doc('Sync OCIRepositories')]
sync-oci:
    kubectl get ocirepo --no-headers -A | while read -r ns name _; do \
        kubectl -n "$ns" annotate --field-manager flux-client-side-apply --overwrite ocirepo "$name" reconcile.fluxcd.io/requestedAt="$(date +%s)"; \
    done

[doc('Clear Rook Ceph Crash Reports')]
clear-ceph-crashes:
    kubectl -n rook-ceph exec deploy/rook-ceph-tools -- ceph crash archive-all
    kubectl -n rook-ceph exec deploy/rook-ceph-tools -- ceph status
