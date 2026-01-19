# Agent tokens

This endpoint manages agent tokens within a [cluster](/docs/apis/rest-api/clusters).

An agent token is used to [connect agents to a Buildkite cluster](/docs/pipelines/security/clusters/manage#connect-agents-to-a-cluster).

## Token data model

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

## List tokens

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

## Get a token

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

## Create a token

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

## Update a token

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

## Revoke a token

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
