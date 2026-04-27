# GraphQL resource limits

To ensure that Buildkite stays stable for everyone, there are limits on how you can use the GraphQL API. These limits prevent excessive or abusive calls to the servers while still allowing you to use GraphQL endpoints in a wide range of ways.

The limits are based on query complexity, which is calculated from the requested resources. We recommend using techniques for limiting calls, pagination, caching, and retrying requests to lower the complexity of queries.

## Query complexity

Every field type in the schema has an integer cost assigned to it. The cost of the query is the sum of the cost of each field. Usually, running the query is the best way to know the true cost of the query.

A cost is based on what the field returns using the following values.

<table>
  <thead>
    <tr>
      <th>Field type</th>
      <th>Complexity value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Scalar</td>
      <td>0</td>
    </tr>
    <tr>
      <td>Enum</td>
      <td>0</td>
    </tr>
    <tr>
      <td>Object</td>
      <td>1</td>
    </tr>
    <tr>
      <td>Interface</td>
      <td>1</td>
    </tr>
    <tr>
      <td>Union</td>
      <td>1</td>
    </tr>
  <tbody>
</table>

Although these default costs are in place, Buildkite reserves the right to set different costs for specific fields.

## Complexity calculation

Buildkite calculates the cost of the query before and after the query execution.

### Requested complexity

The requested complexity is calculated based on the number of fields and objects requested. Usually, requesting a deeply nested query or excluding pagination details from connections results in high requested complexity.

A simple query like the following would incur more than 500 requested complexity points as the query asks for 503 possible resources.

```graphql
query RecentPipelineSlugs {
  organization(slug: "organization-slug") {  # 1 point
    pipelines(first: 500) {                  # 1 point
      edges {                                # 1 point
        node {                               # 500 points
          slug                               # 0 points
        }
      }
    }
  }
}
```

### Actual complexity

The actual complexity is based on the results returned after the query execution, since the connection fields can return fewer nodes than requested. Lowering the requested complexity usually lowers the actual complexity of queries.

Taking the same query used earlier, if the organization has only 10 pipelines, the actual complexity will be around 13.

```graphql
query RecentPipelineSlugs {
  organization(slug: "organization-slug") {  # 1 point
    pipelines(first: 500) {                  # 1 point
      edges {                                # 1 point
        node {                               # 10 points
          slug                               # 0 points
        }
      }
    }
  }
}
```

## Rate limits

Rate limits help keep the GraphQL API stable and performant by capping how many resources a single client or organization can consume at once. They also protect the platform from unintentional misuse, such as runaway automation or inefficient queries.

The GraphQL API enforces two rate limits, both measured in actual complexity points. A request is rejected if either is exceeded:

- An [organization-level limit](#rate-limits-organization-time-based-rate-limit) shared across all users in the organization.
- A [per-user limit](#rate-limits-per-user-rate-limit). The default per-user limit is 5,000 complexity points per five minutes.

There is also a [single query limit](#rate-limits-single-query-limit) that caps the maximum complexity of any individual query.

### Single query limit

Buildkite's API has a requested complexity limit of 50,000 for each individual query. This limit is enforced prior to query execution. The intention of this limit is to prevent users from requesting an excessive number of resources in a single query.

As a best practice, we recommend breaking up queries into smaller, more manageable chunks and utilizing pagination to navigate through the resulting list rather than relying on a single large query.

If the query exceeds the limit, the response will return HTTP 200 status code with the following error.

```json
{
  "errors": [
    {
      "message": "Query has complexity of 251503, which exceeds max complexity of 50000"
    }
  ]
}
```

### Organization-level time-based rate limit

To ensure optimal performance, a Buildkite organization can use up to 20,000 actual complexity points within a 5-minute period. By allowing a set number of actual complexity points, you have the flexibility to run queries of different sizes within a 5-minute window.

As a best practice, we recommend utilizing client-side strategies like the following to manage time-based rate limits:

- Caching to lower the number of API calls.
- Queues to schedule API calls.
- Pagination to only request the necessary data.

If an organization exceeds the 20,000 point limit, the response returns HTTP 429 status code with the following error.

```json
{
    "errors": [
        {
            "message": "Your organization has exceeded the limit of 20000 complexity points. Please try again in 187 seconds."
        }
    ]
}
```

### Per-user rate limit

In addition to the organization-level limit, the GraphQL API enforces a per-user complexity limit on requests. This limit prevents a single user from consuming the entire organization's GraphQL quota.

The per-user limit is evaluated for the authenticated user associated with the API access token. The default per-user limit is 5,000 complexity points per five minutes.

A request's complexity counts towards both the per-user limit and the [organization-level limit](#rate-limits-organization-time-based-rate-limit). The request is rejected with a `429` status code if either limit is exceeded. Check the `RateLimit-User-Remaining` response header to monitor your per-user quota.

If a user exceeds their per-user complexity limit, the response returns HTTP 429 status code with the following error.

```json
{
    "errors": [
        {
            "message": "You have exceeded your per-user limit of 5000 complexity points. Please try again in 187 seconds."
        }
    ]
}
```

Organization administrators can view the per-user limits that apply to their organization on the [**Service Quotas**](https://buildkite.com/organizations/~/quotas) page, accessible from **Settings** > **Quotas** in the Buildkite interface.

## Accessing limit details

You can access both time-based limits and query complexity information through the API. Accessing limit details will not incur any additional complexity points.

### Check time-based limits

Every GraphQL API response includes two independent sets of rate limit headers:

-  one for the [organization-level limit](#rate-limits-organization-time-based-rate-limit)
-  one for the [per-user limit](#rate-limits-per-user-rate-limit).

You can monitor both limits independently and determine which one your application is closer to reaching.

The `RateLimit-*` headers track the organization's shared complexity quota, while the `RateLimit-User-*` headers track the quota for the authenticated user making the request. A `429` response is returned if either limit is exceeded.

Organization-level headers:

| Header | Description |
|--------|-------------|
| `RateLimit-Remaining` | The remaining complexity points within the current organization time window. |
| `RateLimit-Limit` | The organization complexity limit for the time window. |
| `RateLimit-Reset` | The number of seconds remaining until the organization time window resets. |

Per-user headers:

| Header | Description |
|--------|-------------|
| `RateLimit-User-Remaining` | The remaining complexity points for the authenticated user within the current time window. |
| `RateLimit-User-Limit` | The per-user complexity limit for the time window. |
| `RateLimit-User-Reset` | The number of seconds remaining until the per-user time window resets. |

For example, the following response headers show an authenticated user with 3,500 complexity points remaining against their per-user limit of 5,000. The organization has 15,000 points remaining against its limit of 20,000:

```js
RateLimit-Remaining: 15000
RateLimit-Limit: 20000
RateLimit-Reset: 300
RateLimit-User-Remaining: 3500
RateLimit-User-Limit: 5000
RateLimit-User-Reset: 300
```

### View query complexity

The query complexity status is available in the following response headers of each GraphQL call:

| Header | Description |
|--------|-------------|
| `RateLimit-Complexity-Requested` | The requested complexity of the query, based on the maximum possible data that the query could return. |
| `RateLimit-Complexity-Actual` | The actual complexity based on the query response. |

If reading response headers is not possible, you can include the complexity data in the response body by setting the `Buildkite-Include-Query-Stats` request header to `true`. This returns the complexity data in the response like the following:

```json
{
  "data" : {
    "organization": {
      "name": "Buildkite"
    }
  },
  "stats" : {
    "requestedComplexity": 1910,
    "actualComplexity": 550
  }
}
```

## Best practices to avoid rate limit errors

Designing your client application with best practices in mind is the simplest way to avoid throttling errors. For example, you can stagger API requests in a queue and do other processing tasks while waiting for the next queued job to run.

Consider the following best practices when designing your API usage:

- Optimize the request by only requesting the data you require. We recommend using specific queries rather than a single all-purpose query.
- Always use appropriate `first` or `last` values when requesting connections. Not providing those may default to 500, which can increase the requested complexity exponentially. Some connections support a higher maximum — for example, `Build.metaData` accepts `first` values up to 10,000.
- Use strategies like caching for data you use often that is unlikely to be updated instead of constantly calling APIs.
- Regulate the rate of your requests for smoother distribution. You can do this using queues or scheduling API calls in appropriate intervals.
- Use metadata about your API usage, including rate limit status to manage the behavior dynamically.
- Think of rate limiting while designing your client application. Be mindful of retries, errors, loops, and the frequency of API calls.
