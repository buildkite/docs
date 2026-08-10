# Queue migrations

> 📘 Preview feature
> Queue migrations are in preview. [Contact Buildkite support](https://buildkite.com/support) to have this feature enabled for your organization.

A queue migration associates a queue key with a specific destination [queue](/docs/apis/rest-api/clusters/queues), tracking the proportion of that queue key's jobs routed to the destination using `routed_percent`. Creating a migration starts `routed_percent` at 0, and the create endpoint doesn't accept a value for it. Use the update endpoint to move `routed_percent` up or down after creation. Only one queue migration can exist for a queue key in your organization at a time.

## Queue migration data model

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>id</code></th>
      <td>ID of the queue migration</td>
    </tr>
    <tr>
      <th><code>source.queue_key</code></th>
      <td>Key of the queue being migrated</td>
    </tr>
    <tr>
      <th><code>destination.cluster_id</code></th>
      <td>ID of the cluster containing the destination queue</td>
    </tr>
    <tr>
      <th><code>destination.queue_id</code></th>
      <td>ID of the destination queue</td>
    </tr>
    <tr>
      <th><code>destination.queue_key</code></th>
      <td>Key of the destination queue</td>
    </tr>
    <tr>
      <th><code>routed_percent</code></th>
      <td>Percentage of the queue key's jobs currently routed to the destination queue. New queue migrations start at <code>0</code>.</td>
    </tr>
    <tr>
      <th><code>created_at</code></th>
      <td>When the queue migration was created</td>
    </tr>
    <tr>
      <th><code>updated_at</code></th>
      <td>When the queue migration was last updated</td>
    </tr>
  </tbody>
</table>

## Create a queue migration

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/cluster-queue-migrations" \
  -H "Content-Type: application/json" \
  -d '{ "cluster_id": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf", "queue_key": "default" }'
```

```json
{
  "id": "0198f47a-9c1a-7db2-93aa-2b6f6a2e9d41",
  "source": {
    "queue_key": "default"
  },
  "destination": {
    "cluster_id": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
    "queue_id": "01885682-55a7-44f5-84f3-0402fb452e66",
    "queue_key": "default"
  },
  "routed_percent": 0,
  "created_at": "2026-08-07T04:17:55.867Z",
  "updated_at": "2026-08-07T04:17:55.867Z"
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>cluster_id</code></th>
    <td>ID of the cluster containing the destination queue.<br><em>Example:</em> <code>"42f1a7da-812d-4430-93d8-1cc7c33a6bcf"</code></td>
  </tr>
  <tr>
    <th><code>queue_key</code></th>
    <td>Key of the destination queue within the specified cluster.<br><em>Example:</em> <code>"default"</code></td>
  </tr>
</tbody>
</table>

Required scope: `write_clusters`

Success response: `201 Created`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>404 Not Found</code></th>
    <td><code>{ "message": "No cluster found" }</code> if <code>cluster_id</code> doesn't resolve to a cluster in your organization, or <code>{ "message": "No cluster queue found" }</code> if <code>queue_key</code> doesn't resolve to a queue in that cluster</td>
  </tr>
  <tr>
    <th><code>409 Conflict</code></th>
    <td><code>{ "message": "A migration for queue key `default` already exists" }</code></td>
  </tr>
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td><code>{ "message": "routed_percent cannot be set when creating a migration" }</code>, <code>{ "message": "cluster_id must be a valid UUID" }</code>, or <code>{ "message": "queue_key must be a string" }</code></td>
  </tr>
  <tr>
    <th><code>503 Service Unavailable</code></th>
    <td><code>{ "message": "This feature hasn't been enabled for your organization" }</code></td>
  </tr>
</tbody>
</table>

## Update a queue migration

Changes the percentage of a queue key's jobs routed to the migration's destination queue. `routed_percent` can be moved up or down, and accepts any integer from 0 through 100.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PATCH "https://api.buildkite.com/v2/organizations/{org.slug}/cluster-queue-migrations/{migration.id}" \
  -H "Content-Type: application/json" \
  -d '{ "routed_percent": 70 }'
```

```json
{
  "id": "0198f47a-9c1a-7db2-93aa-2b6f6a2e9d41",
  "source": {
    "queue_key": "default"
  },
  "destination": {
    "cluster_id": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
    "queue_id": "01885682-55a7-44f5-84f3-0402fb452e66",
    "queue_key": "default"
  },
  "routed_percent": 70,
  "created_at": "2026-08-07T04:17:55.867Z",
  "updated_at": "2026-08-07T05:02:11.221Z"
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>routed_percent</code></th>
    <td>The percentage of the queue key's jobs to route to the destination queue, as an integer from <code>0</code> through <code>100</code>. Can be higher or lower than the migration's current value.<br><em>Example:</em> <code>70</code></td>
  </tr>
</tbody>
</table>

Required scope: `write_clusters`

Required permission: organization administration, and permission to manage the destination cluster

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The token does not have the required scope, or the user lacks organization administration or destination cluster management permission.</td>
  </tr>
  <tr>
    <th><code>404 Not Found</code></th>
    <td><code>{ "message": "No cluster queue migration found" }</code> if the migration doesn't exist or belongs to another organization</td>
  </tr>
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td><code>{ "message": "routed_percent is required" }</code>, <code>{ "message": "routed_percent must be an integer" }</code>, or <code>{ "message": "Validation failed: Routed percent must be greater than or equal to 0" }</code> (and similarly for values over 100)</td>
  </tr>
  <tr>
    <th><code>503 Service Unavailable</code></th>
    <td><code>{ "message": "This feature hasn't been enabled for your organization" }</code></td>
  </tr>
</tbody>
</table>
