# Remote MCP server rate limits

Requests to the [Buildkite REST API](/docs/apis/rest-api) made through the [remote Buildkite MCP server](/docs/apis/mcp-server#types-of-mcp-servers-remote-mcp-server) are tracked under a separate rate limit of _50 requests per minute per user_. Unlike your Buildkite organization [REST API rate limit](/docs/apis/rest-api/limits#rate-limits), this remote MCP server limit is scoped to each individual user.

Your remote Buildkite MCP server usage is independent of your Buildkite organization's standard REST API rate limit, whose quota is not affected by remote MCP server usage.

## Checking rate limit details

The rate limit status is available in the following response headers of each API call.

- `RateLimit-Remaining`: The remaining requests that can be made within the current time window.
- `RateLimit-Limit`: The current rate limit.
- `RateLimit-Reset`: The number of seconds remaining until a new time window is started and limits are reset.
- `RateLimit-Scope`: Set to `mcp` for all MCP server requests, identifying the type of rate limit applied.

For example, the following response headers from an MCP server request, show that 35 of the 50 per-user requests remain in the current window, with 28 seconds before a new time window begins.

```js
RateLimit-Remaining: 35
RateLimit-Limit: 50
RateLimit-Reset: 28
RateLimit-Scope: mcp
```

## Exceeding the rate limit

Once your Buildkite MCP server rate limit is exceeded, API requests made by the MCP server on your behalf fail with a `429` HTTP status code until the rate limit window is reset. The window resets after every 60 seconds, from which requests will work again.

The `429` response body includes additional context:

```json
{
  "message": "You have exceeded your API rate limit. Please wait 28 seconds before making more requests.",
  "scope": "mcp",
  "limit": 50,
  "current": 55,
  "reset": 28
}
```
