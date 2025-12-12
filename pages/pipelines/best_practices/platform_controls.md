# Platform controls

This guide covers how platform and infrastructure teams can maintain centralized control while giving development teams the flexibility they need to run and observe pipelines in your Buildkite organization.

> 📘
> For security-specific controls, see [Enforcing security controls](/docs/pipelines/best-practices/security-controls).

## Platform management approach

Successful Buildkite administration balances centralized control with developer autonomy. Platform teams manage shared resources and enforce company-wide standards without becoming a bottleneck for feature teams.

Platform teams control infrastructure settings—machine capacity, timeouts, resource limits—through YAML configurations that developer teams can't modify. They also manage the scripts that read these configurations, generate pipelines, and allocate agents with the right capacity to run jobs.

- Platform teams maintain central control while giving developer teams appropriate flexibility
- One script generates multiple pipeline variations, enabling centralized logic and organization-wide checks like [security scanning](/docs/pipelines/security/enforcing-security-controls#dependencies-and-package-management)
- Developer teams only access permissions and information relevant to their builds

## Agent infrastructure

Platform teams with [organization administrator permissions](/docs/platform/team-management/permissions#manage-teams-and-permissions-organization-level-permissions) decide agent resource allocation (CPU, RAM, etc.) before agents start picking up jobs. This applies whether you use [hosted agents](/docs/pipelines/hosted-agents), [self-hosted agents](/docs/pipelines/architecture#self-hosted-hybrid-architecture), or cloud deployments ([AWS](/docs/agent/v3/aws), [GCP](/docs/agent/v3/gcloud), [Kubernetes](/docs/agent/v3/agent-stack-k8s)).

## Clusters and queues

Configure clusters and queues following [best practices](/docs/pipelines/clusters#clusters-and-queues-best-practices), then document which ones your engineers can use. Control the number of agents per queue and monitor wait times. Set maximum job ages for waiting jobs to catch misconfigured queue usage.

## Pipeline templates

> 📘 Enterprise feature
> Pipeline templates require an [Enterprise](https://buildkite.com/pricing) plan.

[Pipeline templates](/docs/pipelines/governance/templates) let platform teams enforce standardization and security across all pipelines. Create centrally-managed templates that define approved step configurations, security scanning requirements, deployment patterns, and compliance checks. Development teams follow established practices without manual review of every pipeline.

Templates embed infrastructure and security policies directly into CI/CD workflows. Include mandatory steps for vulnerability scanning, artifact signing, infrastructure-as-code validation, and deployment approvals. When you update a template, the changes roll out instantly across all pipelines using it.

Create different template variants for different contexts (microservices, frontend apps, data pipelines) while maintaining consistent security and infrastructure patterns underneath.

## Team-based access control

Use Buildkite's [teams feature](/docs/platform/team-management/permissions#manage-teams-and-permissions) to implement least-privilege access:

Organization administrators can:

- Enable and configure teams organization-wide
- Create, modify, and delete teams
- Set organization-wide policies and security configurations
- Access audit logs and manage integrations

Team structure options:

- Product-based teams organized around business units
- Function-based teams for infrastructure, security, frontend, backend
- Environment-based access for staging, production, development
- Cross-functional teams enabling collaboration within boundaries

Permission levels:

- Full Access: Complete control over resources
- Build & Read: Trigger builds and view details (pipelines only)
- Read Only: View-only for monitoring

Automated management:

- Use the GraphQL API for automated provisioning
- Configure SSO to auto-assign users to teams
- Restrict agents using `BUILDKITE_BUILD_CREATOR_TEAMS`

For security incidents, immediately remove compromised users from the organization to revoke all access. With SSO enabled, coordinate removal in both Buildkite and your SSO provider.

## Custom checkout workflows

Standardize code checkout across pipelines using custom hooks that gather metadata, enforce security policies, and prepare build environments consistently.

### Agent-level hooks

- Place scripts in the agent's hooks directory (configured via [`hooks-path`](/docs/agent/v3/configuration#hooks-path))
- Override default checkout with the `checkout` hook
- Use `pre-checkout` and `post-checkout` for setup and validation

### Repository-specific customizations

- Create `.buildkite/hooks/post-checkout` for additional setup
- Configure project-specific environment variables
- Add validation checks after checkout

## Communication with annotations

Use [annotations](/docs/agent/v3/cli-annotate) to provide context and links to related systems:

```bash
buildkite-agent annotate "Build failed - contact platform@yourorg.com" --style "error" --context "build-failure"
```

Include links to internal dashboards, FAQs, or your ticketing system so developers know where to get help.

## Cost management

### User and license tracking

Track user count with GraphQL or view it at `https://buildkite.com/organizations/~/users`. Use this query:

```graphql
query getOrgMembersCount {
  organization(slug: "org-slug") {
    members(first:1) {
      count
    }
  }
}
```

- Remove inactive accounts to optimize license costs
- Automate provisioning/deprovisioning through your identity system
- Set alerts when approaching license limits

### Cost allocation

- Tag builds by team, project, or department
- Generate usage reports by team and queue type
- Track peak usage to optimize scaling
- Monitor artifact storage and implement retention policies

### Proactive monitoring
- Alert on unusual usage spikes
- Implement build timeout policies
- Provide cost dashboards to team leads
- Create cost-aware pipeline design guidelines

## Access controls

Protect sensitive pipelines with appropriate access restrictions:

- **Team-based permissions** - grant read-only or write access per team based on needs. See [Teams permissions](/docs/platform/team-management/permissions)
- **Branch protections** - require reviews before changes to critical pipelines
- **Regular audits** - review permissions as people and projects change
- **SSO/SAML integration** - centralize authentication with your identity provider

## Plugin management

Create and maintain a curated set of [plugins](/docs/pipelines/best-practices/plugin-management/) to standardize tooling and reduce configuration duplication. Provide development teams with approved, secure, well-maintained tools while controlling the CI/CD environment.

Learn more about [Plugin management](/docs/pipelines/best-practices/plugin-management).

## Deployment controls

Use block steps for production approvals:

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

Model staged rollouts with [Deployments](/docs/pipelines/deployments) and [deployment plugins](https://buildkite.com/docs/pipelines/deployments/deployment-plugins).

## Next steps

The following are the key areas we recommend you to focus on next:

- [Security controls](/docs/pipelines/security/enforcing-security-controls)
- [Monitoring and observability](/docs/pipelines/best-practices/monitoring-and-observability) strategies
- [Integration](/docs/pipelines/integrations) with existing infrastructure
