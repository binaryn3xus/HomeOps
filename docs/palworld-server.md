# Palworld Server

The Palworld game server is a dedicated Docker host, managed from this repository by the [`deploy-palworld.yml`](../.github/workflows/deploy-palworld.yml) GitHub Actions workflow. Its Compose template is [`docker-compose.template.yaml`](../resources/palworld-server/docker/docker-compose.template.yaml).

## Access

| Service | Internal URL | Path |
| --- | --- | --- |
| Server dashboard | `https://palworld-dashboard.unscfleet.com` | `envoy-internal` → Tailscale egress → Docker host TCP 3000 |
| Portainer | `https://portainer.unscfleet.com` | `envoy-internal` → Tailscale egress → Docker host TCP 9000 |

These are LAN-only Gateway routes. They are not published by Cloudflare or the external gateway. The host has no router port forwards, so the dashboard and Portainer are not ordinarily reachable from the internet.

The Docker ports are still bound on the host, so direct access is limited by the host firewall and Tailnet ACLs. Do not expose TCP 3000 or TCP 9000 publicly.

## Services and ports

| Service | Port | Use |
| --- | --- | --- |
| Palworld game server | UDP 8211 | Player connections |
| Palworld server dashboard | TCP 3000 | Dashboard, accessed through the internal route |
| Portainer | TCP 9000 | Docker management UI, accessed through the internal route |
| Palworld REST API | TCP 8212 | Used inside the Docker network by the dashboard; no route is required |

## Tailscale

The Kubernetes egress proxy reaches the host through its Tailnet FQDN, configured on the `palworld-server` ExternalName Service. The Tailnet ACL must allow the Kubernetes nodes to reach the Palworld host:

```json
{
  "src": ["tag:k8s"],
  "dst": ["tag:palworld"],
  "ip": ["tcp:3000", "tcp:9000"]
}
```

Players need the separate UDP 8211 grant. TCP 8212 is not needed by Kubernetes for this setup.

## Deployment and secrets

Push changes to the Docker templates or deployment workflow to run the Palworld deployment workflow. It renders the Compose file and service environment files, copies them to `/home/joshua/palworld`, then runs Docker Compose remotely.

Portainer's initial administrator password is read from Azure Key Vault secret `Palworld-Portainer-Admin-Password`. The workflow converts it to a root-readable password file on the host; it is not committed to Git. Portainer manages the local Docker socket at `/var/run/docker.sock`.

## Deployment stages

The workflow first stages the rendered configuration on the host and updates only the dashboard and Portainer services. It then pauses at the `palworld-production` GitHub Environment approval gate before the Palworld game-server job begins. Waiting for approval does not occupy a GitHub Actions runner.

Approve the game-server stage only after confirming the server is empty. The job checks `rest-cli players` again immediately before it pulls or recreates the `palworld` service. If a player joins in the meantime, the job fails without changing Palworld; rerun that failed job once the server is empty.

## Operations

Use Portainer at `https://portainer.unscfleet.com` to manage the local Docker environment. The environment is a **Docker Standalone** environment connected through the local socket at `/var/run/docker.sock`.

For route failures, first check the corresponding `HTTPRoute` and the Tailscale ACL. An Envoy upstream timeout usually means the egress proxy cannot reach TCP 3000 or TCP 9000 on the Palworld host.
