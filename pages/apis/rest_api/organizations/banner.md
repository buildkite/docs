# Organization banner API

The organization banner API lets you manage the [system banner](/docs/platform/team-management/system-banners) shown at the top of every page for members of a Buildkite organization. An organization has at most one active banner, so `PUT` creates the banner if none exists, or updates the existing one.

> 📘 Enterprise plan feature
> The system banners feature is only available to Buildkite customers on [Enterprise](https://buildkite.com/pricing) plans.

These endpoints require a `read_organization_settings` or `write_organization_settings` [access token scope](/docs/apis/managing-api-tokens#token-scopes), and the authenticated user must be a Buildkite organization administrator on a plan that includes system banners.

## Banner data model

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>uuid</code></th>
    <td>UUID of the banner.</td>
  </tr>
  <tr>
    <th><code>graphql_id</code></th>
    <td>The <a href="/docs/apis/graphql-api">GraphQL ID</a> of the banner.</td>
  </tr>
  <tr>
    <th><code>url</code></th>
    <td>The canonical API URL for this resource.</td>
  </tr>
  <tr>
    <th><code>message</code></th>
    <td>The banner message, shown to organization members. Supports Markdown.</td>
  </tr>
  <tr>
    <th><code>created_at</code></th>
    <td>ISO 8601 timestamp of when the banner was created.</td>
  </tr>
  <tr>
    <th><code>updated_at</code></th>
    <td>ISO 8601 timestamp of when the banner was last updated.</td>
  </tr>
</tbody>
</table>

## Get the banner

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/banner"
```

```json
{
  "uuid": "01a0fe3d-3faa-7ada-9168-23bc3e4f4788",
  "graphql_id": "T3JnYW5pemF0aW9uQmFubmVyLS0tMDFhMGZlM2QtM2ZhYS03YWRhLTkxNjgtMjNiYzNlNGY0Nzg4",
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/banner",
  "message": "Deploy freeze until Monday",
  "created_at": "2026-10-02T20:10:21.992Z",
  "updated_at": "2026-10-02T20:10:21.992Z"
}
```

Required scope: `read_organization_settings`

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The token does not have the <code>read_organization_settings</code> scope, the authenticated user is not an organization administrator, or the organization's plan does not include system banners.</td>
  </tr>
  <tr>
    <th><code>404 Not Found</code></th>
    <td>The organization has no active banner.</td>
  </tr>
</tbody>
</table>

## Create or update the banner

Creates the banner if the organization doesn't have one, or updates the existing banner's message. The response status indicates which happened.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/banner" \
  -d '{
    "message": "Deploy freeze until Monday"
  }'
```

```json
{
  "uuid": "01a0fe3d-3faa-7ada-9168-23bc3e4f4788",
  "graphql_id": "T3JnYW5pemF0aW9uQmFubmVyLS0tMDFhMGZlM2QtM2ZhYS03YWRhLTkxNjgtMjNiYzNlNGY0Nzg4",
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/banner",
  "message": "Deploy freeze until Monday",
  "created_at": "2026-10-02T20:10:21.992Z",
  "updated_at": "2026-10-02T20:10:21.992Z"
}
```

Request fields:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>message</code></th>
    <td>Required. The banner message to display to organization members. Must be a string of no more than 2,000 characters.</td>
  </tr>
</tbody>
</table>

Required scope: `write_organization_settings`

Success response: `201 Created` when a banner is created, `200 OK` when an existing banner is updated.

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The token does not have the <code>write_organization_settings</code> scope, the authenticated user is not an organization administrator, or the organization's plan does not include system banners.</td>
  </tr>
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td><code>message</code> is missing, isn't a string, is blank, or is longer than 2,000 characters.</td>
  </tr>
</tbody>
</table>

## Delete the banner

Removes the organization's active banner.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/banner"
```

Required scope: `write_organization_settings`

Success response: `204 No Content`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The token does not have the <code>write_organization_settings</code> scope, the authenticated user is not an organization administrator, or the organization's plan does not include system banners.</td>
  </tr>
  <tr>
    <th><code>404 Not Found</code></th>
    <td>The organization has no active banner.</td>
  </tr>
</tbody>
</table>
