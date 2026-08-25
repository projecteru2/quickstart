# quickstart

quickstart is the Ansible playbook that deploys an Eru cluster on Ubuntu hosts. It installs three
things and wires them together: an etcd cluster that holds all cluster metadata, `eru-core` as the
scheduler in front of it, and `eru-agent` on every node that runs workloads.

```
        inventory.yml
              │
   ┌──────────┼──────────────────────────────┐
   │          │                              │
[etcd]     [core]                      [node_docker]
   │          │                              │
 etcd     eru-core ──── gRPC :5001 ───── eru-agent
 :2379    (container)                    (container)
   ▲          │                              │
   └──────────┘                          dockerd :2375
    metadata, locks                     (workloads run here)
```

Each inventory group is a role. A host may belong to several groups — the single-node bootstrap
puts one host in all three.

## Guides

- [Installation](installation.md) — requirements, the inventory, running the playbook, and what
  lands on each host
- [Configuration](configuration.md) — every variable the playbook reads, and the config files it
  renders for core and agent

## Repository

Source and issue tracker: [github.com/projecteru2/quickstart](https://github.com/projecteru2/quickstart).
Part of the [Eru](https://github.com/projecteru2) cluster stack, alongside
[core](https://github.com/projecteru2/core), [agent](https://github.com/projecteru2/agent),
[cli](https://github.com/projecteru2/cli) and
[resource-extend](https://github.com/projecteru2/resource-extend).
