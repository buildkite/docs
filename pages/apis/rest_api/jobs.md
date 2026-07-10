# Jobs API

A job is the execution of a command step during a build. Jobs run the commands, scripts, or plugins defined in the step.

A job can be in various states during its lifecycle, such as `pending`, `scheduled`, `running`, `finished`, `failed`, `canceled`, and others. These states represent the execution state of the job as it progresses through the build system.

A running command job can also declare an expected failure before it finishes by using [promise job failure](/docs/pipelines/configure/promise-job-failure). In that case, the job state remains `running`, and the job payload includes the promised exit status and the time when the promise was recorded.

When you need to find failed jobs in a large build, query jobs directly rather than fetching a build with all nested jobs. Failed-job filtering can include terminally failed jobs and running jobs that have declared a promised failure.

## List jobs

Returns a paginated list of jobs in a build.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{build.number}/jobs"
```

```json
{
  "items": [
    {
      "id": "b63254c0-3271-4a98-8270-7cfbd6c2f14e",
      "graphql_id": "Sm9iLS0tMTQ4YWQ0MzgtM2E2My00YWIxLWIzMjItNzIxM2Y3YzJhMWFi",
      "type": "script",
      "name": ":package: Build",
      "step_key": "build",
      "step": { "id": "...", "signature": null },
      "priority": { "number": 0 },
      "agent_query_rules": [],
      "state": "passed",
      "build_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1",
      "web_url": "https://buildkite.com/my-great-org/my-pipeline/builds/1#b63254c0-3271-4a98-8270-7cfbd6c2f14e",
      "log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/log",
      "raw_log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/log.txt",
      "artifacts_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/artifacts",
      "command": "scripts/build.sh",
      "soft_failed": false,
      "exit_status": 0,
      "signal": null,
      "signal_reason": null,
      "broken_reason": null,
      "artifact_paths": null,
      "created_at": "2015-05-09T21:05:59.874Z",
      "scheduled_at": "2015-05-09T21:05:59.874Z",
      "runnable_at": "2015-05-09T21:06:00.000Z",
      "started_at": "2015-05-09T21:06:05.000Z",
      "finished_at": "2015-05-09T21:06:20.000Z",
      "expired_at": null,
      "retried": false,
      "retried_in_job_id": null,
      "retries_count": null,
      "retry_source": null,
      "retry_type": null,
      "parallel_group_index": null,
      "parallel_group_total": null,
      "matrix": null,
      "agent": null,
      "retried_by": null,
      "cluster_id": null,
      "cluster_url": null,
      "cluster_queue_id": null,
      "cluster_queue_url": null
    }
  ],
  "links": {
    "self": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs?per_page=30",
    "next": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs?after=...&per_page=30"
  }
}
```

This endpoint uses cursor-based pagination. The response body is a JSON object with an `items` array and a `links` object. Use the `next` URL from `links` to fetch the next page.

Optional [query string parameters](/docs/api#query-string-parameters):

<table>
<tbody>
  <tr>
    <th><code>state[]</code></th>
    <td>Filter by job state. Pass multiple values to OR them together (for example, <code>?state[]=passed&amp;state[]=failed</code>). Accepted values: <code>pending</code>, <code>waiting</code>, <code>waiting_failed</code>, <code>blocked</code>, <code>blocked_failed</code>, <code>unblocked</code>, <code>unblocked_failed</code>, <code>scheduled</code>, <code>assigned</code>, <code>accepted</code>, <code>running</code>, <code>passed</code>, <code>failed</code>, <code>timed_out</code>, <code>timing_out</code>, <code>canceled</code>, <code>canceling</code>, <code>skipped</code>, <code>broken</code>, <code>expired</code>, or <code>limited</code>. Note: <code>passed</code> and <code>failed</code> are API-only aliases derived from the job's exit status; the raw <code>finished</code> DB state is not accepted. When your organization has early failure declarations enabled and configured to count promised exit statuses toward a build failing, <code>state=failed</code> also matches running script jobs that have declared a hard-failing promised exit status (a non-zero promised exit status that is not covered by the step's soft-fail rules). The job's <code>state</code> field in the response still reads <code>running</code> for these jobs. Correspondingly, <code>state=running</code> excludes those same jobs, keeping the two filters mutually exclusive.</td>
  </tr>
  <tr>
    <th><code>include_retried_jobs</code></th>
    <td>Include jobs that have been retried. Default: <code>true</code>. Set to <code>false</code> to return only the most recent attempt for each step.<p class="Docs__api-param-eg"><em>Example:</em> <code>false</code></p></td>
  </tr>
  <tr>
    <th><code>per_page</code></th>
    <td>How many results to return per page.<p class="Docs__api-param-eg"><em>Default:</em> <code>30</code></p><p class="Docs__api-param-eg"><em>Maximum:</em> <code>100</code></p></td>
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
    <td>Invalid <code>state</code>, <code>per_page</code>, or cursor value</td>
  </tr>
</tbody>
</table>

## Get a job

Returns a single job.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{build.number}/jobs/{job.id}"
```

You can also use the organization-scoped route if you only have the organization slug and job UUID (without the pipeline or build):

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/jobs/{job.id}"
```

```json
{
  "id": "b63254c0-3271-4a98-8270-7cfbd6c2f14e",
  "graphql_id": "Sm9iLS0tMTQ4YWQ0MzgtM2E2My00YWIxLWIzMjItNzIxM2Y3YzJhMWFi",
  "type": "script",
  "name": ":package: Build",
  "step_key": "build",
  "step": { "id": "...", "signature": null },
  "priority": { "number": 0 },
  "agent_query_rules": [],
  "state": "passed",
  "build_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1",
  "web_url": "https://buildkite.com/my-great-org/my-pipeline/builds/1#b63254c0-3271-4a98-8270-7cfbd6c2f14e",
  "log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/log",
  "raw_log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/log.txt",
  "artifacts_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/artifacts",
  "command": "scripts/build.sh",
  "soft_failed": false,
  "exit_status": 0,
  "signal": null,
  "signal_reason": null,
  "broken_reason": null,
  "artifact_paths": null,
  "created_at": "2015-05-09T21:05:59.874Z",
  "scheduled_at": "2015-05-09T21:05:59.874Z",
  "runnable_at": "2015-05-09T21:06:00.000Z",
  "started_at": "2015-05-09T21:06:05.000Z",
  "finished_at": "2015-05-09T21:06:20.000Z",
  "expired_at": null,
  "retried": false,
  "retried_in_job_id": null,
  "retries_count": null,
  "retry_source": null,
  "retry_type": null,
  "parallel_group_index": null,
  "parallel_group_total": null,
  "matrix": null,
  "agent": null,
  "retried_by": null,
  "cluster_id": null,
  "cluster_url": null,
  "cluster_queue_id": null,
  "cluster_queue_url": null
}
```

Required scope: `read_builds`

Success response: `200 OK`

Error responses:

<table>
<tbody>
  <tr>
    <th><code>404 Not Found</code></th>
    <td><code>{ "message": "No job found" }</code></td>
  </tr>
</tbody>
</table>

## Retry a job

Retries a `failed` OR `timed_out` OR a job whose step has the [manual retry after passing attribute set to true](/docs/pipelines/configure/retry#retry-attributes-manual-retry-attributes) (that is, `permit_on_passed: true`). You can only retry each `job.id` once. To retry a "second time" use the new `job.id` returned in the first retry query.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/jobs/{job.id}/retry"
```

You can also use the build-scoped route if you have the pipeline slug and build number:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{build.number}/jobs/{job.id}/retry"
```

```json
    {
      "id": "b63254c0-3271-4a98-8270-7cfbd6c2f14e",
      "graphql_id": "Sm9iLS0tMTQ4YWQ0MzgtM2E2My00YWIxLWIzMjItNzIxM2Y3YzJhMWFi",
      "type": "script",
      "name": ":package:",
      "step_key": "package",
      "agent_query_rules": ["*"],
      "state": "scheduled",
      "build_url": "https://buildkite.com/my-great-org/my-pipeline/builds/1",
      "web_url": "https://buildkite.com/my-great-org/my-pipeline/builds/1#b63254c0-3271-4a98-8270-7cfbd6c2f14e",
      "log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/log",
      "raw_log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/log.txt",
      "artifacts_url": "",
      "command": "scripts/build.sh",
      "soft_failed": false,
      "exit_status": 0,
      "artifact_paths": "",
      "agent": null,
      "created_at": "2015-05-09T21:05:59.874Z",
      "scheduled_at": "2015-05-09T21:05:59.874Z",
      "runnable_at": null,
      "started_at": null,
      "finished_at": null,
      "retried": false,
      "retried_in_job_id": null,
      "retries_count": 1,
      "retry_type": null,
      "parallel_group_index": null,
      "parallel_group_total": null,
      "priority": { "number": 0 }
    }
```

Required scope: `write_builds`

Success response: `200 OK`

Error responses:

<table>
<tbody>
  <tr>
    <th><code>400 Bad Request</code></th>
    <td><code>{ "message": "Only failed, timed out or canceled jobs can be retried" }</code></td>
  </tr>
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td><code>{ "message": "Jobs from canceled builds cannot be retried" }</code></td>
  </tr>
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td><code>{ "message": "This job can't be retried because this build was triggered by a synchronous trigger step in a canceled build" }</code></td>
  </tr>
</tbody>
</table>

## Reprioritize a job

Reprioritizes a job by changing its [priority value](/docs/pipelines/configure/workflows/job-priority). This affects the order in which jobs are picked up by agents.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/jobs/{job.id}/reprioritize" \
  -H "Content-Type: application/json" \
  -d '{"priority": 5}'
```

You can also use the build-scoped route if you have the pipeline slug and build number:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{build.number}/jobs/{job.id}/reprioritize" \
  -H "Content-Type: application/json" \
  -d '{"priority": 5}'
```

```json
    {
      "id": "b63254c0-3271-4a98-8270-7cfbd6c2f14e",
      "graphql_id": "Sm9iLS0tMTQ4YWQ0MzgtM2E2My00YWIxLWIzMjItNzIxM2Y3YzJhMWFi",
      "type": "script",
      "name": ":package:",
      "step_key": "package",
      "agent_query_rules": ["*"],
      "state": "scheduled",
      "build_url": "https://buildkite.com/my-great-org/my-pipeline/builds/1",
      "web_url": "https://buildkite.com/my-great-org/my-pipeline/builds/1#b63254c0-3271-4a98-8270-7cfbd6c2f14e",
      "log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/log",
      "raw_log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/log.txt",
      "artifacts_url": "",
      "command": "scripts/build.sh",
      "soft_failed": false,
      "exit_status": 0,
      "artifact_paths": "",
      "agent": null,
      "created_at": "2015-05-09T21:05:59.874Z",
      "scheduled_at": "2015-05-09T21:05:59.874Z",
      "runnable_at": null,
      "started_at": null,
      "finished_at": null,
      "retried": false,
      "retried_in_job_id": null,
      "retries_count": 0,
      "retry_type": null,
      "parallel_group_index": null,
      "parallel_group_total": null,
      "priority": { "number": 5 }
    }
```

Required [request body properties](/docs/api#request-body-properties):

<table>
<tbody>
  <tr>
    <th><code>priority</code></th>
    <td>An integer value representing the job's priority. Higher values indicate higher priority.<br><em>Example: 5</em></td>
  </tr>
</tbody>
</table>

Required scope: `write_builds`

Success response: `200 OK`

Error responses:

<table>
<tbody>
  <tr>
    <th><code>400 Bad Request</code></th>
    <td><code>{ "message": "Priority must be an integer" }</code></td>
  </tr>
</tbody>
</table>

## Unblock a job

Unblocks a build's "Block pipeline" job. The job's `unblockable` property indicates whether it is able to be unblocked, and the `unblock_url` property points to this endpoint.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/jobs/{job.id}/unblock" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "name": "Liam Neeson",
      "email": "liam@evilbatmanvillans.com"
    }
  }'
```

You can also use the build-scoped route if you have the pipeline slug and build number:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{build.number}/jobs/{job.id}/unblock" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "name": "Liam Neeson",
      "email": "liam@evilbatmanvillans.com"
    }
  }'
```

```json
{
  "id": "ded35de2-7de0-4da8-8daa-b4ce0b7f1064",
  "graphql_id": "Sm9iLS0tZGM5YTg5MmQtM2I5Ny00MzgyLWEzYzItNWJhZmU5M2RlZWI1",
  "type": "manual",
  "label": "Deploy",
  "state": "unblocked",
  "web_url": null,
  "unblocked_by": {
    "id": "cfbb422f-2e4a-41b5-86f0-59e813b3d6e2",
    "graphql_id": "VXNlci0tLTBmYTQzYjY2LWI5N2YtNDc0Yi04Y2YxLWIxMzQ5NWIxYjRjMQ==",
    "name": "Liam Neeson",
    "email": "liam@evilbatmanvillans.com",
    "avatar_url": "https://www.gravatar.com/avatar/e14f55d3f939977cecbf51b64ff6f861",
    "created_at": "2015-05-09T21:05:59.874Z"
  },
  "unblocked_at": "2015-05-09T21:06:10.264Z",
  "unblockable": false,
  "unblock_url": "https://buildkite.com/my-great-org/my-pipeline/builds/1#ded35de2-7de0-4da8-8daa-b4ce0b7f1064"
}
```

Optional [request body properties](/docs/api#request-body-properties):

<table>
<tbody>
  <tr>
    <th><code>unblocker</code></th>
    <td>The user id of the person activating the job.<br><em>Default value: the user making the API request</em>.</td>
  </tr>
  <tr>
    <th><code>fields</code></th>
    <td>The values for the <a href="/docs/pipelines/configure/step-types/block-step#block-step-attributes">block step's fields</a>.<br>
    <p class="Docs__api-param-eg"><em>Example:</em> <code>{"release-name": "Flying Dolpin"}</code></p></td>
  </tr>
</tbody>
</table>

Required scope: `write_builds`

Success response: `200 OK`

Error responses:

<table>
<tbody>
  <tr>
    <th><code>400 Bad Request</code></th>
    <td><code>{ "message": "This job type cannot be unblocked" }</code></td>
  </tr>
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td><code>{ "message": "Unblocker is not a valid user id for this organization"}</code></td>
  </tr>
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td><code>{ "message": "Jobs from canceled builds cannot be unblocked" }</code></td>
  </tr>
</tbody>
</table>

## Get a job's log output

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/jobs/{job.id}/log"
```

You can also use the build-scoped route if you have the pipeline slug and build number:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{build.number}/jobs/{job.id}/log"
```

```json
{
  "url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/log",
  "content": "This is the job's log output",
  "size": 28,
  "header_times": [1563337899810051000,1563337899811015000,1563337905336878000,1563337906589603000,156333791038291900]
}
```

Required scope: `read_build_logs`

Success response: `200 OK`

Alternative formats (using `Accept` header or file extension):

<table>
<tbody>
  <tr>
    <th><code>text/plain</code></th>
    <th><code>.txt</code></th>
    <td>The job's raw log content</td>
  </tr>
  <tr>
    <th><code>text/html</code></th>
    <th><code>.html</code></th>
    <td>The job's log content as rendered by <a href="http://buildkite.github.io/terminal-to-html/">Terminal</a></td>
  </tr>
</tbody>
</table>

### Get log size without downloading

Use `HEAD` instead of `GET` to retrieve the byte size of a job log without downloading its content. This is useful for monitoring log growth or checking whether new output is available.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -I "https://api.buildkite.com/v2/organizations/{org.slug}/jobs/{job.id}/log"
```

You can also use the build-scoped route:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -I "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{build.number}/jobs/{job.id}/log"
```

A successful response has no body and includes:

- `Content-Length`: the total size of the raw stored log bytes
- `Accept-Ranges: bytes`: indicates that suffix byte range requests are supported

Required scope: `read_build_logs`

Success response: `200 OK`

### Get a log tail using a range request

To retrieve only the last _N_ bytes of a job log, send a `GET` request with `Accept: text/plain` and a `Range: bytes=-N` header. This avoids downloading the entire log when you only need the most recent output.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -H "Accept: text/plain" \
  -H "Range: bytes=-100" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/jobs/{job.id}/log"
```

Range requests are only supported with `Accept: text/plain`. Only suffix ranges (`bytes=-N`) are supported. Explicit start-end ranges and multipart ranges are not supported. The response body contains the raw stored bytes without UTF-8 normalization, so `Content-Length` reflects the exact number of bytes returned.

A successful partial response includes:

- `Accept-Ranges: bytes`
- `Content-Range`: the byte range returned and total log size (for example, `bytes 900-999/1000`)
- `Content-Length`: the number of bytes in the response body

Required scope: `read_build_logs`

Success response: `206 Partial Content`

Error responses:

<table>
<tbody>
  <tr>
    <th><code>400 Bad Request</code></th>
    <td>Range request sent without <code>Accept: text/plain</code>, or an unsupported range form such as an explicit start-end range (<code>bytes=500-1000</code>), a multipart range, or a zero-byte suffix (<code>bytes=-0</code>)</td>
  </tr>
  <tr>
    <th><code>416 Range Not Satisfiable</code></th>
    <td>The suffix range cannot be satisfied because the job log is empty</td>
  </tr>
</tbody>
</table>

## Delete a job's log output

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/jobs/{job.id}/log"
```

You can also use the build-scoped route if you have the pipeline slug and build number:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{build.number}/jobs/{job.id}/log"
```

Required scope: `write_build_logs`

Success response: `204 No Content`

## Get a job's environment variables

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/jobs/{job.id}/env"
```

You can also use the build-scoped route if you have the pipeline slug and build number:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{build.number}/jobs/{job.id}/env"
```

```json
{
  "env": {
    "CI": "true",
    "BUILDKITE": "true",
    "BUILDKITE_TAG": "",
    "BUILDKITE_REPO": "git@github.com:my-great-org/my-repo.git",
    "BUILDKITE_BRANCH": "main",
    "BUILDKITE_COMMIT": "a65572555600c07c7ee79a2bd909220e1ca5485b",
    "BUILDKITE_JOB_ID": "bde076a8-bc2c-4fda-9652-10220a56d638",
    "BUILDKITE_COMMAND": "buildkite-agent pipeline upload",
    "BUILDKITE_MESSAGE": "\:llama\:",
    "BUILDKITE_BUILD_ID": "c4e312cb-e734-4f0a-a5bd-1cac2535c57e",
    "BUILDKITE_BUILD_URL": "https://buildkite.com/my-great-org/my-pipeline/builds/15",
    "BUILDKITE_AGENT_NAME": "ci-1",
    "BUILDKITE_COMMAND": "buildkite-agent pipeline upload",
    "BUILDKITE_BUILD_NUMBER": "15",
    "BUILDKITE_ORGANIZATION_SLUG": "my-great-org",
    "BUILDKITE_PIPELINE_SLUG": "my-pipeline",
    "BUILDKITE_PULL_REQUEST": "false",
    "BUILDKITE_BUILD_CREATOR": "Keith Pitt",
    "BUILDKITE_REPO_SSH_HOST": "github.com",
    "BUILDKITE_ARTIFACT_PATHS": "",
    "BUILDKITE_PIPELINE_PROVIDER": "github",
    "BUILDKITE_BUILD_CREATOR_EMAIL": "keith@buildkite.com",
    "BUILDKITE_AGENT_META_DATA_LOCAL": "true"
  }
}
```

Required scope: `read_job_env`

Success response: `200 OK`

Alternative formats (using `Accept` header or file extension):

<!-- vale off -->
<table>
<tbody>
  <tr>
    <th><code>text/plain</code></th>
    <th><code>.txt</code></th>
    <td>The job's environment in a <code>KEY=VALUE</code> format suitable for parsing by tools such as <a href="https://github.com/bkeepers/dotenv">dotenv</a></td>
  </tr>
</tbody>
</table>
<!-- vale on -->
