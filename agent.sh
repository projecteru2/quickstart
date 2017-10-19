#!/bin/bash

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
fi

# Agent
export STATSD="127.0.0.1:8125"
export LOGS="tcp://127.0.0.1:5144"
export APILISTEN="127.0.0.1:12345"

mkdir -p /etc/eru
echo "pid: /tmp/agent.pid
health_check_interval: 5
health_check_timeout: 10
core: 127.0.0.1:5001

docker:
  endpoint: unix:///var/run/docker.sock
metrics:
  step: 30
  transfers:
    - ${STATSD}
api:
  addr: ${APILISTEN}
log:
  forwards:
    - ${LOGS}
  stdout: False
" > /etc/eru/agent.yaml

docker run -it --rm \
    --net host \
    projecteru2/cli \
    erucli container deploy --pod eru --entry agent \
    --network host --image projecteru2/agent \
    --cpu 0.05 https://goo.gl/3K3GHb
