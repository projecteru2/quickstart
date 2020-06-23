QuickStart
===========

Launch a Eru core and agent, run lambda script on it.

### Requirements

* Ubuntu>=1604
* ansible>=2.9.10, jmespath>=0.10.0
* sshpass if ansible runs on macOS

### Run Standalone Node

prepare your inventory and

```
ansible-playbook  -i inventory.yml cluster.yml
```

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
