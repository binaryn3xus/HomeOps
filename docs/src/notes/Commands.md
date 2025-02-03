# Commands

## Kubernetes

### Delete all evicted pods

```sh
kubectl get pods --all-namespaces --field-selector 'status.phase==Failed' -o json | kubectl delete -f -
```

- [Source](https://stackoverflow.com/a/54648944/1322471)

### Scale all deployments in a Namespace

```sh
kubectl scale deployment -n <namespace> --replicas 0 --all
```

### Check KS

```sh
k get ks -A
```

### Check HRs

```sh
k get hr -A
```

### Check all backups (volsync)

```sh
kubectl get replicationsources -A
```

### Expand PVC Storage Size for StatefulSets

```sh
flux suspend hr <thing>
kubectl delete sts <thing> --cascade=false
kubectl patch pvc thing -p '{"spec": {"resources": {"requests": {"storage": "50Gi"}}}}'
# commit and push changes to HR with new size, wait for reconcile
flux resume hr <thing>
```

---

## Flux

### Force Reconcile

```sh
flux reconcile -n flux-system source git flux-cluster
flux reconcile -n flux-system kustomization flux-cluster
```

---

## SOPS

### To encrypt the file

```sh
sops --encrypt --age $(cat $SOPS_AGE_KEY_FILE |grep -oP "public key: \K(.*)") --encrypted-regex '^(data|stringData)$' --in-place ./secret.sops.yaml
```

### To decrypt the file

```sh
sops --decrypt --age $(cat $SOPS_AGE_KEY_FILE |grep -oP "public key: \K(.*)") --encrypted-regex '^(data|stringData)$' --in-place ./secret.sops.yaml
```

---

## Hardware

### List Disks on Linux with filesystems

```sh
lsblk -f
```

### How to get device UUID path

Example for getting the ID Path for all devices

```sh
ls -la /dev/disk/by-id/*
```

Example for getting the ID Path for a device with nvme in the name:

```sh
ls -la /dev/disk/by-id/* | grep nvme
```

### Format a drive

Format to ext4

```sh
sudo mkfs -t ext4 /dev/nvme0n1
```

Format to FAT32

```sh
sudo mkfs -t vfat /dev/nvme0n1
```

Format to NTFS

```sh
sudo mkfs -t ntfs /dev/nvme0n1
```

---

## SSH

### Copy SSH Key to Host

```sh
ssh-copy-id -i ~/.ssh/id_rsa joshua@IP_ADDRESS
```
