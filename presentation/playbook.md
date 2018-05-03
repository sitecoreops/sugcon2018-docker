# Playbook

...

## Preparations

1. DEV branches deleted from github AND locally.
1. DEV branches deleted from teamcity.
1. DEV services deleted from portainer.
1. DEV containers deleted on winvm0, winvm1, winvm2.
1. Restart influxdb to clean old data.
1. Ensure that `Ping.ps1` runs on the `support` Windows node.
1. Monday: Ensure current outbound IP (https://api.ipify.org/) has access to Azure resource group.
1. Tuesday: Ensure mobile hotspot also has access to Azure resource group.

## Scenarios

1. [00:06:00] Code change
    1. Show https://www.sugops.net, point out TEST 0.
    1. Change `src/WebApp/Views/Main.cshtml`, set `TEST 1`, commit, push.
    1. [MAX 00:00:30] Check build starts: http://build-winvm0.westeurope.cloudapp.azure.com/
    1. [MAX 00:00:30] Show that www is healthy: http://runtime-nixvm0.westeurope.cloudapp.azure.com:3000
    1. [MAX 00:01:30] Show http://runtime-nixvm0.westeurope.cloudapp.azure.com:8000/
        - Show `web` stack
        - Show `proxy` stack
        - Explain teamcity agent
    1. Check build completes and triggers deploy: http://build-winvm0.westeurope.cloudapp.azure.com/
    1. [MAX 00:03:00] See that **cd1** and **cm** is updating: http://runtime-nixvm0.westeurope.cloudapp.azure.com:8000/
        1. Show that www is still healthy: http://runtime-nixvm0.westeurope.cloudapp.azure.com:3000
        1. In `web` stack, show and explain `update_config`, `order`, `parallelism` and `failure_action`.
        1. In `web` stack, show and explain `healthcheck` and `start_period`.
        1. See that **cd2** is started: http://runtime-nixvm0.westeurope.cloudapp.azure.com:8000/
        1. See that **cd1** and **cd2** is taking requests: https://www.sugops.net
        1. Show that www is still healthy with no downtime: http://runtime-nixvm0.westeurope.cloudapp.azure.com:3000

1. [00:03:00] Stack change
    1. Update `web` stack, set cd scale to replicas = 4, parallelism = 2, commit and push.
    1. [MAX 00:00:20] Check build starts: http://build-winvm0.westeurope.cloudapp.azure.com/
    1. [MAX 00:02:30] Show and see **cd3** and **cd4** starts up: http://runtime-nixvm0.westeurope.cloudapp.azure.com:8000/
        1. Explain the use of `image digest` in `Build.ps1` and TeamCity http://build-winvm0.westeurope.cloudapp.azure.com/
        1. See that **cd3** and **cd4** is started: http://runtime-nixvm0.westeurope.cloudapp.azure.com:8000/
        1. Show that www is still healthy with no downtime: http://runtime-nixvm0.westeurope.cloudapp.azure.com:3000

1. [00:06:00] Deploy new branch
    1. Create branch, change `src/WebApp/Views/Main.cshtml`, set `DEV branch, TEST 1`, commit, publish
    1. [MAX 00:01:45] Check build starts: http://build-winvm0.westeurope.cloudapp.azure.com/
        1. Explain the use of *branch name* as *stack name*.
        1. Explain sql and solr data volumes defined in `web` stack.
    1. Check build completes and triggers deploy: http://build-winvm0.westeurope.cloudapp.azure.com/
    1. Show http://runtime-nixvm0.westeurope.cloudapp.azure.com:8000/
    1. [MAX 00:05:00] Warmup...
        1. Explain auto clean sql/solr data into volumes on first run.
        1. Talk about the different rollback methods.
        1. --> Optionally start on questions...
        1. [ELAPSED 00:04:00] CM is warm...
        1. Login to https://cm-dev.sugops.net, go to content editor, serialization, revert database, site publish.
        1. [ELAPSED 00:05:00] CD is warm at https://www-dev.sugops.net

1. [OPTIONAL] Rollback
    - [00:00:10] using --rollback RIGHT AFTER scale UP is fast.
    - [00:05:30] using Deploy any previous Build (runs like a normal deploy)
    - [00:08:15] using --rollback (for each service, jobs waits for previous state is restored in cluster)

### Additional

1. Drain worker node => with no downtime, recovery
1. Kill container => with no downtime, recovery
1. Stop worker node => with no downtime, recovery
1. TeamCity docker containers, server, build agent (named pipes), deploy agent
1. Terraform setup

## Notes

- First level timings is *from build start* to *all replicas is warm*
- Do NOT manually scale a Windows service DOWN, old container is NOT shutdown due to some unknown issue on current Docker EE on Windows...
