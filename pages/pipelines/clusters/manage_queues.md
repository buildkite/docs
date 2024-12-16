# Manage queues

This page provides details on how to manage queues within a [cluster](/docs/pipelines/clusters/manage-clusters) of your Buildkite organization.

## Setting up queues

When a new Buildkite organization is created, along with the automatically created [default cluster](/docs/pipelines/clusters/manage-clusters#setting-up-clusters) (named **Default cluster**), a default queue (named **default-queue**) within this cluster is also created.

A cluster can be configured with multiple queues, each of which can be used to represent a specific combination of your build/agent infrastructure, based on:

- Architecture (x86-64, arm64, Apple silicon, etc.)
- Size of agents (small, medium, large)
- Type of machine (Mac, Linux, Windows, etc.)

Some example queues might be `mac_medium_x86`, `mac_large_silicon`, etc.

Having individual queues according to these breakdowns allows you to scale a set of similar agents, which Buildkite can then report on.

### Agent infrastructure

As part of setting up a queue, you can choose between setting up your agents using either [hosted](/docs/pipelines/hosted-agents) or self-hosted infrastructure.

Buildkite provides a hosted infrastructure for your [Buildkite Agents](/docs/agent/v3), as well as support for self-hosted infrastructure, where you provide the infrastructure that hosts Buildkite Agents.

## Create a self-hosted queue

Self-hosted queues use your own infrastructure to run your builds. New queues can be created by a [cluster maintainer](/docs/pipelines/clusters/manage-clusters#manage-maintainers-on-a-cluster) using the [**Queues** page of a cluster](#create-a-self-hosted-queue-using-the-buildkite-interface), as well as the [REST API's](#create-a-self-hosted-queue-using-the-rest-api) or [GraphQL API's](#create-a-self-hosted-queue-using-the-graphql-api) create a queue feature.

For these API requests, the _cluster ID_ value submitted in the request is the target cluster the queue will be created in.

When you [create a new cluster](/docs/pipelines/clusters/manage-clusters#create-a-cluster) through the [Buildkite interface](/docs/pipelines/clusters/manage-clusters#create-a-cluster-using-the-buildkite-interface), this cluster automatically has an initial **default** queue.

### Using the Buildkite interface

To create a new queue using the Buildkite interface:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster in which to create the new queue.
1. On the **Queues** page, select **New Queue** to open the **Create a new Queue** page.
1. In the **Create a key** field, enter a unique _key_ for the queue, which can only contain letters, numbers, hyphens, and underscores, as valid characters.
1. Select the **Add description** checkbox to enter an optional longer description for the queue. This description appears under the queue's key, which is listed on the **Queues** page, as well as when viewing the queue's details.
1. In the **Select your agent infrastructure** section, select **Self hosted** for your agent infrastructure.
1. Select **Create Queue**.

    The new queue's details are displayed, indicating the queue's key and its description (if configured) underneath this key. Select **Queues** on the interface again to list all configured queues in your cluster.

### Using the REST API

To [create a new self-hosted agent queue](/docs/apis/rest-api/clusters#queues-create-a-self-hosted-queue) using the [REST API](/docs/apis/rest-api), run the following example `curl` command:

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

To [create a new self-hosted agent queue](/docs/apis/graphql/schemas/mutation/clusterqueuecreate) using the [GraphQL API](/docs/apis/graphql-api), run the following example mutation:

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

## Create a hosted queue

Hosted cluster queues use Buildkite's hosted agent infrastructure to run your builds. You can create a hosted queue using the [Buildkite interface](#create-a-hosted-queue-using-the-buildkite-interface), the [REST API](#create-a-hosted-queue-using-the-rest-api), or the [GraphQL API](#create-a-hosted-queue-using-the-graphql-api).

When you create a hosted queue, you can choose the machine type (Linux or macOS) and the capacity (small, medium, or large) of the hosted agents that will run your builds.

### Using the Buildkite interface

To create a new hosted queue using the Buildkite interface:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster in which to create the new queue.
1. On the **Queues** page, select **New Queue** to open the **Create a new Queue** page.
1. In the **Create a key** field, enter a unique _key_ for the queue, which can only contain letters, numbers, hyphens, and underscores, as valid characters.
1. Select the **Add description** checkbox to enter an optional longer description for the queue. This description appears under the queue's key, which is listed on the **Queues** page, as well as when viewing the queue's details.
1. In the **Select your agent infrastructure** section, select [**Hosted**](/docs/pipelines/hosted-agents) for your agent infrastructure.
1. In the new **Configure your hosted agent infrastructure** section, select your **Machine type** ([**Linux**](/docs/pipelines/hosted-agents/linux) or [**macOS**](/docs/pipelines/hosted-agents/mac)).
1. If you selected **Linux**, within **Architecture**, you can choose between **AMD64** (the default and recommended) or **ARM64** architectures for the Linux machines running as hosted agents. To switch to **ARM64**, select **Change**, followed by **ARM64 (AArch64)**.
1. Select the appropriate **Capacity** for your hosted agent machine type (**Small**, **Medium** or **Large**). Take note of the additional information provided in the new **Hosted agents trial** section, which changes based on your selected **Capacity**.
1. Select **Create Queue**.

    The new queue's details are displayed, indicating the queue's key and its description (if configured) underneath this key. Select **Queues** on the interface again to list all configured queues in your cluster.

### Using the REST API

To [create a new hosted agent queue](/docs/apis/rest-api/clusters#queues-create-a-hosted-queue) using the [REST API](/docs/apis/rest-api), run the following example `curl` command:

```curl
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/queues" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "hosted_linux_small",
    "description": "Small AMD64 Linux agents hosted by Buildkite.",
    "hosted": true,
    "hostedAgents": {
      "instanceShape": "LINUX_AMD64_2X4"
    }
  }'
```

where:

<%= render_markdown partial: 'apis/descriptions/rest_access_token' %>

<%= render_markdown partial: 'apis/descriptions/rest_org_slug' %>

<%= render_markdown partial: 'apis/descriptions/rest_cluster_id' %>

<%= render_markdown partial: 'apis/descriptions/common_create_queue_fields' %>

- `hostedAgents` - The hosted agents configuration for this queue, setting this field will make this queue a hosted queue.
  + `instanceShape` - The instance shape describes the machine type, architecture, CPU, and RAM to provision for hosted agent instances running jobs in this queue.

### Instance shapes for Linux hosted agents

<%= render_markdown partial: 'shared/hosted_agents/hosted_agents_instance_shape_table_linux' %>

### Instance shapes for Mac hosted agents

<%= render_markdown partial: 'shared/hosted_agents/hosted_agents_instance_shape_table_mac' %>

  Example:
    ```json
    "hostedAgents": {
      "instanceShape": "LINUX_AMD64_2X4"
    }
    ```


### Using the GraphQL API

To [create a new hosted agent queue](/docs/apis/graphql/schemas/mutation/clusterqueuecreate) using the [GraphQL API](/docs/apis/graphql-api), run the following example mutation:

```graphql
mutation {
  clusterQueueCreate(
    input: {
      organizationId: "organization-id"
      clusterId: "cluster-id"
      key: "hosted_linux_small"
      description: "Small AMD64 Linux agents hosted by Buildkite."
      hostedAgents: {
        instanceShape: LINUX_AMD64_2X4
      }
    }
  ) {
    clusterQueue {
      id
      uuid
      key
      description
      dispatchPaused
      hosted
      hostedAgents {
        instanceShape {
          name
          size
          vcpu
          memory
        }
      }
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

- `hosted` - Setting this field to `true` will make this queue a hosted queue. Setting this field to `false` will make this queue a self-hosted queue. Providing `hostedAgents` configuration is only valid for hosted queues and will implicitly set `hosted` to `true`.

- `hostedAgents` - The hosted agents configuration for this queue, setting this field will make this queue a hosted queue.
    `instanceShape` - The instance shape describes the machine type, architecture, CPU and RAM to provision for hosted agent instances running jobs in this queue.

    Example:

    ```graphql
    hostedAgents: {
      instanceShape: LINUX_AMD64_2X4
    }
    ```

### Instance shapes for Linux hosted agents

<%= render_markdown partial: 'shared/hosted_agents/hosted_agents_instance_shape_table_linux' %>

### Instance shapes for Mac hosted agents

<%= render_markdown partial: 'shared/hosted_agents/hosted_agents_instance_shape_table_mac' %>

## Pause and resume a queue

You can pause a queue to prevent any jobs of the cluster's pipelines from being dispatched to agents associated with this queue.

> 📘 Enterprise feature
> Queue pausing is only available to Buildkite customers with [Pro and Enterprise](https://buildkite.com/pricing) plans.

To pause a queue:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster with the queue to pause.
1. On the **Queues** page, select the queue to pause.
1. On the queue's details page, select **Pause Queue**.
1. Enter an optional note in the confirmation dialog, and select **Pause Queue** to pause the queue.

    **Note:** Use this note to explain why you're pausing the queue. The note will be displayed on the queue's details page and on any affected builds.

Jobs _already_ dispatched to agents in the queue before pausing will continue to run. New jobs that target the paused queue will wait until the queue is resumed.

Since [trigger steps](/docs/pipelines/configure/step-types/trigger-step) do not rely on agents, these steps will run, unless they have dependencies waiting on the paused queue. The behavior of the triggered jobs depends on their configuration:

- If a triggered job targets a paused queue, the job will wait until the queue is resumed.
- If a triggered job does not target the paused queue, the job will run as usual.

To resume a queue:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster with the queue to resume.
1. On the **Queues** page, select the queue to resume.
1. On the queue's details page, select **Resume Queue**.

    Jobs will resume being dispatched to the resumed queue as usual, including any jobs waiting to run.
