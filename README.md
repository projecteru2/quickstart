QuickStart
===========

Launch a Eru core and agent, run lambda script on it.

### Run

```./quickstart.sh```

Noted, we use [docker mirror for china](https://www.docker-cn.com/registry-mirror) for acceleration.
And, this project was full tested under CentOS 7. If you used another OS, maybe it will not work.

### How it works

* yum.sh make system updated.
* etcd.sh install etcd and update it to 3.2.X.
* docker.sh install docker, and configure it.
* calico.sh run calico node, create a SDN network and register in docker.
* register.sh register pod and node.
* agent.sh run agent on node. run agent in container.
* core.sh run core in container.
* lambda.sh run lambda commands.

* clean.sh reset server.


