# Cluster token events

## Events

<table>
<tbody>
  <tr>
    <th><code>cluster_token.registration_blocked</code></th>
    <td>An attempted agent registration has been blocked because the request IP address is not included in the cluster token's <a href="/docs/clusters/manage-clusters#set-up-clusters-restrict-access-for-a-cluster-token-by-ip-address">allowed IP addresses</a></td>
  </tr>
</tbody>
</table>

## Request body data

<table>
<tbody>
  <tr><th><code>blocked_ip</code></th><td>The IP address of the blocked registration request</td></tr>
  <tr><th><code>cluster_token</code></th><td>The <a href="/docs/apis/rest-api/clusters#cluster-tokens">cluster token</a> used in the registration attempt</td></tr>
  <tr><th><code>sender</code></th><td>The user who created the webhook</td></tr>
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
