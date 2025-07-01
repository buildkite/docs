# Migrate from unclustered to clustered agents

Clusters create logical boundaries between different parts of your build infrastructure, enhancing security, discoverability, and manageability. Learn more about clusters from the [Clusters overview](/docs/pipelines/clusters) page.

Therefore, if your Buildkite pipelines are still operating in an unclustered agent environment, you should migrate these pipelines across to operating with clustered agents. This guide provides details on how to migrate your unclustered agents across to clustered ones.

Unclustered agents are agents associated with the **Unclustered** area of the **Clusters** page in a Buildkite organization. Learn more about unclustered agents in [Unclustered agent tokens](/docs/agent/v3/unclustered-tokens).

Moving unclustered agents to a cluster allows those agents to use [agent tokens](/docs/agent/v3/tokens) that connect to Buildkite via a cluster, and requires at least [cluster maintainer](/docs/pipelines/clusters/manage-clusters#manage-maintainers-on-a-cluster) privileges.

> 📘 Buildkite organizations created after February 26, 2024
> Buildkite organizations created after this date will not have an **Unclustered** area. Therefore, this process is not required for these newer Buildkite organizations.

## Key benefits of clusters

- **Enhanced security boundaries**: Clusters provide hard security boundaries between different environments. However, you can use [rules](/docs/pipelines/rules) to create exceptions that allow controlled interaction between clusters when needed.

- **Improved observability**: Clusters provide access to [cluster insights](/docs/pipelines/insights/clusters) (for customers on Enterprise plans), providing better metrics and visibility into your build infrastructure such as queue wait times and job pass rates. All plans have access to [cluster queue metrics](/docs/pipelines/insights/queue-metrics).

- **Easier agent management**: Clusters make agents and queues more discoverable across your organization and allow teams to self-manage their agent pools.

- **Better organization**: You can separate agents and pipelines by team, environment, or use case, making your CI/CD infrastructure easier to understand and maintain.

## Assessing your current environment

Before planning your migration, assess your current environment to understand the scope and complexity of the transition.

### Make an inventory of existing resources

1. Document all _unclustered_ agents, including:
    * Number of agents
    * Agent queues
    * Agent tags
    * Agent environments (for example, operating system, architecture, etc.)

1. Document _all_ pipelines, including:
    * How pipelines are targeted to specific agents (that is, queue targeting, tag targeting, etc.)
    * Dependencies between pipelines
    * Shared resources or configurations

1. Identify cross-pipeline interactions:
    * Pipeline triggers
    * Artifact sharing
    * Other dependencies

### Evaluate complexity of the agent migration process

Consider the following factors that might increase the complexity of moving your unclustered agents to clustered ones:

- **Agents assigned to multiple queues (not supported in clusters)**: In unclustered environments, a single agent can be assigned to multiple queues. However, with clusters, each agent can only belong to one queue. This limitation requires restructuring your agent configuration.
    * You'll need to decide whether to create separate agents for each queue or consolidate queues.
    * Pipeline configurations may need updating to accommodate the new queue structure.

- **Use of agent tags across different queues**: Agent tags in clusters are scoped to the specific cluster they belong to, unlike in unclustered environments where tags can be used across multiple queues for targeting purposes.
    * Pipeline configurations that target agents using tags across queues will need to be updated.
    * You may need to standardize tagging conventions within each cluster.
    * Cross-cluster targeting patterns will require redesign using [rules](/docs/pipelines/rules) to allow specific exceptions.

- **Pipelines that trigger other pipelines**: Pipelines across different clusters will not be able to trigger each other by default, requiring additional configuration if you split interconnected pipelines into separate clusters.
    * You'll need to create [rules](/docs/pipelines/rules) to allow cross-cluster pipeline triggering.
    * Consider grouping pipelines that interact frequently into the same cluster (at least initially, to simplify the agent moving process).
    * Triggers between clusters may have different behavior than within the same scope (for instance, [rules](/docs/pipelines/rules) allows [conditionals](/docs/pipelines/configure/conditionals)).

- **Shared infrastructure or configuration between different teams or environments**: When different environments share infrastructure or configurations, sharing these resources across separate clusters adds complexity to the entire agent migration process.
    * Shared resources like caches, artifacts, or Docker images may need reconfiguring.
    * Teams might need to coordinate the timing their individual agent migrations to avoid disruption.
    * You may need to rethink how shared infrastructure is accessed across cluster boundaries.

- **Custom scripts or automation that interacts with the Buildkite API**: Any custom scripts, integrations, or automations that interact with the Buildkite API might need updates to work with the cluster model.
    * Scripts that create or manage agents may need updating to handle [agent tokens](/docs/agent/v3/tokens) (which work with clusters).
    * Reporting tools that query agent or pipeline state might need modification.
    * CI/CD automation that interacts with Buildkite Pipelines may require updates to handle the clustered structure.

Use this assessment to determine which agent migration approach is best for your Buildkite organization.

## Agent migration approaches

Choose an agent migration approach based on your organization's structure, CI/CD ownership model, and risk tolerance.

### Gradual team-by-team agent migration

This agent migration approach is best for Buildkite organizations that have their CI/CD ownership _distributed_ across multiple teams.

#### Advantages

- Inherently has lower risk, as changes affect only one team at a time.
- Teams can migration to clustered agents at their own pace.
- Easier to troubleshoot issues if they arise.

#### Considerations

- Requires a longer overall migration timeframe.
- May require temporary solutions for cross-team pipeline dependencies.
- Requires coordination between teams for shared resources.

### All-at-once agent migration

This agent migration approach is best for Buildkite organizations with _centrally_ managed infrastructure, particularly those using infrastructure-as-code tools like Terraform.

#### Advantages

- Provides a shorter migration timeframe.
- Provides a consistent implementation across all teams.
- Avoids a prolonged hybrid state, where your Buildkite organization contains a mix of clustered and unclustered agents.

#### Considerations

- Higher risk of other problems occurring if issues are encountered during migration.
- Requires more extensive planning and testing.

### Hybrid approaches

Consider a hybrid of the [team-by-team](#agent-migration-approaches-gradual-team-by-team-agent-migration) and [all-at-once](#agent-migration-approaches-all-at-once-agent-migration) agent migration approaches if your Buildkite organization has both distributed and centralized CI/CD components:

- Migrate core infrastructure in one operation.
- Allow teams to gradually migrate their team-specific agents and pipelines over to clusters.
- Create a timeline with clear milestones for the complete agent migration process.

## Technical considerations and blockers

Understanding these limitations and differences is crucial for planning your migration.

### Agent queue limitations

<table>
  <thead>
    <tr>
      <th style="width:20%">Feature</th>
      <th style="width:40%">Unclustered environment</th>
      <th style="width:40%">Clustered environment</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        feature: "Agent queue membership",
        clustered_environment: "Each agent can only belong to one queue.",
        unclustered_environment: "Agents can belong to multiple queues."
      },
      {
        feature: "Queue management",
        clustered_environment: "Users create queues in the Buildkite interface or APIs.",
        unclustered_environment: "Tags function as queues."
      },
      {
        feature: "Agent tag scope",
        clustered_environment: "Tags are scoped to the cluster and queue the agent belongs to.",
        unclustered_environment: "Tags have broader scope and function as queues."
      },
      {
        feature: "Agent tag targeting",
        clustered_environment: "Requires mapping existing tag-based targeting to the cluster model.",
        unclustered_environment: "Direct tag-based targeting available."
      },
      {
        feature: "Migration considerations",
        clustered_environment: "Requires planning for agents in multiple queues: create separate agents for each queue, consolidate queues, or use agent tags for granular targeting within a single queue.",
        unclustered_environment: "No migration needed for existing multi-queue agents."
      }
    ].select { |field| field[:feature] }.each do |field| %>
      <tr>
        <td>
          <p><strong><%= field[:feature] %></strong></p>
        </td>
        <td>
          <p><%= field[:unclustered_environment] %></p>
        </td>
        <td>
          <p><%= field[:clustered_environment] %></p>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

### Token management

#### Token differences

- Agent tokens for clusters are different from unclustered agent tokens.
- Agent tokens have a different length and are scoped to a single cluster.
- Agent tokens for clusters offer the ability to restrict access based on IP address, offering greater security and control.

#### Security considerations

- Switching from unclustered agent tokens to agent tokens for clusters is necessity for migrating your agents to clusters.
- Ensure secure distribution of new agent tokens.
- Plan for token rotation if needed, and if doing so, plan to implement [agent token expiration with a limited lifetime](/docs/agent/v3/tokens#agent-token-lifetime) (available via token creation API).

### Pipeline relationships

- As part of [evaluating the complexity of the agent migration process](#assessing-your-current-environment-evaluate-complexity-of-the-agent-migration-process), be aware of which of your pipelines trigger others.
- You'll need to create [rules](/docs/pipelines/rules) to allow cross-cluster pipeline interactions, such as triggering or reading cross-cluster artifacts.
- Consider how to structure your clusters to minimize the need for cross-cluster triggers, but also maintain meaningful boundaries.

