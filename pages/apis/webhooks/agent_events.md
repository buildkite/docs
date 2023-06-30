# Agent webhook events


## Events

<table>
<tbody>
<%= render_markdown partial: 'apis/webhooks/agent_events_table' %>
</tbody>
</table>

## Request body data

<table>
<tbody>
  <tr><th><code>agent</code></th><td>The <a href="/docs/api/agents">Agent</a> this notification relates to</td></tr>
  <tr><th><code>sender</code></th><td>The user who created the webhook</td></tr>
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

### `agent.blocked`

<table>
<tbody>
  <tr><th><code>blocked_ip</code></th><td>The blocked request IP address</td></tr>
  <tr><th><code>agent</code></th><td>The <a href="/docs/api/agents">Agent</a> this notification relates to</td></tr>
  <tr><th><code>cluster_token</code></th><td>The <a href="/docs/apis/rest-api/clusters#cluster-tokens">cluster token</a> used in the registration attempt</td></tr>
  <tr><th><code>sender</code></th><td>The user who created the webhook</td></tr>
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
