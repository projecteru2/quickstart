#!/bin/bash -eu

dist=`./dist.sh`

docker ps -a | grep -v CONTAINER | awk '{print $1}' | xargs -I{} sudo docker stop {}
docker ps -a | grep -v CONTAINER | awk '{print $1}' | xargs -I{} sudo docker rm {}
systemctl stop etcd || echo
systemctl stop docker || echo

if [[ $dist == "centos" ]]; then
  yum erase -y docker etcd 
  rm -fr /var/lib/etcd/default.etcd/ /etc/etcd/etcd.conf
  
elif [[ $dist == "ubuntu" ]]; then
  apt remove -y docker etcd
  rm -fr /var/lib/etcd/default/ /etc/default/etcd

else
  echo "unsupport dist: ${dist}"
  exit
fi

rm -fr /etc/calico/calicoctl.cfg
