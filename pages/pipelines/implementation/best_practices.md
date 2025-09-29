# Best practices

This guide outlines recommended practices for designing, operating, and scaling Buildkite Pipelines effectively. It focuses on speed, reliability, and maintainability, while avoiding common pitfalls. Note that this guide assumes familiarity with the common [terms and notions](/docs/pipelines/glossary) and understanding the [principles of operation of the Buildkite Pipelines](/docs/pipelines/architecture) platform.

> 📘 For in-depth information on enforcing Buildkite security controls, see [Enforcing security controls](/docs/pipelines/security/enforcing-security-controls).

## Architecture and ownership

### Overall ownership

Define clear boundaries of ownership. CI/CD works best if the supporting team is able to control their application pipeline, with supporting tooling brought in to meet GRC standards.

### Agents, queues, and clusters

[Buildkite Agents](/docs/agent/v3) are a core element of Buildkite's ability to deliver massive [parallelization](/docs/pipelines/tutorials/parallel-builds) at scale. The way you configure and set up your agents and [clusters](/docs/pipelines/clusters) can have a huge impact on the security and reliability of your overall systems. The following sub-section cover the suggested approach.

#### Queue by function, cluster by responsibility

The recommended way of configuring your Buildkite Cluster is as follows:

* Use one default queue for uploading initial pipelines.
* Used Task-specific queues grouped by operational function (Terraform IaC, test runners, application deployment, etc.).

#### Keep a mix of static and autoscaling agents

If you want to maximize your pipelines' efficiency, you should keep one or two small instances around to handle the initial pipeline upload in your default queue. This will speed up your initial pipelines and allow the autoscaler to properly scale up as jobs are added to the pipeline. Once the jobs are processed, they should be handed off to dedicated [cluster queues](/docs/pipelines/clusters#clusters-and-queues-best-practices-how-should-i-structure-my-queues) that are geared towards handling those specific tasks.

#### Establish a cached image for your agents

If you are truly operating at a large scale, you need a set of cached agent images. For smaller organizations supporting one application, you may just need one. However, you may also have multiple images depending on your needs. It is recommended to keep only the tooling that you need to execute a specific function on a specific queue image.

For example, a "security" image could have ClamAV, trivy, Datadog's Guarddog, Snyk, and other tooling installed. Try to avoid having a single image containing all of your tooling and dependencies - keep them tightly scoped. You may want to build nightly to take advantage of automatically caching dependencies to speed up your builds, including system, framework, and image updates in Buildkite Packages, or publish to an AWS AMI, etc. This eliminates the potential for you to hit rate limits with high-scaling builds.

#### Use ephemeral agents

Builds should be air-tight, and not share any kind of state or assets with other builds. Using cached images as described in the previous section helps eliminate the necessity of sharing filesystems between services that could cause contention or a dirty cache.

Managing ephemeral infrastructure can be tough, and so we've [made it easy with Buildkite Hosted Agents](https://buildkite.com/docs/pipelines/hosted-agents/linux#agent-images-create-an-agent-image). With hosted agents, you can automatically include caches of your Git repository and any cached volumes for data that must be shared between services or runs.

#### Utilize agent hooks in your architecture

[Buildkite Agent hooks](/docs/agent/v3/hooks) can be very useful in structuring a pipeline. Instead of requiring all the code to be included in every repository, you can use lifecycle hooks to pull down different repositories, allowing you to create guardrails and reusable, immutable pieces of your pipeline for every job execution. They're a critical tool for compliance-heavy workloads and help to automate any setup or teardown functions necessary when running jobs.

## Pipeline design and structure

### Keep pipelines focused and modular

- Start with static pipelines and gradually move to dynamic pipelines to generate steps programmatically. They latter scale better than static YAML as repositories and requirements grow.
- Use `buildkite-agent pipeline upload` to generate steps programmatically based on code changes. This allows conditional inclusion of steps (e.g., integration tests only when backend code changes). (Further work: reword as `buildkite-agent pipeline upload` does not generate steps programmatically.)
- Separate concerns: Split pipelines into testing, building, and deployment flows. Avoid single, monolithic pipelines.
- Use pipeline templates: Define reusable YAML templates for common workflows (linting, testing, building images).

### Use monorepos for change scoping

- Run only what changed. Use a monorepo diff strategy, agent `if_changed`, or official plugins to selectively build and test affected components.
- Two common patterns:
    + One orchestrator pipeline that triggers component pipelines based on diffs.
    + One dynamic pipeline that injects only the steps needed for the change set.

### Prioritize fast feedback loops

- Parallelize where possible: run independent tests in parallel to reduce overall build duration.
- Fail fast: place the fastest, most failure-prone steps early in the pipeline.
- Use conditional steps: skip unnecessary work by using branch filters and step conditions.
- Smart test selection: use test impact analysis or path-based logic to run only the relevant subset of tests.

### Structure YAML for clarity

- Descriptive step names: step labels should be human-readable and clear at a glance.
- Organize with groups: use group steps to keep complex pipelines navigable.
- Emojis for visual cues: quick scanning is easier with consistent iconography.
- Comment complex logic: document non-obvious conditions or dependencies inline.

### Standardize with reusable modules

- Centralized templates: maintain organization-wide pipeline templates and plugins to enforce consistency across teams.
- Shared libraries: package common scripts or Docker images so individual teams don’t reinvent solutions.

## Agent management

### Right-size your agent fleet

- Monitor queue times: Long wait times often mean you need more capacity. You can use cluster insights to monitor queue wait times.
- Autoscale intelligently: Use cloud-based autoscaling groups to scale with demand (using Elastic CI Stack for AWS - and soon-to-be-supported GCP - can help you with auto-scaling).
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

### Avoid snowflake agents

- No manual tweaks: Avoid one-off changes to long-lived agents; enforce everything via code and images.
- Immutable patterns: Use infrastructure-as-code and versioned images for consistency and reproducibility.

Alternatively: Enforce agent configuration and infrastructure using IaC (Infrastructure as code) where possible.

## Environment and dependency management

### Containerize builds for consistency

- Docker-based builds: Ensure environments are reproducible across local and CI.
- Efficient caching: Optimize Dockerfile layering to maximize [cache reuse](https://docs.docker.com/build/cache/).
- [Multi-stage builds in Docker](https://docs.docker.com/build/building/multi-stage/): Keep images slim while supporting complex build processes.
- Pin base images: Avoid unintended breakage from upstream changes.

### Handle dependencies reliably

- Lock versions: Use lockfiles and pin versions to ensure repeatable builds (you can also [pin plugin versions](/docs/pipelines/integrations/plugins/using#pinning-plugin-versions)).
- Cache packages: Reuse downloads where possible to reduce network overhead.
- Validate integrity: Use checksums or signatures to confirm dependency authenticity.



## Monitoring and observability

### Logging best practices

- Structured logs: Favor JSON or other parsable formats. Use [log groups](/docs/pipelines/configure/managing-log-output#grouping-log-output) for better visual representation of the relevant sections in the logs.
- Appropriate log levels: Differentiate between info, warnings, and errors.
- Persist artifacts: Store logs, reports, and binaries for debugging and compliance.
- Track trends: Use [cluster insights](/docs/pipelines/insights/clusters) or external tools to analyze durations and failure patterns.
- Avoid having log files that are too large. Large log files make it harder to troubleshoot the issues and are harder to manage in the Buildkite Pipelines' UI.
To avoid overly large log files, try to not use verbose output of apps and tools unless needed. See also [Managing log output](docs/pipelines/configure/managing-log-output#log-output-limits).

### Set relevant alerts

- Failure alerts: Notify responsible teams for failing builds (relevant links will be added here).
- Queue depth monitoring: Detect bottlenecks when builds queue too long - you can make use of the [Queue insights for this](/docs/pipelines/insights/queue-metrics).
- Agent health alerts: Trigger alerts when agents go offline or degrade. If individual agent health is less of a concern, then terminate an unhealthy instance and spin a new one.

## Telemetry operational tips

- Start where the pain is: profile queue wait and checkout time first. These are often the biggest, cheapest wins.
- Tag everything: include pipeline, queue, repo path, and commit metadata in spans and events to make drill‑downs trivial.
- Keep one source of truth: stream Buildkite to your standard observability stack so platform‑level SLOs and alerts live alongside app telemetry.
- Document the path: publish internal guidance for teams on reading the Pipeline metrics page and where to find org dashboards.

### Quick checklist for using telemetry

- Enable EventBridge and subscribe your alerting pipeline.
- Turn on OTEL export to your collector. Start with job spans and queue metrics.
- If you are a Datadog shop, enable agent APM tracing.
- Stand up a “CI SLO” dashboard with p95 queue wait and build duration per top pipelines.
- Document and socialize how developers should use the Pipeline metrics page for day‑to‑day troubleshooting.

### Core pipeline telemetry recommendations

Establish standardized metrics collection across all pipelines to enable consistent monitoring and analysis:

- **Build duration metrics**: track build times by pipeline, step, and queue to identify performance bottlenecks.
- **Queue wait times**: monitor agent availability and scaling efficiency across different workload types.
- **Failure rate analysis**: measure success rates by pipeline, branch, and time period to identify reliability trends.
- **Retry effectiveness**: track retry success rates by exit code to validate retry policy effectiveness.
- **Resource utilization**: monitor compute usage, artifact storage, and network bandwidth consumption.

Standardize the number of times test flakes are retried and have their custom exit statuses that you can report on with your telemetry provider. Use [OpenTelemetry integration](/docs/pipelines/integrations/observability/opentelemetry#opentelemetry-tracing-notification-service) to gain deep visibility into pipeline execution flows

### Use analytics for improvement

- Key metrics: Monitor build duration, throughput, and success rate (a mention of OTEL integration and queue insights that can help do this will be added here).
- Bottleneck analysis: Identify slowest (using the OTEL integration) steps and optimize them.
- Failure clustering: Look for repeated error types.

## Security best practices

### Manage secrets properly

- Native secret management: Use [Buildkite secrets and redaction](/docs/pipelines/security/secrets/buildkite-secrets) and [secrets plugins](https://buildkite.com/docs/pipelines/integrations/plugins/directory).
- Rotate secrets: Regularly update credentials to minimize risk.
- Limit scope: Expose secrets only to the steps that require them. See more in [Buildkite Secrets](/docs/pipelines/security/secrets/buildkite-secrets#use-a-buildkite-secret-in-a-job) and [vault secrets plugin](https://buildkite.com/resources/plugins/buildkite-plugins/vault-secrets-buildkite-plugin/).
- Audit usage: Track which steps consume which secrets.

### Enforce access controls

- Team-based access: Grant permissions per team and specific team needs (read-only or write permissions). See [Teams permissions](/docs/platform/team-management/permissions).
- Branch protections: Limit edits to sensitive pipelines.
- Permission reviews: Audit permissions on a regular basis.
- Use SSO/SAML: Centralize authentication and improve compliance.

### Governance and compliance
- Policy-as-code: Define and enforce organizational rules (e.g., required steps, approved plugins).
- Audit readiness: Retain logs, artifacts, and approvals for compliance reporting.
- Sandbox pipelines: Provide safe environments to test changes without impacting production.

## Patterns and anti-patterns

### Effective patterns

#### Wait steps for coordination

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

#### Graceful error handling

Use `soft_fail` where failures are acceptable, but document why:

```yaml
steps:
  - label: ":test_tube: Optional integration tests"
    command: "make integration-tests"
    soft_fail: true
  - label: ":white_check_mark: Required unit tests"
    command: "make unit-tests"
```

#### Use block steps for approvals

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

#### Canary releases in CI/CD

Model partial deployments and staged rollouts directly in pipelines. See more in [Deployments](/docs/pipelines/deployments).

#### Pipeline-as-code reviews

Require peer reviews for pipeline changes, just like application code.

#### Chaos testing

Periodically inject failure scenarios (e.g., failing agents, flaky dependencies) to validate pipeline resilience.

### Anti-patterns to avoid

#### Hard-coding environment values

Instead, inject via environment variables or pipeline metadata:

```yaml
# ❌ Bad
command: "deploy.sh https://api.myapp.com/prod"

# ✅ Good
command: "deploy.sh $API_ENDPOINT"
env:
  API_ENDPOINT: "https://api.myapp.com/prod"
```

#### Overloaded single steps

Avoid cramming unrelated tasks into one step, for example:

```
# ❌ Bad - Mixing unrelated concerns
- label: "Build and security scan and deploy"
  command: |
    docker build -t myapp .
    trivy image myapp
    docker push myapp:latest
    kubectl apply -f k8s/deployment.yaml

# ✅ Good - Separate logical concerns
- label: ":docker: Build application"
  command: "docker build -t myapp ."

- label: ":shield: Security scan"
  command: "trivy image myapp"
  depends_on: "build"

- label: ":rocket: Deploy to production"
  command: |
    docker push myapp:latest
    kubectl apply -f k8s/deployment.yaml
  depends_on:
    - "build"
    - "security-scan"
```

The "bad" example crams together building, security scanning, and deployment which are three totally different concerns that you'd want to handle separately, potentially with different permissions, agents, and failure handling strategies.

Cramming more tasks into one step reduces the ability of the pipeline to scale and take advantage of multiple agents.
Splitting steps makes it logically easier to understand and also takes advantage of Buildkite's scalable agents.
Also makes it easier to troubleshoot when something breaks in the pipeline.
Maybe a note about how Buildkite artifacts could be used to "cache" common data between steps.

#### Controlled parallelism and concurrency

Balance parallel execution for speed while managing resource consumption and costs:

**Step-level parallelism (`parallelism` attribute):**

- Set reasonable limits on the `parallelism` attribute for individual steps based on your agent capacity.
- Consider that each parallel job consumes an agent, so `parallelism: 50` requires 50 available agents.
- Monitor queue wait times when using high parallelism values to ensure adequate agent availability.

**Build-level concurrency:**

- While running jobs in parallel across different steps speeds up builds, be mindful of your total agent pool capacity.
- Buildkite has default limits on concurrent steps per build to prevent resource exhaustion.
- Design pipeline dependencies (`wait` steps) to balance speed with resource availability.

**Example of controlled parallelism:**
```yaml
steps:
  - label: "Unit Tests"
    command: npm test
    parallelism: 10  # Reasonable for most agent pools

  - wait

  - label: "Integration Tests"
    command: npm run test:integration
    parallelism: 5   # Lower parallelism for resource-intensive tests
```

#### Silent failures

Never ignore failing steps without a clear follow-up.

## Enabling developers

### Self-service pipelines

- Curated templates: Allow teams to adopt pipelines without deep Buildkite expertise.
- Golden paths: Document and promote recommended workflows to reduce cognitive load.
- Feedback loops: Encourage engineers to propose improvements or report issues.

## Scaling practices

- Workload segmentation: Split pipelines across projects or repositories to reduce contention.
- Cross-team dashboards: Give stakeholders visibility into bottlenecks and throughput.
- Cost optimization: Track agent utilization and cloud spend to balance speed with efficiency.

## Common pitfalls to avoid

- Overly restrictive defaults: Start permissive, then refine.
- Ignoring developer input: CI/CD should enable instead of blocking velocity.
- Skipping observability early: Add metrics and logging from day one.
- Treating pipelines as secondary: Invest in CI/CD as critical infra.
- Not planning for scale: Design for higher volume and parallelism.
- Poor documentation: Document patterns, conventions, and playbooks.
- Unverified pipeline changes: Test modifications in sandbox pipelines first.
- Neglecting build performance: Regularly optimize for faster cycles.

## Conclusion

Buildkite pipelines are most effective when treated as living systems: modular, observable, secure, and developer-friendly. Invest in clarity, speed, and automation from the start, and continuously refine based on developer feedback and scaling needs.
