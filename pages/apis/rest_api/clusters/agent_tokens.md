# Agent tokens

An agent token is used to [connect agents to a Buildkite cluster](/docs/pipelines/security/clusters/manage#connect-agents-to-a-cluster).

Use [scoped agent tokens](/docs/agent/self-hosted/scoped-agent-tokens) to limit the Agent API actions agents can perform and the queues where they can register and explicitly acquire jobs.

Authenticate these requests with a personal [API access token](/docs/apis/managing-api-tokens), using the `read_clusters` scope for reads or `write_clusters` for writes. Your user must have the `manage_cluster` permission for the cluster. Creating a token also requires `see_cluster_tokens`. These management permissions are separate from the agent token's `permissions` array.

## Token data model

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>id</code></th>
    <td>The ID of the agent token.</td>
  </tr>
  <tr>
    <th><code>graphql_id</code></th>
    <td>The <a href="/docs/apis/graphql-api#graphql-ids">GraphQL ID</a> of the token.</td>
  </tr>
  <tr>
    <th><code>description</code></th>
    <td>The description of the token.</td>
  </tr>
  <tr>
    <th><code>allowed_ip_addresses</code></th>
    <td>A string containing permitted <a href="https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing">CIDR-notation</a> IPv4 addresses from which agents can use this token to connect to the cluster.</td>
  </tr>
  <tr>
    <th><code>permissions</code></th>
    <td>An array of allowed Agent API actions. See the <a href="/docs/agent/self-hosted/scoped-agent-tokens#available-permissions">available permissions</a>. An empty array grants no permission-controlled actions.</td>
  </tr>
  <tr>
    <th><code>allow_all_queues</code></th>
    <td>Whether agents using the token can register and explicitly acquire jobs in any queue in the cluster.</td>
  </tr>
  <tr>
    <th><code>allowed_queue_ids</code></th>
    <td>An array of queue UUIDs in the same cluster. With <code>allow_all_queues: false</code>, agents can register and explicitly acquire jobs only in these queues. An empty array with <code>allow_all_queues: false</code> denies all queues.</td>
  </tr>
  <tr>
    <th><code>token</code></th>
    <td>The secret token value. Returned only when creating a token; omitted from list, get, and update responses.</td>
  </tr>
  <tr>
    <th><code>url</code></th>
    <td>The canonical API URL of the token.</td>
  </tr>
  <tr>
    <th><code>cluster_url</code></th>
    <td>The API URL of the Buildkite cluster that the token belongs to.</td>
  </tr>
  <tr>
    <th><code>created_at</code></th>
    <td>The date and time when the token was created.</td>
  </tr>
  <tr>
    <th><code>created_by</code></th>
    <td>The user who created the token.</td>
  </tr>
  <tr>
    <th><code>expires_at</code></th>
    <td>The ISO8601 timestamp at which point the token expires and prevents agents configured with this token from re-connecting to their Buildkite cluster.</td>
  </tr>
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
    "id": "00000000-0000-4000-8000-000000000001",
    "graphql_id": "Q2x1c3RlclRva2VuLS0tMDAwMDAwMDAtMDAwMC00MDAwLTgwMDAtMDAwMDAwMDAwMDAx",
    "description": "Windows agents",
    "allowed_ip_addresses": "192.0.2.0/24",
    "permissions": ["run_jobs", "code_repository_access", "write_build_metadata"],
    "allow_all_queues": false,
    "allowed_queue_ids": ["00000000-0000-4000-8000-000000000002"],
    "expires_at": "2030-01-01T00:00:00Z",
    "url": "https://api.buildkite.com/v2/organizations/example-org/clusters/00000000-0000-4000-8000-000000000003/tokens/00000000-0000-4000-8000-000000000001",
    "cluster_url": "https://api.buildkite.com/v2/organizations/example-org/clusters/00000000-0000-4000-8000-000000000003",
    "created_at": "2023-05-26T04:21:41.350Z",
    "created_by": {
      "id": "00000000-0000-4000-8000-000000000004",
      "graphql_id": "VXNlci0tLTAwMDAwMDAwLTAwMDAtNDAwMC04MDAwLTAwMDAwMDAwMDAwNA==",
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
  "id": "00000000-0000-4000-8000-000000000001",
  "graphql_id": "Q2x1c3RlclRva2VuLS0tMDAwMDAwMDAtMDAwMC00MDAwLTgwMDAtMDAwMDAwMDAwMDAx",
  "description": "Windows agents",
  "allowed_ip_addresses": "192.0.2.0/24",
  "permissions": ["run_jobs", "code_repository_access", "write_build_metadata"],
  "allow_all_queues": false,
  "allowed_queue_ids": ["00000000-0000-4000-8000-000000000002"],
  "expires_at": "2030-01-01T00:00:00Z",
  "url": "https://api.buildkite.com/v2/organizations/example-org/clusters/00000000-0000-4000-8000-000000000003/tokens/00000000-0000-4000-8000-000000000001",
  "cluster_url": "https://api.buildkite.com/v2/organizations/example-org/clusters/00000000-0000-4000-8000-000000000003",
  "created_at": "2023-05-26T04:21:41.350Z",
  "created_by": {
    "id": "00000000-0000-4000-8000-000000000004",
    "graphql_id": "VXNlci0tLTAwMDAwMDAwLTAwMDAtNDAwMC04MDAwLTAwMDAwMDAwMDAwNA==",
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

This example allows agents to run jobs, access code repositories through the Agent API, and write build metadata on a selected queue. Replace the example queue UUID with one from your cluster's [list of queues](/docs/apis/rest-api/clusters/queues#list-queues).

> 📘 Token visibility
> To ensure the security of tokens, the value is only included in the response for the request to create the token. Subsequent responses do not contain the token value.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Windows agents",
    "expires_at": "2030-01-01T00:00:00Z",
    "allowed_ip_addresses": "192.0.2.0/24",
    "permissions": ["run_jobs", "code_repository_access", "write_build_metadata"],
    "allow_all_queues": false,
    "allowed_queue_ids": ["00000000-0000-4000-8000-000000000002"]
  }'
```

```json
{
  "id": "00000000-0000-4000-8000-000000000001",
  "graphql_id": "Q2x1c3RlclRva2VuLS0tMDAwMDAwMDAtMDAwMC00MDAwLTgwMDAtMDAwMDAwMDAwMDAx",
  "description": "Windows agents",
  "expires_at": "2030-01-01T00:00:00Z",
  "allowed_ip_addresses": "192.0.2.0/24",
  "permissions": ["run_jobs", "code_repository_access", "write_build_metadata"],
  "allow_all_queues": false,
  "allowed_queue_ids": ["00000000-0000-4000-8000-000000000002"],
  "url": "https://api.buildkite.com/v2/organizations/example-org/clusters/00000000-0000-4000-8000-000000000003/tokens/00000000-0000-4000-8000-000000000001",
  "cluster_url": "https://api.buildkite.com/v2/organizations/example-org/clusters/00000000-0000-4000-8000-000000000003",
  "created_at": "2023-05-26T04:21:41.350Z",
  "created_by": {
    "id": "00000000-0000-4000-8000-000000000004",
    "graphql_id": "VXNlci0tLTAwMDAwMDAwLTAwMDAtNDAwMC04MDAwLTAwMDAwMDAwMDAwNA==",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2013-08-29T10:10:03.000Z"
  },
  "token": "YOUR_AGENT_TOKEN"
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>description</code></th>
    <td>Description for the token.<br><em>Example:</em> <code>"Windows agents"</code></td>
  </tr>
</tbody>
</table>

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>expires_at</code></th>
    <td>The ISO8601 timestamp at which point the token expires and prevents agents configured with this token from re-connecting to their Buildkite cluster. Cannot be changed after creation.<br><em>Example:</em> <code>2030-01-01T00:00:00Z</code></td>
  </tr>
  <tr>
    <th><code>allowed_ip_addresses</code></th>
    <td>A string of permitted CIDR-notation IPv4 addresses.<br><em>Example:</em> <code>"192.0.2.0/24"</code></td>
  </tr>
  <tr>
    <th><code>permissions</code></th>
    <td>An array of permission strings. Omit to grant all current permissions. An explicit array grants only those permissions, with duplicates removed. An empty array grants no permission-controlled actions.</td>
  </tr>
  <tr>
    <th><code>allow_all_queues</code></th>
    <td>A boolean that defaults to <code>true</code>. Set to <code>false</code> and supply <code>allowed_queue_ids</code> to restrict queue access.</td>
  </tr>
  <tr>
    <th><code>allowed_queue_ids</code></th>
    <td>An array of queue UUIDs from the same cluster, with duplicates removed. Defaults to an empty array. Required when <code>allow_all_queues</code> is <code>false</code>; an empty array then denies all queues. Must be empty when <code>allow_all_queues</code> is <code>true</code>.</td>
  </tr>
</tbody>
</table>

Unknown permission names, including the retired names `read_pipelines` and `modify_steps`, are rejected. A `null` or malformed `permissions` value is also rejected. Invalid permission or queue settings return `422 Unprocessable Entity` without creating a token.

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

## Update a token

Supply `permissions` to replace the entire permission array. Omit `permissions`, `allow_all_queues`, or `allowed_queue_ids` to preserve the corresponding stored value. Supplying `allowed_queue_ids` replaces the queue array.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens/{id}" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Windows agents",
    "allowed_ip_addresses": "192.0.2.0/24",
    "permissions": ["run_jobs", "code_repository_access", "write_build_metadata"],
    "allow_all_queues": false,
    "allowed_queue_ids": ["00000000-0000-4000-8000-000000000002"]
  }'
```

```json
{
  "id": "00000000-0000-4000-8000-000000000001",
  "graphql_id": "Q2x1c3RlclRva2VuLS0tMDAwMDAwMDAtMDAwMC00MDAwLTgwMDAtMDAwMDAwMDAwMDAx",
  "description": "Windows agents",
  "allowed_ip_addresses": "192.0.2.0/24",
  "permissions": ["run_jobs", "code_repository_access", "write_build_metadata"],
  "allow_all_queues": false,
  "allowed_queue_ids": ["00000000-0000-4000-8000-000000000002"],
  "expires_at": "2030-01-01T00:00:00Z",
  "url": "https://api.buildkite.com/v2/organizations/example-org/clusters/00000000-0000-4000-8000-000000000003/tokens/00000000-0000-4000-8000-000000000001",
  "cluster_url": "https://api.buildkite.com/v2/organizations/example-org/clusters/00000000-0000-4000-8000-000000000003",
  "created_at": "2023-05-26T04:21:41.350Z",
  "created_by": {
    "id": "00000000-0000-4000-8000-000000000004",
    "graphql_id": "VXNlci0tLTAwMDAwMDAwLTAwMDAtNDAwMC04MDAwLTAwMDAwMDAwMDAwNA==",
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
  <tr>
    <th><code>description</code></th>
    <td>Description for the token.<br><em>Example:</em> <code>"Windows agents"</code></td>
  </tr>
  <tr>
    <th><code>allowed_ip_addresses</code></th>
    <td>A string of permitted CIDR-notation IPv4 addresses. Omit to preserve the restriction; set to <code>null</code> to clear it.</td>
  </tr>
  <tr>
    <th><code>permissions</code></th>
    <td>The replacement array of permission strings, with duplicates removed. Omit to preserve the existing permissions; use an empty array to grant no permission-controlled actions.</td>
  </tr>
  <tr>
    <th><code>allow_all_queues</code></th>
    <td>A boolean that controls whether agents can register and explicitly acquire jobs in any queue. Omit to preserve the stored value.</td>
  </tr>
  <tr>
    <th><code>allowed_queue_ids</code></th>
    <td>The replacement array of queue UUIDs from the same cluster, with duplicates removed. Omit to preserve the existing queues. Must be empty when <code>allow_all_queues</code> is <code>true</code>.</td>
  </tr>
</tbody>
</table>

To switch a restricted token to all queues, send `"allow_all_queues": true` and `"allowed_queue_ids": []` together. Clearing the array while `allow_all_queues` is `false` denies all queues.

Saved permission changes take effect on subsequent requests from connected agents and running jobs, without re-registration. Queue changes apply to new registrations, including registrations using previously issued [job acquisition tokens](/docs/agent/self-hosted/job-acquisition-tokens), and new stack batch JAT issuance.

Explicit job acquisition also checks current queue bindings. Removing queue access after registration can make the Agent API's `/acquire` endpoint return `404`, including for a JAT-backed agent. Queue edits do not disconnect existing agents or cancel running jobs.

Invalid permission or queue settings return `422 Unprocessable Entity` without changing the token. The same validation rules apply as when creating a token. The expiration date cannot be updated; supplying `expires_at` returns `400 Bad Request`.

Required scope: `write_clusters`

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td><code>{ "message": "Validation failed: Reason for failure" }</code></td>
  </tr>
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
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td><code>{ "message": "Reason the token couldn't be revoked" }</code></td>
  </tr>
</tbody>
</table>
