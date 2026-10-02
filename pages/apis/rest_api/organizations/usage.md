# Organization usage API

The organization usage API returns the billable active-user count shown on a Buildkite organization's [**Usage > Platform**](https://buildkite.com/organizations/~/usage) page. Use this endpoint to monitor active-user counts programmatically, for example, to track usage against a contracted user allowance.

Any organization member can use this endpoint. The [API access token](/docs/apis/managing-api-tokens) must include the `read_organizations` scope and grant access to the requested organization.

## Get organization usage

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/usage"
```

```json
{
  "active_users_count": 42
}
```

Required scope: `read_organizations`

Success response: `200 OK`

## Response fields

Field | Type | Description
----- | ---- | -----------
`active_users_count` | integer | Number of distinct billable users active during the current usage summary period.
{: class="responsive-table"}

For a billing parent organization, the count includes activity from its linked billing child organizations. A user active in more than one linked organization is counted once.

## Usage period

The usage summary period matches the period shown on the organization's **Usage** page:

- **Monthly subscriptions**: The current billing period.
- **Annual subscriptions**: The current calendar month and the previous six calendar months, rather than the full annual billing period.

## Error responses

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The token does not have the <code>read_organizations</code> scope.</td>
  </tr>
  <tr>
    <th><code>404 Not Found</code></th>
    <td>The organization does not exist, or the authenticated user or token cannot access it.</td>
  </tr>
  <tr>
    <th><code>503 Service Unavailable</code></th>
    <td>Usage data is temporarily unavailable. Retry the request.</td>
  </tr>
</tbody>
</table>
