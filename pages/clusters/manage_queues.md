# Manage queues

This page provides details on how to manage queues within a [cluster](/docs/clusters/manage-clusters) of your Buildkite organization.

## Setting up queues

When a new Buildkite organization is created, along with the automatically created [default cluster](/docs/clusters/manage-clusters#setting-up-clusters) (named _Default cluster_), a default queue (named _default-queue_) within this cluster is also created.

A cluster can be configured with multiple queues, each of which can be used to represent a specific combination of your build infrastructure, based on:

- Architecture (x86-64, arm64, Apple silicon, etc.)
- Size of agents (small, medium, large)
- Type of machine (Mac, Linux, Windows, etc.)

Some example queues might be `mac_medium_x86`, `mac_large_silicon`, etc.

Having individual queues according to these breakdowns allows you to scale a set of similar agents, which Buildkite can then report on.

## Create a queue

New queues can be created using the [_Queues_ page of a cluster](#create-a-queue-using-the-buildkite-interface), as well as the [REST API's](#create-a-queue-using-the-rest-api) or [GraphQL API's](#create-a-queue-using-the-graphql-api) create a queue feature.

For these API requests, the _cluster ID_ value submitted in the request is the target cluster the queue will be created in.

When you [create a new cluster](/docs/clusters/manage-clusters#create-a-cluster) through the [Buildkite interface](/docs/clusters/manage-clusters#create-a-cluster-using-the-buildkite-interface), this cluster automatically has an initial _default_ queue.

### Using the Buildkite interface

To create a new queue using the Buildkite interface:

1. Select _Agents_ in the global navigation to access the _Clusters_ page.
1. Select the cluster in which to create the new queue.
1. On the _Queues_ page, select _New Queue_.
1. Enter a _key_ for the queue, which can only contain letters, numbers, hyphens, and underscores, as valid characters.
1. Select the _Add description_ checkbox to enter an optional longer description for the queue. This description appears under the queue's key, which is listed on the _Queues_ page, as well as when viewing the queue's details.
1. Select _Create Queue_.

    The new queue's details are displayed, indicating the queue's key and its description (if configured) underneath this key. Select _Queues_ on the interface again to list all configured queues in your cluster.

### Using the REST API

To [create a new queue](/docs/apis/rest-api/clusters#queues-create-a-queue) using the [REST API](/docs/apis/rest-api), run the following example `curl` command:

```curl
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/queues" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "mac_large_silicon",
    "description": "The queue for powerful macOS agents running on Apple silicon architecture."
  }'
```

where:

<%= render_markdown partial: 'apis/descriptions/rest_access_token' %>

<%= render_markdown partial: 'apis/descriptions/rest_org_slug' %>

<%= render_markdown partial: 'apis/descriptions/rest_cluster_id' %>

<%= render_markdown partial: 'apis/descriptions/common_create_queue_fields' %>

### Using the GraphQL API

To [create a new queue](/docs/apis/graphql/schemas/mutation/clusterqueuecreate) using the [GraphQL API](/docs/apis/graphql-api), run the following example mutation:

```graphql
mutation {
  clusterQueueCreate(
    input: {
      organizationId: "organization-id"
      clusterId: "cluster-id"
      key: "mac_large_silicon"
      description: "The queue for powerful macOS agents running on Apple silicon architecture."
    }
  ) {
    clusterQueue {
      id
      uuid
      key
      description
      dispatchPaused
      createdBy {
        id
        uuid
        name
        email
        avatar {
          url
        }
      }
    }
  }
}
```

where:

<%= render_markdown partial: 'apis/descriptions/graphql_organization_id' %>

<%= render_markdown partial: 'apis/descriptions/graphql_cluster_id' %>

<%= render_markdown partial: 'apis/descriptions/common_create_queue_fields' %>

## Pause and resume a queue

You can pause a queue to prevent any jobs of the cluster's pipelines from being dispatched to agents associated with this queue.

> 📘 Enterprise feature
> Queue pausing is only available to Buildkite customers with [Pro and Enterprise](https://buildkite.com/pricing) plans.

To pause a queue:

1. Select _Agents_ in the global navigation to access the _Clusters_ page.
1. Select the cluster with the queue to pause.
1. On the _Queues_ page, select the queue to pause.
1. On the queue's details page, select _Pause Queue_.
1. Enter an optional note in the confirmation dialog, and select _Pause Queue_ to pause the queue.

    **Note:** Use this note to explain why you're pausing the queue. The note will be displayed on the queue's details page and on any affected builds.

Jobs _already_ dispatched to agents in the queue before pausing will continue to run. New jobs that target the paused queue will wait until the queue is resumed.

Since [trigger steps](/docs/pipelines/trigger-step) do not rely on agents, these steps will run, unless they have dependencies waiting on the paused queue. The behavior of the triggered jobs depends on their configuration:

- If a triggered job targets a paused queue, the job will wait until the queue is resumed.
- If a triggered job does not target the paused queue, the job will run as usual.

To resume a queue:

1. Select _Agents_ in the global navigation to access the _Clusters_ page.
1. Select the cluster with the queue to resume.
1. On the _Queues_ page, select the queue to resume.
1. On the queue's details page, select _Resume Queue_.

    Jobs will resume being dispatched to the resumed queue as usual, including any jobs waiting to run.
