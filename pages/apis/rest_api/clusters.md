# Clusters API

A [cluster](/docs/agent/clusters) is an isolated set of agents and pipelines within an organization.

> 📘 Enable clusters
> You'll need to [enable clusters](/docs/agent/clusters#enable-clusters) for your organization to use this API.

## Cluster data model

<table class="responsive-table">
<tbody>
  <tr><th><code>id</code></th><td>ID of the cluster</td></tr>
  <tr><th><code>graphql_id</code></th><td><a href="/docs/apis/graphql-api#graphql-ids">GraphQL ID</a> of the cluster</td></tr>
  <tr><th><code>name</code></th><td>Name of the cluster</td></tr>
  <tr><th><code>description</code></th><td>Description of the cluster</td></tr>
  <tr><th><code>emoji</code></th><td>Emoji for the cluster using the <a href="/docs/pipelines/emojis">emoji syntax</a></td></tr>
  <tr><th><code>color</code></th><td>Color hex code for the cluster</td></tr>
  <tr><th><code>url</code></th><td>Canonical API URL of the cluster</td></tr>
  <tr><th><code>web_url</code></th><td>URL of the cluster on Buildkite</td></tr>  
  <tr><th><code>created_at</code></th><td>When the cluster was created</td></tr>
  <tr><th><code>created_by</code></th><td>User who created the cluster</td></tr>
</tbody>
</table>

## List clusters

Returns a [paginated list](<%= paginated_resource_docs_url %>) of an organization's clusters.

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/clusters"
```

```json
[
  {
    "id": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
    "graphql_id": "Q2x1c3Rlci0tLTQyZjFhN2RhLTgxMmQtNDQzMC05M2Q4LTFjYzdjMzNhNmJjZg==",
    "name": "Open Source",
    "description": "A place for safely running our open source builds",
    "emoji": "\:technologist\:",
    "color": "#FFE0F1",
    "url": "http://api.buildkite.com/v2/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
    "web_url": "http://buildkite.com/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
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

## Get a cluster

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{id}"
```

```json
{
  "id": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "graphql_id": "Q2x1c3Rlci0tLTQyZjFhN2RhLTgxMmQtNDQzMC05M2Q4LTFjYzdjMzNhNmJjZg==",
  "name": "Open Source",
  "description": "A place for safely running our open source builds",
  "emoji": "\:technologist\:",
  "color": "#FFE0F1",
  "url": "http://api.buildkite.com/v2/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "web_url": "http://buildkite.com/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
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

## Create a cluster

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
  "name": "Open Source",
  "description": "A place for safely running our open source builds",
  "emoji": "\:technologist\:",
  "color": "#FFE0F1",
  "url": "http://api.buildkite.com/v2/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "web_url": "http://buildkite.com/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
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

## Update a cluster

```bash
curl -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/clusters" \
  -H "Content-Type: application/json" \
  -d '{ "name": "Open Source" }'
```

```json
{
  "id": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "graphql_id": "Q2x1c3Rlci0tLTQyZjFhN2RhLTgxMmQtNDQzMC05M2Q4LTFjYzdjMzNhNmJjZg==",
  "name": "Open Source",
  "description": "A place for safely running our open source builds",
  "emoji": "\:technologist\:",
  "color": "#FFE0F1",
  "url": "http://api.buildkite.com/v2/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "web_url": "http://buildkite.com/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
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

## Delete a cluster

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

## Add pipelines to a cluster

Use the [Pipelines API](/docs/apis/rest-api/pipelines) to control which cluster a pipeline runs on by setting the `cluster_id` property.

Set `cluster_id` to `null` to remove a pipeline from a cluster.

For example, to add an existing pipeline to a cluster:

```bash
curl -X PATCH "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{slug}" \
  -H "Content-Type: application/json" \
  -d '{ "cluster_id": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf" }'
```
