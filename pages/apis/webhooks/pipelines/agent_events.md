# Agent webhook events


## Events

<table>
  <thead>
    <tr><th>Event</th><th>Description</th></tr>
  </thead>
  <tbody>
    <%= render_markdown partial: 'apis/webhooks/pipelines/agent_events_table' %>
  </tbody>
</table>

## Common event data

The following properties are sent by all events.

<table>
  <thead>
    <tr><th>Property</th><th>Type</th><th>Description</th></tr>
  </thead>
  <tbody>
    <tr>
      <td><code>agent</code></td>
      <td><a href="/docs/api/agents">Agent</a></td>
      <td>The agent this notification relates to</td></tr>
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
  "event": "agent.connected",
  "agent": {
    "...": "..."
  },
  "sender": {
    "id": "8a7693f8-dbae-4783-9137-84090fce9045",
    "name": "Some Person"
  }
}
```

## Agent blocked event data

The following properties are sent by the `agent.blocked` event.

<table>
  <thead>
    <tr><th>Property</th><th>Type</th><th>Description</th></tr>
  </thead>
  <tbody>
    <tr>
      <td><code>blocked_ip</code></td>
      <td>String</td>
      <td>The blocked request IP address</td>
    </tr>
    <tr>
      <td><code>agent</code></td>
      <td><a href="/docs/api/agents">Agent</a></td>
      <td>The agent this notification relates to</td>
    </tr>
    <tr>
      <td><code>cluster_token</code></td>
      <td><a href="/docs/apis/rest-api/clusters/agent-tokens#token-data-model">Agent token</a></td>
      <td>The agent token used in the registration attempt</td>
    </tr>
    <tr>
      <td><code>sender</code></td>
      <td>String</td>
      <td>The user who created the webhook</td></tr>
  </tbody>
</table>

Example request body:

```json
{
  "event": "agent.blocked",
  "blocked_ip": "202.188.43.20",
  "agent": {
    "...": "..."
  },
  "cluster_token": {
    "...": "..."
  },
  "sender": {
    "id": "8a7693f8-dbae-4783-9137-84090fce9045",
    "name": "Some Person"
  }
}
```
