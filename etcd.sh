#!/bin/bash

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
fi

# etcd
yum install -y etcd
# update to 3.2.6+
export ETCD_VER=v3.2.18
export DOWNLOAD_URL=https://github.com/coreos/etcd/releases/download

curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
mkdir -p /tmp/etcd
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd --strip-components=1
mv /tmp/etcd/etcd /usr/bin/etcd
mv /tmp/etcd/etcdctl /usr/bin/etcdctl
