# Organization rate limits API

The organization rate limits API endpoint allows you to obtain a Buildkite organization's current [REST API](/docs/apis/rest-api) and [GraphQL API](/docs/apis/graphql-api) rate limit status.

## Get rate limits

Returns the current [REST API](/docs/apis/rest-api) and [GraphQL API](/docs/apis/graphql-api) rate limits for a Buildkite organization.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  https://api.buildkite.com/v2/organizations/{organization.slug}/rate_limit
```

```json
{
  "scopes": {
    "rest": {
      "limit": 200,
      "current": 5,
      "reset": 35,
      "reset_at": "2025-12-02T05:30:00Z",
      "enforced": true
    },
    "graphql": {
      "limit": 50000,
      "current": 1000,
      "reset": 263,
      "reset_at": "2025-12-02T05:34:52Z",
      "enforced": true
    }
  }
}
```

Required scope: `read_accounts`

Success response: `200 OK`

## Response fields

The response contains two JSON objects (or scopes)—`rest` for [REST API](#response-fields-rest-api) limits, and `graphql` for [GraphQL API](#response-fields-graphql-api) limits.

### REST API

The `rest` scope provides current REST API rate limits for the Buildkite organization.

Field | Type | Description
----- | ---- | -----------
`limit` | integer | Maximum requests allowed in a time window.
`current` | integer | Number of requests made in the current time window.
`reset` | integer | Seconds remaining until the current time window resets to zero.
`reset_at` | string | ISO 8601 timestamp when the current time window resets to zero.
`enforced` | boolean | Indicates if rate limiting is currently enforced for this Buildkite organization.
{: class="responsive-table"}

The REST API rate limit time window is 60 seconds.

### GraphQL API

The `graphql` scope provides current GraphQL API [complexity points](/docs/apis/graphql/graphql-resource-limits#rate-limits-time-based-rate-limit) for the Buildkite organization.

Field | Type | Description
----- | ---- | -----------
`limit` | integer | Maximum complexity points allowed in a time window.
`current` | integer | Complexity points used in the current time window.
`reset` | integer | Seconds remaining until the current time window resets to zero.
`reset_at` | string | ISO 8601 timestamp when the current time window resets to zero.
`enforced` | boolean | Indicates if rate limiting is currently enforced for this Buildkite organization.
{: class="responsive-table"}

This GraphQL API rate limit time window is 300 seconds (five minutes).
