#!/bin/bash -eu

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
  exit -1
fi

. env.sh

docker ps -a | grep eru_agent_ | awk '{print $1}' | xargs -l -I{} docker rm -f {} || echo

./run-eru-agent.sh
