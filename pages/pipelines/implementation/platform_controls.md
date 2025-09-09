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

Before the agents in your infrastructure pick start picking up jobs, the platform team (team with [Buildkite organization administrator permissions](/docs/platform/team-management/permissions#manage-teams-and-permissions-organization-level-permissions)) decides how much CPU, RAM, other resources the agents can have.

## Pipeline templates as platform control tool

Controls and templates can be used in the process of running the pipelines. Initially, someone has to create and be responsible for the pipeline YAML and the [pipeline templates](/docs/pipelines/governance/templates). This is what the platform team is responsible for.

### Clusters and queues

Use [clusters](/docs/pipelines/clusters) for workload separation. You can organize your infrastructure using Buildkite clusters to:

- Separate different environments (staging, production)
- Isolate different teams or projects
- Apply different security policies per cluster
- Manage costs more granularly

Only run your builds in the queues you define, in the cluster.

Use different clusters for different workloads.

Suggested Ccommon queue patterns:

- `default` - standard CI workloads
- `deploy` - production deployment jobs
- `security` - security scanning and compliance checks
- `performance` - resource-intensive performance tests

See [Clusters and queues for more details](/docs/pipelines/clusters#clusters-and-queues-best-practices)

## Platform team controls

Controls for the platform team in terms of how they run different pipelines and workloads. These controls help standardize operations while providing teams with necessary flexibility.

See more in [Teams permissions](/docs/platform/team-management/permissions#manage-teams-and-permissions).

### Telemetry reporting

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

### Custom checkout scripts

Have standard checkout scripts in which you gather the same data as part of every job.

### Private plugins

[Write](/docs/pipelines/integrations/plugins/writing) a [private plugin](/docs/pipelines/integrations/plugins/using#plugin-sources) if you would like things to be done in a certain way. For example, some repeated functionality from your pipelines can be offloaded into a plugin and reused.

### Annotations

Standardized [annotations](/docs/agent/v3/cli-annotate) can add additional context for the user. You can add internal links for the developers to check from tools.

## Cost and billing controls

Controls and optimization methods around cost. The following approaches will allow you to manage some of your costs based on optimizing your Buildkite Pipelines infrastructure.

### Cluster size control

Cluster maintainer can create the allowed queues and only allow the sizes they want to pay for in hosted.

### Agent scaling

Only allow the specific number of agents you’d like to be in a queue. Monitor the wait times.

> 📘 Scaling tip
> Scale all of your AWS agents to zero and only keep a handful warm during the work/peak hours (could be the ones that are running CloudFormation deploy or Terraform apply).

### User number control

With the cost of using Buildkite (depending on your tier) is partically based on the number of users, the platform team or (platform administrator) can track the number of users in an organiation with the help of the following GraphQL query:

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

Some of the other user activity in Buildkite organizations can also be tracked via [GraphQL](/docs/apis/graphql/cookbooks/organizations).

### Implement cost allocation

- Tag builds with team/project identifiers
- Generate regular usage reports
- Set up alerts for unusual usage spikes
- API-based logging out of users (if possible)

## Implementation recommendations

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
