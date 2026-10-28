# Organization rate limits API

The organization rate limits API endpoint allows you to obtain a Buildkite organization's current [REST API](/docs/apis/rest-api) and [GraphQL API](/docs/apis/graphql-api) rate limit status, as well as the authenticated caller's own per-user REST and [remote MCP server](/docs/apis/mcp-server/remote/rate-limits) rate limit status.

## Get rate limits

Returns the current [REST API](/docs/apis/rest-api) and [GraphQL API](/docs/apis/graphql-api) rate limits for a Buildkite organization, along with the authenticated caller's per-user REST and remote MCP server rate limit status.

Requests to this endpoint don't count towards your organization's REST API rate limit, your per-user rate limit, or your remote MCP server rate limit.

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
    "rest_user": {
      "limit": 50,
      "current": 12,
      "reset": 35,
      "reset_at": "2025-12-02T05:30:00Z",
      "enforced": true
    },
    "mcp": {
      "limit": 50,
      "current": 3,
      "reset": 12,
      "reset_at": "2025-12-02T05:30:17Z",
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

Required scope: `read_organizations`

Success response: `200 OK`

## Response fields

The response contains a `scopes` object with up to four scopes: `rest` for [organization REST API](#response-fields-rest-api) limits, `rest_user` for the [caller's per-user REST API](#response-fields-caller-rest) limits, `mcp` for the [caller's remote MCP server](#response-fields-caller-mcp) limits, and `graphql` for [GraphQL API](#response-fields-graphql-api) limits.

`rest_user` and `mcp` are `null` for tokens that aren't attributed to an individual user, such as compute tokens, since there's no per-user bucket to report for those tokens.

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

### Caller REST

The `rest_user` scope provides the authenticated caller's current [per-user REST API](/docs/apis/rest-api/rate-limits#per-user-rate-limits) rate limit status, scoped to the organization in the request URL.

Field | Type | Description
----- | ---- | -----------
`limit` | integer | Maximum requests allowed in a time window.
`current` | integer | Number of requests made by the caller in the current time window.
`reset` | integer | Seconds remaining until the current time window resets to zero.
`reset_at` | string | ISO 8601 timestamp when the current time window resets to zero.
`enforced` | boolean | Indicates if rate limiting is currently enforced for this caller.
{: class="responsive-table"}

The caller REST rate limit time window is 60 seconds. A request counts towards both `rest_user` and the organization-level `rest` scope.

### Caller MCP

The `mcp` scope provides the authenticated caller's current [remote MCP server](/docs/apis/mcp-server/remote/rate-limits) rate limit status. Unlike the other scopes, this limit applies to the caller across all Buildkite organizations, not just the organization in the request URL.

Field | Type | Description
----- | ---- | -----------
`limit` | integer | Maximum requests allowed in a time window.
`current` | integer | Number of requests made by the caller in the current time window.
`reset` | integer | Seconds remaining until the current time window resets to zero.
`reset_at` | string | ISO 8601 timestamp when the current time window resets to zero.
`enforced` | boolean | Indicates if rate limiting is currently enforced for this caller.
{: class="responsive-table"}

The caller MCP rate limit time window is 60 seconds. Requests made through the remote MCP server count towards `mcp` instead of the baseline `rest` and `rest_user` scopes.

### GraphQL API

The `graphql` scope provides current GraphQL API [complexity points](/docs/apis/graphql/graphql-resource-limits#rate-limits-organization-level-time-based-rate-limit) for the Buildkite organization.

Field | Type | Description
----- | ---- | -----------
`limit` | integer | Maximum complexity points allowed in a time window.
`current` | integer | Complexity points used in the current time window.
`reset` | integer | Seconds remaining until the current time window resets to zero.
`reset_at` | string | ISO 8601 timestamp when the current time window resets to zero.
`enforced` | boolean | Indicates if rate limiting is currently enforced for this Buildkite organization.
{: class="responsive-table"}

The GraphQL API rate limit time window is 300 seconds (five minutes).

## Per-user and remote MCP rate limits

In addition to the organization-level limits above, Buildkite enforces a [per-user rate limit](/docs/apis/rest-api/rate-limits#per-user-rate-limits) on REST and GraphQL API requests, and a separate [remote MCP server rate limit](/docs/apis/mcp-server/remote/rate-limits) on requests made through the remote MCP server. These limits prevent a single user from consuming the entire organization's API quota. The default per-user limit is 50 requests per minute for the REST API and 5,000 complexity points per 5 minutes for the GraphQL API. The default remote MCP server limit is 50 requests per minute per user.

This endpoint's `rest_user` and `mcp` scopes return the authenticated caller's current REST and remote MCP server status respectively. Caller status for the GraphQL per-user limit is not available through this endpoint. Instead, inspect the response headers on any REST or GraphQL API call:

- `RateLimit-User-Scope`: The scope of the per-user rate limit (`rest_user` or `graphql_user`).
- `RateLimit-User-Remaining`: The remaining requests or complexity points for the authenticated user.
- `RateLimit-User-Limit`: The per-user rate limit.
- `RateLimit-User-Reset`: The number of seconds remaining until the per-user time window resets.

These headers are returned alongside the organization-level `RateLimit-*` headers on every API response. Learn more in [REST API rate limits](/docs/apis/rest-api/rate-limits) and [GraphQL resource limits](/docs/apis/graphql/graphql-resource-limits#rate-limits-per-user-rate-limit).
