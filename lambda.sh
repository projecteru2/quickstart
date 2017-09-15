#!/bin/bash

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
fi

# lambda
echo 'servers:
  - 127.0.0.1:5001
concurrency: 15
default:
  adminpod: "test"
  adminvolumes:
    - "/tmp:/tmp/host"
  pod: "test"
  image: "alpine:3.6"
  network: "etest"
  working_dir: "/tmp"
  cpu: 1.0
  memory: 33554432
  timeout: 15
  openstdin: false
' > /etc/eru/lambda.yaml
docker run -it --rm -e IN_DOCKER=1 \
  --name eru-lambda --net host \
  -v /etc/eru:/etc/eru \
  projecteru2/lambda \
  /usr/bin/eru-lambda --name test --command date --raw