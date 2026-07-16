# Remote MCP server rate limits

Requests to the [Buildkite REST API](/docs/apis/rest-api) made through the [remote Buildkite MCP server](/docs/apis/mcp-server#types-of-mcp-servers-remote-mcp-server) are tracked under a separate rate limit of _50 requests per minute per user_. Unlike your Buildkite organization [REST API rate limit](/docs/apis/rest-api/rate-limits), this remote MCP server limit is scoped to each individual user.

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

When an AI client receives a `429` response:

1. Stop repeated or parallel retries.
1. Check `RateLimit-Scope` and `RateLimit-Reset`.
1. If `RateLimit-Scope` is `mcp`, wait for the number of seconds in `RateLimit-Reset`, then retry once.
1. Reduce the number of tool calls by narrowing the prompt, enabling only the required [toolsets](/docs/apis/mcp-server/tools/toolsets), or asking the client to summarize results in one pass.

Requests through the local MCP server and the remote API token pass-through endpoint can also be subject to other limits in the request path, including Buildkite REST API limits and limits applied by a web application firewall (WAF), customer-managed gateway, or proxy. Check which component returned the response before changing retry behavior. A `429` response with `RateLimit-Scope: mcp` came from the dedicated remote MCP limit. If the response does not include that header, inspect the REST API, WAF, gateway, and proxy response headers and logs to identify the limit. Do not configure immediate retries for `429` responses because they increase load without restoring capacity.

## Recovering from authentication errors

Repeated `401` responses do not recover through retries. Stop the workflow before it creates a retry storm, then use the recovery action for the authentication mode.

- **Remote OAuth:** Reconnect the MCP server or run the client's OAuth login action. If the access token reached its 12-hour lifetime, the client should refresh it automatically. A prompt to authorize again means the refresh token expired, was revoked, could not rotate, or is no longer available to the client.
- **API token pass-through or local MCP server:** Confirm that the API access token has not expired or been revoked, has access to the requested organization, and includes the scope required by the tool. Replace the token if it may have leaked.
- **Customer-managed gateway or proxy:** Confirm that the gateway forwards the bearer credential and does not cache a previous `401` response. Check the gateway's own session lifetime, refresh behavior, and rate limits separately from Buildkite limits.
- **Organization IP allowlist:** For the remote MCP server, confirm that the [Buildkite egress IP addresses are allowed](/docs/apis/mcp-server/remote/configuring-ai-tools#organization-ip-allowlist-considerations). For local or gateway traffic, allow the egress addresses of that deployment.

After correcting the credential or network policy, make one read-only request before restarting parallel or automated work.
