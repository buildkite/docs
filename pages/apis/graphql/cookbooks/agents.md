# Agents

A collection of common tasks with agents using the GraphQL API.

You can test out the Buildkite GraphQL API using the [Buildkite explorer](https://graphql.buildkite.com/explorer). This includes built-in documentation under the _Docs_ panel.

## Get a list of agent token IDs

Get the first five agent token IDs for an organization.

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

## Search for agents in an organization

```graphql
query SearchAgent {
  organization(slug: "organization-slug") {
    agents(first: 500, search: "search-string") {
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

## Revoke an agent token

Revoking an agent token means no new agents can start using the token. It does not affect any connected agents.

First, get the token ID. You can find it in the Buildkite dashboard, in _Agents_ > _Reveal Agent Token_, or you can retrieve a list of agent token IDs using this query:

```graphql
query GetAgentTokenID {
  organization(slug: "organization-slug") {
    agentTokens(first: 50) {
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

Then, using the token ID, revoke the agent token:

```graphql
mutation {
  agentTokenRevoke(input: { id: "token-id", reason: "A reason" }) {
    agentToken {
      description
      revokedAt
      revokedReason
    }
  }
}
```
