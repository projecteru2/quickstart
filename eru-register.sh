#!/bin/bash -eu

. env.sh

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
  exit -1
fi

echo "Register ERU pod"

docker image pull projecteru2/cli

# create a pod
docker run -it --rm \
  --net host \
  projecteru2/cli \
  eru-cli --eru $ERU_CORE pod add $ERU_POD

cpu=$(grep -ic processor /proc/cpuinfo)
mem="$(awk '/MemTotal/ {print $2}' /proc/meminfo)K"

echo "Register ERU node"

# register a node
docker run -it --rm --privileged \
  --net host \
  projecteru2/cli \
  eru-cli --eru $ERU_CORE node add \
    --cpu $cpu \
    --memory $mem \
    --storage 1T \
    --endpoint tcp://127.0.0.1:2376 \
    --nodename $ERU_NODE \
    $ERU_POD

echo "Register OK"
