# Portals API

The portals API endpoint lets you create and manage [portals](/docs/apis/graphql/portals) in your Buildkite organization.

## Portals

Portals provide restricted GraphQL API access to the Buildkite platform by defining stored GraphQL operations accessible through authenticated URL endpoints.

### Portal data model

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>uuid</code></th>
    <td>UUID of the portal</td>
  </tr>
  <tr>
    <th><code>slug</code></th>
    <td>Slug of the portal, used in API URLs</td>
  </tr>
  <tr>
    <th><code>organization_uuid</code></th>
    <td>UUID of the organization</td>
  </tr>
  <tr>
    <th><code>name</code></th>
    <td>Name of the portal</td>
  </tr>
  <tr>
    <th><code>description</code></th>
    <td>Description of the portal</td>
  </tr>
  <tr>
    <th><code>query</code></th>
    <td>GraphQL query that the portal executes</td>
  </tr>
  <tr>
    <th><code>allowed_ip_addresses</code></th>
    <td>Space-separated list of allowed IP addresses in CIDR notation</td>
  </tr>
  <tr>
    <th><code>user_invokable</code></th>
    <td>Whether users can invoke the portal</td>
  </tr>
  <tr>
    <th><code>created_at</code></th>
    <td>When the portal was created</td>
  </tr>
  <tr>
    <th><code>created_by</code></th>
    <td>User who created the portal</td>
  </tr>
  <tr>
    <th><code>token</code></th>
    <td>Plaintext portal token. Only returned when creating a portal.</td>
  </tr>
</tbody>
</table>

> 📘 Portal token
> The `token` field is only present in the response when creating a portal. Store it securely, as it cannot be retrieved again.

### List portals

Returns a [paginated list](<%= paginated_resource_docs_url %>) of an organization's portals.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/portals"
```

```json
[
  {
    "uuid": "01234567-89ab-cdef-0123-456789abcdef",
    "slug": "trigger-main-build",
    "organization_uuid": "f02d6a6f-7a0e-481d-9d6d-89b427aec48d",
    "name": "Trigger main build",
    "description": "Triggers a build on the main branch",
    "query": "mutation triggerBuild { buildCreate(input: { branch: \"main\", commit: \"HEAD\", pipelineID: \"UGlwZWxpbmUtLS0x\" }) { build { url } } }",
    "created_at": "2024-08-26T03:22:45.555Z",
    "created_by": {
      "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
      "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
      "name": "Sam Kim",
      "email": "sam@example.com",
      "avatar_url": "https://www.gravatar.com/avatar/example",
      "created_at": "2013-08-29T10:10:03.000Z"
    },
    "allowed_ip_addresses": "192.0.2.1/32 198.51.100.0/24",
    "user_invokable": false
  }
]
```

Required scope: `read_portals`

Success response: `200 OK`

### Get a portal

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/portals/{portal.slug}"
```

```json
{
  "uuid": "01234567-89ab-cdef-0123-456789abcdef",
  "slug": "trigger-main-build",
  "organization_uuid": "f02d6a6f-7a0e-481d-9d6d-89b427aec48d",
  "name": "Trigger main build",
  "description": "Triggers a build on the main branch",
  "query": "mutation triggerBuild { buildCreate(input: { branch: \"main\", commit: \"HEAD\", pipelineID: \"UGlwZWxpbmUtLS0x\" }) { build { url } } }",
  "created_at": "2024-08-26T03:22:45.555Z",
  "created_by": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2013-08-29T10:10:03.000Z"
  },
  "allowed_ip_addresses": "192.0.2.1/32 198.51.100.0/24",
  "user_invokable": false
}
```

Required scope: `read_portals`

Success response: `200 OK`

### Create a portal

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/portals" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Trigger main build",
    "query": "mutation triggerBuild { buildCreate(input: { branch: \"main\", commit: \"HEAD\", pipelineID: \"UGlwZWxpbmUtLS0x\" }) { build { url } } }"
  }'
```

```json
{
  "uuid": "01234567-89ab-cdef-0123-456789abcdef",
  "slug": "trigger-main-build",
  "organization_uuid": "f02d6a6f-7a0e-481d-9d6d-89b427aec48d",
  "name": "Trigger main build",
  "description": null,
  "query": "mutation triggerBuild { buildCreate(input: { branch: \"main\", commit: \"HEAD\", pipelineID: \"UGlwZWxpbmUtLS0x\" }) { build { url } } }",
  "created_at": "2024-08-26T03:22:45.555Z",
  "created_by": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2013-08-29T10:10:03.000Z"
  },
  "allowed_ip_addresses": null,
  "user_invokable": false,
  "token": "xxx-yyy-zzz"
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>name</code></th>
    <td>Name for the portal.<br><em>Example:</em> <code>"Trigger main build"</code></td>
  </tr>
  <tr>
    <th><code>query</code></th>
    <td>GraphQL query that the portal executes.<br><em>Example:</em> <code>"mutation triggerBuild { buildCreate(input: { branch: \"main\", pipelineID: \"abc123\" }) { build { url } } }"</code></td>
  </tr>
</tbody>
</table>

[Request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>slug</code></th>
    <td>Slug for the portal. Auto-generated from the name if not provided.<br><em>Example:</em> <code>"trigger-main-build"</code></td>
  </tr>
  <tr>
    <th><code>description</code></th>
    <td>Description for the portal.<br><em>Example:</em> <code>"Triggers a build on the main branch"</code></td>
  </tr>
  <tr>
    <th><code>allowed_ip_addresses</code></th>
    <td>Space-separated list of allowed IP addresses in CIDR notation.<br><em>Example:</em> <code>"192.0.2.1/32 198.51.100.0/24"</code></td>
  </tr>
  <tr>
    <th><code>user_invokable</code></th>
    <td>Whether users can invoke the portal.<br><em>Example:</em> <code>false</code></td>
  </tr>
</tbody>
</table>

Required scope: `write_portals`

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

### Update a portal

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/portals/{portal.slug}" \
  -H "Content-Type: application/json" \
  -d '{ "name": "Trigger main build" }'
```

```json
{
  "uuid": "01234567-89ab-cdef-0123-456789abcdef",
  "slug": "trigger-main-build",
  "organization_uuid": "f02d6a6f-7a0e-481d-9d6d-89b427aec48d",
  "name": "Trigger main build",
  "description": "Triggers a build on the main branch",
  "query": "mutation triggerBuild { buildCreate(input: { branch: \"main\", commit: \"HEAD\", pipelineID: \"UGlwZWxpbmUtLS0x\" }) { build { url } } }",
  "created_at": "2024-08-26T03:22:45.555Z",
  "created_by": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2013-08-29T10:10:03.000Z"
  },
  "allowed_ip_addresses": "192.0.2.1/32 198.51.100.0/24",
  "user_invokable": false
}
```

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>name</code></th>
    <td>Name for the portal.<br><em>Example:</em> <code>"Trigger main build"</code></td>
  </tr>
  <tr>
    <th><code>slug</code></th>
    <td>Slug for the portal.<br><em>Example:</em> <code>"trigger-main-build"</code></td>
  </tr>
  <tr>
    <th><code>description</code></th>
    <td>Description for the portal.<br><em>Example:</em> <code>"Triggers a build on the main branch"</code></td>
  </tr>
  <tr>
    <th><code>query</code></th>
    <td>GraphQL query that the portal executes.<br><em>Example:</em> <code>"mutation triggerBuild { buildCreate(input: { branch: \"main\", pipelineID: \"abc123\" }) { build { url } } }"</code></td>
  </tr>
  <tr>
    <th><code>allowed_ip_addresses</code></th>
    <td>Space-separated list of allowed IP addresses in CIDR notation.<br><em>Example:</em> <code>"192.0.2.1/32 198.51.100.0/24"</code></td>
  </tr>
  <tr>
    <th><code>user_invokable</code></th>
    <td>Whether users can invoke the portal.<br><em>Example:</em> <code>false</code></td>
  </tr>
</tbody>
</table>

Required scope: `write_portals`

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

### Delete a portal

Delete a portal.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/portals/{portal.slug}"
```

Required scope: `write_portals`

Success response: `204 No Content`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td><code>{ "message": "Reason the portal couldn't be deleted" }</code></td>
  </tr>
</tbody>
</table>
