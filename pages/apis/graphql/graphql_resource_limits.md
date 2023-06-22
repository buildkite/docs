# GraphQL resource limits

To make sure that Buildkite stays stable for everyone, we have set some limits on our GraphQL API. These limits prevent excessive or abusive calls to our servers while still allowing API users to use GraphQL endpoints in a wide range of ways.

Our limits are based on the complexity of the query. We calculate complexity based on requested resources of the query and encourage developers to responsibly use techniques for limiting calls, pagination, caching and retrying requests to lower the complexity of the queries.


## Query complexity
Every field type in the schema has an integer cost assigned to it. The cost of the query is the sum of the cost of each field. Usually, running the query is the best way to know the true cost of the query.

A cost is based on what the field returns.

<table>
  <tr>
    <td>Scalar</td>
    <td>0 complexity point</td>
  </tr>
  <tr>
    <td>Enum</td>
    <td>0 complexity point</td>
  </tr>
  <tr>
    <td>Object</td>
    <td>1 complexity point</td>
  </tr>
  <tr>
    <td>Interface</td>
    <td>1 complexity point</td>
  </tr>
  <tr>
    <td>Union</td>
    <td>1 complexity point</td>
  </tr>
</table>

Although these default costs are in place, Buildkite also reserves the right to set manual costs to individual fields.


## Complexity calculation

Buildkite calculates the cost of the query before and after the query execution.

### Requested complexity
The requested complexity is based on the number of fields and objects requested. Usually, requesting a deeply nested query or excluding pagination details from connections results in high requested complexity.

A simple query like the following would incur more than 500 requested complexity points as the query asks for 503 possible resources.

```graphql
query RecentPipelineSlugs {
  organization(slug: "organization-slug") {  # 1 point
    pipelines(first: 500) {                  # 1 point
      edges {                                # 1 point
        node {                               # 500 points
          slug                               # 0 point
        }
      }
    }
  }
}
```

### Actual complexity
The actual complexity is based on the results returned after the query execution, since the connection fields can return fewer nodes than requested. Lowering requested complexity usually lowers the actual complexity of queries.

Taking the same query as above, if the organization has only 10 pipelines, the actual complexity will be around 13.

```graphql
query RecentPipelineSlugs {
  organization(slug: "organization-slug") {  # 1 point
    pipelines(first: 500) {                  # 1 point
      edges {                                # 1 point
        node {                               # 10 points
          slug                               # 0 point
        }
      }
    }
  }
}
```

<!-- How to show example -->



## Rate limits
Buildkite has implemented two distinct limits to our GraphQL endpoints. These limits play a critical role in ensuring that our platform operates smoothly and efficiently, while also minimising the risk of unnecessary downtime or system failures.

By enforcing these limits, we can effectively manage and allocate the necessary resources for our GraphQL endpoints.

### Single query limit

Buildkite's API has a requested complexity limit of 50,000 for each individual query. This limit is enforced prior to query execution. The intention of this limit is to prevent users from requesting an excessive number of resources in a single query.

As a best practice, we recommend breaking up queries into smaller, more manageable chunks and utilizing pagination to navigate through the resulting list, rather than relying on a single large query.

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


### Time based rate limit

To ensure optimal performance, an organization can use up to 20,000 actual complexity points within a 5 minute period. By allowing a set number of actual complexity points, we provide organizations flexibility to run queries of different sizes within a 5 minute window.

As a best practice, we recommend utilizing client size strategies like caching to lower the number of API calls, queues to schedule API calls or proper use of pagination to only request necessary data to manage time based rate limits.

If an organization exceeds the 20,000 points limit, the response will return HTTP 429 status code with the following error.

```json
{
    "errors": [
        {
            "message": "Your organization has exceeded the limit of 20000 complexity points. Please try again in 187 seconds."
        }
    ]
}
```


## Accessing limits details

### HTTP headers

We provide rate limit status on response headers of each GraphQL call. We have 3 rate limit related headers

```js
RateLimit-Remaining: 20
RateLimit-Limit: 20000
RateLimit-Reset: 120
```

`RateLimit-Remaining` provides the remaining complexity left within the current time window.  
`RateLimit-Limit` is the complexity limit for the time window.  
`RateLimit-Limit` is the number of seconds remaining until a new time window is started and the limits are reset.  


### Response body

You can include the header  `Buildkite-Include-Query-Stats` to the GraphQL request, which will return the complexity data along with the GraphQL response.

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

Designing your client application with best practices in mind is the best way to avoid throttling errors. For example, you can stagger API requests in a queue and do other processing tasks while waiting for the next queued job to run.  

Consider the following best practices when designing the app:

* Optimize the request by only requesting data your app requires. We recommend using specific queries rather than a single all-purpose query.
* Always use appropriate `first` or `last` values when requesting connections. Not providing those may default to 500 which can increase the requested complexity exponentially.
* Use strategies like caching for data that you use often and are unlikely to be updated instead of calling APIs constantly.
* Regulate the rate of your requests for smoother distribution. These can be done by using queues or scheduling API calls in appropriate intervals.
* Use metadata about your app’s API usage, including rate limit status to manage app’s behaviour dynamically.
* Think of rate limiting while designing your client application. Be mindful of retries, errors, loops and the frequency of API calls.
