#!/bin/bash -eu
# Smoke-test an Eru cluster: deploy nginx on one node, drive it through every
# workload verb, then remove it. Run it on a host that has eru-cli, which the
# playbook installs on the core hosts.
#
#   ./verify.sh [nodename]
#
# nodename defaults to this host's hostname, which is what the playbook
# registers a node under. ERU, ERU_POD, ERU_NETWORK and ERU_IMAGE override the
# target core, the pod, the cni network and the image.

export ERU=${ERU:-127.0.0.1:5001}
pod=${ERU_POD:-eru}
network=${ERU_NETWORK:-eru}
image=${ERU_IMAGE:-nginx:alpine}
node=${1:-$(hostname)}

step() { printf '\n== %s\n' "$1"; }

step "nodes up in pod ${pod}"
eru-cli pod nodes --filter up "${pod}"

step "caching ${image} on ${node}"
eru-cli image cache --node "${node}" "${image}"

spec=$(mktemp /tmp/eru-verify-XXXXXX.yaml)
trap 'rm -f "${spec}"' EXIT
cat >"${spec}" <<'EOF'
appname: nginx
entrypoints:
  web:
    commands:
      - nginx
      - -g
      - "daemon off;"
    publish:
      - "80"
EOF

step "deploying ${image} on ${node}"
deployed=$(eru-cli workload deploy \
  --pod "${pod}" --node "${node}" --entry web --image "${image}" \
  --network "${network}" --cpu 1 --memory 256M --storage 1G --count 1 \
  "${spec}")
printf '%s\n' "${deployed}"

id=$(printf '%s' "${deployed}" | grep -oE 'nginx_web_[A-Za-z0-9]+|[0-9a-f]{32}' | head -n 1)
if [ -z "${id}" ]; then
  echo "the deploy reported no workload id" >&2
  exit 1
fi

step "workload ${id}"
eru-cli workload get "${id}"

step "exec"
eru-cli workload exec "${id}" -- nginx -v

step "logs"
eru-cli workload logs --tail 20 "${id}"

step "stop"
eru-cli workload stop "${id}"

step "start"
eru-cli workload start "${id}"

step "remove"
eru-cli workload remove "${id}"

step "node resources after the run"
eru-cli node resource "${node}"

printf '\nverified\n'
