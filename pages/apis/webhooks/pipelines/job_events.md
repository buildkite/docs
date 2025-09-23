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
      <td><a href="/docs/api/jobs">Job</a></td>
      <td>The job this notification relates to</td>
    </tr>
    <tr>
      <td><code>build</code></td>
      <td><a href="/docs/api/builds">Build</a></td>
      <td>The build this notification relates to</td>
    </tr>
    <tr>
      <td><code>pipeline</code></td>
      <td><a href="/docs/api/pipelines">Pipeline</a></td>
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
