# Helpful Commands

## Delete all evicted pods

```cli
kubectl get pods --all-namespaces --field-selector 'status.phase==Failed' -o json | kubectl delete -f -
```

- [Source](https://stackoverflow.com/a/54648944/1322471)

## Scale all deployments in a Namespace

```cli
kubectl scale deployment -n <namespace> --replicas 0 --all
```

## Check flux-system KS
```cli
k get ks -A
```

## Check Flux HR
```cli
k get hr -A
```

## Check all backups (volsync)
```
kubectl get replicationsources -A
```

## Expand PVC Storage Size for StatefulSets
```
flux suspend hr <thing>
kubectl delete sts <thing> --cascade=false
kubectl patch pvc thing -p '{"spec": {"resources": {"requests": {"storage": "50Gi"}}}}'
# commit and push changes to HR with new size, wait for reconcile
flux resume hr <thing>
```

---

## SOPS

### To encrypt the file

```cli
sops --encrypt --age $(cat $SOPS_AGE_KEY_FILE |grep -oP "public key: \K(.*)") --encrypted-regex '^(data|stringData)$' --in-place ./secret.sops.yaml
```

### To decrypt the file

```cli
sops --decrypt --age $(cat $SOPS_AGE_KEY_FILE |grep -oP "public key: \K(.*)") --encrypted-regex '^(data|stringData)$' --in-place ./secret.sops.yaml
```

---

## Hardware

### List Disks on Linux with filesystems

```cli
lsblk -f
```

### How to get device UUID path

Example for getting the ID Path for all devices

```cli
ls -la /dev/disk/by-id/*
```

Example for getting the ID Path for a device with nvme in the name:

```cli
ls -la /dev/disk/by-id/* | grep nvme
```

---
