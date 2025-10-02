# Architecture and ownership

This pages covers the best practices regarding architecting and maintaining a Buildkite-based CI/CD environment.

## Overall ownership

Define clear boundaries of ownership. CI/CD works best if the supporting team is able to control their application pipeline, with supporting tooling brought in to meet GRC standards.

## Agents, queues, and clusters

[Buildkite Agents](/docs/agent/v3) are a core element of Buildkite's ability to deliver massive [parallelization](/docs/pipelines/tutorials/parallel-builds) at scale. The way you configure and set up your agents and [clusters](/docs/pipelines/clusters) can have a huge impact on the security and reliability of your overall systems. The following sub-section cover the suggested approach.

### Queue by function, cluster by responsibility

The recommended way of configuring your Buildkite Cluster is as follows:

* Use one default queue for uploading initial pipelines.
* Used Task-specific queues grouped by operational function (Terraform IaC, test runners, application deployment, etc.).

### Keep a mix of static and autoscaling agents

If you want to maximize your pipelines' efficiency, you should keep one or two small instances around to handle the initial pipeline upload in your default queue. This will speed up your initial pipelines and allow the autoscaler to properly scale up as jobs are added to the pipeline. Once the jobs are processed, they should be handed off to dedicated [cluster queues](/docs/pipelines/clusters#clusters-and-queues-best-practices-how-should-i-structure-my-queues) that are geared towards handling those specific tasks.

### Establish a cached image for your agents

If you are truly operating at a large scale, you need a set of cached agent images. For smaller organizations supporting one application, you may just need one. However, you may also have multiple images depending on your needs. It is recommended to keep only the tooling that you need to execute a specific function on a specific queue image.

For example, a "security" image could have ClamAV, Trivy, Datadog's GuardDog, Snyk, and other tooling installed. Try to avoid having a single image containing all of your tooling and dependencies - keep them tightly scoped. You may want to build nightly to take advantage of automatically caching dependencies to speed up your builds, including system, framework, and image updates in Buildkite Packages, or publish to an AWS AMI, etc. This eliminates the potential for you to hit rate limits with high-scaling builds.

### Use ephemeral agents

Builds should be air-tight, and not share any kind of state or assets with other builds. Using cached images as described in the previous section helps eliminate the necessity of sharing filesystems between services that could cause contention or a dirty cache.

Managing ephemeral infrastructure can be tough, and so we've [made it easy with Buildkite Hosted Agents](https://buildkite.com/docs/pipelines/hosted-agents/linux#agent-images-create-an-agent-image). With hosted agents, you can automatically include caches of your Git repository and any cached volumes for data that must be shared between services or runs.

### Utilize agent hooks in your architecture

[Buildkite Agent hooks](/docs/agent/v3/hooks) can be very useful in structuring a pipeline. Instead of requiring all the code to be included in every repository, you can use lifecycle hooks to pull down different repositories, allowing you to create guardrails and reusable, immutable pieces of your pipeline for every job execution. They're a critical tool for compliance-heavy workloads and help to automate any setup or tear-down functions necessary when running jobs.
