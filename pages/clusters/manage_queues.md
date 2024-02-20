# Manage queues

This page provides details on how to manage queues within a [cluster](/docs/clusters/manage-clusters) of your Buildkite organization.

## Setting up queues

When a new Buildkite organization is created, along with the automatically created [default cluster](/docs/clusters/manage-clusters#setting-up-clusters) (named _Default cluster_), a default queue (named _default-queue_) within this cluster is also created.

A cluster can be configured with multiple queues, each of which represents a specific combination of your build infrastructure.

- Architecture (x86, arm64 etc)
- Size of agents (small, medium, large)
- Type of machine (Mac, GPU, Linux, Windows)

So an example queue would be `small_mac_silicon`.

Having individual queues according to these breakdowns allows you to scale your agents that all look the same and Buildkite will report on these

## Create a queue

When you create your first cluster, it will have an initial _default_ queue.

To create additional queues:

1. Navigate to the cluster’s _Queues_.
1. Select _Create a Queue_.
1. Enter a key and description.
1. Select _Create Queue_.

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
