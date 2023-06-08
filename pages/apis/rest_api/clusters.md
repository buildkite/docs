# Clusters API

The clusters API lets you create and manage clusters in your organization.

> 📘 Enable clusters
> You'll need to [enable clusters](/docs/agent/clusters#enable-clusters) for your organization to use this API.

## Clusters

A [cluster](/docs/agent/clusters) is an isolated set of agents and pipelines within an organization.

### Cluster data model

<table class="responsive-table">
<tbody>
  <tr><th><code>id</code></th><td>ID of the cluster</td></tr>
  <tr><th><code>graphql_id</code></th><td><a href="/docs/apis/graphql-api#graphql-ids">GraphQL ID</a> of the cluster</td></tr>
  <tr><th><code>default_queue_id</code></th><td>ID of the cluster's default queue. Agents that connect to the cluster without specifying a queue will accept jobs from this queue.</td></tr>
  <tr><th><code>name</code></th><td>Name of the cluster</td></tr>
  <tr><th><code>description</code></th><td>Description of the cluster</td></tr>
  <tr><th><code>emoji</code></th><td>Emoji for the cluster using the <a href="/docs/pipelines/emojis">emoji syntax</a></td></tr>
  <tr><th><code>color</code></th><td>Color hex code for the cluster</td></tr>
  <tr><th><code>url</code></th><td>Canonical API URL of the cluster</td></tr>
  <tr><th><code>web_url</code></th><td>URL of the cluster on Buildkite</td></tr>
  <tr><th><code>queues_url</code></th><td>API URL of the cluster's queues</td></tr>
  <tr><th><code>default_queue_url</code></th><td>API URL of the cluster's default queue</td></tr>
  <tr><th><code>created_at</code></th><td>When the cluster was created</td></tr>
  <tr><th><code>created_by</code></th><td>User who created the cluster</td></tr>
</tbody>
</table>

### List clusters

Returns a [paginated list](<%= paginated_resource_docs_url %>) of an organization's clusters.

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/clusters"
```

```json
[
  {
    "id": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
    "graphql_id": "Q2x1c3Rlci0tLTQyZjFhN2RhLTgxMmQtNDQzMC05M2Q4LTFjYzdjMzNhNmJjZg==",
    "default_queue_id": "01885682-55a7-44f5-84f3-0402fb452e66",
    "name": "Open Source",
    "description": "A place for safely running our open source builds",
    "emoji": "\:technologist\:",
    "color": "#FFE0F1",
    "url": "http://api.buildkite.com/v2/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
    "web_url": "http://buildkite.com/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
    "default_queue_url": "http://api.buildkite.com/v2/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
    "queues_url": "http://buildkite.com/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues",
    "created_at": "2023-05-03T04:17:55.867Z",
    "created_by": {
      "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
      "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
      "name": "Sam Kim",
      "email": "sam@example.com",
      "avatar_url": "https://www.gravatar.com/avatar/example",
      "created_at": "2013-08-29T10:10:03.000Z"
    }
  }
]
```

Required scope: `read_clusters`

Success response: `200 OK`

### Get a cluster

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{id}"
```

```json
{
  "id": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "graphql_id": "Q2x1c3Rlci0tLTQyZjFhN2RhLTgxMmQtNDQzMC05M2Q4LTFjYzdjMzNhNmJjZg==",
  "default_queue_id": "01885682-55a7-44f5-84f3-0402fb452e66",
  "name": "Open Source",
  "description": "A place for safely running our open source builds",
  "emoji": "\:technologist\:",
  "color": "#FFE0F1",
  "url": "http://api.buildkite.com/v2/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "web_url": "http://buildkite.com/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "default_queue_url": "http://api.buildkite.com/v2/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "queues_url": "http://buildkite.com/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues",
  "created_at": "2023-05-03T04:17:55.867Z",
  "created_by": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2013-08-29T10:10:03.000Z"
  }
}
```

Required scope: `read_clusters`

Success response: `200 OK`

### Create a cluster

```bash
curl -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Open Source",
    "description": "A place for safely running our open source builds",
    "emoji": "\:technologist\:",
    "color": "#FFE0F1",
  }'
```

```json
{
  "id": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "graphql_id": "Q2x1c3Rlci0tLTQyZjFhN2RhLTgxMmQtNDQzMC05M2Q4LTFjYzdjMzNhNmJjZg==",
  "default_queue_id": null,
  "name": "Open Source",
  "description": "A place for safely running our open source builds",
  "emoji": "\:technologist\:",
  "color": "#FFE0F1",
  "url": "http://api.buildkite.com/v2/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "web_url": "http://buildkite.com/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "default_queue_url": null,
  "queues_url": "http://buildkite.com/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues",
  "created_at": "2023-05-03T04:17:55.867Z",
  "created_by": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2013-08-29T10:10:03.000Z"
  }
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr><th><code>name</code></th><td>Name for the cluster.<br><em>Example:</em> <code>"Open Source"</code>
</tbody>
</table>

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr><th><code>description</code></th><td>Description for the cluster.<br><em>Example:</em> <code>"A place for safely running our open source builds"</code>
  <tr><th><code>emoji</code></th><td>Emoji for the cluster using the <a href="/docs/pipelines/emojis">emoji syntax</a>.<br><em>Example:</em> <code>"\:technologist\:"</code>
  <tr><th><code>color</code></th><td>Color hex code for the cluster.<br><em>Example:</em> <code>"#FFE0F1"</code>
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

### Update a cluster

```bash
curl -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/clusters" \
  -H "Content-Type: application/json" \
  -d '{ "name": "Open Source" }'
```

```json
{
  "id": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "graphql_id": "Q2x1c3Rlci0tLTQyZjFhN2RhLTgxMmQtNDQzMC05M2Q4LTFjYzdjMzNhNmJjZg==",
  "default_queue_id": "01885682-55a7-44f5-84f3-0402fb452e66",
  "name": "Open Source",
  "description": "A place for safely running our open source builds",
  "emoji": "\:technologist\:",
  "color": "#FFE0F1",
  "url": "http://api.buildkite.com/v2/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "web_url": "http://buildkite.com/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "default_queue_url": "http://api.buildkite.com/v2/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "queues_url": "http://buildkite.com/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/queues",
  "created_at": "2023-05-03T04:17:55.867Z",
  "created_by": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2013-08-29T10:10:03.000Z"
  }
}
```

[Request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr><th><code>name</code></th><td>Name for the cluster.<br><em>Example:</em> <code>"Open Source"</code>
  <tr><th><code>description</code></th><td>Description for the cluster.<br><em>Example:</em> <code>"A place for safely running our open source builds"</code>
  <tr><th><code>emoji</code></th><td>Emoji for the cluster using the <a href="/docs/pipelines/emojis">emoji syntax</a>.<br><em>Example:</em> <code>"\:technologist\:"</code>
  <tr><th><code>color</code></th><td>Color hex code for the cluster.<br><em>Example:</em> <code>"#FFE0F1"</code>
  <tr><th><code>default_queue_id</code></th><td>ID of the queue to set as the cluster's default queue. Agents that connect to the cluster without specifying a queue will accept jobs from this queue.<br><em>Example:</em> <code>"01885682-55a7-44f5-84f3-0402fb452e66"</code>
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

### Delete a cluster

Delete a cluster along with any queues and tokens that belong to it.

```bash
curl -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{id}"
```

Required scope: `write_clusters`

Success response: `204 No Content`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Reason the cluster couldn't be deleted" }</code></td></tr>
</tbody>
</table>

## Cluster queues

[Cluster queues](https://buildkite.com/docs/agent/clusters#set-up-a-cluster-set-up-queues) are discrete groups of agents within a cluster. Pipelines in that cluster can target cluster queues to run jobs on agents assigned to those queues.

### Cluster queue data model

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

### List queues

Returns a [paginated list](<%= paginated_resource_docs_url %>) of a cluster's queues.

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/queues"
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

### Get a queue

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/queues/{queue.id}"
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

Required scope: `read_clusters`

Success response: `200 OK`

### Create a queue

```bash
curl -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/queues" \
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

### Update a queue

```bash
curl -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/queues/{id}" \
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

### Delete a queue

```bash
curl -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/queues/{id}"
```

Required scope: `write_clusters`

Success response: `204 No Content`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Reason the queue couldn't be deleted" }</code></td></tr>
</tbody>
</table>

### Pause a queue

[Pause a queue](/docs/agent/clusters#pause-a-queue) to prevent jobs from being dispatched to agents associated with the queue.

```bash
curl -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/queues/{id}/pause_dispatch" \
  -H "Content-Type: application/json" \
  -d '{ "note": "Paused while we investigate a security issue" }'
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

### Resume a paused queue

```bash
curl -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/queues/{id}/resume_dispatch" \
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

## Cluster tokens

A [cluster token](https://buildkite.com/docs/agent/clusters#set-up-a-cluster-connect-agents-to-a-cluster) is used to connect agents to a cluster.

### Token data model

<table class="responsive-table">
<tbody>
  <tr><th><code>id</code></th><td>ID of the token</td></tr>
  <tr><th><code>graphql_id</code></th><td><a href="/docs/apis/graphql-api#graphql-ids">GraphQL ID</a> of the token</td></tr>
  <tr><th><code>description</code></th><td>Description of the token</td></tr>
  <tr><th><code>url</code></th><td>Canonical API URL of the token</td></tr>
  <tr><th><code>cluster_url</code></th><td>API URL of the cluster the token belongs to</td></tr>
  <tr><th><code>created_at</code></th><td>When the token was created</td></tr>
  <tr><th><code>created_by</code></th><td>User who created the token</td></tr>
</tbody>
</table>

### List tokens

Returns a [paginated list](<%= paginated_resource_docs_url %>) of a cluster's tokens.

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens"
```

```json
[
  {
    "id": "b6001416-0e1e-41c6-9dbe-3d96766f451a",
    "graphql_id": "Q2x1c3RlclRva2VuLS0tYjYwMDE0MTYtMGUxZS00MWM2LTlkYmUtM2Q5Njc2NmY0NTFh",
    "description": "Windows agents",
    "url": "http://api.buildkite.com/v2/organizations/test/clusters/e4f44564-d3ea-45eb-87c2-6506643b852a/tokens/b6001416-0e1e-41c6-9dbe-3d96766f451a",
    "cluster_url": "http://api.buildkite.com/v2/organizations/test/clusters/e4f44564-d3ea-45eb-87c2-6506643b852a",
    "created_at": "2023-05-26T04:21:41.350Z",
    "created_by": {
      "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
      "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
      "name": "Sam Kim",
      "email": "sam@example.com",
      "avatar_url": "https://www.gravatar.com/avatar/example",
      "created_at": "2013-08-29T10:10:03.000Z"
    }
  }
]
```

Required scope: `read_clusters`

Success response: `200 OK`

### Get a token

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens/{token.id}"
```

```json
{
  "id": "b6001416-0e1e-41c6-9dbe-3d96766f451a",
  "graphql_id": "Q2x1c3RlclRva2VuLS0tYjYwMDE0MTYtMGUxZS00MWM2LTlkYmUtM2Q5Njc2NmY0NTFh",
  "description": "Windows agents",
  "url": "http://api.buildkite.com/v2/organizations/test/clusters/e4f44564-d3ea-45eb-87c2-6506643b852a/tokens/b6001416-0e1e-41c6-9dbe-3d96766f451a",
  "cluster_url": "http://api.buildkite.com/v2/organizations/test/clusters/e4f44564-d3ea-45eb-87c2-6506643b852a",
  "created_at": "2023-05-26T04:21:41.350Z",
  "created_by": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2013-08-29T10:10:03.000Z"
  }
}
```

Required scope: `read_clusters`

Success response: `200 OK`

### Create a token

> 📘 Token visibility
> To ensure the security of tokens, the value is only included in the response for the request to create the token. Subsequent responses do not contain the token value.

```bash
curl -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens" \
  -H "Content-Type: application/json" \
  -d '{ "description": "Windows agents" }'
```

```json
{
  "id": "b6001416-0e1e-41c6-9dbe-3d96766f451a",
  "graphql_id": "Q2x1c3RlclRva2VuLS0tYjYwMDE0MTYtMGUxZS00MWM2LTlkYmUtM2Q5Njc2NmY0NTFh",
  "description": "Windows agents",
  "url": "http://api.buildkite.com/v2/organizations/test/clusters/e4f44564-d3ea-45eb-87c2-6506643b852a/tokens/b6001416-0e1e-41c6-9dbe-3d96766f451a",
  "cluster_url": "http://api.buildkite.com/v2/organizations/test/clusters/e4f44564-d3ea-45eb-87c2-6506643b852a",
  "created_at": "2023-05-26T04:21:41.350Z",
  "created_by": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2013-08-29T10:10:03.000Z"
  },
  "token": "igo6HEj5fxQbgBTDoDzNaZzT"
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr><th><code>description</code></th><td>Description for the token.<br><em>Example:</em> <code>"Windows agents"</code>
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

### Update a token

```bash
curl -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens/{id}" \
  -H "Content-Type: application/json" \
  -d '{ "description": "Windows agents" }'
```

```json
{
  "id": "b6001416-0e1e-41c6-9dbe-3d96766f451a",
  "graphql_id": "Q2x1c3RlclRva2VuLS0tYjYwMDE0MTYtMGUxZS00MWM2LTlkYmUtM2Q5Njc2NmY0NTFh",
  "description": "Windows agents",
  "url": "http://api.buildkite.com/v2/organizations/test/clusters/e4f44564-d3ea-45eb-87c2-6506643b852a/tokens/b6001416-0e1e-41c6-9dbe-3d96766f451a",
  "cluster_url": "http://api.buildkite.com/v2/organizations/test/clusters/e4f44564-d3ea-45eb-87c2-6506643b852a",
  "created_at": "2023-05-26T04:21:41.350Z",
  "created_by": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2013-08-29T10:10:03.000Z"
  }
}
```

[Request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr><th><code>description</code></th><td>Description for the token.<br><em>Example:</em> <code>"Windows agents"</code>
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

### Delete a token

```bash
curl -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens/{id}"
```

Required scope: `write_clusters`

Success response: `204 No Content`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Reason the token couldn't be deleted" }</code></td></tr>
</tbody>
</table>
