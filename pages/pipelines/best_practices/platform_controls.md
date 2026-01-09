# Platform controls

This guide covers how platform (infrastructure) teams can maintain centralized control while giving developer (engineering) teams the flexibility they need to run and observe pipelines in your Buildkite organization.

> 📘
> If you're looking for in-depth information on security controls, see [Enforcing security controls](/docs/pipelines/best-practices/security-controls).

## Concept of platform management

The key to successful administration of the Buildkite Pipelines platform lies in finding the right balance between centralized control and developer autonomy. Platform teams need to manage shared resources and enforce company-wide standards while avoiding becoming a bottleneck for feature teams.

The distinction between platform and developer teams is that platform team specifies the settings like the size of the infrastructure, machine capacity, maximum rerun attempts, time-outs, etc. in the [YAML pipeline configurations included in the codebase](/docs/pipelines/create-your-own#create-a-pipeline), that stays unchanged (by the developer teams).

The platform team also manages the scripts that read these YAML configuration files and generate the correct pipeline(s), and allocates agents (with correct underlying capacity) to run the jobs in those pipelines.

## Agent infrastructure administration

Platform teams with [organization administrator permissions](/docs/platform/team-management/permissions#manage-teams-and-permissions-organization-level-permissions) decide on agent resource allocation (CPU, RAM, etc.) before agents start picking up jobs. This applies whether you use [hosted agents](/docs/pipelines/hosted-agents), [self-hosted agents](/docs/pipelines/architecture#self-hosted-hybrid-architecture), or cloud deployments ([AWS](/docs/agent/v3/aws), [GCP](/docs/agent/v3/self-hosted/gcp), [Kubernetes](/docs/agent/v3/self-hosted/agent-stack-k8s)).

## Pipeline templates as a platform control tool

Platform teams need to create and be responsible for the pipeline YAML and the [pipeline templates](/docs/pipelines/governance/templates).

> 📘 Enterprise feature
> Pipeline templates are only available on an [Enterprise](https://buildkite.com/pricing) plan.

Pipeline templates provide platform teams with a powerful mechanism to enforce standardization and security across all CI/CD pipelines in your organization. By creating centrally-managed templates that define approved step configurations, security scanning requirements, deployment patterns, and compliance checks, platform teams can ensure that all developer teams follow established best practices without needing to manually review every pipeline.

The ability to update templates centrally means that policy changes or security improvements can be rolled out instantly across all pipelines using that template, eliminating the need to coordinate updates across multiple developer teams.

Additionally, platform teams can create different template variants for different environments or application types (microservices, frontend applications, data pipelines) while maintaining consistent underlying security and infrastructure patterns, providing both flexibility and control over your organization's build and deployment processes.

## Implementing least privilege access

The [teams feature](/docs/platform/team-management/permissions#manage-teams-and-permissions) in Buildkite Pipelines provides platform teams with granular access controls and functionality management across pipelines, test suites, and registries throughout your organization. These controls help standardize operations while providing teams with necessary flexibility to manage their own resources within defined boundaries.

The teams permissions allow three distinct permission levels for different resources:

- **Full Access**: Complete control over pipelines, test suites, and registries.
- **Build & Read** (pipelines): Ability to trigger builds and view pipeline details.
- **Read Only**: View-only access for monitoring and reporting purposes.

It is recommended to base your permission-granting policies on the least privilege access principles.

### Automated team management

Leverage programmatic controls to maintain consistency:

- Use the [GraphQL API](/docs/apis/graphql-api) for automated [team provisioning](/docs/apis/graphql/cookbooks/teams) and [user management](/docs/apis/graphql/cookbooks/organizations).
- Implement [SSO integration](/docs/platform/sso) to automatically assign new users to appropriate teams.
- Configure agent restrictions using the `BUILDKITE_BUILD_CREATOR_TEAMS` environment variable.
- Set up automatic team membership for new organization members.
- You can also use [Buildkite Terraform provider](/docs/pipelines/best-practices/iac#terraform-provider) to manage users and teams programmatically. You can learn more in the [Manage your CI/CD resources as Code with Terraform](https://buildkite.com/resources/blog/manage-your-ci-cd-resources-as-code-with-terraform/) blog post.

> 📘 Security incident response
> Platform teams can quickly respond to security incidents by immediately removing compromised users from the organization, which instantly revokes all their access to organizational resources. For organizations with SSO enabled, coordinate user removal both in Buildkite and your SSO provider to prevent re-authentication. Enterprise customers using SCIM deprovisioning can automate this by deactivating users directly in their identity provider.

## Enforcement of access controls

Access controls determine who can view or modify your pipeline configurations. Getting this right means your sensitive pipelines stay in the right hands.

- Set up team-based access controls that match how your organization actually works. Give teams the permissions they need,  whether that's read-only access for visibility or write permissions for teams managing their own pipelines. Check out [Teams permissions](/docs/platform/team-management/permissions) for details on configuring these settings.
- Protect your critical branches. If you're using branch-based workflows, use branch protections to prevent unauthorized changes to sensitive pipelines. This adds a layer of review before changes go live.
- Review permissions regularly. As people join, leave, or change roles, and as projects evolve, permissions that made sense six months ago might not make sense today. Schedule periodic access reviews to keep things tidy.
- Integrate SSO or SAML if your organization uses an identity provider. This centralizes authentication, makes onboarding and offboarding smoother, and often helps with compliance requirements. It's also one less set of credentials for people to manage.

## Telemetry reporting

Platform teams should implement comprehensive telemetry and observability solutions to monitor pipeline performance, identify reliability issues, and optimize CI/CD infrastructure. Effective telemetry provides actionable insights into build patterns, failure rates, resource utilization, and team productivity while enabling data-driven infrastructure decisions.

You can turn Buildkite into a first‑class source of operational truth for your CI fleet by combining in‑product metrics with open telemetry streams, your preferred observability backend, and Buildkite’s real‑time event feeds.

Ensure all pipelines report metrics to your centralized [monitoring](/docs/agent/v3/monitoring) system for:

- Build success/failure rates
- Queue wait times
- Agent utilization
- Cost per pipeline/team

See more in [Monitoring and observability](/docs/pipelines/best-practices/monitoring-and-observability).

## Setting up notifications for platform teams

Timely [notifications](/docs/pipelines/configure/notifications) help platform teams keep builds healthy without manually watching dashboards. In Buildkite Pipelines, you can enable the following notifications types:

- [Basecamp](/docs/pipelines/configure/notifications#basecamp-campfire-message)
- [Email](/docs/pipelines/configure/notifications#email)
- [GitHub commit status](/docs/pipelines/configure/notifications#github-commit-status)
- [GitHub check](/docs/pipelines/configure/notifications#github-check)
- [PagerDuty](/docs/pipelines/configure/notifications#pagerduty-change-events)
- [Slack](/docs/pipelines/configure/notifications#slack-channel-and-direct-messages)
- [Webhooks](/docs/pipelines/configure/notifications#webhooks)

Setting up notification service(s) allows platform teams to:

- Send a success message only when a pipeline that usually fails passes, or when a critical deploy completes.
- Route failed builds to a dedicated channel (for example, `#ci-alerts`) so on-call engineers can react quickly.
- Tag on-call rotations with `@here` or `@platform-oncall` to avoid alert fatigue for the wider team.
- Use thread replies for follow-up logs or links to build pages, keeping the main channel concise.
- Configure different channels for routine and critical events.

See more in [Notifications](/docs/pipelines/configure/notifications#slack-channel-and-direct-messages).

## Custom checkout scripts

Platform teams can standardize code checkout processes across all pipelines by implementing custom checkout hooks that gather consistent metadata, enforce security policies, and prepare the build environment according to organizational standards. Custom checkout scripts ensure that every job starts with the same foundation while accommodating different repository and project requirements.

See more in [Git checkout optimization](/docs/pipelines/best-practices/git-checkout-optimization).

## Cost and billing controls

Platform teams can implement various controls and optimization methods to manage Buildkite infrastructure costs effectively. These approaches help balance performance requirements with budget constraints while maintaining visibility into resource utilization across your organization.

### Implement cost allocation

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

By implementing these cost controls, platform teams can maintain predictable infrastructure spending while ensuring that developer teams have the resources they need for efficient CI/CD operations.

### User and license management

Since the cost of using Buildkite Pipelines (depending on your tier) is partially based on the number of active users, the platform administrators can track the number of users in an organization with the help of the following GraphQL query:

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

## Plugin management best practices

Platform teams can leverage [Buildkite plugins](/docs/pipelines/integrations/plugins) to standardize tooling, enforce best practices, and reduce configuration duplication across pipelines - for instance, when you are repeatedly reusing some pieces of code. By creating and managing a curated set of plugins, platform teams can provide developer teams with approved, secure, and well-maintained tools while maintaining control over the CI/CD environment.

By establishing secure [Plugin management](/docs/pipelines/best-practices/plugin-management/) practices, platform teams can provide developer teams with powerful, standardized tools while maintaining security, compliance, and operational consistency across the entire CI/CD ecosystem.

## Release and deployment processes

Platform teams need to balance deployment velocity with safety and compliance requirements. This means implementing controls that prevent unauthorized production changes while avoiding processes that slow down legitimate deployments. The key is building guardrails into your pipelines that enforce approval workflows, enable gradual rollouts, and maintain visibility into deployment activities across your organization.

### Deployment approvals and gates

Use block steps to require human confirmation before critical deployments. This gives teams a final checkpoint to verify that the right code is going to the right environment:

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

Block steps work particularly well for production deployments, infrastructure changes, or any operation where you want a human in the loop. Learn more in [Block step](/docs/pipelines/configure/step-types/block-step).

For more sophisticated deployment patterns, implement canary releases and staged rollouts directly in your pipelines. This lets you gradually increase traffic to new versions while monitoring for issues. See [Deployments](/docs/pipelines/deployments) for implementation details, or use the [Buildkite deployment plugins](https://buildkite.com/docs/pipelines/deployments/deployment-plugins) to standardize these patterns across your organization.

### Reliability and resilience practices

Build resilience testing into your platform operations. Periodically inject failure scenarios (failing agents, flaky dependencies, network issues, etc.) to validate that your pipelines handle problems gracefully. This chaos testing approach helps you identify weak points before they cause real incidents.

Never ignore failing steps without a clear follow-up plan. Silent failures erode trust in your CI/CD platform and hide problems that will eventually cause larger issues. Configure your pipelines to surface failures immediately and ensure someone is responsible for addressing them.

## Build context and visibility with annotations

Use [annotations](/docs/agent/v3/cli-annotate) to provide build context and link to relevant documentation or monitoring systems. Annotations help developer teams quickly understand build failures, access troubleshooting resources, and find related operational data without leaving the Buildkite interface.

Platform teams can standardize annotation patterns across pipelines to include:

- Links to internal FAQs or runbooks for common build issues
- Direct links to monitoring dashboards showing real-time infrastructure health
- Pointers to relevant documentation for pipeline-specific processes
- Contact information for on-call teams or subject matter experts

By embedding these contextual links directly in build output, you reduce the time teams spend hunting for information when builds fail or when they need to understand pipeline behavior.

## Next steps

The following are the key areas we recommend you to focus on next:

- [Security controls](/docs/pipelines/security/enforcing-security-controls)
- [Monitoring and observability](/docs/pipelines/best-practices/monitoring-and-observability) strategies
- [Integration](/docs/pipelines/integrations) with your existing infrastructure
