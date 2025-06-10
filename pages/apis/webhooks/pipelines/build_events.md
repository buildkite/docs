# Build webhook events

## Events

<table>
  <thead>
    <tr><th>Event</th><th>Description</th></tr>
  </thead>
  <tbody>
    <tr><th><code>build.scheduled</code></th><td>A build has been scheduled</td></tr>
    <tr><th><code>build.running</code></th><td>A build has started running</td></tr>
    <tr><th><code>build.finished</code></th><td>A build has finished</td></tr>
    <tr><th><code>build.failing</code></th><td>A build is failing</td></tr>
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
## Finding out if a build is blocked

To if a build is blocked, look for `blocked: true` in the `build.finished` event

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
> However, to determine if an EventBridge notification is blocked, look for <code>"state": "blocked". </code>, like in this <a href="/docs/pipelines/integrations/other/amazon-eventbridge#events-build-blocked">sample Eventbridge request</a>.
