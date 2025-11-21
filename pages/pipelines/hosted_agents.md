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

Buildkite hosted agents' execution model for pipeline jobs, reduces job flakiness through the following mechanisms.

- Each job runs on an [ephemeral agent](/docs/pipelines/glossary#ephemeral-agent) which begins with a clean environment.

- **Clean state guarantee**: Each build starts from a known, clean baseline without accumulated artifacts, cached credentials, or residual data from previous builds that could introduce vulnerabilities or cross-contamination between projects.

- **Dependency consistency**: Fresh container instances ensure that dependencies are pulled cleanly each time, preventing supply chain attacks that might involve compromised cached packages or modified dependencies in long-lived environments.

Buildkite hosted agents' pipeline execution model is also designed with security in mind.

- **Reduced attack surface**: Short-lived containers minimize the window of opportunity for attackers to compromise the build environment, establish persistence, or exploit vulnerabilities that might be discovered over time.

- **Immutable infrastructure**: Ephemeral containers prevent unauthorized modifications to the build environment since any changes are discarded after each build, making it impossible for malicious actors to install backdoors or persistent malware.

- **Credential isolation**: Temporary containers naturally limit credential exposure, since secrets are only present during the build process and are automatically destroyed afterward, reducing the risk of credential theft or misuse.

- **Cluster isolation**: Every Buildkite hosted agent is configured within a [Buildkite cluster](/docs/pipelines/clusters), which benefits from hypervisor-level isolation, ensuring robust separation between each instance.

- **Audit trail clarity**: Ephemeral builds create clearer audit trails, since each build is both isolated and reproducible, making it easier to identify the source of any security issues or compliance violations.

## Getting started with Buildkite hosted agents

Buildkite offers both [Linux](/docs/pipelines/hosted-agents/linux) and [macOS](/docs/pipelines/hosted-agents/macos) hosted agents, whose respective pages explain how to start setting them up.

Buildkite hosted agent services support both public and private repositories. Learn more about setting up code access in [Hosted agent code access](/docs/pipelines/hosted-agents/code-access).

If you need to migrate your existing Buildkite pipelines from using Buildkite Agents in a [self-hosted architecture](/docs/pipelines/architecture#self-hosted-hybrid-architecture) to those using Buildkite hosted agents, see [Hosted agent pipeline migration](/docs/pipelines/hosted-agents/pipeline-migration) for details.

When a Buildkite hosted agent machine is running (during a pipeline build) you can access the machine through a terminal. Learn more about this feature in [Hosted agents terminal access](/docs/pipelines/hosted-agents/terminal-access).
