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
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  yum-config-manager --add-repo https://copr.fedorainfracloud.org/coprs/ngompa/musl-libc/repo/epel-7/ngompa-musl-libc-epel-7.repo
  yum update -y
  yum install -y epel-release yum-utils device-mapper-persistent-data lvm2 openssl musl-libc-static

elif [[ $dist == "ubuntu" ]]; then
  echo "Ubuntu updating..."
  apt update -y
  apt install -y lvm2 openssl

else
  echo "unsupport dist: ${dist}"
  exit -1
fi

echo "Updating OK"
