# Agents

A collection of common tasks with unclustered agents using the GraphQL API.

You can test out the Buildkite GraphQL API using the [Buildkite explorer](https://graphql.buildkite.com/explorer). This includes built-in documentation under the _Docs_ panel.

## Get a list of unclustered agent token IDs

Get the first five unclustered agent token IDs for an organization.

```graphql
query token {
  organization(slug: "organization-slug") {
    id
    name
    agentTokens(first: 5) {
      edges {
        node {
          id
          description
        }
      }
    }
  }
}
```

## Search for unclustered agents in an organization

```graphql
query SearchAgent {
   organization(slug:"organization-slug") {
    agents(first:500, search:"search-string") {
      edges {
        node {
          name
          hostname
          version
        }
      }
    }
  }
}
```

## Revoke an unclustered agent token

Revoking an unclustered agent token means no new agents can start using the token. It does not affect any connected agents.

First, retrieve a list of agent token IDs using this query to obtain the required token ID.

```graphql
query GetAgentTokenID {
  organization(slug: "organization-slug") {
    agentTokens(first:50) {
      edges {
        node {
          id
          uuid
          description
        }
      }
    }
  }
}
```

Then, using this token ID, revoke the agent token:

```graphql
mutation {
  agentTokenRevoke(input: {
    id: "token-id",
    reason: "A reason"
  }) {
    agentToken {
      description
      revokedAt
      revokedReason
    }
  }
}
```
