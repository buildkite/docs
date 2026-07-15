# Network ranges

Egress network ranges are the IP CIDR blocks that [Buildkite hosted agents](/docs/agent/buildkite-hosted) in a cluster use for outbound traffic. Use this endpoint to retrieve those ranges for firewall allowlisting or network policy configuration.

This API is available to organizations with Buildkite hosted agents enabled. Non-hosted clusters and hosted clusters with no configured ranges return an empty list.

## Network range data model

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>cidr_range</code></th>
      <td>The egress IP address range in CIDR notation</td>
    </tr>
    <tr>
      <th><code>kind</code></th>
      <td>The type of network range</td>
    </tr>
  </tbody>
</table>

## List network ranges

Returns the list of egress network ranges for a cluster. Non-hosted clusters and hosted clusters with no configured ranges return an empty list.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/network_ranges"
```

```json
[
  {
    "cidr_range": "203.0.113.0/29",
    "kind": "NAMESPACE_MANAGED"
  }
]
```

Required scope: `read_clusters`

Success response: `200 OK`

Error responses:

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>503 Service Unavailable</code></th>
      <td><code>{ "message": "Could not load network ranges: reason" }</code></td>
    </tr>
  </tbody>
</table>
