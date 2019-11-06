#!/bin/bash -eu

. env.sh

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
fi

# eru-core is running yet.
docker ps | grep eru_core &>/dev/null && exit 0

echo "Install eru-core"

mkdir -p /etc/eru
cat <<EOF >/etc/eru/core.yaml
log_level: DEBUG
bind: "${ERU_BIND}"
statsd: "${STATSD}"
image_cache: 2
global_timeout: 300s
lock_timeout: 30s

etcd:
    machines:
        - "http://${ETCD}"
    prefix: "/eru-core"
    lock_prefix: "core/_lock"

docker:
    log:
      type: "json-file"
      config:
        "max-size": "10m"
    network_mode: "bridge"
    cert_path: ""
    hub: "hub.docker.com"
    namespace: "projecteru2"
    build_pod: "${ERU_POD}"
    local_dns: true

scheduler:
    maxshare: -1
    sharebase: ${ERU_SHARES}
EOF

docker image pull projecteru2/core

docker run -d \
  --name eru_core_$(hostname) \
  --net host \
  --restart always \
  -v /etc/eru:/etc/eru \
  projecteru2/core \
  /usr/bin/eru-core

echo "eru-core is running"
