
# REST API rate limits

To ensure stability and prevent excessive or abusive calls to the server, Buildkite imposes limits on the number of REST API requests that can be made within a minute. These limits apply to the Pipelines REST API as well as the Analytics REST API.

The REST API enforces two layers of rate limits: an [organization-level limit](#organization-rate-limit) shared across all users, and a [per-user limit](#per-user-rate-limits) scoped to each authenticated user. A request is rejected if _either_ limit is exceeded.

> 📘 New: per-user rate limits
> Buildkite now enforces per-user rate limits in addition to existing organization-level limits. Each authenticated user has their own rate limit of 50 requests per minute, tracked independently from the organization's shared quota.

## Organization rate limit

Buildkite imposes a rate limit of 200 requests per minute for each organization. This is the cumulative limit of all API requests made by users in an organization.

> 📘 Buildkite MCP server requests
> Requests to the Buildkite REST API made through the [Buildkite MCP server](/docs/apis/mcp-server) are handled differently based on whether you're using the [remote](/docs/apis/mcp-server#types-of-mcp-servers-remote-mcp-server) or [local](/docs/apis/mcp-server#types-of-mcp-servers-local-mcp-server) MCP server.
> The remote MCP server's requests are tracked through a separate per-user rate limit, which _does not_ count towards your Buildkite organization's REST API limit. See [Remote MCP server rate limits](/docs/apis/mcp-server/remote/rate-limits) for details.
> The local MCP server's requests, however, _do_ count towards your Buildkite organization's REST API limit.

## Per-user rate limits

In addition to the organization-level limit, Buildkite enforces a per-user rate limit on REST API requests. This limit prevents a single user from consuming the entire organization's API quota.

Per-user limits are evaluated for the authenticated user associated with the API access token. The default per-user limit is 50 requests per minute.

A request counts towards both the per-user limit and the [organization-level limit](#organization-rate-limit). The request is rejected with a `429` status code if either limit is exceeded. The `RateLimit-Scope` response header indicates which limit was reached. See [Exceeding the rate limit](#exceeding-the-rate-limit) for details.

You can view the per-user limits that apply to your organization on the [**Service Quotas** page](/docs/platform/limits#viewing-your-organizations-service-quotas) in **Organization Settings**.

## Checking rate limit details

The rate limit status is available in the following response headers of each API call.

- `RateLimit-Remaining`: The remaining requests that can be made within the current time window.
- `RateLimit-Limit`: The current rate limit.
- `RateLimit-Reset`: The number of seconds remaining until a new time window is started and limits are reset.
- `RateLimit-Scope`: The scope of the rate limit that applies to the current response. Either `organization` or `user`.

The response headers reflect whichever limit (organization or per-user) is _closest_ to being exhausted. Use the `RateLimit-Scope` header to determine which limit the remaining values refer to.

For example, the following headers show a per-user rate limit with 35 requests remaining, resetting in 42 seconds:

```js
RateLimit-Remaining: 35
RateLimit-Limit: 50
RateLimit-Reset: 42
RateLimit-Scope: user
```

The following headers show an organization-level rate limit with 180 requests remaining:

```js
RateLimit-Remaining: 180
RateLimit-Limit: 200
RateLimit-Reset: 42
RateLimit-Scope: organization
```

### Using the rate limit API

You can also programmatically query your organization's rate limit status using the dedicated rate limit endpoint. See the [rate limit endpoint documentation](/docs/apis/rest-api/organizations/rate-limits) for details on retrieving comprehensive rate limit information for both REST API and GraphQL API usage.

## Exceeding the rate limit

Once a rate limit is exceeded, subsequent API requests return a `429` HTTP status code, and the `RateLimit-Remaining` header is `0`. You should not make any further requests until the `RateLimit-Reset` specifies a new availability window.

The `429` response body includes additional context about which limit was exceeded:

```json
{
  "message": "You have exceeded your API rate limit. Please wait 42 seconds before making more requests.",
  "scope": "user",
  "limit": 50,
  "current": 55,
  "reset": 42
}
```

The `scope` field indicates whether the `organization` or `user` limit was exceeded.

## Best practices to avoid rate limits

To ensure the smooth functioning and efficient use of the API, design your client application with the following best practices in mind:

- **Distribute load across tokens:** If you have multiple automated processes, use separate API tokens so that their usage is tracked independently against per-user limits.
- Implement appropriate pagination techniques when querying data.
- Use caching strategies to avoid excessive calls to the Buildkite API.
- Regulate the rate of your requests to ensure smoother distribution by using strategies such as queues or scheduling API calls at appropriate intervals.
- Use metadata about your API usage, including rate limit status, to manage behavior dynamically.
- Be aware of retries, errors, and loops when designing your application, as they can easily accumulate and use up allocated quotas.
