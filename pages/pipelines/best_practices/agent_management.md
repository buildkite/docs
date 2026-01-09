# Agent management best practices

This page covers best practices for effective management of [Buildkite Agents](/docs/agent/v3). Buildkite Agents execute your pipeline's jobs. The right infrastructure, queue layout, and lifecycle policies for your Buildkite Agents determine the security, speed, and cost of your agent fleet.

## Choosing the right architecture

Buildkite Agents can run on local machines, cloud compute, container schedulers, and serverless infrastructure. Choose based on your workload characteristics, cost constraints, and operational maturity. Many teams adopt a hybrid approach, combining different stacks for different workload types.

| Stack | Best for | Key benefits |
| ----- | -------- | ------------ |
| **Cloud compute** | High utilization, disk-heavy jobs | Bin-pack multiple agents, warm images, large cache support |
| **Containers (Kubernetes/ECS)** | Elastic isolation per job, burst isolation | Fast autoscaling, clean environments, strong isolation |
| **Buildkite hosted agents** | Speed to value, zero ops, bursty workloads | Fully managed, isolated clusters, per-minute billing |
| **Hybrid approach** | Cost optimization and accounting for different use cases for different teams| Provides the best agent infrastructure for your particular needs |

See a more detailed overview of each architecture type for Buildkite Agents to choose what's right for your Buildkite organization.

### Cloud compute

Run multiple agents per an instance to maximize cost efficiency and enable heavy caching.

**Pros:**

- Strong isolation with predictable performance
- Warm images reduce job startup time
- Compatible with spot instances for cost savings
- Support for large disk caches and GPU/TPU workloads

**Cons:**

- Additional operational overhead to patch and maintain instances
- Cost inefficiency at low utilization if agents are under-used
- Slower agent spin-up times compared to other agent architectures

Learn more in [Elastic CI Stack for AWS](/docs/agent/v3/self-hosted/aws/elastic-ci-stack).

### Containers (Kubernetes, ECS)

You can deploy ephemeral agents per job for maximum isolation and rapid scaling, or long-running agents that stay alive between jobs for improved performance through warm starts and persistent caching.

**Pros:**

- Fast spin-up with fine-grained autoscaling
- Clean environments reduce build flakiness
- Native resource limits and multi-tenant isolation

**Cons:**

- Pulling large images can increase job startup latency
- Requires cluster expertise and ongoing platform maintenance
- Limited access to large persistent disk caches per job

Learn more in [Agent Stack for Kubernetes](/docs/agent/v3/self-hosted/agent-stack-k8s).

### Buildkite hosted agents

[Buildkite hosted agents](/docs/pipelines/hosted-agents) provide fully managed infrastructure with isolated clusters and minimal operational overhead.

**Pros:**

- Fully managed infrastructure with zero operational overhead
- Built-in caching for [Git mirrors](/docs/agent/v3/git-mirrors) and containers, as well as attachable [Cache volumes](/docs/pipelines/hosted-agents/cache-volumes#container-cache-volumes) for temporary data storage
- Isolated clusters that provide strong security boundaries
- Per-minute billing with automatic scaling for bursty workloads
- Ideal for highly parallel test suites

**Cons:**

- Hosted agents run outside your private network boundary, so may not meet strict compliance or data-residency requirements
- Less control over hardware configuration and OS versions than in self-managed compute
- Higher cost for sustained high throughput compared to self-managed compute

## Capacity strategy

There is no need to settle on a single architecture within your Buildkite organization as you utilize different stacks based on the needs and knowledge level in your teams.

For example, a popular approach among Buildkite users is to have a self-managed agent fleet that is based on either [Kubernetes](/docs/agent/v3/self-hosted/agent-stack-k8s) or cloud compute instances ([AWS](/docs/agent/v3/aws) or [Google Cloud Platform](/docs/agent/v3/self-hosted/gcp)), as well as on [Buildkite macOS hosted agents](/docs/pipelines/hosted-agents/macos) due to ease of management, clean development environments, and [optimized caching](/docs/pipelines/hosted-agents/cache-volumes) the latter provide. Different teams in those Buildkite organizations can utilize the stacks that are better suited to their needs.

Similarly, in terms of agent fleet scaling, instead of choosing between using static or autoscaling agents exclusively, you can:

- Keep one-two small static instances in your default queue for pipeline uploads as this speeds up pipeline starts and allows proper autoscaling.
- Use dedicated autoscaling queues for actual workload.

## Structuring clusters and queues

You should organize [clusters](/docs/pipelines/clusters) as security boundaries and [queues](/docs/agent/v3/targeting/queues) for workload routing. Use separate queues and a small subset of agents to trial new architectures (for example, [Buildkite hosted agents](/docs/pipelines/hosted-agents)) before rolling them out broadly across your Buildkite organization.

Learn more about using clusters and queues in [Managing clusters](/docs/pipelines/clusters/manage-clusters) and [Managing queues](/docs/agent/v3/targeting/queues/managing).

## Agent lifecycle

- Long-running agents provide caching benefits ([Git mirrors](/docs/agent/v3/git-mirrors), [dependencies](/docs/pipelines/configure/dependencies)):
  * Retire oldest agents first during scale-down
  * Add telemetry to detect flaky agents
- Ephemeral agents reduce attack surface and configuration drift. [Buildkite hosted agents](/docs/pipelines/hosted-agents/linux#agent-images) support repository caches and shared volumes.

## Right-sizing of your agent fleet

- Monitor queue times with [cluster insights](/docs/pipelines/clusters#cluster-insights) and [Buildkite Agent Metrics](https://github.com/buildkite/buildkite-agent-metrics).
- Use cloud-based autoscaling ([Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws), [Buildkite Agent Scaler](https://github.com/buildkite/buildkite-agent-scaler), [Agent Stack for Kubernetes](/docs/agent/v3/self-hosted/agent-stack-k8s)).
- Maintain dedicated pools for CPU-intensive, GPU-enabled, or OS-specific workloads.
- Configure [graceful termination](/docs/agent/v3#signal-handling) to allow jobs to complete.
- To be able to duplicate your fleet of agents in an easy way, favor agent images and configurations that are able to run in more than one environment. For example, you can have a single Docker image that contains the latest Buildkite Agent binary, a selection of development and deployment tools, and a config that reads information such as queues or tags from environment variables. You could then run such image as Kubernetes agents, ECS agents, or in a Docker setup on a virtual machine.

## Resilience and redundancy

Strive to have an architecture that allows you to run agents in multiple regions or on a secondary platform to make sure that the critical queues keep running during outages. For example, instead of running all your agents for a critical queue in a single availability zone - spread your agents to other availability zones. This way, if one of the availability zones experiences issues, the agents in other zones will still be able to pick up the jobs.

Opt for building out your agent architecture in such a way that a single host or cluster problem will only affect a limited (preferably small) subset of queues or pipelines, and not your entire agent fleet.

## Security

Build security into agent infrastructure from the start. Follow least privilege principles and integrate proper secret management. It's recommended that you:

- Store secrets in hooks or cloud secret stores. You can find more on proper secrets management in Buildkite Pipelines in [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets) and [Secrets management](/docs/pipelines/best-practices/secrets-management)
- Use short-lived tokens and [ephemeral agents](/docs/pipelines/hosted-agents/linux#agent-images)
- Enforce infrastructure-as-code ([Terraform](/docs/package-registries/ecosystems/terraform), CloudFormation)

For more information on agent security, see [Buildkite Agent security](/docs/pipelines/best-practices/security-controls#buildkite-agent-security).
