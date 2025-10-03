# Clusters API

The clusters API endpoint lets you create and manage clusters in your organization.

## Clusters

A [Buildkite cluster](/docs/pipelines/clusters) is an isolated set of agents and pipelines within an organization.

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
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/clusters"
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
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{id}"
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
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters" \
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
  <tr>
    <th>
      <code>description</code>
    </th>
    <td>
      Description for the cluster.<br/>
      <em>Example:</em> <code>"A place for safely running our open source builds"</code>
    </td>
  </tr>
  <tr>
    <th>
      <code>emoji</code>
    </th>
    <td>
      Emoji for the cluster using the <a href="/docs/pipelines/emojis">emoji syntax</a><br/>
      <em>Example:</em> <code>"\:technologist\:"</code>
    </td>
  <tr>
    <th>
      <code>color</code>
    </th>
    <td>
      Color hex code for the cluster.<br/>
      <em>Example:</em> <code>"#FFE0F1"</code>
    </td>
  </tr>
  <tr>
    <th>
      <code>maintainers</code>
    </th>
    <td>
      An array of one or more hashes of representing users or teams to grant maintainer permissions to for this cluster.<br/>
      <em>Example:</em>
      <code>
      [{ "user: "282a043f-4d4f-4db5-ac9a-58673ae02caf" }, { "team: "0da645b7-9840-428f-bd80-0b92ee274480" }]
      </code>
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

### Update a cluster

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{id}" \
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
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{id}"
```

Required scope: `write_clusters`

Success response: `204 No Content`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Reason the cluster couldn't be deleted" }</code></td></tr>
</tbody>
</table>

## Queues

[Queues](/docs/pipelines/clusters/manage-queues) are discrete groups of agents within a Buildkite cluster. Pipelines in that cluster can target queues to run jobs on agents assigned to those queues.

### Queue data model

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

### Create a self-hosted queue

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

Required scope: `write_clusters`

Success response: `201 Created`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Validation failed: Reason for failure" }</code></td></tr>
</tbody>
</table>

### Create a Buildkite hosted queue

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
      Learn more about the instance shapes available for <a href="#queues-instance-shape-values-for-linux">Linux</a> and <a href="#queues-instance-shape-values-for-macos">macOS</a> hosted agents.
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

### Update a queue

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
      Learn more about the instance shapes available for <a href="#queues-instance-shape-values-for-linux">Linux</a> and <a href="#queues-instance-shape-values-for-macos">macOS</a> Buildkite hosted agents.
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

### Delete a queue

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

### Pause a queue

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

### Resume a paused queue

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

### Instance shape values for Linux

Specify the appropriate **Instance shape** for the `instanceShape` value in your REST API call.

<%= render_markdown partial: 'shared/hosted_agents/hosted_agents_instance_shape_table_linux' %>

### Instance shape values for macOS

Specify the appropriate **Instance shape** for the `instanceShape` value in your REST API call.

<%= render_markdown partial: 'shared/hosted_agents/hosted_agents_instance_shape_table_mac' %>

## Agent tokens

An agent token is used to [connect agents to a Buildkite cluster](/docs/pipelines/clusters/manage-clusters#connect-agents-to-a-cluster).

### Token data model

<table class="responsive-table">
<tbody>
  <tr><th><code>id</code></th><td>The ID of the agent token.</td></tr>
  <tr><th><code>graphql_id</code></th><td>The <a href="/docs/apis/graphql-api#graphql-ids">GraphQL ID</a> of the token.</td></tr>
  <tr><th><code>description</code></th><td>The description of the token.</td></tr>
  <tr><th><code>allowed_ip_addresses</code></th><td>A list of permitted <a href="https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing">CIDR-notation</a> IPv4 addresses that agents must be accessible through, to access this token and connect to your Buildkite cluster.</td></tr>
  <tr><th><code>url</code></th><td>The canonical API URL of the token.</td></tr>
  <tr><th><code>cluster_url</code></th><td>The API URL of the Buildkite cluster that the token belongs to.</td></tr>
  <tr><th><code>created_at</code></th><td>The date and time when the token was created.</td></tr>
  <tr><th><code>created_by</code></th><td>The user who created the token.</td></tr>
  <tr><th><code>expires_at</code></th><td>The ISO8601 timestamp at which point the token expires and prevents agents configured with this token from re-connecting to their Buildkite cluster.</td></tr>
</tbody>
</table>

### List tokens

Returns a [paginated list](<%= paginated_resource_docs_url %>) of a cluster's agent tokens.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens"
```

```json
[
  {
    "id": "b6001416-0e1e-41c6-9dbe-3d96766f451a",
    "graphql_id": "Q2x1c3RlclRva2VuLS0tYjYwMDE0MTYtMGUxZS00MWM2LTlkYmUtM2Q5Njc2NmY0NTFh",
    "description": "Windows agents",
    "allowed_ip_addresses": "202.144.0.0/24",
    "expires_at" : "2026-01-01T00:00:00Z",
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
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens/{token.id}"
```

```json
{
  "id": "b6001416-0e1e-41c6-9dbe-3d96766f451a",
  "graphql_id": "Q2x1c3RlclRva2VuLS0tYjYwMDE0MTYtMGUxZS00MWM2LTlkYmUtM2Q5Njc2NmY0NTFh",
  "description": "Windows agents",
  "allowed_ip_addresses": "202.144.0.0/24",
  "expires_at" : "2026-01-01T00:00:00Z",
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
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens" \
  -H "Content-Type: application/json" \
  -d '{ "description": "Windows agents", "expires_at": "2025-01-01T00:00:00Z", "allowed_ip_addresses": "202.144.0.0/24" }'
```

```json
{
  "id": "b6001416-0e1e-41c6-9dbe-3d96766f451a",
  "graphql_id": "Q2x1c3RlclRva2VuLS0tYjYwMDE0MTYtMGUxZS00MWM2LTlkYmUtM2Q5Njc2NmY0NTFh",
  "description": "Windows agents",
  "expires_at": "2025-01-01T00:00:00Z",
  "allowed_ip_addresses": "202.144.0.0/24",
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

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr><th><code>expires_at</code></th><td>The ISO8601 timestamp at which point the token expires and prevents agents configured with this token from re-connecting to their Buildkite cluster.<br><em>Example:</em> <code>2025-01-01T00:00:00Z</code>
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
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens/{id}" \
  -H "Content-Type: application/json" \
  -d '{ "description": "Windows agents", "expires_at": "2025-01-01T00:00:00Z", "allowed_ip_addresses": "202.144.0.0/24" }'
```

```json
{
  "id": "b6001416-0e1e-41c6-9dbe-3d96766f451a",
  "graphql_id": "Q2x1c3RlclRva2VuLS0tYjYwMDE0MTYtMGUxZS00MWM2LTlkYmUtM2Q5Njc2NmY0NTFh",
  "description": "Windows agents",
  "allowed_ip_addresses": "202.144.0.0/24",
  "expires_at" : "2026-01-01T00:00:00Z",
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

### Revoke a token

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens/{id}"
```

Required scope: `write_clusters`

Success response: `204 No Content`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Reason the token couldn't be revoked" }</code></td></tr>
</tbody>
</table>

## Cluster maintainers

Cluster maintainers permissions can be assigned to a list of [Users or teams](/docs/platform/team-management/permissions), or both. This grants assignees the ability to manage the [Buildkite clusters they maintain](/docs/pipelines/clusters/manage-clusters#manage-maintainers-on-a-cluster).

### Cluster maintainer data model

<table class="responsive-table">
  <tbody>
    <tr><th><code>id</code></th><td>The ID of the cluster maintainer assignment.</td></tr>
    <tr><th><code>actor</code></th><td>Metadata on the assigned User or Team</td></tr>
  </tbody>
</table>

### List cluster maintainers

Returns a list of [maintainers](/docs/pipelines/clusters/manage-clusters#manage-maintainers-on-a-cluster) on a [cluster](/docs/pipelines/clusters).

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/maintainers"
```

```json
[
	{
		"id": "f6cf1097-c9c5-4492-885f-a2d3281a07dd",
		"actor": {
			"id": "01973824-0c57-45ae-a440-638fceb3ec06",
			"graphql_id": "VXNlci0tLTAxOTczODI0LTBjNTctNDVhZS1hNDQwLTYzOGZjZWIzZWMwNg==",
			"name": "Staff",
			"email": "staff@example.com",
			"type": "user"
		}
	},
	{
		"id": "282a043f-4d4f-4db5-ac9a-58673ae02caf",
		"actor": {
			"id": "0da645b7-9840-428f-bd80-0b92ee274480",
			"graphql_id": "VGVhbS0tLTBkYTY0NWI3LTk4NDAtNDI4Zi1iZDgwLTBiOTJlZTI3NDQ4MA==",
			"slug": "Developers",
			"type": "team"
		}
	}
]
```

Required scope: `read_clusters`

Success response: `200 OK`

### Get a cluster maintainer

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/maintainers/{id}"
```

```json
{
	"id": "282a043f-4d4f-4db5-ac9a-58673ae02caf",
	"actor": {
		"id": "0da645b7-9840-428f-bd80-0b92ee274480",
		"graphql_id": "VGVhbS0tLTBkYTY0NWI3LTk4NDAtNDI4Zi1iZDgwLTBiOTJlZTI3NDQ4MA==",
		"slug": "Developers",
		"type": "team"
	}
}
```

Required scope: `read_clusters`

Success response: `200 OK`

### Create a cluster maintainer

Assigns [cluster maintainer](/docs/pipelines/clusters/manage-clusters#manage-maintainers-on-a-cluster) permissions to a [user or team](/docs/platform/team-management/permissions).

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/maintainers" \
  -H "Content-Type: application/json" \
  -d '{ "team": "0da645b7-9840-428f-bd80-0b92ee274480" }'
```

```json
{
	"id": "282a043f-4d4f-4db5-ac9a-58673ae02caf",
	"actor": {
		"id": "0da645b7-9840-428f-bd80-0b92ee274480",
		"graphql_id": "VGVhbS0tLTBkYTY0NWI3LTk4NDAtNDI4Zi1iZDgwLTBiOTJlZTI3NDQ4MA==",
		"slug": "Developers",
		"type": "team"
	}
}
```

#### Cluster maintainer permission target

Cluster maintainer permissions can be targeted to either a [user or team](/docs/platform/team-management/permissions) by specifying either a `user` or `team` field as the target in the request body, along with the target's UUID for its value.

<table class="responsive-table">
  <thead>
    <th>Target</th>
    <th>Value</th>
    <th>Example request body</th>
  </thead>
  <tbody>
    <tr>
      <td><code>user</code></td>
      <td>UUID of the user</td>
      <td><code>{ "user: "282a043f-4d4f-4db5-ac9a-58673ae02caf" }</code></td>
    </tr>
    <tr>
      <td><code>team</code></td>
      <td>UUID of the team</th>
      <td><code>{ "team: "0da645b7-9840-428f-bd80-0b92ee274480" }</code></td>
    </tr>
  </tbody>
</table>

Required scope: `write_clusters`

Success response: `201 Created`

Error responses:

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>422 Unprocessable Entity</code></th>
      <td><code>{ "message": "Validation failed: Reason for failure" }</code></td>
    </tr>
  </tbody>
</table>

### Remove a cluster maintainer

Remove cluster maintainer permissions from a [user or team](/docs/platform/team-management/permissions).

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{id}"
```

Required scope: `write_clusters`

Success response: `204 No Content`

Error responses:

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>422 Unprocessable Entity</code></th>
      <td><code>{ "message": "Validation failed: Reason cluster maintainer permission could not be deleted" }</code></td>
    </tr>
  </tbody>
</table>
