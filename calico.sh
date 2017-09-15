#!/bin/bash

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
fi

# calico
curl -L https://github.com/projectcalico/calicoctl/releases/download/v1.5.0/calicoctl -o /usr/bin/calicoctl
chmod +x /usr/bin/calicoctl
docker pull calico/node
calicoctl node run --node-image=calico/node
cat << EOF | calicoctl create -f -
- apiVersion: v1
  kind: ipPool
  metadata:
    cidr: 10.213.0.0/16
  spec:
    nat-outgoing: true
EOF
docker network create --driver calico --ipam-driver calico-ipam --subnet 10.213.0.0/16 etest