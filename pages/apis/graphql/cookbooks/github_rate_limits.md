# GitHub rate limits

A collection of common tasks with GitHub rate limits using the GraphQL API.

<%= render_markdown partial: 'apis/graphql/cookbooks/graphql_console_link' %>

## List GitHub repository providers rate limits

Get all repository providers and their GitHub rate limits if applicable. These are the rate limits GitHub imposes on
the [Buildkite app for GitHub](/docs/pipelines/source-control/github#connect-your-buildkite-account-to-github-using-the-github-app), based on [GitHub's rate limits for their REST API](https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api?apiVersion=2022-11-28).

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

You can query a single repository provider's GitHub rate limit using the [OrganizationRepositoryProviderGitHub](/docs/apis/graphql/schemas/object/organizationrepositoryprovidergithub) [GraphQL ID](/docs/apis/graphql-api#graphql-ids) from the `getLimits` query [above](#list-github-repository-providers-rate-limits).

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
