# Audit events API

The audit events API endpoint lets you retrieve audit log events for your organization.

> 📘 Enterprise plan feature
> The audit log is only available to Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan, and is only accessible to Buildkite organization administrators.

Audit events are system-generated records of activity within a Buildkite organization. The API provides read-only access. You cannot create or modify audit events using the API.

The audit events API requires the `read_audit_events` [OAuth scope](/docs/apis/managing-api-tokens#token-scopes).

## List audit events

Returns a [paginated list](<%= paginated_resource_docs_url %>) of audit events for an organization, ordered from newest to oldest.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/audit_events"
```

```json
{
  "items": [
    {
      "uuid": "01931fa7-b1c0-7abc-8abc-0123456789ab",
      "graphql_id": "QXVkaXRFdmVudC0tLTAxOTMxZmE3LWIxYzAtN2FiYy04YWJjLTAxMjM0NTY3ODlhYg==",
      "type": "OrganizationUpdatedEvent",
      "occurred_at": "2024-11-12T09:15:04.000Z",
      "actor": {
        "type": "User",
        "uuid": "01234567-89ab-4cde-8f01-23456789abcd",
        "name": "Example User"
      },
      "subject": {
        "type": "Organization",
        "uuid": "12345678-9abc-4def-8012-3456789abcde",
        "name": "acme-inc"
      },
      "context": {
        "type": "WebContext",
        "request_ip": "192.0.2.1",
        "request_user_agent": "Mozilla/5.0"
      },
      "data": {},
      "url": "https://api.buildkite.com/v2/organizations/acme-inc/audit_events/01931fa7-b1c0-7abc-8abc-0123456789ab"
    }
  ],
  "links": {
    "self": "https://api.buildkite.com/v2/organizations/acme-inc/audit_events?per_page=30",
    "next": "https://api.buildkite.com/v2/organizations/acme-inc/audit_events?per_page=30&after=eyJvY2N1cnJlZF9hdCI6Ii4uLiJ9"
  }
}
```

The response body contains the following pagination fields:

- `items`: The audit events on the current page.
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

Required scope: `read_audit_events`

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>400 Bad Request</code></th>
    <td>The request supplies both cursor parameters, an invalid cursor, or a <code>per_page</code> value outside the supported range.</td>
  </tr>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The organization's plan does not include audit logging, the user cannot view the audit log, or the token does not have the <code>read_audit_events</code> scope.</td>
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
  "uuid": "01931fa7-b1c0-7abc-8abc-0123456789ab",
  "graphql_id": "QXVkaXRFdmVudC0tLTAxOTMxZmE3LWIxYzAtN2FiYy04YWJjLTAxMjM0NTY3ODlhYg==",
  "type": "OrganizationUpdatedEvent",
  "occurred_at": "2024-11-12T09:15:04.000Z",
  "actor": {
    "type": "User",
    "uuid": "01234567-89ab-4cde-8f01-23456789abcd",
    "name": "Example User"
  },
  "subject": {
    "type": "Organization",
    "uuid": "12345678-9abc-4def-8012-3456789abcde",
    "name": "acme-inc"
  },
  "context": {
    "type": "WebContext",
    "request_ip": "192.0.2.1",
    "request_user_agent": "Mozilla/5.0"
  },
  "data": {},
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/audit_events/01931fa7-b1c0-7abc-8abc-0123456789ab"
}
```

Required scope: `read_audit_events`

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The organization's plan does not include audit logging, the user cannot view the audit log, or the token does not have the <code>read_audit_events</code> scope.</td>
  </tr>
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
    <td>The event type, in class-style form (for example, <code>OrganizationUpdatedEvent</code>). See <a href="/docs/platform/audit-log#logged-events">logged events</a> for the full set of activities that are recorded. That list uses the audit log search names (for example, <code>ORGANIZATION_UPDATED</code>), which are the uppercase, underscore-separated form of each type value with the <code>Event</code> suffix removed.</td>
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
