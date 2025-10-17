# Migrate from unclustered to clustered agents

Clusters create logical boundaries between different parts of your build infrastructure, enhancing security, discoverability, and manageability. Learn more about clusters from the [Clusters overview](/docs/pipelines/clusters) page.

Therefore, if your Buildkite pipelines are still operating in an unclustered agent environment, you should migrate these pipelines across to operating with clustered agents. This guide provides details on how to migrate your unclustered agents across to clustered ones.

Unclustered agents are agents associated with the **Unclustered** area of the **Clusters** page in a Buildkite organization. Learn more about unclustered agents in [Unclustered agent tokens](/docs/agent/v3/unclustered-tokens).

Migrating unclustered agents to a cluster allows those agents to use [agent tokens](/docs/agent/v3/tokens) that connect to Buildkite via a cluster, which can be managed by users with [cluster maintainer](/docs/pipelines/clusters/manage-clusters#manage-maintainers-on-a-cluster) privileges.

> 📘 Buildkite organizations created after February 26, 2024
> Buildkite organizations created after this date will not have an **Unclustered** area. Therefore, this process is not required for these newer Buildkite organizations.

## Single-cluster migration overview

Migrating your unclustered agents to a single cluster is the fastest migration strategy that offers the least friction, and is a recommended starting point. To do this:

1. Ensure you are familiar with the [key benefits of clusters](#key-benefits-of-clusters), and [starting the migration process with a single cluster](#key-benefits-of-clusters-starting-with-a-single-cluster).

1. Generate a [new agent token](/docs/agent/v3/tokens#create-a-token) for your **Default cluster**.

    **Note:** This step is only required for clustered agents that you'll be running in a [self-hosted (hybrid)](/docs/pipelines/architecture#self-hosted-hybrid-architecture) environment.

1. Create your required [self-hosted](/docs/pipelines/clusters/manage-queues#create-a-self-hosted-queue) or [Buildkite hosted](/docs/pipelines/clusters/manage-queues#create-a-buildkite-hosted-queue) queues in this cluster—one for each queue tag that was assigned to all agents when they were started in your unclustered agent environment.

    Ensure you are familiar with the differences in how queues are managed and configured between unclustered and clustered environments in [Agent queue differences](#technical-considerations-agent-queue-differences), as well as the [Create your clusters and queues](#agent-migration-process-create-your-clusters-and-queues) and [Migrate unclustered agents to clusters](#agent-migration-process-migrate-unclustered-agents-to-clusters) sections of the [Agent migration process](#agent-migration-process).

    **Tip:** If you'll be running your clustered agents in a self-hosted (hybrid) environment, ensure you create _copies_ of your unclustered agents for your new cluster. This allows you to use your unclustered agents to fall back on if you experience any issues in getting your new clustered agents up and running. Once your agents have been successfully migrated over to your new cluster, you can then decommission your unclustered agents.

1. Move the [pipelines associated with your unclustered agents to their new cluster](#agent-migration-process-move-pipelines-to-clusters), and [test and validate](#agent-migration-process-test-and-validate-the-migrated-pipelines) that they build as expected on your new clustered agents.

1. Decommission your [unclustered agents](#agent-migration-process-decommission-your-unclustered-resources).

You can now unlock [cluster insights](/docs/pipelines/insights/clusters), [queue metrics](/docs/pipelines/insights/queue-metrics), and [secrets management](/docs/pipelines/security/secrets/buildkite-secrets).

See [Agent migration process](#agent-migration-process) for the full migration process and detailed migration steps, bearing in mind that you are only working with a single cluster.

## Key benefits of clusters

- **Enhanced security boundaries**: Clusters provide hard security boundaries between different environments. However, you can use [rules](/docs/pipelines/rules) to create exceptions that allow controlled interaction between clusters when needed.

- **Improved observability**: Clusters provide access to [cluster insights](/docs/pipelines/insights/clusters) (for customers on Enterprise plans), providing better metrics and visibility into your build infrastructure such as queue wait times and job pass rates. All plans have access to [queue metrics](/docs/pipelines/insights/queue-metrics).

- **Secrets management**: Clusters provide access to [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets) and controlled access to sensitive resources.

- **Easier agent management**: Clusters make agents and queues more discoverable across your organization and allow teams to self-manage their agent pools.

- **Better organization**: You can separate agents and pipelines by team, environment, or use case, making your CI/CD infrastructure easier to understand and maintain.

### Starting with a single cluster

Starting your unclustered to clustered migration process with a single cluster offers several advantages:

- **Minimal queue rewiring**: Your existing queue structure requires minimal configuration changes.

- **No pipeline edits**: Pipelines continue to work without modification.

- **Immediate insights**: Access [cluster insights](/docs/pipelines/insights/clusters) and [queue metrics](/docs/pipelines/insights/queue-metrics) instantly.

- **Buildkite secrets**: Benefit from immediate access to [secrets management](/docs/pipelines/security/secrets/buildkite-secrets).

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

## Migration strategies

Choose a migration strategy based on your organization's structure, CI/CD ownership model, and risk tolerance.

### Single-cluster migration

This migration strategy is the fastest and safest for most organizations. Start with a single cluster containing all your agents, then optionally split into multiple clusters later.

#### Advantages

- Involves minimal queue and pipeline configuration changes.
- Complete migration could be achieved within a matter of hours—not days or weeks.
- Instant access to [cluster insights](/docs/pipelines/insights/clusters) and [queue metrics](/docs/pipelines/insights/queue-metrics).
- Easiest environment to revert if issues arise, provided you have made copies of your agents as part of the [Migrate unclustered agents to clusters](#agent-migration-process-migrate-unclustered-agents-to-clusters) process (when running the agents in a [self-hosted (hybrid)](/docs/pipelines/architecture#self-hosted-hybrid-architecture) environment).

#### Considerations

- All agents initially share the same security boundary.
- Once you have completed migrating all your unclustered agents across to a single cluster, you may wish or need to split your agents and pipelines into multiple clusters later, using a [team-by-team](#migration-strategies-team-by-team-migration), [all-at-once](#migration-strategies-all-at-once-migration), or a [hybrid](#migration-strategies-hybrid-strategy) migration strategy, for an improved and more secure build environment.

See [Agent migration process](#agent-migration-process) for detailed steps on the full migration process, bearing in mind that you are only working with a single cluster.

### Team-by-team migration

This migration strategy is best for Buildkite organizations that have their CI/CD ownership _distributed_ across multiple teams.

#### Advantages

- Inherently has lower risk, as changes affect only one team at a time.
- Teams can migration to clustered agents at their own pace.
- Easier to troubleshoot issues if they arise.

#### Considerations

- Requires a longer overall migration timeframe.
- May require temporary solutions for cross-team pipeline dependencies.
- Requires coordination between teams for shared resources.

Learn more about the [technical considerations](#technical-considerations) of migrating agents from unclustered to clustered environments, and the [Agent migration process](#agent-migration-process) for detailed steps on the full migration process.

### All-at-once migration

This migration strategy is best for Buildkite organizations with _centrally_ managed infrastructure, particularly those using infrastructure-as-code tools like Terraform.

#### Advantages

- Provides a shorter migration timeframe.
- Provides a consistent implementation across all teams.
- Avoids a prolonged hybrid state, where your Buildkite organization contains a mix of clustered and unclustered agents.

#### Considerations

- Higher risk of other problems occurring if issues are encountered during migration.
- Requires more extensive planning and testing.

Learn more about the [technical considerations](#technical-considerations) of migrating agents from unclustered to clustered environments, and the [Agent migration process](#agent-migration-process) for detailed steps on the full migration process.

### Hybrid strategy

Consider a hybrid of the [team-by-team](#migration-strategies-team-by-team-migration) and [all-at-once](#migration-strategies-all-at-once-migration) migration strategy if your Buildkite organization has both _distributed_ and _centralized_ CI/CD components:

- Migrate core infrastructure in one operation.
- Allow teams to gradually migrate their team-specific agents and pipelines over to clusters.
- Create a timeline with clear milestones for the complete agent migration process.

Learn more about the [technical considerations](#technical-considerations) of migrating agents from unclustered to clustered environments, and the [Agent migration process](#agent-migration-process) for detailed steps on the full migration process.

## Technical considerations

Understanding these differences is crucial for planning your migration.

### Agent queue differences

The following table lists the differences in how agents, queues and tags are handled between unclustered and clustered environments.

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
        clustered_environment: "Requires planning for agents in multiple queues: create separate self-hosted agents for each queue, consolidate queues, or use agent tags for granular targeting within a single queue.",
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

### Agent token management

#### Agent token differences

The following table lists the differences between the former unclustered agent tokens and newer agent tokens associated with clusters.

<table>
  <thead>
    <tr>
      <th style="width:20%">Feature</th>
      <th style="width:40%">Unclustered agent tokens</th>
      <th style="width:40%">Agent tokens for clusters</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        feature: "Token scope",
        agent_tokens_for_clusters: "Agent tokens are scoped to a single cluster.",
        unclustered_agent_tokens: "Unclustered agent tokens can be configured on any unclustered agent."
      },
      {
        feature: "IP address restrictions",
        agent_tokens_for_clusters: "Agent tokens offer the ability to restrict access based on IP address, providing greater security and control.",
        unclustered_agent_tokens: "Unclustered agent tokens do not possess IP address restriction capabilities."
      }
    ].select { |field| field[:feature] }.each do |field| %>
      <tr>
        <td>
          <p><strong><%= field[:feature] %></strong></p>
        </td>
        <td>
          <p><%= field[:unclustered_agent_tokens] %></p>
        </td>
        <td>
          <p><%= field[:agent_tokens_for_clusters] %></p>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

#### Security considerations

- Switching from unclustered agent tokens to agent tokens for clusters is necessary for migrating your agents to clusters.
- Ensure secure distribution of new agent tokens.
- Plan for token rotation if needed, and if doing so, plan to implement [agent token expiration with a limited lifetime](/docs/agent/v3/tokens#agent-token-lifetime) (available when [creating agent tokens](/docs/agent/v3/tokens#create-a-token) using the [REST](/docs/agent/v3/tokens#create-a-token-using-the-rest-api) or [GraphQL](/docs/agent/v3/tokens#create-a-token-using-the-graphql-api) APIs).

### Pipeline relationships

- As part of [evaluating the complexity of the agent migration process](#assessing-your-current-environment-evaluate-complexity-of-the-agent-migration-process), be aware of which of your pipelines trigger others.
- You'll need to create [rules](/docs/pipelines/rules) to allow cross-cluster pipeline interactions, such as triggering or reading cross-cluster artifacts.
- Consider how to structure your clusters to minimize the need for cross-cluster triggers, but also maintain meaningful boundaries.

## Agent migration process

This section outlines the complete migration process from unclustered to clustered agents, providing both an overview of each step and detailed implementation guidance.

### Plan and prepare

1. Identify which clusters you need based on your organization's structure.
   * Common patterns include creating clusters to separate environments (development, test, production), platforms (Linux, macOS, Windows), or teams.
   * Create a mapping of existing agents to their future clusters.

1. Document your current unclustered setup including:
   * Agent configurations and locations.
   * Pipeline configurations and dependencies.
   * Cross-pipeline interactions.

1. Create a realistic timeline that accounts for testing and potential rollbacks.

1. Develop a communication plan for all teams affected by the migration. See [best practices on communication planning](#best-practices-and-recommendations-communication-planning) for some high-level guidelines on how to approach this step.

### Set up your infrastructure

1. Set up infrastructure to support your new cluster configuration.
   * Update agent installation scripts or configuration management tools.
   * Prepare for temporary coexistence of clustered and unclustered agents during migration.

1. If using infrastructure as code, create or update templates to support the new cluster model.

1. Establish monitoring for both clustered and unclustered agents during the transition.

### Create your clusters and queues

1. Create the [appropriate clusters](/docs/pipelines/clusters/manage-clusters#setting-up-clusters) within your Buildkite organization.

    You can [create clusters](/docs/pipelines/clusters/manage-clusters#create-a-cluster) using the [Buildkite interface](/docs/pipelines/clusters/manage-clusters#create-a-cluster-using-the-buildkite-interface), or [REST](/docs/pipelines/clusters/manage-clusters#create-a-cluster-using-the-rest-api) or [GraphQL](/docs/pipelines/clusters/manage-clusters#create-a-cluster-using-the-graphql-api) APIs.

1. Define the [appropriate queues](/docs/pipelines/clusters/manage-queues#setting-up-queues) within each cluster.

    Name queues according to their purpose (for example, `linux-amd64`, `macos-m1`, etc.), bearing in mind that basing the queue name on the [queue tag assigned to an agent when it was started](/docs/agent/v3/queues#setting-an-agents-queue) (in its unclustered environment), could reduce the complexity of the agent migration process.

    If you have unclustered agents where any one of them was assigned to multiple queues (that is, if the [agent was started with multiple queue tags in its unclustered environment](/docs/agent/v3/queues#setting-an-agents-queue-setting-up-queues-for-unclustered-agents)), then create a new queue in its relevant cluster for each of these queue tags, or (based on **Migration considerations** under [Agent queue differences](#technical-considerations-agent-queue-differences) above), perhaps just for the important queue tags you wish to continue using in your clustered environment.

    If defining multiple queues, select a sensible queue to be the default. Jobs without a specific queue mentioned will use the default queue.

    Last, add descriptions to your queues to help users understand the queues' purposes and capabilities.

    You can create either:
    * [self-hosted queues](/docs/pipelines/clusters/manage-queues#create-a-self-hosted-queue) (using the [Buildkite interface](/docs/pipelines/clusters/manage-queues#create-a-self-hosted-queue-using-the-buildkite-interface), or [REST](/docs/pipelines/clusters/manage-queues#create-a-self-hosted-queue-using-the-rest-api) or [GraphQL](/docs/pipelines/clusters/manage-queues#create-a-self-hosted-queue-using-the-graphql-api) APIs), or
    * [Buildkite hosted queues](/docs/pipelines/clusters/manage-queues#create-a-buildkite-hosted-queue) (also using the [Buildkite interface](/docs/pipelines/clusters/manage-queues#create-a-buildkite-hosted-queue-using-the-buildkite-interface), or [REST](/docs/pipelines/clusters/manage-queues#create-a-buildkite-hosted-queue-using-the-rest-api) or [GraphQL](/docs/pipelines/clusters/manage-queues#create-a-buildkite-hosted-queue-using-the-graphql-api) APIs).

1. Configure the necessary permissions for each cluster. As part of this process, consider how you'll set up [cluster maintainers](/docs/pipelines/clusters/manage-clusters#manage-maintainers-on-a-cluster) so that infrastructure teams are enabled to self-manage agent resources.

If you'll be:

- Running any of your clustered agents in a [self-hosted (hybrid)](/docs/pipelines/architecture#self-hosted-hybrid-architecture) environment, continue on to the [Configure agent tokens](#agent-migration-process-configure-agent-tokens) and [Migrate unclustered agents to clusters](#agent-migration-process-migrate-unclustered-agents-to-clusters).
- Running _all_ of your clustered agents as Buildkite hosted agents, you can skip to the [Move pipelines to clusters](#agent-migration-process-move-pipelines-to-clusters) section of this process.

### Configure agent tokens

This part of the agent migration process is only applicable for clustered agents running in a [self-hosted (hybrid)](/docs/pipelines/architecture#self-hosted-hybrid-architecture) environment.

1. Generate new [agent tokens](/docs/agent/v3/tokens) for each cluster.
1. Securely distribute these agent tokens to the appropriate teams or systems.
1. Document the mapping between these agent tokens and their clusters.

You can [create agent tokens](/docs/agent/v3/tokens#create-a-token) using the [Buildkite interface](/docs/agent/v3/tokens#create-a-token-using-the-buildkite-interface), or the [REST](/docs/agent/v3/tokens#create-a-token-using-the-rest-api) or [GraphQL](/docs/agent/v3/tokens#create-a-token-using-the-graphql-api) API. Consider rotating tokens and setting an expiry date as you create them. Learn more about this process in [Agent token lifetime](/docs/agent/v3/tokens#agent-token-lifetime).

### Migrate unclustered agents to clusters

This part of the agent migration process is only applicable for clustered agents running in a [self-hosted (hybrid)](/docs/pipelines/architecture#self-hosted-hybrid-architecture) environment.

1. Update your unclustered agent configurations—preferably by making a new copy of each agent for its new clustered environment. For each new agent, replace its existing unclustered agent token with its new agent token for its cluster.

    As part of a [best practice](#best-practices-and-recommendations) strategy to [minimize downtime](#best-practices-and-recommendations-minimizing-downtime), creating copies of your agents like this results in two instances of each agent—one running in your original unclustered environment and the other associated with its appropriate cluster. This allows you to fall back on your unclustered agents if you have issues getting any of your clustered agents to operate as expected, thereby minimizing downtime. Be aware that this situation is only temporary, since you'll eventually be [decommissioning your unclustered agents](#agent-migration-process-decommission-your-unclustered-resources).

1. For each of your agents, ensure they are configured to start with their appropriate tags for targeting, _and_ set the queue that was [already defined in your cluster](#agent-migration-process-create-your-clusters-and-queues) (or the [default queue](/docs/agent/v3/queues#the-default-queue)), which will be selected for that agent. For example, the following code snippet shows how to [configure an agent](/docs/agent/v3/configuration) from its [former unclustered environment that defined multiple queue tags](/docs/agent/v3/queues#setting-an-agents-queue-setting-up-queues-for-unclustered-agents), to instead target its single queue ([configured previously](#agent-migration-process-create-your-clusters-and-queues)) for its clustered environment:

    ```bash
    # Before migration (unclustered) - multiple queues
    buildkite-agent start \
        --token "unclustered-agent-token-value" \
        --tags "queue=linux,queue=testing,arch=amd64,env=prod"

    # After migration (clustered) - single queue
    buildkite-agent start \
        --token "agent-token-value-for-cluster" \
        --tags "queue=linux,arch=amd64,env=prod"
    ```

1. Restart agents to apply the new configuration.

1. Verify that agents appear in the correct cluster in the Buildkite interface.

### Move pipelines to clusters

Move all the pipelines that were associated with your unclustered agents to their appropriate clusters (associated with the agents that will build these pipelines). Also, see [best practices](#best-practices-and-recommendations) on [minimizing downtime](#best-practices-and-recommendations-minimizing-downtime) and [testing strategies](#best-practices-and-recommendations-testing-strategies) for some high-level guidelines on how to approach moving your pipelines over to clusters.

1. For each such pipeline:
   1. Navigate to the pipeline's **Settings**.
   1. On the **General** settings page, select the **Change Cluster** button, and then select the appropriate cluster from the resulting dialog.
   1. Select **Save** to update the pipeline's cluster.
   1. Update any queue references in the pipeline's steps if required. Check both the pipeline's **Settings** > **Steps**, as well as the relevant `pipeline.yml` file uploaded from its Git repository.
   1. Ensure these queue reference updates are saved.

1. Configure cross-cluster interactions if needed:
   1. Navigate to your Buildkite organization's **Settings** > **Rules** to access its [**Rules** page](https://buildkite.com/organizations/~/rules).
   1. Create [rules](/docs/pipelines/rules) to allow specific cross-cluster interactions.
   1. Test that these new rules function as expected.

1. Update any CI/CD automation that interacts with these pipelines.

Alternatively, consider using [Terraform](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs) to assign pipelines to clusters in a single action at once.

### Test and validate the migrated pipelines

1. Run test builds on migrated pipelines to verify their execution.

1. Verify that agents pick up jobs correctly and use [queue metrics](/docs/pipelines/insights/queue-metrics) graphs to monitor job creation within your clusters.

1. Check that any pipeline triggers that you implemented work as expected.

1. Monitor for any errors or unexpected behavior.

1. Test failure scenarios to ensure proper recovery.

### Decommission your unclustered resources

1. Once [all tests pass](#agent-migration-process-test-and-validate-the-migrated-pipelines), gradually increase traffic to the pipelines that were migrated to clusters.

1. Monitor for any issues during the transition. If you are on an Enterprise plan, monitor [cluster insights](/docs/pipelines/insights/clusters).

1. After a suitable monitoring period (typically 1-2 weeks):
   * Decommission your old unclustered agents.
   * Archive any obsolete pipelines.
   * Remove temporary configurations used during the agent migration process.

1. Document the final cluster configuration for future reference.

## Best practices and recommendations

### Minimizing downtime

- Maintain parallel unclustered and clustered agents during migration.
- Migrate one pipeline at a time to minimize risk.
- Schedule migrations during low-traffic periods.
- Have a rollback plan ready in the event that unexpected issues are encountered.

### Testing strategies

- Create a test cluster with a subset of pipelines and agents before full migration.
- Test with non-critical pipelines first.
- Use feature branches to validate pipeline behavior in clusters.
- Simulate failure scenarios to verify recovery processes.

### Communication planning

- Notify all stakeholders well in advance of the migration.
- Provide documentation on how the new cluster structure works.
- Offer training or support sessions for teams unfamiliar with clusters.
- Set up a communication channel for reporting issues during migration.

## Troubleshooting common issues

### Agent connection problems

**Issue**: Agents fail to connect to Buildkite after the migration.

**Solutions**:

- Verify the agent token is correct and belongs to the intended cluster.
- Check network connectivity between the agent and Buildkite.
- Review agent logs for error messages.

### Pipeline execution failures

**Issue**: Pipelines don't execute on clustered agents.

**Solutions**:

- Verify the pipeline is assigned to the correct cluster.
- Check that any queues referenced in the pipeline steps exist in the cluster.
- Ensure agent tags match what's expected by the pipeline.
- Verify that agents are connected and healthy.

### Queue configuration issues

**Issue**: Jobs target the wrong agents or don't run.

**Solutions**:

- Review queue names and configurations.
- Verify agent tags are correctly set and aren't trying to align cross-queues.
- Check pipeline step queue targeting in your YAML.
- Consider using more descriptive queue names to avoid confusion.
