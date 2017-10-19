#!/bin/bash

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
fi

# simulate a pod with one node
# node has 2 cpu and 512 memory
# each core will share 10 pieces

# cpu pod will create more containers
export POD_FAVOR="CPU"
export CPU="{\"0\":100,\"1\":100}"
export MEMORY="536870912"
export IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
export PODNAME="eru"

# for testing, we assume pod use CPU favor
etcdctl set /eru-core/pod/${PODNAME}/info "{\"name\":\"eru\",\"desc\":\"eru pod\",\"favor\":\"${POD_FAVOR}\"}"
etcdctl set /eru-core/pod/${PODNAME}/node/${HOSTNAME}/info "{\"name\":\"${HOSTNAME}\",\"endpoint\":\"tcp://${IP}:2376\",\"podname\":\"eru\",\"public\":false,\"available\":true,\"cpu\":${CPU},\"memcap\":${MEMORY}}"
CAPEM=`cat /etc/docker/tls/ca.crt`
KEYPEM=`cat /etc/docker/tls/client.key`
CERTPEM=`cat /etc/docker/tls/client.crt`
etcdctl set -- /eru-core/pod/${PODNAME}/node/${HOSTNAME}/ca.pem "${CAPEM}"
etcdctl set -- /eru-core/pod/${PODNAME}/node/${HOSTNAME}/key.pem "${KEYPEM}"
etcdctl set -- /eru-core/pod/${PODNAME}/node/${HOSTNAME}/cert.pem "${CERTPEM}"

