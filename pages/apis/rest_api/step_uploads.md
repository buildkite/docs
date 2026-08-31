# Step uploads API

A step upload is a pipeline configuration uploaded by [`buildkite-agent pipeline upload`](/docs/agent/cli/reference/pipeline) while a build is running, as part of a [dynamic pipeline](/docs/pipelines/configure/dynamic-pipelines). This API provides read-only access to a build's step uploads, including the definition that was uploaded.

Step uploads are only available for builds within their maximum lifetime (up to 30 days after creation). Requesting step uploads for an older build returns a `410 Gone` response.

## Step upload data model

<table>
<tbody>
  <tr>
    <th><code>uuid</code></th>
    <td>UUID of the step upload</td>
  </tr>
  <tr>
    <th><code>state</code></th>
    <td>State of the step upload. One of <code>pending</code>, <code>processing</code>, <code>applied</code>, <code>rejected</code>, or <code>failed</code></td>
  </tr>
  <tr>
    <th><code>source</code></th>
    <td>Source of the step upload. Currently always <code>job</code></td>
  </tr>
  <tr>
    <th><code>source_job_id</code></th>
    <td>ID of the job that performed the upload</td>
  </tr>
  <tr>
    <th><code>replace_existing_steps</code></th>
    <td>Whether the upload replaced the rest of the pipeline's steps instead of appending to them. Corresponds to the <a href="/docs/agent/cli/reference/pipeline#replace"><code>--replace</code></a> flag</td>
  </tr>
  <tr>
    <th><code>created_jobs_count</code></th>
    <td>Number of jobs created from this upload. <code>null</code> while the upload hasn't been applied yet, as distinct from <code>0</code> for an applied upload that created no jobs</td>
  </tr>
  <tr>
    <th><code>rejection_type</code></th>
    <td>Type of rejection for a <code>rejected</code> upload, otherwise <code>null</code></td>
  </tr>
  <tr>
    <th><code>message</code></th>
    <td>Human-readable message describing the outcome of <code>rejected</code> and <code>failed</code> uploads, otherwise <code>null</code>. The message never includes the uploaded configuration or internal failure details</td>
  </tr>
  <tr>
    <th><code>url</code></th>
    <td>Canonical API URL of the step upload</td>
  </tr>
  <tr>
    <th><code>created_at</code></th>
    <td>When the step upload was received</td>
  </tr>
  <tr>
    <th><code>processed_at</code></th>
    <td>When the step upload finished processing, or <code>null</code> if it hasn't finished yet</td>
  </tr>
</tbody>
</table>

## List a build's step uploads

Returns a paginated list of step uploads for a build, newest first. The uploaded definitions aren't included. Use [Get a step upload](#get-a-step-upload) to fetch the definition for a specific upload.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{build.number}/step-uploads"
```

<%= render_markdown partial: 'apis/rest_api/build_number_vs_build_id_with_link' %>

```json
{
  "items": [
    {
      "uuid": "0198f2f4-1c33-4e0a-9d5e-3a4a5b6c7d8e",
      "graphql_id": "QnVpbGRTdGVwVXBsb2FkLS0tMDE5OGYyZjQtMWMzMy00ZTBhLTlkNWUtM2E0YTViNmM3ZDhl",
      "state": "applied",
      "source": "job",
      "source_job_id": "0198f2f3-64a2-4a8e-8b78-0d9157a0e35f",
      "replace_existing_steps": false,
      "created_jobs_count": 1,
      "rejection_type": null,
      "message": null,
      "url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/42/step-uploads/0198f2f4-1c33-4e0a-9d5e-3a4a5b6c7d8e",
      "created_at": "2026-08-11T10:15:32.000Z",
      "processed_at": "2026-08-11T10:15:33.000Z"
    }
  ],
  "links": {
    "self": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/42/step-uploads?per_page=30",
    "next": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/42/step-uploads?after=...&per_page=30"
  }
}
```

This endpoint uses cursor-based pagination. The response body is a JSON object with an `items` array and a `links` object. Use the `next` URL from `links` to fetch the next page, following it verbatim rather than constructing your own cursor values.

Optional [query string parameters](/docs/api#query-string-parameters):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>filter[source_job_id]</code></th>
    <td>Returns only step uploads made by the given job.
      <p class="Docs__api-param-eg"><em>Example:</em> <code>filter[source_job_id]=0198f2f3-64a2-4a8e-8b78-0d9157a0e35f</code></p></td>
  </tr>
  <tr>
    <th><code>per_page</code></th>
    <td>How many results to return per page.
      <p class="Docs__api-param-eg"><em>Default:</em> <code>30</code></p></td>
  </tr>
  <tr>
    <th><code>after</code></th>
    <td>Return results after this cursor value. Mutually exclusive with <code>before</code>.</td>
  </tr>
  <tr>
    <th><code>before</code></th>
    <td>Return results before this cursor value. Mutually exclusive with <code>after</code>.</td>
  </tr>
</tbody>
</table>

Required scope: `read_builds`

Success response: `200 OK`

Error responses:

<table>
<tbody>
  <tr>
    <th><code>400 Bad Request</code></th>
    <td>Invalid <code>per_page</code> or cursor value, or both <code>after</code> and <code>before</code> supplied</td>
  </tr>
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td>Unsupported filter key, or an invalid <code>filter[source_job_id]</code> value</td>
  </tr>
  <tr>
    <th><code>410 Gone</code></th>
    <td>The build is outside its maximum lifetime</td>
  </tr>
</tbody>
</table>

## Get a step upload

Returns a single step upload, including its uploaded definition rendered as YAML.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{build.number}/step-uploads/{uuid}"
```

<%= render_markdown partial: 'apis/rest_api/build_number_vs_build_id_with_link' %>

```json
{
  "uuid": "0198f2f4-1c33-4e0a-9d5e-3a4a5b6c7d8e",
  "graphql_id": "QnVpbGRTdGVwVXBsb2FkLS0tMDE5OGYyZjQtMWMzMy00ZTBhLTlkNWUtM2E0YTViNmM3ZDhl",
  "state": "applied",
  "source": "job",
  "source_job_id": "0198f2f3-64a2-4a8e-8b78-0d9157a0e35f",
  "replace_existing_steps": false,
  "created_jobs_count": 1,
  "rejection_type": null,
  "message": null,
  "url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/42/step-uploads/0198f2f4-1c33-4e0a-9d5e-3a4a5b6c7d8e",
  "created_at": "2026-08-11T10:15:32.000Z",
  "processed_at": "2026-08-11T10:15:33.000Z",
  "definition_bytes": 61,
  "definition_yaml": "---\nsteps:\n- command: echo hello\n  key: dynamic-step\n",
  "definition_yaml_omitted": false
}
```

The uploaded document isn't retained as raw text, so `definition_yaml` is re-rendered from the stored definition and may not preserve the original file's formatting, comments, or anchors.

Definitions larger than 2 MB when serialized aren't rendered. For these, `definition_yaml` is `null` and `definition_yaml_omitted` is `true`, while `definition_bytes` still reports the definition's serialized size.

Required scope: `read_builds`

Success response: `200 OK`

Error responses:

<table>
<tbody>
  <tr>
    <th><code>404 Not Found</code></th>
    <td>No step upload matches the given UUID for this build</td>
  </tr>
  <tr>
    <th><code>410 Gone</code></th>
    <td>The build is outside its maximum lifetime</td>
  </tr>
</tbody>
</table>
