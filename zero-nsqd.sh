#!/usr/bin/env bash

set -e

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
  exit -1
fi

ip=$(ip address show eth0 | awk '/ inet / {print $2}' | awk -F'/' '{print $1}')

docker inspect nsqlookupd &>/dev/null || docker run -d --name nsqlookupd \
	--restart unless-stopped \
	--network host \
	nsqio/nsq \
	/nsqlookupd

docker inspect nsqd &>/dev/null || docker run -d --name nsqd \
	--restart unless-stopped \
	--network host \
	nsqio/nsq \
	/nsqd --lookupd-tcp-address=127.0.0.1:4160 -broadcast-address $ip

docker inspect nsqadmin &>/dev/null || docker run -d --name nsqadmin \
	--restart unless-stopped \
	--network host \
	nsqio/nsq \
	/nsqadmin --lookupd-http-address=127.0.0.1:4161
