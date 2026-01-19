# Team suites API

This endpoint manages test suite associations with a [team](/docs/apis/rest-api/teams).

The team suites API endpoint allows users to review, create, update, and delete test suites associated with a team in your organization.

## Team suite data model

<table class="responsive-table">
<tbody>
  <tr><th><code>suite_id</code></th><td>UUID of the suite</td></tr>
  <tr><th><code>suite_url</code></th><td>URL of the suite</td></tr>
  <tr><th><code>created_at</code></th><td>When the team and suite association was created</td></tr>
  <tr><th><code>access_level</code></th><td>The access levels that user has to the associated suite - <code>edit</code>, <code>read</code></td></tr>
</tbody>
</table>

## List team suites

Returns a list of a team's associated suites.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/teams/{team.uuid}/suites"
```

```json
[
  {
    "access_level": [ "read" ],
    "created_at": "2024-01-11T04:24:21.352Z",
    "suite_id": "19f3973d-1e0b-43f1-b490-22be52abd99a",
    "suite_url": "https://api.buildkite.com/v2/analytics/organizations/acme-corp/suites/suite-dreams"
  },
  {
    "access_level": [ "read", "edit" ],
    "created_at": "2024-01-11T04:24:21.352Z",
    "suite_id": "19f3973d-1e0b-43f1-b490-22besa5299a",
    "suite_url": "https://api.buildkite.com/v2/analytics/organizations/acme-corp/suites/suite-and-sour"
  }
]
```

Required scope: `view_teams`

Success response: `200 OK`

## Get a team suite

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/teams/{team.uuid}/suites/{suite.uuid}"
```

```json
{
  "access_level": [ "read" ],
  "created_at": "2024-01-11T04:24:21.352Z",
  "suite_id": "19f3973d-1e0b-43f1-b490-22besa5299a",
  "suite_url": "https://api.buildkite.com/v2/analytics/organizations/acme-corp/suites/suite-and-sour"
}
```

Required scope: `view_teams`

Success response: `200 OK`

## Create a team suite

Creates an association between a team and a suite.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/teams/{team.uuid}/suites/" \
  -H "Content-Type: application/json" \
  -d '{
    "suite_id": suite.uuid,
    "access_level": ["read", "edit"]
  }'
```

```json
{
  "access_level": [ "read", "edit" ],
  "created_at": "2024-01-11T04:39:18.638Z",
  "suite_id": "192k973d-1e0b-43f1-b490-22be52abd99a",
  "suite_url": "https://api.buildkite.com/v2/analytics/organizations/acme-inc/suites/suiteheart"
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>suite_id</code></th>
    <td>The UUID of the suite.</td>
  </tr>
  <tr><th><code>access_level</code></th><td>The access levels for team members to the associated suite - <code>read</code>, <code>edit</code></td></tr>
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

## Update a team suite

Updates an association between a team and a suite.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PATCH "https://api.buildkite.com/v2/organizations/{org.slug}/teams/{team.uuid}/suites/{suite.uuid}" \
  -H "Content-Type: application/json" \
  -d '{
    "access_level": ["edit", "read"]"
  }'
```

```json
{
  "access_level": [ "edit", "read" ],
  "created_at": "2024-01-11T04:56:53.516Z",
  "suite_id": "19f3973d-1e0b-43f1-b490-22be52abd99a",
  "suite_url": "https://api.buildkite.com/v2/analytics/organizations/acme-inc/suites/suiteness"
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>access_level</code></th>
    <td>The access level for the suite - <code>read</code> or <code>edit</code></td>
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

## Delete a team suite

Remove the association between a team and a suite.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/teams/{team.uuid}/suites/{suite.uuid}/"
```

Required scope: `write_teams`

Success response: `204 No Content`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Reason the team suite couldn't be deleted" }</code></td></tr>
</tbody>
</table>
