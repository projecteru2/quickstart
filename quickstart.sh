#!/bin/bash -eu

ans_dir=/tmp/quickstart
rm -fr ${ans_dir}
git clone https://github.com/projecteru2/quickstart.git ${ans_dir}
cd ${ans_dir}

hn=$(ip a show eth0 | grep inet | grep -v inet6 | awk '{print $2}' | awk -F/ '{print $1}')

cat <<EOF >inventory.yml
all:
  children:
    etcd:
      hosts:
        ${hn}:
          etcd_name: etcd0
      vars:
        etcd_version: v3.3.4

    core:
      hosts:
        ${hn}:

    node_docker:
      hosts:
        ${hn}:
          node_docker_name: docker0
          node_calico_name: calico0

    calico:
      children:
        core:
        node_docker:
      vars:
        calico_version: v3.4
        calico_ippool_name: testpool
        calico_ippool_cidr: 10.10.0.0/16
EOF

rm -fr /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock
dpkg --configure -a

apt update -y

ansible-playbook --become -i inventory.yml cluster.yml

source /etc/profile
