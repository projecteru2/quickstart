# quickstart

quickstart is the Ansible playbook that stands up an Eru cluster on Ubuntu hosts: an etcd cluster
for metadata, `eru-core` as the scheduler, and any number of Docker nodes registered with core and
running `eru-agent`. One inventory file describes the cluster, one command deploys it, and
`quickstart.sh` collapses the whole thing onto a single machine.

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

Deploy something onto the cluster from the core host, where the playbook installs `eru-cli`:

```shell
cat > /tmp/spec.yaml <<'EOF'
appname: redis
entrypoints:
  singular:
    commands:
      - --appendonly
      - "yes"
    publish:
      - "6379"
EOF

eru-cli workload deploy \
  --pod eru --entry singular --image redis:7-alpine \
  --network host --count 1 --deploy-strategy fill --nodes-limit 3 \
  --memory 128M /tmp/spec.yaml
```

`--pod` is the node group to deploy on, `--entry` the entrypoint from the spec, `--count` with
`--deploy-strategy fill --nodes-limit 3` spreads one workload over three nodes, and `--memory` is
the per-workload limit. `eru-cli pod nodes eru` shows what the cluster now holds.

## What it installs

| Group | Host gets |
| --- | --- |
| `etcd` | etcd, from the upstream release tarball, as a systemd unit |
| `core` | Docker, the `eru-core` container, and `eru-cli` in `/usr/local/bin` |
| `node_docker` | Docker, a node registration in core, and the `eru-agent` container |

A host may belong to several groups; the single-node bootstrap puts it in all three.

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
