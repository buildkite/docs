# Notification services

The notification services API endpoints let you manage your organization's notification services over REST.

Notification services deliver build notifications to destinations such as Slack, webhooks, and Datadog. See [integrations](/docs/pipelines/integrations) for setup guides.

## Enable a notification service

Enables a notification service. If the service was previously disabled automatically because of delivery failures (a _broken_ service), this also clears the broken state and any associated error message.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/services/{uuid}/enable"
```

Returns the updated notification service.

Required scope: `write_notification_services`

Success response: `200 OK`

An audit event is recorded for the enabling actor.

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The token does not have the <code>write_notification_services</code> scope, or the authenticated user does not have the <code>change_services</code> permission.</td>
  </tr>
  <tr>
    <th><code>404 Not Found</code></th>
    <td>The service does not exist, belongs to another organization, or is not visible through the REST API (for example, internal dispatch services).</td>
  </tr>
</tbody>
</table>

## Disable a notification service

Disables a notification service and records the disabling user.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/services/{uuid}/disable"
```

Returns the updated notification service.

Required scope: `write_notification_services`

Success response: `200 OK`

An audit event is recorded for the disabling actor.

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The token does not have the <code>write_notification_services</code> scope, or the authenticated user does not have the <code>change_services</code> permission.</td>
  </tr>
  <tr>
    <th><code>404 Not Found</code></th>
    <td>The service does not exist, belongs to another organization, or is not visible through the REST API (for example, internal dispatch services).</td>
  </tr>
</tbody>
</table>
