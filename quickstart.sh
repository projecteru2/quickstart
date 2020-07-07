#!/bin/bash -eu

ans_dir=/tmp/quickstart
rm -fr ${ans_dir}
git clone https://github.com/projecteru2/quickstart.git ${ans_dir}
cd ${ans_dir}

hn=127.0.0.1

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

ansible-playbook --become -i inventory.yml cluster.yml
