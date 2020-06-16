#!/bin/bash -eu

. env.sh

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
  exit -1
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

config_file=/etc/etcd/etcd.yaml
mkdir -p ${config_file%/*}
IFS=,; for netloc in $ETCD_NETLOC; do
    IFS=':' read ipv4 _ <<<"$netloc"
    ((i++))
    name="etcd$i"
    cluster+=("$name=http://$ipv4:2379")
    if [[ "$i" == "${ETCD_IDX:=1}" ]] then
        NAME=$name
        IPV4=$ipv4
    fi
done
INIT_CLUSTER=$(echo "${cluster[*]}")
eval "cat <<< \"$(cat etcd.conf.tmpl)\"" > $config_file

cat <<EOF >${env_file}
ETCD_CONFIG_FILE=$config_file
EOF

sed -i 's/ExecStart=.*$/ExecStart=\/usr\/bin\/etcd/g' $unit_file

systemctl enable etcd
systemctl daemon-reload
systemctl restart etcd

lsof -i:2379 && echo "ETCD OK" || echo "ETCD failed"
