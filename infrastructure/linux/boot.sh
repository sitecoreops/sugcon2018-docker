#!/bin/sh
echo "Installing docker..."
apt-get -y update
apt-get -y upgrade
apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get -y update
echo { \"insecure-registries\":[\"registry.valtech.dk\"] } >| /etc/docker/daemon.json
apt-get -y install docker-ce
docker --version

echo "Done!"
exit 0