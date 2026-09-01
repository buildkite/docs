# Queue migrations

> 📘 Preview feature
> Queue migrations are in preview. [Contact Buildkite support](https://buildkite.com/support) to have this feature enabled for your organization.

A queue migration associates a queue key with a specific destination [queue](/docs/apis/rest-api/clusters/queues), tracking the proportion of that queue key's jobs routed to the destination using `routed_percent`. Creating a migration starts `routed_percent` at 0, and the create endpoint doesn't accept a value for it. Use the update endpoint to move `routed_percent` up or down after creation. Only one queue migration can exist for a queue key in your organization at a time.

A queue migration is addressed by its `queue_key`, matched exactly and case-sensitively. A request using a differently-cased key returns a `404 Not Found`.

## Queue migration data model

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>queue_key</code></th>
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
      <th><code>url</code></th>
      <td>Canonical URL of the queue migration, addressed by <code>queue_key</code></td>
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

## List queue migrations

Returns a cursor-paginated list of queue migrations. Organization administrators can view all queue migrations in the organization. Cluster maintainers can view migrations whose destination queues belong to clusters they maintain.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/cluster-queue-migrations"
```

```json
{
  "items": [
    {
      "queue_key": "default",
      "destination": {
        "cluster_id": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
        "queue_id": "01885682-55a7-44f5-84f3-0402fb452e66",
        "queue_key": "default"
      },
      "routed_percent": 70,
      "url": "https://api.buildkite.com/v2/organizations/acme-inc/cluster-queue-migrations/default",
      "created_at": "2026-08-07T04:17:55.867Z",
      "updated_at": "2026-08-07T05:02:11.221Z"
    }
  ],
  "links": {
    "self": "https://api.buildkite.com/v2/organizations/acme-inc/cluster-queue-migrations?per_page=30",
    "next": "https://api.buildkite.com/v2/organizations/acme-inc/cluster-queue-migrations?per_page=30&after=eyJ1dWlkIjoiLi4uIn0"
  }
}
```

The response body contains the following pagination fields:

- `items`: The queue migrations on the current page.
- `links`: URLs for the current page and available `first`, `prev`, and `next` pages. Follow these URLs instead of constructing cursors. The response also includes these links in the HTTP `Link` header.

Optional query string parameters:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>after</code></th>
    <td>Returns the next page after the supplied cursor. Cannot be combined with <code>before</code>.</td>
  </tr>
  <tr>
    <th><code>before</code></th>
    <td>Returns the previous page before the supplied cursor. Cannot be combined with <code>after</code>.</td>
  </tr>
  <tr>
    <th><code>per_page</code></th>
    <td>Number of results per page. Defaults to <code>30</code> and has a maximum of <code>100</code>.</td>
  </tr>
</tbody>
</table>

Required scope: `read_clusters`

Required permission: organization administrator privileges or cluster maintainer permissions for at least one cluster

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>400 Bad Request</code></th>
    <td>The request supplies both cursor parameters, an invalid cursor, or a <code>per_page</code> value outside the supported range.</td>
  </tr>
</tbody>
</table>

## Get a queue migration

Organization administrators can retrieve any queue migration in the organization. Cluster maintainers can retrieve a migration if its destination queue belongs to a cluster they maintain.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/cluster-queue-migrations/{queue_key}"
```

```json
{
  "queue_key": "default",
  "destination": {
    "cluster_id": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
    "queue_id": "01885682-55a7-44f5-84f3-0402fb452e66",
    "queue_key": "default"
  },
  "routed_percent": 70,
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/cluster-queue-migrations/default",
  "created_at": "2026-08-07T04:17:55.867Z",
  "updated_at": "2026-08-07T05:02:11.221Z"
}
```

Required scope: `read_clusters`

Required permission: organization administrator privileges or cluster maintainer permissions for the destination cluster

Success response: `200 OK`

## Create a queue migration

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/cluster-queue-migrations" \
  -H "Content-Type: application/json" \
  -d '{ "cluster_id": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf", "queue_key": "default" }'
```

```json
{
  "queue_key": "default",
  "destination": {
    "cluster_id": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
    "queue_id": "01885682-55a7-44f5-84f3-0402fb452e66",
    "queue_key": "default"
  },
  "routed_percent": 0,
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/cluster-queue-migrations/default",
  "created_at": "2026-08-07T04:17:55.867Z",
  "updated_at": "2026-08-07T04:17:55.867Z"
}
```

The response also includes a `Location` header set to the created queue migration's `url`.

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

Required permissions: organization administrator privileges (the `change_organization` permission) and permission to manage the destination cluster

Success response: `201 Created`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The token does not have the required scope, or the user lacks organization administrator privileges or permission to manage the destination cluster.</td>
  </tr>
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
  -X PATCH "https://api.buildkite.com/v2/organizations/{org.slug}/cluster-queue-migrations/{queue_key}" \
  -H "Content-Type: application/json" \
  -d '{ "routed_percent": 70 }'
```

```json
{
  "queue_key": "default",
  "destination": {
    "cluster_id": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
    "queue_id": "01885682-55a7-44f5-84f3-0402fb452e66",
    "queue_key": "default"
  },
  "routed_percent": 70,
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/cluster-queue-migrations/default",
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

## Check pipeline migration readiness

Reports whether an unclustered pipeline is ready to move to a destination cluster, based on the queue and concurrency group activity Buildkite has observed for that pipeline. This is a read-only evidence check: a `ready: false` response is a successful read, not an error, and it doesn't perform the move itself.

The check only evaluates queues and concurrency groups actually observed for the pipeline, using a rolling 10-minute job history window. Because the window is bounded, the observation is never a complete picture of the pipeline's queues, and any concurrency group observed for the pipeline blocks readiness, since concurrency groups can't be routed individually.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/cluster-queue-migrations/pipelines/{pipeline.slug}/readiness?destination_cluster_id={destination_cluster_id}"
```

```json
{
  "pipeline": "my-pipeline",
  "destination_cluster_id": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "ready": false,
  "status": "blocked",
  "retry_after_seconds": null,
  "queue_observation": {
    "observed_at": "2026-08-31T07:00:00.000Z",
    "window_started_at": "2026-08-31T06:50:00.000Z",
    "window_seconds": 600,
    "complete": false,
    "blocking_queues": [
      {
        "queue": "deploy",
        "reasons": ["active_source_jobs"],
        "routed_percent": 100,
        "active_source_jobs": 1
      }
    ]
  },
  "concurrency_group_observation": {
    "observed_at": "2026-08-31T07:00:00.000Z",
    "window_started_at": "2026-08-31T06:50:00.000Z",
    "window_seconds": 600,
    "complete": false,
    "blocking_concurrency_groups": []
  },
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/cluster-queue-migrations/pipelines/my-pipeline/readiness?destination_cluster_id=42f1a7da-812d-4430-93d8-1cc7c33a6bcf"
}
```

The response body contains the following fields:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>ready</code></th>
    <td>Whether the pipeline can move to the destination cluster based on the available evidence</td>
  </tr>
  <tr>
    <th><code>status</code></th>
    <td><code>no_known_blockers</code> if nothing observed is blocking the move, <code>blocked</code> if something observed is blocking it, or <code>observation_pending</code> if a fresh observation is still being calculated</td>
  </tr>
  <tr>
    <th><code>retry_after_seconds</code></th>
    <td>How long to wait before retrying, when <code>status</code> is <code>observation_pending</code>. <code>null</code> otherwise.</td>
  </tr>
  <tr>
    <th><code>queue_observation.blocking_queues</code></th>
    <td>Queues observed for the pipeline that are blocking readiness, each with one or more <code>reasons</code>: <code>migration_missing</code> (no queue migration exists for the queue), <code>routing_incomplete</code> (the queue migration's <code>routed_percent</code> is below 100), <code>wrong_destination</code> (the queue migration targets a different cluster), or <code>active_source_jobs</code> (the queue still has active, non-grouped legacy jobs)</td>
  </tr>
  <tr>
    <th><code>concurrency_group_observation.blocking_concurrency_groups</code></th>
    <td>Concurrency groups observed for the pipeline, each blocking readiness with reason <code>concurrency_group_migration_unavailable</code></td>
  </tr>
  <tr>
    <th><code>queue_observation.window_seconds</code>, <code>concurrency_group_observation.window_seconds</code></th>
    <td>Length of the job history window used to discover queues and concurrency groups, in seconds</td>
  </tr>
  <tr>
    <th><code>queue_observation.complete</code>, <code>concurrency_group_observation.complete</code></th>
    <td>Always <code>false</code>. The observation only covers the bounded window and is never guaranteed to be a complete picture of the pipeline's queues or concurrency groups.</td>
  </tr>
  <tr>
    <th><code>url</code></th>
    <td>Canonical URL of this readiness check, including the <code>destination_cluster_id</code> query string parameter</td>
  </tr>
</tbody>
</table>

Readiness observations are cached for up to two minutes. `queue_observation` and `concurrency_group_observation` reflect the cached observation's timestamp, but the migrations they're checked against are always resolved fresh, so `ready` and `status` always reflect current migration state.

Required query string parameter:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>destination_cluster_id</code></th>
    <td>ID of the destination cluster to check readiness against</td>
  </tr>
</tbody>
</table>

Required scopes: `read_clusters`, `read_pipelines`

Required permission: organization administrator privileges, or cluster maintainer permissions for the destination cluster

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The token does not have the required scopes, or the user lacks the required permission</td>
  </tr>
  <tr>
    <th><code>404 Not Found</code></th>
    <td><code>destination_cluster_id</code> doesn't resolve to a cluster in your organization</td>
  </tr>
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td><code>{ "message": "Pipeline must not already belong to a cluster" }</code> or <code>{ "message": "destination_cluster_id must be a valid UUID" }</code></td>
  </tr>
  <tr>
    <th><code>503 Service Unavailable</code></th>
    <td><code>{ "message": "This feature hasn't been enabled for your organization" }</code></td>
  </tr>
</tbody>
</table>
