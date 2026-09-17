# Organization usage API

The organization usage API returns the billable active-user count shown on the organization's **Usage > Platform** page.

Any organization member can use this endpoint. The API access token must include the `read_organizations` scope and grant access to the requested organization.

## Get organization usage

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/usage"
```

```json
{
  "active_users_count": 1842
}
```

Required scope: `read_organizations`

Success response: `200 OK`

The `active_users_count` value is the number of distinct billable users active during the current Usage summary period. This is the same period displayed on the Usage page. For organizations with annual subscriptions, the summary period includes the current calendar month and the previous six calendar months, rather than the full annual billing period.

For a billing parent organization, the count includes activity from its linked billing child organizations. A user active in more than one linked organization is counted once.

## Response fields

Field | Type | Description
----- | ---- | -----------
`active_users_count` | integer | Number of distinct billable users active during the current Usage summary period.
{: class="table table--no-wrap"}

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
