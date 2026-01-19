# Teams API

The teams API endpoint allows you to view and manage teams within an organization.

## Team data model

<table>
<tbody>
  <tr><th><code>id</code></th><td>ID of the team</td></tr>
  <tr><th><code>name</code></th><td>Name of the team</td></tr>
  <tr><th><code>slug</code></th><td>URL slug of the team</td></tr>
  <tr><th><code>description</code></th><td>Description of the team</td></tr>
  <tr><th><code>privacy</code></th><td>Privacy setting of the team (<code>visible</code>, <code>secret</code>)</td></tr>
  <tr><th><code>default</code></th><td>Whether users join this team by default (<code>true</code>, <code>false</code>)</td></tr>
  <tr><th><code>created_at</code></th><td>Time of when the team was created</td></tr>
  <tr><th><code>created_by</code></th><td>User who created the team</td></tr>
</tbody>
</table>

## List teams

Returns a [paginated list](<%= paginated_resource_docs_url %>) of an organization's teams.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/teams"
```

```json
[
  {
    "id": "c5e09619-8648-4896-a936-9d0b8b7b3fe9",
    "graphql_id": "VGVhbS0tLWM1ZTA5NjE5LTg2NDgtNDg5Ni1hOTM2LTlkMGI4YjdiM2ZlOQ==",
    "name": "Fearless Frontenders",
    "slug": "fearless-frontenders",
    "description": "",
    "created_at": "2023-03-14T00:45:16.215Z",
    "privacy": "secret",
    "default": true,
    "created_by": {
      "id": "8s7ce846-f6c0-4360-8133-389b03c7c46a",
      "graphql_id": "VXNlci0tLTg3NWNlODQ2LWY2YzAtNDM2MC04MTMzLTM4OWIwM2M3YzQ2YQ==",
      "name": "Peter Pettigrew",
      "email": "pp@hogwarts.co.uk",
      "avatar_url": "https://www.gravatar.com/avatar/aa9e3513ea543edb9143cbcca425e56c",
      "created_at": "2022-01-18T02:51:30.983Z"
    }
  },
]
```

Optional [query string parameters](/docs/api#query-string-parameters):

<table>
<tbody>
  <tr><th><code>user_id</code></th><td>Filters the results to teams that have the given user as a member. <p class="Docs__api-param-eg"><em>Example:</em> <code>?user_id=5acb99cf-d349-4189-b361-d1b9f36d70d7</code></p></td></tr>
</tbody>
</table>


Required scope: `read_teams`

Success response: `200 OK`

## Get a team

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/teams/{team.uuid}"
```

```json
{
  "id": "c5e09619-8648-4896-a936-9d0b8b7b3fe9",
  "graphql_id": "VGVhbS0tLWM1ZTA5NjE5LTg2NDgtNDg5Ni1hOTM2LTlkMGI4YjdiM2ZlOQ==",
  "name": "Fearless Frontenders",
  "slug": "fearless-frontenders",
  "description": "",
  "created_at": "2023-03-14T00:45:16.215Z",
  "privacy": "secret",
  "default": true,
  "created_by": {
    "id": "8s7ce846-f6c0-4360-8133-389b03c7c46a",
    "graphql_id": "VXNlci0tLTg3NWNlODQ2LWY2YzAtNDM2MC04MTMzLTM4OWIwM2M3YzQ2YQ==",
    "name": "Peter Pettigrew",
    "email": "pp@hogwarts.co.uk",
    "avatar_url": "https://www.gravatar.com/avatar/aa9e3513ea543edb9143cbcca425e56c",
    "created_at": "2022-01-18T02:51:30.983Z"
  }
}
```

Required scope: `view_teams`

Success response: `200 OK`

## Create a team

Creates a team.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/teams" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Barefoot Backenders",
    "description": "Backend engineers at Acme Inc",
    "privacy": "secret",
    "is_default_team": false,
    "default_member_role": "member",
    "members_can_create_pipelines": true,
    "members_can_create_suites": true,
    "members_can_create_registries": true,
    "members_can_destroy_registries": false,
    "members_can_destroy_packages": false
  }'
```

```json
{
  "name": "Barefoot Backenders",
  "description": "Backend engineers at Acme Inc",
  "privacy": "secret",
  "is_default_team": false,
  "default_member_role": "member",
  "members_can_create_pipelines": true,
  "members_can_create_suites": true,
  "members_can_create_registries": true,
  "members_can_destroy_registries": false,
  "members_can_destroy_packages": false
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
  <tbody>
    <tr><th><code>name</code></th><td>Name of the team</td></tr>
    <tr><th><code>description</code></th><td>Description of the team</td></tr>
    <tr><th><code>privacy</code></th><td>Privacy setting of the team (<code>visible</code>, <code>secret</code>)</td></tr>
    <tr><th><code>is_default_team</code></th><td>Whether new organization members are assigned to this team by default (<code>true</code>, <code>false</code>)</td></tr>
    <tr><th><code>default_member_role</code></th><td>The default role assigned to members of this team (<code>member</code>, <code>maintainer</code>)</td></tr>
    <tr><th><code>members_can_create_pipelines</code></th><td>Whether or not team members can create new pipelines (<code>true</code>, <code>false</code>)</td></tr>
    <tr><th><code>members_can_create_suites</code></th><td>Whether or not team members can create new test suites (<code>true</code>, <code>false</code>)</td></tr>
    <tr><th><code>members_can_create_registries</code></th><td>Whether or not team members can create new registries (<code>true</code>, <code>false</code>)</td></tr>
    <tr><th><code>members_can_destroy_registries</code></th><td>Whether or not team members can destroy registries (<code>true</code>, <code>false</code>)</td></tr>
    <tr><th><code>members_can_destroy_packages</code></th><td>Whether or not team members can destroy packages (<code>true</code>, <code>false</code>)</td></tr>
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

## Update a team

Updates a team.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PATCH "https://api.buildkite.com/v2/organizations/{org.slug}/teams/{team.uuid}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New and Improved Backenders V2!",
    "description": "Updated backend engineers team at Acme Inc",
    "privacy": "visible",
    "is_default_team": true,
    "default_member_role": "maintainer",
    "members_can_create_pipelines": false,
    "members_can_create_suites": false,
    "members_can_create_registries": true,
    "members_can_destroy_registries": false,
    "members_can_destroy_packages": false
  }'
```

```json
{
  "name": "New and Improved Backenders V2!",
  "description": "Updated backend engineers team at Acme Inc",
  "privacy": "visible",
  "is_default_team": true,
  "default_member_role": "maintainer",
  "members_can_create_pipelines": false,
  "members_can_create_suites": false,
  "members_can_create_registries": true,
  "members_can_destroy_registries": false,
  "members_can_destroy_packages": false
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
  <tbody>
    <tr><th><code>name</code></th><td>Name of the team</td></tr>
    <tr><th><code>description</code></th><td>Description of the team</td></tr>
    <tr><th><code>privacy</code></th><td>Privacy setting of the team (<code>visible</code>, <code>secret</code>)</td></tr>
    <tr><th><code>is_default_team</code></th><td>Whether new organization members are assigned to this team by default (<code>true</code>, <code>false</code>)</td></tr>
    <tr><th><code>default_member_role</code></th><td>The default role assigned to members of this team (<code>member</code>, <code>maintainer</code>)</td></tr>
    <tr><th><code>members_can_create_pipelines</code></th><td>Whether or not team members can create new pipelines (<code>true</code>, <code>false</code>)</td></tr>
    <tr><th><code>members_can_create_suites</code></th><td>Whether or not team members can create new test suites (<code>true</code>, <code>false</code>)</td></tr>
    <tr><th><code>members_can_create_registries</code></th><td>Whether or not team members can create new registries (<code>true</code>, <code>false</code>)</td></tr>
    <tr><th><code>members_can_destroy_registries</code></th><td>Whether or not team members can destroy registries (<code>true</code>, <code>false</code>)</td></tr>
    <tr><th><code>members_can_destroy_packages</code></th><td>Whether or not team members can destroy packages (<code>true</code>, <code>false</code>)</td></tr>
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

## Delete a team

Remove a team.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/teams/{team.uuid}"
```

Required scope: `write_teams`

Success response: `204 No Content`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Reason the team couldn't be deleted" }</code></td></tr>
</tbody>
</table>

## Related endpoints

- [Team members](/docs/apis/rest-api/teams/members) - Manage members of a team
- [Team pipelines](/docs/apis/rest-api/teams/pipelines) - Assign pipelines to teams
- [Team suites](/docs/apis/rest-api/teams/suites) - Assign test suites to teams
