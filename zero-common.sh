#!/usr/bin/env bash

set -e

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
  exit -1
fi

# update image
echo Cloud123 | docker login --username cloud --password-stdin harbor.shopeemobile.com
docker pull $ZEROIMAGE

# gen config
docker run --rm \
	-v /tmp:/tmp \
	-e VIRTUALDEV_NETWORK=testpool \
	-e VIRTUALDEV_PODNAME=testpod \
	-e VIRTUALDEV_VOLUMES="/data/shared:/data/shared:rw" \
	-e ETCD_MACHINES=127.0.0.1:2379 \
	-e ERU=127.0.0.1:5001 \
	-e DEPLOY_ENV=dev \
	-e API_BIND=0.0.0.0:8000 \
	-e NSQ_TOPICS=rediscluster,redissingular,etcdcluster \
	-e NSQD=127.0.0.1:4151 \
	-e NSQ_LOOKUPS=127.0.0.1:4161 \
	$ZEROIMAGE \
	/bin/sh /usr/bin/make_config.sh
mv /tmp/zero.yaml /etc/
