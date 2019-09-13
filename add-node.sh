set -u
: "$ERU_ETCD" "$ERU_CORE" "$NODE_CPU" "$NODE_MEMORY"

. yum.sh
echo yum ok

. docker.sh
echo docker ok

. calico.sh
echo calico ok

. register.sh
echo register ok

. agent.sh
echo agent ok

. minions.sh
echo minion ok
