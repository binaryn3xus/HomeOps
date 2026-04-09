# Manifest Templates for Argo-VolSync Migration

## 1. replicationsource.yaml
```yaml
---
# yaml-language-server: $schema=https://kubernetes-schemas.pages.dev/volsync.backube/replicationsource_v1alpha1.json
apiVersion: volsync.backube/v1alpha1
kind: ReplicationSource
metadata:
  name: {{ .app }}
  annotations:
    argocd.argoproj.io/sync-options: Prune=false
spec:
  sourcePVC: {{ .app }}
  trigger:
    schedule: "0 * * * *"
  kopia:
    accessModes: ["ReadWriteOnce"]
    cacheAccessModes: ["ReadWriteOnce"]
    cacheCapacity: {{ .volsync_capacity }}
    cacheStorageClassName: openebs-hostpath
    compression: zstd-fastest
    copyMethod: Snapshot
    moverSecurityContext:
      runAsUser: 1000
      runAsGroup: 1000
      fsGroup: 1000
    repository: volsync-kopia-secret
    retain:
      hourly: 24
      daily: 7
    storageClassName: ceph-block
    volumeSnapshotClassName: csi-ceph-blockpool
```

## 2. replicationdestination.yaml
```yaml
---
# yaml-language-server: $schema=https://kubernetes-schemas.pages.dev/volsync.backube/replicationdestination_v1alpha1.json
apiVersion: volsync.backube/v1alpha1
kind: ReplicationDestination
metadata:
  name: {{ .app }}-dst
spec:
  trigger:
    manual: restore-once
  kopia:
    accessModes: ["ReadWriteOnce"]
    cacheAccessModes: ["ReadWriteOnce"]
    cacheCapacity: {{ .volsync_capacity }}
    cacheStorageClassName: openebs-hostpath
    capacity: {{ .volsync_capacity }}
    cleanupCachePVC: true
    cleanupTempPVC: true
    copyMethod: Snapshot
    enableFileDeletion: true
    moverSecurityContext:
      runAsUser: 1000
      runAsGroup: 1000
      fsGroup: 1000
    repository: volsync-kopia-secret
    sourceIdentity:
      sourceName: {{ .app }}
    storageClassName: ceph-block
    volumeSnapshotClassName: csi-ceph-blockpool
```

## 3. pvc.yaml
```yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ .app }}
spec:
  accessModes: ["ReadWriteOnce"]
  dataSourceRef:
    kind: ReplicationDestination
    apiGroup: volsync.backube
    name: {{ .app }}-dst
  resources:
    requests:
      storage: {{ .volsync_capacity }}
  storageClassName: ceph-block
```
