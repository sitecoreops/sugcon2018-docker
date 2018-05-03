$tag = "registry.valtech.dk/teamcity-agent-docker:2017.2.3-windowsservercore-1709"

docker image build --tag $tag .
docker image push $tag