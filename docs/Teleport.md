# Teleport Notes

## Cluster Commands

Most commands that start with `kubectl exec -i deployment/teleport-auth -n teleport -- ` are run from a terminal that has access to the Cluster using kubectl.

### Check inventory

```bash
kubectl exec -i deployment/teleport-auth -n teleport -- tctl inventory status --connected
```

### List Server Nodes

```bash
kubectl exec -i deployment/teleport-auth -n teleport -- tctl nodes ls
```

### CLI on Nodes/Servers

```bash
sudo pkill -f teleport /
&& sudo rm -rf /var/lib/teleport /
&& sudo rm -f /etc/teleport.yaml /
&& sudo rm -f /usr/local/bin/teleport /usr/local/bin/tctl /usr/local/bin/tsh /
&& sudo apt remove teleport -y
```
