# Buildkite hosted agents

Buildkite hosted agents provides a fully-managed platform on which you can run your pipeline jobs, so that you don't have to manage Buildkite Agents in your own self-hosted environment.

With hosted agents, Buildkite handles infrastructure management tasks, such as provisioning, scaling, and maintaining the servers that run your agents.

## Why use Buildkite hosted agents

Buildkite hosted agents provides numerous benefits over similar hosted machine and runner features of other CI/CD providers.

The following cost benefits deliver enhanced value through accelerated build times, reduced operational overhead, and a lower total cost of ownership (TCO).

- **Superior performance**: Buildkite hosted agents delivers up to 3x faster performance compared to equivalent sized machines/runners from other CI/CD providers and cloud platforms, powered by dedicated quality hardware and a proprietary low-latency virtualization layer exclusive to Buildkite.

- **Pricing is calculated per second**: Charges apply only to the precise duration of command or script execution—excluding startup and shutdown periods, with no minimum charges and no rounding to the nearest minute.

- **Caching is included at no additional cost**: There are no supplementary charges for storage or cache usage. [Cache volumes](/docs/pipelines/hosted-agents/cache-volumes) operate on high-speed, local NVMe-attached disks, substantially accelerating caching and disk operations. This results in faster job completion, reduced minute consumption, and lower overall costs.

- **Transparent Git mirroring**: This significantly accelerates git clone operations by caching repositories locally on the agent at startup—particularly beneficial for large repositories and monorepos.

- **Transparent remote Docker builders at no additional cost**: Offloading Docker build commands to [dedicated, pre-configured machines](/docs/pipelines/hosted-agents/remote-docker-builders) equipped with Docker layer caching and additional performance optimizations. This feature is available to [Enterprise](https://buildkite.com/pricing/) plan customers only.

- **An internal container registry**: Speed up your pipeline build times by managing your jobs' container images through your [internal container registry](/docs/pipelines/hosted-agents/internal-container-registries), which provides deterministic storage for Open Container Initiative (OCI) images.

- **Consistently rapid queue times**: Job are dispatched to hosted agents within a matter of seconds, providing consistently low queue times.

## How Buildkite hosted agents work

When a pipeline's job is scheduled on a [Buildkite hosted queue](/docs/pipelines/clusters/manage-queues#create-a-buildkite-hosted-queue), this action begins the process to start the job's execution on a new [ephemeral agent](/docs/pipelines/glossary#ephemeral-agent).

The hosted queue's ephemeral agent begins its lifecycle with the initiation of a virtualized environment.

- For Linux hosted agents, this environment includes a base image for containerization, which is the cluster's default or one that you've configured to use in your pipeline, to which custom layers, such as the Buildkite Agent, and Buildkite-specific configurations, are added.

- For macOS hosted agents, this environment is a virtual machine, based on a specific version macOS and suite of relevant software, running on dedicated Mac machines.

As part of this initiation process, any configured cache volumes are attached, and then the entire virtualized environment is started. This process can take a few seconds to complete, and depends on the base image you're using.

The Buildkite Agent in this virtualized environment then acquires the job and proceeds to run the job through to its completion. Once the job is completed, regardless of its exit status, the virtualized environment and all of its associated data, including data it generated during job execution, is removed and destroyed. Any cache volume data, however, is persisted.

> 📘 Cluster isolation
> Every Buildkite hosted agent is configured within a [Buildkite cluster](/docs/pipelines/clusters), which benefits from hypervisor-level isolation, ensuring robust separation between each instance. Each cluster also has Cache volumes, remote Docker builder and internal container registries are isolated per cluster. As well as Buildkite secrets.

Due to the nature of Buildkite hosted agents' ephemeral environments, these are the benefits you get. (Sum up the following into no more than 1-2 paragraphs.)

- **Clean state guarantee**: Each build starts from a known, clean baseline without accumulated artifacts, cached credentials, or residual data from previous builds that could introduce vulnerabilities or cross-contamination between projects.

- **Dependency consistency**: Fresh container instances ensure that dependencies are pulled cleanly each time, preventing supply chain attacks that might involve compromised cached packages or modified dependencies in long-lived environments.

- **Reduced attack surface**: Short-lived containers minimize the window of opportunity for attackers to compromise the build environment, establish persistence, or exploit vulnerabilities that might be discovered over time.

- **Immutable infrastructure**: Ephemeral containers prevent unauthorized modifications to the build environment since any changes are discarded after each build, making it impossible for malicious actors to install backdoors or persistent malware.

- **Credential isolation**: Temporary containers naturally limit credential exposure, since secrets are only present during the build process and are automatically destroyed afterward, reducing the risk of credential theft or misuse.

## Getting started with Buildkite hosted agents

Buildkite offers both [Linux](/docs/pipelines/hosted-agents/linux) and [macOS](/docs/pipelines/hosted-agents/macos) hosted agents, whose respective pages explain how to start setting them up.

Buildkite hosted agent services support both public and private repositories. Learn more about setting up code access in [Hosted agent code access](/docs/pipelines/hosted-agents/code-access).

If you need to migrate your existing Buildkite pipelines from using Buildkite Agents in a [self-hosted architecture](/docs/pipelines/architecture#self-hosted-hybrid-architecture) to those using Buildkite hosted agents, see [Hosted agent pipeline migration](/docs/pipelines/hosted-agents/pipeline-migration) for details.

When a Buildkite hosted agent machine is running (during a pipeline build) you can access the machine through a terminal. Learn more about this feature in [Hosted agents terminal access](/docs/pipelines/hosted-agents/terminal-access).
