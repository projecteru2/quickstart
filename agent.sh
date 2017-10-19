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
echo '
appname: "eru"
entrypoints:
  agent:
    cmd: "/usr/bin/eru-agent"
    restart: always
    publish:
      - "12345"
    healthcheck:
      ports:
        - "12345/tcp"
    privileged: true
    log_config: "journald"
volumes:
  - "/etc/eru:/etc/eru"
  - "/sys/fs/cgroup/:/sys/fs/cgroup/"
  - "/var/run/docker.sock:/var/run/docker.sock"
  - "/proc/:/hostProc/"
' > /tmp/spec.yaml

docker run -it --rm \
    --net host \
    -v /tmp/spec.yaml:/tmp/spec.yaml \
    projecteru2/cli \
    erucli container deploy --pod eru --entry agent \
    --network host --image projecteru2/agent \
    --cpu 0.05 /tmp/spec.yaml
