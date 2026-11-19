# Resource controls

A self-hosted [Buildkite agent](/docs/agent) runs each job as ordinary processes on the machine, container, or Kubernetes pod where you run the agent. The agent doesn't limit the CPU, memory, disk space, or workspace size that those jobs use. You set these limits in the layer that runs the agent, such as the operating system, a container runtime, Kubernetes, or your cloud infrastructure. Machine resources for self-hosted agents aren't configured in the Buildkite interface.

This page explains which controls Buildkite Pipelines and the agent provide, and how to apply CPU, memory, and disk limits on Linux hosts, in containers, and on Kubernetes.

## Who controls each resource

Buildkite Pipelines controls when and where jobs run, and the agent controls how many jobs run on a host. Your infrastructure controls the resources those jobs can use:

Control | Where to configure it | How
------- | --------------------- | ---
How long a job can run | Buildkite Pipelines | [Command step timeouts](/docs/pipelines/configure/build-timeouts), set on steps or as pipeline and organization defaults
How many jobs from related steps run at once | Buildkite Pipelines | [Concurrency limits and groups](/docs/pipelines/configure/workflows/controlling-concurrency)
Which machines run a job | Buildkite Pipelines and agent configuration | [Queues](/docs/agent/queues) and [agent targeting](/docs/pipelines/configure/defining-steps#targeting-specific-agents)
How many jobs run at once on a host | Agent configuration | [`spawn`](/docs/agent/self-hosted/configure#spawn) or [`spawn-per-cpu`](/docs/agent/self-hosted/configure#spawn-per-cpu)
Where checkouts are stored and how they're cleaned | Agent configuration | [`build-path`](/docs/agent/self-hosted/configure#build-path), [`git-clean-flags`](/docs/agent/self-hosted/configure#git-clean-flags), and [clean checkouts](/docs/agent/self-hosted/security#force-clean-checkouts)
CPU, memory, and process limits | Your operating system or container platform | [systemd](#limit-cpu-and-memory-with-systemd), [Docker](#containers-and-kubernetes-docker), or [Kubernetes](#containers-and-kubernetes-kubernetes) resource limits
Disk space and workspace size | Your infrastructure | [Filesystem sizing, free-space checks, cleanup, and monitoring](#limit-disk-usage)
{: class="responsive-table"}

[Buildkite-hosted agents](/docs/agent/buildkite-hosted) work differently. When you [create a Buildkite-hosted queue](/docs/agent/queues/managing#create-a-buildkite-hosted-queue), you choose the instance shape, and Buildkite manages the machine.

## How the agent and its jobs share limits

The `buildkite-agent start` process starts a `buildkite-agent bootstrap` child process for each job it runs. The bootstrap process then runs the job's hooks, plugins, and command as its own children:

```text
buildkite-agent start            # one process for all workers started by spawn
├── buildkite-agent bootstrap    # one for each running job
│   └── hooks, plugins, and the job command
└── buildkite-agent bootstrap
    └── hooks, plugins, and the job command
```

Because jobs are child processes of the agent, limits set on the agent's service affect its jobs in the following ways:

- **Control group limits are shared:** Linux control group (cgroup) limits, such as the systemd `CPUQuota`, `MemoryMax`, and `TasksMax` settings, apply to the agent process and all its jobs combined. All workers started by one agent service share one allowance, so a single job can use all of it.
- **Per-process limits apply to each job:** Resource limits that the operating system applies per process, such as the maximum number of open files (`LimitNOFILE` in systemd or `ulimit -n`), are inherited by each job process.
- **Containers started through Docker aren't covered:** The Docker daemon creates containers in its own cgroups, so limits on the agent service don't apply to containers that jobs start. Set limits on the containers instead. Learn more in [Docker](#containers-and-kubernetes-docker).

## Limit concurrent jobs on a host

Each agent worker runs one job at a time, so the number of workers sets how many jobs can run at once on a host. Set the number of workers with the [`spawn`](/docs/agent/self-hosted/configure#spawn) setting:

```ini
spawn=4
```
{: codeblock-file="buildkite-agent.cfg"}

Choose a number of workers that fits the host's CPU, memory, and disk space when every worker runs your most demanding regular job at the same time.

The [`spawn-per-cpu`](/docs/agent/self-hosted/configure#spawn-per-cpu) setting starts a number of workers for each CPU that the agent process can run on. A CPU quota, such as the systemd `CPUQuota` setting, doesn't reduce this count. Restricting the agent to specific CPUs, such as with the systemd `AllowedCPUs` setting, does.

To limit how many jobs use a shared resource across all your agents, such as a deployment target or a test database, use [concurrency limits and groups](/docs/pipelines/configure/workflows/controlling-concurrency) instead.

## Limit CPU and memory with systemd

The agent packages for Debian, Ubuntu, and Red Hat-based systems run the agent as the `buildkite-agent` systemd service. To limit the resources that the agent and its jobs use, add resource control settings to a [drop-in file](/docs/agent/self-hosted/install/ubuntu#systemd-modifications):

```conf
[Service]
# Limits for the agent and all of its jobs, combined
CPUQuota=600%
MemoryMax=12G
MemorySwapMax=0
TasksMax=4096
# Keep the agent service running when the OOM killer stops one of its processes
OOMPolicy=continue
# Per-process limit, inherited by each job process
LimitNOFILE=65536
```
{: codeblock-file="/etc/systemd/system/buildkite-agent.service.d/resource-limits.conf"}

Reload the systemd configuration and restart the agent to apply the change:

```bash
sudo systemctl daemon-reload
sudo systemctl restart buildkite-agent
```

To check the limits that systemd applied, run:

```bash
systemctl show buildkite-agent \
  -p CPUQuotaPerSecUSec -p MemoryMax -p MemorySwapMax \
  -p TasksMax -p OOMPolicy -p LimitNOFILE
```

These settings work as follows:

- `CPUQuota`: Sets the total CPU time available to the agent and its jobs, where `100%` is one CPU. Jobs that reach the quota are slowed down, not stopped.
- `MemoryMax`: Sets the total memory available to the agent and its jobs. When they reach the limit, the Linux out-of-memory (OOM) killer stops a process in the service, usually the process using the most memory. Because all jobs share this limit, that process can belong to any running job, or be the agent itself. A job whose process is stopped fails with exit status `137`, and its log shows `Killed`. To confirm the cause, check `journalctl -u buildkite-agent` for `A process of this unit has been killed by the OOM killer`.
- `MemorySwapMax`: Limits swap usage. On hosts with swap enabled, jobs can use swap to go beyond `MemoryMax` unless you set this to `0`.
- `TasksMax`: Sets the maximum number of processes and threads across the agent and its jobs.
- `OOMPolicy`: Controls what systemd does with the rest of the service after the OOM killer stops one of its processes. Use `continue` so that systemd doesn't stop the agent and its other jobs. This setting doesn't choose which process is stopped. To keep jobs from affecting each other, [set limits for each agent](#limit-cpu-and-memory-with-systemd-set-limits-for-each-agent).
- `LimitNOFILE`: Sets the maximum number of open files for each process, including each job process.

> 🚧 One job that runs out of memory can stop every worker on the host
> By default, systemd stops a service when any of its processes is killed for running out of memory. Without `OOMPolicy=continue`, one OOM kill after the agent and its jobs reach `MemoryMax` stops the whole `buildkite-agent` service. The agent then stops gracefully: every worker stops accepting jobs and waits for its running job to finish before the agent exits. After that, systemd restarts the service, but the host doesn't accept new jobs until the longest-running job finishes.

The `MemorySwapMax` and `AllowedCPUs` settings require the unified cgroup hierarchy (cgroup v2), which is the default on current Debian, Ubuntu, and Red Hat Enterprise Linux releases. On cgroup v1, systemd applies `MemoryMax` as the legacy memory limit but doesn't apply `MemorySwapMax`, so jobs can still use swap. For all available settings, see the [systemd.resource-control](https://www.freedesktop.org/software/systemd/man/latest/systemd.resource-control.html) documentation.

### Set limits for each agent

Limits on the `buildkite-agent` service are shared by all of its workers. To give each agent its own limits, run each agent as a separate instance of the `buildkite-agent@.service` template unit, which the Debian, Ubuntu, and Red Hat packages also install. Each instance runs in its own cgroup.

Create a drop-in file for the template unit. The following example starts one worker in each instance, and gives each instance two CPUs and 4 GiB of memory:

```conf
[Service]
Environment=BUILDKITE_AGENT_SPAWN=1
Environment=BUILDKITE_AGENT_SPAWN_PER_CPU=0
CPUQuota=200%
MemoryMax=4G
MemorySwapMax=0
OOMPolicy=continue
```
{: codeblock-file="/etc/systemd/system/buildkite-agent@.service.d/resource-limits.conf"}

All instances read the same agent configuration file. The `BUILDKITE_AGENT_SPAWN` and `BUILDKITE_AGENT_SPAWN_PER_CPU` environment variables take precedence over the `spawn` and `spawn-per-cpu` settings in that file. Set both, because a `spawn-per-cpu` value above `0` replaces `spawn` and would start several workers in each instance.

Then replace the `buildkite-agent` service with the number of instances you need. For example, to run three agents:

```bash
sudo systemctl daemon-reload
sudo systemctl disable --now buildkite-agent
sudo systemctl enable --now \
  buildkite-agent@1 buildkite-agent@2 buildkite-agent@3
```

Each instance names its agent after the host and the instance, for example, `my-host-1`. To set different limits for one instance, add a drop-in file for that instance, such as `/etc/systemd/system/buildkite-agent@1.service.d/resource-limits.conf`.

### Other operating systems

The agent doesn't provide its own CPU or memory limits on macOS, Windows, or Linux systems without systemd. On these systems, run each agent on a machine, virtual machine, or container sized for its jobs, or use the process controls your platform provides.

## Limit disk usage

The agent checks out each pipeline into a directory under the [build path](/docs/agent/self-hosted/configure#build-path), named after the agent, the Buildkite organization, and the pipeline (`<build-path>/<agent-name>/<organization-slug>/<pipeline-slug>`). The agent reuses that directory for later jobs of the same pipeline on the same agent, but doesn't delete checkouts after jobs finish or limit their size.

Before each checkout, the agent removes untracked and ignored files from the directory using the [`git-clean-flags`](/docs/agent/self-hosted/configure#git-clean-flags) setting. This only happens the next time that agent runs a job for that pipeline. Disk usage therefore grows with the number of agents on the host, the number of pipelines they build, and the files that jobs leave behind. [Git mirrors](/docs/agent/self-hosted/configure/git-mirrors), plugins, Docker images, and Docker build cache use additional disk space outside the checkouts.

### Use a dedicated filesystem for builds

Put the build path on its own filesystem or volume, sized for the agents on the host. When a job fills that filesystem, its writes fail with `No space left on device` and the job fails, but the root filesystem and other services on the host keep working. Consider separate volumes for the [`git-mirrors-path`](/docs/agent/self-hosted/configure#git-mirrors-path) and the Docker data directory too.

Set the build path in the agent configuration file:

```ini
build-path="/mnt/buildkite-builds"
```
{: codeblock-file="buildkite-agent.cfg"}

If the agent runs as a systemd service, make the service wait for the filesystem to be mounted:

```conf
[Unit]
RequiresMountsFor=/mnt/buildkite-builds
```
{: codeblock-file="/etc/systemd/system/buildkite-agent.service.d/build-path.conf"}

To limit the workspace size for each agent, [run each agent as a separate service instance](#limit-cpu-and-memory-with-systemd-set-limits-for-each-agent) and give each instance its own filesystem. For example, for the first instance:

```conf
[Unit]
RequiresMountsFor=/mnt/buildkite-builds-1

[Service]
Environment=BUILDKITE_BUILD_PATH=/mnt/buildkite-builds-1
```
{: codeblock-file="/etc/systemd/system/buildkite-agent@1.service.d/build-path.conf"}

Filesystem quotas are another option if your filesystem supports them.

### Check free space before jobs start

An agent [`environment` hook](/docs/agent/hooks#job-lifecycle-hooks) runs before the checkout. The following hook fails the job with a clear message when the build path filesystem has less than 10 GiB free, instead of letting the job fail partway through:

```bash
#!/bin/bash
set -euo pipefail

# Minimum free space on the build path filesystem, in kilobytes (10 GiB)
min_free_kb=$((10 * 1024 * 1024))

# Use the nearest existing directory if the build path doesn't exist yet
dir="$BUILDKITE_BUILD_PATH"
while [[ ! -d "$dir" ]]; do dir=$(dirname "$dir"); done

free_kb=$(df -Pk "$dir" | awk 'NR==2 {print $4}')

if (( free_kb < min_free_kb )); then
  echo "^^^ +++"
  echo "Only $((free_kb / 1024)) MiB free in ${BUILDKITE_BUILD_PATH}." >&2
  echo "Not starting the job." >&2
  exit 1
fi
```
{: codeblock-file="/etc/buildkite-agent/hooks/environment"}

Pair a free-space check with cleanup. Without cleanup, the check can keep failing jobs on the host, because the job fails before the checkout step that would remove leftover files.

### Clean up after jobs

The following agent [`pre-exit` hook](/docs/agent/hooks#job-lifecycle-hooks) runs the same `git clean` commands that the agent runs in the checkout and its submodules before the next checkout, but runs them as soon as the job finishes. This frees disk space sooner without changing which files are kept between jobs:

```bash
#!/bin/bash
set -euo pipefail

# Remove untracked and ignored files from the checkout when the job finishes
checkout="${BUILDKITE_BUILD_CHECKOUT_PATH:-}"
clean_flags="${BUILDKITE_GIT_CLEAN_FLAGS:--ffxdq}"
if [[ -d "$checkout/.git" ]]; then
  # Clean submodules too, as the agent does before each checkout
  git -C "$checkout" submodule foreach --recursive "git clean $clean_flags"
  # xargs splits the flags like the agent does, including quoted values
  printf '%s' "$clean_flags" | xargs git -C "$checkout" clean
fi
```
{: codeblock-file="/etc/buildkite-agent/hooks/pre-exit"}

The `pre-exit` hook also runs when an earlier hook fails, such as the free-space check, but it might not run or finish for canceled or timed-out jobs. Learn more in [Signal handling](/docs/agent/lifecycle#signal-handling).

Other ways to reclaim disk space include:

- **Clean checkouts:** Set `BUILDKITE_CLEAN_CHECKOUT` on a step to remove the whole checkout directory before the checkout. The next job then clones the repository again. Learn more in [Force clean checkouts](/docs/agent/self-hosted/security#force-clean-checkouts).
- **Docker cleanup:** Docker images and build cache aren't stored in the build path. Remove them on a schedule, for example, with `docker image prune` and `docker builder prune` in a cron job or systemd timer.
- **Ephemeral agents:** Start the agent with [`disconnect-after-job`](/docs/agent/self-hosted/configure#disconnect-after-job) and replace the machine or container after each job, so every job starts with empty disks.

### Monitor disk usage

The agent doesn't report a host's CPU, memory, or disk usage to Buildkite Pipelines. Monitor the build path filesystem with your existing host monitoring tools, and alert before it fills. For agent metrics, such as running jobs and workers, see [Monitoring and observability](/docs/agent/self-hosted/monitoring-and-observability).

## Containers and Kubernetes

Container platforms provide their own resource limits. Where jobs run in containers, set the limits on those containers.

### Docker

Containers that a job starts through the Docker daemon, including containers started by the [Docker](https://buildkite.com/resources/plugins/buildkite-plugins/docker-buildkite-plugin/) and [Docker Compose](https://buildkite.com/resources/plugins/buildkite-plugins/docker-compose-buildkite-plugin/) plugins, aren't limited by systemd settings on the agent service. Set limits on each container, for example, using the `--cpus` and `--memory` options of `docker run`, or the `cpus` and `memory` options of the Docker plugin:

```yaml
steps:
  - label: "Tests"
    command: "npm test"
    plugins:
      - docker#v5.14.0:
          image: "node:24"
          cpus: "2"
          memory: "4g"
```

A container that exceeds its memory limit is stopped, and the job fails with exit status `137`. Learn more about container limits in the Docker [resource constraints](https://docs.docker.com/engine/containers/resource_constraints/) documentation.

If you [run the agent in a Docker container](/docs/agent/self-hosted/install/docker), limits on the agent container apply to the agent and the jobs running inside it. These limits don't apply to containers that jobs start through a Docker socket mounted from the host.

### Kubernetes

The [Agent Stack for Kubernetes](/docs/agent/self-hosted/agent-stack-k8s) runs each job in its own Kubernetes pod:

- Set CPU and memory requests and limits for job containers using resource classes or PodSpec patches. Learn more in [Container resources](/docs/agent/self-hosted/agent-stack-k8s/container-resource-limits).
- Limit how many jobs the controller runs at once with the [`max-in-flight`](/docs/agent/self-hosted/agent-stack-k8s/controller-configuration) controller setting.
- Limit disk usage with Kubernetes [local ephemeral storage](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#local-ephemeral-storage) requests and limits.

### Elastic CI Stack

The Elastic CI Stack for AWS and the Elastic CI Stack for GCP size agent resources through their stack configuration:

- **Elastic CI Stack for AWS:** The [`InstanceTypes`](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/configuration-parameters#InstanceTypes) and [`AgentsPerInstance`](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/configuration-parameters#AgentsPerInstance) parameters set the resources and the number of workers on each instance, and [`RootVolumeSize`](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/configuration-parameters#RootVolumeSize) sets the disk size. The stack checks free disk space before each job and prunes Docker resources when space is low. The [`BuildkitePurgeBuildsOnDiskFull`](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/configuration-parameters#BuildkitePurgeBuildsOnDiskFull) and [`BuildkiteTerminateInstanceOnDiskFull`](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/configuration-parameters#BuildkiteTerminateInstanceOnDiskFull) parameters control what happens when disk space is still low after pruning.
- **Elastic CI Stack for GCP:** The `machine_type` and `root_disk_size_gb` variables set the resources and disk size of each instance. Learn more in [Configuration parameters](/docs/agent/self-hosted/gcp/elastic-ci-stack/configuration-parameters).
