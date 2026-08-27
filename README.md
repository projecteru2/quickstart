# quickstart

quickstart is the Ansible playbook that stands up an Eru cluster on Ubuntu hosts: an etcd cluster
for metadata, `eru-core` as the scheduler, its resource plugins, and any number of nodes registered
with core and running `eru-agent`. One inventory file describes the cluster, one command deploys it,
and `quickstart.sh` collapses the whole thing onto a single machine.

**Documentation: [projecteru2.github.io/quickstart](https://projecteru2.github.io/quickstart/)** (source in [`docs/`](docs/)).

## Quick start

One node, on a fresh Ubuntu host, as root:

```shell
curl -fsSL https://raw.githubusercontent.com/projecteru2/quickstart/master/quickstart.sh | bash
```

Several nodes, from any machine with `ansible-core` installed:

```shell
git clone https://github.com/projecteru2/quickstart.git && cd quickstart
cp inventory.yml.example inventory.yml
$EDITOR inventory.yml     # your hosts, and which of them run etcd, core and workloads
make up
```

## Deploying something

`eru-cli` lands on the core hosts, already pointed at core through `ERU`. A deploy needs a spec
file: it carries the app name and the entrypoints, while the flags carry the placement and the
resources.

```shell
cat > /tmp/nginx.yaml <<'EOF'
appname: nginx
entrypoints:
  web:
    commands:
      - nginx
      - -g
      - "daemon off;"
    publish:
      - "80"
EOF

eru-cli workload deploy \
  --pod eru --entry web --image nginx:alpine \
  --network eru --count 1 --cpu 1 --memory 256M --storage 1G \
  /tmp/nginx.yaml
```

`--pod` is the node group to deploy on, `--entry` names an entrypoint from the spec, and `--network`
is the CNI network the playbook configured on every containerd node — pass `host` instead to share
the node's network namespace. `--storage` is accounted by the `resource-storage` plugin, which the
playbook installs alongside core.

`eru-cli pod nodes eru` shows what the cluster holds, and `eru-cli workload list nginx` what is
running. [`verify.sh`](verify.sh) runs the whole loop — cache the image, deploy, `get`, `exec`,
`logs`, `stop`, `start`, `remove` — against a freshly deployed cluster:

```shell
./verify.sh              # or ./verify.sh <nodename>
```

## What it installs

| Group | Host gets |
| --- | --- |
| `etcd` | etcd, from the upstream release tarball, as a systemd unit |
| `core` | `eru-core`, the `resource-storage` and `resource-gpu` plugins, and `eru-cli` |
| `node_containerd` | containerd, runc, the CNI plugins, `eru-agent`, and a node registration |
| `node_process` | `oras` and `eru-agent`; workloads run as transient systemd units |

Core reaches every node over SSH with a key pair the playbook generates for it, so nodes expose no
daemon API of their own. A host may belong to `etcd`, `core` and one node group at once — the
single-node bootstrap does exactly that — but not to both node groups, because one host is one Eru
node with one engine.

## Related projects

- [core](https://github.com/projecteru2/core) — stateless gRPC resource scheduler
- [agent](https://github.com/projecteru2/agent) — per-node daemon reporting node and workload status
- [cli](https://github.com/projecteru2/cli) — command line client for the core API
- [resource-extend](https://github.com/projecteru2/resource-extend) — external resource plugins (gpu, storage)
- [footstone](https://github.com/projecteru2/footstone) — container images the project builds with

## Development

```shell
make check    # ansible-playbook --syntax-check against $(INVENTORY)
make lint     # ansible-lint over every playbook, role and template
make up       # run the playbook; TAGS=etcd,core limits it to those roles
make all      # check, then lint
```

`make help` lists every target. Both checks run in CI on every push and pull request.

## License

This project is licensed under the MIT License. See [`LICENSE`](./LICENSE).
