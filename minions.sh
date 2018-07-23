#!/bin/bash

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
fi

export NETPOOL=10.213.0.0/16
export NETNAME="etest"

echo '
appname: "eru"
entrypoints:
  minions:
    cmd: "/usr/bin/eru-minions"
    restart: "always"
    log_config: "journald"
    privileged: true
volumes:
  - "/var/run/docker/plugins/:/var/run/docker/plugins"
' > /tmp/spec.yaml

docker run -it --rm \
    --net host \
    -v /tmp/spec.yaml:/tmp/spec.yaml \
    projecteru2/cli \
    eru-cli container deploy --pod eru --entry minions \
    --network host --image projecteru2/minions \
    --cpu 0.05 --mem 104857600 --env ETCD_ENDPOINTS=http://${ERU_ETCD} /tmp/spec.yaml

docker network create --driver calico --ipam-driver calico-ipam --subnet ${NETPOOL} ${NETNAME}
