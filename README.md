# practical-test

## Notes

## Diagram

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
