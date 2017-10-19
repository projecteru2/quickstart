#!/bin/bash

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
fi

# docker
systemctl stop docker
rm -rf /var/lib/docker
rm -rf /etc/docker
rm -rf /etc/eru

# etcd
systemctl stop etcd
rm -rf /var/lib/etcd/.*
