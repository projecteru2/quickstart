#!/bin/bash -eu

. env.sh

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
  exit -1
fi

dist=`./dist.sh`

if [[ $dist == "centos" ]]; then
  echo "Install Docker on CentOS"
  yum install -y docker-ce

  unit_file="/usr/lib/systemd/system/docker.service"

elif [[ $dist == "ubuntu" ]]; then
  echo "Install Docker on Ubuntu"
  apt install -y docker.io

  unit_file="/lib/systemd/system/docker.service"

else
  echo "unsupport dist: ${dist}"
  exit -1
fi

mkdir -p /etc/docker

cat <<EOF >/etc/docker/daemon.json
{
  "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2376"],
  "cluster-store": "etcd://${ETCD}"
}
EOF

sed -i 's/-H\s\+fd:\/\///g' ${unit_file}

systemctl enable docker
systemctl daemon-reload
systemctl restart docker

echo "Docker installing OK"
