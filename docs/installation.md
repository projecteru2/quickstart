# Installation

## Requirements

On the machine running the playbook: `ansible-core`. The playbook uses only builtin modules, so no
Galaxy collections need installing.

On every target host: Ubuntu, reachable over SSH as a user who can `become` root, with `sshd`
reading `/etc/ssh/sshd_config.d/*.conf` — the stock Ubuntu configuration does. Everything the
playbook installs comes from upstream GitHub releases; only a handful of base packages come from
apt.

## The inventory

Copy `inventory.yml.example` to `inventory.yml` — the latter is gitignored — and edit it. Four
groups matter:

| Group | Meaning | Host variables |
| --- | --- | --- |
| `etcd` | runs an etcd member | `etcd_name`, the unique member name |
| `core` | runs `eru-core`, its resource plugins and `eru-cli`; the first host is the one every `eru-cli` call is delegated to | — |
| `node_containerd` | runs containers | `node_containerd_name`, the node name registered with core |
| `node_process` | runs process bundles as systemd units | `node_process_name` |

Both node names default to the host's own hostname, which is also what `eru-agent` reports under, so
they can be left out entirely.

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
    node_containerd:
      hosts:
        192.0.2.11:
    node_process: {}
  vars:
    ansible_user: root
```

The group names are fixed: `cluster.yml` maps each one to its role. A host may be in `etcd`, `core`
and one node group at the same time, but not in both node groups — one host is one Eru node, and a
node has exactly one engine.

## Running it

```shell
make up                      # everything
make up TAGS=etcd,core       # only those roles
make up INVENTORY=other.yml  # a different inventory
```

`make up` is `ansible-playbook -i inventory.yml cluster.yml`; use that directly if you prefer.
Re-running is safe: every download is keyed on its pinned version, and both `pod add` and `node add`
treat an existing pod or node as success. Bumping a version in `group_vars/all.yml` and re-running
installs the new binary and restarts the service.

## Single node

`quickstart.sh` writes an inventory that puts this host in `etcd`, `core` and `node_containerd`, and
runs the playbook against `localhost`:

```shell
curl -fsSL https://raw.githubusercontent.com/projecteru2/quickstart/master/quickstart.sh | bash
```

It installs `ansible` from apt if it is missing, detects the host's IPv4 address from the default
route, and clones the repository to `/tmp/quickstart` (override with `ANSIBLE_DIR`). Run it as root.
`ERU_NODE_KIND=process` registers the host as a process node instead of a containerd one.

Ansible connects locally, but core still reaches the node over a real SSH connection to its own
address, so `sshd` has to be running.

## What lands on each host

**etcd hosts.** The `etcd-<version>-linux-<arch>.tar.gz` release tarball from GitHub, unpacked into
`/usr/local/bin/etcd` and `/usr/local/bin/etcdctl`, configured by `/etc/etcd/etcd.conf` and started
by an `etcd.service` systemd unit. Data lives in `/var/lib/etcd`. The members form one cluster with
initial token `eru`, listening on `:2379` for clients and `:2380` for peers.

**core hosts.** `eru-core` in `/usr/local/bin`, `/etc/eru/core.yaml` rendered from the inventory,
and an `eru-core.service` systemd unit. The playbook generates core's SSH key pair at
`/etc/eru/ssh_key` if it is not already there — this is the key every node authorizes, and core uses
it for containerd and process nodes alike. The `resource-storage` and `resource-gpu` plugin binaries
and their configs go into `/etc/eru/plugins`, which is what `resource_plugin.dir` points at. Finally
`eru-cli` lands in `/usr/local/bin` and `/etc/profile.d/eru.sh` exports `ERU` so interactive shells
find core without flags.

**node_containerd hosts.** containerd and `ctr` from the upstream release into `/usr/local/bin`,
`runc` into `/usr/local/sbin`, the CNI plugin binaries into `/opt/cni/bin`, and a bridge conflist
named `eru` into `/etc/cni/net.d`. Core's public key is authorized for root, journald's rate limits
are raised, `eru-agent` is installed into `/usr/local/bin` with `/etc/eru/agent.yaml` and an
`eru-agent.service` unit, and the node is registered as `containerd://root@<host>:22`.

**node_process hosts.** `oras` and `eru-agent` into `/usr/local/bin`, an `agent.yaml` configured for
the systemd runtime, core's key authorized for root, journald's rate limits raised, and the node
registered as `process://root@<host>:22`. There is no container runtime: a process workload is a
bundle core pulls with `oras` and runs as a transient systemd unit under `/var/lib/eru/process`.

## Ordering the playbook has to respect

Three constraints decide the order inside a node role, and they are worth knowing before editing it:

- `eru-agent` must sit at `/usr/local/bin/eru-agent` before the node is registered. Core writes that
  exact path into every container spec as the CNI hook and the log shim, and probes it over SSH when
  the node is added: a containerd node whose binary is missing is refused.
- The node must be registered before `eru-agent` starts, because the agent asks core for its own
  node record at startup and exits if core does not know it.
- containerd has to be running before the node is added, since core queries the engine for the
  node's cpu, memory and storage while adding it.

## Verifying

From a core host, `verify.sh` runs the full loop against one node — cache the image, deploy nginx,
`get`, `exec`, `logs`, `stop`, `start`, `remove`, and print the node's resources afterwards:

```shell
./verify.sh              # the local hostname is the node name
./verify.sh worker-2     # or name one
```

By hand:

```shell
eru-cli pod nodes --filter up eru     # the node should be listed
eru-cli node resource $(hostname)
journalctl -u eru-core -n 50
journalctl -u eru-agent -n 50         # on a node
```

A node that never comes up is almost always core failing to reach it over SSH. Check that from the
core host:

```shell
ssh -i /etc/eru/ssh_key root@<node> /usr/local/bin/eru-agent oci-hook --help
```

That is the probe core itself runs when a containerd node is added.

## Cocoon nodes

A `node_cocoon` host runs VM workloads. The playbook deliberately does not install cocoon — its
hypervisor stack (cloud-hypervisor or firecracker, guest firmware, CNI) has its own documentation
and release cadence — so the prerequisites on the node are: cocoon installed with its daemon
running (`node_cocoon_binary`, `node_cocoon_socket`), `/dev/kvm` present — on a virtual host that
means nested virtualization — and `mkfs.erofs` from erofs-utils ≥ 1.8 for OCI direct-boot images
(Ubuntu 22.04 ships 1.2, which cocoon refuses; build erofs-utils from source or use a newer
distribution). The role's preflight refuses the node otherwise. What the role
does do: authorizes core's key, raises the journald limits, installs `eru-agent` against the
daemon socket, and registers the node as `cocoon://<user>@<host>:22` into the `vm` pod. The
`cocoon:` block in core.yaml (binary, record root, run_dir, cgroup parent) renders only when the
inventory has cocoon nodes, and its values must match the node-side install.
