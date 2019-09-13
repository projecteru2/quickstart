#!/bin/bash

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
fi

# create a pod
docker run -it --rm \
  --net host \
  projecteru2/cli \
  eru-cli --eru $ERU_CORE pod add eru

# register a node
docker run -it --rm --privileged \
  --net host \
  -v /etc/docker/tls:/etc/docker/tls \
  projecteru2/cli \
  eru-cli --eru $ERU_CORE node add --cpu 1 --memory 1073741824 eru
