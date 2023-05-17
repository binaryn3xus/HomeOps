<div align="center">

<img src="https://camo.githubusercontent.com/5b298bf6b0596795602bd771c5bddbb963e83e0f/68747470733a2f2f692e696d6775722e636f6d2f7031527a586a512e706e67" align="center" width="144px" height="144px"/>

### My home operations repository :octocat:

_... managed with Flux, SOPS and GitHub Actions_ 🤖

</div>

<div align="center">

[![Kubernetes](https://img.shields.io/badge/v1.27.1-blue?style=for-the-badge&logo=kubernetes&logoColor=white)](https://k3s.io/)

[![Plex](https://img.shields.io/uptimerobot/status/m792627751-0264dfd72c060e8b390e6398?logo=plex&logoColor=white&color=brightgreeen&label=Plex&style=for-the-badge)](https://plex.tv)
[![Home-Assistant](https://img.shields.io/uptimerobot/status/m792627687-253e54a4fb0305d78f746aef?logo=homeassistant&logoColor=white&color=brightgreeen&label=Home%20Assistant&style=for-the-badge)](https://www.home-assistant.io/)

</div>

---

## 📖 Overview

This is a mono repository for my home infrastructure and Kubernetes cluster. I try to adhere to Infrastructure as Code (IaC) and GitOps practices using the tools like [Ansible](https://www.ansible.com/), [Terraform](https://www.terraform.io/), [Kubernetes](https://kubernetes.io/), [Flux](https://github.com/fluxcd/flux2), [Renovate](https://github.com/renovatebot/renovate) and [GitHub Actions](https://github.com/features/actions).

---

## ⛵ Kubernetes

There is a template over at [onedr0p/flux-cluster-template](https://github.com/onedr0p/flux-cluster-template) if you wanted to try and follow along with some of the practices I use here.

### Installation

My cluster is [k3s](https://k3s.io/) provisioned overtop bare-metal Fedora Server using the [Ansible](https://www.ansible.com/) galaxy role [ansible-role-k3s](https://github.com/PyratLabs/ansible-role-k3s). This is a semi hyper-converged cluster, workloads and block storage are sharing the same available resources on my nodes while I have a separate server for (NFS) file storage.

🔸 _[Click here](./ansible/) to see my Ansible playbooks and roles._

### Core Components

- [calico](https://github.com/projectcalico/calico): Internal Kubernetes networking plugin.
- [cert-manager](https://cert-manager.io/docs/): Creates SSL certificates for services in my Kubernetes cluster.
- [external-dns](https://github.com/kubernetes-sigs/external-dns): Automatically manages DNS records from my cluster in a cloud DNS provider.
- [ingress-nginx](https://github.com/kubernetes/ingress-nginx/): Ingress controller to expose HTTP traffic to pods over DNS.
- [rook](https://github.com/rook/rook): Distributed block storage for peristent storage.
- [sops](https://toolkit.fluxcd.io/guides/mozilla-sops/): Managed secrets for Kubernetes, Ansible and Terraform which are commited to Git.
- [tf-controller](https://github.com/weaveworks/tf-controller): Additional Flux component used to run Terraform from within a Kubernetes cluster.

### GitOps

[Flux](https://github.com/fluxcd/flux2) watches my [kubernetes](./kubernetes/) folder (see Directories below) and makes the changes to my cluster based on the YAML manifests.

[Renovate](https://github.com/renovatebot/renovate) watches my **entire** repository looking for dependency updates, when they are found a PR is automatically created. When some PRs are merged [Flux](https://github.com/fluxcd/flux2) applies the changes to my cluster.

### Directories

This Git repository contains the following directories under [kubernetes](./kubernetes/).

```sh
📁 kubernetes      # Kubernetes cluster defined as code
├─📁 bootstrap     # Flux installation
├─📁 flux          # Main Flux configuration of repository
└─📁 apps          # Apps deployed into my cluster grouped by namespace (see below)
```

## ☁️ Cloud Dependencies

While most of my infrastructure and workloads are selfhosted I do rely upon the cloud for certain key parts of my setup. This saves me from having to worry about two things. (1) Dealing with chicken/egg scenarios and (2) services I critically need whether my cluster is online or not.

| Service                                      | Use                                                               | Cost          |
|----------------------------------------------|-------------------------------------------------------------------|---------------|
| [GitHub](https://github.com/)                | Hosting this repository and continuous integration/deployments    | Free          |
| [Cloudflare](https://www.cloudflare.com/)    | Domain, DNS and proxy management                                  | Free          |
| [UptimeRobot](https://uptimerobot.com/)      | Monitoring internet connectivity and external facing applications | Free          |
|                                              |                                                                   | Total: Free   |

---

## 🌐 DNS

### Ingress Controller

Over WAN, I have port forwarded ports `80` and `443` to the load balancer IP of my ingress controller that's running in my Kubernetes cluster.

[Cloudflare](https://www.cloudflare.com/) works as a proxy to hide my homes WAN IP and also as a firewall. When not on my home network, all the traffic coming into my ingress controller on port `80` and `443` comes from Cloudflare.

🔸 _Cloudflare is also configured to GeoIP block all countries except a few I have whitelisted_

### Internal DNS

[coredns](https://github.com/coredns/coredns) is deployed on my `VyOS` router and all DNS queries for **my** domains are forwarded to [k8s_gateway](https://github.com/ori-edge/k8s_gateway) that is running in my cluster. With this setup `k8s_gateway` has direct access to my clusters ingresses and services and serves DNS for them in my internal network.

### External DNS

[external-dns](https://github.com/kubernetes-sigs/external-dns) is deployed in my cluster and configure to sync DNS records to [Cloudflare](https://www.cloudflare.com/). The only ingresses `external-dns` looks at to gather DNS records to put in `Cloudflare` are ones that I explicitly set an annotation of `external-dns.home.arpa/enabled: "true"`

🔸 _[Click here](./terraform/cloudflare) to see how else I manage Cloudflare with Terraform._

---

## 🔧 Hardware

| Node            | Model                          | RAM       | OS Disk Size | Data Disk Size | Operating System      | Purpose                  | Rack Location    |
| --------------- | ------------------------------ | --------- | ------------ | -------------- | --------------------- | ------------------------ | ---------------- |
| N/A             | HUNSN Micro Firewall Appliance | 8 GB      | 64GB (SSD)   |                | VyOS                  | Router                   |   18U (Right)
| FleetCom Node 1 | Dell Optiplex 7050 Micro       | 16 GB     | 500GB (SSD)  | 1TB (NVMe)     | Ubuntu Server 22.04.x | Kubernetes Control Plane |   15U (Left)     |
| FleetCom Node 2 | Dell Optiplex 7050 Micro       | 16 GB     | 500GB (SSD)  | 1TB (NVMe)     | Ubuntu Server 22.04.x | Kubernetes Control Plane |   15U (Right)    |
| FleetCom Node 3 | Dell Optiplex 7050 Micro       | 16 GB     | 500GB (NVMe) | 1TB (SSD)      | Ubuntu Server 22.04.x | Kubernetes Worker        |   16U (Left)     |
| FleetCom Node 4 | HP ProDesk 600 G3 Mini         | 16 GB     | 500GB (SSD)  | 1TB (NVMe)     | Ubuntu Server 22.04.x | Kubernetes Worker        |   17U (Right)    |
| FleetCom Node 5 | HP ProDesk 600 G3 Mini         | 16 GB     | 500GB (SSD)  | 1TB (NVMe)     | Ubuntu Server 22.04.x | Kubernetes Control Plane |   17U (Left)     |
| FleetCom Node 6 | Dell Optiplex 3060 Micro       | 16 GB     | 500GB (SSD)  | 1TB (NVMe)     | Ubuntu Server 22.04.x | Kubernetes Worker        |   16U (Right)    |

---

## 🤝 Gratitude and Thanks

Big shout out to all the authors and contributors to the projects that we are using in this repository.

Community member [onedr0p](https://github.com/onedr0p/) for initially creating this amazing template and providing me with additional help.
Community member [snoopy82481](https://github.com/snoopy82481/) for support in some of these projects within this repo.

---

## 📜 Changelog

See _awful_ [commit history](https://github.com/binaryn3xus/HomeOps/commits/main)

---

## 🔏 License

See [LICENSE](./LICENSE)
