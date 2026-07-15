# Notification services

The notification services API endpoints let you manage an organization's notification services over REST. Notification services deliver Buildkite Pipelines notifications to destinations such as Slack, webhooks, and Datadog. See [Integrations](/docs/pipelines/integrations) for provider setup guides.

All endpoints require the authenticated user to have the **Change Notification Services** permission. Read operations require the `read_notification_services` API access token scope. Create, update, delete, enable, and disable operations require the `write_notification_services` scope.

## Notification service data model

The API returns the following fields for a notification service:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>id</code></th>
    <td>UUID of the notification service.</td>
  </tr>
  <tr>
    <th><code>graphql_id</code></th>
    <td><a href="/docs/apis/graphql-api#graphql-ids">GraphQL ID</a> of the notification service. The value is <code>null</code> for providers without a corresponding GraphQL type.</td>
  </tr>
  <tr>
    <th><code>url</code></th>
    <td>Canonical REST API URL of the notification service.</td>
  </tr>
  <tr>
    <th><code>provider</code></th>
    <td>Map containing the provider's <code>id</code> and display <code>name</code>.</td>
  </tr>
  <tr>
    <th><code>description</code></th>
    <td>Description of the notification service.</td>
  </tr>
  <tr>
    <th><code>enabled</code></th>
    <td>Whether the notification service is enabled.</td>
  </tr>
  <tr>
    <th><code>scope</code></th>
    <td>Resources that use the notification service: <code>all</code>, <code>some_projects</code>, <code>some_teams</code>, or <code>some_clusters</code>.</td>
  </tr>
  <tr>
    <th><code>scope_uuids</code></th>
    <td>Array of pipeline, team, or cluster UUIDs selected by <code>scope</code>. The array is empty when <code>scope</code> is <code>all</code>.</td>
  </tr>
  <tr>
    <th><code>branch_configuration</code></th>
    <td>Branch pattern that limits notifications, or an empty string when no branch filter is configured.</td>
  </tr>
  <tr>
    <th><code>build_states</code></th>
    <td>Map of notification events and whether each event is enabled. See <a href="#notification-service-data-model-build-state-fields">Build state fields</a>.</td>
  </tr>
  <tr>
    <th><code>settings</code></th>
    <td>Provider-specific settings. Secret fields can be masked or omitted. See <a href="#notification-service-data-model-provider-settings">Provider settings</a>.</td>
  </tr>
  <tr>
    <th><code>created_at</code></th>
    <td>Time when the notification service was created.</td>
  </tr>
  <tr>
    <th><code>created_by</code></th>
    <td>User who created the notification service, or <code>null</code> when the creator is unavailable.</td>
  </tr>
</tbody>
</table>

### Build state fields

The `build_states` map contains boolean values for these fields:

- `build_passed`
- `build_fixed`
- `build_failed`
- `build_blocked`
- `build_canceled`
- `build_failing`
- `job_activated`

### Provider settings

The `provider` value is immutable after you create a notification service. The following provider IDs and settings are available:

Provider ID | Writable settings | Notes
----------- | ----------------- | -----
`aws_event_bridge` | `aws_region`, `aws_account_id`, `include_build_meta_data` | `aws_region` and `aws_account_id` are required when creating the service and cannot be changed later.
`datadog_pipeline_visibility` | `api_key`, `datadog_site`, `datadog_tags` | The API masks `api_key` in responses.
`event_log_api` | `events` | Available only to organizations with the Event Log API provider enabled.
`linear` | None | Uses OAuth. Create the service in the Buildkite interface. You can update its common fields using the API.
`open_telemetry_tracing` | `endpoint`, `service_name`, `headers`, `resource_attributes`, `tracestate` | The API omits encrypted `headers` from responses. Availability of `tracestate` depends on the organization.
`slack` | `url`, `theme` | The API omits `url` from responses. OAuth-connected Slack service URLs cannot be changed using the API.
`slack_workspace` | None | Uses OAuth. Create the service in the Buildkite interface. You can update its common fields using the API.
`webhook` | `url`, `token`, `token_mode`, `version`, `events`, `tls_verify` | New services must use the latest webhook payload version. The API returns `token` without masking so it can be used to verify webhook signatures.
{: class="responsive-table"}

## List notification services

Returns an organization's notification services in chronological order. The response uses cursor pagination and excludes Package Registries notification services, hosted agent dispatch webhooks, and providers that are not available to the organization.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/services"
```

```json
{
  "items": [
    {
      "id": "01234567-89ab-cdef-0123-456789abcdef",
      "graphql_id": "Tm90aWZpY2F0aW9uU2VydmljZVdlYmhvb2stLS0wMTIzNDU2Ny04OWFiLWNkZWYtMDEyMy00NTY3ODlhYmNkZWY=",
      "url": "https://api.buildkite.com/v2/organizations/acme-inc/services/01234567-89ab-cdef-0123-456789abcdef",
      "provider": {
        "id": "webhook",
        "name": "Webhook"
      },
      "description": "Deployment events",
      "enabled": true,
      "scope": "all",
      "scope_uuids": [],
      "branch_configuration": "main",
      "build_states": {
        "build_passed": true,
        "build_fixed": true,
        "build_failed": true,
        "build_blocked": false,
        "build_canceled": false,
        "build_failing": false,
        "job_activated": false
      },
      "settings": {
        "url": "https://example.com/webhook",
        "token": "YOUR_WEBHOOK_TOKEN",
        "token_mode": "token",
        "version": 3,
        "events": ["build.finished"],
        "tls_verify": true
      },
      "created_at": "2026-07-01T12:00:00.000Z",
      "created_by": {
        "id": "abcdef01-2345-6789-abcd-ef0123456789",
        "name": "Sam Kim"
      }
    }
  ],
  "links": {
    "self": "https://api.buildkite.com/v2/organizations/acme-inc/services?per_page=30"
  }
}
```

Optional [query string parameters](/docs/api#query-string-parameters):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>per_page</code></th>
    <td>Number of notification services to return per page.</td>
  </tr>
  <tr>
    <th><code>after</code></th>
    <td>Returns the page after this cursor. Do not use with <code>before</code>.</td>
  </tr>
  <tr>
    <th><code>before</code></th>
    <td>Returns the page before this cursor. Do not use with <code>after</code>.</td>
  </tr>
</tbody>
</table>

Required scope: `read_notification_services`

Success response: `200 OK`

## Get a notification service

Returns one notification service.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/services/{uuid}"
```

The response uses the [notification service data model](#notification-service-data-model).

Required scope: `read_notification_services`

Success response: `200 OK`

Error response: `404 Not Found` when the notification service does not exist, belongs to another organization, or is not visible through this API.

## Create a notification service

Creates a notification service. The following example creates a webhook notification service:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/services" \
  -d '{
    "provider": "webhook",
    "description": "Deployment events",
    "scope": "all",
    "branch_configuration": "main",
    "build_states": {
      "build_failed": true,
      "build_passed": true
    },
    "settings": {
      "url": "https://example.com/webhook",
      "events": ["build.finished"],
      "tls_verify": true
    }
  }'
```

Request body fields:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>provider</code></th>
    <td>Required provider ID. See <a href="#notification-service-data-model-provider-settings">Provider settings</a>.</td>
  </tr>
  <tr>
    <th><code>description</code></th>
    <td>Description of the notification service.</td>
  </tr>
  <tr>
    <th><code>scope</code></th>
    <td>Resources that use the notification service: <code>all</code>, <code>some_projects</code>, <code>some_teams</code>, or <code>some_clusters</code>. Defaults to <code>all</code>.</td>
  </tr>
  <tr>
    <th><code>scope_uuids</code></th>
    <td>Array of pipeline, team, or cluster UUIDs. Supply this field when <code>scope</code> is a corresponding <code>some_*</code> value.</td>
  </tr>
  <tr>
    <th><code>branch_configuration</code></th>
    <td>Branch pattern that limits notifications.</td>
  </tr>
  <tr>
    <th><code>build_states</code></th>
    <td>Map containing the events to enable or disable. See <a href="#notification-service-data-model-build-state-fields">Build state fields</a>.</td>
  </tr>
  <tr>
    <th><code>settings</code></th>
    <td>Map of settings accepted by the selected provider.</td>
  </tr>
</tbody>
</table>

Returns the created notification service.

Required scope: `write_notification_services`

Success response: `201 Created`

Error response: `422 Unprocessable Entity` when the provider, scope, event, or provider-specific setting is invalid. Providers that use OAuth must be created in the Buildkite interface.

## Update a notification service

Updates the supplied fields of a notification service. Omitted fields remain unchanged. The `provider` cannot be changed.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -X PATCH "https://api.buildkite.com/v2/organizations/{org.slug}/services/{uuid}" \
  -d '{
    "description": "Production deployment events",
    "build_states": {
      "build_failed": true,
      "build_passed": false
    }
  }'
```

The request accepts the same fields as [Create a notification service](#create-a-notification-service). The API accepts a masked secret from a previous response without replacing the stored secret. OAuth-managed and create-only settings cannot be changed.

Returns the updated notification service.

Required scope: `write_notification_services`

Success response: `200 OK`

Error responses: `404 Not Found` when the notification service is unavailable, or `422 Unprocessable Entity` when a field is invalid or cannot be changed.

## Delete a notification service

Deletes a notification service.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/services/{uuid}"
```

Required scope: `write_notification_services`

Success response: `204 No Content`

## Enable a notification service

Enables a notification service. If delivery failures automatically disabled the service, enabling it also clears its broken state and associated error message.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/services/{uuid}/enable"
```

Returns the updated notification service and records an audit event.

Required scope: `write_notification_services`

Success response: `200 OK`

## Disable a notification service

Disables a notification service and records the user who disabled it.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/services/{uuid}/disable"
```

Returns the updated notification service and records an audit event.

Required scope: `write_notification_services`

Success response: `200 OK`
