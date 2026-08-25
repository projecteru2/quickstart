# Installation

## Requirements

On the machine running the playbook: `ansible-core`. The playbook uses only builtin modules, so no
Galaxy collections need installing.

On every target host: Ubuntu, reachable over SSH as a user who can `become` root. `python3-debian`
is installed by the playbook itself (the `essential` role) because the apt repository module needs
it; everything else the playbook installs is pulled from upstream apt repositories, GitHub releases
or GHCR.

## The inventory

Copy `inventory.yml.example` to `inventory.yml` — the latter is gitignored — and edit it. Three
groups matter:

| Group | Meaning | Host variables |
| --- | --- | --- |
| `etcd` | runs an etcd member | `etcd_name`, the unique member name |
| `core` | runs `eru-core`; the first host is the one every `eru-cli` call is delegated to | — |
| `node_docker` | runs workloads | `node_docker_name`, the node name registered with core |

```yaml
all:
  children:
    etcd:
      hosts:
        192.0.2.11:
          etcd_name: etcd0
    core:
      hosts:
        192.0.2.11:
    node_docker:
      hosts:
        192.0.2.11:
          node_docker_name: node-192-0-2-11
  vars:
    ansible_user: root
```

The group names are fixed: `cluster.yml` maps each one to its role.

## Running it

```shell
make up                      # everything
make up TAGS=etcd,core       # only those roles
make up INVENTORY=other.yml  # a different inventory
```

`make up` is `ansible-playbook -i inventory.yml cluster.yml`; use that directly if you prefer.
Re-running is safe: the roles skip an etcd, core or agent that is already in place. To replace a
running core or agent container with a newer image, set `upgrade: true` in `group_vars/all.yml` (or
pass `-e upgrade=true`) and run again.

## Single node

`quickstart.sh` writes an inventory that puts this host in all three groups and runs the playbook
against `localhost`:

```shell
curl -fsSL https://raw.githubusercontent.com/projecteru2/quickstart/master/quickstart.sh | bash
```

It installs `ansible` from apt if it is missing, detects the host's IPv4 address from the default
route, and clones the repository to `/tmp/quickstart` (override with `ANSIBLE_DIR`). Run it as root.

## What lands on each host

**etcd hosts.** The `etcd-<version>-linux-<arch>.tar.gz` release tarball from GitHub, unpacked into
`/usr/bin/etcd` and `/usr/bin/etcdctl`, configured by `/etc/etcd/etcd.conf` and started by an
`etcd.service` systemd unit. Data lives in `/var/lib/etcd`. The members form one cluster with
initial token `eru`, listening on `:2379` for clients and `:2380` for peers.

**core hosts.** Docker from Docker's own apt repository, `/etc/eru/core.yaml` rendered from the
inventory, and the `eru-core` container running with `--net host` and `/etc/eru` mounted in. The
playbook then copies `eru-cli` out of the cli image into `/usr/local/bin/eru-cli` and creates the
pod named by `eru_pod`.

**node_docker hosts.** Docker, configured through `/etc/docker/daemon.json` to listen on both the
unix socket and `tcp://0.0.0.0:2375`, plus a systemd drop-in that drops the distribution unit's `-H`
flag so `daemon.json` owns the listen addresses. The node is registered with core over that TCP
endpoint, `/etc/eru/agent.yaml` is rendered, and the `eru-agent` container is started with
`--net host` and the docker socket mounted in.

That TCP endpoint is how core reaches the node, and it is **unauthenticated**. Keep port 2375
reachable only from the core hosts — with a firewall, a private network, or both. For a TLS-secured
daemon instead, point `docker_api_port` at 2376, configure dockerd's certificates yourself, and pass
`--ca/--cert/--key` when registering the node.

## Verifying

From a core host:

```shell
eru-cli pod list
eru-cli pod nodes eru
docker logs eru-core
```

On a node:

```shell
docker logs eru-agent
```
