
# REST API rate limits

To ensure stability and prevent excessive or abusive calls to the server, Buildkite imposes limits on the number of REST API requests that can be made within a minute. These limits apply to the Pipelines REST API as well as the Analytics REST API.

The REST API enforces two rate limits, and a request is rejected if either is exceeded:

- An [organization-level limit](#organization-rate-limit) shared across all users in the organization.
- A [per-user limit](#per-user-rate-limits). The default per-user limit is 50 requests per minute.

## Organization rate limit

Buildkite imposes a rate limit of 200 requests per minute for each organization. This is the cumulative limit of all API requests made by users in an organization.

> 📘 Buildkite MCP server requests
> Requests to the Buildkite REST API made through the [Buildkite MCP server](/docs/apis/mcp-server) are handled differently based on whether you're using the [remote](/docs/apis/mcp-server#types-of-mcp-servers-remote-mcp-server) or [local](/docs/apis/mcp-server#types-of-mcp-servers-local-mcp-server) MCP server.
> The remote MCP server's requests are tracked through a separate per-user rate limit, which _does not_ count towards your Buildkite organization's REST API limit. See [Remote MCP server rate limits](/docs/apis/mcp-server/remote/rate-limits) for details.
> The local MCP server's requests, however, _do_ count towards your Buildkite organization's REST API limit.

## Per-user rate limits

In addition to the organization-level limit, the REST API enforces a per-user rate limit on requests. This limit prevents a single user from consuming the entire organization's API quota.

The per-user limit is evaluated for the authenticated user associated with the API access token. The default per-user limit is 50 requests per minute.

A request counts towards both the per-user limit and the [organization-level limit](#organization-rate-limit). The request is rejected with a `429` status code if either limit is exceeded. Check the `RateLimit-User-Remaining` response header to monitor your per-user quota. See [Exceeding the rate limit](#exceeding-the-rate-limit) for details.

Organization administrators can view the per-user limits that apply to their organization on the [**Service Quotas**](https://buildkite.com/organizations/~/quotas) page, accessible from **Settings** > **Quotas** in the Buildkite interface.

## Checking rate limit details

Every API response includes two independent sets of rate limit headers: one for the [organization-level limit](#organization-rate-limit) and one for the [per-user limit](#per-user-rate-limits). You can monitor both limits independently and determine which one your application is closer to reaching.

The `RateLimit-*` headers track the organization's shared quota, while the `RateLimit-User-*` headers track the quota for the authenticated user making the request. A `429` response is returned if either limit is exceeded.

Organization-level headers:

- `RateLimit-Scope`: The scope of the organization-level rate limit. Set to `rest`.
- `RateLimit-Remaining`: The remaining requests within the current organization time window.
- `RateLimit-Limit`: The organization rate limit.
- `RateLimit-Reset`: The number of seconds remaining until the organization time window resets.

Per-user headers:

- `RateLimit-User-Scope`: The scope of the per-user rate limit. Set to `rest_user`.
- `RateLimit-User-Remaining`: The remaining requests for the authenticated user within the current time window.
- `RateLimit-User-Limit`: The per-user rate limit.
- `RateLimit-User-Reset`: The number of seconds remaining until the per-user time window resets.

For example, the following response headers show an authenticated user with 35 requests remaining against their per-user limit of 50. The organization has 80 requests remaining against its limit of 200, reflecting usage from multiple users across the organization.

```js
RateLimit-User-Scope: rest_user
RateLimit-User-Remaining: 35
RateLimit-User-Limit: 50
RateLimit-User-Reset: 42
RateLimit-Scope: rest
RateLimit-Remaining: 80
RateLimit-Limit: 200
RateLimit-Reset: 42
```

### Using the rate limit API

You can also programmatically query your organization's rate limit status using the dedicated rate limit endpoint. See the [rate limit endpoint documentation](/docs/apis/rest-api/organizations/rate-limits) for details on retrieving comprehensive rate limit information for both REST API and GraphQL API usage.

## Exceeding the rate limit

Once a rate limit is exceeded, subsequent API requests return a `429` HTTP status code. You should not make any further requests until the relevant `RateLimit-Reset` or `RateLimit-User-Reset` header specifies a new availability window.

The `429` response body includes additional context about which limit was exceeded:

```json
{
  "message": "You have exceeded your API rate limit. Please wait 42 seconds before making more requests.",
  "scope": "rest_user",
  "limit": 50,
  "current": 55,
  "reset": 42
}
```

The `scope` field indicates which limit was exceeded, for example `rest` for the organization limit or `rest_user` for the per-user limit.

## Best practices to avoid rate limits

To ensure the smooth functioning and efficient use of the API, design your client application with the following best practices in mind:

- Implement appropriate pagination techniques when querying data.
- Use caching strategies to avoid excessive calls to the Buildkite API.
- Regulate the rate of your requests to ensure smoother distribution by using strategies such as queues or scheduling API calls at appropriate intervals.
- Use metadata about your API usage, including rate limit status, to manage behavior dynamically.
- Consider all users making requests across your organization when designing your rate-limiting solution.
- Be aware of retries, errors, and loops when designing your application, as they can easily accumulate and use up allocated quotas.
