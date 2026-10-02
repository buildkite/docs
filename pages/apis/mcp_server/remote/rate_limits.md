# Remote MCP server rate limits

Requests to the [Buildkite REST API](/docs/apis/rest-api) made through the OAuth-based [remote Buildkite MCP server](/docs/apis/mcp-server#types-of-mcp-servers-remote-mcp-server) are tracked under a separate rate limit of _50 requests per minute per user_. Unlike your Buildkite organization [REST API rate limit](/docs/apis/rest-api/rate-limits), this remote MCP server limit is scoped to each individual user.

This limit applies to the OAuth endpoints, such as `https://mcp.buildkite.com/mcp` and `https://mcp.buildkite.com/mcp/readonly`. Your OAuth-based remote MCP server usage is independent of your Buildkite organization's standard REST API rate limit, whose quota is not affected by this usage.

Requests through the [API token pass-through endpoint](/docs/apis/mcp-server#api-token-pass-through-remote-mcp-server) (`https://mcp.buildkite.com/direct`) use your API access token, so they count toward your organization's REST API rate limit instead.

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
1. Find out which limit was exceeded. Most AI clients show the response body in their error output. A `scope` value of `mcp` means the remote MCP server limit was exceeded, and `reset` is the number of seconds until the limit resets. If your client, gateway, or proxy logs response headers, the `RateLimit-Scope` and `RateLimit-Reset` headers contain the same values. See [Checking rate limit details](#checking-rate-limit-details).
1. If the scope is `mcp`, wait for the number of seconds in `reset`, then retry once.
1. Reduce the number of tool calls by narrowing the prompt, enabling only the required [toolsets](/docs/apis/mcp-server/tools/toolsets), or asking the client to summarize results in one pass.

Requests can also be limited by other components in the request path:

- Requests through the local MCP server and the API token pass-through endpoint are subject to your organization's [REST API rate limits](/docs/apis/rest-api/rate-limits).
- The OAuth token endpoint that clients use to refresh their sessions rate limits requests for each client. A client that retries a failed refresh too quickly receives `429` responses and should wait before retrying.
- A web application firewall (WAF), customer-managed gateway, or proxy can apply its own limits.

If a `429` response doesn't identify the `mcp` scope, check the REST API, gateway, and proxy response headers and logs to identify which component returned it. Do not configure immediate retries for `429` responses because they increase load without restoring capacity.

## Recovering from authentication errors

Repeated `401` responses do not recover through retries. Stop the workflow before it creates a retry storm, then use the recovery action for the authentication mode.

- **Remote OAuth:** The client should refresh its one-hour access token automatically when it receives a `401` response. If the `401` responses continue, reconnect the MCP server or run the client's OAuth login action. A prompt to authorize again means the session ended, for example, because it wasn't used for 30 days, was revoked, or was revoked after a refresh token was reused. See [Session lifetime and re-authentication](/docs/apis/mcp-server#how-remote-oauth-works-session-lifetime-and-re-authentication).
- **API token pass-through or local MCP server:** Confirm that the API access token has not expired or been revoked, and has access to the requested organization. Replace the token if it may have leaked.
- **Customer-managed gateway or proxy:** Confirm that the gateway forwards the bearer credential and does not cache a previous `401` response. Check the gateway's own session lifetime, refresh behavior, and rate limits separately from Buildkite limits.
- **Organization IP allowlist:** For the remote MCP server, confirm that the [Buildkite egress IP addresses are allowed](/docs/apis/mcp-server/remote/configuring-ai-tools#organization-ip-allowlist-considerations). For local or gateway traffic, allow the egress addresses of that deployment.

If a tool call fails with a `403` error, the credential is valid, but either it lacks the scope that the tool requires or your Buildkite user doesn't have permission for the action. Re-authenticating doesn't fix this. Check the tool's required scope in the [MCP tools overview](/docs/apis/mcp-server/tools#available-mcp-tools). For API token pass-through or the local MCP server, use an API access token with that scope.

After correcting the credential or network policy, make one read-only request before restarting parallel or automated work.
