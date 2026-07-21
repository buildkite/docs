# Organization invitations API

The organization invitations REST API lets authorized users list, retrieve, create, and revoke invitations for a Buildkite organization.

## Organization invitation data model

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>id</code></th>
    <td>UUID of the invitation.</td>
  </tr>
  <tr>
    <th><code>graphql_id</code></th>
    <td>The GraphQL ID of the invitation. Use this to look up the invitation using the <a href="/docs/apis/graphql-api">GraphQL API</a>.</td>
  </tr>
  <tr>
    <th><code>url</code></th>
    <td>The canonical API URL for this invitation.</td>
  </tr>
  <tr>
    <th><code>email</code></th>
    <td>The email address the invitation was sent to.</td>
  </tr>
  <tr>
    <th><code>state</code></th>
    <td>Current state of the invitation: <code>pending</code>, <code>accepted</code>, <code>revoked</code>, or <code>expired</code>.</td>
  </tr>
  <tr>
    <th><code>role</code></th>
    <td>The organization role offered: <code>admin</code> or <code>member</code>.</td>
  </tr>
  <tr>
    <th><code>sso_mode</code></th>
    <td>The SSO requirement for the invited member: <code>required</code> or <code>optional</code>.</td>
  </tr>
  <tr>
    <th><code>teams</code></th>
    <td>Array of teams included in the invitation. Each entry contains the team <code>id</code> (UUID), <code>graphql_id</code>, and <code>slug</code>.</td>
  </tr>
  <tr>
    <th><code>created_at</code></th>
    <td>ISO 8601 timestamp of when the invitation was created.</td>
  </tr>
  <tr>
    <th><code>created_by</code></th>
    <td>The user who created the invitation.</td>
  </tr>
  <tr>
    <th><code>accepted_at</code></th>
    <td>ISO 8601 timestamp of when the invitation was accepted, or <code>null</code>.</td>
  </tr>
  <tr>
    <th><code>accepted_by</code></th>
    <td>The user who accepted the invitation, or <code>null</code>.</td>
  </tr>
  <tr>
    <th><code>revoked_at</code></th>
    <td>ISO 8601 timestamp of when the invitation was revoked, or <code>null</code>.</td>
  </tr>
  <tr>
    <th><code>revoked_by</code></th>
    <td>The user who revoked the invitation, or <code>null</code>.</td>
  </tr>
  <tr>
    <th><code>expired_at</code></th>
    <td>ISO 8601 timestamp of when the invitation expired, or <code>null</code>.</td>
  </tr>
</tbody>
</table>

## List organization invitations

Returns a [paginated list](<%= paginated_resource_docs_url %>) of pending invitations for an organization, ordered from newest to oldest. The list does not include accepted, revoked, or expired invitations. You can retrieve those invitations individually by UUID.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/invitations"
```

```json
{
  "items": [
    {
      "id": "00000000-0000-4000-8000-000000000001",
      "graphql_id": "T3JnYW5pemF0aW9uSW52aXRhdGlvbi0tLTAwMDAwMDAwLTAwMDAtNDAwMC04MDAwLTAwMDAwMDAwMDAwMQ==",
      "url": "https://api.buildkite.com/v2/organizations/acme-inc/invitations/00000000-0000-4000-8000-000000000001",
      "email": "new-member@example.com",
      "state": "pending",
      "role": "member",
      "sso_mode": "required",
      "teams": [],
      "created_at": "2024-11-12T09:15:04.000Z",
      "created_by": {
        "id": "00000000-0000-4000-8000-000000000002",
        "name": "Example User",
        "email": "example@example.com"
      },
      "accepted_at": null,
      "accepted_by": null,
      "revoked_at": null,
      "revoked_by": null,
      "expired_at": null
    }
  ],
  "links": {
    "self": "https://api.buildkite.com/v2/organizations/acme-inc/invitations?per_page=30",
    "next": "https://api.buildkite.com/v2/organizations/acme-inc/invitations?per_page=30&after=eyJjcmVhdGVkX2F0IjoiMjAyNC0xMS0xMlQwOToxNTowNC4wMDBaIn0="
  }
}
```

The response body contains the following pagination fields:

- `items`: The invitations on the current page.
- `links`: URLs for the current page and available `next` page. Follow these URLs instead of constructing cursors. The response also includes these links in the HTTP `Link` header.

Optional query string parameters:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>after</code></th>
    <td>Returns the next page after the supplied cursor. Cannot be combined with <code>before</code>.</td>
  </tr>
  <tr>
    <th><code>before</code></th>
    <td>Returns the previous page before the supplied cursor. Cannot be combined with <code>after</code>.</td>
  </tr>
  <tr>
    <th><code>per_page</code></th>
    <td>Number of results per page. Defaults to <code>30</code> and has a maximum of <code>100</code>.</td>
  </tr>
</tbody>
</table>

Required scope: `read_organization_invitations`

Required permission: permission to invite organization members

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>400 Bad Request</code></th>
    <td>The request supplies both cursor parameters, a non-string cursor value, or a <code>per_page</code> value outside the supported range.</td>
  </tr>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The token does not have the required scope or the user does not have permission to invite organization members.</td>
  </tr>
</tbody>
</table>

## Get an organization invitation

Returns a single invitation by UUID. Unlike the list endpoint, this returns invitations in any state.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/invitations/{uuid}"
```

```json
{
  "id": "00000000-0000-4000-8000-000000000001",
  "graphql_id": "T3JnYW5pemF0aW9uSW52aXRhdGlvbi0tLTAwMDAwMDAwLTAwMDAtNDAwMC04MDAwLTAwMDAwMDAwMDAwMQ==",
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/invitations/00000000-0000-4000-8000-000000000001",
  "email": "new-member@example.com",
  "state": "pending",
  "role": "member",
  "sso_mode": "required",
  "teams": [],
  "created_at": "2024-11-12T09:15:04.000Z",
  "created_by": {
    "id": "00000000-0000-4000-8000-000000000002",
    "name": "Example User",
    "email": "example@example.com"
  },
  "accepted_at": null,
  "accepted_by": null,
  "revoked_at": null,
  "revoked_by": null,
  "expired_at": null
}
```

Required scope: `read_organization_invitations`

Required permission: permission to invite organization members

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The token does not have the required scope or the user does not have permission to invite organization members.</td>
  </tr>
  <tr>
    <th><code>404 Not Found</code></th>
    <td>The invitation UUID does not exist or belongs to a different organization.</td>
  </tr>
</tbody>
</table>

## Create organization invitations

Creates invitations for one or more email addresses. The response contains the created invitations. The API treats duplicate email addresses as one address, regardless of capitalization. The entire batch is validated before any invitations are created. If any address is invalid, no invitations are created.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/invitations" \
  -H "Content-Type: application/json" \
  -d '{
    "emails": ["member@example.com", "admin@example.com"],
    "role": "member",
    "sso_mode": "required",
    "teams": [
      { "id": "00000000-0000-4000-8000-000000000003", "role": "member" }
    ]
  }'
```

```json
[
  {
    "id": "00000000-0000-4000-8000-000000000001",
    "graphql_id": "T3JnYW5pemF0aW9uSW52aXRhdGlvbi0tLTAwMDAwMDAwLTAwMDAtNDAwMC04MDAwLTAwMDAwMDAwMDAwMQ==",
    "url": "https://api.buildkite.com/v2/organizations/acme-inc/invitations/00000000-0000-4000-8000-000000000001",
    "email": "member@example.com",
    "state": "pending",
    "role": "member",
    "sso_mode": "required",
    "teams": [
      { "id": "00000000-0000-4000-8000-000000000003", "graphql_id": "TEAM_GRAPHQL_ID", "slug": "example-team" }
    ],
    "created_at": "2024-11-12T09:15:04.000Z",
    "created_by": {
      "id": "00000000-0000-4000-8000-000000000002",
      "name": "Example User",
      "email": "example@example.com"
    },
    "accepted_at": null,
    "accepted_by": null,
    "revoked_at": null,
    "revoked_by": null,
    "expired_at": null
  }
]
```

Required [request body properties](/docs/apis/rest-api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>emails</code></th>
    <td>An array of email address strings to invite.</td>
  </tr>
</tbody>
</table>

Optional [request body properties](/docs/apis/rest-api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>role</code></th>
    <td>The organization role to assign to the invitee: <code>admin</code> or <code>member</code>. Defaults to <code>member</code>.</td>
  </tr>
  <tr>
    <th><code>sso_mode</code></th>
    <td>The SSO requirement for the invitee: <code>required</code> or <code>optional</code>. When SSO is disabled for the organization, omitting this field defaults it to <code>required</code>. When SSO is enabled, this field is required, and omitting it returns <code>422 Unprocessable Entity</code>.</td>
  </tr>
  <tr>
    <th><code>teams</code></th>
    <td>An array of team assignment objects. Each object requires an <code>id</code> (team UUID) and a <code>role</code> (<code>member</code> or <code>maintainer</code>). Provide at most one assignment per team. Omit or provide an empty array to skip team assignments.</td>
  </tr>
</tbody>
</table>

Required scope: `write_organization_invitations`

Required permission: permission to invite organization members

Success response: `201 Created`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The token does not have the required scope or the user does not have permission to invite organization members.</td>
  </tr>
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td>The request contains invalid input, such as a malformed email address, an invalid role or SSO mode, conflicting team assignments, an email address that is already a member, a batch size that exceeds the organization's invitation quota, or an organization user limit that has been reached. This response also occurs when the organization has SSO enabled and the request omits <code>sso_mode</code>.</td>
  </tr>
</tbody>
</table>

## Revoke an organization invitation

Revokes a pending invitation. Returns no content on success. Only pending invitations can be revoked.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/invitations/{uuid}"
```

Required scope: `write_organization_invitations`

Required permission: permission to invite organization members

Success response: `204 No Content`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The token does not have the required scope or the user does not have permission to invite organization members.</td>
  </tr>
  <tr>
    <th><code>404 Not Found</code></th>
    <td>The invitation UUID does not exist or belongs to a different organization.</td>
  </tr>
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td>The invitation cannot be revoked because it has already been accepted, revoked, or expired.</td>
  </tr>
</tbody>
</table>
