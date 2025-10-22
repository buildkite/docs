# Platform controls

This guide is focusing on how platform and infrastructure teams can maintain centralized control while providing development teams with the flexibility they need to run and observe the pipelines in your Buildkite organization.

> 📘
> If you're looking for in-depth information on security controls, see [Enforcing security controls](/docs/pipelines/security/enforcing-security-controls).

## Concept of platform management

The key to successful Buildkite administration lies in finding the right balance between centralized control and developer autonomy. Platform teams need to manage shared resources and enforce company-wide standards while avoiding becoming a bottleneck for feature teams.

The distinction between platform (or "infrastructure") and developer teams is that the former gets to specify settings like the size of the infrastructure, machine capacity, maximum rerun attempts, time-outs, etc. in the YAML configurations included in the codebase, that stays unchanged (by the developer teams). The platform team also manages a script that reads these YAML configuration files, generates the correct pipeline(s), and allocates agents (with correct underlying capacity) to run the jobs in those pipelines.

When the resulting pipeline runs, the end user of Buildkite (a member of the developer team) sees [annotations](/docs/agent/v3/cli-annotate) generated from the specific steps that ran just for their run. These annotations can contain useful additional information and context (for example, a link to an internal dashboard in case of an error).

To sum it up:

- Platform teams manage central control while still giving end users of Buildkite (developer teams) as much or as little flexibility as necessary.
- One script can generate many different variations of pipelines, and this allows the platform teams to manage shared logic and run organization-wide checks, for example, [security scanning](/docs/pipelines/security/enforcing-security-controls#dependencies-and-package-management).
- Developer teams only get the permissions and information that is relevant to their builds and pipelines.

## Buildkite agent controls

Before the agents in your infrastructure pick start picking up jobs, the infrastructure team (team with [Buildkite organization administrator permissions](/docs/platform/team-management/permissions#manage-teams-and-permissions-organization-level-permissions)) decides how much CPU, RAM, other resources the agents can have, regardless of whether the Buildkite Agents will be [hosted](/docs/pipelines/hosted-agents), [self-hosted](/docs/pipelines/architecture#self-hosted-hybrid-architecture) (running locally), or in the cloud ([AWS](/docs/agent/v3/aws), [GCP](/docs/agent/v3/gcloud), [Kubernetes](/docs/agent/v3/agent-stack-k8s)).

## Clusters and queues

- Set your clusters and queues according to our best practices and then provide an internal guide for your engineers in terms of which ones they can use. Only allow the specific number of agents you’d like to be in a queue. Monitor the wait times.
- Monitor or set a maximum job age for waiting jobs to make sure that wrong queue usage is handled.
- See [Clusters and queues for more details](/docs/pipelines/clusters#clusters-and-queues-best-practices).

## Pipeline templates as platform control tool

Controls and templates can be used in the process of running the pipelines. Initially, the platform team has to create and be responsible for the pipeline YAML and the [pipeline templates](/docs/pipelines/governance/templates).

> 📘 Enterprise feature
> Pipeline templates are only available on an [Enterprise](https://buildkite.com/pricing) plan.

Pipeline templates provide platform teams with a powerful mechanism to enforce standardization and security across all CI/CD pipelines in your organization. By creating centrally-managed templates that define approved step configurations, security scanning requirements, deployment patterns, and compliance checks, platform teams can ensure that all development teams follow established best practices without needing to manually review every pipeline.

From an operational perspective, platform teams should leverage pipeline templates to embed infrastructure and security policies directly into the CI/CD workflow. Templates can include mandatory steps for vulnerability scanning, artifact signing, infrastructure-as-code validation, and deployment approvals, ensuring that every build follows your organization's security and compliance requirements.

The ability to update templates centrally means that policy changes or security improvements can be rolled out instantly across all pipelines using that template, eliminating the need to coordinate updates across multiple development teams. Additionally, platform teams can create different template variants for different environments or application types (microservices, frontend applications, data pipelines) while maintaining consistent underlying security and infrastructure patterns, providing both flexibility and control over your organization's build and deployment processes.

## Access with least privilege

Buildkite's teams feature provides platform teams with granular access controls and functionality management across pipelines, test suites, and registries throughout your organization. These controls help standardize operations while providing teams with necessary flexibility to manage their own resources within defined boundaries.

### Organization-level control

Platform administrators maintain full organizational oversight through Buildkite organization administrator privileges, allowing them to:

- Enable and configure the teams feature across the organization
- Create, modify, and delete teams as organizational needs evolve
- Set organization-wide policies and security configurations
- Access audit logs and usage reports for compliance and monitoring
- Manage integrations and organization-level settings

### Team-based access management

Structure your teams to align with your organizational hierarchy and security requirements:

- **Product-based teams**: organize teams around product lines or business units.
- **Function-based teams**: create teams for infrastructure, security, frontend, and backend functions.
- **Environment-based access**: control who can access staging, production, and development environments.
- **Cross-functional teams**: enable collaboration while maintaining appropriate access boundaries.

### Permission levels and controls

The teams feature provides three distinct permission levels for different resources:

- **Full Access**: Complete control over pipelines, test suites, and registries.
- **Build & Read** (pipelines): Ability to trigger builds and view pipeline details.
- **Read Only**: View-only access for monitoring and reporting purposes.

We recommend basing your permission-granting policies on the least privilege access principles.

### Automated team management

Leverage programmatic controls to maintain consistency:

- Use the GraphQL API for automated team provisioning and user management.
- Implement SSO integration to automatically assign new users to appropriate teams.
- Configure agent restrictions using the `BUILDKITE_BUILD_CREATOR_TEAMS` environment variable.
- Set up automatic team membership for new organization members.

### Security incident response

Platform teams can quickly respond to security incidents by immediately removing compromised users from the organization, which instantly revokes all their access to organizational resources. For organizations with SSO enabled, coordinate user removal both in Buildkite and your SSO provider to prevent re-authentication.

See more in [Teams permissions](/docs/platform/team-management/permissions#manage-teams-and-permissions).

## Telemetry reporting

Platform teams should implement comprehensive telemetry and observability solutions to monitor pipeline performance, identify reliability issues, and optimize CI/CD infrastructure. Effective telemetry provides actionable insights into build patterns, failure rates, resource utilization, and team productivity while enabling data-driven infrastructure decisions.

You can turn Buildkite into a first‑class source of operational truth for your CI fleet by combining in‑product metrics with open telemetry streams, your preferred observability backend, and Buildkite’s real‑time event feeds.

## Centralize observability

Ensure all pipelines report metrics to your centralized monitoring system for:

- Build success/failure rates
- Queue wait times
- Agent utilization
- Cost per pipeline/team

## Standardized retry policies

Platform teams should implement consistent retry policies across all pipelines to handle transient failures gracefully while avoiding unnecessary resource consumption. Well-designed retry strategies distinguish between different types of failures and apply appropriate retry logic based on the likelihood of success upon retry.

### Automatic retry configuration

#### Exit code-based retry policies

Define specific retry behaviors for different failure categories using Buildkite's automatic retry functionality:

```yaml
steps:
  - label: "Test Suite"
    command: run_tests.sh
    retry:
      automatic:
        - exit_status: 1      # Test failures - may pass on retry
          limit: 2
        - exit_status: 255    # Infrastructure issues - likely transient
          limit: 3
        - exit_status: 130    # SIGINT/timeout - resource contention
          limit: 1
        - exit_status: 137    # SIGKILL/OOM - memory issues
          limit: 1
```

#### Conditional retry strategies

Implement more sophisticated retry logic that considers build context and failure patterns:

```yaml
steps:
  - label: "Integration Tests"
    command: integration_test_runner.sh
    retry:
      automatic:
        # Network-related failures - aggressive retry
        - exit_status: 2
          limit: 5
        # Database connection issues - moderate retry
        - exit_status: 3
          limit: 3
        # Authentication failures - single retry only
        - exit_status: 4
          limit: 1
      manual:
        # Allow manual retry for complex failures
        allowed: true
        permit_on_passed: false
        reason: "Manual investigation required"
```

#### Environment-specific retry policies

Tailor retry behavior based on the deployment environment and criticality:

```yaml
# Production deployment - conservative retries
- label: "Deploy to Production"
  command: deploy_production.sh
  retry:
    automatic:
      - exit_status: 255    # Infrastructure only
        limit: 2
  if: build.branch == "main"

# Development environment - aggressive retries
- label: "Deploy to Development"
  command: deploy_development.sh
  retry:
    automatic:
      - exit_status: "*"    # Any failure
        limit: 3
  if: build.branch =~ /^feature\//
```

### Platform-wide retry standards

#### Centralized retry policies

Use pipeline templates to enforce consistent retry behavior across the organization:

```yaml
# In your pipeline template
common_retry_policies: &retry_policies
  retry:
    automatic:
      - exit_status: 1      # Test failures
        limit: 2
      - exit_status: 2      # Build failures
        limit: 1
      - exit_status: 255    # Infrastructure
        limit: 3
    manual:
      allowed: true
      permit_on_passed: false

steps:
  - label: "Unit Tests"
    command: npm test
    <<: *retry_policies
  - label: "Integration Tests"
    command: npm run test:integration
    <<: *retry_policies
```

#### Workload-specific retry patterns

Define different retry strategies for different types of workloads:

```yaml
# High-availability service retries
high_availability_retry: &ha_retry
  retry:
    automatic:
      - exit_status: "*"
        limit: 5

# Security scanning retries (conservative)
security_scan_retry: &security_retry
  retry:
    automatic:
      - exit_status: 255    # Infrastructure only
        limit: 2
    manual:
      allowed: false        # No manual retries for security

# Performance testing retries (resource-aware)
performance_test_retry: &perf_retry
  retry:
    automatic:
      - exit_status: 137    # OOM errors
        limit: 1
      - exit_status: 124    # Timeouts
        limit: 2
```

## Custom exit codes and failure classification

Implement standardized exit codes across your organization to enable intelligent retry policies, better error reporting, and automated incident response. Well-defined exit codes help platform teams understand failure patterns and optimize pipeline reliability.

### Exit code standardization

#### Organizational exit code conventions

Establish consistent exit code meanings across all build scripts and tools. For example:

```bash
#!/bin/bash
# Standard exit codes for organizational use

# Success
readonly EXIT_SUCCESS=0

# Test and build failures (retryable)
readonly EXIT_TEST_FAILURE=1
readonly EXIT_BUILD_FAILURE=2
readonly EXIT_LINT_FAILURE=3

# Infrastructure failures (highly retryable)
readonly EXIT_NETWORK_ERROR=10
readonly EXIT_DEPENDENCY_UNAVAILABLE=11
readonly EXIT_RESOURCE_EXHAUSTION=12

# Configuration failures (not retryable)
readonly EXIT_CONFIG_ERROR=20
readonly EXIT_AUTHENTICATION_FAILURE=21
readonly EXIT_PERMISSION_DENIED=22

# Security failures (critical, not retryable)
readonly EXIT_SECURITY_VIOLATION=30
readonly EXIT_VULNERABILITY_DETECTED=31
readonly EXIT_COMPLIANCE_FAILURE=32

# System failures (infrastructure retryable)
readonly EXIT_TIMEOUT=124
readonly EXIT_SIGKILL=137
readonly EXIT_SIGTERM=143
readonly EXIT_INFRASTRUCTURE=255

# Example usage in a test script
run_security_scan() {
    if ! security_scanner --config security.yaml; then
        echo "Security vulnerabilities detected"
        exit $EXIT_VULNERABILITY_DETECTED
    fi
}

run_unit_tests() {
    if ! npm test; then
        echo "Unit tests failed"
        exit $EXIT_TEST_FAILURE
    fi
}
```

## Custom checkout scripts

Platform teams can standardize code checkout processes across all pipelines by implementing custom checkout hooks that gather consistent metadata, enforce security policies, and prepare the build environment according to organizational standards. Custom checkout scripts ensure that every job starts with the same foundation while accommodating different repository and project requirements.

### Implementing standardized checkout workflows

#### Agent-level checkout hooks

Create agent hooks that run for every job, regardless of pipeline or repository:

- Place custom checkout scripts in the agent's hooks directory (configured by the [`hooks-path`](/docs/agent/v3/configuration#hooks-path) setting)
- Use the `checkout` hook to completely override the default git checkout behavior with your organization's standards
- Implement `pre-checkout` and `post-checkout` hooks to perform setup and validation tasks around the standard checkout process

#### Repository-specific enhancements

Supplement agent-level hooks with repository-specific checkout customizations:

- Create `.buildkite/hooks/post-checkout` scripts in repositories that need additional setup after code retrieval
- Implement repository-specific environment variable configuration and dependency preparation
- Add project-specific validation checks that run immediately after checkout

## Annotations

- You can use annotations to communicate and link other documents/systems.
- In annotations, you can add internal frequently asked questions or a link to those, as well as to dashboard monitoring.
- Give your contact details/ticketing system to raise things through.

## Cost and billing controls

Platform teams can implement various controls and optimization methods to manage Buildkite infrastructure costs effectively. These approaches help balance performance requirements with budget constraints while maintaining visibility into resource utilization across your organization.

### User and license management

With the cost of using Buildkite (depending on your tier) is partially based on the number of users, the platform team or (platform administrator) can track the number of users in an organization with the help of the following GraphQL query:

```graphql
query getOrgMembersCount {
  organization(slug: "org-slug") {
    members(first:1) {
      count
    }
  }
}
```

Alternatively, Buildkite organization administrators can view the number of users in a Buildkite organization in https://buildkite.com/organizations/~/users.

It's also recommended to:

- Monitor user activity and remove inactive accounts to optimize license costs.
- Implement automated user provisioning and deprovisioning workflows integrated with your identity management system.
- Track user activity patterns using [GraphQL organization queries](/docs/apis/graphql/cookbooks/organizations) to identify optimization opportunities.
- Set up alerts when user counts approach license limits to prevent overage charges.

## Enforce access controls

Access controls determine who can view or modify your pipeline configurations. Getting this right means your sensitive pipelines stay in the right hands.

Set up team-based access controls that match how your organization actually works. Give teams the permissions they need—whether that's read-only access for visibility or write permissions for teams managing their own pipelines. Check out [Teams permissions](/docs/platform/team-management/permissions) for details on configuring these settings.

Protect your critical branches. If you're using branch-based workflows (and you probably should be), use branch protections to prevent unauthorized changes to sensitive pipelines. This adds a layer of review before changes go live.

Review permissions regularly. As people join, leave, or change roles, and as projects evolve, permissions that made sense six months ago might not make sense today. Schedule periodic access reviews to keep things tidy.

Integrate SSO or SAML if your organization uses an identity provider. This centralizes authentication, makes onboarding and offboarding smoother, and often helps with compliance requirements. It's also one less set of credentials for people to manage.

Alternative version:

Access controls help ensure that only authorized users and teams can view or modify sensitive pipeline configurations:

- Team-based access - Grant permissions per team based on specific needs, such as read-only or write permissions. See [Teams permissions](/docs/platform/team-management/permissions).
- Branch protections - Limit edits to sensitive pipelines by protecting critical branches.
- Permission reviews - Audit permissions regularly to ensure they remain appropriate as teams and projects evolve.
- Use SSO/SAML - Centralize authentication and improve compliance by integrating with your organization's identity provider.

## Implement cost allocation

Implement comprehensive cost allocation mechanisms to understand and optimize spending:

- Tag builds with team, project, or department identifiers to enable cost attribution.
- Generate regular usage reports that break down compute hours by team, project, and queue type.
- Track peak usage periods to optimize scaling schedules and resource allocation.
- Monitor artifact storage costs and implement retention policies for large or frequently uploaded artifacts.

### Proactive cost management

Set up monitoring and alerting systems to prevent unexpected cost overruns:

- Configure alerts for unusual usage spikes that could indicate runaway builds or security incidents.
- Implement build timeout policies to prevent stuck or infinite-loop jobs from consuming resources.
- Set up automated reporting that provides cost visibility to team leads and budget owners.
- Create dashboards that show real-time cost trends and projections for proactive budget management.

### Cost optimization workflows

- Establish regular review cycles to assess queue utilization and right-size resources.
- Implement automated policies that pause or scale down underutilized queues.
- Create cost-aware pipeline design guidelines that help teams optimize their build configurations.
- Use build duration and queue wait time metrics to identify opportunities for parallelization or resource optimization.

By implementing these cost controls, platform teams can maintain predictable infrastructure spending while ensuring that development teams have the resources they need for efficient CI/CD operations.

## Enabling developers

### Self-service pipelines

- Curated templates: Allow teams to adopt pipelines without deep Buildkite expertise.
- Golden paths: Document and promote recommended workflows to reduce cognitive load.
- Feedback loops: Encourage engineers to propose improvements or report issues.
- Use [annotations](/docs/agent/v3/cli-annotate) to let your developer team know whom in your organization to contact in case of a failure. For example:

```bash
buildkite-agent annotate "Your build has failed - reach out to johndoe_platform@yourorg.com" --style "error" --context "build-failure"
```

## Overall ownership

Set up a platform team that is managing the infrastructure and the common constructs that can be used as pipelines, for example, private plugins, Docker image building pipeline, an so on. And then allow the individual developer teams build their own pipelines.

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

## Next steps

The following are the key areas we recommend you to focus on next:

- [Security controls](/docs/pipelines/security/enforcing-security-controls)
- Advanced [monitoring](/docs/agent/v3/monitoring) and alerting strategies
- [Integration](/docs/pipelines/integrations) with your existing infrastructure
