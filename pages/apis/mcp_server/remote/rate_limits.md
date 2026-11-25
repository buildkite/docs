# Remote MCP server rate limits

Requests to the [Buildkite REST API](/docs/apis/rest-api) made with credentials issued through the remote MCP server's interactive OAuth flow count toward a separate limit of _50 requests per minute per user_. This quota is independent of standard REST API quotas.

Requests through the [API token pass-through endpoint](/docs/apis/mcp-server#api-token-pass-through-remote-mcp-server) (`/direct`) with a personal API token or a token issued by your token exchange application count toward [standard REST API limits](/docs/apis/rest-api/rate-limits). For organization-scoped requests made as a user, these include both the organization-wide limit and the per-user limit within that organization.

## Checking rate limit details

For requests subject to the separate MCP quota, rate limit status is available in the following REST API response headers.

- `RateLimit-Remaining`: The remaining requests that can be made within the current time window.
- `RateLimit-Limit`: The current rate limit.
- `RateLimit-Reset`: The number of seconds remaining until a new time window is started and limits are reset.
- `RateLimit-Scope`: Set to `mcp` for the separate MCP quota.

For example, the following response headers from an MCP server request, show that 35 of the 50 per-user requests remain in the current window, with 28 seconds before a new time window begins.

```js
RateLimit-Remaining: 35
RateLimit-Limit: 50
RateLimit-Reset: 28
RateLimit-Scope: mcp
```

You can also inspect your current remote MCP server rate limit status without making an MCP request, and without consuming any quota, using the `mcp` scope of the [organization rate limits endpoint](/docs/apis/rest-api/organizations/rate-limits#response-fields-caller-mcp).

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
1. Find out which limit was exceeded. If your client surfaces the REST API error, check the `scope` and `reset` fields. A scope of `mcp` identifies the separate MCP quota. If you have access to the REST API response headers, see [Checking rate limit details](#checking-rate-limit-details).
1. Wait for the indicated reset time before retrying. If no reset time is available, use a bounded retry with backoff.
1. Reduce the number of tool calls by narrowing the prompt, enabling only the required [toolsets](/docs/apis/mcp-server/tools/toolsets), or asking the client to summarize results in one pass.

Requests can also be limited by other components in the request path:

- The OAuth token endpoint that clients use to refresh their sessions can apply a separate rate limit. If refresh returns `429`, wait before trying again.
- A web application firewall (WAF), customer-managed gateway, or proxy can apply its own limits.

If a `429` response doesn't identify the `mcp` scope, check the REST API, gateway, and proxy response headers and logs to identify which component returned it. Do not configure immediate retries for `429` responses because they increase load without restoring capacity.

## Recovering from authentication errors

Repeated `401` responses do not recover through retries. Stop the workflow before it creates a retry storm, then use the recovery action for the authentication mode.

- **Remote OAuth:** If the client supports refresh, check whether it successfully renewed and saved its credentials. If refresh fails or the `401` responses continue, reconnect the MCP server or run the client's OAuth login action. See [Session lifetime and re-authentication](/docs/apis/mcp-server#how-remote-oauth-works-session-lifetime-and-re-authentication).
- **API token pass-through or local MCP server:** Confirm that the API access token has not expired or been revoked, and has access to the requested organization. Replace the token if it may have leaked.
- **Customer-managed gateway or proxy:** Confirm that the gateway forwards the bearer credential and does not cache a previous `401` response. Check the gateway's own session lifetime, refresh behavior, and rate limits separately from Buildkite limits.
- **Organization IP allowlist:** If the gateway forwards to the hosted MCP server, check the [Buildkite egress IP addresses](/docs/apis/mcp-server/remote/configuring-ai-tools#organization-ip-allowlist-considerations). If you run the MCP server yourself, check the egress addresses of that deployment.

If a tool call fails with a `403` error, check the response for the cause. Check the tool's required scope in the [MCP tools overview](/docs/apis/mcp-server/tools#available-mcp-tools), the user's permissions, and any applicable access policy before re-authenticating.

After correcting the credential or network policy, make one read-only request before restarting parallel or automated work.
