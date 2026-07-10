# Organization members API

The organization members API endpoint allows users to view and manage members of a Buildkite organization.

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

Optional [request body properties](/docs/api#request-body-properties):

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

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td><code>{ "message": "Reason the member couldn't be updated" }</code></td>
  </tr>
</tbody>
</table>

## Remove an organization member

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/members/{user.uuid}"
```

Required scope: `write_organizations`

Success response: `204 No Content`
