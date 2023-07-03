# Cluster token events

## Events

<table>
  <thead>
    <tr><th>Event</th><th>Description</th></tr>
  </thead>
<tbody>
  <tr>
    <th><code>cluster_token.registration_blocked</code></th>
    <td>An attempted agent registration has been blocked because the request IP address is not included in the cluster token's <a href="/docs/clusters/manage-clusters#set-up-clusters-restrict-access-for-a-cluster-token-by-ip-address">allowed IP addresses</a></td>
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
      <td><code>blocked_ip</code></td>
      <td>String</td>
      <td>The IP address of the blocked registration request</td>
    </tr>
    <tr>
      <td><code>cluster_token</code></td>
      <td><a href="/docs/apis/rest-api/clusters#cluster-tokens">Cluster token</a></td>
      <td>The cluster token used in the registration attempt</td>
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
  "event": "cluster_token.registration_blocked",
  "blocked_ip": "202.188.43.20",
  "cluster_token": {
    "...": "..."
  },
  "sender": {
    "id": "8a7693f8-dbae-4783-9137-84090fce9045",
    "name": "Some Person"
  }
}
```
