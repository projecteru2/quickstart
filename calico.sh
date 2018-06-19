#!/bin/bash

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
fi

# calico
export CALICOCTL_VER=v3.1.3
export NETPOOL=10.213.0.0/16
export NETNAME="etest"
curl -L https://github.com/projectcalico/calicoctl/releases/download/${CALICOCTL_VER}/calicoctl -o /usr/bin/calicoctl
chmod +x /usr/bin/calicoctl

mkdir -p /etc/calico
echo "apiVersion: projectcalico.org/v3
kind: CalicoAPIConfig
metadata:
spec:
  datastoreType: "etcdv3"
  etcdEndpoints: "http://${ERU_ETCD}"
" > /etc/calico/calicoctl.cfg

calicoctl node run --node-image=calico/node
cat << EOF | calicoctl create -f -
- apiVersion: projectcalico.org/v3
  kind: IPPool
  metadata:
    name: testpool
  spec:
    natOutgoing: true
    cidr: ${NETPOOL}
EOF

# prepare docker plugin
mkdir -p /etc/eru
echo "ETCD_ENDPOINTS=http://${ERU_ETCD}" > /etc/eru/minions.conf
rpm -i https://12-137714834-gh.circle-artifacts.com/0/RPM/eru-minions-0.1-1.el7.x86_64.rpm
systemctl enable eru-minions
systemctl start eru-minions

docker network create --driver calico --ipam-driver calico-ipam --subnet ${NETPOOL} ${NETNAME}
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.netfilter.nf_conntrack_max=1000000
