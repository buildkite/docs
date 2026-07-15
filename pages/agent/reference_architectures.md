---
description: "Compare four practical reference architecture patterns for Buildkite agent infrastructure, from a small initial setup to a multi-cluster enterprise fleet."
---

# Buildkite agent reference architectures

This page compares four reference architecture patterns for running [Buildkite agents](/docs/agent), from a small initial setup to a multi-cluster enterprise fleet. Each pattern describes a typical combination of agent compute, queues, caching, workload isolation, and operational ownership.

The _Starter_, _Growth_, _Scale_, and _Enterprise_ names are convenience labels used only on this page. They are not official Buildkite architecture names, product tiers, or required stages. Your architecture can combine elements from more than one pattern.

Choose the simplest pattern that meets your current requirements. Add complexity when recurring queue delays, workload conflicts, security boundaries, or fleet management work show that the current design no longer fits.

## Which reference architecture should you choose

Use build volume and team size as initial indicators, then make the decision based on workload diversity, isolation requirements, and operational capacity:

- **Starter:** Use Buildkite hosted agents, one VM, or a small auto-scaling group when one team has similar workloads and needs little infrastructure specialization.
- **Growth:** Add auto-scaling, separate queues, and shared caching when queue contention or different credential boundaries become recurring concerns.
- **Scale:** Use workload-specific container pools and centralized fleet management when teams need different operating systems, architectures, accelerators, or compliance controls.
- **Enterprise:** Use multi-cluster Kubernetes infrastructure when you need per-job isolation, regional resilience, detailed cost attribution, or platform-level service objectives.

Treat these recommendations as starting points rather than thresholds. A smaller organization with regulated workloads might need stronger isolation, while a larger organization with uniform workloads might not need Kubernetes.

## Architecture comparison

The following ranges show the environments that each pattern commonly fits. They are guides, not limits or Buildkite service requirements.

| Dimension | Starter | Growth | Scale | Enterprise |
| --------- | ------- | ------ | ----- | ---------- |
| **Team size** | 1–15 engineers | 15–60 engineers | 60–250 engineers | 250+ engineers |
| **Daily builds** | Under 200 | 200–2,000 | 2,000–20,000 | 20,000+ |
| **Agent compute** | Buildkite hosted agents or a single VM | Auto-scaled VMs | Container pool | Kubernetes clusters |
| **Queue strategy** | Single queue | 2–3 queues | Per-workload queues | Dynamic routing with tags |
| **Caching** | None or basic | Object storage bucket | Shared cache layer | Distributed cache tier |
| **Operational complexity** | Low | Moderate | High | Very high |
{: class="responsive-table"}

## Starter pattern

The Starter pattern suits a single team with similar workloads and limited isolation requirements. It prioritizes a small operational footprint over specialized routing or high throughput.

Avoid adding Kubernetes, multiple queues, or custom hooks before the workload requires them. A flat setup is easier to operate and diagnose.

### Recommended setup

- Use [Buildkite hosted agents](/docs/agent/buildkite-hosted) when you want Buildkite to manage the agent infrastructure. If you self-host, begin with a single VM or a small auto-scaling group of one to four general-purpose agents. The [Elastic CI Stack for AWS](/docs/agent/self-hosted/aws/elastic-ci-stack) provides a starting point on AWS.
- Use a single default [queue](/docs/agent/queues). Do not segment queues at this stage, since the added complexity outweighs the benefit.
- Store secrets as [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets) or in a lightweight cloud secret store.

### When to move beyond the Starter pattern

Consider the Growth pattern when you see any of the following recurring conditions:

- Build queue wait times regularly exceed two to three minutes.
- A single flaky or runaway job can block the whole team.
- You need to separate deployment jobs from test jobs for security or compliance.
- You run more than one language or platform stack, and agents need different toolchains.

## Growth pattern

The Growth pattern suits multiple teams that need more capacity or clearer workload boundaries. It adds auto-scaling, queue segmentation, and caching without requiring a container scheduler.

### Recommended setup

- Deploy auto-scaling as a first-class concern, so agents start in response to queue depth and terminate after an idle period rather than running always-on. The [Elastic CI Stack for AWS](/docs/agent/self-hosted/aws/elastic-ci-stack) provides this out of the box, or you can use an equivalent module for another cloud.
- Introduce two to three named [queues](/docs/agent/queues). Separate test jobs from deploy jobs at minimum. This isolates production credential access to a specific agent pool and prevents a broken test run from blocking deploys.
- Scale on queue depth using the [buildkite-agent-metrics](/docs/agent/self-hosted/monitoring-and-observability#buildkite-agent-metrics-cli) tool to drive your scaler. Target a p95 queue wait time under 60 seconds.
- Cache dependencies and build outputs in object storage. See [Caching best practices](/docs/pipelines/best-practices/caching) for patterns.
- Standardize on a base agent image with shared tooling, so agents do not install dependencies on every boot.
- Use [agent hooks](/docs/agent/hooks) to inject secrets, configure the environment, and enforce policy.

The following example queue layout separates workloads by compute profile and credential access:

| Queue | Job types | Agent notes |
| ----- | --------- | ----------- |
| `test` | Unit tests, integration tests, linting | Auto-scaled, no production credentials |
| `build` | Container image builds, artifact compilation | Auto-scaled, access to your registry |
| `deploy` | Staging and production deployments | Small pool, production role attached |
{: class="responsive-table"}

### When to move beyond the Growth pattern

Consider the Scale pattern when you see any of the following recurring conditions:

- Test parallelism demands exceed what one uniform agent pool can absorb cost-effectively.
- Different teams need different agent environments, such as mobile builds, ML training jobs, or ARM64.
- Queue wait times keep climbing despite larger VMs and higher scaling limits.
- Compliance requirements demand stricter isolation between workload types.
- Your platform team spends significant time managing the agent fleet.

## Scale pattern

The Scale pattern suits organizations with diverse workloads, stronger compliance requirements, and a dedicated platform team. Different job types run in agent pools designed for their compute, toolchain, and isolation requirements.

### Recommended setup

- Move agents into containers. Use the Buildkite agent Docker image as a base, and build per-workload images that include the toolchain for each job class.
- Run agents on demand through a container scheduler, such as Amazon ECS, Nomad, or a managed Kubernetes cluster. Map each job type to a specific task definition or container spec.
- Design queues around job characteristics, not team ownership. Team-specific queues fragment the pool and reduce utilization, so own the queue taxonomy at the platform level.
- Run a dedicated cache layer. At this volume, object storage round-trips add up, so combine a shared network file system mount for workspace-local caches with object storage for broader artifacts.
- Use [agent tags](/docs/agent/queues) to route jobs to specific capabilities, such as a queue, architecture, or GPU requirement. This gives pipeline authors a declarative interface without knowing the underlying infrastructure.
- Introduce pipeline templates or step libraries to prevent a proliferation of per-team agent configurations.
- Export structured build metrics. At this scale, identifying systemic slowdowns requires data you cannot eyeball. See [Monitoring and observability best practices](/docs/pipelines/best-practices/monitoring-and-observability).

A layered agent image hierarchy can reduce maintenance work. Define a base image with shared security and monitoring tooling, then build job-class images from it.

| Image layer | Contents | Rebuild cadence |
| ----------- | -------- | --------------- |
| `agent-base` | Agent binary, certificates, monitoring agents, shell config | Weekly or on patches |
| `agent-test` | Common test dependencies and language runtimes | Weekly or on dependency updates |
| `agent-deploy` | Deployment CLIs, with production credentials injected at runtime | Weekly |
| `agent-security` | Security scanners, network-isolated by the scheduler | Weekly |
{: class="responsive-table"}

### When to move beyond the Scale pattern

Consider the Enterprise pattern when you see any of the following recurring conditions:

- You run agents across multiple cloud regions or on-premises data centers.
- Kubernetes is your standard compute substrate, and you want agents to live natively in it.
- You need pod-level isolation between job executions for compliance, such as SOC 2, FedRAMP, or HIPAA.
- Build infrastructure cost is a meaningful line item, and you need per-team or per-project cost attribution.
- Your platform team runs agent infrastructure as a product, with SLAs and an internal customer base.

## Enterprise pattern

The Enterprise pattern suits large or regulated organizations that operate multi-cloud, hybrid, or multi-region infrastructure. It uses multiple Kubernetes clusters and requires a dedicated platform engineering function. This design supports high throughput, per-job isolation, regional resilience, and detailed cost controls at the cost of greater operational complexity.

### Recommended setup

- Deploy the [Agent Stack for Kubernetes](/docs/agent/self-hosted/agent-stack-k8s) into each cluster. Rather than running long-lived agents that poll for jobs, the stack runs a dedicated pod per job and tears it down on completion. This delivers per-job isolation and integrates with Kubernetes RBAC, network policies, and service accounts.
- Right-size nodes for actual job resource requests using a node provisioner such as Karpenter or the Cluster Autoscaler. Avoid over-provisioning for theoretical worst-case job sizes.
- Run spot or preemptible instances for stateless test workloads, which are typically 70–85% of build volume. Reserve on-demand capacity for deploy agents and jobs with strict SLAs, and configure automatic retries so jobs survive instance interruptions. See the [agent lifecycle](/docs/agent/lifecycle) for graceful termination.
- Apply Kubernetes network policies to isolate job namespaces. Run security-sensitive jobs, such as credential rotation and production deployments, in dedicated namespaces with restricted egress.
- Bind cloud credentials to specific job service accounts using workload identity, such as IRSA on Amazon EKS or Workload Identity on Google GKE. Static credential injection is not acceptable at this tier.
- Deploy across multiple clusters in at least two regions, and define a primary queue and a fallback queue for regional redundancy.
- Run a build observability stack that exports agent metrics, such as queue depth, job duration, and agent utilization, and define SLOs on build latency.
- Provide a self-service catalog of approved agent configurations, base images, and resource presets that teams select from. This prevents configuration sprawl while giving teams flexibility.

### Cost controls

The main cost controls at this scale are:

- Run spot or preemptible instances for stateless jobs, which typically reduce cost by 60–80% versus on-demand for test workloads.
- Right-size pod resource requests against historical job metrics, since bin-packing efficiency degrades when requests are over-specified.
- Cache aggressively. At 20,000+ daily builds, even a 10-minute average reduction in job duration compounds to hundreds of compute-hours per day.
- Attribute cost per team using Kubernetes labels and cloud cost allocation tags. Teams that see their build cost tend to optimize it.

## How should you apply these patterns

Do not treat these patterns as a required progression. Start with the least complex design that satisfies your workload, security, and reliability requirements. Adopt individual elements from another pattern when you can define the problem that the added component will solve.

Use recurring operational signals rather than one-off incidents to justify a change. Define a success criterion, such as reducing p95 queue wait time below 60 seconds or isolating production credentials from test jobs, before changing the architecture.

Use these questions to check the fit:

- Does one team run fewer than 200 similar builds each day? Start by evaluating the Starter pattern.
- Do queue contention or security boundaries affect a workload that is growing beyond 200 daily builds? Evaluate the Growth pattern.
- Do mobile, web, machine learning, or security workloads need different compute and a platform team manages the fleet? Evaluate the Scale pattern.
- Do Kubernetes, multi-region availability, per-job isolation, or compliance requirements shape the infrastructure? Evaluate the Enterprise pattern.
- Do several answers apply? Combine the relevant components, and keep queue ownership and security boundaries explicit.

For guidance that applies across all four patterns, see [Agent management best practices](/docs/pipelines/best-practices/agent-management).
