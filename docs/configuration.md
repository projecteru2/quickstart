# Configuration

Everything is set through Ansible variables. Cluster-wide settings live in `group_vars/all.yml`;
per-role settings live in each role's `defaults/main.yml` and can be overridden anywhere Ansible
allows — inventory group vars, host vars, or `-e` on the command line.

## Cluster-wide (`group_vars/all.yml`)

| Variable | Default | Meaning |
| --- | --- | --- |
| `upgrade` | `false` | Remove and recreate the core and agent containers even when they already run |
| `eru_pod` | `eru` | Pod every node joins, and the pod core builds images on |
| `core_port` | `5001` | Port core binds its gRPC API to |
| `core_host` | first host in the `core` group | Host every `eru-cli` call is delegated to |

## essential

| Variable | Default | Meaning |
| --- | --- | --- |
| `essential_packages` | `ca-certificates`, `curl`, `gnupg`, `lvm2`, `openssl`, `python3-debian` | Packages installed on every host before anything else |

## docker

| Variable | Default | Meaning |
| --- | --- | --- |
| `docker_api_port` | `2375` | Port dockerd listens on for the plain TCP API core connects to |

## etcd

| Variable | Default | Meaning |
| --- | --- | --- |
| `etcd_version` | `v3.6.14` | Release tag downloaded from `github.com/etcd-io/etcd` |
| `etcd_data_dir` | `/var/lib/etcd` | etcd data directory |
| `etcd_name` | — | Per-host, required: the etcd member name |

## core

| Variable | Default | Meaning |
| --- | --- | --- |
| `core_image` | `ghcr.io/projecteru2/core:latest` | Image the core container runs |
| `core_cli_image` | `ghcr.io/projecteru2/cli:latest` | Image `eru-cli` is copied out of |
| `core_container_name` | `eru-core` | Name of the core container |
| `core_config_dir` | `/etc/eru` | Directory holding `core.yaml` and the WAL, mounted into the container |

## node_docker

| Variable | Default | Meaning |
| --- | --- | --- |
| `node_docker_agent_image` | `ghcr.io/projecteru2/agent:latest` | Image the agent container runs |
| `node_docker_agent_container_name` | `eru-agent` | Name of the agent container |
| `node_docker_config_dir` | `/etc/eru` | Directory holding `agent.yaml`, mounted into the container |
| `node_docker_name` | — | Per-host, required: the node name registered with core |

Both images are pinned to `latest` by default. For a reproducible deployment set them to a released
tag instead, for example `core_image: ghcr.io/projecteru2/core:v0.1.0`.

## Rendered core config

`roles/core/templates/core.yaml.j2` becomes `/etc/eru/core.yaml`. It sets the etcd machine list from
the `etcd` group, `store: etcd`, a WAL file inside the config directory, `log.level: info`, the
docker defaults (`network_mode: bridge`, json-file logging capped at 10m, `build_pod` set to
`eru_pod`), and the cpumem scheduler defaults (`maxshare: -1`, `sharebase: 100`).

Keys the playbook deliberately leaves out, and what to add if you need them:

- `auth` — core requires no credentials by default. Setting it means also setting
  `ERU_USERNAME`/`ERU_PASSWORD` for `eru-cli` and `auth` in `agent.yaml`.
- `resource_plugin` — external resource plugins such as those in
  [resource-extend](https://github.com/projecteru2/resource-extend). Add `dir` and `call_timeout`
  and drop the plugin binaries into that directory on the core hosts.
- `statsd`, `sentry_dsn`, `profile` — optional telemetry, off by default.
- `cert_path` — needed only for TLS-secured docker daemons.

The full key reference is core's own
[configuration guide](https://projecteru2.github.io/core/configuration.html).

## Rendered agent config

`roles/node_docker/templates/eru-agent.yaml.j2` becomes `/etc/eru/agent.yaml`. It points `core` at
`{{ core_host }}:{{ core_port }}`, talks to dockerd over the mounted unix socket, exposes the agent
HTTP API on `127.0.0.1:12345`, logs to stdout so `docker logs eru-agent` shows something, and sets
the healthcheck interval to 120 seconds. The agent container also gets `ERU_HOSTNAME` set to
`node_docker_name`, which is what ties it to the node registered in core — the two names must match.

`metrics.transfers` and `log.forwards` are left unset, so the agent neither ships metrics to statsd
nor forwards workload logs. Add them to `eru-agent.yaml.j2` if you run those collectors.
