#!/usr/bin/env bash

# ==============================================================================
# APP MIGRATION & VOLSYNC RESTORE TOOL
# ==============================================================================
# This tool automates moving an application from one namespace to another
# while preserving its data using VolSync/Kopia snapshots.
#
# PREREQUISITES:
# 1. Move the app folder in the repository and update kustomizations.
# 2. Push changes so Flux creates the new (empty) app and its Secrets/PVCs.
# 3. Ensure the target namespace has a VolSync secret (e.g. <app>-volsync-secret).
#
# USAGE:
#   just migrate-app <src_app> <src_ns> [dst_ns] [snap_id_or_date] [dst_app] [dst_pvc]
#
# EXAMPLES:
#   1. List snapshots:
#      just migrate-app sonarr default
#
#   2. Move app (keep name, latest data):
#      just migrate-app sonarr default media
#
#   3. Move app (specific date):
#      just migrate-app sonarr default media 2026-04-25
#
#   4. Move & Rename app (e.g. overseerr -> seerr):
#      just migrate-app overseerr default media latest seerr
#
#   5. Move, Rename, and specify a custom PVC:
#      just migrate-app sabnzbd default media latest sabnzbd sabnzbd-config
#
# WHAT IT DOES:
# - Auto-detects the Kopia snapshot for the source identity (src_app@src_ns).
# - Adds a shared Synology Media PV for the new namespace if missing.
# - Suspends the Flux Kustomization for the target app to prevent conflicts.
# - Scales down the target app to avoid database locks.
# - Wipes the destination /config directory (leaving lost+found).
# - Runs a manual Kopia restore Job from the chosen snapshot.
# - Automatically detects file ownership from the deployment or defaults to 1000:1000.
# - Resumes Flux to bring the app back online.
# ==============================================================================

# Check for required arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <source_app_name> <from_namespace> [to_namespace] [date_or_id] [to_app_name] [to_pvc_name]"
    exit 1
fi

SRC_APP=$1
FROM_NS=$2
TO_NS=$3
SEARCH_STR=$4
TO_APP=${5:-$SRC_APP}
TO_PVC=$6

# 0. Find the Kopia pod
KOPIA_POD=$(kubectl get pods -n volsync-system -l app.kubernetes.io/name=kopia -o name | head -n 1)
if [ -z "$KOPIA_POD" ]; then
    echo "Error: Could not find Kopia pod in volsync-system."
    exit 1
fi

# 1. Fetch snapshot block for this identity
BLOCK=$(kubectl exec -n volsync-system "$KOPIA_POD" -- kopia snapshot list --all | \
        sed -n "/^${SRC_APP}@${FROM_NS}:/,/^[a-z]/p" | grep "^  ")

if [ -z "$BLOCK" ]; then
    echo "Error: No snapshots found for ${SRC_APP}@${FROM_NS}"
    exit 1
fi

# 2. Handle Listing vs Migration
if [ -z "$TO_NS" ]; then
    echo "Available snapshots for ${SRC_APP}@${FROM_NS}:"
    echo "$BLOCK"
    exit 0
fi

# 3. Resolve SNAP_ID
if [ -n "$SEARCH_STR" ] && [ "$SEARCH_STR" != "latest" ]; then
    echo "Searching for snapshot matching '${SEARCH_STR}'..."
    MATCH=$(echo "$BLOCK" | grep "$SEARCH_STR" | tail -n 1)
    if [ -z "$MATCH" ]; then
        echo "Error: No snapshot found matching '${SEARCH_STR}'"
        exit 1
    fi
    SNAP_ID=$(echo "$MATCH" | awk '{print $4}')
    echo "✔ Resolved to snapshot ID: ${SNAP_ID} (${SEARCH_STR})"
else
    echo "Selecting latest snapshot from ${SRC_APP}@${FROM_NS}..."
    SNAP_ID=$(echo "$BLOCK" | grep "latest-1" | awk '{print $4}')
    if [ -z "$SNAP_ID" ]; then
        SNAP_ID=$(echo "$BLOCK" | tail -n 1 | awk '{print $4}')
    fi
    echo "✔ Found latest snapshot: ${SNAP_ID}"
fi

# 4. Resolve TO_PVC (Default to detected or to_app_name)
DEPLOY_INFO=$(kubectl get deployment -n "${TO_NS}" "${TO_APP}" -o json 2>/dev/null)
if [ -z "$TO_PVC" ]; then
    echo "Attempting to detect PVC name for app '${TO_APP}'..."
    TO_PVC=$(echo "$DEPLOY_INFO" | jq -r '.spec.template.spec.volumes[] | select(.name=="config") | .persistentVolumeClaim.claimName' 2>/dev/null)
    if [ -z "$TO_PVC" ] || [ "$TO_PVC" == "null" ]; then
        TO_PVC=$TO_APP
        echo "Could not detect PVC from deployment 'config' volume. Using: ${TO_PVC}"
    else
        echo "✔ Detected PVC name: ${TO_PVC}"
    fi
fi

# 5. Detect UID/GID
RUN_AS_USER=$(echo "$DEPLOY_INFO" | jq -r '.spec.template.spec.securityContext.runAsUser // .spec.template.spec.containers[0].securityContext.runAsUser // 1000' 2>/dev/null)
RUN_AS_GROUP=$(echo "$DEPLOY_INFO" | jq -r '.spec.template.spec.securityContext.runAsGroup // .spec.template.spec.containers[0].securityContext.runAsGroup // 1000' 2>/dev/null)
FS_GROUP=$(echo "$DEPLOY_INFO" | jq -r '.spec.template.spec.securityContext.fsGroup // 1000' 2>/dev/null)

# For Arrs, we usually want 568:1000, but we'll trust the deployment if it says 1000
echo "✔ Detected ownership requirements: UID=${RUN_AS_USER}, GID=${FS_GROUP}"

echo "--- PHASE 1: STORAGE PREPARATION ---"

STORAGE_FILE="kubernetes/apps/synology-storage.yaml"
PV_NAME="synology-media-${TO_NS}"
if ! grep -q "name: ${PV_NAME}" "$STORAGE_FILE"; then
    echo "Adding PV for ${TO_NS} to ${STORAGE_FILE}..."
    cat >> "$STORAGE_FILE" <<EOF
---
# Shared Media PV for ${TO_NS} namespace
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${PV_NAME}
spec:
  storageClassName: synology-nfs
  capacity:
    storage: 1Mi
  accessModes: ["ReadWriteMany"]
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: "10.0.30.4"
    path: /volume1/Media
  mountOptions: [ "nfsvers=4.1", "nconnect=8", "hard", "noatime", "rsize=131072", "wsize=131072" ]
EOF
else
    echo "✔ Shared PV for ${TO_NS} exists."
fi

echo "--- PHASE 2: CLUSTER OPERATIONS ---"

# 5. Suspend Flux for the target app
echo "Suspending Kustomization ${TO_APP} in ${TO_NS}..."
flux suspend ks "${TO_APP}" -n "${TO_NS}" 2>/dev/null || true

# 6. Scale down target app
echo "Scaling down ${TO_APP} in ${TO_NS}..."
kubectl scale deployment -n "${TO_NS}" "${TO_APP}" --replicas=0 2>/dev/null || true

# 7. Manual Restore Job
RESTORE_JOB_FILE="restore-${TO_APP}-manual.yaml"
echo "Restoring ${SRC_APP}@${FROM_NS} -> ${TO_APP}@${TO_NS} (PVC: ${TO_PVC})..."
cat > "$RESTORE_JOB_FILE" <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: ${TO_APP}-manual-restore
  namespace: ${TO_NS}
spec:
  template:
    spec:
      containers:
        - name: kopia
          image: ghcr.io/perfectra1n/volsync:v0.17.11
          command: ["sh", "-c"]
          args:
            - |
              export KOPIA_CACHE_DIR=/tmp/kopia-cache
              export KOPIA_CHECK_FOR_UPDATES=false
              mkdir -p \$KOPIA_CACHE_DIR
              echo "Connecting to repository..."
              kopia repository connect filesystem --path=/repository --password="\$KOPIA_PASSWORD" --override-hostname=${FROM_NS} --override-username=${SRC_APP}
              echo "Cleaning destination..."
              find /config -mindepth 1 -maxdepth 1 ! -name 'lost+found' -exec rm -rf {} +
              echo "Restoring snapshot ${SNAP_ID}..."
              kopia snapshot restore ${SNAP_ID} /config --progress --log-level=info
              echo "Fixing permissions (${RUN_AS_USER}:${FS_GROUP})..."
              chown -R ${RUN_AS_USER}:${FS_GROUP} /config
              find /config -type d -exec chmod 775 {} +
              find /config -type f -exec chmod 664 {} +
              echo "Restore complete!"
          env:
            - name: KOPIA_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: ${TO_APP}-volsync-secret
                  key: KOPIA_PASSWORD
          volumeMounts:
            - name: config
              mountPath: /config
            - name: repository
              mountPath: /repository
      restartPolicy: Never
      volumes:
        - name: config
          persistentVolumeClaim:
            claimName: ${TO_PVC}
        - name: repository
          nfs:
            server: "10.0.30.4"
            path: "/volume1/Kubernetes/VolsyncKopia"
EOF

kubectl apply -f "$RESTORE_JOB_FILE"
kubectl wait --for=condition=complete job/"${TO_APP}-manual-restore" -n "${TO_NS}" --timeout=20m

# 8. Cleanup and Resume Flux
kubectl delete -f "$RESTORE_JOB_FILE"
rm "$RESTORE_JOB_FILE"
echo "Resuming Kustomization ${TO_APP}..."
flux resume ks "${TO_APP}" -n "${TO_NS}"

echo "--- MIGRATION COMPLETE ---"
