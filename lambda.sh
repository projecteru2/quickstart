#!/bin/bash

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
fi

# cli
docker run -it --rm \
  --net host \
  projecteru2/cli \
  cli lambda \
  --name data --pod eru --cpu 0.01 --count 10 data
