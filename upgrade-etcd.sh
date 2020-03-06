#!/bin/bash -eu

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
  exit -1
fi

. env.sh

rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf /tmp/etcd-download && mkdir -p /tmp/etcd-download

curl -L ${ETCD_DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download --strip-components=1
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

mv -f /tmp/etcd-download/etcd /usr/bin/etcd
mv -f /tmp/etcd-download/etcdctl /usr/bin/etcdctl

systemctl restart etcd
