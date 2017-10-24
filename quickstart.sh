#!/bin/bash
# Date: 2017-9-13
# Usage: deploy eru-core, eru-agent in one node
#        and run eru-lambda for example

set -e

# yum
echo "Updating..."
source yum.sh
echo "Update OK"

# docker
echo "Install Docker"
doker version &>/dev/null || source docker.sh
echo "Docker OK"

# etcd
echo "Install Etcd"
sysctl status etcd || source etcd.sh
echo "Etcd OK"

# start etcd then start docker
systemctl enable etcd
systemctl start etcd
systemctl enable docker
systemctl start docker
echo "Enable etcd and docker... OK"

# calico
echo "Deploy Calico network"
docker ps | grep calico &> /dev/null || source calico.sh
echo "Calico network OK"

# get eru cli
docker pull projecteru2/cli
echo "ERU_Cli OK"

# eru
docker ps | grep eru_core &> /dev/null || source core.sh
echo "Core OK"

# register a pod with a node
source register.sh
echo "Register OK"

# eru agent
docker ps | grep eru_agent &> /dev/null || source agent.sh
echo "Agent OK"

# run lambda test
echo "Let's run a lambda for testing"
read -p "Are you ready?[Y/n]" Y
[[ "$Y" == "Y" || "$Y" == "y" || "$Y" == "" ]] && source lambda.sh || echo "That's fine"

echo "Done"
