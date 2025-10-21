# Architecture and ownership

This pages covers the best practices regarding architecting and maintaining a Buildkite-based CI/CD environment.

## Overall ownership

Set up a platform team that is managing the infrastructure and the common constructs that can be used as pipelines, for example, private plugins, Docker image building pipeline, an so on. And then allow the individual developer teams build their own pipelines.

## Agents, queues, and clusters

[Buildkite Agents](/docs/agent/v3) are a core element of Buildkite's ability to deliver massive [parallelization](/docs/pipelines/tutorials/parallel-builds) at scale. The way you configure and set up your agents and [clusters](/docs/pipelines/clusters) can have a huge impact on the security and reliability of your overall systems. The following sub-section cover the suggested approach.

### Queue by function, cluster by responsibility

The recommended way of configuring your Buildkite Cluster is as follows:

- Use one default queue for uploading initial pipelines.
- Used Task-specific queues grouped by operational function (Terraform IaC, test runners, application deployment, etc.).
- Set up a queue of pipeline upload agents that are readily available.

You can also use [Buildkite hosted agents](/docs/pipelines/hosted-agents) as they are using their own isolated clusters.

### Clusters as security boundaries

- If you have multiple cloud providers with different security stances, create separate clusters for this.
- If you have different security posture in your development environments, also have a separate cluster for each.
- If you have an open-source repository that is getting built in Buildkite, put the agents working with this repository on a separate cluster, to enforce the boundary.

### Keep a mix of static and autoscaling agents

If you want to maximize your pipelines' efficiency, you should keep one or two small instances around to handle the initial pipeline upload in your default queue. This will speed up your initial pipelines and allow the autoscaler to properly scale up as jobs are added to the pipeline. Once the jobs are processed, they should be handed off to dedicated [cluster queues](/docs/pipelines/clusters#clusters-and-queues-best-practices-how-should-i-structure-my-queues) that are geared towards handling those specific tasks.

How should you structure your queues? The most common queue attributes are based on infrastructure set-ups, such as:

- Architecture (x86, arm64, Apple silicon, etc.)
- Size of agents (small, medium, large, extra large)
- Type of machine (macOS, Linux, Windows, GPU, etc.)

So an example queue would be called `small_mac_silicon`.

Many Buildkite customers break queues down into `dev`, `test`, `prod`, and the agent sizes - into `small`, `medium`, `large`.

Having individual queues according to these breakdowns allows you to scale a set of similar agents, which Buildkite can then report on.

Learn more about working with queues in [Manage queues](/docs/pipelines/clusters/manage-queues).

### Establish a cached image for your agents

If you are truly operating at a large scale, you need a set of cached agent images. For smaller organizations supporting one application, you may just need one. However, you may also have multiple images depending on your needs. It is recommended to keep only the tooling that you need to execute a specific function on a specific queue image. You can also use Buildkite registry plugin to get these images from the registry.

For example, a "security" image could have ClamAV, Trivy, Datadog's GuardDog, Snyk, and other tooling installed. Try to avoid having a single image containing all of your tooling and dependencies - keep them tightly scoped. You may want to build nightly to take advantage of automatically caching dependencies to speed up your builds, including system, framework, and image updates in Buildkite Packages, or publish to an AWS AMI, etc. This eliminates the potential for you to hit rate limits with high-scaling builds.

### Use ephemeral agents

Builds should be air-tight, and not share any kind of state or assets with other builds. Using cached images as described in the previous section helps eliminate the necessity of sharing filesystems between services that could cause contention or a dirty cache.

Managing ephemeral infrastructure can be tough, and so we've [made it easy with Buildkite Hosted Agents](https://buildkite.com/docs/pipelines/hosted-agents/linux#agent-images-create-an-agent-image). With hosted agents, you can automatically include caches of your Git repository and any cached volumes for data that must be shared between services or runs.

### Utilize agent hooks in your architecture

[Buildkite Agent hooks](/docs/agent/v3/hooks) can be very useful in structuring a pipeline. Instead of requiring all the code to be included in every repository, you can use lifecycle hooks to pull down different repositories, allowing you to create guardrails and reusable, immutable pieces of your pipeline for every job execution. They're a critical tool for compliance-heavy workloads and help to automate any setup or tear-down functions necessary when running jobs.

### Wait steps for coordination

Ensure multiple parallel jobs complete before proceeding:

```yaml
steps:
  - label: ":hammer: Build"
    command: "make build"
    parallelism: 3
  - wait
  - label: ":rocket: Deploy"
    command: "make deploy"
```

### Graceful error handling

Use `soft_fail` where failures are acceptable, but document why:

```yaml
steps:
  - label: ":test_tube: Optional integration tests"
    command: "make integration-tests"
    soft_fail: true
  - label: ":white_check_mark: Required unit tests"
    command: "make unit-tests"
```

### Use block steps for approvals

Require human confirmation before production deployment:

```yaml
steps:
  - block: ":rocket: Deploy to production?"
    branches: "main"
    fields:
      - select: "Environment"
        key: "environment"
        options:
          - label: "Staging"
            value: "staging"
          - label: "Production"
            value: "production"
```

### Canary releases in CI/CD

Model partial deployments and staged rollouts directly in pipelines. See more in [Deployments](/docs/pipelines/deployments).

### Pipeline-as-code reviews

Require peer reviews for pipeline changes, just like application code.

### Chaos testing

Periodically inject failure scenarios (e.g., failing agents, flaky dependencies) to validate pipeline resilience.

### Silent failures

Never ignore failing steps without a clear follow-up.
