#!/bin/bash -eu

./upgrade-etcd.sh

./upgrade-eru-core.sh

./upgrade-eru-agent.sh
