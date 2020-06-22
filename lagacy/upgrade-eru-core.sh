#!/bin/bash -eu

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
  exit -1
fi

. env.sh

docker rm -f ${ERU_CORE_NAME} || echo

./run-eru-core.sh
