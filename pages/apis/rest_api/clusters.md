# Clusters API

The clusters API endpoint lets you create and manage [clusters](#clusters) in your organization, along with the following other aspects associated with clusters:

- [Queues](/docs/apis/rest-api/clusters/queues)
- [Agent tokens](/docs/apis/rest-api/clusters/agent-tokens)
- [Cluster maintainers](/docs/apis/rest-api/clusters/maintainers)
- [Buildkite secrets](/docs/apis/rest-api/clusters/secrets)

## Clusters

A [Buildkite cluster](/docs/pipelines/security/clusters) is an isolated set of agents and pipelines within an organization.

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
  <tr><th><code>maintainers</code></th><td>The maintainers of the cluster</td></tr>
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
    "maintainers": {
      "users": [],
      "teams": []
    },
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
  "maintainers": {
    "users": [
      {
        "id": "56c210cb-474c-47a7-b4ef-5761a1cb91c1",
        "actor": {
          "id": "da206b36-e5ae-4f4a-aca6-07dd478f3a48",
          "graphql_id": "VXNlci0tLWU1N2ZiYTBmLWFiMTQtNGNjMC1iYjViLTY5NTc3NGZmYmZiZQ==",
          "name": "John Smith",
          "email": "john.smith@example.com",
          "type": "user"
        }
      }
    ],
    "teams": [
      {
        "id": "77ec8d4c-edb3-430e-baba-488757a418e2",
        "actor": {
          "id": "c5e09619-8648-4896-a936-9d0b8b7b3fe9",
          "graphql_id": "VGVhbS0tLWM1ZTA5NjE5LTg2NDgtNDg5Ni1hOTM2LTlkMGI4YjdiM2ZlOQ==",
          "name": "Fearless Frontenders",
          "slug": "fearless-frontenders",
        }
      }
    ]
  },
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
  "maintainers": {
    "users": [],
    "teams": []
  },
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
      [{ "user": "282a043f-4d4f-4db5-ac9a-58673ae02caf" }, { "team": "0da645b7-9840-428f-bd80-0b92ee274480" }]
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
  "maintainers": {
    "users": [],
    "teams": []
  },
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
