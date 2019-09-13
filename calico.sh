#!/bin/bash

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
fi

# calico
export CALICOCTL_VER=v3.4.0
export CALICO_NODE=v3.4

ls /usr/bin | grep calicoctl &> /dev/null || curl -L https://github.com/projectcalico/calicoctl/releases/download/${CALICOCTL_VER}/calicoctl -o /usr/bin/calicoctl
chmod +x /usr/bin/calicoctl

mkdir -p /etc/calico
echo "apiVersion: projectcalico.org/v3
kind: CalicoAPIConfig
metadata:
spec:
  datastoreType: "etcdv3"
  etcdEndpoints: "http://${ERU_ETCD}"
" > /etc/calico/calicoctl.cfg

calicoctl node run --node-image="calico/node:release-${CALICO_NODE}" --disable-docker-networking
cat << EOF | calicoctl create -f -
- apiVersion: projectcalico.org/v3
  kind: IPPool
  metadata:
    name: testpool
  spec:
    natOutgoing: true
    cidr: ${NETPOOL}
EOF

echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
echo 'net.netfilter.nf_conntrack_max=1000000' >> /etc/sysctl.conf
sysctl -p
