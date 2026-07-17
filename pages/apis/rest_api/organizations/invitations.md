# Organization invitations API

The organization invitations API endpoint lets platform administrators list, retrieve, create, and revoke pending invitations for a Buildkite organization.

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
    <td>Array of team assignments included in the invitation. Each entry has an <code>id</code> (team UUID) and a <code>role</code> (<code>member</code> or <code>maintainer</code>).</td>
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

Returns a [paginated list](<%= paginated_resource_docs_url %>) of pending invitations for an organization, ordered from newest to oldest. Accepted, revoked, and expired invitations are not included but can be retrieved individually by UUID.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/invitations"
```

```json
{
  "items": [
    {
      "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "graphql_id": "T3JnYW5pemF0aW9uSW52aXRhdGlvbi0tLWExYjJjM2Q0LWU1ZjYtNzg5MC1hYmNkLWVmMTIzNDU2Nzg5MA==",
      "url": "https://api.buildkite.com/v2/organizations/acme-inc/invitations/a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "email": "new-member@example.com",
      "state": "pending",
      "role": "member",
      "sso_mode": "required",
      "teams": [],
      "created_at": "2024-11-12T09:15:04.000Z",
      "created_by": {
        "id": "01234567-89ab-4cde-8f01-23456789abcd",
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
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "graphql_id": "T3JnYW5pemF0aW9uSW52aXRhdGlvbi0tLWExYjJjM2Q0LWU1ZjYtNzg5MC1hYmNkLWVmMTIzNDU2Nzg5MA==",
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/invitations/a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "email": "new-member@example.com",
  "state": "pending",
  "role": "member",
  "sso_mode": "required",
  "teams": [],
  "created_at": "2024-11-12T09:15:04.000Z",
  "created_by": {
    "id": "01234567-89ab-4cde-8f01-23456789abcd",
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

Creates invitations for one or more email addresses. The response contains the created invitations. Duplicate email addresses in the request are deduplicated case-insensitively. The entire batch is validated before any invitations are created. If any address is invalid, no invitations are created.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/invitations" \
  -H "Content-Type: application/json" \
  -d '{
    "emails": ["member@example.com", "admin@example.com"],
    "role": "member",
    "sso_mode": "required",
    "teams": [
      { "id": "team-uuid", "role": "member" }
    ]
  }'
```

```json
[
  {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "graphql_id": "T3JnYW5pemF0aW9uSW52aXRhdGlvbi0tLWExYjJjM2Q0LWU1ZjYtNzg5MC1hYmNkLWVmMTIzNDU2Nzg5MA==",
    "url": "https://api.buildkite.com/v2/organizations/acme-inc/invitations/a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "email": "member@example.com",
    "state": "pending",
    "role": "member",
    "sso_mode": "required",
    "teams": [
      { "id": "team-uuid", "role": "member" }
    ],
    "created_at": "2024-11-12T09:15:04.000Z",
    "created_by": {
      "id": "01234567-89ab-4cde-8f01-23456789abcd",
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
    <td>The SSO requirement for the invitee: <code>required</code> or <code>optional</code>. Defaults to <code>required</code>. When SSO is enabled for the organization, this field is required.</td>
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
    <td>The request contains invalid input—for example, a malformed email address, an invalid role or SSO mode, conflicting team assignments, an email address that is already a member, a batch size that exceeds the organization's invitation quota, or an organization user limit that has been reached.</td>
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
