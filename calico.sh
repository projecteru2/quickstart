#!/bin/bash

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
fi

# calico
export CALICOCTL_VER=v1.5.0
export NETPOOL=10.213.0.0/16
export NETNAME="etest"
curl -L https://github.com/projectcalico/calicoctl/releases/download/${CALICOCTL_VER}/calicoctl -o /usr/bin/calicoctl
chmod +x /usr/bin/calicoctl
docker pull calico/node
calicoctl node run --node-image=calico/node
cat << EOF | calicoctl create -f -
- apiVersion: v1
  kind: ipPool
  metadata:
    cidr: ${NETPOOL}
  spec:
    nat-outgoing: true
EOF
docker network create --driver calico --ipam-driver calico-ipam --subnet ${NETPOOL} ${NETNAME}
