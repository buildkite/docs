# Clusters

Clusters are a new way of managing your Buildkite agents. They allow teams to self-manage their agent pools, let admins create isolated sets of agents and pipelines within the one Buildkite organization, and help to make agents and queues more discoverable across your organization.

The following diagram shows the architecture difference after enabling clusters.

<%= image "clusters-architecture.png", alt: "Diagram showing existing architecture and architecture with clusters" %>

Clusters encapsulate groups of agents and pipelines. This enables the following:

* Clusters are viewable to your entire organization, allowing engineers to understand better what agents and queues are available in their pipelines.
* You can grant cluster-admin access to individual users or teams to let them self-administer their own sets of agents. Cluster admins can create and delete queues, access agent tokens, and add and remove pipelines.
* Queues can be created within a cluster and validated when a pipeline’s configuration is saved during pipeline upload, and when a new agent connects. This helps to make queues more discoverable to pipeline authors and helps to prevent ghost jobs that never run because they had a typo in their pipeline.yml’s queue name.
* Pipelines now belong to a cluster. Pipelines can only schedule jobs on the cluster it belongs to and can only trigger builds on pipelines in the same cluster.

## Enabling clusters

Any administrator can enable clusters for an organization. Note that once enabled, you can’t disable clusters.

To enable clusters:

1. Navigate to the [organization’s pipeline settings](https://buildkite.com/organizations/~/pipeline-settings).
1. In _Clusters_, select _Enable Clusters_.
1. In the modal that opens, select _Enable Clusters_ to confirm.

_Clusters_ appears in the global navigation.

## Using clusters

We’ve built clusters in a way that shouldn’t affect any of your existing agents or pipelines or require any breaking changes to try out. Once enabled, all members of your organization will see _Clusters_ in the global navigation.

Your agents display under their cluster or in the unclustered view:

<%= image "clusters-views.png", alt: "Image showing clustered and unclustered views" %>

You can still access your agent and its count by selecting _Clusters_ > _All Agents_.

Once you create a cluster, copy the auto-generated token for your agents and add it to the agents in the cluster. If you want to use a custom token, edit the token in the _Agent Tokens_ tab:

<%= image "agent-registration-tokens-views.png", alt: "Image showing Agent Tokens view" %>

You can add teams and individual users under Maintainers for that cluster.

Clusters can be created through the Buildkite dashboard, the REST API, or the GraphQL API. If you migrate all your existing agents over to clusters, be sure to modify all your pipelines to belong in the cluster. Otherwise, any builds created (either manually, using source code, or schedules) will never find any agents to run their builds.

### Adding pipelines to clusters

Adding a pipeline to a cluster ensures jobs for the pipeline only run on agents in the cluster.

To add a pipeline to a cluster:

1. Navigate to the _Pipeline Settings_ for the pipeline.
1. In the _Cluster Settings_, select the relevant cluster.
