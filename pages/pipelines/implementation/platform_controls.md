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
- One script can generate many different variations of pipelines, and this allows the platform teams to manage shared logic and run organization-wide checks, for example, [security scanning](https://buildkite.com/docs/pipelines/security/enforcing-security-controls#dependencies-and-package-management).
- Developer teams only get the permissions and information that is relevant to their builds and pipelines.

## Buildkite agent controls

Before the agents in your infrastructure pick start picking up jobs, the platform team (team with [Buildkite organization administrator permissions](/docs/platform/team-management/permissions#manage-teams-and-permissions-organization-level-permissions)) decides how much CPU, RAM, other resources the agents can have, regardless of whether the Buildkite Agents will be [hosted](/docs/pipelines/hosted-agents), [self-hosted](/docs/pipelines/architecture#self-hosted-hybrid-architecture) (running locally), or in the cloud ([AWS](/docs/agent/v3/aws), [GCP](/docs/agent/v3/gcloud), [Kubernetes](/docs/agent/v3/agent-stack-k8s)).

## Pipeline templates as platform control tool

Controls and templates can be used in the process of running the pipelines. Initially, the platform team has to create and be responsible for the pipeline YAML and the [pipeline templates](/docs/pipelines/governance/templates).

> 📘 Enterprise feature
> Pipeline templates are only available on an [Enterprise](https://buildkite.com/pricing) plan.

Pipeline templates provide platform teams with a powerful mechanism to enforce standardization and security across all CI/CD pipelines in your organization. By creating centrally-managed templates that define approved step configurations, security scanning requirements, deployment patterns, and compliance checks, platform teams can ensure that all development teams follow established best practices without needing to manually review every pipeline.

From an operational perspective, platform teams should leverage pipeline templates to embed infrastructure and security policies directly into the CI/CD workflow. Templates can include mandatory steps for vulnerability scanning, artifact signing, infrastructure-as-code validation, and deployment approvals, ensuring that every build follows your organization's security and compliance requirements.

The ability to update templates centrally means that policy changes or security improvements can be rolled out instantly across all pipelines using that template, eliminating the need to coordinate updates across multiple development teams. Additionally, platform teams can create different template variants for different environments or application types (microservices, frontend applications, data pipelines) while maintaining consistent underlying security and infrastructure patterns, providing both flexibility and control over your organization's build and deployment processes.

## Clusters and queues

Use [clusters](/docs/pipelines/clusters) for workload separation and enhanced infrastructure management.Buildkite clusters create logical boundaries between different parts of your build infrastructure, enhancing security, discoverability, and manageability across your organization.

You can organize your infrastructure using Buildkite clusters to:

- Separate different environments (staging, production)
- Isolate different teams or projects
- Apply different security policies per cluster
- Manage costs more granularly
- Enable teams to self-manage their Buildkite agent pools
- Provide easily accessible queue metrics and operational insights

See [Clusters and queues for more details](/docs/pipelines/clusters#clusters-and-queues-best-practices).

### Cluster structure recommendations

In small to medium organizations, a single default cluster will often suffice. As your organization grows, consider structuring clusters based on team or department ownership:

- **Product lines:** create individual clusters for each product when managing multiple products.
- **Type of work:** separate open source, infrastructure, frontend, and backend workloads.
- **Security boundaries:** isolate sensitive workloads that require different compliance or security policies.

Keep in mind that pipelines associated with one cluster cannot trigger or access artifacts from pipelines in another cluster unless you create explicit rules to allow cross-cluster interactions.

### Queue structure recommendations

Structure your queues based on infrastructure characteristics to enable efficient scaling and resource management:

- Architecture: `x86`, `arm64`, `apple-silicon`.
- Agent size: `small`, `medium`, `large`, `extra-large`.
- Machine type: `macos`, `linux`, `windows`, `gpu`.
- Workload type: `default`, `deploy`, `security`, `performance`.

An effective naming convention combines these attributes, such as `small_mac_silicon` or `large_linux_deploy`. This approach allows you to scale similar agents together while providing clear reporting and resource allocation.

## Platform team controls

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

Standardize the number of times test flakes are retried and have their custom exit statuses that you can report on with your telemetry provider. For example, you can use the [OpenTelemetry](/docs/pipelines/integrations/observability/opentelemetry#opentelemetry-tracing-notification-service) integration with Buildkite Pipelines.

### Standardize retry behavior

Define consistent retry policies for infrastructure flakes and test failures:

```yaml
retry:
  automatic:
    - exit_status: 1  # Test failures
      limit: 2
    - exit_status: 255  # Infrastructure issues
      limit: 3
```

### Implement custom exit codes

Use specific exit codes for different failure types to improve reporting and automated responses.

### Centralize observability

Ensure all pipelines report metrics to your centralized monitoring system for:

- Build success/failure rates
- Queue wait times
- Agent utilization
- Cost per pipeline/team

## Custom checkout scripts

Platform teams can standardize code checkout processes across all pipelines by implementing custom checkout hooks that gather consistent metadata, enforce security policies, and prepare the build environment according to organizational standards. Custom checkout scripts ensure that every job starts with the same foundation while accommodating different repository and project requirements.

### Implementing standardized checkout workflows

**Agent-level checkout hooks:**

Create agent hooks that run for every job, regardless of pipeline or repository:

- Place custom checkout scripts in the agent's hooks directory (configured by the [`hooks-path`](/docs/agent/v3/configuration#hooks-path) setting)
- Use the `checkout` hook to completely override the default git checkout behavior with your organization's standards
- Implement `pre-checkout` and `post-checkout` hooks to perform setup and validation tasks around the standard checkout process

**Repository-specific enhancements:**

Supplement agent-level hooks with repository-specific checkout customizations:

- Create `.buildkite/hooks/post-checkout` scripts in repositories that need additional setup after code retrieval
- Implement repository-specific environment variable configuration and dependency preparation
- Add project-specific validation checks that run immediately after checkout

## Plugin management and standardization

Platform teams can leverage Buildkite plugins to standardize tooling, enforce best practices, and reduce configuration duplication across pipelines. By creating and managing a curated set of plugins, platform teams can provide development teams with approved, secure, and well-maintained tools while maintaining control over the CI/CD environment.

### Private plugin development

You can [write](/docs/pipelines/integrations/plugins/writing) a [private plugin](/docs/pipelines/integrations/plugins/using#plugin-sources) when you need to implement organization-specific requirements or standardize complex workflows:

- **Security and compliance integration**: develop plugins that automatically integrate with your organization's security scanning tools, compliance frameworks, or audit logging systems.
- **Deployment standardization**: create plugins that encapsulate your organization's deployment patterns, environment-specific configurations, and rollback procedures.
- **Infrastructure automation**: build plugins that interact with your internal APIs, infrastructure provisioning systems, or monitoring platforms.
- **Quality gate enforcement**: Implement plugins that enforce code quality standards, testing requirements, or documentation completeness checks.

### Reusable functionality patterns through plugins

You can extract common pipeline functionality into plugins to reduce duplication and ensure consistency:

- Multi-environment deployment pipelines with approval gates.
- Artifact packaging and distribution processes.
- Performance testing and benchmarking procedures.
- Container image building and security scanning workflows.

### Plugin source management

Platform teams should establish clear governance around plugin sources and usage:

- **Buildkite-maintained plugins**: use these for standard functionality like Docker, Docker Compose, and common testing frameworks.
- **Approved third-party plugins**: maintain an allowlist of vetted community plugins that meet your security and reliability standards.
- **Private organizational plugins**: host your custom plugins in private repositories using fully qualified Git URLs for sensitive or proprietary functionality.

Implement strict version management practices to ensure reliability and security:

- Always pin plugins to specific versions or commit SHA values to prevent unexpected changes: `docker#v3.3.0` or `my-plugin#287293c4`.
- Regularly audit and update plugin versions as part of your maintenance cycle.
- Use YAML anchors to centralize plugin configuration and ensure consistency across pipelines.
- Monitor plugin repositories for security vulnerabilities and updates.

#### Plugin orchestration

Design plugin workflows that work together seamlessly across pipeline steps:

- Use plugins that leverage Buildkite's meta-data store to share information between steps
- Create plugin chains that handle complex workflows like build → test → security scan → deploy
- Implement plugins that can conditionally execute based on previous step results or build metadata

### Plugin access control and security

Platform administrators can control plugin usage through agent configuration:

- Use the [agent's plugin restrictions](/docs/agent/v3/securing#restrict-access-by-the-buildkite-agent-controller-allow-a-list-of-plugins) to allowlist approved plugins.
- Set the [`no-plugins`](/docs/agent/v3/configuration#no-plugins) option to disable plugins entirely on sensitive agents.
- Implement different plugin policies for different agent clusters based on security requirements.

### Private plugin distribution

For sensitive or proprietary functionality, use private Git repositories:

```yml
steps:
  - command: deploy to production
    plugins:
      - ssh://git@github.com/your-org/deployment-plugin.git#v1.0.0:
          environment: production
          approval_required: true
      - file:///internal/monitoring-plugin.git#v2.0.0:
          alert_channels: ["#ops", "#security"]
```

### Plugin security

- Regularly audit plugin permissions and access patterns
- Use separate Git repositories for different security domains
- Implement code review processes for all plugin changes
- Monitor plugin usage across your organization to identify potential security risks or optimization opportunities

By establishing comprehensive plugin management practices, platform teams can provide development teams with powerful, standardized tools while maintaining security, compliance, and operational consistency across the entire CI/CD ecosystem.

## Annotations

[Build annotations](/docs/agent/v3/cli-annotate) provide platform teams with a powerful mechanism to surface critical information, standardize reporting, and enhance visibility across your CI/CD pipelines. Using the `buildkite-agent annotate` command, platform teams can programmatically add rich, formatted information to build pages that helps development teams understand build results, identify issues, and access important resources.

### Standardized reporting and visibility

Platform teams can leverage annotations to create consistent reporting standards across all pipelines:

- **Test result summaries**: use annotations to display comprehensive test failure reports, coverage metrics, and performance benchmarks in a standardized format.
- **Security scan results**: surface vulnerability findings, compliance status, and remediation guidance directly in the build interface.
- **Deployment status**: provide clear visibility into deployment progress, environment health checks, and rollback procedures.
- **Infrastructure insights**: display resource utilization, cost analysis, and infrastructure drift detection results.

### Automated quality gates and compliance

Implement automated quality gates that use annotations to communicate pass/fail status and required actions:

- Use different annotation styles (`success`, `warning`, `error`, `info`) to clearly indicate the severity and urgency of findings.
- Set annotation priorities (1-10) to ensure critical issues are prominently displayed.
- Embed artifacts like detailed reports, logs, and analysis results using the `artifact://` prefix for easy access.

## Cross-pipeline communication

Platform teams can use contextual annotations to provide consistent information across related builds:

- Use the `--context` parameter to group related annotations and enable updates from different pipeline steps.
- Leverage the `--append` option to build comprehensive reports that aggregate information from parallel or sequential jobs.
- Create standardized contexts for common reporting types like `security-scan`, `performance-test`, or `deployment-status`.

### Implementation recommendations

When implementing annotations as part of your platform controls:

- Create reusable scripts or tools that generate consistent annotation formats across teams.
- Use CommonMark Markdown with supported CSS classes to ensure professional, readable formatting.
- Implement colored terminal output for logs and console information using `term` or `terminal` code blocks.
- Set up automated annotation removal for temporary status updates that become obsolete.
- Consider annotation size limits (1MiB maximum) when designing comprehensive reports.

## Cost and billing controls

Platform teams can implement various controls and optimization methods to manage Buildkite infrastructure costs effectively. These approaches help balance performance requirements with budget constraints while maintaining visibility into resource utilization across your organization.

### Cluster and queue management (size control)

Cluster maintainers have granular control over resource allocation through queue management:

- Create only the agent sizes and types necessary for your workloads in Buildkite-hosted queues.
- Restrict queue creation permissions to prevent unnecessary resource provisioning.
- Implement approval workflows for new queue requests that include cost impact assessments.
- Regularly audit existing queues to identify and remove unused or underutilized resources.

### Agent scaling

Only allow the specific number of agents you’d like to be in a queue. Monitor the wait times.

Implement intelligent scaling strategies to minimize idle resource costs:

- Configure agent scaling policies based on historical usage patterns and queue wait times
- Monitor queue metrics to identify optimal scaling thresholds for different workload types
- Set maximum agent limits per queue to prevent runaway scaling during load spikes
- Use time-based scaling to align agent availability with team working hours

> 📘 Scaling tip
> Scale all of your AWS agents to zero and only keep a handful warm during the work/peak hours (could be the ones that are running CloudFormation deploy or Terraform apply).

Scale your infrastructure based on actual usage patterns rather than peak capacity:

- Scale AWS agents to zero during off-hours and maintain only essential agents for critical deployments.
- Keep a minimal number of "warm" agents during peak hours for immediate job execution.
- Reserve larger agent sizes only for resource-intensive tasks like performance testing or large deployments.
- Implement queue-specific scaling policies that match the compute requirements of different job types.

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

### User access optimization strategies

- Use team-based access controls to limit pipeline access to necessary personnel only.
- Implement SSO-based automatic user lifecycle management.
- Create processes for regular user access reviews and cleanup.
- Consider using service accounts for automated processes instead of personal user accounts where appropriate.

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

## Implementation recommendations for the platform team

- Assess current state: audit existing pipelines, agents, and usage patterns.
- Define policies: establish resource limits, security requirements, and cost targets.
- Create templates: build standard pipeline templates for common use cases.
- Implement gradually: roll out controls incrementally to avoid disrupting existing workflows.

## Next steps

The framework of Buildkite Pipelines platform controls outline on this page provides a foundation for managing Buildkite Pipelines at scale. Consider your organization's specific needs around security, compliance, and cost management when implementing these controls.

The following are the key areas we recommend you to focus on next:

- [Security controls](/docs/pipelines/security/enforcing-security-controls)
- [Best practices](/docs/pipelines/implementation/best-practices)
- Advanced [monitoring](/docs/agent/v3/monitoring) and alerting strategies
- [Integration](/docs/pipelines/integrations) with your existing infrastructure
