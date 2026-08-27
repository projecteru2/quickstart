#!/bin/bash
# Stand up a single-node Eru cluster on this machine.
# Run it as root on a fresh Ubuntu host: bash quickstart.sh
#
# The host becomes an etcd member, core, the resource plugins, eru-cli and one
# node. A host is exactly one Eru node, so it is either a containerd node or a
# process node: set ERU_NODE_KIND=process for the latter.

ans_dir=${ANSIBLE_DIR:-/tmp/quickstart}
set -eu

node_kind=${ERU_NODE_KIND:-containerd}

case "${node_kind}" in
  containerd | process) ;;
  *)
    echo "ERU_NODE_KIND must be containerd or process, got ${node_kind}" >&2
    exit 1
    ;;
esac

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

member=$'\n      hosts:\n        '"${ip}:"
containerd_group=" {}"
process_group=" {}"
if [ "${node_kind}" = process ]; then
  process_group="${member}"
else
  containerd_group="${member}"
fi

cat >inventory.yml <<EOF
---
all:
  children:
    etcd:
      hosts:
        ${ip}:
          etcd_name: etcd0

    core:
      hosts:
        ${ip}:

    node_containerd:${containerd_group}

    node_process:${process_group}

  vars:
    ansible_connection: local
EOF

ansible-playbook -i inventory.yml cluster.yml

cat <<EOF

The cluster is up. Core listens on ${ip}:5001 and eru-cli already points at it:

  eru-cli pod nodes eru
  ./verify.sh

EOF
