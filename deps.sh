#!/bin/bash -eu

. env.sh

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
  exit -1
fi

dist=`./dist.sh`

if [[ $dist == "centos" ]]; then
  echo "CentOS updating..."
  yum update -y
  yum install -y epel-release yum-utils device-mapper-persistent-data lvm2 openssl
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

elif [[ $dist == "ubuntu" ]]; then
  echo "Ubuntu updating..."
  apt update -y
  apt install -y lvm2 openssl

else
  echo "unsupport dist: ${dist}"
  exit -1
fi

echo "Updating OK"
