# SUGCON 2018 "Painless deployments of Sitecore using Docker Swarm"

Thanks for stopping by! Here you can find everything to setup you own hybrid Docker Swarm cluster and try out everything we showed in our presentation and demos. If you have question or comments, reach out on the #Docker channel on [https://sitecorechat.slack.com](https://sitecorechat.slack.com) or twitter: @pbering.

## Preparations

1. Create a new Azure resource group.
1. Create a Azure storage account in **another** resource group to store the Terraform state (**OR** remove the remote state config `.\infrastructure\backend.tf` and use local state instead).
1. Review IP whitelist in `.\infrastructure\network\main.tf`.
1. Review resource group name, vm sizes and vm count in `.\infrastructure\variables.tf`.
1. Change all `prefix` variables in `.\infrastructure\main.tf`.
1. Ensure you have a valid `terraform.tfvars` file with these variables:

    ```text
    tenant_id = "***"

    subscription_id = "***"

    client_id = "***"

    client_secret = "***"

    admin_username = "***"

    admin_password = "***"
    ```
1. Replace all occurrences of "registry.valtech.dk" with your own Docker registry.
1. Build and publish all images from `.\images\**\Build.ps1`.

## Services

- teamcity: http://build-winvm0.westeurope.cloudapp.azure.com:80
- visualizer: http://runtime-nixvm0.westeurope.cloudapp.azure.com:8000
- portainer: http://runtime-nixvm0.westeurope.cloudapp.azure.com:9000
- grafana: http://runtime-nixvm0.westeurope.cloudapp.azure.com:3000

master:

- cd: https://www.sugops.net
- cm: https://cm.sugops.net (admin/b)

dev:

- cd: https://www-dev.sugops.net
- cm: https://cm-dev.sugops.net (admin/b)

## Provision infrastructure

- Switch dir to `.\infrastructure`.
- Run:
    ```text
    terraform init -backend-config='access_key=***'
    terraform plan
    terraform apply -auto-approve
    ```

Get IP addresses: `az vm list-ip-addresses -g RESOURCE_GROUP_NAME -o table`

### Initialize build server

```text
Install-Package Docker -ProviderName DockerProvider -RequiredVersion preview -Verbose -Force

docker image pull registry.valtech.dk/buildtools:2017;docker image pull registry.valtech.dk/sitecore:9.0.171219-xm1-cm;docker image pull registry.valtech.dk/sitecore:9.0.171219-xm1-cd;docker image pull jetbrains/teamcity-server:2017.2.3-nanoserver-1709;docker image pull registry.valtech.dk/teamcity-agent-docker:2017.2.3-windowsservercore-1709

mkdir c:\teamcity\server\data; mkdir c:\teamcity\server\logs; mkdir c:\teamcity\agent\conf

docker container run -d --name teamcity-server --restart=always -v c:\teamcity\server\data:C:/ProgramData/JetBrains/TeamCity -v c:\teamcity\server\logs:C:/TeamCity/logs -p 80:8111 jetbrains/teamcity-server:2017.2.3-nanoserver-1709

docker container run -d --name teamcity-agent --restart=always -e SERVER_URL="http://teamcity-server:8111" -e AGENT_NAME="build-agent" -v c:\teamcity\agent\conf:C:/BuildAgent/conf -v //./pipe/docker_engine://./pipe/docker_engine --link teamcity-server registry.valtech.dk/teamcity-agent-docker:2017.2.3-windowsservercore-1709
```

>The containers cannot currently be started using docker-compose as it does not yet understand mounting Windows named pipes (the `-v //./pipe/docker_engine://./pipe/docker_engine` argument).

## Initialize Docker Swarm cluster

- Linux: `docker swarm init` on the first one and join the rest as managers.
- Windows: Join as workers.
- Windows: Pull images `docker image pull registry.valtech.dk/sugcon2018sql;docker image pull registry.valtech.dk/sugcon2018solr;docker image pull registry.valtech.dk/sitecore:9.0.171219-xm1-cm;docker image pull registry.valtech.dk/sitecore:9.0.171219-xm1-cd`

```text
sudo docker node update --label-add zone=a runtime-nixvm0
sudo docker node update --label-add data=yes runtime-nixvm1
sudo docker node update --label-add data=no runtime-winvm0
sudo docker node update --label-add data=yes runtime-winvm1
sudo docker node update --label-add data=no runtime-winvm2

sudo docker network create --driver overlay --opt com.docker.network.driver.mtu=1400 www

sudo docker stack deploy --compose-file ./docker-compose.operations.yml operations
sudo docker stack deploy --compose-file ./docker-compose.metrics.yml metrics
```

## Misc

Acquire new Let's Encrypt certificate from a manager node and add it as Docker Swarm secrets:

1. `sudo docker run -it --rm --name letsencrypt -v "/etc/letsencrypt:/etc/letsencrypt" -v "/var/lib/letsencrypt:/var/lib/letsencrypt" certbot/certbot:latest certonly -d *.sugops.net --manual --preferred-challenges dns --server https://acme-v02.api.letsencrypt.org/directory`
1. `sudo docker secret create fullchain.pem /etc/letsencrypt/live/sugops.net/fullchain.pem`
1. `sudo docker secret create privkey.pem /etc/letsencrypt/live/sugops.net/privkey.pem`

Links:

- Azure VM Sizes: https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes-general
- The MTU hybrid swarm issue: https://github.com/moby/moby/issues/33596
