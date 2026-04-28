# Pipeline schedules API

The pipeline schedules API endpoint allows you to manage [scheduled builds](/docs/pipelines/configure/workflows/scheduled-builds) for a pipeline. Pipeline schedules automatically create builds at specified intervals, such as nightly builds or hourly integration tests.

## Pipeline schedule data model

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>id</code></th>
    <td>UUID of the pipeline schedule</td>
  </tr>
  <tr>
    <th><code>graphql_id</code></th>
    <td><a href="/docs/apis/graphql-api#graphql-ids">GraphQL ID</a> of the pipeline schedule</td>
  </tr>
  <tr>
    <th><code>url</code></th>
    <td>Canonical API URL of the pipeline schedule</td>
  </tr>
  <tr>
    <th><code>label</code></th>
    <td>Label describing the pipeline schedule</td>
  </tr>
  <tr>
    <th><code>cronline</code></th>
    <td>The interval used to trigger builds. Either a <a href="/docs/pipelines/configure/workflows/scheduled-builds#schedule-intervals">predefined interval</a> (such as <code>@hourly</code> or <code>@daily</code>) or a <a href="/docs/pipelines/configure/workflows/scheduled-builds#crontab-time-syntax">crontab time syntax</a> string.</td>
  </tr>
  <tr>
    <th><code>message</code></th>
    <td>Message used for the builds created by the pipeline schedule</td>
  </tr>
  <tr>
    <th><code>commit</code></th>
    <td>Commit used for the builds created by the pipeline schedule. Defaults to <code>HEAD</code>.</td>
  </tr>
  <tr>
    <th><code>branch</code></th>
    <td>Branch used for the builds created by the pipeline schedule. Defaults to the pipeline's default branch.</td>
  </tr>
  <tr>
    <th><code>env</code></th>
    <td>JSON object of environment variables to set on the builds created by the pipeline schedule</td>
  </tr>
  <tr>
    <th><code>enabled</code></th>
    <td>Whether the pipeline schedule is enabled</td>
  </tr>
  <tr>
    <th><code>next_build_at</code></th>
    <td>When the next build will be created</td>
  </tr>
  <tr>
    <th><code>failed_message</code></th>
    <td>Failure message from the most recent failed attempt to create a build, or <code>null</code> if the most recent attempt succeeded</td>
  </tr>
  <tr>
    <th><code>failed_at</code></th>
    <td>When the most recent failed attempt to create a build occurred, or <code>null</code> if the most recent attempt succeeded</td>
  </tr>
  <tr>
    <th><code>created_at</code></th>
    <td>When the pipeline schedule was created</td>
  </tr>
  <tr>
    <th><code>created_by</code></th>
    <td><a href="/docs/apis/rest-api/user">User</a> who created the pipeline schedule</td>
  </tr>
  <tr>
    <th><code>pipeline</code></th>
    <td>Reference to the parent pipeline, including its <code>id</code>, <code>slug</code>, and API <code>url</code></td>
  </tr>
</tbody>
</table>

## List pipeline schedules

Returns a [paginated list](<%= paginated_resource_docs_url %>) of a pipeline's schedules, ordered by most recently created first.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/schedules"
```

```json
[
  {
    "id": "b3a1e9f2-7c4d-4f1a-9e6c-2d8a5f7b1c3d",
    "graphql_id": "UGlwZWxpbmVTY2hlZHVsZS0tLWIzYTFlOWYyLTdjNGQtNGYxYS05ZTZjLTJkOGE1ZjdiMWMzZA==",
    "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/schedules/b3a1e9f2-7c4d-4f1a-9e6c-2d8a5f7b1c3d",
    "label": "Nightly build",
    "cronline": "@daily",
    "message": "Nightly scheduled build",
    "commit": "HEAD",
    "branch": "main",
    "env": {
      "DEPLOY_ENV": "staging"
    },
    "enabled": true,
    "next_build_at": "2024-01-02T00:00:00.000Z",
    "failed_message": null,
    "failed_at": null,
    "created_at": "2024-01-01T12:00:00.000Z",
    "created_by": {
      "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
      "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
      "name": "Sam Kim",
      "email": "sam@example.com",
      "avatar_url": "https://www.gravatar.com/avatar/example",
      "created_at": "2013-05-03T04:17:55.867Z"
    },
    "pipeline": {
      "id": "9d1d1e9c-5e8f-4f9a-9b0c-1a2b3c4d5e6f",
      "slug": "my-pipeline",
      "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline"
    }
  }
]
```

Required scope: `read_pipelines`

Success response: `200 OK`

## Get a pipeline schedule

Returns the details for a single pipeline schedule.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/schedules/{id}"
```

```json
{
  "id": "b3a1e9f2-7c4d-4f1a-9e6c-2d8a5f7b1c3d",
  "graphql_id": "UGlwZWxpbmVTY2hlZHVsZS0tLWIzYTFlOWYyLTdjNGQtNGYxYS05ZTZjLTJkOGE1ZjdiMWMzZA==",
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/schedules/b3a1e9f2-7c4d-4f1a-9e6c-2d8a5f7b1c3d",
  "label": "Nightly build",
  "cronline": "@daily",
  "message": "Nightly scheduled build",
  "commit": "HEAD",
  "branch": "main",
  "env": {
    "DEPLOY_ENV": "staging"
  },
  "enabled": true,
  "next_build_at": "2024-01-02T00:00:00.000Z",
  "failed_message": null,
  "failed_at": null,
  "created_at": "2024-01-01T12:00:00.000Z",
  "created_by": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2013-05-03T04:17:55.867Z"
  },
  "pipeline": {
    "id": "9d1d1e9c-5e8f-4f9a-9b0c-1a2b3c4d5e6f",
    "slug": "my-pipeline",
    "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline"
  }
}
```

Required scope: `read_pipelines`

Success response: `200 OK`

## Create a pipeline schedule

Creates a new pipeline schedule.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/schedules" \
  -H "Content-Type: application/json" \
  -d '{
    "label": "Nightly build",
    "cronline": "@daily",
    "message": "Nightly scheduled build",
    "commit": "HEAD",
    "branch": "main",
    "env": {
      "DEPLOY_ENV": "staging"
    },
    "enabled": true
  }'
```

```json
{
  "id": "b3a1e9f2-7c4d-4f1a-9e6c-2d8a5f7b1c3d",
  "graphql_id": "UGlwZWxpbmVTY2hlZHVsZS0tLWIzYTFlOWYyLTdjNGQtNGYxYS05ZTZjLTJkOGE1ZjdiMWMzZA==",
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/schedules/b3a1e9f2-7c4d-4f1a-9e6c-2d8a5f7b1c3d",
  "label": "Nightly build",
  "cronline": "@daily",
  "message": "Nightly scheduled build",
  "commit": "HEAD",
  "branch": "main",
  "env": {
    "DEPLOY_ENV": "staging"
  },
  "enabled": true,
  "next_build_at": "2024-01-02T00:00:00.000Z",
  "failed_message": null,
  "failed_at": null,
  "created_at": "2024-01-01T12:00:00.000Z",
  "created_by": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2013-05-03T04:17:55.867Z"
  },
  "pipeline": {
    "id": "9d1d1e9c-5e8f-4f9a-9b0c-1a2b3c4d5e6f",
    "slug": "my-pipeline",
    "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline"
  }
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>cronline</code></th>
    <td>The interval used to trigger builds. Either a <a href="/docs/pipelines/configure/workflows/scheduled-builds#schedule-intervals">predefined interval</a> or a <a href="/docs/pipelines/configure/workflows/scheduled-builds#crontab-time-syntax">crontab time syntax</a> string.<br><em>Example:</em> <code>"@daily"</code></td>
  </tr>
</tbody>
</table>

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>label</code></th>
    <td>Label describing the pipeline schedule.<br><em>Example:</em> <code>"Nightly build"</code></td>
  </tr>
  <tr>
    <th><code>message</code></th>
    <td>Message used for the builds created by the pipeline schedule.<br><em>Example:</em> <code>"Nightly scheduled build"</code></td>
  </tr>
  <tr>
    <th><code>commit</code></th>
    <td>Commit used for the builds created by the pipeline schedule.<br><em>Default:</em> <code>"HEAD"</code></td>
  </tr>
  <tr>
    <th><code>branch</code></th>
    <td>Branch used for the builds created by the pipeline schedule.<br><em>Default:</em> the pipeline's default branch</td>
  </tr>
  <tr>
    <th><code>env</code></th>
    <td>JSON object of environment variables to set on the builds created by the pipeline schedule.<br><em>Example:</em> <code>{ "DEPLOY_ENV": "staging" }</code></td>
  </tr>
  <tr>
    <th><code>enabled</code></th>
    <td>Whether the pipeline schedule is enabled.<br><em>Default:</em> <code>true</code></td>
  </tr>
</tbody>
</table>

Required scope: `write_pipelines`

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

## Update a pipeline schedule

Updates a pipeline schedule.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/schedules/{id}" \
  -H "Content-Type: application/json" \
  -d '{
    "cronline": "@hourly",
    "enabled": false
  }'
```

```json
{
  "id": "b3a1e9f2-7c4d-4f1a-9e6c-2d8a5f7b1c3d",
  "graphql_id": "UGlwZWxpbmVTY2hlZHVsZS0tLWIzYTFlOWYyLTdjNGQtNGYxYS05ZTZjLTJkOGE1ZjdiMWMzZA==",
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/schedules/b3a1e9f2-7c4d-4f1a-9e6c-2d8a5f7b1c3d",
  "label": "Nightly build",
  "cronline": "@hourly",
  "message": "Nightly scheduled build",
  "commit": "HEAD",
  "branch": "main",
  "env": {
    "DEPLOY_ENV": "staging"
  },
  "enabled": false,
  "next_build_at": null,
  "failed_message": null,
  "failed_at": null,
  "created_at": "2024-01-01T12:00:00.000Z",
  "created_by": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2013-05-03T04:17:55.867Z"
  },
  "pipeline": {
    "id": "9d1d1e9c-5e8f-4f9a-9b0c-1a2b3c4d5e6f",
    "slug": "my-pipeline",
    "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline"
  }
}
```

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>label</code></th>
    <td>Label describing the pipeline schedule.<br><em>Example:</em> <code>"Nightly build"</code></td>
  </tr>
  <tr>
    <th><code>cronline</code></th>
    <td>The interval used to trigger builds.<br><em>Example:</em> <code>"@hourly"</code></td>
  </tr>
  <tr>
    <th><code>message</code></th>
    <td>Message used for the builds created by the pipeline schedule.<br><em>Example:</em> <code>"Nightly scheduled build"</code></td>
  </tr>
  <tr>
    <th><code>commit</code></th>
    <td>Commit used for the builds created by the pipeline schedule.<br><em>Example:</em> <code>"HEAD"</code></td>
  </tr>
  <tr>
    <th><code>branch</code></th>
    <td>Branch used for the builds created by the pipeline schedule.<br><em>Example:</em> <code>"main"</code></td>
  </tr>
  <tr>
    <th><code>env</code></th>
    <td>JSON object of environment variables to set on the builds created by the pipeline schedule.<br><em>Example:</em> <code>{ "DEPLOY_ENV": "staging" }</code></td>
  </tr>
  <tr>
    <th><code>enabled</code></th>
    <td>Whether the pipeline schedule is enabled. Re-enabling a previously failed schedule clears its <code>failed_message</code> and <code>failed_at</code> values.<br><em>Example:</em> <code>true</code></td>
  </tr>
</tbody>
</table>

Required scope: `write_pipelines`

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

## Delete a pipeline schedule

Deletes a pipeline schedule.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/schedules/{id}"
```

Required scope: `write_pipelines`

Success response: `204 No Content`
