# Build webhook events

## Events

<table>
  <thead>
    <tr><th>Event</th><th>Description</th></tr>
  </thead>
  <tbody>
    <tr><th><code>build.scheduled</code></th><td>A build has been scheduled</td></tr>
    <tr><th><code>build.running</code></th><td>A build has started running</td></tr>
    <tr><th><code>build.failing</code></th><td>A build is failing</td></tr>
    <tr><th><code>build.finished</code></th><td>A build has finished</td></tr>
    <tr><th><code>build.skipped</code></th><td>A build has been skipped</td></tr>
  </tbody>
</table>

## Request body data

<table>
  <thead>
    <tr><th>Property</th><th>Type</th><th>Description</th></tr>
  </thead>
  <tbody>
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
      <td>Object</td>
      <td>The user who created the webhook</td>
    </tr>
  </tbody>
</table>

Example request body:

```json
{
  "event": "build.scheduled",
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

> 📘 Job data not included
> When using webhooks, the build object does not contain job data (as returned by calls to the [Build API](/docs/apis/rest-api/builds) of Buildkite's REST API). Learn more about obtaining job data from Buildkite Pipelines using webhooks in [Job events](/docs/webhooks/pipelines/job_events).


## Finding out if a build is blocked

If a build is blocked, look for `blocked: true` in the `build.finished` event

Example request body for blocked build:

```json
{
  "event": "build.finished",
  "build": {
    "...": "...",
    "blocked": true,
    "...": "..."
  },
  "pipeline": {
    "...": "..."
  },
  "sender": {
    "id": "0adfbc27-5f72-4a91-bf61-5693da0dd9c5",
    "name": "Some person"
  }
}
```

> 📘 To determine if an EventBridge notification is blocked
> However, to determine if an EventBridge notification is blocked, look for <code>"state": "blocked". </code>, like in this <a href="/docs/pipelines/integrations/observability/amazon-eventbridge#events-build-blocked">sample Eventbridge request</a>.

## Trigger steps in build events

When a build contains trigger steps, the `build.finished` webhook includes the `async` field in the step configuration.

Example `build.finished` request body with trigger step:

```json
{
  "event": "build.finished",
  "build": {
    "steps": [
      {
        "type": "trigger",
        "async": true,
        "...": "..."
      }
    ],
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
- `true`: The trigger step continues immediately, regardless of the triggered build's success
- `false`: The trigger step waits for the triggered build to complete before continuing.
