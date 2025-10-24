# Agent management

This page covers the best practices for effective management of [Buildkite Agents](/docs/agent/v3). The way you configure and set up your agents and [clusters](/docs/pipelines/clusters) can have a huge impact on the security and reliability of your overall systems. The following sub-section cover the suggested approach.

## Use different stacks

different infra stacks - when are VMs good (longer running, a lot installed in machine, when you buy big machines & bin pack a lot of agents in that its cheaper, you can do spot instances)

### Use different stacks

Choose the infrastructure stack that matches your workload shape, cost goals, and operational model. Buildkite Agents run well across VMs, container schedulers, and serverless runners, but the trade-offs differ.

### Virtual machines (VMs)

Best for:

- Long‑running agents that need lots of preinstalled tools and SDKs
- Heavy caching on disk, large ephemeral storage, or GPU/TPU access
- Cost efficiency from “bin packing” many agents per large VM
- Stable capacity with predictable performance

Pros:

- Strong isolation and steady performance for noisy jobs
- Warm, preprovisioned images reduce job startup time
- Easy to attach large disks for caches and build artifacts
- Works well with spot/preemptible instances for savings

Cons:

- Slower to scale from zero compared to containers
- More golden image management drift to handle
- Bin packing requires tuning CPU/RAM oversubscription and agent queues

Tips:

- Use bigger instances and run multiple agents per VM to improve $/build
- Enable spot instances where interruption-tolerant, and configure graceful termination hooks
- Bake images with toolchains to minimize per‑job setup time
- Separate queues for heavyweight vs lightweight jobs to avoid head‑of‑line blocking

### Containers on a scheduler (e.g., Kubernetes, ECS, Nomad)

Best for:

- Ephemeral agents per job for strong isolation and reproducibility
- Rapid, elastic scaling of job throughput
- Teams who already standardize on container build pipelines

Pros:

- Fast spin-up and fine-grained auto‑scaling
- Clean environments per build reduce flakiness
- Native primitives for resource requests/limits and scheduling
- Easier multi‑tenant isolation via namespaces and policies

Cons:

- Containerizing complex toolchains can be upfront work
- Disk‑heavy or GPU workloads need extra node and storage setup
- Cold starts can impact short jobs if images are large

Tips:

- Keep agent images slim, layer heavy toolchains via on‑demand init or shared cache volumes
- Pin queues to node pools with the right resources (e.g., GPU nodes)
- Pre‑pull frequently used images and use a local registry cache
- Use PodDisruptionBudgets and graceful shutdown to avoid mid‑job eviction

### Serverless or on‑demand runners

Best for:

- Spiky, bursty workloads with idle periods
- Minimal ops overhead and pay‑per‑use economics
- Strict isolation requirements per build

Pros:

- Near‑zero capacity planning
- Strong isolation by default
- Simple operational model

Cons:

- Higher unit cost for always‑on workloads
- Startup latency can affect short jobs
- Limited access to privileged features, large local disks, or GPUs

Tips:

- Reserve for sporadic queues or overflow
- Cache dependencies in remote stores to offset cold starts
- Split fast vs slow jobs into separate queues to manage latency

### When VMs are a great fit

- Agents run continuously with high utilization
- You “buy big” machines and pack many agents for lower unit cost
- Toolchains are bulky, licensed, or tricky to containerize
- You need large persistent caches or dedicated hardware
- You can tolerate and manage spot interruptions for further savings

### Choosing the right stack

- Optimize for stability and cost: favor VMs with bin‑packed agents
- Optimize for elasticity and isolation: favor containers with one ephemeral agent per job
- Optimize for simplicity and burst handling: use serverless/on‑demand runners
- Many teams blend stacks: baseline on VMs, burst with containers/serverless, and reserve specialty nodes for GPU or storage‑heavy work

### Operational guardrails

- Use separate queues per workload class and resource profile
- Define clear SLOs: startup time, throughput, and cost per build
- Standardize images and hooks to keep environments consistent
- Track interruption rates and retry costs when using spot capacity
- Monitor utilization to tune bin packing vs parallelism for best $/build

### Agent Stack for Kubernetes

pros: ephemeral so less clean up issues, faster spin up time. cons: need to think about caching since there is no shared infrastructure.

Run Buildkite Agents as ephemeral pods for strong isolation and rapid scaling. Each job gets a clean environment, so drift and cleanup are minimal. Plan for image size, cache strategy, and graceful shutdowns to prevent pod churn from hurting throughput.

### Pros

- Ephemeral agents mean fewer cleanup issues and less environment drift between builds
- Fast spin-up time with autoscaling and pre-pulled images
- Fine‑grained isolation. One agent per pod reduces cross‑job interference
- Native scheduling controls with requests/limits, node selectors, and taints/tolerations

### Cons

- Caching is harder without shared local disks
- Large images and cold pulls can dominate short jobs
- Disk‑heavy or GPU workloads require specialized node pools and storage classes
- Pod evictions and node rollouts can interrupt work if not configured carefully

### Deployment patterns

- One agent per pod for isolation
- Separate queues per workload class, and map queues to node pools via labels
- Use a small base agent image plus job‑specific tool layers to keep cold starts low
- Pre‑pull common images on nodes with DaemonSets or image cache warmers
- Configure graceful termination so in‑flight jobs can finish on SIGTERM

### Caching strategies

- Remote caches for portability
    - Package and dependency caches in S3, GCS, or Artifactory
    - Container layer caches in a nearby registry with pull‑through caching
    - Language‑native caches stored remotely per lockfile or checksum key
- On‑cluster caches
    - Read‑only cache images: bake popular deps into a sidecar or a dedicated layer
    - Ephemeral volumes (emptyDir) for intra‑job reuse only
    - Node‑scoped caches using hostPath or local PVs to reuse across pods on the same node
- Keys and invalidation
    - Use content‑based keys: lockfiles, toolchain versions, and OS image digest
    - Split hot caches per major runtime to avoid thrash
    - TTL caches for CI‑only artifacts to limit bloat

### Scheduling and scaling

- Resource sizing
    - Set requests to typical use and limits to safe peaks to improve bin packing
    - Reserve IOPS and ephemeral storage for build phases that stream artifacts
- Node pools
    - General pool for CPU‑bound jobs
    - High‑IO or large‑disk pool for build/test with heavy caching
    - GPU pool for ML workloads, using queue tags and node selectors
- Autoscaling
    - Cluster autoscaler for nodes, workload autoscaler for agent replicas
    - Pre‑scale before known peaks or long queues to avoid cold‑start cascades

### Reliability and interruptions

- PodDisruptionBudgets to keep enough agents available during rollouts
- PriorityClasses to ensure critical queues schedule first
- Graceful shutdown
    - Increase terminationGracePeriodSeconds so agents can finish or checkpoint work
    - PreStop hook to signal agent to stop accepting new jobs
- Image pull robustness
    - Use imagePullPolicy=IfNotPresent with digest pins
    - Private registry mirrors close to the cluster

### Security and isolation

- Run agents as non‑root where possible
- Limit privileges and mount only required volumes
- Use distinct namespaces and network policies per environment or tenant
- Scan images and pin versions for reproducibility

### Observability

- Emit queue wait, job duration, and success rate per queue and node pool
- Track cold‑start time components: image pull, pod schedule, init, and checkout
- Alert on eviction rate, OOMKills, and container restarts
- Correlate build steps with pod events to spot noisy neighbors

### When Kubernetes is a great fit

- You need elastic throughput with minimal ops overhead
- Isolation and reproducibility are priorities
- Workloads are already containerized or moving that way
- Caching can be shifted to remote stores or node‑local strategies

### Quick checklist

- Keep agent images slim and pre‑pull heavy layers
- Decide on cache strategy: remote first, node‑local where beneficial
- Map queues to node pools with clear resource profiles
- Set PDBs, termination hooks, and autoscaling policies
- Measure cold start and iterate on the biggest contributors

## Hosted agents

hosted (very fast builds in which everything is handled for you, full ephemeral).

Buildkite hosted agents provide fully managed, fully ephemeral execution environments optimized for speed and simplicity. Capacity, images, lifecycle, and patching are handled for you, so you focus on pipelines and code, not infrastructure.

### What you get

- Very fast startup and build times with pre‑tuned images
- Full isolation per job. No cross‑build drift or cleanup required
- Zero infra to operate. No nodes, autoscalers, or AMIs to maintain
- Secure defaults with least‑privilege access and patched runtimes

### Pros

- Lowest operational overhead. Start shipping immediately
- Highly consistent environments reduce flakiness
- Elastic capacity for bursts without pre‑warming
- Simple cost model with pay‑for‑what‑you‑use

### Cons and constraints

- Limited customization compared to self‑managed agents or custom node pools
- Large local caches are not persistent across jobs by default
- Access to privileged features, custom kernels, or GPUs may be restricted
- Per‑job startup latency can matter for ultra‑short steps if images are large

### Best for

- Teams that want speed to value with minimal ops
- Highly parallel test suites and bursty workloads
- Security‑sensitive pipelines needing strong isolation by default
- Organizations standardizing on a consistent environment across repos

### Caching and artifacts

- Prefer remote caches for dependencies and build outputs (S3, GCS, Artifactory)
- Use content‑based cache keys tied to lockfiles and tool versions
- Leverage registry‑level caching for container layers and keep images slim
- Store artifacts in remote stores. Avoid assuming local reuse between jobs

### Image and runtime guidance

- Choose the smallest compatible runtime image. Layer heavy toolchains on demand
- Pin versions for reproducibility. Track image digests in your pipeline
- Pre‑build language toolchains or test runners into custom images if supported

### Reliability and guardrails

- Split fast and slow queues to control latency and throughput
- Set retry policies for flaky network pulls and transient failures
- Emit metrics for queue wait, cold‑start components, and success rate per queue

### When hosted agents are a great fit

- You want the fastest path to reliable CI without managing infrastructure
- Workloads are well served by standard runtimes and remote caching
- You need elastic capacity with strong isolation and predictable performance

### Quick checklist

- Use remote dependency and layer caches with stable, content‑based keys
- Keep images lean. Pre‑build only what you truly need
- Separate queues by job profile and SLO
- Track cold‑start time and optimize the biggest contributors

## Queue by function, cluster by responsibility

The recommended way of configuring your Buildkite Cluster is as follows:

- Use one default queue for uploading initial pipelines.
- Used Task-specific queues grouped by operational function (Terraform IaC, test runners, application deployment, etc.).
- Set up a queue of pipeline upload agents that are readily available.

You can also use [Buildkite hosted agents](/docs/pipelines/hosted-agents) as they are using their own isolated clusters.

## Clusters as security boundaries

- If you have multiple cloud providers with different security stances, create separate clusters for this.
- If you have different security posture in your development environments, also have a separate cluster for each.
- If you have an open-source repository that is getting built in Buildkite, put the agents working with this repository on a separate cluster, to enforce the boundary.

## Keep a mix of static and autoscaling agents

If you want to maximize your pipelines' efficiency, you should keep one or two small instances around to handle the initial pipeline upload in your default queue. This will speed up your initial pipelines and allow the autoscaler to properly scale up as jobs are added to the pipeline. Once the jobs are processed, they should be handed off to dedicated [cluster queues](/docs/pipelines/clusters#clusters-and-queues-best-practices-how-should-i-structure-my-queues) that are geared towards handling those specific tasks.

### Recommended queue structure

How should you structure your queues? The most common queue attributes are based on infrastructure set-ups, such as:

- Architecture (x86, arm64, Apple silicon, etc.)
- Size of agents (small, medium, large, extra large)
- Type of machine (macOS, Linux, Windows, GPU, etc.)

So an example queue would be called `small_mac_silicon`.

Many Buildkite customers break queues down into `dev`, `test`, `prod`, and the agent sizes - into `small`, `medium`, `large`.

Having individual queues according to these breakdowns allows you to scale a set of similar agents, which Buildkite can then report on.

Learn more about working with queues in [Manage queues](/docs/pipelines/clusters/manage-queues).

## Establish a cached image for your agents

If you are truly operating at a large scale, you need a set of cached agent images. For smaller organizations supporting one application, you may just need one. However, you may also have multiple images depending on your needs. It is recommended to keep only the tooling that you need to execute a specific function on a specific queue image. You can also use the [Buildkite registry plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-cache-buildkite-plugin/) to get these images from the registry.

For example, a "security" image could have ClamAV, Trivy, Datadog's GuardDog, Snyk, and other tooling installed. Try to avoid having a single image containing all of your tooling and dependencies - keep them tightly scoped. You may want to build nightly to take advantage of automatically caching dependencies to speed up your builds, including system, framework, and image updates in Buildkite Packages, or publish to an AWS AMI, etc. This eliminates the potential for you to hit rate limits with high-scaling builds.

Using cached images helps eliminate the necessity of sharing filesystems between services that could cause contention or a dirty cache.

For hosted agents, we recommend using queue images.

## Using long running and ephemeral agents

To choose between long-running agents and ephemeral agents, you should know that by using long-running agents, you get speed benefits and also can get caching-like capabilities benefits storing a git mirror or large shared files in the machine image (a common practice).

To start using long-running agents:

- Set a maximum age for your machines that is max 24 hours.
- Add telemetry to understand when an agent becomes flaky so you can pause it and take it out.
- Try to scale down by retiring the oldest agents first.

With ephemeral [Buildkite hosted agents](/docs/pipelines/hosted-agents/linux#agent-images-create-an-agent-image), you can automatically include caches of your Git repository and any cached volumes for data that must be shared between services or runs.

## Utilize agent hooks in your architecture

[Buildkite Agent hooks](/docs/agent/v3/hooks) can be very useful in structuring a pipeline. Instead of requiring all the code to be included in every repository, you can use lifecycle hooks to pull down different repositories, allowing you to create guardrails and reusable, immutable pieces of your pipeline for every job execution. They're a critical tool for compliance-heavy workloads and help to automate any setup or tear-down functions necessary when running jobs.

Example use cases:

- Sending telemetry data at the start and end of the job
- Policy and access control: block unapproved users, limit allowed plugins, restrict queues, or disable command eval on sensitive agents
- Environment setup: fetch secrets, set environment variables, configure language runtimes, start sidecar services
- Source control tweaks: custom checkout strategies, Git mirrors, Git worktrees for faster builds

- Auditing and hygiene: log context, enforce required steps, collect and upload artifacts or metadata in post-command

## Right-size your agent fleet

- Monitor queue times: Long wait times often mean you need more capacity. You can use cluster insights to monitor queue wait times.
- Autoscale intelligently: Use cloud-based autoscaling groups to scale with demand (using Elastic CI Stack for AWS, [Agent Stack for Kubernetes](/docs/agent/v3/agent-stack-k8s) - and soon-to-be-supported GCP - can help you with auto-scaling).
- Specialized pools: Maintain dedicated pools for CPU-intensive, GPU-enabled, or OS-specific workloads.
- Graceful scaling: Configure agents to complete jobs before termination to prevent abrupt failures (Elastic CI Stack for AWS already has graceful scaling implemented. Also, if you are building your own AWS stack, you can use [Buildkite's lifecycle daemon](https://github.com/buildkite/lifecycled) for handling graceful termination and scaling).

### Optimize agent performance

- Use targeting and metadata: Route jobs to the correct environment using queues and agent tags.
- Implement caching: Reuse dependencies, build artifacts, and Docker layers to reduce redundant work. (Further work here: add a link to some of our cache plugins and highlight cache volumes for hosted agents. Also - potentially create a best practices section for self-hosted and hosted agents.)
- Pre-warm environments: Bake common tools and dependencies into images for faster startup.
- Monitor agent health: Continuously check for resource exhaustion and recycle unhealthy instances. Utilize agent pausing when resources are tied to the lifetime of the agent, such as a cloud instance configured to terminate when the agent exits. By pausing an agent, you can investigate problems in its environment more easily, without the worry of jobs being dispatched to it.

### Secure your agents

- Principle of least privilege: provide only the permissions required for the job.
- Prefer ephemeral agents: short-lived agents reduce the attack surface and minimize drift.
- Secret management: use environment hooks or secret managers; never hard-code secrets in YAML.
- Keep base images updated: regularly patch agents to mitigate security vulnerabilities.

Further work in this section: mention BK Secrets, suggest using external secret managers like AWS Secrets Manager or Hashicorp Vault. Potentially also link back to our own plugins, too.

### Enforce infrastructure-as-code

- Enforce agent configuration and infrastructure using [infrastructure-as-code (IaC)](https://aws.amazon.com/what-is/iac/) where possible. For example, see [Buildkite Package Registries with Terraform support](/docs/package-registries/ecosystems/terraform).
- No manual tweaks: avoid one-off changes to long-lived agents; enforce everything via code and images.
- Immutable patterns: use infrastructure-as-code and versioned images for consistency and reproducibility.
