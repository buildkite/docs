# Organization members API

The organization members API endpoint allows users to view and manage members of a Buildkite organization. Member paths use the user's UUID, which is returned as the member's `id`.

## Organization member data model

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>id</code></th>
    <td>UUID of the user</td>
  </tr>
  <tr>
    <th><code>name</code></th>
    <td>Name of the user</td>
  </tr>
  <tr>
    <th><code>email</code></th>
    <td>Email of the user</td>
  </tr>
  <tr>
    <th><code>role</code></th>
    <td>The user's role within the organization: <code>admin</code> or <code>member</code></td>
  </tr>
  <tr>
    <th><code>sso_mode</code></th>
    <td>The member's SSO requirement: <code>required</code> or <code>optional</code>. Only returned for organization admins or when viewing your own membership.</td>
  </tr>
</tbody>
</table>

## List organization members

Returns a list of an organization's members.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/members"
```

```json
[
  {
    "id": "0185c636-fcbf-4a6c-b49d-c4048e7b8aea",
    "name": "Scout Finch",
    "email": "scout@example.com",
    "role": "admin",
    "sso_mode": "required"
  },
  {
    "id": "0185dbbf-8447-4f72-ac7e-4ea3c2ec8381",
    "name": "Huck Finn",
    "email": "huck@example.com",
    "role": "member",
    "sso_mode": "required"
  }
]
```

Required scope: `read_organizations`

Required permission: permission to view teams in the organization

Success response: `200 OK`

## Get an organization member

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/members/{user.uuid}"
```

```json
{
  "id": "0185dbbf-8447-4f72-ac7e-4ea3c2ec8381",
  "name": "Victor Frankenstein",
  "email": "vic@example.com",
  "role": "member",
  "sso_mode": "required"
}
```

Required scope: `read_organizations`

Required permission: permission to view teams in the organization

Success response: `200 OK`

## Update an organization member

Updates a member's role or SSO mode within the organization. At least one of `role` or `sso_mode` must be provided. You cannot update your own membership.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PATCH "https://api.buildkite.com/v2/organizations/{org.slug}/members/{user.uuid}" \
  -H "Content-Type: application/json" \
  -d '{
    "role": "admin",
    "sso_mode": "optional"
  }'
```

```json
{
  "id": "0185dbbf-8447-4f72-ac7e-4ea3c2ec8381",
  "name": "Victor Frankenstein",
  "email": "vic@example.com",
  "role": "admin",
  "sso_mode": "optional"
}
```

Optional [request body properties](/docs/apis/rest-api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>role</code></th>
    <td>The role to assign to the member: <code>admin</code> or <code>member</code></td>
  </tr>
  <tr>
    <th><code>sso_mode</code></th>
    <td>The SSO requirement for the member: <code>required</code> or <code>optional</code></td>
  </tr>
</tbody>
</table>

Required scope: `write_organizations`

Required permission: permission to update the organization member

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The token does not have the required scope, the user cannot update the member, or the user attempts to update their own membership.</td>
  </tr>
  <tr>
    <th><code>404 Not Found</code></th>
    <td>The organization or member could not be found or accessed.</td>
  </tr>
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td>The request does not provide <code>role</code> or <code>sso_mode</code>, supplies an unsupported value, or the member cannot be updated.</td>
  </tr>
</tbody>
</table>

## Remove an organization member

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/members/{user.uuid}"
```

Required scope: `write_organizations`

Required permission: permission to remove the organization member

Success response: `204 No Content`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The token does not have the required scope or the user cannot remove the member.</td>
  </tr>
  <tr>
    <th><code>404 Not Found</code></th>
    <td>The organization or member could not be found or accessed.</td>
  </tr>
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td>The member cannot be removed, such as when removing them would leave the organization without an administrator.</td>
  </tr>
</tbody>
</table>
