# Notification services API

The notification services API lets you manage the organization-level integrations that send build and job notifications to services such as Slack, webhooks, Amazon EventBridge, Datadog, and OpenTelemetry.

List and get operations require the `read_notification_services` [access token scope](/docs/apis/managing-api-tokens#token-scopes). Create, update, delete, enable, and disable operations require the `write_notification_services` scope. All operations also require the authenticated user to have the **Change Notification Services** [organization permission](/docs/pipelines/security/permissions).

> 📘 Notification service visibility
> These endpoints exclude hosted agent dispatch webhooks and Package Registries notification services. The Event Log API provider is returned only when it is enabled for the organization.

## Notification service data model

Notification service endpoints return objects with the following fields:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>id</code></th>
    <td>UUID of the notification service.</td>
  </tr>
  <tr>
    <th><code>graphql_id</code></th>
    <td><a href="/docs/apis/graphql-api#graphql-ids">GraphQL ID</a> of the notification service. This is <code>null</code> for providers without a corresponding GraphQL node type.</td>
  </tr>
  <tr>
    <th><code>url</code></th>
    <td>Canonical REST API URL of the notification service.</td>
  </tr>
  <tr>
    <th><code>provider</code></th>
    <td>Object containing the provider <code>id</code> and display <code>name</code>.</td>
  </tr>
  <tr>
    <th><code>description</code></th>
    <td>User-provided description of the notification service.</td>
  </tr>
  <tr>
    <th><code>enabled</code></th>
    <td>Whether the notification service is active.</td>
  </tr>
  <tr>
    <th><code>scope</code></th>
    <td>Resources covered by the service. One of <code>all</code>, <code>some_projects</code>, <code>some_teams</code>, or <code>some_clusters</code>.</td>
  </tr>
  <tr>
    <th><code>scope_uuids</code></th>
    <td>UUIDs of the pipelines, teams, or clusters covered when <code>scope</code> is a <code>some_*</code> value.</td>
  </tr>
  <tr>
    <th><code>branch_configuration</code></th>
    <td>Branch filter pattern. An empty string means all branches.</td>
  </tr>
  <tr>
    <th><code>build_states</code></th>
    <td>Object whose keys are build or job states and whose values indicate whether that state triggers a notification.</td>
  </tr>
  <tr>
    <th><code>settings</code></th>
    <td>Provider-specific configuration. See <a href="#settings-and-secret-handling">Settings and secret handling</a>.</td>
  </tr>
  <tr>
    <th><code>created_at</code></th>
    <td>ISO 8601 timestamp of when the notification service was created.</td>
  </tr>
  <tr>
    <th><code>created_by</code></th>
    <td>User who created the notification service, or <code>null</code> when unavailable.</td>
  </tr>
</tbody>
</table>

For example:

```json
{
  "id": "9f0f9a19-1b88-4e37-98d8-c5a0cebcdb9a",
  "graphql_id": "Tm90aWZpY2F0aW9uU2VydmljZVdlYmhvb2stLS05ZjBmOWExOS0xYjg4LTRlMzctOThkOC1jNWEwY2ViY2RiOWE=",
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/services/9f0f9a19-1b88-4e37-98d8-c5a0cebcdb9a",
  "provider": {
    "id": "webhook",
    "name": "Webhook"
  },
  "description": "Deploy notifications",
  "enabled": true,
  "scope": "all",
  "scope_uuids": [],
  "branch_configuration": "",
  "build_states": {
    "build_passed": false,
    "build_fixed": false,
    "build_failed": true,
    "build_blocked": false,
    "build_canceled": false,
    "build_failing": false,
    "job_activated": false
  },
  "settings": {
    "url": "https://example.com/buildkite-webhook",
    "version": 3,
    "token": "xxx-yyy-zzz",
    "token_mode": "token",
    "events": ["build.finished"],
    "tls_verify": true
  },
  "created_at": "2026-07-01T10:00:00.000Z",
  "created_by": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQ==",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2025-01-01T00:00:00.000Z"
  }
}
```

### Settings and secret handling

The `settings` object varies by provider. Secret handling mirrors the Buildkite interface:

- Webhook `token` values are returned in full so that callers can verify webhook tokens or HMAC signatures.
- Masked fields, such as the Datadog `api_key` and Amazon EventBridge `aws_account_id`, show only their final characters.
- OAuth credentials such as `access_token` and `refresh_token` are omitted.
- Slack incoming webhook URLs and encrypted OpenTelemetry headers are omitted.

When updating a service, sending a masked value back unchanged preserves the stored secret. Send a new plaintext value to replace it.

## List notification services

Returns a cursor-paginated list of notification services, ordered from oldest to newest.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/services?per_page=30"
```

The response contains notification service objects in `items` and pagination URLs in `links`:

```json
{
  "items": [
    {
      "id": "9f0f9a19-1b88-4e37-98d8-c5a0cebcdb9a",
      "graphql_id": null,
      "url": "https://api.buildkite.com/v2/organizations/acme-inc/services/9f0f9a19-1b88-4e37-98d8-c5a0cebcdb9a",
      "provider": {
        "id": "datadog_pipeline_visibility",
        "name": "Datadog Pipeline Visibility"
      },
      "description": "Pipeline visibility",
      "enabled": true,
      "scope": "all",
      "scope_uuids": [],
      "branch_configuration": "",
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
        "api_key": "XXXXXXXXXXXXcdef",
        "datadog_site": "datadoghq.com",
        "datadog_tags": null
      },
      "created_at": "2026-07-01T10:00:00.000Z",
      "created_by": null
    }
  ],
  "links": {
    "self": "https://api.buildkite.com/v2/organizations/acme-inc/services?per_page=30",
    "next": "https://api.buildkite.com/v2/organizations/acme-inc/services?after=CURSOR&per_page=30"
  }
}
```

Optional [query string parameters](/docs/api#query-string-parameters):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>per_page</code></th>
    <td>Number of results per page.<p class="Docs__api-param-eg"><em>Default:</em> <code>30</code></p><p class="Docs__api-param-eg"><em>Maximum:</em> <code>100</code></p></td>
  </tr>
  <tr>
    <th><code>after</code></th>
    <td>Return results after this cursor. Mutually exclusive with <code>before</code>.</td>
  </tr>
  <tr>
    <th><code>before</code></th>
    <td>Return results before this cursor. Mutually exclusive with <code>after</code>.</td>
  </tr>
</tbody>
</table>

Required scope: `read_notification_services`

Success response: `200 OK`

## Get a notification service

Returns a notification service by UUID.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/services/{uuid}"
```

Required scope: `read_notification_services`

Success response: `200 OK`

Error response: `404 Not Found` when the UUID does not identify a visible notification service in the organization.

## Create a notification service

Creates a notification service. OAuth-managed `slack_workspace` and `linear` services must first be connected using the Buildkite interface, but can then be read, updated, deleted, enabled, and disabled using the API.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/services" \
  -d '{
    "provider": "webhook",
    "description": "Deploy notifications",
    "settings": {
      "url": "https://example.com/buildkite-webhook",
      "token": "xxx-yyy-zzz",
      "events": ["build.finished"]
    },
    "build_states": {
      "build_failed": true
    }
  }'
```

[Request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>provider</code></th>
    <td>Required. Provider identifier. See <a href="#providers">Providers</a>.</td>
  </tr>
  <tr>
    <th><code>description</code></th>
    <td>Human-readable description.</td>
  </tr>
  <tr>
    <th><code>branch_configuration</code></th>
    <td>Branch filter pattern. For example, <code>main feature/*</code>.</td>
  </tr>
  <tr>
    <th><code>scope</code></th>
    <td>One of <code>all</code> (the default), <code>some_projects</code>, <code>some_teams</code>, or <code>some_clusters</code>.</td>
  </tr>
  <tr>
    <th><code>scope_uuids</code></th>
    <td>UUIDs from the organization that correspond to a <code>some_*</code> scope.</td>
  </tr>
  <tr>
    <th><code>build_states</code></th>
    <td>Object with boolean values for <code>build_passed</code>, <code>build_fixed</code>, <code>build_failed</code>, <code>build_blocked</code>, <code>build_canceled</code>, <code>build_failing</code>, and <code>job_activated</code>.</td>
  </tr>
  <tr>
    <th><code>settings</code></th>
    <td>Provider-specific configuration. See <a href="#providers">Providers</a>.</td>
  </tr>
</tbody>
</table>

Required scope: `write_notification_services`

Success response: `201 Created`

Error response: `422 Unprocessable Entity` when the request contains invalid, unavailable, unknown, or read-only fields.

### Providers

The following providers can be created using the REST API:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>webhook</code></th>
    <td>Settings: <code>url</code> (required), <code>token</code>, <code>token_mode</code> (<code>token</code> or <code>signature</code>), <code>version</code>, <code>events</code>, and <code>tls_verify</code>.</td>
  </tr>
  <tr>
    <th><code>slack</code></th>
    <td>Slack or Slack-compatible incoming webhook. Settings: <code>url</code> (required) and <code>theme</code> (<code>text</code> or <code>emoji</code>).</td>
  </tr>
  <tr>
    <th><code>aws_event_bridge</code></th>
    <td>Settings: <code>aws_region</code> (required), <code>aws_account_id</code> (required 12-digit string), and <code>include_build_meta_data</code> when available for the organization.</td>
  </tr>
  <tr>
    <th><code>datadog_pipeline_visibility</code></th>
    <td>Settings: <code>api_key</code> (required), <code>datadog_site</code>, and <code>datadog_tags</code>.</td>
  </tr>
  <tr>
    <th><code>open_telemetry_tracing</code></th>
    <td>Settings: <code>endpoint</code> (required), <code>service_name</code>, <code>headers</code>, <code>resource_attributes</code>, and <code>tracestate</code> when available for the organization. Map values must be strings.</td>
  </tr>
  <tr>
    <th><code>event_log_api</code></th>
    <td>Available only when enabled for the organization. Settings: <code>events</code>.</td>
  </tr>
</tbody>
</table>

## Update a notification service

Updates only the fields in the request. Omitted top-level fields and settings remain unchanged.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -X PATCH "https://api.buildkite.com/v2/organizations/{org.slug}/services/{uuid}" \
  -d '{
    "description": "Production deploy notifications",
    "scope": "some_projects",
    "scope_uuids": ["16f3b56f-4934-4546-923c-287859851332"],
    "build_states": {
      "build_failed": true,
      "build_fixed": true
    }
  }'
```

The request accepts the same optional properties as create. If supplied, `provider` must match the existing provider because a service's provider cannot be changed.

Some settings have additional update restrictions:

- Amazon EventBridge `aws_region` and `aws_account_id` are create-only.
- A webhook can be upgraded to the latest payload `version`, but cannot be downgraded.
- OAuth credentials and provider-managed metadata cannot be changed.
- A Slack webhook URL connected using the Buildkite interface cannot be changed.

Resending unchanged restricted or masked values from a get response is allowed, so a get-update round trip does not overwrite secrets.

Required scope: `write_notification_services`

Success response: `200 OK`

Error responses: `404 Not Found` when the service is not visible, or `422 Unprocessable Entity` when the update is invalid.

## Delete a notification service

Deletes a notification service.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/services/{uuid}"
```

Required scope: `write_notification_services`

Success response: `204 No Content`

Error responses: `404 Not Found` when the service is not visible, or `422 Unprocessable Entity` when Buildkite cannot remove the provider configuration.

## Enable a notification service

Enables a notification service and clears any previous disabled or broken state. The response contains the updated notification service object.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/services/{uuid}/enable"
```

Required scope: `write_notification_services`

Success response: `200 OK`

Error response: `404 Not Found` when the service is not visible.

## Disable a notification service

Disables a notification service. The response contains the updated notification service object.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/services/{uuid}/disable"
```

Required scope: `write_notification_services`

Success response: `200 OK`

Error response: `404 Not Found` when the service is not visible.
