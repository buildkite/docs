# Manage queues

This page provides details on how to manage queues within a [cluster](/docs/clusters/manage-clusters) of your Buildkite organization.

## Setting up queues

When a new Buildkite organization is created, along with the automatically created [default cluster](/docs/clusters/manage-clusters#setting-up-clusters) (named _Default cluster_), a default queue (named _default-queue_) within this cluster is also created.

A cluster can be configured with multiple queues, each of which can be used to represent a specific combination of your build infrastructure, based on:

- Architecture (x86-64, arm64, Apple silicon, etc.)
- Size of agents (small, medium, large)
- Type of machine (Mac, Linux, Windows, etc.)

Therefore, some example queues might be `mac_medium_x86`, `mac_large_silicon`, etc.

Having individual queues according to these breakdowns allows you to scale your agents that all look the same and Buildkite will report on these.

## Create a new queue

New queues can be created using the [_Queues_ page of a cluster](#create-a-new-queue-using-the-buildkite-interface), or the [REST API's create a queue](#create-a-new-queue-using-the-rest-api) feature.

When you [create a new cluster](/docs/clusters/manage-clusters#create-a-new-cluster) through the [Buildkite interface](/docs/clusters/manage-clusters#create-a-new-cluster-using-the-buildkite-interface), this cluster automatically has an initial _default_ queue.

### Using the Buildkite interface

To create a new queue using the Buildkite interface:

1. Select _Agents_ in the global navigation to access the _Clusters_ page.
1. Select the cluster in which to create the new queue.
1. On the _Queues_ page, select _New Queue_.
1. Enter a _key_ for the queue, which can only contain letters, numbers, hyphens, and underscores, as valid characters.
1. Select the _Add description_ checkbox to enter an optional description for the queue. This description appears under the queue's key, which is listed on the _Queues_ page, as well as when viewing the queue's details.
1. Select _Create Queue_.

    The new queue's details are displayed, indicating the queue's key and its description (if configured).

### Using the REST API



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
