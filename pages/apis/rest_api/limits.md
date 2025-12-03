
# REST API rate limits

To ensure stability and prevent excessive or abusive calls to the server, Buildkite imposes a limit on the number of REST API requests that can be made within a minute. These limits apply to the Pipelines REST API as well as the Analytics REST API.

## Rate limits

Buildkite imposes a rate limit of 200 requests per minute for each organization. This is the cumulative limit of all API requests made by users in an organization.

## Checking rate limit details

The rate limit status is available in the following response headers of each API call.

- `RateLimit-Remaining` - The remaining requests that can be made within the current time window.
- `RateLimit-Limit` - The current rate limit imposed on your organization.
- `RateLimit-Reset` - The number of seconds remaining until a new time window is started and limits are reset.

For example, the following headers show a situation where 180 requests can still be made in the current window, with a limit of 200 requests a minute imposed on the organization, and 42 seconds before a new time window begins.

```js
RateLimit-Remaining: 180
RateLimit-Limit: 200
RateLimit-Reset: 42
```

### Using the rate limit API

You can also programmatically query your organization's rate limit status using the dedicated rate limit endpoint. See the [rate limit endpoint documentation](/docs/apis/rest-api/organizations/rate-limits) for details on retrieving comprehensive rate limit information for both REST API and GraphQL API usage.

## Exceeding the rate limit

Once the rate limit is exceeded, subsequent API requests will return a 429 HTTP status code, and the `RateLimit-Remaining` header will be 0. You should not make any further requests until the `RateLimit-Reset` specifies a new availability window.

## Best practices to avoid rate limits

To ensure the smooth functioning and efficient use of the API, we recommend you design your client application with the following best practices in mind:

- Implement appropriate pagination techniques when querying data.
- Use caching strategies to avoid excessive calls to the Buildkite API.
- Regulate the rate of your requests to ensure smoother distribution by using strategies such as queues or scheduling API calls at appropriate intervals.
- Utilize metadata about your API usage, including rate limit status, to manage behavior dynamically.
- Ensure you consider all users making requests across your organization in your rate-limiting solution.
- Be aware of retries, errors, and loops when designing your application, as they can easily accumulate and use up allocated quotas.
