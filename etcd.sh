#!/bin/bash -eu

. env.sh

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
fi

dist=`./dist.sh`

if [[ $dist == "centos" ]]; then
  echo "Install ETCD on CentOS"
  yum install -y etcd

  env_file="/etc/etcd/etcd.conf"
  mkdir -p /etc/etcd

  unit_file="/usr/lib/systemd/system/etcd.service"

elif [[ $dist == "ubuntu" ]]; then
  echo "Install ETCD on Ubuntu"
  apt install -y etcd

  env_file="/etc/default/etcd"
  mkdir -p /etc/default

  unit_file="/lib/systemd/system/etcd.service"

else
  echo "unsupport dist: ${dist}"
  exit -1
fi

cat <<EOF >${env_file}
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://0.0.0.0:2379"
EOF

sed -i 's/ExecStart=.*$/ExecStart=\/usr\/bin\/etcd/g' $unit_file

systemctl enable etcd
systemctl daemon-reload
systemctl restart etcd

echo "ETCD installing OK"
