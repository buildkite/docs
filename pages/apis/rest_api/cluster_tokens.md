# Cluster tokens API

A [cluster token](https://buildkite.com/docs/agent/clusters#set-up-a-cluster-connect-agents-to-a-cluster) is used to connect agents to a cluster.

> 📘 Enable clusters
> You'll need to [enable clusters](/docs/agent/clusters#enable-clusters) for your organization to use this API.

## Token data model

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

## List tokens

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

## Get a token

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

## Create a token

> 📘 Token values
> The token value is only be included in the response for the request to create it. To ensure the security of tokens, their value isn't included in subsequent responses.

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

[Request body properties](/docs/api#request-body-properties):

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

## Update a token

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

## Delete a token

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
