# Repository connections API

The repository connections API lets organization administrators list and inspect connected source control integrations. Repository connections provide a consistent representation across GitHub, GitHub Enterprise Server, Bitbucket Server, and GitLab Self-Managed connection types.

These endpoints are read-only and do not return credentials or other secret values. The endpoints require the `read_organization_repository_connections` [OAuth scope](/docs/apis/managing-api-tokens#token-scopes) and organization administrator access.

## Repository connection data model

List responses contain the following fields:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>id</code></th>
    <td>Stable UUID for the repository connection</td>
  </tr>
  <tr>
    <th><code>type</code></th>
    <td>Connection type: <code>github_app</code>, <code>github_code_access_app</code>, <code>github_enterprise_app</code>, <code>github_restricted_app</code>, <code>github_enterprise</code>, <code>bitbucket_server</code>, or <code>gitlab_self_managed</code></td>
  </tr>
  <tr>
    <th><code>display_name</code></th>
    <td>Human-readable name for the connection</td>
  </tr>
  <tr>
    <th><code>url</code></th>
    <td>Canonical API URL for the repository connection</td>
  </tr>
</tbody>
</table>

Get responses also contain the following fields:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>service_account</code></th>
    <td>Connected service account with its <code>login</code>, or <code>null</code> for host-only connections</td>
  </tr>
  <tr>
    <th><code>host</code></th>
    <td>Source control host details, or <code>null</code> when they are unavailable. Contains <code>type</code> and <code>url</code>. Depending on the provider, the host can also contain <code>webhook_allowed_addresses</code>, <code>verify_server_cert</code>, <code>authentication_strategy</code>, or <code>proxy_auth_strategy</code></td>
  </tr>
  <tr>
    <th><code>rate_limit</code></th>
    <td>Cached provider rate-limit details, or <code>null</code> when they are unavailable or do not apply. When present, contains <code>limit</code>, <code>used</code>, <code>remaining</code>, and <code>reset_at</code></td>
  </tr>
</tbody>
</table>

Bitbucket Server connections with multiple configured URLs return a comma-separated value in `host.url`.

## List repository connections

Returns an unpaginated list of repository connections for an organization.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/repository_connections"
```

```json
[
  {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "type": "github_code_access_app",
    "display_name": "GitHub (acme-inc)",
    "url": "https://api.buildkite.com/v2/organizations/acme-inc/repository_connections/01234567-89ab-cdef-0123-456789abcdef"
  },
  {
    "id": "12345678-9abc-def0-1234-56789abcdef0",
    "type": "gitlab_self_managed",
    "display_name": "GitLab Self-Managed",
    "url": "https://api.buildkite.com/v2/organizations/acme-inc/repository_connections/12345678-9abc-def0-1234-56789abcdef0"
  }
]
```

Required scope: `read_organization_repository_connections`

Required permission: organization administrator access

Success response: `200 OK`

## Get a repository connection

Returns a repository connection by its ID.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/repository_connections/{id}"
```

```json
{
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "type": "github_code_access_app",
  "display_name": "GitHub (acme-inc)",
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/repository_connections/01234567-89ab-cdef-0123-456789abcdef",
  "service_account": {
    "login": "acme-inc"
  },
  "host": {
    "type": "github",
    "url": "https://github.com"
  },
  "rate_limit": {
    "limit": 5000,
    "used": 42,
    "remaining": 4958,
    "reset_at": "2026-07-16T06:00:00Z"
  }
}
```

Required scope: `read_organization_repository_connections`

Required permission: organization administrator access

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>400 Bad Request</code></th>
    <td>The connection ID is not a valid UUID.</td>
  </tr>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The token does not have the required scope or the user does not have organization administrator access.</td>
  </tr>
  <tr>
    <th><code>404 Not Found</code></th>
    <td>The repository connection does not exist or belongs to a different organization.</td>
  </tr>
</tbody>
</table>
