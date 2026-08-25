#!/bin/bash -eu
# Stand up a single-node Eru cluster on this machine.
# Run it as root on a fresh Ubuntu host: bash quickstart.sh

ans_dir=${ANSIBLE_DIR:-/tmp/quickstart}
etcd_version=${ETCD_VERSION:-v3.6.14}

if ! command -v ansible-playbook >/dev/null; then
  apt update
  apt install -y ansible git
fi

rm -fr "${ans_dir}"
git clone https://github.com/projecteru2/quickstart.git "${ans_dir}"
cd "${ans_dir}"

ip=$(ip -4 -o route get 1.1.1.1 | awk '{for (i = 1; i < NF; i++) if ($i == "src") print $(i + 1)}')
if [ -z "${ip}" ]; then
  echo "cannot determine this host's IPv4 address" >&2
  exit 1
fi

cat >inventory.yml <<EOF
---
all:
  children:
    etcd:
      hosts:
        ${ip}:
          etcd_name: etcd0
      vars:
        etcd_version: ${etcd_version}

    core:
      hosts:
        ${ip}:

    node_docker:
      hosts:
        ${ip}:
          node_docker_name: node-$(echo "${ip}" | tr . -)

  vars:
    ansible_connection: local
EOF

ansible-playbook -i inventory.yml cluster.yml
