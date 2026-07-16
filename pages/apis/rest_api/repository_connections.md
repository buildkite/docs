# Repository connections API

The repository connections API endpoint lets you list repositories available to a repository connection in your organization.

## List repositories

Returns the repositories available to the specified repository connection, in provider order.

This endpoint is supported for GitHub, GitHub Limited Access, GitHub Restricted, and GitHub Enterprise Server (GHES) connections. For Bitbucket Server, GitLab Self-Managed, and GHES Legacy connections, the endpoint returns `422 Unprocessable Entity`.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/repository_connections/{repository_connection.id}/repositories"
```

```json
[
  {
    "full_name": "acme/widgets",
    "html_url": "https://github.com/acme/widgets",
    "clone_url": "https://github.com/acme/widgets.git",
    "default_branch": "main"
  },
  {
    "full_name": "acme/gadgets",
    "html_url": "https://github.com/acme/gadgets",
    "clone_url": "https://github.com/acme/gadgets.git",
    "default_branch": "trunk"
  }
]
```

### Repository data model

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>full_name</code></th>
      <td>Full name of the repository in <code>owner/repo</code> format</td>
    </tr>
    <tr>
      <th><code>html_url</code></th>
      <td>URL of the repository on the source control provider</td>
    </tr>
    <tr>
      <th><code>clone_url</code></th>
      <td>HTTPS clone URL for the repository</td>
    </tr>
    <tr>
      <th><code>default_branch</code></th>
      <td>Default branch of the repository</td>
    </tr>
  </tbody>
</table>

### Query parameters

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>repository</code></th>
      <td>
        Optional. Filter results to the repository whose <code>full_name</code> matches this value (case-insensitive exact match). Returns an empty list if no repository matches. Returns <code>400 Bad Request</code> if the value is not a string.
      </td>
    </tr>
  </tbody>
</table>

Required scope: `read_organization_repository_connections`

Required permission: organization administrator privileges (the `change_organization` permission)

Success response: `200 OK`

Error responses:

- `400 Bad Request`: malformed connection ID, or the `repository` parameter is not a string
- `403 Forbidden`: the token does not have the `read_organization_repository_connections` scope, or the authenticated user does not have the `change_organization` permission
- `404 Not Found`: connection not found or belongs to another organization
- `422 Unprocessable Entity`: the connection type does not support repository listing
- `503 Service Unavailable`: the upstream source control provider is temporarily unavailable; may include a `Retry-After` response header indicating when to retry
