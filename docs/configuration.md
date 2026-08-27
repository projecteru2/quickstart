# Configuration

Everything is set through Ansible variables. Cluster-wide settings live in `group_vars/all.yml`;
per-role settings live in each role's `defaults/main.yml` and can be overridden anywhere Ansible
allows — inventory group vars, host vars, or `-e` on the command line.

## Cluster-wide (`group_vars/all.yml`)

Every version the playbook installs is pinned here and nowhere else, so a bump is a one-line change.

| Variable | Default | Meaning |
| --- | --- | --- |
| `eru_core_version` | `v0.1.1` | Release tag of `eru-core` |
| `eru_agent_version` | `v0.1.1` | Release tag of `eru-agent` |
| `eru_cli_version` | `v0.1.2` | Release tag of `eru-cli` |
| `eru_resource_extend_version` | `v0.1.2` | Release tag of the resource plugins |
| `etcd_version` | `v3.6.14` | Release tag of etcd |
| `containerd_version` | `v2.3.4` | Release tag of containerd |
| `runc_version` | `v1.5.1` | Release tag of runc |
| `cni_plugins_version` | `v1.9.1` | Release tag of the CNI plugins |
| `oras_version` | `v1.3.3` | Release tag of `oras`, used on process nodes |
| `eru_download_dir` | `/opt/eru/dist` | Where release archives are unpacked, one directory per version |
| `eru_bin_dir` | `/usr/local/bin` | Where binaries land |
| `eru_config_dir` | `/etc/eru` | Where `core.yaml` and `agent.yaml` live |
| `eru_ssh_key` | `/etc/eru/ssh_key` | Core's private key, on the core host; nodes authorize its public half |
| `eru_ssh_user` | `root` | The user core logs into nodes as |
| `eru_pod` | `eru` | Pod the containerd nodes join |
| `eru_process_pod` | `proc` | Pod the process nodes join |
| `core_host` | first host in the `core` group | Host every `eru-cli` call is delegated to |
| `core_port` | `5001` | Port core binds its gRPC API to |

`eru_bin_dir` is not a free choice: core writes `/usr/local/bin/eru-agent` into every container spec
as the CNI hook and log shim, and that path is compiled into core.

## essential

| Variable | Default | Meaning |
| --- | --- | --- |
| `essential_packages` | `ca-certificates`, `curl`, `iptables`, `openssh-client` | Packages installed on every host before anything else |

`iptables` is what the CNI bridge plugin shells out to for outbound NAT; `openssh-client` provides
the `ssh-keygen` that generates core's key pair.

## etcd

| Variable | Default | Meaning |
| --- | --- | --- |
| `etcd_data_dir` | `/var/lib/etcd` | etcd data directory |
| `etcd_client_port` | `2379` | Client port, which core and the plugins connect to |
| `etcd_peer_port` | `2380` | Peer port |
| `etcd_cluster_token` | `eru` | Initial cluster token |
| `etcd_name` | — | Per-host, required: the etcd member name |

## core

| Variable | Default | Meaning |
| --- | --- | --- |
| `core_service` | `eru-core` | Name of the systemd unit |
| `core_plugin_dir` | `/etc/eru/plugins` | `resource_plugin.dir`; core loads every executable file in it |
| `core_plugin_call_timeout` | `30s` | How long core waits for a plugin to answer |
| `core_log_level` | `info` | `log.level` in `core.yaml` |
| `core_max_deploy_count` | `10000` | `scheduler.max_deploy_count` |
| `core_containerd_socket` | `/run/containerd/containerd.sock` | Node-side containerd socket core forwards over SSH |
| `core_containerd_namespace` | `eru` | containerd namespace core creates containers in |
| `core_process_root` | `/var/lib/eru/process` | Where core unpacks process bundles on a node |
| `core_registry_hub` | `""` | Registry built images are pushed to; empty omits the `registry` block |
| `core_registry_namespace` | `eru` | Namespace under that hub |
| `core_registry_plain_http` | `[]` | Registry hosts served over http rather than TLS |
| `core_build_pod` | `""` | Pod whose nodes may build images; empty lets any node build |

The containerd socket and namespace have to match `node_containerd_socket` and
`node_containerd_namespace` on the nodes, and `core_process_root` has to match `node_process_root`.

## plugins

| Variable | Default | Meaning |
| --- | --- | --- |
| `plugins_enabled` | `resource-storage`, `resource-gpu` | Which plugin binaries to install |
| `plugins_dir` | `/etc/eru/plugins` | Where they go; must equal `core_plugin_dir` |
| `plugins_core_service` | `eru-core` | Unit restarted when a plugin changes |
| `plugins_storage_etcd_prefix` | `/eru-storage` | etcd key prefix for the storage plugin |
| `plugins_gpu_etcd_prefix` | `/eru-gpu` | etcd key prefix for the gpu plugin |
| `plugins_storage_max_deploy_count` | `1000` | Cap on the deploy capacity the storage plugin reports |

The file names are load-bearing. Core names a resource after the binary it found, and `eru-cli`'s
`--storage` flag addresses the plugin called `resource-storage`; renaming the binary renames the
resource. Drop `resource-gpu` from `plugins_enabled` on a cluster with no GPUs — nothing else
changes, since a node registered without GPU cards simply has none.

## cli

| Variable | Default | Meaning |
| --- | --- | --- |
| `cli_profile_path` | `/etc/profile.d/eru.sh` | Shell snippet exporting `ERU` for interactive use |

## node_containerd

| Variable | Default | Meaning |
| --- | --- | --- |
| `node_containerd_name` | the host's hostname | Node name registered with core, and the agent's `ERU_HOSTNAME` |
| `node_containerd_pod` | `{{ eru_pod }}` | Pod the node joins |
| `node_containerd_endpoint_host` | `{{ inventory_hostname }}` | Address core opens the SSH connection to |
| `node_containerd_ssh_port` | `22` | Port of that connection |
| `node_containerd_storage` | `""` | `--storage` at registration; empty lets the plugin take 80% of the disk |
| `node_containerd_labels` | `[]` | `key=value` labels attached to the node |
| `node_containerd_service` | `containerd` | Name of the containerd systemd unit |
| `node_containerd_socket` | `/run/containerd/containerd.sock` | containerd socket |
| `node_containerd_namespace` | `eru` | containerd namespace |
| `node_containerd_network` | `eru` | Name of the CNI network, which is what `--network` takes |
| `node_containerd_bridge` | `eru0` | Bridge the CNI conflist creates |
| `node_containerd_subnet` | `10.66.0.0/16` | Subnet `host-local` hands addresses out of |
| `node_containerd_cni_bin_dir` | `/opt/cni/bin` | Where the CNI plugin binaries go |
| `node_containerd_cni_conf_dir` | `/etc/cni/net.d` | Where the conflist goes |
| `node_containerd_agent_service` | `eru-agent` | Name of the agent systemd unit |
| `node_containerd_agent_api_addr` | `127.0.0.1:12345` | Agent HTTP API address |
| `node_containerd_heartbeat_interval` | `30` | Seconds between node heartbeats |
| `node_containerd_healthcheck_interval` | `30` | Seconds between workload health checks |
| `node_containerd_meta_dir` | `/run/eru/workloads` | Where the agent reads workload meta files |
| `node_containerd_state_dir` | `/var/lib/eru-agent` | Where the agent keeps its journal cursor |
| `node_containerd_journal_rate_limit_interval` | `30s` | journald `RateLimitIntervalSec` |
| `node_containerd_journal_rate_limit_burst` | `100000` | journald `RateLimitBurst` |

The subnet is per node and NATed, so containers reach the outside world but not each other across
nodes. Give each node its own subnet and route between them if you need that.

## node_process

| Variable | Default | Meaning |
| --- | --- | --- |
| `node_process_name` | the host's hostname | Node name registered with core, and the agent's `ERU_HOSTNAME` |
| `node_process_pod` | `{{ eru_process_pod }}` | Pod the node joins |
| `node_process_endpoint_host` | `{{ inventory_hostname }}` | Address core opens the SSH connection to |
| `node_process_ssh_port` | `22` | Port of that connection |
| `node_process_storage` | `""` | `--storage` at registration; empty lets the plugin take 80% of the disk |
| `node_process_labels` | `[]` | `key=value` labels attached to the node |
| `node_process_root` | `/var/lib/eru/process` | Where bundles are unpacked; must equal `core_process_root` |
| `node_process_agent_service` | `eru-agent` | Name of the agent systemd unit |
| `node_process_agent_api_addr` | `127.0.0.1:12345` | Agent HTTP API address |
| `node_process_heartbeat_interval` | `30` | Seconds between node heartbeats |
| `node_process_healthcheck_interval` | `30` | Seconds between workload health checks |
| `node_process_meta_dir` | `/run/eru/workloads` | Where the agent reads workload meta files |
| `node_process_state_dir` | `/var/lib/eru-agent` | Where the agent keeps its journal cursor |
| `node_process_journal_rate_limit_interval` | `30s` | journald `RateLimitIntervalSec` |
| `node_process_journal_rate_limit_burst` | `100000` | journald `RateLimitBurst` |

## Rendered core config

`roles/core/templates/core.yaml.j2` becomes `/etc/eru/core.yaml`. It sets the etcd machine list from
the `etcd` group, the `ssh` block pointing at the generated key pair, the `containerd` and `process`
blocks describing the node-side layout, the cpumem scheduler defaults (`maxshare: -1`,
`sharebase: 100`), and `resource_plugin.dir`.

Keys the playbook deliberately leaves out, and what to add if you need them:

- `auth` — core requires no credentials by default. Setting it means also setting
  `ERU_USERNAME`/`ERU_PASSWORD` for `eru-cli` and an `auth` block in `agent.yaml`.
- `git` — needed only to build images from a repository.
- `cocoon` — the VM engine, which quickstart does not deploy.
- `statsd`, `sentry_dsn`, `profile` — optional telemetry, off by default.

Two shapes are easy to get wrong when editing the template by hand. `bind` needs its colon
(`":5001"`, not `5001`), and `etcd.machines` is required whatever the store is. Core refuses to
start on either.

The full key reference is core's own
[configuration guide](https://projecteru2.github.io/core/configuration.html).

## Rendered plugin configs

`storage.yaml` and `gpu.yaml` sit next to their binaries in `/etc/eru/plugins`, which is where each
plugin looks for its config: core runs a plugin with that directory as its working directory, and
the default config path is relative. Both point at the same etcd cluster as core under their own key
prefix, so clearing core's `/eru` prefix cannot take the plugins' node records with it. The configs
are mode `0644` on purpose — core loads every *executable* file in the directory as a plugin.

## Rendered agent config

Each node role renders its own `/etc/eru/agent.yaml`. Both set `store: grpc` and point `core` at
`{{ core_host }}:{{ core_port }}`; they differ in the `runtimes` block, which is what decides how
the agent inspects workloads — `containerd` on a containerd node, `systemd` on a process node. There
is no `runtime:` key any more, and an agent with an empty `runtimes` block exits at startup.

The agent's node name comes from `ERU_HOSTNAME` in the systemd unit and must match the name the node
was registered under; both default to the host's hostname.

`metrics.transfers` and `log.forwards` are left unset, so the agent neither ships metrics to statsd
nor forwards workload logs anywhere. Add them to the template if you run those collectors.

The unit keeps upstream's `RestartKillSignal=SIGUSR1`, which lets the agent be restarted without
withdrawing its node from the cluster. Note that `systemctl restart` does not use that path — it
stops with `SIGTERM`, which does withdraw the node until the agent comes back.

## node_cocoon

| Variable | Default | Meaning |
| --- | --- | --- |
| `node_cocoon_pod` | `vm` (`eru_vm_pod`) | pod the node joins |
| `node_cocoon_binary` | `/usr/local/bin/cocoon` | the cocoon command core execs over ssh; a sudo wrapper works |
| `node_cocoon_socket` | `/var/lib/cocoon/run/cocoond.sock` | the daemon socket eru-agent watches |
| `node_cocoon_record_root` | `/var/lib/eru/cocoon` | durable workload records, must match `core_cocoon_record_root` |
| `node_cocoon_run_dir` | `/var/lib/cocoon/run` | cocoon run_dir (guest consoles), must match `core_cocoon_run_dir` |
| `node_cocoon_cgroup_parent` | `cocoon.slice` | slice VMs land in, must match `core_cocoon_cgroup_parent` |
