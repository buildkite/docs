# Audit events API

The audit events API endpoint lets you retrieve audit log events for your organization.

> 📘 Enterprise plan feature
> The audit log is only available to Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan, and is only accessible to Buildkite organization administrators.

Audit events are system-generated records of activity within a Buildkite organization. The API provides read-only access — audit events cannot be created or modified using the API.

The audit events API requires the `read_audit_events` [OAuth scope](/docs/apis/managing-api-tokens#token-scopes).

## List audit events

Returns a [paginated list](<%= paginated_resource_docs_url %>) of audit events for an organization, ordered from newest to oldest.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/audit_events"
```

```json
[
  {
    "uuid": "0191e71a-552b-7be5-8a3d-8e0fc2c84e52",
    "graphql_id": "QXVkaXRFdmVudC0tLTAxOTFlNzFhLTU1MmItN2JlNS04YTNkLThlMGZjMmM4NGU1Mg==",
    "type": "OrganizationUpdatedEvent",
    "occurred_at": "2024-11-12T09:15:04.000Z",
    "actor": {
      "type": "User",
      "uuid": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
      "name": "Sam Kim"
    },
    "subject": {
      "type": "Organization",
      "uuid": "bb3125de-4dc9-44cf-ad18-65d2b71a5a34",
      "name": "acme-inc"
    },
    "context": {
      "type": "WebContext",
      "request_ip": "1.2.3.4",
      "request_user_agent": "Mozilla/5.0"
    },
    "data": {},
    "url": "https://api.buildkite.com/v2/organizations/acme-inc/audit_events/0191e71a-552b-7be5-8a3d-8e0fc2c84e52"
  }
]
```

Required scope: `read_audit_events`

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The organization's plan does not include audit logging, or the token does not have the <code>read_audit_events</code> scope.</td>
  </tr>
</tbody>
</table>

## Get an audit event

Returns a single audit event by UUID.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/audit_events/{uuid}"
```

```json
{
  "uuid": "0191e71a-552b-7be5-8a3d-8e0fc2c84e52",
  "graphql_id": "QXVkaXRFdmVudC0tLTAxOTFlNzFhLTU1MmItN2JlNS04YTNkLThlMGZjMmM4NGU1Mg==",
  "type": "OrganizationUpdatedEvent",
  "occurred_at": "2024-11-12T09:15:04.000Z",
  "actor": {
    "type": "User",
    "uuid": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "name": "Sam Kim"
  },
  "subject": {
    "type": "Organization",
    "uuid": "bb3125de-4dc9-44cf-ad18-65d2b71a5a34",
    "name": "acme-inc"
  },
  "context": {
    "type": "WebContext",
    "request_ip": "1.2.3.4",
    "request_user_agent": "Mozilla/5.0"
  },
  "data": {},
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/audit_events/0191e71a-552b-7be5-8a3d-8e0fc2c84e52"
}
```

Required scope: `read_audit_events`

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>404 Not Found</code></th>
    <td>The audit event UUID does not exist or belongs to a different organization.</td>
  </tr>
</tbody>
</table>

## Response fields

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>uuid</code></th>
    <td>UUID of the audit event.</td>
  </tr>
  <tr>
    <th><code>graphql_id</code></th>
    <td>The GraphQL ID of the audit event. Use this to look up the event using the <a href="/docs/apis/graphql-api">GraphQL API</a>.</td>
  </tr>
  <tr>
    <th><code>type</code></th>
    <td>The event type. See <a href="/docs/platform/audit-log#logged-events">logged events</a> for a full list.</td>
  </tr>
  <tr>
    <th><code>occurred_at</code></th>
    <td>ISO 8601 timestamp of when the event occurred.</td>
  </tr>
  <tr>
    <th><code>actor</code></th>
    <td>The entity that triggered the event. Contains <code>type</code>, <code>uuid</code>, and <code>name</code>. May be <code>null</code> for system-generated events.</td>
  </tr>
  <tr>
    <th><code>subject</code></th>
    <td>The entity the event acted upon. Contains <code>type</code>, <code>uuid</code>, and <code>name</code>.</td>
  </tr>
  <tr>
    <th><code>context</code></th>
    <td>Request context for the event. Contains <code>type</code> and additional fields depending on the context type, such as <code>request_ip</code>, <code>request_user_agent</code>, or agent connection details. May be <code>null</code>.</td>
  </tr>
  <tr>
    <th><code>data</code></th>
    <td>Event-specific data. The structure varies by event type.</td>
  </tr>
  <tr>
    <th><code>url</code></th>
    <td>The canonical API URL for this audit event.</td>
  </tr>
</tbody>
</table>
