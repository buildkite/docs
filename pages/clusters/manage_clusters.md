# Manage clusters

This page provides instructions for common tasks when managing clusters.

## Set up clusters

Follow these instructions when setting up a cluster.

### Create a cluster

To create a new cluster:

1. Navigate to _Clusters_.
1. Select _Create a Cluster_.
1. Enter a name, description, and emoji.
1. Select _Create Cluster_.

### Create a queue

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
1. Select _New Token_.
1. Enter a description.
1. Select _Create Token_.
1. Select _Copy to Clipboard_ and save the token somewhere secure.
1. Select _Okay, I'm done!_
1. [Use the token](/docs/agent/v3/tokens#using-and-storing-tokens) with the relevant agents, along with [the key from the relevant cluster queue](/docs/agent/v3/queues#setting-an-agents-queue).

You can also create, edit, and revoke other agent tokens from the cluster’s _Agent tokens_.

### Add pipelines to a cluster

Add a pipeline to a cluster to ensure the pipeline’s builds run only on agents connected to that cluster.

To add a pipeline to a cluster:

1. Navigate to the _Pipeline Settings_ for the pipeline.
1. Under _Cluster Settings_, select the relevant cluster.

### Add maintainers to a cluster

Only Buildkite administrators or users with the [_change organization_ permission](/docs/team-management/permissions) can create clusters.

You can assign other users or teams as a cluster’s maintainers to permit them to manage the cluster. Cluster maintainers can:

- Update or delete the cluster.
- Manage cluster agent tokens.
- Add or remove pipelines to the cluster.

To add a maintainer to a cluster:

1. Navigate to the cluster’s _Maintainers_.
1. Select a user or team.
1. Click _Add Maintainer_.

### Restrict access for a cluster token by IP address

Each cluster token can be locked down so that only agents with an allowed IP address can use them to register.

You can set the _Allowed IP Addresses_ when creating a token, or you can modify existing tokens:

1. Navigate to the cluster's _Agent Tokens_.
1. Select the token to which you wish to restrict access.
1. Select _Edit_.
1. Update the _Allowed IP Addresses_ setting, using space-separated [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing).
1. Select _Save Token_.

Modifying the _Allowed IP Addresses_ forcefully disconnects any existing agents with IP addresses outside the updated value. This prevents the completion of any jobs in progress on those agents.

Note the following limitations:

- This setting does not restrict access to the [Metrics API](/docs/apis/agent-api/metrics) for the given cluster token.
- There is a maximum of 24 CIDR blocks per agent token.
- IPv6 is currently not supported.

### Migrate to clusters

If you migrate all your existing agents over to clusters, make sure to add all your pipelines to the relevant clusters. Otherwise, any builds for those pipelines will never find agents to run them.

## Pause a queue

> 📘 Enterprise feature
> Cluster queue pausing is only available on [Pro and Enterprise](https://buildkite.com/pricing) plans.

You can pause a queue to prevent jobs from being dispatched to agents associated with that queue.

To pause a queue:

1. Navigate to your cluster’s _Queues_.
1. Select the queue you wish to pause.
1. Select _Pause_.
1. Enter an optional note in the dialog, and confirm that you wish to pause the queue.

   You can use the note to explain why you're pausing the queue. The note will display on the queue page and any affected builds.

Jobs _already_ dispatched to agents in the queue before pausing will continue to run. New jobs that target the paused queue will wait until the queue is resumed.

Trigger steps do not rely on agents, so they will run unless they have dependencies waiting on the paused queue. The behavior of the jobs they trigger depends on their configuration. If a triggered job targets the paused queue, it will wait until the queue is resumed. If a triggered job does not target the paused queue, it will run as usual.

Select _Resume Queue_ to resume a paused queue. Jobs will resume dispatching to the queue as usual, including any jobs waiting to run.
