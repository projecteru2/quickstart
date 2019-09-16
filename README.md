QuickStart
===========

Launch a Eru core and agent, run lambda script on it.

### Requirements

* CentOS 7 with kernel version supporting Docker (>2.6)
* all nodes MUST have distinguished hostname
* iptables MUST be prepared to ensure communication over layer 3 and layer 4

### Run Standalone Node

```
bash quickstart.sh
```

### Add Agent Nodes

Assume standalone node has IP address `$CORE_IP`:

```
export ERU_ETCD=$CORE_IP:2379 ERU_CORE=$CORE_IP:5001 NODE_CPU=1 NODE_MEMORY=498916000
bash add_node.sh
```

`NODE_CPU` and `NODE_MEMORY` is to be adjusted on node capacity, and `NODE_MEMORY` is calculated on bytes.

### Usage

Let's say we want to run 3 redis server on 3 nodes.

Step 1: compose yaml spec for deploy

```
cat > /tmp/spec.yaml <<!
appname: redis
entrypoints:
  singular:
    cmd: '--appendonly yes'
    publish:
      - 6379
!
```

Step 2: use eru-cli to deploy

```
eru-cli container deploy --pod eru --entry singular --image redis --network host --count 1 --deploy-method fill --nodes-limit 3  --memory 10M /tmp/spec.yaml
```

* `--pod` indicates node group on which you want to deploy;
* `--entry` indicates entrypoint written in spec to deploy;
* `--image` indicates docker image to pull and run with;
* `--count 1 --deploy-method fill --node-limit 3` indicates to carry deployment on 3 nodes;
* `--memory` indicates memory limit for each container;

more info see https://book.eru.sh/
