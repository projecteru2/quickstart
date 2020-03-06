#!/bin/bash -eu

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
  exit -1
fi

. env.sh

docker image pull ${ERU_CORE_IMAGE}

docker run -d \
  --name ${ERU_CORE_NAME} \
  --net host \
  --restart always \
  -v /etc/eru:/etc/eru \
  ${ERU_CORE_IMAGE} \
  /usr/bin/eru-core
