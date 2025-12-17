# Portal API rate limits

To ensure stability and prevent excessive or abusive calls to the server, Buildkite imposes a limit on the number of portal API requests that can be made within a minute. These limits apply to all portal API endpoints within an organization.

## Rate limits

Buildkite imposes a rate limit of 200 requests per minute for each Buildkite organization. This is the cumulative limit of all API requests made using a portal token as well as users-scoped portal tokens in an organization.

## Checking rate limit details

The rate limit status is available in the following response headers of each API call.

- `RateLimit-Remaining` - The remaining requests that can be made within the current time window.
- `RateLimit-Limit` - The current rate limit imposed on your organization.
- `RateLimit-Reset` - The number of seconds remaining until a new time window is started and limits are reset.
- `Ratelimit-Scope` - This will be set as `portal` for all portal requests and helps identify different types of rate limits.

For example, the following headers show a situation where 180 requests can still be made in the current window, with a limit of 200 requests per minute imposed on the organization, and 42 seconds before a new time window begins.

```js
RateLimit-Remaining: 180
RateLimit-Limit: 200
RateLimit-Reset: 42
Ratelimit-Scope: 'portal'
```

## Exceeding the rate limit

Once the rate limit is exceeded, subsequent API requests will return a 429 HTTP status code, and the `RateLimit-Remaining` header will be 0. You should not make any further requests until the `RateLimit-Reset` specifies a new availability window.
