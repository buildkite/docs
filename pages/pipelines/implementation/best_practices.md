# Best practices

This guide outlines recommended practices for designing, operating, and scaling Buildkite Pipelines effectively. It focuses on speed, reliability, and maintainability, while avoiding common pitfalls.

> 📘 For in-depth information on enforcing Buildkite security controls, see [Enforcing security controls](/docs/pipelines/security/enforcing-security-controls).

## Architecture and ownership

- Prefer hybrid: keep code and secrets in your infrastructure. Use clusters and queues to create clear security and workload boundaries.
- Establish platform ownership for pipelines, agent fleets, secrets, and access. Route escalations to the platform team and maintain a single source of truth for the Buildkite organization and queues.

## Pipeline design and structure

### Keep pipelines focused and modular

- Default to dynamic pipelines to generate steps programmatically. They scale better than static YAML as repositories and requirements grow.
- Use `buildkite-agent pipeline upload` to generate steps programmatically based on code changes. This allows conditional inclusion of steps (e.g., integration tests only when backend code changes).
- Separate concerns: Split pipelines into testing, building, and deployment flows. Avoid single, monolithic pipelines.
- Use pipeline templates: Define reusable YAML templates for common workflows (linting, testing, building images).

### Use monorepos for change scoping

- Run only what changed. Use a monorepo diff strategy, agent `if_changed`, or official plugins to selectively build and test affected components.
- Two common patterns:
    + One orchestrator pipeline that triggers component pipelines based on diffs.
    + One dynamic pipeline that injects only the steps needed for the change set.

### Prioritize fast feedback loops

- Parallelize where possible: Run independent tests in parallel to reduce overall build duration.
- Fail fast: Place the fastest, most failure-prone steps early in the pipeline.
- Use conditional steps: Skip unnecessary work by using branch filters and step conditions.
- Smart test selection: Use test impact analysis or path-based logic to run only the relevant subset of tests.

### Structure YAML for clarity

- Descriptive step names: Step labels should be human-readable and clear at a glance.
- Organize with groups: Use group steps to keep complex pipelines navigable.
- Emojis for visual cues: Quick scanning is easier with consistent iconography.
- Comment complex logic: Document non-obvious conditions or dependencies inline.

### Standardize with reusable modules

- Centralized templates: Maintain organization-wide pipeline templates and plugins to enforce consistency across teams.
- Shared libraries: Package common scripts or Docker images so individual teams don’t reinvent solutions.

## Agent management

### Right-size your agent fleet

- Monitor queue times: Long wait times often mean you need more capacity.
- Autoscale intelligently: Use cloud-based autoscaling groups to scale with demand.
- Specialized pools: Maintain dedicated pools for CPU-intensive, GPU-enabled, or OS-specific workloads.
- Graceful scaling: Configure agents to complete jobs before termination to prevent abrupt failures.

### Optimize agent performance

- Use targeting and metadata: Route jobs to the correct environment using queues and agent tags.
- Implement caching: Reuse dependencies, build artifacts, and Docker layers to reduce redundant work.
- Pre-warm environments: Bake common tools and dependencies into images for faster startup.
- Monitor agent health: Continuously check for resource exhaustion and recycle unhealthy instances.

### Secure your agents

- Principle of least privilege: Provide only the permissions required for the job.
- Prefer ephemeral agents: Short-lived agents reduce the attack surface and minimize drift.
- Secret management: Use environment hooks or secret managers; never hard-code secrets in YAML.
- Keep base images updated: Regularly patch agents to mitigate security vulnerabilities.

### Avoid snowflake agents

- No manual tweaks: Avoid one-off changes to long-lived agents; enforce everything via code and images.
- Immutable patterns: Use infrastructure-as-code and versioned images for consistency and reproducibility.

## Environment and dependency management

### Containerize builds for consistency

- Docker-based builds: Ensure environments are reproducible across local and CI.
- Efficient caching: Optimize Dockerfile layering to maximize cache reuse.
- Multi-stage builds: Keep images slim while supporting complex build processes.
- Pin base images: Avoid unintended breakage from upstream changes.

### Handle dependencies reliably

- Lock versions: Use lockfiles and pin versions to ensure repeatable builds (you can also [pin plugin versions](/docs/pipelines/integrations/plugins/using#pinning-plugin-versions)).
- Cache packages: Reuse downloads where possible to reduce network overhead.
- Validate integrity: Use checksums or signatures to confirm dependency authenticity.
- Document requirements: Record OS packages, runtimes, and tools for onboarding and reproducibility.

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

Model partial deployments and staged rollouts directly in pipelines.

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

Avoid cramming unrelated tasks into one step:

```yaml
# ❌ Bad
- label: "Build, test, and deploy"
  command: |
    npm install
    npm run build
    npm test
    npm run deploy

# ✅ Good
- label: ":package: Install dependencies"
  command: "npm install"

- label: ":hammer: Build"
  command: "npm run build"

- label: ":test_tube: Test"
  command: "npm test"

- label: ":rocket: Deploy"
  command: "npm run deploy"
```

#### Unbounded parallelism

Avoid spinning up excessive parallel jobs without considering agent limits and costs.

#### Silent failures

Never ignore failing steps without clear documentation or follow-up.

## Monitoring and observability

### Logging best practices

- Structured logs: Favor JSON or other parsable formats.
- Appropriate log levels: Differentiate between info, warnings, and errors.
- Persist artifacts: Store logs, reports, and binaries for debugging and compliance.
- Track trends: Use Buildkite Insights or external tools to analyze durations and failure patterns.

### Set relevant alerts

- Failure alerts: Notify responsible teams for failing builds.
- Queue depth monitoring: Detect bottlenecks when builds queue too long.
- Agent health alerts: Trigger alerts when agents go offline or degrade.
- Escalation paths: Define clear procedures for handling critical outages.

### Use analytics for improvement

- Key metrics: Monitor build duration, throughput, and success rate.
- Bottleneck analysis: Identify slowest steps and optimize them.
- Failure clustering: Look for repeated error types.
- Developer experience feedback: Collect input from engineers on pipeline usability.

## Security best practices

### Manage secrets properly

- Native secret management: Use Buildkite’s secret redaction and plugins.
- Rotate secrets: Regularly update credentials to minimize risk.
- Limit scope: Expose secrets only to the steps that require them.
- Audit usage: Track which steps consume which secrets.

### Enforce access controls

- Role-based access: Grant permissions per team and role.
- Branch protections: Limit edits to sensitive pipelines.
- Permission reviews: Audit permissions on a regular basis.
- Use SSO/SAML: Centralize authentication and improve compliance.

### Governance and compliance
- Policy-as-code: Define and enforce organizational rules (e.g., required steps, approved plugins).
- Audit readiness: Retain logs, artifacts, and approvals for compliance reporting.
- Sandbox pipelines: Provide safe environments to test changes without impacting production.

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
- Ignoring developer input: CI/CD should enable, not block, velocity.
- Skipping observability early: Add metrics and logging from day one.
- Treating pipelines as secondary: Invest in CI/CD as critical infra.
- Not planning for scale: Design for higher volume and parallelism.
- Poor documentation: Document patterns, conventions, and playbooks.
- Unverified pipeline changes: Test modifications in sandbox pipelines first.
- Neglecting build performance: Regularly optimize for faster cycles.

## Conclusion

Buildkite pipelines are most effective when treated as living systems: modular, observable, secure, and developer-friendly. Invest in clarity, speed, and automation from the start, and continuously refine based on developer feedback and scaling needs.
