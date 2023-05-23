# Clusters

Clusters are a new way of managing your Buildkite agents. They allow teams to self-manage their agent pools, let admins create isolated sets of agents and pipelines within the one Buildkite organization, and help to make agents and queues more discoverable across your organization.

The following diagram shows the architectural change when enabling clusters.

<%= image "clusters-architecture.png", alt: "Diagram showing existing architecture and architecture with clusters" %>

Clusters encapsulate groups of agents and pipelines, enabling the following:

* Clusters are viewable to your entire organization, allowing engineers to better understand the agents and queues available for their pipelines.
* Individual users or teams can maintain their own clusters. Cluster maintainers can manage queues and agent tokens and add and remove pipelines.
* Pipelines can be assigned to a cluster, ensuring their builds run only on the agents connected to this cluster. These pipelines can also trigger builds only on other pipelines in the same cluster.

## Enable clusters

Any Buildkite administrator can enable clusters for an organization. Once you enable clusters, you can only disable them by contacting support.

To enable clusters:

1. Navigate to your [organization’s pipeline settings](https://buildkite.com/organizations/~/pipeline-settings).
1. In _Clusters_, select _Enable Clusters_.

_Clusters_ will now appear in the global navigation.

### Use clusters alongside unclustered agents and pipelines

Enabling clusters will not impact any of your existing agents or pipelines, nor will you require any workflow-breaking changes for you to try clusters.

Once you’ve enabled clusters, all members of your organization will see _Clusters_ in the global navigation. This will show all your clusters as well as _Unclustered_ agents and pipelines.

Any agents or pipelines not associated with a cluster are called _unclustered_. To view and manage your unclustered agents, agent tokens, and pipelines, select _Unclustered_.

To view all running agents in your organization (in a cluster or not), click on _All agents_ in the sidebar.

## Set up a cluster

To set up a new cluster:

1. Navigate to _Clusters_.
1. Select _Create a Cluster_.
1. Enter a name, description, and emoji.
1. Select _Create Cluster_.

### Set up queues

When you create your first cluster, it will have an initial _default_ queue.

To create additional queues:

1. Navigate to the cluster’s _Queues_.
1. Select _Create a Queue_.
1. Enter a key and description.
1. Select _Create Queue_.

### Connect agents to a cluster

Agents are associated with a cluster through the cluster’s agent tokens.

To connect an agent:

1. Navigate to the cluster's _Agent tokens_.
1. Copy the auto-generated token.
1. [Use the token](/docs/agent/v3/tokens#using-and-storing-tokens) with the relevant agents, along with [the key from the relevant cluster queue](/docs/agent/v3/queues#setting-an-agents-queue).

You can also create, edit, and revoke other agent tokens from the cluster’s _Agent tokens_.

### Add pipelines to a cluster

Add a pipeline to a cluster to ensure the pipeline’s builds run only on agents connected to that cluster.

To add a pipeline to a cluster:

1. Navigate to the _Pipeline Settings_ for the pipeline.
1. Under _Cluster Settings_, select the relevant cluster.

### Add maintainers to a cluster

Only Buildkite administrators or users with the [_change organization_ permission](/docs/pipelines/permissions) can create clusters.

You can assign other users or teams as a cluster’s maintainers to permit them to manage the cluster. Cluster maintainers can:

* Update or delete the cluster.
* Manage cluster agent tokens.
* Add or remove pipelines to the cluster.

To add a maintainer to a cluster:

1. Navigate to the cluster’s _Maintainers_.
1. Select a user or team.
1. Click _Add Maintainer_.

### Pause a queue

You can pause a queue to prevent jobs from being dispatched to agents associated with that queue.
To pause a queue:

1. Navigate to your cluster’s _Queues_.
1. Select on the queue you wish to pause.
1. Select _Edit_.
1. Under _Queue Management_, select _Pause Queue_.
1. Enter an optional note in the dialog if needed, and confirm that you wish to pause the queue. The note will be displayed on the queue page, and any affected builds.

Jobs which have _already_ been dispatched to agents in the queue prior to pausing will continue to run. New jobs which target the paused queue will 'wait' until the queue is resumed.

Trigger steps do not rely on agents, so they will run unless they have a dependency that has been halted by the paused queue. The behaviour of the jobs they trigger depends on their configuration. If a triggered job targets the paused queue, it will 'wait' until the queue is resumed. If a triggered job does not target the pasued queue, it will run as usual.

To resume the queue again, select _Resume Queue_. Once resumed, job dispatch to the queue will operate as usual, and any 'waiting' jobs affected by the pause will be picked up.

### Migrate to clusters

If you migrate all your existing agents over to clusters, make sure to add all your pipelines to the relevant clusters. Otherwise, any builds for those pipelines will never find agents to run them.
