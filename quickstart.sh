#!/bin/bash
# Date: 2017-9-13
# Usage: deploy eru-core, eru-agent in one node
#        and run eru-lambda for example

set -e

# dist. deps. installation.
./deps.sh

./etcd.sh
./docker.sh
./calico.sh

./eru-core.sh
./eru-register.sh
./eru-agent.sh
./eru-minions.sh

export ZEROIMAGE=harbor.shopeemobile.com/cloud/zero:master
./zero-common.sh
./zero-nsqd.sh
./zero-programs.sh

echo all done
