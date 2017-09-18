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
docker:
  endpoint: unix:///var/run/docker.sock
etcd:
  prefix: agent
  etcd:
    - http://127.0.0.1:2379
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
docker run -d --privileged \
  --name eru_agent_$HOSTNAME \
  --net host \
  --restart always \
  -v /sys/fs/cgroup/:/sys/fs/cgroup/ \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /proc/:/hostProc/ \
  -v /etc/eru:/etc/eru \
  projecteru2/agent \
  /usr/bin/eru-agent
