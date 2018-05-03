# Slides to be added to PowerPoint...

...

## Current pain points

1. CI/CD pipelines are often build from scratch or copied from previous solutions and then customized. This takes time to do, *every* time.
1. Shared build agents typically with different Visual Studio versions, node versions, nuget versions, coverage tools, PowerShell, .NET Framework and SDK's installed, becomes more and more difficult to maintain over time.
1. Time consuming to create deployments without downtime, mostly due to differences in each solution, load balancers, on-prem servers and Azure App Services.
1. You often produce large build artifacts with many files that not necessarily belong to the solution but to the Sitecore version you are running on. All of this needs to be copied *every time* we deploy.
1. Large artifacts and many files takes time to deploy, often many minutes per instance on on-prem servers and even longer on Azure App Services.

## How can this be addressed?

1. Run your build in a Docker container:
    - **All** your build dependencies is nicely **documented** and **versioned** in the Dockerfile.
    - Build agents *only* knows about Docker and **nothing** else.
    - Many solutions can share the same agents and use exactly the dependencies they want without conflicting with others.
    - Responsibility of the agent capabilities is moved from IT to the developers.
1. Leverage the Docker image layering caching, only changed layers is pulled from registry to the Docker host. Windows, IIS, ASP.NET and Sitecore layers will only be transferred to the host once. Everything after is *only* layers with your changes. Reduces deployment time *and* size.
1. Use a container orchestration tool to:
    - Deploy changes without downtime.
    - Easy rollback to previous state.
    - Automatic rollback in case of failure.

## What is container orchestration?

- Declarative service model: Everything including desired state, is defined in versioned files, for example docker-compose files.
- Rolling updates: Updates can be applied in parallel with the running containers.
- Service discovery and load balancing: DNS based discovery, reference for example sql, mongo or solr servers by *service name* instead of servername/IP, reduces configuration management and ensures portability.
- Self-healing: Containers are kept running and automatically restarted in case of failure, moved to a healthy host in case of server errors or update. It will try its best to keep the desired state of each service.
- Secrets and configuration management: Provides a place for, for example SSL certificates or other configuration that can be referenced from your services.

## Why use Docker Swarm for container orchestration?

1. Built into the Docker engine and cli.
1. Most mature Windows support right now, compared to:
    - Kubernetes: Just moved from experimental to **beta**! Hopefully stable as part of the 2.0 release in the summer.
    - Rancher: **Experimental**
    - Apache Mesos: **Experimental**
1. Use both Windows and Linux containers *together*.
1. Also supported and documented by Microsoft since Docker Enterprise Edition was added to Windows Server 2016, for free.
1. Easy to get up and running with `docker swarm init` and `docker swarm join`, no other moving parts.

>Kubernetes is very popular right now and could be the platform to use with Windows containers in the future. All major cloud providers has support and it's massively invested in by also Microsoft, both on the Azure front with ACS (Azure Container Services) and AKS (Azure Kubernetes Services), but also with Visual Studio and "VS Connected Environments". Even Docker for Windows and Mac now supports running Kubernetes out-of-the-box.

## Key takeaways

... TODO ...
