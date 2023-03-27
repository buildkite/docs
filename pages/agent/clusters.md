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

Any administrator can enable clusters for an organization. Once you enable clusters, you can only disable it by contacting support.

To enable clusters:

1. Navigate to your [organization’s pipeline settings](https://buildkite.com/organizations/~/pipeline-settings).
1. In _Clusters_, select _Enable Clusters_.

_Clusters_ will now appear in the global navigation.

## Setting up a cluster

To set up a new cluster:

1. Navigate to _Clusters_
2. Click _Create a Cluster_
3. Enter a name, description and emoji
4. Click _Create Cluster_

### Setting up queues

When you create your first cluster, it will have an initial “default” queue.

To create additional queues:

1. Navigate to the cluster’s _Queues_
2. Click _Create a Queue_
3. Enter a key and description
4. Click _Create Queue_

You should [supply the queue’s key][agent-queue-key] to the agents that you wish to run build jobs on the queue.

[agent-queue-key]: http://localhost:3000/docs/agent/v3/queues#setting-an-agents-queue

### Using cluster agent tokens

Once you’ve created your cluster and queues, navigate to the cluster’s _Agent tokens_, copy the auto-generated token and [use this token][agent-use-token] for the agents you wish to connect to the cluster.

You can also create, edit, and revoke other cluster agent tokens in this area.

[agent-use-token]: /docs/agent/v3/tokens#using-and-storing-tokens

### Adding pipelines to a cluster

Add a pipeline to a cluster to ensure the pipeline’s builds run only on agents connected to that cluster.

To add a pipeline to a cluster:

1. Navigate to the _Pipeline Settings_ for the pipeline.
1. Under _Cluster Settings_, select the relevant cluster.

### Adding maintainers to a cluster

Only Buildkite admins or users with the [“change organization” permission][permissions] can create clusters.

Afterwards, you can assign other users or teams as a cluster’s maintainers to permit them to manage the cluster. Cluster maintainers can:

* Update or delete the cluster
* Manage cluster agent tokens
* Add or remove pipelines to the cluster

To add a maintainer to a cluster:

1. Navigate to the cluster’s _Maintainers_
2. Select a user or team
3. Click _Add Maintainer_

[permissions]: /docs/pipelines/permissions

## Using clusters alongside unclustered agents and pipelines

Enabling clusters will not impact any of your existing agents or pipelines, or otherwise require any workflow-breaking changes to try.

Once you’ve enabled clusters, all members of your organization will see _Clusters_ in the global navigation. This will show all your clusters as well as _Unclustered_ agents and pipelines.

To view and manage your unclustered agents, agent tokens and pipelines (i.e. not conenected to any cluster), click _Unclustered._

To view all running agents in your organization (in a cluster or not), click on _All agents_ in the sidebar.

## Migrating to clusters

You can create clusters through the Buildkite dashboard, the REST API, or the GraphQL API.

If you migrate all your existing agents over to clusters, be sure to add all your pipelines to the relevant clusters. Otherwise, any builds created (either manually, using source code, or schedules) will never find any agents to run their builds.
