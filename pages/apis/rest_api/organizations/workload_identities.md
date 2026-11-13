# Workload identities API

The workload identities API lets you manage the workload identities that your Buildkite organization uses for [workload identity federation](/docs/apis/workload-identity-federation). A workload identity lets a trusted workload, such as a job running on a Buildkite agent, exchange the OpenID Connect (OIDC) token that its platform issues for a short-lived API access token. The API access token can only reach the pipelines and scopes that the workload identity allows.

> 📘 Required permissions
> These endpoints require both an API access token scope and organization administrator access for the user who owns the token:
> - List and get operations require the `read_workload_identities` [scope](/docs/apis/managing-api-tokens#token-scopes).
> - Create and update operations require the `write_workload_identities` scope.
> - Delete operations require the `delete_workload_identities` scope.
> Workload identities must also be enabled for your Buildkite organization. Otherwise, every endpoint returns `404 Not Found`.

## Workload identity data model

Workload identity endpoints return objects with the following fields:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>uuid</code></th>
    <td>UUID of the workload identity.</td>
  </tr>
  <tr>
    <th><code>url</code></th>
    <td>Canonical API URL of the workload identity.</td>
  </tr>
  <tr>
    <th><code>client_id</code></th>
    <td>Client ID that workloads send in <a href="/docs/apis/workload-identity-federation#exchange-an-oidc-token">token exchange requests</a>. The client ID isn't a secret.</td>
  </tr>
  <tr>
    <th><code>name</code></th>
    <td>Name of the workload identity.</td>
  </tr>
  <tr>
    <th><code>description</code></th>
    <td>Description of the workload identity.</td>
  </tr>
  <tr>
    <th><code>oidc_issuer</code></th>
    <td>Issuer URL that the OIDC token's <code>iss</code> claim must equal.</td>
  </tr>
  <tr>
    <th><code>oidc_audience</code></th>
    <td>Audience that the OIDC token's <code>aud</code> claim must contain.</td>
  </tr>
  <tr>
    <th><code>oidc_subject</code></th>
    <td>Pattern that the OIDC token's <code>sub</code> claim must match, where <code>*</code> matches any characters.</td>
  </tr>
  <tr>
    <th><code>oidc_claims</code></th>
    <td>Object of top-level claims and the exact values that they must have in the OIDC token. Learn more in <a href="/docs/apis/workload-identity-federation#lock-tokens-to-an-owner-with-claims">Lock tokens to an owner with claims</a>.</td>
  </tr>
  <tr>
    <th><code>oidc_claim_conditions</code></th>
    <td>CEL expression that the OIDC token's claims must satisfy. <code>null</code> when not set. Learn more in <a href="/docs/apis/workload-identity-federation#write-claim-conditions">Write claim conditions</a>.</td>
  </tr>
  <tr>
    <th><code>jwks</code></th>
    <td>A <a href="https://datatracker.ietf.org/doc/html/rfc7517">JSON Web Key Set (JWKS)</a> URL or inline JWKS JSON, as a string, that Buildkite uses instead of fetching the signing keys from the issuer. <code>null</code> when not set.</td>
  </tr>
  <tr>
    <th><code>grantable_token_scopes</code></th>
    <td>Array of the maximum scopes that an API access token can have. A token exchange request can ask for any subset of these scopes.</td>
  </tr>
  <tr>
    <th><code>default_token_scopes</code></th>
    <td>Array of the scopes that an API access token gets when the token exchange request doesn't ask for any.</td>
  </tr>
  <tr>
    <th><code>max_token_ttl_seconds</code></th>
    <td>Longest lifetime, in seconds, that an API access token can have.</td>
  </tr>
  <tr>
    <th><code>allowed_ip_addresses</code></th>
    <td>Space-separated CIDR ranges that can use the API access tokens that the workload identity mints. Any IP address can use them when not set.</td>
  </tr>
  <tr>
    <th><code>allowed_token_exchange_ip_addresses</code></th>
    <td>Space-separated CIDR ranges that can make token exchange requests for the workload identity. Any IP address can make them when not set.</td>
  </tr>
  <tr>
    <th><code>resource_grants</code></th>
    <td>Array of the pipelines that API access tokens can reach. Learn more in <a href="#workload-identity-data-model-resource-grants">Resource grants</a>.</td>
  </tr>
  <tr>
    <th><code>enabled</code></th>
    <td>Whether the workload identity accepts token exchange requests.</td>
  </tr>
  <tr>
    <th><code>created_at</code></th>
    <td>When the workload identity was created.</td>
  </tr>
  <tr>
    <th><code>updated_at</code></th>
    <td>When the workload identity was last updated.</td>
  </tr>
</tbody>
</table>

The API never returns API access tokens that the workload identity minted.

For example, this workload identity accepts OIDC tokens from jobs in one pipeline's builds of its `main` branch, running on Buildkite agents:

```json
{
  "uuid": "00000000-0000-4000-8000-000000000010",
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/workload-identities/00000000-0000-4000-8000-000000000010",
  "client_id": "0123456789abcdef0123",
  "name": "Deploy pipeline",
  "description": "Jobs in the deploy pipeline on the main branch",
  "oidc_issuer": "https://agent.buildkite.com",
  "oidc_audience": "https://api.buildkite.com/v2/organizations/00000000-0000-4000-8000-000000000001",
  "oidc_subject": "organization:acme-inc:pipeline:deploy:ref:refs/heads/main:commit:*:step:*",
  "oidc_claims": {
    "organization_id": "00000000-0000-4000-8000-000000000001"
  },
  "oidc_claim_conditions": "claims.pipeline_id == \"00000000-0000-4000-8000-000000000002\"",
  "jwks": null,
  "grantable_token_scopes": ["read_builds", "write_builds"],
  "default_token_scopes": ["read_builds"],
  "max_token_ttl_seconds": 600,
  "allowed_ip_addresses": "192.0.2.0/24",
  "allowed_token_exchange_ip_addresses": "192.0.2.0/24",
  "resource_grants": [
    {
      "type": "pipeline",
      "access": "selected",
      "ids": ["00000000-0000-4000-8000-000000000002"]
    }
  ],
  "enabled": true,
  "created_at": "2026-11-01T10:00:00.000Z",
  "updated_at": "2026-11-01T10:00:00.000Z"
}
```

### Resource grants

The `resource_grants` array holds one object for pipeline access, with the following fields. When the array is empty, API access tokens can't reach any pipelines.

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>type</code></th>
    <td>The resource type. Must be <code>pipeline</code>.</td>
  </tr>
  <tr>
    <th><code>access</code></th>
    <td><code>none</code> for no pipelines, <code>selected</code> for the pipelines in <code>ids</code>, or <code>all</code> for every pipeline in your Buildkite organization, including pipelines created later.</td>
  </tr>
  <tr>
    <th><code>ids</code></th>
    <td>UUIDs of up to 20 pipelines in your Buildkite organization. Required when <code>access</code> is <code>selected</code>, with at least one UUID, and not allowed otherwise.</td>
  </tr>
</tbody>
</table>

These fields match the **Resource Access** setting in the Buildkite interface. Learn more in [Choose pipeline access](/docs/apis/workload-identity-federation#choose-pipeline-access).

## List workload identities

Returns a cursor-paginated list of the workload identities in your Buildkite organization, ordered from newest to oldest.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/workload-identities"
```

The response contains [workload identity objects](#workload-identity-data-model) in `items`, and pagination URLs in `links` and the `Link` response header:

```json
{
  "items": [
    {
      "uuid": "00000000-0000-4000-8000-000000000010",
      "url": "https://api.buildkite.com/v2/organizations/acme-inc/workload-identities/00000000-0000-4000-8000-000000000010",
      "client_id": "0123456789abcdef0123",
      "name": "Deploy pipeline",
      "description": "Jobs in the deploy pipeline on the main branch",
      "oidc_issuer": "https://agent.buildkite.com",
      "oidc_audience": "https://api.buildkite.com/v2/organizations/00000000-0000-4000-8000-000000000001",
      "oidc_subject": "organization:acme-inc:pipeline:deploy:ref:refs/heads/main:commit:*:step:*",
      "oidc_claims": {
        "organization_id": "00000000-0000-4000-8000-000000000001"
      },
      "oidc_claim_conditions": "claims.pipeline_id == \"00000000-0000-4000-8000-000000000002\"",
      "jwks": null,
      "grantable_token_scopes": ["read_builds", "write_builds"],
      "default_token_scopes": ["read_builds"],
      "max_token_ttl_seconds": 600,
      "allowed_ip_addresses": "192.0.2.0/24",
      "allowed_token_exchange_ip_addresses": "192.0.2.0/24",
      "resource_grants": [
        {
          "type": "pipeline",
          "access": "selected",
          "ids": ["00000000-0000-4000-8000-000000000002"]
        }
      ],
      "enabled": true,
      "created_at": "2026-11-01T10:00:00.000Z",
      "updated_at": "2026-11-01T10:00:00.000Z"
    }
  ],
  "links": {
    "self": "https://api.buildkite.com/v2/organizations/acme-inc/workload-identities",
    "next": "https://api.buildkite.com/v2/organizations/acme-inc/workload-identities?after=CURSOR"
  }
}
```

Optional [query string parameters](/docs/apis/rest-api#query-string-parameters):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>per_page</code></th>
    <td>Number of results per page.<p class="Docs__api-param-eg"><em>Default:</em> <code>30</code></p><p class="Docs__api-param-eg"><em>Maximum:</em> <code>100</code></p></td>
  </tr>
  <tr>
    <th><code>after</code></th>
    <td>Return results after this cursor. Can't be used with <code>before</code>.</td>
  </tr>
  <tr>
    <th><code>before</code></th>
    <td>Return results before this cursor. Can't be used with <code>after</code>.</td>
  </tr>
</tbody>
</table>

Required scope: `read_workload_identities`

Success response: `200 OK`

Error response: `400 Bad Request` when the request has both `after` and `before`, an invalid cursor, or a `per_page` value below `1` or above `100`.

## Get a workload identity

Returns a [workload identity object](#workload-identity-data-model).

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/workload-identities/{uuid}"
```

Required scope: `read_workload_identities`

Success response: `200 OK`

Error response: `404 Not Found` when your Buildkite organization has no workload identity with this UUID.

## Create a workload identity

Creates a workload identity, and returns the new [workload identity object](#workload-identity-data-model), including its `client_id`.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/workload-identities" \
  -d '{
    "name": "Deploy pipeline",
    "description": "Jobs in the deploy pipeline on the main branch",
    "oidc_issuer": "https://agent.buildkite.com",
    "oidc_audience": "https://api.buildkite.com/v2/organizations/00000000-0000-4000-8000-000000000001",
    "oidc_subject": "organization:acme-inc:pipeline:deploy:ref:refs/heads/main:commit:*:step:*",
    "oidc_claims": {
      "organization_id": "00000000-0000-4000-8000-000000000001"
    },
    "oidc_claim_conditions": "claims.pipeline_id == \"00000000-0000-4000-8000-000000000002\"",
    "grantable_token_scopes": ["read_builds", "write_builds"],
    "default_token_scopes": ["read_builds"],
    "max_token_ttl_seconds": 600,
    "allowed_ip_addresses": "192.0.2.0/24",
    "allowed_token_exchange_ip_addresses": "192.0.2.0/24",
    "resource_grants": [
      {
        "type": "pipeline",
        "access": "selected",
        "ids": ["00000000-0000-4000-8000-000000000002"]
      }
    ]
  }'
```

Required [request body properties](/docs/apis/rest-api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>name</code></th>
    <td>Name of the workload identity.</td>
  </tr>
  <tr>
    <th><code>description</code></th>
    <td>Description of the workload identity.</td>
  </tr>
  <tr>
    <th><code>oidc_issuer</code></th>
    <td>Issuer URL that the OIDC token's <code>iss</code> claim must equal. Must be an HTTPS URL with no query or fragment.<p class="Docs__api-param-eg"><em>Example:</em> <code>"https://agent.buildkite.com"</code></p></td>
  </tr>
  <tr>
    <th><code>oidc_audience</code></th>
    <td>Audience that the OIDC token's <code>aud</code> claim must contain. Use a value that's unique to your Buildkite organization. The API saves a workload identity without an audience, but Buildkite refuses its token exchange requests until it has one.</td>
  </tr>
  <tr>
    <th><code>oidc_subject</code></th>
    <td>Pattern that the OIDC token's <code>sub</code> claim must match, where <code>*</code> matches any characters. The pattern must contain at least one character that isn't a wildcard, so <code>*</code> on its own isn't allowed.<p class="Docs__api-param-eg"><em>Example:</em> <code>"organization:acme-inc:pipeline:deploy:*"</code></p></td>
  </tr>
  <tr>
    <th><code>grantable_token_scopes</code></th>
    <td>Array of the maximum scopes that an API access token can have. Must include at least one scope. The available scopes are <code>read_pipelines</code>, <code>write_pipelines</code>, <code>read_builds</code>, <code>write_builds</code>, <code>retry_builds</code>, <code>read_job_env</code>, <code>read_build_logs</code>, <code>write_build_logs</code>, <code>read_artifacts</code>, <code>write_artifacts</code>, <code>read_organizations</code>, and <code>write_organizations</code>.</td>
  </tr>
</tbody>
</table>

Optional [request body properties](/docs/apis/rest-api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>oidc_claims</code></th>
    <td>Object of top-level claims and the exact values that they must have in the OIDC token, up to 20. Learn more in <a href="/docs/apis/workload-identity-federation#lock-tokens-to-an-owner-with-claims">Lock tokens to an owner with claims</a>. Workload identities for <a href="/docs/apis/workload-identity-federation/buildkite-agents">Buildkite agents</a> need an <code>organization_id</code> or <code>organization_slug</code> claim.<p class="Docs__api-param-eg"><em>Example:</em> <code>{"organization_id": "00000000-0000-4000-8000-000000000001"}</code></p></td>
  </tr>
  <tr>
    <th><code>oidc_claim_conditions</code></th>
    <td>CEL expression of up to 4,096 bytes that the OIDC token's claims must satisfy. Learn more in <a href="/docs/apis/workload-identity-federation#write-claim-conditions">Write claim conditions</a>.<p class="Docs__api-param-eg"><em>Example:</em> <code>"claims.build_branch == \"main\""</code></p></td>
  </tr>
  <tr>
    <th><code>jwks</code></th>
    <td>A JWKS URL, or inline JWKS JSON as a string, for when Buildkite can't fetch the signing keys from the issuer. Learn more in <a href="/docs/apis/workload-identity-federation#oidc-token-requirements">OIDC token requirements</a>.</td>
  </tr>
  <tr>
    <th><code>default_token_scopes</code></th>
    <td>Array of the scopes that an API access token gets when the token exchange request doesn't ask for any. Must be a subset of <code>grantable_token_scopes</code>.</td>
  </tr>
  <tr>
    <th><code>resource_grants</code></th>
    <td>Array of the pipelines that API access tokens can reach. Learn more in <a href="#workload-identity-data-model-resource-grants">Resource grants</a>.<p class="Docs__api-param-eg"><em>Default:</em> <code>[]</code>, which reaches no pipelines</p></td>
  </tr>
  <tr>
    <th><code>max_token_ttl_seconds</code></th>
    <td>Longest lifetime, in seconds, that an API access token can have, from 30 to 3,600. A token also expires when the OIDC token that it was exchanged for expires.<p class="Docs__api-param-eg"><em>Default:</em> <code>3600</code></p></td>
  </tr>
  <tr>
    <th><code>allowed_ip_addresses</code></th>
    <td>Space-separated CIDR ranges that can use the API access tokens that the workload identity mints.<p class="Docs__api-param-eg"><em>Example:</em> <code>"192.0.2.0/24 198.51.100.12/32"</code></p></td>
  </tr>
  <tr>
    <th><code>allowed_token_exchange_ip_addresses</code></th>
    <td>Space-separated CIDR ranges that can make token exchange requests for the workload identity.<p class="Docs__api-param-eg"><em>Example:</em> <code>"192.0.2.0/24"</code></p></td>
  </tr>
  <tr>
    <th><code>enabled</code></th>
    <td>Whether the workload identity accepts token exchange requests.<p class="Docs__api-param-eg"><em>Default:</em> <code>true</code></p></td>
  </tr>
</tbody>
</table>

Required scope: `write_workload_identities`

Success response: `201 Created`

Error response: `422 Unprocessable Entity` when the request has an unknown field, a value of the wrong type, or settings that Buildkite rejects, such as an unavailable scope, an invalid claim or claim condition, or a pipeline from another Buildkite organization. The response message describes each problem.

## Update a workload identity

Updates the fields in the request body, and returns the updated [workload identity object](#workload-identity-data-model). Fields that the request leaves out keep their values. An array in the request, such as `grantable_token_scopes` or `resource_grants`, replaces the existing array.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -X PATCH "https://api.buildkite.com/v2/organizations/{org.slug}/workload-identities/{uuid}" \
  -d '{
    "resource_grants": [
      {
        "type": "pipeline",
        "access": "none"
      }
    ]
  }'
```

The request body accepts the same properties as [create a workload identity](#create-a-workload-identity), and all of them are optional.

Set `enabled` to `false` to disable the workload identity. Buildkite stops accepting its token exchange requests, and revokes its active API access tokens shortly afterwards. Set `enabled` to `true` to accept token exchange requests again. Other changes only apply to new token exchanges. API access tokens that the workload identity already minted keep their pipeline access, scopes, IP restrictions, and expiry.

Required scope: `write_workload_identities`

Success response: `200 OK`

Error responses: `404 Not Found` when your Buildkite organization has no workload identity with this UUID, or `422 Unprocessable Entity` when the update is invalid. An invalid update changes nothing, including `enabled`.

## Delete a workload identity

Permanently deletes a workload identity, and revokes its API access tokens. You can't undo this action.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/workload-identities/{uuid}"
```

Required scope: `delete_workload_identities`

Success response: `204 No Content`

Error response: `404 Not Found` when your Buildkite organization has no workload identity with this UUID.
