# HomeOps Documentation

Welcome to the HomeOps documentation! This site contains information about the setup, configuration, and maintenance of my home infrastructure managed through GitOps principles.

## Infrastructure Overview

```mermaid
graph TB
    subgraph "Home Kubernetes Cluster"
        direction TB
        
        subgraph "Core Infrastructure"
            FLUX[Flux CD] --> |manages| APPS[Applications]
            FLUX --> |manages| INFRA[Infrastructure]
            
            CILIUM[Cilium CNI] --> |provides| NET[Networking]
            NET --> |features| BGP[BGP Control Plane]
            NET --> |features| L2[L2 Announcements]
        end

        subgraph "Storage Solutions"
            ROOK[Rook] --> |manages| CEPH[Ceph Storage]
            OPENEBS[OpenEBS] --> |provides| LOCAL[Local Storage]
            VOLSYNC[Volsync] --> |handles| SYNC[Data Sync]
        end

        subgraph "Core Services"
            CERT[cert-manager] --> |manages| CERTS[Certificates]
            OBS[Observability] --> |includes| MONITOR[Monitoring Stack]
            SEC[Security] --> |includes| TELEPORT[Teleport Access]
        end

        subgraph "Networking Layer"
            ING[Ingress] --> |handles| TRAFFIC[Traffic Routing]
            DNS[DNS] --> |provides| DISCOVERY[Service Discovery]
        end
    end

    style FLUX fill:#2196f3,stroke:#333,stroke-width:2px,color:white
    style CILIUM fill:#00bcd4,stroke:#333,stroke-width:2px,color:white
    style ROOK fill:#4caf50,stroke:#333,stroke-width:2px,color:white
    style OPENEBS fill:#4caf50,stroke:#333,stroke-width:2px,color:white
    style CERT fill:#ff9800,stroke:#333,stroke-width:2px,color:white
    style OBS fill:#9c27b0,stroke:#333,stroke-width:2px,color:white
```

## Quick Links

- [Tools](Tools.md) - Essential tools used in this infrastructure
- [Commands](Commands.md) - Common commands and operations
- [Scripts](Scripts.md) - Useful scripts for automation
- [PiKVM](Pikvm.md) - PiKVM setup and configuration
- [Teleport](Teleport.md) - Teleport access management
- [Semantic Commits](SemanticCommits.md) - Commit message guidelines
