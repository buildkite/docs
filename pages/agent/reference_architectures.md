---
description: "Compare four practical reference architecture patterns for Buildkite agent infrastructure, from a small initial setup to a multi-cluster enterprise fleet."
---

# Buildkite agent reference architectures

This page compares four reference architecture patterns for running [Buildkite agents](/docs/agent), from a small initial setup to a multi-cluster enterprise fleet. Each pattern describes a typical combination of agent compute, queues, caching, workload isolation, and operational ownership.

The _Starter_, _Growth_, _Scale_, and _Enterprise_ names are convenience labels used only on this page. They are not official Buildkite architecture names, product tiers, or required stages. Your architecture can combine elements from more than one pattern.

Choose the simplest pattern that meets your current requirements. Add complexity when recurring queue delays, workload conflicts, security boundaries, or fleet management work show that the current design no longer fits.

[Buildkite hosted agents](/docs/agent/buildkite-hosted) fit into every pattern. In a small setup, they can replace self-managed CI infrastructure entirely. In larger setups, they run alongside self-hosted agents and take on workloads such as macOS builds or extra capacity.

## Which reference architecture should you choose

Use build volume and team size as initial indicators, then make the decision based on workload diversity, isolation requirements, and operational capacity:

- **[Starter](#starter-pattern):** Use Buildkite hosted agents, one VM, or a small auto-scaling group when one team has similar workloads and needs little infrastructure specialization.
- **[Growth](#growth-pattern):** Add separate queues and shared caching, running on Buildkite hosted agents or auto-scaled VMs, when queue contention or different credential boundaries become recurring concerns.
- **[Scale](#scale-pattern):** Use workload-specific agent pools and centralized fleet management when teams need different operating systems, architectures, accelerators, or compliance controls.
- **[Enterprise](#enterprise-pattern):** Use multi-cluster Kubernetes infrastructure, with Buildkite hosted agents for the workloads they suit, when you need per-job isolation, regional resilience, detailed cost attribution, or platform-level service objectives.

Treat these recommendations as starting points rather than thresholds. A smaller organization with regulated workloads might need stronger isolation, while a larger organization with uniform workloads might not need Kubernetes.

## Architecture comparison

The following ranges show the environments that each pattern commonly fits. They are guides, not limits or Buildkite service requirements.

| Dimension | Starter | Growth | Scale | Enterprise |
| --------- | ------- | ------ | ----- | ---------- |
| **Team size** | 1–15 engineers | 15–60 engineers | 60–250 engineers | 250+ engineers |
| **Daily builds** | Under 200 | 200–2,000 | 2,000–20,000 | 20,000+ |
| **Agent compute** | Buildkite hosted agents or a single VM | Buildkite hosted agents or auto-scaled VMs | Hosted and self-hosted pools per workload | Kubernetes clusters alongside Buildkite hosted agents |
| **Queue strategy** | Single queue | 2–3 queues | Per-workload queues | Dynamic routing with tags |
| **Caching** | Built-in caching | Buildkite Cache | Buildkite Cache and Git mirrors | Buildkite Cache, persistent volumes, and remote Git mirrors |
| **Operational complexity** | Low | Moderate | High | Very high |
{: class="responsive-table"}

## Should your agents be ephemeral or persistent

Decide early whether each workload needs a clean environment for every job, or local state that persists between jobs. This choice affects which compute options fit, whichever pattern you use.

- **Ephemeral agents:** Each job runs in a fresh environment that is destroyed when the job finishes. Choose ephemeral agents when you want clean, reproducible builds with no state carried between jobs and a shorter window for an attacker to compromise the build environment. Buildkite hosted agents are always [ephemeral](/docs/agent/buildkite-hosted#how-buildkite-hosted-agents-work), and the [Agent Stack for Kubernetes](/docs/agent/self-hosted/agent-stack-k8s) runs each job in its own pod. To avoid starting each job cold, restore dependencies with [Buildkite Cache](/docs/pipelines/configure/cache) or, on hosted agents, [cache volumes](/docs/agent/buildkite-hosted/cache-volumes).
- **Persistent agents:** Agents keep local state, such as build outputs, disk caches, and checkouts, between jobs. Build systems such as Bazel and Pants rely on this state for fast incremental builds. Choose persistent agents when rebuilding or restoring that state for every job costs more time than it saves.

Buildkite hosted agents are designed for ephemeral workloads. Cache volumes carry data between hosted jobs on a best-effort basis, but they don't guarantee the warm local state that tools such as Bazel and Pants expect. Run these workloads on self-hosted agents that keep their state between jobs, and route them to their own queue. For example, instances in the [Elastic CI Stack for AWS](/docs/agent/self-hosted/aws/elastic-ci-stack) keep running between jobs until the stack scales in, unless you [terminate each instance after its job](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/managing-elastic-ci-stack#terminating-the-instance-after-the-job-is-complete). Pair persistent agents with a remote cache, so that a replacement instance doesn't start cold. See [Bazel caching](/docs/pipelines/best-practices/caching#bazel-caching) for remote cache options.

## Starter pattern

The Starter pattern suits a single team with similar workloads and limited isolation requirements. It prioritizes a small operational footprint over specialized routing or high throughput.

Avoid adding Kubernetes, multiple queues, or custom hooks before the workload requires them. A flat setup is easier to operate and diagnose.

### Recommended setup

- Start with Buildkite hosted agents, so you don't need to provision, scale, or upgrade CI infrastructure. If you self-host, begin with a single VM or a small auto-scaling group of one to four general-purpose agents. The [Elastic CI Stack for AWS](/docs/agent/self-hosted/aws/elastic-ci-stack) provides a starting point on AWS.
- Use a single default [queue](/docs/agent/queues). Do not segment queues at this stage, since the added complexity outweighs the benefit.
- Store secrets as [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets) or in a lightweight cloud secret store.
- If dependency installs slow your builds, use the caching built into Buildkite rather than running your own cache infrastructure. Buildkite hosted agents support [cache volumes](/docs/agent/buildkite-hosted/cache-volumes), and [Buildkite Cache](/docs/pipelines/configure/cache) works on both hosted and self-hosted agents. Hosted agents receive a Buildkite Cache store automatically, with no storage to configure.

### When to move beyond the Starter pattern

Consider the Growth pattern when you see any of the following recurring conditions:

- Build queue wait times regularly exceed two to three minutes.
- A single flaky or runaway job can block the whole team.
- You need to separate deployment jobs from test jobs for security or compliance.
- You run more than one language or platform stack, and agents need different toolchains.

## Growth pattern

The Growth pattern suits multiple teams that need more capacity or clearer workload boundaries. It adds auto-scaling, queue segmentation, and caching without requiring a container scheduler.

### Recommended setup

- Scale agents with demand rather than running them always-on. Buildkite hosted agents scale automatically, so you don't need to run an autoscaler. If you self-host, deploy auto-scaling as a first-class concern, so agents start in response to queue depth and terminate after an idle period. The [Elastic CI Stack for AWS](/docs/agent/self-hosted/aws/elastic-ci-stack) provides this out of the box, or you can use an equivalent module for another cloud.
- Introduce two to three named [queues](/docs/agent/queues). Separate test jobs from deploy jobs at minimum, so a broken test run cannot block deploys. Each Buildkite hosted queue has its own instance shape, so you can size each queue for its workload.
- Do not rely on queues alone to protect production credentials. A queue routes jobs, but any pipeline in the same [Buildkite cluster](/docs/pipelines/security/clusters) can target it. Jobs in the same cluster can also, by default, use their [job tokens](/docs/agent/self-hosted/tokens#additional-agent-tokens-job-tokens) to read and write each other's metadata, annotations, and artifacts. Run deploy agents in a separate cluster that contains only trusted deployment pipelines, or use [OIDC](/docs/pipelines/security/oidc) with a trust policy that only accepts tokens from your deployment pipelines.
- For self-hosted agents, scale on queue depth using the [buildkite-agent-metrics](/docs/agent/self-hosted/monitoring-and-observability#buildkite-agent-metrics-cli) tool to drive your scaler. Target a p95 queue wait time under 60 seconds.
- Cache dependencies with [Buildkite Cache](/docs/pipelines/configure/cache), which requires Buildkite agent v4.0.3 or later and stores entries in an Amazon S3 or S3-compatible bucket that you provide for self-hosted agents. Use [build artifacts](/docs/pipelines/configure/artifacts) for build outputs that later jobs need. See [Choosing a caching approach](/docs/pipelines/best-practices/caching#choosing-a-caching-approach) to compare the options.
- Standardize on a base agent image with shared tooling, so agents do not install dependencies on every boot. On Linux hosted agents, build this as a [custom agent image](/docs/agent/buildkite-hosted/linux/custom-agent-images).
- Use [agent hooks](/docs/agent/hooks) to inject secrets, configure the environment, and enforce policy.

The following example queue layout separates workloads by compute profile and credential access:

| Queue | Job types | Agent notes |
| ----- | --------- | ----------- |
| `test` | Unit tests, integration tests, linting | Auto-scaled, no production credentials |
| `build` | Container image builds, artifact compilation | Auto-scaled, access to your registry |
| `deploy` | Staging and production deployments | Small pool, production credentials scoped to trusted deployment pipelines |
{: class="responsive-table responsive-table--nowrap-first-column"}

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

- Give each job class its own agent pool and queue, scaled independently. Use Buildkite hosted queues for workloads that suit ephemeral agents, and self-hosted pools for workloads that need persistent state, private network access, or hardware that hosted agents don't offer.
- Package each job class's toolchain as a container image, and select it with the `image` attribute on [Linux hosted agents](/docs/agent/buildkite-hosted/linux/custom-agent-images#use-an-agent-image-specify-an-image-in-your-pipeline-yaml) or the [Agent Stack for Kubernetes](/docs/agent/self-hosted/agent-stack-k8s/custom-images#specifying-custom-images-using-the-image-attribute). Both run the job's commands directly in your image and supply the Buildkite agent, so you don't need to install the agent in your images or set up Docker-in-Docker to run a containerized toolchain.
- Run macOS and iOS builds on [macOS hosted agents](/docs/agent/buildkite-hosted/macos) rather than maintaining your own Mac fleet. New Xcode versions, including beta and release candidate versions, are available on macOS hosted agents [one week after Apple releases them](/docs/agent/buildkite-hosted/macos#macos-instance-software-support).
- Design queues around job characteristics, not team ownership. Team-specific queues fragment the pool and reduce utilization, so own the queue taxonomy at the platform level.
- Use Buildkite Cache as your shared dependency cache rather than running your own cache service. [Cache registries and policies](/docs/pipelines/configure/cache#manage-cache-registries) control which pipelines, branches, and builds can save or restore entries, so you can stop untrusted builds from replacing cache entries that trusted builds restore.
- Speed up checkouts of large repositories with [Git mirrors](/docs/agent/self-hosted/configure/git-mirrors) on self-hosted agents and [Git mirror volumes](/docs/agent/buildkite-hosted/cache-volumes#git-mirror-volumes) on hosted agents. See [Git checkout optimization](/docs/pipelines/best-practices/git-checkout-optimization) to compare Git mirrors with shallow clones and sparse checkout.
- Use a [secrets manager](/docs/pipelines/security/secrets/managing) with separate IAM roles or service accounts for each workload-specific agent pool. Because any pipeline in a Buildkite cluster can target any of its queues, also scope each role's trust policy to the pipelines that need it, for example with [OIDC](/docs/pipelines/security/oidc) claims, or place pools with privileged credentials in a separate cluster.
- Use [agent tags](/docs/agent/queues) to route jobs to specific capabilities, such as a queue, architecture, or GPU requirement. This gives pipeline authors a declarative interface without knowing the underlying infrastructure.
- Introduce [pipeline templates](/docs/pipelines/governance/templates) or step libraries to prevent a proliferation of per-team agent configurations.
- Export structured build metrics. At this scale, identifying systemic slowdowns requires data you cannot eyeball. See [Monitoring and observability best practices](/docs/pipelines/best-practices/monitoring-and-observability).

A layered image hierarchy can reduce the maintenance work for these toolchain images. Define a base image with shared security and monitoring tooling, then build job-class images from it.

| Image layer | Contents | Rebuild cadence |
| ----------- | -------- | --------------- |
| `ci-base` | Certificates, monitoring agents, shell config | Weekly or on patches |
| `ci-test` | Common test dependencies and language runtimes | Weekly or on dependency updates |
| `ci-deploy` | Deployment CLIs, with production credentials injected at runtime | Weekly |
| `ci-security` | Security scanners, network-isolated by the scheduler | Weekly |
{: class="responsive-table"}

### When to move beyond the Scale pattern

Consider the Enterprise pattern when you see any of the following recurring conditions:

- You run agents across multiple cloud regions or on-premises data centers.
- Kubernetes is your standard compute substrate, and you want agents to live natively in it.
- You need pod-level isolation between job executions for compliance, such as SOC 2, FedRAMP, or HIPAA.
- Build infrastructure cost is a meaningful line item, and you need per-team or per-project cost attribution.
- Your platform team runs agent infrastructure as a product, with SLAs and an internal customer base.

## Enterprise pattern

The Enterprise pattern suits large or regulated organizations that operate multi-cloud, hybrid, or multi-region infrastructure. It uses multiple Kubernetes clusters, typically alongside Buildkite hosted agents, and requires a dedicated platform engineering function. This design supports high throughput, per-job isolation, regional resilience, and detailed cost controls at the cost of greater operational complexity.

### Recommended setup

- Deploy the Agent Stack for Kubernetes into each cluster. Rather than running long-lived agents that poll for jobs, the stack runs a dedicated pod per job and tears it down on completion. This delivers per-job isolation and integrates with Kubernetes RBAC, network policies, and service accounts. The stack also uses [job acquisition tokens](/docs/agent/self-hosted/job-acquisition-tokens) by default, so job pods receive a short-lived, single-job registration credential instead of the long-lived agent token.
- Size each Agent Stack for Kubernetes controller for your peak job volume. By default, a controller has at most 25 jobs in flight at a time, set by its `max-in-flight` [flag](/docs/agent/self-hosted/agent-stack-k8s/controller-configuration#flags). Load test each controller at your expected peak before moving high-volume queues to it. See [Controller stops accepting new jobs from a queue](/docs/agent/self-hosted/agent-stack-k8s/troubleshooting#common-issues-and-fixes-controller-stops-accepting-new-jobs-from-a-queue) for how to recognize and raise this limit.
- Use Buildkite hosted agents to augment your self-hosted fleet or fill gaps in it, such as macOS builds or extra capacity for bursty workloads, without provisioning more infrastructure. Hosted agents request the same Buildkite OIDC tokens as self-hosted agents, so hosted jobs can access your AWS, Google Cloud, or Azure resources without static credentials. If your internal firewalls allowlist source IP addresses, contact Buildkite Support to request [dedicated static IP addresses](/docs/agent/buildkite-hosted/network-security#buildkite-hosted-agent-ip-address-ranges) for your hosted agents. Keep workloads that require a zero-trust build environment on self-hosted agents, as described in [Build infrastructure segmentation best practices](/docs/agent/buildkite-hosted/network-security#considerations-build-infrastructure-segmentation-best-practices).
- Right-size nodes for actual [job resource requests](/docs/agent/self-hosted/agent-stack-k8s/container-resource-limits) using a node provisioner such as Karpenter or the Cluster Autoscaler. Avoid over-provisioning for theoretical worst-case job sizes.
- Run spot or preemptible instances for stateless test workloads, which are typically 70–85% of build volume. Reserve on-demand capacity for deploy agents and jobs with strict SLAs. Configure [automatic retries](/docs/pipelines/configure/retry#retry-attributes-automatic-retry-attributes) so jobs survive instance interruptions. See the [agent lifecycle](/docs/agent/lifecycle) for graceful termination.
- Apply Kubernetes network policies to isolate job namespaces. Run security-sensitive jobs, such as credential rotation and production deployments, in dedicated namespaces with restricted egress.
- Bind cloud credentials to specific job service accounts using workload identity, such as IRSA on Amazon EKS or Workload Identity on Google GKE. Static credential injection is not acceptable at this tier. By default, a pipeline's `kubernetes` plugin can override the controller's pod spec, including `serviceAccountName`, so enable [`prohibit-kubernetes-plugin`](/docs/agent/self-hosted/agent-stack-k8s/securing-the-stack) or an admission policy that allowlists service accounts on any stack that exposes privileged identities.
- Use Buildkite Cache for dependency caching in each cluster, with separate cache registries and policies for workloads that must not share cache entries. For workloads that need warm local state, such as Bazel builds, use [persistent volume mounts](/docs/agent/self-hosted/agent-stack-k8s/volume-mounts) together with a remote build cache. Use object storage for build artifacts.
- Reduce clone traffic to your Git host with a remote clone mirror. For example, you can keep GitHub as the source of truth and build trigger, while jobs fetch commits from an [Origin clone mirror](/docs/pipelines/source-control/origin#use-origin-as-a-clone-mirror-for-github) and fall back to GitHub when a commit isn't available. This helps pipelines that create many jobs from a single push. Clone mirrors must be enabled for your Buildkite organization.
- Deploy across multiple clusters in at least two regions. Jobs target a single queue, and automatic retries keep that queue, so a separately named fallback queue does not pick up jobs when the primary region fails. Instead, run a controller in each region that polls the same critical queue, and give each controller installation a [distinct, stable controller ID](https://github.com/buildkite/agent-stack-k8s#multiple-independent-controllers-serving-the-same-queue).
- Run a build observability stack that exports agent metrics, such as queue depth, job duration, agent utilization, and cache misses, and define SLOs on build latency. Use the [waterfall view](/docs/pipelines/insights/waterfall) to investigate slow jobs and [Test Engine](/docs/pipelines/configure/tests) to identify slow or flaky tests that consume fleet capacity.
- Provide a self-service catalog of approved agent configurations, base images, and resource presets that teams select from. This prevents configuration sprawl while giving teams flexibility.

### Cost controls

The main cost controls at this scale are:

- Run spot or preemptible instances for stateless jobs, which typically reduce cost by 60–80% versus on-demand for test workloads.
- Right-size pod resource requests against historical job metrics, since bin-packing efficiency degrades when requests are over-specified.
- Cache aggressively. At 20,000+ daily builds, even a 10-minute average reduction in job duration compounds to hundreds of compute-hours per day.
- Include instance startup, idle, and shutdown time when you compare self-hosted and hosted costs. Self-hosted cloud instances usually accrue charges during these periods. Usage of Buildkite hosted agents is [billed in vCPU minutes of job runtime](/docs/agent/buildkite-hosted#why-use-buildkite-hosted-agents), excluding startup and shutdown periods, with no minimum charges. For fleets that run large numbers of short jobs, this overhead can be a material part of total compute cost.
- Attribute cost per team using Kubernetes labels and cloud cost allocation tags. Teams that see their build cost tend to optimize it. If you also run EC2-based agents with the Elastic CI Stack for AWS, see [Attributing AWS agent costs](/docs/pipelines/tutorials/attributing-aws-agent-costs) for a separate approach that correlates agent events with hourly instance pricing.

## How should you apply these patterns

Do not treat these patterns as a required progression. Start with the least complex design that satisfies your workload, security, and reliability requirements. Adopt individual elements from another pattern when you can define the problem that the added component will solve.

Use recurring operational signals rather than one-off incidents to justify a change. Define a success criterion, such as reducing p95 queue wait time below 60 seconds or isolating production credentials from test jobs, before changing the architecture.

Use these questions to check the fit:

- Does one team run fewer than 200 similar builds each day? Start by evaluating the Starter pattern.
- Do queue contention or security boundaries affect a workload that is growing beyond 200 daily builds? Evaluate the Growth pattern.
- Do mobile, web, machine learning, or security workloads need different compute, and does a platform team manage the fleet? Evaluate the Scale pattern.
- Do Kubernetes, multi-region availability, per-job isolation, or compliance requirements shape the infrastructure? Evaluate the Enterprise pattern.
- Do some builds depend on warm local state, such as Bazel or Pants caches? Run those builds on persistent self-hosted agents, as described in [Should your agents be ephemeral or persistent](#should-your-agents-be-ephemeral-or-persistent).
- Do several answers apply? Combine the relevant components, and keep queue ownership and security boundaries explicit.

Whichever pattern you choose, plan regular agent upgrades so your self-hosted fleet stays on a supported release line. Buildkite manages agent versions on hosted agents. See the [Buildkite agent version support policy](/docs/agent/version-support-policy) for support windows.

For guidance that applies across all four patterns, see [Agent management best practices](/docs/pipelines/best-practices/agent-management).
