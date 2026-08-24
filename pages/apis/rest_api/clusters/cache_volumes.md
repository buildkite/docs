# Cache volumes

[Cache volumes](/docs/agent/buildkite-hosted/cache-volumes) are external volumes attached to [Buildkite hosted agent](/docs/agent/buildkite-hosted) instances in a cluster. Use these endpoints to list and delete a cluster's cache volumes.

This API is available to organizations with Buildkite hosted agents enabled. For non-hosted clusters, the list endpoint returns an empty list, and the delete endpoint returns `404 Not Found`.

## Cache volume data model

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>id</code></th>
      <td>ID of the cache volume</td>
    </tr>
    <tr>
      <th><code>tag</code></th>
      <td>The cache tag identifying this volume (for example, <code>pipeline-uuid/node-modules</code>)</td>
    </tr>
    <tr>
      <th><code>cluster_id</code></th>
      <td>ID of the cluster the cache volume belongs to</td>
    </tr>
    <tr>
      <th><code>size_mb</code></th>
      <td>Size of the cache volume in megabytes</td>
    </tr>
    <tr>
      <th><code>created_at</code></th>
      <td>When the cache volume was created</td>
    </tr>
    <tr>
      <th><code>attached_at</code></th>
      <td>When the cache volume was last attached to an agent</td>
    </tr>
    <tr>
      <th><code>detached_at</code></th>
      <td>When the cache volume was last detached from an agent</td>
    </tr>
  </tbody>
</table>

## List cache volumes

Returns an unpaginated list containing the latest detached cache volume for each tag. Volumes that have not been detached are not returned. Non-hosted clusters and hosted clusters with no detached cache volumes return an empty list.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/cache_volumes"
```

```json
[
  {
    "id": "vol-01j9z1p0qr3s4t5u6v7w8x9y0z",
    "tag": "pipeline-uuid/node-modules",
    "cluster_id": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
    "size_mb": 20480,
    "created_at": "2024-10-01T00:00:00.000Z",
    "attached_at": "2024-10-15T08:00:00.000Z",
    "detached_at": "2024-10-15T08:30:00.000Z"
  }
]
```

Required scope: `read_clusters`

Required permission: permission to manage the cluster

Success response: `200 OK`

Error responses:

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>503 Service Unavailable</code></th>
      <td><code>{ "message": "Could not load cache volumes: reason" }</code></td>
    </tr>
  </tbody>
</table>

## Delete a cache volume

Deletes cache data by its tag. Cache tags can contain `/` and `;`. The tag is passed in the request body rather than as a URL path segment. Use the `tag` from a list response, not the cache volume `id`. Deletion applies to the tag represented by the list result.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/cache_volumes" \
  -H "Content-Type: application/json" \
  -d '{ "tag": "pipeline-uuid/node-modules" }'
```

Required [request body properties](/docs/apis/rest-api#request-body-properties):

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>tag</code></th>
      <td>The cache tag identifying the volume to delete.<br><em>Example:</em> <code>"pipeline-uuid/node-modules"</code></td>
    </tr>
  </tbody>
</table>

Required scope: `write_clusters`

Required permission: permission to manage the cluster

Success response: `204 No Content`

Error responses:

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>400 Bad Request</code></th>
      <td><code>{ "message": "`tag` must be a non-empty string" }</code></td>
    </tr>
    <tr>
      <th><code>404 Not Found</code></th>
      <td><code>{ "message": "No cache volume found for tag: tag-value" }</code></td>
    </tr>
    <tr>
      <th><code>404 Not Found</code></th>
      <td><code>{ "message": "This cluster has no hosted cache volumes" }</code></td>
    </tr>
    <tr>
      <th><code>503 Service Unavailable</code></th>
      <td><code>{ "message": "Could not delete cache volume: reason" }</code></td>
    </tr>
  </tbody>
</table>
