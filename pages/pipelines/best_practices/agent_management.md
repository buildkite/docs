# Agent management

This page covers the best practices for effective management of Buildkite Agents.

## Right-size your agent fleet

* Monitor queue times: Long wait times often mean you need more capacity. You can use cluster insights to monitor queue wait times.
* Autoscale intelligently: Use cloud-based autoscaling groups to scale with demand (using Elastic CI Stack for AWS - and soon-to-be-supported GCP - can help you with auto-scaling).
* Specialized pools: Maintain dedicated pools for CPU-intensive, GPU-enabled, or OS-specific workloads.
* Graceful scaling: Configure agents to complete jobs before termination to prevent abrupt failures (Elastic CI Stack for AWS already has graceful scaling implemented. Also, if you are building your own AWS stack, you can use [Buildkite's lifecycle daemon](https://github.com/buildkite/lifecycled) for handling graceful termination and scaling).

### Optimize agent performance

* Use targeting and metadata: Route jobs to the correct environment using queues and agent tags.
* Implement caching: Reuse dependencies, build artifacts, and Docker layers to reduce redundant work. (Further work here: add a link to some of our cache plugins and highlight cache volumes for hosted agents. Also - potentially create a best practices section for self-hosted and hosted agents.)
* Pre-warm environments: Bake common tools and dependencies into images for faster startup.
* Monitor agent health: Continuously check for resource exhaustion and recycle unhealthy instances. Utilize agent pausing when resources are tied to the lifetime of the agent, such as a cloud instance configured to terminate when the agent exits. By pausing an agent, you can investigate problems in its environment more easily, without the worry of jobs being dispatched to it.

### Secure your agents

* Principle of least privilege: Provide only the permissions required for the job.
* Prefer ephemeral agents: Short-lived agents reduce the attack surface and minimize drift.
* Secret management: Use environment hooks or secret managers; never hard-code secrets in YAML.
* Keep base images updated: Regularly patch agents to mitigate security vulnerabilities.

Further work in this section: mention BK Secrets, suggest using external secret managers like AWS Secrets Manager or Hashicorp Vault. Potentially also link back to our own plugins, too.

### Avoid snowflake agents

* No manual tweaks: Avoid one-off changes to long-lived agents; enforce everything via code and images.
* Immutable patterns: Use infrastructure-as-code and versioned images for consistency and reproducibility.

Alternatively: Enforce agent configuration and infrastructure using IaC (Infrastructure as code) where possible.
