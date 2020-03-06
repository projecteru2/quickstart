#!/bin/bash -eu

. env.sh

docker image pull projecteru2/agent

mkdir -p /etc/eru
cat <<EOF >${ERU_AGENT_ETC}
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

sudo cp ${ERU_AGENT_ETC} /tmp

docker run -it --rm \
  --net host \
  -v /tmp:/tmp \
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
