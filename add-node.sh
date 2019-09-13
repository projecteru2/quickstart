set -u
: "$ERU_ETCD" "$ERU_CORE" "$NODE_CPU" "$NODE_MEMORY"

. yum.sh

. docker.sh

. calico.sh

. register.sh

. agent.sh

. minions.sh
