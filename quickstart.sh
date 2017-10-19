#!/bin/bash
# Date: 2017-9-13
# Usage: deploy eru-core, eru-agent in one node
#        and run eru-lambda for example

# yum
./yum.sh

# docker
./docker.sh

# etcd
./etcd.sh

# start etcd then start docker
systemctl enable etcd
systemctl start etcd
systemctl enable docker
systemctl start docker

# calico
./calico.sh

# prepare a pod with a node
./register.sh

# get eru cli
docker pull projecteru2/cli

# eru
./core.sh
./agent.sh

# run lambda test
./lambda.sh
