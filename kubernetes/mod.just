set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

kubernetes_dir := justfile_dir() + '/kubernetes'

[private]
default:
    just -l kubernetes

# --- Flux & ExternalSecrets Sync ---
[doc('Reconcile flux-system GitRepository and Kustomization')]
reconcile:
    flux --namespace flux-system reconcile kustomization flux-system --with-source

[doc('Reconcile a single Flux Kustomization (with source)')]
reconcile-ks namespace name:
    flux --namespace "{{ namespace }}" reconcile kustomization "{{ name }}" --with-source

[doc('Reconcile a single Flux HelmRelease (with source)')]
reconcile-hr namespace name:
    flux --namespace "{{ namespace }}" reconcile helmrelease "{{ name }}" --with-source

[doc('List all Flux Kustomizations with suspended and ready status')]
reconcile-status:
    kubectl get kustomizations --all-namespaces -o json | \
        jq -r '.items[] | "\(.metadata.namespace)\t\(.metadata.name)\tSuspended: \(.spec.suspend // false)\tReady: \(.status.conditions[]? | select(.type=="Ready") | .status // "Unknown")"' | \
        column -t

[doc('Sync all Flux GitRepositories')]
sync-git:
    kubectl get gitrepo --no-headers -A | while read -r ns name _; do \
        kubectl -n "$ns" annotate --field-manager flux-client-side-apply --overwrite gitrepo "$name" reconcile.fluxcd.io/requestedAt="$(date +%s)"; \
    done

[doc('Sync all Flux HelmReleases')]
sync-hr:
    kubectl get hr --no-headers -A | while read -r ns name _; do \
        kubectl -n "$ns" annotate --field-manager flux-client-side-apply --overwrite hr "$name" reconcile.fluxcd.io/requestedAt="$(date +%s)" reconcile.fluxcd.io/forceAt="$(date +%s)"; \
    done

[doc('Sync all Flux Kustomizations')]
sync-ks:
    kubectl get ks --no-headers -A | while read -r ns name _; do \
        kubectl -n "$ns" annotate --field-manager flux-client-side-apply --overwrite ks "$name" reconcile.fluxcd.io/requestedAt="$(date +%s)"; \
    done

[doc('Sync all Flux OCIRepositories')]
sync-oci:
    kubectl get ocirepo --no-headers -A | while read -r ns name _; do \
        kubectl -n "$ns" annotate --field-manager flux-client-side-apply --overwrite ocirepo "$name" reconcile.fluxcd.io/requestedAt="$(date +%s)"; \
    done

[doc('Sync a single ExternalSecret')]
sync-es namespace secret:
    @kubectl -n "{{ namespace }}" annotate externalsecret "{{ secret }}" force-sync="$(date +%s)" --overwrite

[doc('Sync all ExternalSecrets')]
sync-all-es:
    kubectl get es --no-headers -A | while read -r ns name _; do \
        kubectl -n "$ns" annotate --field-manager flux-client-side-apply --overwrite es "$name" force-sync="$(date +%s)"; \
    done

# --- Cluster & Pod Utilities ---
[doc('Open a privileged debug shell on a node')]
node-shell node:
    kubectl debug node/{{ node }} -n default -it --image="mirror.gcr.io/alpine:latest" --profile sysadmin
    kubectl delete pod -n default -l app.kubernetes.io/managed-by=kubectl-debug

[doc('Prune pods in Failed, Pending, or Succeeded state')]
prune-pods:
    for phase in Failed Pending Succeeded; do \
        kubectl delete pods -A --field-selector status.phase="$phase" --ignore-not-found=true; \
    done

[doc('Read a key from a Kubernetes Secret in plaintext')]
read-secret namespace secret key:
    kubectl get secret "{{ secret }}" -n "{{ namespace }}" -o jsonpath="{.data.{{ key }}}" | base64 --decode

# --- Rook-Ceph & Teleport ---
[doc('Open a bash shell in the Rook Ceph tools pod')]
rook-console:
    kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- /bin/bash

[doc('Clear Rook Ceph crash reports')]
clear-ceph-crashes:
    kubectl -n rook-ceph exec deploy/rook-ceph-tools -- ceph crash archive-all
    kubectl -n rook-ceph exec deploy/rook-ceph-tools -- ceph status

[doc('Renew all Teleport certificates')]
teleport-renew-certs:
    kubectl delete secret -n teleport teleport-intermediary-ca-secret teleport-proxy-internal-cert teleport-proxy-public-cert
    @echo "Teleport certificates deleted. cert-manager will recreate them shortly."
