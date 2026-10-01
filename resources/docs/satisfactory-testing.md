# Satisfactory Server (Temporary Pre-Testing)

This document describes the temporary pre-testing deployment of Satisfactory 1.2 on the dedicated Docker host alongside Palworld, prior to migrating Satisfactory to a dedicated Talos node in the Kubernetes cluster.

## Architecture & Storage

- **Container Image**: `wolveix/satisfactory-server:latest` (Satisfactory 1.2 stable)
- **Container Name**: `satisfactory-server`
- **Compose Location**: `/home/joshua/palworld/docker-compose.yml` (managed via [`docker-compose.template.yaml`](../palworld-server/docker/docker-compose.template.yaml))
- **Environment File**: `/home/joshua/palworld/satisfactory.env` (managed via [`satisfactory.env.template`](../palworld-server/docker/satisfactory.env.template))
- **Persistent Data Volume**: `/mnt/fastdata/satisfactory-data:/config`
  - `/config/saved`: Game saves, blueprints, and server configuration
  - `/config/backups`: Automatic backups created by the container
  - `/config/gamefiles`: Downloaded Steam Dedicated Server files

By isolating all Satisfactory data into `/mnt/fastdata/satisfactory-data`, the deployment is completely separate from Palworld (`/mnt/fastdata/palworld-data`), Portainer, and Dashboard.

## Network & Ports

Satisfactory 1.2 requires the following ports:

| Port | Protocol | Purpose |
| --- | --- | --- |
| 7777 | UDP | Game traffic & query |
| 7777 | TCP | Server connection |
| 8888 | TCP | Reliable messaging / API |

### Tailscale ACL Configuration

To allow players connecting via Tailscale without exposing router port forwards, add a grant to your Tailscale ACL policy targeting `tag:palworld`:

```json
{
  "src": ["autogroup:shared"],
  "dst": ["tag:palworld"],
  "ip":  ["udp:7777", "tcp:7777", "tcp:8888"]
}
```

Players can then connect directly using the host's Tailnet IP or MagicDNS name and port `7777`.


## Operations & Monitoring

- **Portainer**: View logs, CPU/memory usage, and restart the container via `https://portainer.unscfleet.com`.
- **First-time Setup**: When connecting from the Satisfactory game client for the first time:
  1. Open the in-game **Server Manager**.
  2. Add the server IP/Tailscale IP and port `7777`.
  3. Claim the server and configure the administrator password and server name.

## Migration & Decommissioning / Cleanup Checklist

When the new Talos node is added to the cluster and Satisfactory is ready to move into Kubernetes:

### 1. Preserve Save Files (Optional)
If you wish to retain your test world and save games:
```bash
# Archive save games to a tarball
tar -czvf satisfactory-saves-backup.tar.gz -C /mnt/fastdata/satisfactory-data/saved .
```

### 2. Stop and Remove the Docker Container
On the Docker host:
```bash
cd /home/joshua/palworld
docker compose stop satisfactory
docker compose rm -f satisfactory
```

### 3. Remove Data & Configuration
```bash
# Remove container data directory
sudo rm -rf /mnt/fastdata/satisfactory-data

# Remove local env file on host
rm -f /home/joshua/palworld/satisfactory.env
```

### 4. Clean Up Repository & ACLs
1. Remove the `satisfactory` service block in [`resources/palworld-server/docker/docker-compose.template.yaml`](../palworld-server/docker/docker-compose.template.yaml).
2. Delete [`resources/palworld-server/docker/satisfactory.env.template`](../palworld-server/docker/satisfactory.env.template).
3. Remove Satisfactory env injection, staging, and deploy steps in [`.github/workflows/deploy-palworld.yml`](../../.github/workflows/deploy-palworld.yml).
4. Remove the temporary Satisfactory grant from your Tailscale ACL policy.
5. Commit and push the repository cleanup changes.

