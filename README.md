<div align="center">

<img src="https://raw.githubusercontent.com/binaryn3xus/HomeOps/refs/heads/main/docs/src/assets/logo.png" align="center" width="144px" height="144px"/>

### My Home Operations Repository :octocat:

_... managed with Flux, SOPS and GitHub Actions_ 🤖

</div>

<div align="center">

[![Talos](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.unscfleet.com%2Ftalos_version&style=for-the-badge&logo=talos&logoColor=white&color=blue&label=%20)](https://talos.dev)&nbsp;&nbsp;
[![Kubernetes](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.unscfleet.com%2Fkubernetes_version&style=for-the-badge&logo=kubernetes&logoColor=white&color=blue&label=%20)](https://kubernetes.io)&nbsp;&nbsp;
[![Renovate](https://img.shields.io/github/actions/workflow/status/binaryn3xus/HomeOps/renovate.yaml?branch=main&label=&logo=renovatebot&style=for-the-badge&color=blue)](https://github.com/binaryn3xus/HomeOps/actions/workflows/renovate.yaml)

</div>

<div align="center">

[![Status-Page](https://img.shields.io/uptimerobot/status/m798346386-6bc92c6b1f9748ebbed8708b?color=brightgreeen&label=Status%20Page&style=for-the-badge&logo=statuspage&logoColor=white)](https://status.unscfleet.com)&nbsp;&nbsp;
[![Plex](https://img.shields.io/uptimerobot/status/m792627751-0264dfd72c060e8b390e6398?logo=plex&logoColor=white&color=brightgreeen&label=Plex&style=for-the-badge)](https://plex.tv)&nbsp;&nbsp;
[![Home-Assistant](https://img.shields.io/uptimerobot/status/m792627687-253e54a4fb0305d78f746aef?logo=homeassistant&logoColor=white&color=brightgreeen&label=Home%20Assistant&style=for-the-badge)](https://www.home-assistant.io/)

</div>

<div align="center">

[![Age-Days](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.unscfleet.com%2Fcluster_age_days&style=flat-square&label=Age)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Uptime-Days](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.unscfleet.com%2Fcluster_uptime_days&style=flat-square&label=Uptime)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Node-Count](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.unscfleet.com%2Fcluster_node_count&style=flat-square&label=Nodes)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Pod-Count](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.unscfleet.com%2Fcluster_pod_count&style=flat-square&label=Pods)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![CPU-Usage](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.unscfleet.com%2Fcluster_cpu_usage&style=flat-square&label=CPU)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Memory-Usage](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.unscfleet.com%2Fcluster_memory_usage&style=flat-square&label=Memory)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Alerts](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.unscfleet.com%2Fcluster_alert_count&style=flat-square&label=Alerts)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
![GitHub License](https://img.shields.io/github/license/binaryn3xus/HomeOps?style=flat-square)

</div>

---

## 📖 Overview

This is a mono repository for my home infrastructure and Kubernetes cluster. I try to adhere to Infrastructure as Code (IaC) and GitOps practices using the tools like [Ansible](https://www.ansible.com/), [Kubernetes](https://kubernetes.io/), [Flux](https://github.com/fluxcd/flux2), [Renovate](https://github.com/renovatebot/renovate) and [GitHub Actions](https://github.com/features/actions).

---

## ⛵ Kubernetes

### Installation

My Kubernetes cluster is deploy with [Talos](https://www.talos.dev). This is a semi-hyper-converged cluster, workloads and block storage are sharing the same available resources on my nodes while I have a separate server with on my Synology NAS for storage for bulk file storage and backups.

### Core Components

- [cert-manager](https://github.com/cert-manager/cert-manager): Creates SSL certificates for services in my cluster.
- [cilium](https://github.com/cilium/cilium): Internal Kubernetes container networking interface.
- [cloudflared](https://github.com/cloudflare/cloudflared): Enables Cloudflare secure access to certain ingresses.
- [external-dns](https://github.com/kubernetes-sigs/external-dns): Automatically syncs ingress DNS records to a DNS provider.
- [external-secrets](https://github.com/external-secrets/external-secrets): Managed Kubernetes secrets using [Azure Keyvault](https://azure.microsoft.com/en-us/products/key-vault).
- [ingress-nginx](https://github.com/kubernetes/ingress-nginx): Kubernetes ingress controller using NGINX as a reverse proxy and load balancer.
- [rook](https://github.com/rook/rook): Distributed block storage for peristent storage.
- [sops](https://github.com/getsops/sops): Managed secrets for Kubernetes and Terraform which are commited to Git.
- [spegel](https://github.com/spegel-org/spegel): Stateless cluster local OCI registry mirror.
- [teleport](https://goteleport.com/): Manage some network resources remotely
- [volsync](https://github.com/backube/volsync): Backup and recovery of persistent volume claims.

### GitOps

[Flux](https://github.com/fluxcd/flux2) watches my [kubernetes](./kubernetes/) folder (see Directories below) and makes the changes to my cluster based on the YAML manifests.

The way Flux works for me here is it will recursively search the [kubernetes/apps](./kubernetes/apps) folder until it finds the most top level `kustomization.yaml` per directory and then apply all the resources listed in it. That aforementioned `kustomization.yaml` will generally only have a namespace resource and one or many Flux kustomizations. Those Flux kustomizations will generally have a `HelmRelease` or other resources related to the application underneath it which will be applied.

[Renovate](https://github.com/renovatebot/renovate) watches my **entire** repository looking for dependency updates, when they are found a PR is automatically created. When some PRs are merged [Flux](https://github.com/fluxcd/flux2) applies the changes to my cluster.

### Directories

This Git repository contains the following directories under [kubernetes](./kubernetes/).

```sh
📁 kubernetes      # Kubernetes cluster defined as code
├─📁 apps          # Apps deployed into my cluster grouped by namespace (see below)
├─📁 bootstrap     # Flux installation
├─📁 flux          # Main Flux configuration of repository
```

### 📡 Networking

| Name                | CIDR           |
|---------------------|----------------|
| Server VLAN         | `10.0.30.0/24` |
| Kubernetes pods     | `10.69.0.0/16` |
| Kubernetes services | `10.96.0.0/16` |

## ☁️ Cloud Dependencies

While most of my infrastructure and workloads are selfhosted I do rely upon the cloud for certain key parts of my setup. This saves me from having to worry about two things. (1) Dealing with chicken/egg scenarios and (2) services I critically need whether my cluster is online or not.

| Service                                                                 | Use                                                               | Cost             |
|-------------------------------------------------------------------------|-------------------------------------------------------------------|------------------|
| [GitHub](https://github.com/)                                           | Hosting this repository and continuous integration/deployments    | Free             |
| [Cloudflare](https://www.cloudflare.com/)                               | Domain, DNS and proxy management                                  | Free             |
| [UptimeRobot](https://uptimerobot.com/)                                 | Monitoring internet connectivity and external facing applications | Free             |
| [Azure Key Vault](https://azure.microsoft.com/en-us/products/key-vault) | Secrets with [External Secrets](https://external-secrets.io/)     | ~$0.10/mo        |
|                                                                         |                                                                   | Total: ~$0.10/mo |

---

## 🌐 DNS

### Home DNS

Unifi with Ad-Blocking

### Public DNS

Outside the `external-dns` instance mentioned above another instance is deployed in my cluster and configured to sync DNS records to [Cloudflare](https://www.cloudflare.com/). The only ingress this `external-dns` instance looks at to gather DNS records to put in `Cloudflare` are ones that have an ingress class name of `external` and contain an ingress annotation `external-dns.alpha.kubernetes.io/target`.

---

## 🔧 Hardware

| Model | RAM   | OS Disk Size | Data Disk Size | OS    | Purpose           | Rack Location | Bios Key |
|-------|-------|--------------|----------------|-------|-------------------|---------------|----------|
| MS01  | 64 GB | 1TB (NVMe)   | 1TB (NVMe)     | Talos | K8s Control Plane | U17 (Right)   | DEL      |
| MS01  | 64 GB | 1TB (NVMe)   | 1TB (NVMe)     | Talos | K8s Control Plane | U15 (Left)    | DEL      |
| MS01  | 64 GB | 1TB (NVMe)   | 1TB (NVMe)     | Talos | K8s Control Plane | U15 (Right)  | DEL      |

<details>
  <summary>Click to see the Full Home Ops Rack!</summary>

![ServerRack](/docs/src/assets/ServerRack_20250206.jpg)

</details>

---

## 🤝 Gratitude and Thanks

[![home-operations-discord](https://img.shields.io/discord/673534664354430999?style=for-the-badge&label=Home-Operations%20Discord&logo=discord&logoColor=white&color=blue)](https://discord.gg/home-operations)

[![onedr0p](https://avatars.githubusercontent.com/u/213795?v=4&size=50)](https://github.com/onedr0p/)
[![bjw-s](https://avatars.githubusercontent.com/u/6213398?v=4&size=50)](https://github.com/bjw-s/)
[![mitchross](https://avatars.githubusercontent.com/u/6330506?v=v&size=50)](https://github.com/mitchross/)
