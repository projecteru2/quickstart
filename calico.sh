#!/bin/bash -eu

. env.sh

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
  exit -1
fi

# Calico is running yet.
docker ps | grep calico &>/dev/null && exit 0

echo "Insall Calico"

# calicoctl installation
ls /usr/bin | grep calicoctl &>/dev/null || curl -L https://github.com/projectcalico/calicoctl/releases/download/${CALICOCTL_VER}/calicoctl -o /usr/bin/calicoctl
chmod +x /usr/bin/calicoctl

mkdir -p /etc/calico
cat <<EOF >/etc/calico/calicoctl.cfg
apiVersion: projectcalico.org/v3

kind: CalicoAPIConfig
metadata:
spec:
  datastoreType: "etcdv3"
  etcdEndpoints: "http://${ETCD}"
EOF

calicoctl node run --node-image="calico/node:release-${CALICO_NODE}" --disable-docker-networking || exit -1

cat <<EOF | calicoctl create -f -
- apiVersion: projectcalico.org/v3
  kind: IPPool
  metadata:
    name: ${CALICO_POOL_NAME}
  spec:
    natOutgoing: true
    cidr: ${CALICO_POOL_CIDR}
EOF

cat <<EOF | calicoctl create -f -
apiVersion: projectcalico.org/v3
kind: Profile
metadata:
  name: ${CALICO_POOL_NAME}
spec:
  egress:
  - action: Allow
    destination: {}
    source: {}
  ingress:
  - action: Allow
    destination: {}
    source: {}
EOF


echo 'net.ipv4.ip_forward=1' >>/etc/sysctl.conf
echo 'net.netfilter.nf_conntrack_max=1000000' >>/etc/sysctl.conf
sysctl -p

echo 'Calico installing OK'
