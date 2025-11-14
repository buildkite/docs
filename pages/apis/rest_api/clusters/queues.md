# Queues

[Queues](/docs/pipelines/clusters/manage-queues) define discrete groups of agents within a [Buildkite cluster](/docs/pipelines/clusters). Pipelines in that cluster can target queues to run jobs on agents assigned to those queues.

## Queue data model

<table class="responsive-table">
  <tbody>
    <tr><th><code>id</code></th><td>ID of the queue</td></tr>
    <tr><th><code>graphql_id</code></th><td><a href="/docs/apis/graphql-api#graphql-ids">GraphQL ID</a> of the queue</td></tr>
    <tr><th><code>key</code></th><td>The queue key</td></tr>
    <tr><th><code>description</code></th><td>Description of the queue</td></tr>
    <tr><th><code>url</code></th><td>Canonical API URL of the queue</td></tr>
    <tr><th><code>web_url</code></th><td>URL of the queue on Buildkite</td></tr>
    <tr><th><code>cluster_url</code></th><td>API URL of the cluster the queue belongs to</td></tr>
    <tr><th><code>dispatch_paused</code></th><td>Indicates whether the queue has paused dispatching jobs to associated agents</td></tr>
    <tr><th><code>dispatch_paused_by</code></th><td>User who paused the queue</td></tr>
    <tr><th><code>dispatch_paused_at</code></th><td>When the queue was paused</td></tr>
    <tr><th><code>dispatch_paused_note</code></th><td>The note left when the queue was paused</td></tr>
    <tr><th><code>created_at</code></th><td>When the queue was created</td></tr>
    <tr><th><code>created_by</code></th><td>User who created the queue</td></tr>
  </tbody>
</table>

## List queues

Returns a [paginated list](<%= paginated_resource_docs_url %>) of a cluster's queues.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/queues"
```

```json
[
  {
    "id": "01885682-55a7-44f5-84f3-0402fb452e66",
    "graphql_id": "Q2x1c3Rlci0tLTQyZjFhN2RhLTgxMmQtNDQzMC05M2Q4LTFjYzdjMzNhNmJjZg==",
    "key": "default",
    "description": "The default queue for this cluster",
    "url": "http://api.buildkite.com/v2/organizations/test/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues/01885682-55a7-44f5-84f3-0402fb452e66",
    "web_url": "http://buildkite.com/organizations/test/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues/01885682-55a7-44f5-84f3-0402fb452e66",
    "cluster_url": "http://api.buildkite.com/v2/organizations/test/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
    "agent_retry_affinity": "prefer-warmest",
    "dispatch_paused": false,
    "dispatch_paused_by": null,
    "dispatch_paused_at": null,
    "dispatch_paused_note": null,
    "created_at": "2023-05-03T04:17:55.867Z",
    "created_by": {
      "id": "0187dfd4-92cf-4b01-907b-1146c8525dde",
      "graphql_id": "VXNlci0tLTAxODdkZmQ0LTkyY2YtNGIwMS05MDdiLTExNDZjODUyNWRkZQ==",
      "name": "Sam Kim",
      "email": "sam@example.com",
      "avatar_url": "https://www.gravatar.com/avatar/example",
      "created_at": "2023-05-03T04:17:43.118Z"
    }
  }
]
```

Required scope: `read_clusters`

Success response: `200 OK`

## Get a queue

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/queues/{queue.id}"
```

```json
{
  "id": "01885682-55a7-44f5-84f3-0402fb452e66",
  "graphql_id": "Q2x1c3Rlci0tLTQyZjFhN2RhLTgxMmQtNDQzMC05M2Q4LTFjYzdjMzNhNmJjZg==",
  "key": "default",
  "description": "The default queue for this cluster",
  "url": "http://api.buildkite.com/v2/organizations/test/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues/01885682-55a7-44f5-84f3-0402fb452e66",
  "web_url": "http://buildkite.com/organizations/test/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues/01885682-55a7-44f5-84f3-0402fb452e66",
  "cluster_url": "http://api.buildkite.com/v2/organizations/test/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "agent_retry_affinity": "prefer-warmest",
  "dispatch_paused": false,
  "dispatch_paused_by": null,
  "dispatch_paused_at": null,
  "dispatch_paused_note": null,
  "created_at": "2023-05-03T04:17:55.867Z",
  "created_by": {
    "id": "0187dfd4-92cf-4b01-907b-1146c8525dde",
    "graphql_id": "VXNlci0tLTAxODdkZmQ0LTkyY2YtNGIwMS05MDdiLTExNDZjODUyNWRkZQ==",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2023-05-03T04:17:43.118Z"
  }
}
```

Required scope: `read_clusters`

Success response: `200 OK`

## Create a self-hosted queue

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/queues" \
  -H "Content-Type: application/json" \
  -d '{ "key": "default", "description": "The default queue for this cluster" }'
```

```json
{
  "id": "01885682-55a7-44f5-84f3-0402fb452e66",
  "graphql_id": "Q2x1c3Rlci0tLTQyZjFhN2RhLTgxMmQtNDQzMC05M2Q4LTFjYzdjMzNhNmJjZg==",
  "key": "default",
  "description": "The default queue for this cluster",
  "url": "http://api.buildkite.com/v2/organizations/test/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues/01885682-55a7-44f5-84f3-0402fb452e66",
  "web_url": "http://buildkite.com/organizations/test/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues/01885682-55a7-44f5-84f3-0402fb452e66",
  "cluster_url": "http://api.buildkite.com/v2/organizations/test/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "dispatch_paused": false,
  "dispatch_paused_by": null,
  "dispatch_paused_at": null,
  "dispatch_paused_note": null,
  "created_at": "2023-05-03T04:17:55.867Z",
  "created_by": {
    "id": "0187dfd4-92cf-4b01-907b-1146c8525dde",
    "graphql_id": "VXNlci0tLTAxODdkZmQ0LTkyY2YtNGIwMS05MDdiLTExNDZjODUyNWRkZQ==",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2023-05-03T04:17:43.118Z"
  }
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr><th><code>key</code></th><td>Key for the queue.<br><em>Example:</em> <code>"default"</code>
</tbody>
</table>

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr><th><code>description</code></th><td>Description for the queue.<br><em>Example:</em> <code>"The default queue for this cluster"</code>
  <tr><th><code>retry_agent_affinity</code></th><td>Controls how agents are selected for retries. Must be one of <code>prefer-warmest</code> or <code>prefer-different</code>.<br><em>Example:</em> <code>"prefer-warmest"</code></td></tr>
</tbody>
</table>

Required scope: `write_clusters`

Success response: `201 Created`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Validation failed: Reason for failure" }</code></td></tr>
</tbody>
</table>

## Create a Buildkite hosted queue

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/queues" \
  -H "Content-Type: application/json" \
  -d '{ "key": "default", "description": "Queue of hosted Buildkite agents", "hostedAgents": { "instanceShape": "LINUX_AMD64_2X4" } }'
```

```json
{
  "id": "01885682-55a7-44f5-84f3-0402fb452e66",
  "graphql_id": "Q2x1c3Rlci0tLTQyZjFhN2RhLTgxMmQtNDQzMC05M2Q4LTFjYzdjMzNhNmJjZg==",
  "key": "default",
  "description": "Queue of hosted Buildkite agents",
  "url": "http://api.buildkite.com/v2/organizations/test/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues/01885682-55a7-44f5-84f3-0402fb452e66",
  "web_url": "http://buildkite.com/organizations/test/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues/01885682-55a7-44f5-84f3-0402fb452e66",
  "cluster_url": "http://api.buildkite.com/v2/organizations/test/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "dispatch_paused": false,
  "dispatch_paused_by": null,
  "dispatch_paused_at": null,
  "dispatch_paused_note": null,
  "created_at": "2023-05-03T04:17:55.867Z",
  "created_by": {
    "id": "0187dfd4-92cf-4b01-907b-1146c8525dde",
    "graphql_id": "VXNlci0tLTAxODdkZmQ0LTkyY2YtNGIwMS05MDdiLTExNDZjODUyNWRkZQ==",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2023-05-03T04:17:43.118Z"
  },
  "hosted": true,
  "hosted_agents": {
    "instance_shape": {
      "machine_type": "linux",
      "architecture": "amd64",
      "cpu": 2,
      "memory": 4,
      "name": "LINUX_AMD64_2X4"
    }
  }
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr><th><code>key</code></th><td>Key for the queue.<br><em>Example:</em> <code>"default"</code>
</tbody>
</table>

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr><th><code>description</code></th><td>Description for the queue.<br><em>Example:</em> <code>"The default queue for this cluster"</code>
  <tr>
    <th><code>hostedAgents</code></th>
    <td>
      Configures this queue to use <a href="/docs/pipelines/hosted-agents">Buildkite hosted agents</a>, along with its <em>instance shape</em>. This makes the queue a <a href="/docs/pipelines/clusters/manage-queues#create-a-buildkite-hosted-queue">Buildkite hosted queue</a>.
      <br>
      <em>Example:</em>
      <br/>
      <code>
        { "instanceShape": "LINUX_AMD64_2X4" }
      </code>
      <br/>
      <code>instanceShape</code> (required when <code>hostedAgents</code> is specified): Describes the machine type, architecture, CPU, and RAM to provision for Buildkite hosted agent instances running jobs in this queue.
      <br/>
      Learn more about the instance shapes available for <a href="#instance-shape-values-for-linux">Linux</a> and <a href="#instance-shape-values-for-macos">macOS</a> hosted agents.
  </td>
  </tr>
</tbody>
</table>

Required scope: `write_clusters`

Success response: `201 Created`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Validation failed: Reason for failure" }</code></td></tr>
</tbody>
</table>

## Update a queue

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/queues/{id}" \
  -H "Content-Type: application/json" \
  -d '{ "description": "The default queue for this cluster" }'
```

```json
{
  "id": "01885682-55a7-44f5-84f3-0402fb452e66",
  "graphql_id": "Q2x1c3Rlci0tLTQyZjFhN2RhLTgxMmQtNDQzMC05M2Q4LTFjYzdjMzNhNmJjZg==",
  "key": "default",
  "description": "The default queue for this cluster",
  "url": "http://api.buildkite.com/v2/organizations/test/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues/01885682-55a7-44f5-84f3-0402fb452e66",
  "web_url": "http://buildkite.com/organizations/test/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues/01885682-55a7-44f5-84f3-0402fb452e66",
  "cluster_url": "http://api.buildkite.com/v2/organizations/test/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "dispatch_paused": false,
  "dispatch_paused_by": null,
  "dispatch_paused_at": null,
  "dispatch_paused_note": null,
  "created_at": "2023-05-03T04:17:55.867Z",
  "created_by": {
    "id": "0187dfd4-92cf-4b01-907b-1146c8525dde",
    "graphql_id": "VXNlci0tLTAxODdkZmQ0LTkyY2YtNGIwMS05MDdiLTExNDZjODUyNWRkZQ==",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2023-05-03T04:17:43.118Z"
  }
}
```

[Request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr><th><code>description</code></th><td>Description for the queue.<br><em>Example:</em> <code>"The default queue for this cluster"</code>
  <tr><th><code>retry_agent_affinity</code></th><td>Controls how agents are selected for retries. Must be one of <code>prefer-warmest</code> or <code>prefer-different</code>.<br><em>Example:</em> <code>"prefer-warmest"</code></td></tr>
  <tr>
    <th><code>hostedAgents</code></th>
    <td>
      Configures this queue to use <a href="/docs/pipelines/hosted-agents">Buildkite hosted agents</a>, along with its <em>instance shape</em>. This makes the queue a <a href="/docs/pipelines/clusters/manage-queues#create-a-buildkite-hosted-queue">Buildkite hosted queue</a>.
      <br>
      <em>Example:</em>
      <br/>
      <code>
        { "instanceShape": "LINUX_AMD64_2X4" }
      </code>
      <br/>
      <code>instanceShape</code> (required when <code>hostedAgents</code> is specified): Describes the machine type, architecture, CPU, and RAM to provision for Buildkite hosted agent instances running jobs in this queue.
      <br/>
      It is only possible to change the <em>size</em> of the current instance shape assigned to this queue. It is not possible to change the current instance shape's machine type (from macOS to Linux, or vice versa), or for a Linux machine, its architecture (from AMD64 to ARM64, or vice versa).<br/>
      Learn more about the instance shapes available for <a href="#instance-shape-values-for-linux">Linux</a> and <a href="#instance-shape-values-for-macos">macOS</a> Buildkite hosted agents.
  </td>
  </tr>
</tbody>
</table>

Required scope: `write_clusters`

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Validation failed: Reason for failure" }</code></td></tr>
</tbody>
</table>

## Delete a queue

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/queues/{id}"
```

Required scope: `write_clusters`

Success response: `204 No Content`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Reason the queue couldn't be deleted" }</code></td></tr>
</tbody>
</table>

## Pause a queue

[Pause a queue](/docs/pipelines/clusters/manage-queues#pause-and-resume-a-queue) to prevent jobs from being dispatched to agents associated with the queue.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/queues/{id}/pause_dispatch" \
  -H "Content-Type: application/json" \
  -d '{ "dispatch_paused_note": "Paused while we investigate a security issue" }'
```

```json
{
  "id": "01885682-55a7-44f5-84f3-0402fb452e66",
  "graphql_id": "Q2x1c3Rlci0tLTQyZjFhN2RhLTgxMmQtNDQzMC05M2Q4LTFjYzdjMzNhNmJjZg==",
  "key": "default",
  "description": "The default queue for this cluster",
  "url": "http://api.buildkite.com/v2/organizations/test/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues/01885682-55a7-44f5-84f3-0402fb452e66",
  "web_url": "http://buildkite.com/organizations/test/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues/01885682-55a7-44f5-84f3-0402fb452e66",
  "cluster_url": "http://api.buildkite.com/v2/organizations/test/clusters/01885682-55a7-44f5-84f3-0402fb452e66",
  "dispatch_paused": true,
  "dispatch_paused_by": {
    "id": "0187dfd4-92cf-4b01-907b-1146c8525dde",
    "graphql_id": "VXNlci0tLTAxODdkZmQ0LTkyY2YtNGIwMS05MDdiLTExNDZjODUyNWRkZQ==",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2023-05-03T04:17:43.118Z"
  },
  "dispatch_paused_at": "2023-05-03T04:19:43.118Z",
  "dispatch_paused_note": "Paused while we investigate a security issue",
  "created_at": "2023-05-03T04:17:55.867Z",
  "created_by": {
    "id": "0187dfd4-92cf-4b01-907b-1146c8525dde",
    "graphql_id": "VXNlci0tLTAxODdkZmQ0LTkyY2YtNGIwMS05MDdiLTExNDZjODUyNWRkZQ==",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2023-05-03T04:17:43.118Z"
  }
}
```

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>note</code></th>
    <td>
      Note explaining why the queue is paused. The note will display on the queue page and any affected builds.
      <br><em>Example:</em> <code>"Paused while we investigate a security issue"</code>
    </td>
  </tr>
</tbody>
</table>

Required scope: `write_clusters`

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Cluster queue is already paused" }</code></td></tr>
</tbody>
</table>

## Resume a paused queue

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/queues/{id}/resume_dispatch" \
  -H "Content-Type: application/json"
```

```json
{
  "id": "01885682-55a7-44f5-84f3-0402fb452e66",
  "graphql_id": "Q2x1c3Rlci0tLTQyZjFhN2RhLTgxMmQtNDQzMC05M2Q4LTFjYzdjMzNhNmJjZg==",
  "key": "default",
  "description": "The default queue for this cluster",
  "url": "http://api.buildkite.com/v2/organizations/test/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues/01885682-55a7-44f5-84f3-0402fb452e66",
  "web_url": "http://buildkite.com/organizations/test/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues/01885682-55a7-44f5-84f3-0402fb452e66",
  "cluster_url": "http://api.buildkite.com/v2/organizations/test/clusters/01885682-55a7-44f5-84f3-0402fb452e66",
  "dispatch_paused": false,
  "dispatch_paused_by": null,
  "dispatch_paused_at": null,
  "dispatch_paused_note": null,
  "created_at": "2023-05-03T04:17:55.867Z",
  "created_by": {
    "id": "0187dfd4-92cf-4b01-907b-1146c8525dde",
    "graphql_id": "VXNlci0tLTAxODdkZmQ0LTkyY2YtNGIwMS05MDdiLTExNDZjODUyNWRkZQ==",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2023-05-03T04:17:43.118Z"
  }
}
```

Required scope: `write_clusters`

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Cluster queue is not paused" }</code></td></tr>
</tbody>
</table>

## Instance shape values for Linux

Specify the appropriate **Instance shape** for the `instanceShape` value in your REST API call.

<%= render_markdown partial: 'shared/hosted_agents/hosted_agents_instance_shape_table_linux' %>

## Instance shape values for macOS

Specify the appropriate **Instance shape** for the `instanceShape` value in your REST API call.

<%= render_markdown partial: 'shared/hosted_agents/hosted_agents_instance_shape_table_mac' %>
