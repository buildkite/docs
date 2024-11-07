# Team pipelines API

The team pipelines API endpoint allows users to review, create, update, and delete pipelines associated with a team in your organization.

## Team pipeline data model

<table class="responsive-table">
<tbody>
  <tr><th><code>pipeline_id</code></th><td>UUID of the pipeline</td></tr>
  <tr><th><code>access_level</code></th><td>The access levels that users have to the associated pipeline - <code>read_only</code>, <code>build_and_read</code>, <code>manage_build_and_read</code></td></tr>
  <tr><th><code>pipeline_url</code></th><td>URL of the pipeline</td></tr>
  <tr><th><code>created_at</code></th><td>When the team and pipeline association was created</td></tr>
</tbody>
</table>

## List team pipelines

Returns a [paginated list](<%= paginated_resource_docs_url %>) of a team's associated pipelines.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/teams/{team.uuid}/pipelines"
```

```json
[
  {
    "access_level": "manage_build_and_read",
    "created_at": "2023-12-12T21:57:40.306Z",
    "pipeline_id": "018c5ad7-28f1-45d4-867e-b59fa04511b2",
    "pipeline_url": "http://api.buildkite.com/v2/organizations/acme-inc/pipelines/test-pipeline"
  },
]
```

Required scope: `view_teams`

Success response: `200 OK`

## Get a team pipeline

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/teams/{team.uuid}/pipelines/{pipeline.uuid}"
```

```json
{
  "access_level": "read_only",
  "created_at": "2023-12-12T21:57:40.306Z",
  "pipeline_id": "018c5ad7-28f1-45d4-867e-b59fa04511b2",
  "pipeline_url": "http://api.buildkite.com/v2/organizations/acme-inc/pipelines/test-pipeline"
}
```

Required scope: `view_teams`

Success response: `200 OK`

## Create a team pipeline

Creates an association between a team and a pipeline.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/teams/{team.uuid}/pipelines/" \
  -H "Content-Type: application/json" \
  -d '{
    "pipeline_id": "pipeline.uuid",
    "access_level": "read_only"
  }'
```

```json
{
  "access_level": "read",
  "created_at": "2023-12-12T21:57:40.306Z",
  "pipeline_id": "018c5ad7-28f1-45d4-867e-b59fa04511b2",
  "pipeline_url": "http://api.buildkite.com/v2/organizations/acme-inc/pipelines/test-pipeline"
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>pipeline_id</code></th>
    <td>The UUID of the pipeline.</td>
  </tr>
  <tr>
    <th><code>access_level</code></th>
    <td>The access level for the pipeline - <code>read_only</code>, <code>build_and_read</code> or <code>manage_build_and_read</code>.</td>
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

## Update a team pipeline

Updates an association between a team and a pipeline.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PATCH "https://api.buildkite.com/v2/organizations/{org.slug}/teams/{team.uuid}/pipelines/{pipeline.uuid}" \
  -H "Content-Type: application/json" \
  -d '{
    "access_level": "read_only"
  }'
```

```json
{
  "access_level": "read_only",
  "created_at": "2023-12-12T21:57:40.306Z",
  "pipeline_id": "018c5ad7-28f1-45d4-867e-b59fa04511b2",
  "pipeline_url": "http://api.buildkite.com/v2/organizations/acme-inc/pipelines/test-pipeline"
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>access_level</code></th>
    <td>The access level for the pipeline - <code>read_only</code>, <code>build_and_read</code> or <code>manage_build_and_read</code>.</td>
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

## Delete a team pipeline

Remove the association between a team and a pipeline.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/teams/{team.uuid}/pipelines/{pipeline.uuid}"
```

Required scope: `write_teams`

Success response: `204 No Content`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Reason the team pipeline couldn't be deleted" }</code></td></tr>
</tbody>
</table>
