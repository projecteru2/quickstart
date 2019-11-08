#!/bin/bash -eu

. env.sh

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
  exit -1
fi

mkdir -p /etc/eru
cat <<EOF >/tmp/agent.yaml
pid: /tmp/agent.pid

health_check_interval: 5
health_check_timeout: 10
core: 127.0.0.1:5001

docker:
  endpoint: tcp://127.0.0.1:2376
metrics:
  step: 30
  transfers:
    - ${STATSD}
api:
  addr: ${ERU_AGENT_LISTEN}
log:
  forwards:
    - ${ERU_AGENT_LOGS}
  stdout: False
EOF

echo "Install ERU agnet"

docker image pull projecteru2/agent

docker run -it --rm \
  --net host \
  -v /tmp/agent.yaml:/tmp/agent.yaml \
  projecteru2/cli \
  eru-cli --eru $ERU_CORE container deploy \
    --pod ${ERU_POD} \
    --node ${ERU_NODE} \
    --entry agent \
    --file /tmp/agent.yaml:/agent.yaml \
    --network host \
    --image projecteru2/agent \
    --cpu 0.05 \
    --memory 104857600 \
    --env="ERU_HOSTNAME=${ERU_NODE}" \
    https://raw.githubusercontent.com/projecteru2/agent/master/spec.yaml

echo "ERU agent installing OK"
