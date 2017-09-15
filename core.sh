#!/bin/bash

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
fi

# eru
echo 'log_level: "DEBUG"
bind: ":5001"
appdir: "/home"
backupdir: "/tmp/backup"
statsd: "127.0.0.1:8125"
zone: "eru-test"
image_cache: 2
global_timeout: 300
lock_timeout: 30

etcd:
    machines:
        - "http://127.0.0.1:2379"
    prefix: "/eru-core"
    lock_prefix: "core/_lock"

git:
    public_key: "***REMOVED***"
    private_key: "***REMOVED***"
    token: "***REMOVED***"
    scm_type: "github"

docker:
    log_driver: "json-file"
    network_mode: "bridge"
    cert_path: "/tmp"
    hub: "hub.docker.com"
    hub_prefix: "projecteru2"
    build_pod: "eru-test"
    local_dns: true

scheduler:
    maxshare: -1
    sharebase: 10

syslog:
    address: "udp://localhost:5111"
    facility: "daemon"
    format: "rfc5424"
' > /etc/eru/core.yaml
docker run -d -e IN_DOCKER=1 \
  --name eru-core --net host \
  --restart always \
  -v /etc/eru:/etc/eru \
  -v /tmp/backup:/tmp/backup \
  projecteru2/core \
  /usr/bin/eru-core
