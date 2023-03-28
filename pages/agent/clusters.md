# Clusters

Clusters are a new way of managing your Buildkite agents. They allow teams to self-manage their agent pools, let admins create isolated sets of agents and pipelines within the one Buildkite organization, and help to make agents and queues more discoverable across your organization.

The following diagram shows the architectural change when enabling clusters.

<%= image "clusters-architecture.png", alt: "Diagram showing existing architecture and architecture with clusters" %>

Clusters encapsulate groups of agents and pipelines, enabling the following:

* Clusters are viewable to your entire organization, allowing engineers to better understand the agents and queues available for their pipelines.
* Individual users or teams can maintain their own clusters. Cluster maintainers can manage queues and agent tokens and add and remove pipelines.
* Pipelines can be assigned to a cluster, ensuring their builds run only on the agents connected to this cluster. These pipelines can also trigger builds only on other pipelines in the same cluster.

## Enabling clusters

Any Buildkite administrator can enable clusters for an organization. Once you enable clusters, you can only disable them by contacting support.

To enable clusters:

1. Navigate to your [organization’s pipeline settings](https://buildkite.com/organizations/~/pipeline-settings).
1. In _Clusters_, select _Enable Clusters_.

_Clusters_ will now appear in the global navigation.

## Using clusters alongside unclustered agents and pipelines

Enabling clusters will not impact any of your existing agents or pipelines, nor will you require any workflow-breaking changes for you to try clusters.

Once you’ve enabled clusters, all members of your organization will see _Clusters_ in the global navigation. This will show all your clusters as well as _Unclustered_ agents and pipelines.

Any agents or pipelines not associated with a cluster are called _unclustered_. To view and manage your unclustered agents, agent tokens, and pipelines, select _Unclustered_.

To view all running agents in your organization (in a cluster or not), click on _All agents_ in the sidebar.

## Setting up a cluster

To set up a new cluster:

1. Navigate to _Clusters_.
1. Select _Create a Cluster_.
1. Enter a name, description, and emoji.
1. Select _Create Cluster_.

### Setting up queues

When you create your first cluster, it will have an initial _default_ queue.

To create additional queues:

1. Navigate to the cluster’s _Queues_.
1. Select _Create a Queue_.
1. Enter a key and description.
1. Select _Create Queue_.

For agents to run jobs in a particular queue, [supply the queue’s key](/docs/agent/v3/queues#setting-an-agents-queue) to the agents.

### Using cluster agent tokens

Once you’ve created your cluster and queues, navigate to the cluster’s _Agent tokens_, copy the auto-generated token and [use this token](/docs/agent/v3/tokens#using-and-storing-tokens) for the agents you wish to connect to the cluster.

You can also create, edit, and revoke other agent tokens here.

### Adding pipelines to a cluster

Add a pipeline to a cluster to ensure the pipeline’s builds run only on agents connected to that cluster.

To add a pipeline to a cluster:

1. Navigate to the _Pipeline Settings_ for the pipeline.
1. Under _Cluster Settings_, select the relevant cluster.

### Adding maintainers to a cluster

Only Buildkite administrators or users with the [_change organization_ permission](/docs/pipelines/permissions) can create clusters.

You can assign other users or teams as a cluster’s maintainers to permit them to manage the cluster. Cluster maintainers can:

* Update or delete the cluster.
* Manage cluster agent tokens.
* Add or remove pipelines to the cluster.

To add a maintainer to a cluster:

1. Navigate to the cluster’s _Maintainers_.
1. Select a user or team.
1. Click _Add Maintainer_.

## Migrating to clusters

If you migrate all your existing agents over to clusters, make sure to add all your pipelines to the relevant clusters. Otherwise, any builds for those pipelines will never find agents to run them.
