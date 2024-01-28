<div align="center">

<img src="https://camo.githubusercontent.com/5b298bf6b0596795602bd771c5bddbb963e83e0f/68747470733a2f2f692e696d6775722e636f6d2f7031527a586a512e706e67" align="center" width="144px" height="144px"/>

### My Home Operations Repository :octocat:

_... managed with Flux, SOPS and GitHub Actions_ 🤖

</div>

<div align="center">

[![Kubernetes](https://img.shields.io/badge/v1.29-blue?style=for-the-badge&logo=kubernetes&logoColor=white)](https://k3s.io/)

[![Plex](https://img.shields.io/uptimerobot/status/m792627751-0264dfd72c060e8b390e6398?logo=plex&logoColor=white&color=brightgreeen&label=Plex&style=for-the-badge)](https://plex.tv)
[![Home-Assistant](https://img.shields.io/uptimerobot/status/m792627687-253e54a4fb0305d78f746aef?logo=homeassistant&logoColor=white&color=brightgreeen&label=Home%20Assistant&style=for-the-badge)](https://www.home-assistant.io/)

</div>

---

## 📖 Overview

This is a mono repository for my home infrastructure and Kubernetes cluster. I try to adhere to Infrastructure as Code (IaC) and GitOps practices using the tools like [Ansible](https://www.ansible.com/), [Kubernetes](https://kubernetes.io/), [Flux](https://github.com/fluxcd/flux2), [Renovate](https://github.com/renovatebot/renovate) and [GitHub Actions](https://github.com/features/actions).

---

## ⛵ Kubernetes

There is a template over at [onedr0p/flux-cluster-template](https://github.com/onedr0p/flux-cluster-template) if you wanted to try and follow along with some of the practices I use here.

### Installation

My cluster is [k3s](https://k3s.io/) provisioned overtop bare-metal Debian Servers using the [Ansible](https://www.ansible.com/) galaxy role [ansible-role-k3s](https://github.com/PyratLabs/ansible-role-k3s). This is a semi hyper-converged cluster, workloads and block storage are sharing the same available resources on my nodes while I have a separate server for (NFS) file storage.

🔸 _[Click here](./ansible/) to see my Ansible playbooks and roles._

### Core Components

- [cilium](https://cilium.io/): Internal Kubernetes networking plugin.
- [cloudflared](https://github.com/cloudflare/cloudflared): Tunneling daemon that proxies traffic from the Cloudflare network to my cluster
- [cert-manager](https://cert-manager.io/docs/): Creates SSL certificates for services in my Kubernetes cluster.
- [external-dns](https://github.com/kubernetes-sigs/external-dns): Automatically manages DNS records from my cluster in a cloud DNS provider.
- [ingress-nginx](https://github.com/kubernetes/ingress-nginx/): Ingress controller to expose HTTP traffic to pods over DNS.
- [rook](https://github.com/rook/rook): Distributed block storage for peristent storage.
- [sops](https://toolkit.fluxcd.io/guides/mozilla-sops/): Managed secrets for Kubernetes, Ansible and Terraform which are commited to Git.
- [teleport](https://goteleport.com/): Manage some network resources remotely
- [tf-controller](https://github.com/weaveworks/tf-controller): Additional Flux component used to run Terraform from within a Kubernetes cluster.
- [volsync](https://github.com/backube/volsync) and [snapscheduler](https://github.com/backube/snapscheduler): Backup and recovery of persistent volume claims.

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
└─📁 flux          # Main Flux configuration of repository
```

### 📡 Networking

| Name                  | CIDR              |
|-----------------------|-------------------|
| Server VLAN           | `10.0.30.0/24`    |
| Kubernetes pods       | `10.42.0.0/16`    |
| Kubernetes services   | `10.43.0.0/16`    |

## ☁️ Cloud Dependencies

While most of my infrastructure and workloads are selfhosted I do rely upon the cloud for certain key parts of my setup. This saves me from having to worry about two things. (1) Dealing with chicken/egg scenarios and (2) services I critically need whether my cluster is online or not.

| Service                                                                      | Use                                                               | Cost             |
|------------------------------------------------------------------------------|-------------------------------------------------------------------|------------------|
| [GitHub](https://github.com/)                                                | Hosting this repository and continuous integration/deployments    | Free             |
| [Cloudflare](https://www.cloudflare.com/)                                    | Domain, DNS and proxy management                                  | Free             |
| [UptimeRobot](https://uptimerobot.com/)                                      | Monitoring internet connectivity and external facing applications | Free             |
| [NextDNS Pro](https://nextdns.io/?from=wgggpc5h)                             | DNS with some ad-blocking and other features                      | ~$1.65.mo        |
| [Azure Key Vault](https://azure.microsoft.com/en-us/products/key-vault)      | Secrets with [External Secrets](https://external-secrets.io/)     | ~$0.10/mo        |
|                                                                              |                                                                   | Total: ~$1.75/mo |

---

## 🌐 DNS

### Home DNS

On my Vyos router I have CoreDNS deployed as a container. I have a split-dns setup so I can access certain pods on my network but not expose them to the public internet.

You can see more about this setup in my VyOS repo: [VyosConfig](https://github.com/binaryn3xus/VyosConfig)

### Public DNS

Outside the `external-dns` instance mentioned above another instance is deployed in my cluster and configure to sync DNS records to [Cloudflare](https://www.cloudflare.com/). The only ingresses this `external-dns` instance looks at to gather DNS records to put in `Cloudflare` are ones that have an ingress class name of `external` and an ingress annotation of `external-dns.alpha.kubernetes.io/target`.

---

## 🔧 Hardware

| Model                          | RAM       | OS Disk Size | Data Disk Size | Operating System  | Purpose                    | Rack Location    |
| ------------------------------ | --------- | ------------ | -------------- | ----------------- | -------------------------- | ---------------- |
| HUNSN Micro Firewall Appliance | 8 GB      | 64GB (SSD)   |                | VyOS              | Router                     |   18U (Right)    |
| Dell Optiplex 7050 Micro       | 16 GB     | 500GB (SSD)  | 1TB (NVMe)     | Debian            | Node 1 (K8s Control Plane) |   15U (Left)     |
| Dell Optiplex 7050 Micro       | 16 GB     | 500GB (SSD)  | 1TB (NVMe)     | Debian            | Node 2 (K8s Control Plane) |   15U (Right)    |
| Dell Optiplex 7050 Micro       | 16 GB     | 500GB (NVMe) | 1TB (SSD)      | Debian            | Node 3 (K8s Worker)        |   16U (Left)     |
| HP ProDesk 600 G3 Mini         | 16 GB     | 500GB (SSD)  | 1TB (NVMe)     | Debian            | Node 4 (K8s Worker)        |   17U (Right)    |
| HP ProDesk 600 G3 Mini         | 16 GB     | 500GB (SSD)  | 1TB (NVMe)     | Debian            | Node 5 (K8s Control Plane) |   17U (Left)     |
| Dell Optiplex 3060 Micro       | 16 GB     | 500GB (SSD)  | 1TB (NVMe)     | Debian            | Node 6 (K8s Worker)        |   16U (Right)    |



<details>
  <summary>Click to see the Full Home Ops Rack!</summary>

![ServerRack](/docs/images/ServerRack_20231214.jpg)

<table>
  <thead>
    <tr>
      <th>Rack U</th>
      <th>Hardware</th>
      <th>Power Rail</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>22</td>
      <td>16 Port KVM Switch</td>
      <td>Pending Assignment</td>
    </tr>
    <tr>
      <td>21</td>
      <td>CAT6 Patch Panel</td>
      <td>Pending Assignment</td>
    </tr>
    <tr>
      <td>20</td>
      <td>24 Port Unifi Network Switch</td>
      <td>Pending Assignment</td>
    </tr>
    <tr>
      <td>19</td>
      <td>Unifi CloudKey Gen 2</td>
      <td>Pending Assignment</td>
    </tr>
    <tr>
      <td>18</td>
      <td>
        Linux Desktop - Intel Skull Canyon NUC
        <br/>
        VyOS Router - HUNSN Micro Firewall Appliance
      </td>
      <td>Pending Assignment</td>
    </tr>
    <tr>
      <td>17</td>
      <td>
        Node 4 - HP ProDesk 600 G3 Mini
        <br/>
        Node 5 - HP ProDesk 600 G3 Mini
      </td>
      <td>Pending Assignment</td>
    </tr>
    <tr>
      <td>16</td>
      <td>
        Node 3 - Dell Optiplex 7050 Micro
        <br/>
        Node 6 - Dell Optiplex 3060 Micro
      </td>
      <td>Pending Assignment</td>
    </tr>
    <tr>
      <td>15</td>
      <td>
        Node 1 - Dell Optiplex 7050 Micro
        <br/>
        Node 2 - Dell Optiplex 7050 Micro
      </td>
      <td>Pending Assignment</td>
    </tr>
    <tr>
      <td>14</td>
      <td rowspan=4>Custom Build Server</td>
      <td rowspan=4>Pending Assignment</td>
    </tr>
    <tr>
      <td>13</td>
    </tr>
    <tr>
      <td>12</td>
    </tr>
    <tr>
      <td>11</td>
    </tr>
    <tr>
      <td>10</td>
      <td>BLANK</td>
      <td>Pending Assignment</td>
    </tr>
    <tr>
      <td>9</td>
      <td>Raspberry Pi Mount</td>
      <td>Pending Assignment</td>
    </tr>
    <tr>
      <td>8</td>
      <td rowspan=4>Synology DS1819+</td>
      <td rowspan=4>Pending Assignment</td>
    </tr>
    <tr>
      <td>7</td>
    </tr>
    <tr>
      <td>6</td>
    </tr>
    <tr>
      <td>5</td>
    </tr>
    <tr>
      <td>4</td>
      <td rowspan=2>Dell PowerEdge 2950</td>
      <td rowspan=2>Pending Assignment</td>
    </tr>
    <tr>
      <td>3</td>
    </tr>
    <tr>
      <td>2</td>
      <td rowspan=2>APC Battery Backup</td>
      <td rowspan=2>Pending Assignment</td>
    </tr>
    <tr>
      <td>1</td>
    </tr>
  </tbody>
</table>

</details>

---

## 🤝 Gratitude and Thanks

Big shout out to all the authors and contributors to the [flux-cluster-template](https://github.com/onedr0p/flux-cluster-template) projects that we are using in this repository.

Community member [onedr0p](https://github.com/onedr0p/) for initially creating this amazing template and providing me with additional help.

---

## 📜 Changelog

See _awful_ [commit history](https://github.com/binaryn3xus/HomeOps/commits/main)

---

## 🔏 License

See [LICENSE](./LICENSE)
