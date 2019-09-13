set -u
: "$ERU_ETCD" "$ERU_CORE"

. yum.sh

. docker.sh

. calico.sh

. register.sh

. agent.sh

. minions.sh
