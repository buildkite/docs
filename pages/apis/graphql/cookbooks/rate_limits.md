# GitHub rate limits

A collection of common tasks with GitHub rate limits using the GraphQL API.

You can test out the Buildkite GraphQL API using the [Buildkite explorer](https://graphql.buildkite.com/explorer). This includes built-in documentation under the **Docs** panel.

## List GitHub repository providers rate limits

Get all repository providers and their GitHub rate limits if applicable. These are the rate limits GitHub imposes on
the [Buildkite app for GitHub](/docs/integrations/github#connect-your-buildkite-account-to-github-using-the-github-app) as [documented](https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api?apiVersion=2022-11-28)

```graphql
query getLimits {
  organization(slug: "organization-slug") {
    repositoryProviders {
      name
      ... on OrganizationRepositoryProviderGitHub {
        id
        name
        rateLimit {
          mostRecent {
            limit
            used
            remaining
            resetAt
          }
        }
      }
    }
  }
}
```

## Show single repository providers rate limits

Using the [OrganizationRepositoryProviderGitHub](/docs/apis/graphql/schemas/object/organizationrepositoryprovidergithub) [GraphQL ID](/docs/apis/graphql-api#graphql-ids) from the above `getLimits` query it is possible to
query a single repository providers GitHub rate limit.

```graphql
query getLimit {
  node(
    id: "U0NMU2VrxmljZS0tLT70NWE3Y9QyLWMzYzctQGZkZS1hmGE3LWFmIWVmMmA5ZmP4Ng=="
  ) {
    ... on OrganizationRepositoryProviderGitHub {
      name
      rateLimit {
        mostRecent {
          limit
          used
          remaining
          resetAt
        }
      }
    }
  }
}
```
