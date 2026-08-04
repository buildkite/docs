# Job webhook events


## Events

<table>
  <thead>
    <tr><th>Event</th><th>Description</th></tr>
  </thead>
  <tbody>
    <tr>
      <th><code>job.scheduled</code></th>
      <td>A command step job is in a scheduled state and is waiting to run on an agent</td>
    </tr>
    <tr>
      <th><code>job.started</code></th>
      <td>A command step job has started running on an agent</td>
    </tr>
    <tr>
      <th><code>job.finished</code></th>
      <td>A job has finished</td>
    </tr>
    <tr>
      <th><code>job.activated</code></th>
      <td>A block step job has been unblocked using the web or API</td>
    </tr>
    <tr>
      <th><code>job.promised_exit_status</code></th>
      <td>A running job has declared an anticipated exit status before it has finished</td>
    </tr>
  </tbody>
</table>

## Request body data

<table>
  <thead>
    <tr><th>Property</th><th>Type</th><th>Description</th></tr>
  </thead>
  <tbody>
    <tr>
      <td><code>job</code></td>
      <td><a href="/docs/apis/rest-api/jobs">Job</a></td>
      <td>The job this notification relates to</td>
    </tr>
    <tr>
      <td><code>build</code></td>
      <td><a href="/docs/apis/rest-api/builds">Build</a></td>
      <td>The build this notification relates to</td>
    </tr>
    <tr>
      <td><code>pipeline</code></td>
      <td><a href="/docs/apis/rest-api/pipelines">Pipeline</a></td>
      <td>The pipeline this notification relates to</td>
    </tr>
    <tr>
      <td><code>sender</code></td>
      <td>String</td>
      <td>The user who created the webhook</td>
    </tr>
  </tbody>
</table>

Example request body:

```json
{
  "event": "job.started",
  "job": {
    "...": "..."
  },
  "build": {
    "...": "..."
  },
  "pipeline": {
    "...": "..."
  },
  "sender": {
    "id": "8a7693f8-dbae-4783-9137-84090fce9045",
    "name": "Some Person"
  }
}
```

## Trigger job events

When a trigger step in the parent pipeline finishes, the `job.finished` webhook will include an `async` field that shows whether the step runs asynchronously.

Example `job.finished` request body for a trigger job:

```json
{
  "event": "job.finished",
  "job": {
    "id": "...",
    "type": "trigger",
    "name": "...",
    "state": "...",
    "async": true,
    "...": "..."
  },
  "build": {
    "...": "..."
  },
  "pipeline": {
    "...": "..."
  },
  "sender": {
    "id": "8a7693f8-dbae-4783-9137-84090fce9045",
    "name": "Some Person"
  }
}
```

The `async` field indicates:

- `true`: The trigger step continues immediately, regardless of the triggered build's success.
- `false`: The trigger step waits for the triggered build to complete before continuing.

## Retry source in job events

When a job was created by retrying a previous job, its payload includes a `retry_source` object with details about the original job and, for manual retries, who triggered the retry.

<table>
  <thead>
    <tr><th>Property</th><th>Type</th><th>Description</th></tr>
  </thead>
  <tbody>
    <tr>
      <td><code>job_id</code></td>
      <td>String</td>
      <td>The UUID of the job that was retried</td>
    </tr>
    <tr>
      <td><code>retry_type</code></td>
      <td>String</td>
      <td>How the retry was triggered: <code>manual</code> or <code>automatic</code></td>
    </tr>
    <tr>
      <td><code>retried_by</code></td>
      <td>Object</td>
      <td>The user who triggered a manual retry, containing <code>name</code> and <code>email</code>. <code>null</code> for automatic retries, or when no retry occurred</td>
    </tr>
  </tbody>
</table>

`retry_source` itself is `null` when the job was not created by a retry.

Example `job.finished` request body for a manually retried job:

```json
{
  "event": "job.finished",
  "job": {
    "...": "...",
    "retry_source": {
      "job_id": "0194b92a-4d74-46bb-a1bf-61c73c5642af",
      "retry_type": "manual",
      "retried_by": {
        "name": "Some Person",
        "email": "some-person@example.com"
      }
    },
    "...": "..."
  },
  "build": {
    "...": "..."
  },
  "pipeline": {
    "...": "..."
  },
  "sender": {
    "id": "8a7693f8-dbae-4783-9137-84090fce9045",
    "name": "Some Person"
  }
}
```

For automatic retries, `retried_by` is `null`:

```json
{
  "retry_source": {
    "job_id": "0194b92a-4d74-46bb-a1bf-61c73c5642af",
    "retry_type": "automatic",
    "retried_by": null
  }
}
```

## Promised exit status events

When a running job declares an anticipated failure before it has finished, Buildkite Pipelines fires a `job.promised_exit_status` event. The job's state is still `running` at the time of this event. This event does not replace the subsequent `job.finished` event.

The payload uses the standard job webhook structure with one addition: a top-level `promised_exit_status_reason` field that describes why the job is expected to fail. This field can be `null`. The job object also includes `promised_exit_status` and `promised_exit_status_at` fields.

Example `job.promised_exit_status` request body:

```json
{
  "event": "job.promised_exit_status",
  "job": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "state": "running",
    "promised_exit_status": 1,
    "promised_exit_status_at": "2026-06-03T04:15:41.618Z",
    "...": "..."
  },
  "build": {
    "...": "..."
  },
  "pipeline": {
    "...": "..."
  },
  "promised_exit_status_reason": "test_failure (2 failed after retries)",
  "sender": {
    "id": "01234567-89ab-cdef-0123-456789abcdef",
    "name": "Some Person"
  }
}
```
