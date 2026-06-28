# Agent reference architectures

This page describes four reference architectures for running [Buildkite agents](/docs/agent) as your usage grows, from a single team getting started through to a large enterprise fleet. Use it to identify the architecture that fits your team today, and to recognize the signals that tell you when to move up to the next one.

The goal is to run the simplest architecture that meets your needs now, and to upgrade only when you see recurring pressure, not one-off incidents. Just as you would match a vehicle to its load, match your agent infrastructure to your build volume, team size, and operational maturity. Reaching for the most complex architecture too early adds operational cost for no return, while staying too long on a small setup slows your team down.

## Architecture comparison

The four architectures map to maturity stages, each with a typical team size, build volume, and set of operational trade-offs.

| Dimension | Starter | Growth | Scale | Enterprise |
| --------- | ------- | ------ | ----- | ---------- |
| **Team size** | 1–15 engineers | 15–60 engineers | 60–250 engineers | 250+ engineers |
| **Daily builds** | Under 200 | 200–2,000 | 2,000–20,000 | 20,000+ |
| **Agent compute** | Buildkite hosted agents or a single VM | Auto-scaled VMs | Container pool | Kubernetes clusters |
| **Queue strategy** | Single queue | 2–3 queues | Per-workload queues | Dynamic routing with tags |
| **Caching** | None or basic | Object storage bucket | Shared cache layer | Distributed cache tier |
| **Operational complexity** | Low | Moderate | High | Very high |
{: class="responsive-table"}

## Starter

The Starter architecture suits startups, small product teams, side projects, and pilot programs adopting CI/CD. It is optimized for speed of setup and simplicity, not for throughput or isolation.

At this scale, the main risk is over-engineering. Adding Kubernetes, multi-queue routing, and agent hooks when you have 10 engineers and 100 daily builds adds operational cost for no return. Keep the setup flat.

Recommended setup:

- Use [Buildkite hosted agents](/docs/agent/buildkite-hosted) for zero infrastructure management. This suits teams that want to move fast without a dedicated platform engineer. If you self-host, a single VM or a small auto-scaling group of one to four general-purpose agents is enough, and the [Elastic CI Stack for AWS](/docs/agent/self-hosted/aws/elastic-ci-stack) is a practical starting point.
- Use a single default [queue](/docs/agent/queues). Do not segment queues at this stage, since the added complexity outweighs the benefit.
- Store secrets as [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets) or in a lightweight cloud secret store.

Move up to Growth when you see any of the following:

- Build queue wait times regularly exceed two to three minutes.
- A single flaky or runaway job can block the whole team.
- You need to separate deployment jobs from test jobs for security or compliance.
- You run more than one language or platform stack, and agents need different toolchains.

## Growth

The Growth architecture suits growing product companies and multi-team engineering organizations scaling their CI practice. It introduces the foundational patterns that every larger architecture builds on: auto-scaling, queue segmentation, and artifact caching. Getting these right now makes a later move to Scale or Enterprise less painful.

Recommended setup:

- Deploy auto-scaling as a first-class concern, so agents start in response to queue depth and terminate after an idle period rather than running always-on. The [Elastic CI Stack for AWS](/docs/agent/self-hosted/aws/elastic-ci-stack) provides this out of the box, or you can use an equivalent module for another cloud.
- Introduce two to three named [queues](/docs/agent/queues). Separate test jobs from deploy jobs at minimum. This isolates production credential access to a specific agent pool and prevents a broken test run from blocking deploys.
- Scale on queue depth using the [buildkite-agent-metrics](/docs/agent/self-hosted/monitoring-and-observability#buildkite-agent-metrics-cli) tool to drive your scaler. Target a p95 queue wait time under 60 seconds.
- Cache dependencies and build outputs in object storage. See [Caching best practices](/docs/pipelines/best-practices/caching) for patterns.
- Standardize on a base agent image with shared tooling, so agents do not install dependencies on every boot.
- Use [agent hooks](/docs/agent/hooks) to inject secrets, configure the environment, and enforce policy.

A minimal queue layout at this stage separates workloads by their compute profile and credential needs.

| Queue | Job types | Agent notes |
| ----- | --------- | ----------- |
| `test` | Unit tests, integration tests, linting | Auto-scaled, no production credentials |
| `build` | Container image builds, artifact compilation | Auto-scaled, access to your registry |
| `deploy` | Staging and production deployments | Small pool, production role attached |
{: class="responsive-table"}

Move up to Scale when you see any of the following:

- Test parallelism demands exceed what one uniform agent pool can absorb cost-effectively.
- Different teams need different agent environments, such as mobile builds, ML training jobs, or ARM64.
- Queue wait times keep climbing despite larger VMs and higher scaling limits.
- Compliance requirements demand stricter isolation between workload types.
- Your platform team spends significant time managing the agent fleet.

## Scale

The Scale architecture suits engineering organizations with diverse workloads, compliance requirements, and a dedicated platform team. The agent fleet is no longer uniform, since different job types have different compute profiles. It introduces container-native workloads, mixed agent pools, and a more deliberate approach to isolation and observability.

Recommended setup:

- Move agents into containers. Use the Buildkite agent Docker image as a base, and build per-workload images that include the toolchain for each job class.
- Run agents on demand through a container scheduler, such as Amazon ECS, Nomad, or a managed Kubernetes cluster. Map each job type to a specific task definition or container spec.
- Design queues around job characteristics, not team ownership. Team-specific queues fragment the pool and reduce utilization, so own the queue taxonomy at the platform level.
- Run a dedicated cache layer. At this volume, object storage round-trips add up, so combine a shared network file system mount for workspace-local caches with object storage for broader artifacts.
- Use [agent tags](/docs/agent/queues) to route jobs to specific capabilities, such as a queue, architecture, or GPU requirement. This gives pipeline authors a declarative interface without knowing the underlying infrastructure.
- Introduce pipeline templates or step libraries to prevent a proliferation of per-team agent configurations.
- Export structured build metrics. At this scale, identifying systemic slowdowns requires data you cannot eyeball. See [Monitoring and observability best practices](/docs/pipelines/best-practices/monitoring-and-observability).

A layered agent image hierarchy reduces maintenance overhead. Define a base image with shared security and monitoring tooling, then stack job-class images on top.

| Image layer | Contents | Rebuild cadence |
| ----------- | -------- | --------------- |
| `agent-base` | Agent binary, certificates, monitoring agents, shell config | Weekly or on patches |
| `agent-test` | Common test dependencies and language runtimes | Weekly or on dependency updates |
| `agent-deploy` | Deployment CLIs, with production credentials injected at runtime | Weekly |
| `agent-security` | Security scanners, network-isolated by the scheduler | Weekly |
{: class="responsive-table"}

Move up to Enterprise when you see any of the following:

- You run agents across multiple cloud regions or on-premises data centers.
- Kubernetes is your standard compute substrate, and you want agents to live natively in it.
- You need pod-level isolation between job executions for compliance, such as SOC 2, FedRAMP, or HIPAA.
- Build infrastructure cost is a meaningful line item, and you need per-team or per-project cost attribution.
- Your platform team runs agent infrastructure as a product, with SLAs and an internal customer base.

## Enterprise

The Enterprise architecture suits large engineering organizations, regulated industries, and multi-cloud or hybrid infrastructure. It is Kubernetes-native and multi-cluster. The operational complexity is real and demands a dedicated platform engineering function. In exchange, it offers the highest throughput, the finest-grained isolation, and the most sophisticated cost optimization.

Recommended setup:

- Deploy the [Agent Stack for Kubernetes](/docs/agent/self-hosted/agent-stack-k8s) into each cluster. Rather than running long-lived agents that poll for jobs, the stack runs a dedicated pod per job and tears it down on completion. This delivers per-job isolation and integrates with Kubernetes RBAC, network policies, and service accounts.
- Right-size nodes for actual job resource requests using a node provisioner such as Karpenter or the Cluster Autoscaler. Avoid over-provisioning for theoretical worst-case job sizes.
- Run spot or preemptible instances for stateless test workloads, which are typically 70–85% of build volume. Reserve on-demand capacity for deploy agents and jobs with strict SLAs, and configure automatic retries so jobs survive instance interruptions. See the [agent lifecycle](/docs/agent/lifecycle) for graceful termination.
- Apply Kubernetes network policies to isolate job namespaces. Run security-sensitive jobs, such as credential rotation and production deployments, in dedicated namespaces with restricted egress.
- Bind cloud credentials to specific job service accounts using workload identity, such as IRSA on Amazon EKS or Workload Identity on Google GKE. Static credential injection is not acceptable at this tier.
- Deploy across multiple clusters in at least two regions, and define a primary queue and a fallback queue for regional redundancy.
- Run a build observability stack that exports agent metrics, such as queue depth, job duration, and agent utilization, and define SLOs on build latency.
- Provide a self-service catalog of approved agent configurations, base images, and resource presets that teams select from. This prevents configuration sprawl while giving teams flexibility.

The highest-impact cost levers at this scale are:

- Run spot or preemptible instances for stateless jobs, which typically reduce cost by 60–80% versus on-demand for test workloads.
- Right-size pod resource requests against historical job metrics, since bin-packing efficiency degrades when requests are over-specified.
- Cache aggressively. At 20,000+ daily builds, even a 10-minute average reduction in job duration compounds to hundreds of compute-hours per day.
- Attribute cost per team using Kubernetes labels and cloud cost allocation tags. Teams that see their build cost tend to optimize it.

## Choosing your architecture

The most common mistake is skipping a stage. Going straight from Starter to Enterprise rarely works, not because the technology cannot be made to work, but because the team has not built the operational habits to run it safely.

Each architecture is a stable resting point, not a temporary stop. Operate at your current stage until the upgrade signals in the preceding sections become recurring patterns, then migrate with a clear success criterion.

Use this checklist as a starting point:

- Below 200 daily builds with a single team? Start with the Starter architecture. Buildkite hosted agents are a production-ready choice.
- Growing past 200 builds a day and seeing queue contention or security boundary needs? Move to the Growth architecture, and add auto-scaling and queue segmentation.
- Diverse workload types, such as mobile, web, ML, and security, and a platform team of two or more? The Scale architecture gives you the flexibility you need.
- A large enterprise with Kubernetes as your compute substrate, multi-region requirements, or compliance mandates? The Enterprise architecture is the right fit.
- Not sure? Default to one stage below where you think you are. Operational complexity is easier to add than to remove.

For day-to-day guidance that applies across all four architectures, see [Agent management best practices](/docs/pipelines/best-practices/agent-management).
