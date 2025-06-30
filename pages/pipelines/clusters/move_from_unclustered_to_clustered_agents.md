# Move from unclustered to clustered agents

Clusters create logical boundaries between different parts of your build infrastructure, enhancing security, discoverability, and manageability. Learn more about clusters from the [Clusters overview](/docs/pipelines/clusters) page.

Therefore, if your Buildkite pipelines are still operating in an unclustered agent environment, you should move these pipelines across to operating with clustered agents. This guide provides details on how to move your unclustered agents across to clustered ones.

Unclustered agents are agents associated with the **Unclustered** area of the **Clusters** page in a Buildkite organization. Learn more about unclustered agents in [Unclustered agent tokens](/docs/agent/v3/unclustered-tokens).

Moving unclustered agents to a cluster allows those agents to use [agent tokens](/docs/agent/v3/tokens) that connect to Buildkite via a cluster, and requires at least [cluster maintainer](/docs/pipelines/clusters/manage-clusters#manage-maintainers-on-a-cluster) privileges.

> 📘 Buildkite organizations created after February 26, 2024
> Buildkite organizations created after this date will not have an **Unclustered** area. Therefore, this process is not required for these newer organizations.

## Key benefits of clusters

- **Enhanced security boundaries**: Clusters provide hard security boundaries between different environments. However, you can use [rules](/docs/pipelines/rules) to create exceptions that allow controlled interaction between clusters when needed.

- **Improved observability**: Clusters provide access to [cluster insights](/docs/pipelines/insights/clusters) (for customers on Enterprise plans), providing better metrics and visibility into your build infrastructure such as queue wait times and job pass rates. All plans have access to [cluster queue metrics](/docs/pipelines/insights/queue-metrics).

- **Easier agent management**: Clusters make agents and queues more discoverable across your organization and allow teams to self-manage their agent pools.

- **Better organization**: You can separate agents and pipelines by team, environment, or use case, making your CI/CD infrastructure easier to understand and maintain.

## Assessing your current environment

Before planning your move, assess your current environment to understand the scope and complexity of the transition.

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

### Evaluate complexity of the move

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

- **Shared infrastructure or configuration between different teams or environments**: When different environments share infrastructure or configurations, sharing these resources across separate clusters adds complexity to the entire agent move process.
    * Shared resources like caches, artifacts, or Docker images may need reconfiguring.
    * Teams might need to coordinate the timing their individual agent moves to avoid disruption.
    * You may need to rethink how shared infrastructure is accessed across cluster boundaries.

- **Custom scripts or automation that interacts with the Buildkite API**: Any custom scripts, integrations, or automations that interact with the Buildkite API might need updates to work with the cluster model.
    * Scripts that create or manage agents may need updating to handle [agent tokens](/docs/agent/v3/tokens) (which work with clusters),
    * Reporting tools that query agent or pipeline state might need modification.
    * CI/CD automation that interacts with Buildkite Pipelines may require updates to handle the clustered structure.

Use this assessment to determine which agent move approach is best for your Buildkite organization.

