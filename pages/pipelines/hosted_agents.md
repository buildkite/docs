# Buildkite hosted agents

Buildkite hosted agents provides a fully-managed platform on which you can run your pipeline jobs, so that you don't have to manage [Buildkite Agents](/docs/agent/v3) in your own self-hosted environment.

With hosted agents, Buildkite handles infrastructure management tasks, such as provisioning, scaling, and maintaining the servers that run your agents.

## Why use Buildkite hosted agents

Buildkite hosted agents provides numerous benefits over similar hosted machine and runner features of other CI/CD providers.

The following cost benefits deliver enhanced value through accelerated build times, reduced operational overhead, and a lower total cost of ownership (TCO).

- **Superior performance**: Buildkite hosted agents uses the latest generation Mac and AMD Zen-based hardware, which deliver up to 3x faster performance compared to equivalent sized machines/runners from other CI/CD providers and cloud platforms, powered by dedicated quality hardware and a proprietary low-latency virtualization layer exclusive to Buildkite. The hosted agents also dynamically autoscale to operate concurrently to meet high demand.

- **Ephemeral, isolated environments that scale**: Hosted agents are provisioned on demand and destroyed after each job, providing clean, reproducible builds that dynamically scale and operate concurrently to meet high demand.

- **Pricing is calculated per second**: Charges apply only to the precise duration of command or script execution—excluding startup and shutdown periods, with no minimum charges and no rounding to the nearest minute.

- **Caching is included at no additional cost**: There are no supplementary charges for storage or cache usage. [Cache volumes](/docs/pipelines/hosted-agents/cache-volumes) operate on high-speed, local NVMe-attached disks, substantially accelerating caching and disk operations. This results in faster job completion, reduced minute consumption, and lower overall costs.

- **Transparent Git mirroring**: This significantly accelerates git clone operations by caching repositories locally on the agent at startup—particularly beneficial for large repositories and monorepos.

- **Transparent remote Docker builders at no additional cost**: Offloading Docker build commands to [dedicated, pre-configured machines](/docs/pipelines/hosted-agents/remote-docker-builders) equipped with Docker layer caching and additional performance optimizations. This feature operates without any additional configuration, and is available to [Enterprise](https://buildkite.com/pricing/) plan customers only.

- **An internal container registry**: Speed up your pipeline build times by managing your jobs' container images through your [internal container registry](/docs/pipelines/hosted-agents/internal-container-registry), which provides deterministic storage for Open Container Initiative (OCI) images.

- **Consistently rapid queue times**: Job are dispatched to hosted agents within a matter of seconds, providing consistently low queue times.

Buildkite hosted agents also provides the following assurances:

- The platform:

    * Runs in a private cloud, which is purpose built and optimized for CI/CD workloads.
    * Is exclusively hosted in US East Coast data centers, operated by a trusted infrastructure provider, strategically selected to provide optimal performance, reliability and low-latency connectivity to major cloud regions.

- Buildkite manages and runs hosted agents to ensure consistency under load for all customers.

## How Buildkite hosted agents work

When a pipeline's job is scheduled on a [Buildkite hosted queue](/docs/pipelines/clusters/manage-queues#create-a-buildkite-hosted-queue), this action begins the process of starting the job's execution on a new [ephemeral agent](/docs/pipelines/glossary#ephemeral-agent).

The hosted queue's ephemeral agent begins its lifecycle with the initiation of a virtualized environment.

- For [Linux hosted agents](/docs/pipelines/hosted-agents/linux), this environment includes a base image for containerization, which is either the hosted queue's [configured agent image](/docs/pipelines/hosted-agents/linux#agent-images), or one that you've configured to use in your pipeline, to which custom layers are added, including the Buildkite Agent, and Buildkite-specific configurations.

- For [macOS hosted agents](/docs/pipelines/hosted-agents/macos), this environment is a virtual machine, based on the macOS and Xcode version configured in your queue settings, running on dedicated Mac hardware.

As part of this initiation process, any configured [cache volumes](/docs/pipelines/hosted-agents/cache-volumes) are attached, and then the entire virtualized environment is started. This process can take a few seconds to complete (appearing as job wait time), and varies depending on the size and recency of the cache volumes and the base image being used.

Once started, the Buildkite Agent running in the virtualized environment acquires the job and proceeds to run the job through to its completion. Once the job is complete, regardless of its exit status, the virtualized environment and all of its associated data, including data it generated during job execution, is removed and destroyed. Any cache volume data, however, is persisted.

> 📘 Cluster isolation
> Every Buildkite hosted queue and its agents are configured within a [Buildkite cluster](/docs/pipelines/clusters), which benefits from hypervisor-level isolation, ensuring robust separation between each instance. Each cluster also has its own [cache volumes](/docs/pipelines/hosted-agents/cache-volumes), [remote Docker builders](/docs/pipelines/hosted-agents/remote-docker-builders) and [internal container registry](/docs/pipelines/hosted-agents/internal-container-registry), as well as [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets), which are not available to any other cluster.

The ephemeral nature of Buildkite hosted agents' virtualized environments also offer the following benefits:

- Each Buildkite hosted agent begins with a clean state, with no residual data from previous builds that could introduce vulnerabilities or cross-contamination between projects. Job dependencies are also pulled cleanly each time.

- Short-lived hosted agents mitigate the window of opportunity for attackers to compromise the build environment, and any data generated or used during job execution, such as secrets or credentials, are destroyed after job completion or failure.

## Getting started with Buildkite hosted agents

Buildkite offers both [Linux](/docs/pipelines/hosted-agents/linux) and [macOS](/docs/pipelines/hosted-agents/macos) hosted agents, whose respective pages explain how to start setting them up.

Buildkite hosted agent services support both public and private repositories. Learn more about setting up code access in [Hosted agent code access](/docs/pipelines/hosted-agents/code-access).

If you need to migrate your existing Buildkite pipelines from using Buildkite Agents in a [self-hosted architecture](/docs/pipelines/architecture#self-hosted-hybrid-architecture) to those using Buildkite hosted agents, see [Hosted agent pipeline migration](/docs/pipelines/hosted-agents/pipeline-migration) for details.

When a Buildkite hosted agent machine is running (during a pipeline build) you can access the machine through a terminal. Learn more about this feature in [Hosted agents terminal access](/docs/pipelines/hosted-agents/terminal-access).

## Buildkite Agent version updates

As part of the hosted agents service, Buildkite aims to keep [Buildkite Agents](/docs/agent/v3) in your hosted agents up to date and to the latest version.

If you find that your hosted agent queues are not on the latest version of the Buildkite Agent, contact Buildkite support at support@buildkite.com and we'd be happy to get them updated for you.
