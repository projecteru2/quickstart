#!/bin/bash

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
fi

# create a pod
docker run -it --rm \
  --net host \
  projecteru2/cli \
  eru-cli pod add --favor CPU eru

# register a node
docker run -it --rm --privileged \
  --net host \
  -v /etc/docker/tls:/etc/docker/tls \
  projecteru2/cli \
  eru-cli node add eru
