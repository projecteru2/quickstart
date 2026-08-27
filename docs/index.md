# quickstart

quickstart is the Ansible playbook that deploys an Eru cluster on Ubuntu hosts. It installs the
metadata store, the scheduler in front of it, and the per-node daemon that reports what the nodes
are doing, then registers every node with the scheduler.

```
        inventory.yml
              │
   ┌──────────┼───────────────┬─────────────────┬──────────────────┐
   │          │               │                 │                  │
[etcd]     [core]     [node_containerd]   [node_process]    [node_cocoon]
   │          │               │                 │                  │
 etcd     eru-core         containerd        systemd            cocoon
 :2379       │  │             │                 │                  │
   ▲         │  └─ ssh ──────►│◄────── ssh ─────┴──── ssh ─────────┘
   └─────────┘             eru-agent         eru-agent          eru-agent
  metadata, locks              └───────── grpc :5001 ──────────────┘
```

Core is the only component that talks to etcd. It reaches every node over SSH with its own key
pair — nodes run no daemon that core connects to — and `eru-agent` reports node and workload status
back over gRPC. The engine behind a node is decided by the endpoint it was registered under:
`containerd://` for containers, `process://` for bundles that run as transient systemd units, and
`cocoon://` for VM workloads on a host that already runs cocoon.

Each inventory group is a role. A host may belong to `etcd`, `core` and one node group at once — the
single-node bootstrap puts one host in all three.

## Guides

- [Installation](installation.md) — requirements, the inventory, running the playbook, what lands on
  each host, and how to verify the result
- [Configuration](configuration.md) — every variable the playbook reads, and the config files it
  renders for core, the resource plugins and the agent

## Repository

Source and issue tracker: [github.com/projecteru2/quickstart](https://github.com/projecteru2/quickstart).
Part of the [Eru](https://github.com/projecteru2) cluster stack, alongside
[core](https://github.com/projecteru2/core), [agent](https://github.com/projecteru2/agent),
[cli](https://github.com/projecteru2/cli) and
[resource-extend](https://github.com/projecteru2/resource-extend).
