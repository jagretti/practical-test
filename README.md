# practical-test

## Notes

### Web Server
Small app written in Python, using Django framework. I had some knowledge about this framework that's why I chose it.
It connects to a MySQL database, and a Redis instance.

### Docker
Using minimal Python Alpine image, but the Django framework is not lightweight, so the image has around ~200MB, but it's fast and easy to build.

Commands:
```
$ docker compose build
$ docker compose up
```

### Jenkins

Simple pipeline to build, test, push, and deploy image to Kubernetes. I'm using Kustomize because it's a simple tool to modify small apps, but as soon as the resources are bigger or there are too many changes to do, maybe Helm could be a good replacement.

Some assumptions:
* There's some kind of Ingress Controller installed in Kubernetes
* Jenkins has kustomize/docker installed in their worked nodes

### Monitoring

High-level diagram of a monitoring setup. Most of the tools provide a `/monitoring` Prometheus endpoint, that can
be scraped and stored in Prometheus, to then visualize and alert using Grafana. Also there's a chance to push
metrics to Prometheus from the application itself.

```mermaid
graph LR
    subgraph Application
        LB{Load balancer}
        Users --> LB
        LB --> WA[WebApp]
        WA --> R[Redis]
        WA --> DB[(Database)]
    end
    subgraph Monitoring
        P[Prometheus]
        G[Grafana]
        P --scrapes--> LB
        P --scrapes--> R
        P --scrapes--> DB
        WA -- pushes --> P
        G --> P
    end
```

### Terraform

There are two modules:
* VPC: Creates a VPC with three public/private subnets, along with the corresponding NAT gateways and EIPs.
* EKS cluster: Create a simple EKS cluster, with one AWS managed nodegroup, and its corresponding security group.
