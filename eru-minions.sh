#!/bin/bash -eu

. env.sh

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
  exit -1
fi

echo "Install ERU minions"

docker image pull projecteru2/minions

docker run -it --rm \
  --net host \
  projecteru2/cli \
  eru-cli --eru $ERU_CORE container deploy \
    --pod ${ERU_POD} \
    --node $(hostname) \
    --entry minions \
    --network host \
    --image projecteru2/minions \
    --cpu 0.05 \
    --memory 104857600 \
    --env ETCD_ENDPOINTS=http://${ETCD} \
    https://raw.githubusercontent.com/projecteru2/minions/master/app.yaml

docker network create \
  --driver calico \
  --ipam-driver calico-ipam \
  --subnet ${CALICO_POOL_CIDR} \
  ${CALICO_POOL_NAME}

echo 1 >/proc/sys/net/ipv6/conf/all/disable_ipv6
echo 1 >/proc/sys/net/ipv6/conf/default/disable_ipv6

echo "ERU minions installing OK"
