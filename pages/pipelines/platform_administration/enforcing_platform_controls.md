# Enforcing platform controls in Buildkite

This guide covers best practices for managing Buildkite at scale, focusing on how platform and infrastructure teams can maintain centralized control while providing development teams with the flexibility they need.

> 📘
> If you're looking for in-depth information on best practices for security controls, see [Enforcing security controls](/docs/pipelines/security/enforcing-security-controls).

## Concept of platform management

The key to successful Buildkite administration lies in finding the right balance between centralized control and developer autonomy. Platform teams need to manage shared resources and enforce company-wide standards while avoiding becoming a bottleneck for feature teams.

One script can generate many different permutations of pipelines, so it's very easy for platform teams to manage shared logic, company-wide checks like security etc. You also have the full power of a programming language (conditionals, loops, tests etc) and can version control these pipeline generation scripts.

End users get just the information that's relevant to their run, and don't have to worry about the complexities of other permutations

## Buildkite agent controls

Controls around the agents touch upon using those with different software (?).

### Queues and clusters

Only run in the queues you define, in the cluster.

Have different clusters for different workloads.

Common queue patterns:
- `default` - Standard CI workloads
- `deploy` - Production deployment jobs
- `security` - Security scanning and compliance checks
- `performance` - Resource-intensive performance tests

**Use clusters for workload separation**: Organize your infrastructure using Buildkite clusters to:
- Separate different environments (staging, production)
- Isolate different teams or projects
- Apply different security policies per cluster
- Manage costs more granularly

Additional info:

Buildkite provides balance between control and controller giveaway - good, as you can run your own agents, decide how much CPU, RAM, other resources the agents can have.
Controls and templates can be used, but initially, someone has to be responsible for the pipeline YAML. A dedicated administration/infrastructure team can do that.

## Platform team controls

Controls for the platform team in terms of how they run different pipelines/workloads. These controls help standardize operations while providing teams with necessary flexibility.

### Telemetry reporting

Standardise the number of times infrastructure/test flakes are retried and have their custom exit statuses that you can report on with your telemetry provider.

**Standardize retry behavior**: Define consistent retry policies for infrastructure flakes and test failures:
```yaml
retry:
  automatic:
    - exit_status: 1  # Test failures
      limit: 2
    - exit_status: 255  # Infrastructure issues
      limit: 3
```

**Implement custom exit codes**: Use specific exit codes for different failure types to improve reporting and automated responses.

**Centralize observability**: Ensure all pipelines report metrics to your centralized monitoring system for:
- Build success/failure rates
- Queue wait times
- Agent utilization
- Cost per pipeline/team

### Custom checkout scripts

Have standard checkout scripts in which you gather the same data as part of every job.

### Private plugins

Build a private plugin if you would like things to be done in a certain way - helps standardize things. For example, some functionality can be offloaded into a plugin and reused.

### Annotations

Standardised annotation can add additional context for the user. You can add internal links for the developers to check from tools.

## Cost and billing controls

Controls and optimization methods around cost.

### Cluster size control

Cluster maintainer can create the allowed queues and only allow the sizes they want to pay for in hosted.

### Agent scaling

Only allow the number of agents you’d like in that queue. Monitor wait times.
Potential tip - scale all (AWS agents) to zero and only keep a handful warm during the work/peak hours (could be the ones that are running CloudFormation deploy or Terraform apply).

### User number control

User based cost, do we have any reporting to let you know of the number of user you have? any alerting? (most likely no).
We do have API commands that can show the number of users and active users, in GraphQL.

**Track user activity**: Use Buildkite's GraphQL API to monitor:
- Total user count vs. licensed seats
- Active users over different time periods
- Usage patterns by team or project

**Implement cost allocation**:
- Tag builds with team/project identifiers
- Generate regular usage reports
- Set up alerts for unusual usage spikes

## Implementation Recommendations

### Getting Started

1. **Assess current state**: Audit existing pipelines, agents, and usage patterns
2. **Define policies**: Establish resource limits, security requirements, and cost targets
3. **Create templates**: Build standard pipeline templates for common use cases
4. **Implement gradually**: Roll out controls incrementally to avoid disrupting existing workflows

### Common Pitfalls to Avoid

- **Over-restricting initially**: Start permissive and tighten controls based on actual usage
- **Ignoring developer feedback**: Platform controls should enable, not hinder, development teams
- **Lack of documentation**: Provide clear guidance on how teams should request resources or escalate issues
- **No monitoring**: Implement observability from day one to understand the impact of your controls

## Next Steps

This framework provides a foundation for managing Buildkite at scale. Consider your organization's specific needs around security, compliance, and cost management when implementing these controls.

Key areas to focus on next:
- Security controls and secrets management
- Integration with your existing infrastructure automation
- Advanced monitoring and alerting strategies
- Self-service capabilities for development teams
