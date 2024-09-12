# Team members API

The team members API endpoint allows users to review, create, update, and delete members associated with a team in your organization.

## Team member data model

<table class="responsive-table">
<tbody>

  <tr><th><code>user_name</code></th><td>The name of the user</td></tr>
  <tr><th><code>user_id</code></th><td>The UUID of the user</td></tr>
  <tr><th><code>created_at</code></th><td>When the team and user association was created</td></tr>
  <tr><th><code>role</code></th><td>The role the member has within the team - <code>member</code> or <code>maintainer</code></td></tr>
</tbody>
</table>

## List team members

Returns a list of a team's associated members.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/teams/{team.uuid}/members"
```

```json
[
  {
    "role": "member",
    "created_at": "2023-03-14T00:49:55.534Z",
    "user_id": "978ce846-f6c0-4360-8133-389b03cus7a",
    "user_name": "Severus Snape"
  },
  {
    "role": "member",
    "created_at": "2023-03-14T00:49:55.534Z",
    "user_id": "3878ce86-f6c0-4360-8133-389b0372",
    "user_name": "Draco Malfoy"
  },
]
```

Required scope: `view_teams`

Success response: `200 OK`

## Get a team member

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/teams/{team.uuid}/members/{user.uuid}"
```

```json
{
  "role": "member",
  "created_at": "2023-12-15T00:23:23.823Z",
  "user_id": "018c6030-b459-45b2-a844-951f0fc8a4e7",
  "user_name": "Dolores Umbridge"
}
```

Required scope: `view_teams`

Success response: `200 OK`

## Create a team member

Creates an association between a team and a user.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/teams/{team.uuid}/members/" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "6030-b459-45b2-a844-951f0fs727",
    "role": "maintainer"
  }'
```

```json
{
  "role": "maintainer",
  "created_at": "2023-12-14T00:43:04.675Z",
  "user_id": "875ce846-f6c0-4360-8133-389b03c7c46a",
  "user_name": "Professor Quirrel"
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>user_id</code></th>
    <td>The UUID of the user.</td>
  </tr>
  <tr>
    <th><code>role</code></th>
    <td>The role the member has within the team - <code>member</code> or <code>maintainer</code></td>
  </tr>
</tbody>
</table>

Required scope: `write_teams`

Success response: `201 Created`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Validation failed: Reason for failure" }</code></td></tr>
</tbody>
</table>

## Update a team member

Updates an association between a team and a user.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PATCH "https://api.buildkite.com/v2/organizations/{org.slug}/teams/{team.uuid}/members/{user.uuid}" \
  -H "Content-Type: application/json" \
  -d '{
    "role": "member"
  }'
```

```json
{
  "role": "member",
  "created_at": "2023-12-15T00:23:23.823Z",
  "user_id": "027c6030-b459-45b2-a844-951f0fc8a4e7",
  "user_name": "Ron Weasley"
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>role</code></th>
    <td>The role the member has within the team - <code>member</code> or <code>maintainer</code></td>
  </tr>
</tbody>
</table>

Required scope: `write_teams`

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Validation failed: Reason for failure" }</code></td></tr>
</tbody>
</table>

## Delete a team member

Remove the association between a team and a user.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/teams/{team.uuid}/members/{user.uuid}"
```

Required scope: `write_teams`

Success response: `204 No Content`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Reason the team member couldn't be deleted" }</code></td></tr>
</tbody>
</table>
