#!/bin/bash

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
fi

# Agent
echo 'pid: /tmp/agent.pid
docker:
  endpoint: unix:///var/run/docker.sock
etcd:
  prefix: agent
  etcd:
    - http://127.0.0.1:2379
metrics:
  step: 30
  transfers:
    - 127.0.0.1:8125
api:
  addr: 127.0.0.1:12345
log:
  forwards:
    - udp://127.0.0.1:5144
  stdout: False
' > /etc/eru/agent.yaml
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
