# Agent management

This page covers the best practices for effective management of Buildkite Agents.

[Buildkite Agents](/docs/agent/v3) are a core element of Buildkite's ability to deliver massive [parallelization](/docs/pipelines/tutorials/parallel-builds) at scale. The way you configure and set up your agents and [clusters](/docs/pipelines/clusters) can have a huge impact on the security and reliability of your overall systems. The following sub-section cover the suggested approach.

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

How should you structure your queues? The most common queue attributes are based on infrastructure set-ups, such as:

- Architecture (x86, arm64, Apple silicon, etc.)
- Size of agents (small, medium, large, extra large)
- Type of machine (macOS, Linux, Windows, GPU, etc.)

So an example queue would be called `small_mac_silicon`.

Many Buildkite customers break queues down into `dev`, `test`, `prod`, and the agent sizes - into `small`, `medium`, `large`.

Having individual queues according to these breakdowns allows you to scale a set of similar agents, which Buildkite can then report on.

Learn more about working with queues in [Manage queues](/docs/pipelines/clusters/manage-queues).

## Establish a cached image for your agents

If you are truly operating at a large scale, you need a set of cached agent images. For smaller organizations supporting one application, you may just need one. However, you may also have multiple images depending on your needs. It is recommended to keep only the tooling that you need to execute a specific function on a specific queue image. You can also use Buildkite registry plugin to get these images from the registry.

For example, a "security" image could have ClamAV, Trivy, Datadog's GuardDog, Snyk, and other tooling installed. Try to avoid having a single image containing all of your tooling and dependencies - keep them tightly scoped. You may want to build nightly to take advantage of automatically caching dependencies to speed up your builds, including system, framework, and image updates in Buildkite Packages, or publish to an AWS AMI, etc. This eliminates the potential for you to hit rate limits with high-scaling builds.

For hosted agents, we recommend using queue images.

Using cached images helps eliminate the necessity of sharing filesystems between services that could cause contention or a dirty cache.

## Using long running and ephemeral agents

To choose between long-running agents and ephemeral agents, you should know that by using long-running agents, you get speed benefits and also can get caching-like capabilities benefits storing a git mirror or large shared files in the machine image (a common practice).

To start using long-running agents:

- Set a maximum age for your machines that is max 24 hours.
- Add telemetry to understand when an agent becomes flaky so you can pause it and take it out.
- Try to scale down by retiring the oldest agents first.

With ephemeral [Buildkite hosted agents](/docs/pipelines/hosted-agents/linux#agent-images-create-an-agent-image), you can automatically include caches of your Git repository and any cached volumes for data that must be shared between services or runs.

## Utilize agent hooks in your architecture

[Buildkite Agent hooks](/docs/agent/v3/hooks) can be very useful in structuring a pipeline. Instead of requiring all the code to be included in every repository, you can use lifecycle hooks to pull down different repositories, allowing you to create guardrails and reusable, immutable pieces of your pipeline for every job execution. They're a critical tool for compliance-heavy workloads and help to automate any setup or tear-down functions necessary when running jobs.

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

- Principle of least privilege: Provide only the permissions required for the job.
- Prefer ephemeral agents: Short-lived agents reduce the attack surface and minimize drift.
- Secret management: Use environment hooks or secret managers; never hard-code secrets in YAML.
- Keep base images updated: Regularly patch agents to mitigate security vulnerabilities.

Further work in this section: mention BK Secrets, suggest using external secret managers like AWS Secrets Manager or Hashicorp Vault. Potentially also link back to our own plugins, too.

### Enforce IaC

- No manual tweaks: Avoid one-off changes to long-lived agents; enforce everything via code and images.
- Immutable patterns: Use infrastructure-as-code and versioned images for consistency and reproducibility.

Alternatively: Enforce agent configuration and infrastructure using IaC (Infrastructure as code) where possible. For example, see [Buildkite Package Registries with Terraform support](/docs/package-registries/ecosystems/terraform).
