# Rate limits API

The rate limits API endpoint allows you to query your organization's current rate limit status for both [REST API](/docs/apis/rest-api) and [GraphQL API](/docs/apis/graphql-api) usage.

## Get rate limit status

Returns the current rate limit status for an organization, covering both [REST API](/docs/apis/rest-api) and [GraphQL API](/docs/apis/graphql-api) rate limits.

```bash
curl -H "Authorization: Bearer {api-token}" \
  https://api.buildkite.com/v2/organizations/{organization.slug}/rate-limit
```

```json
{
  "scopes": {
    "rest": {
      "limit": 200,
      "current": 5,
      "reset": 60,
      "reset_at": "2025-12-02T05:30:00Z",
      "enforced": true
    },
    "graphql": {
      "limit": 50000,
      "current": 1000,
      "reset": 300,
      "reset_at": "2025-12-02T05:35:00Z",
      "enforced": true
    }
  }
}
```

Required scope: `read_accounts`

Success response: `200 OK`

## Response fields

The response contains two scopes: `rest` for [REST API](/docs/apis/rest-api) limits and `graphql` for [GraphQL API](/docs/apis/graphql-api) limits.

### REST scope

The `rest` scope tracks REST API request limits.

Field | Type | Description
----- | ---- | -----------
`limit` | integer | Maximum requests allowed per window
`current` | integer | Number of requests made in the current window
`reset` | integer | Seconds until the rate limit window resets
`reset_at` | string | ISO 8601 timestamp when the rate limit window resets
`enforced` | boolean | Whether rate limiting is currently enforced for this organization
{: class="responsive-table"}

The REST API rate limit window is 60 seconds.

### GraphQL scope

The `graphql` scope tracks GraphQL API [complexity limits](/docs/apis/graphql/graphql-resource-limits#rate-limits-time-based-rate-limit).

Field | Type | Description
----- | ---- | -----------
`limit` | integer | Maximum complexity points allowed per window
`current` | integer | Complexity points used in the current window
`reset` | integer | Seconds until the rate limit window resets
`reset_at` | string | ISO 8601 timestamp when the rate limit window resets
`enforced` | boolean | Whether rate limiting is currently enforced for this organization
{: class="responsive-table"}

The GraphQL rate limit window is 300 seconds (five minutes).
