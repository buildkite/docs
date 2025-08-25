# Agents

A collection of common tasks with unclustered agents using the GraphQL API.

<%= render_markdown partial: 'apis/graphql/cookbooks/graphql_console_link' %>

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

## Stop an agent

First, get the agent's ID. Search for the agent in the organization where the `search-string` matches the agent name and retrieve the agent's ID.

```graphql
query SearchAgent {
   organization(slug:"organization-slug") {
    agents(first:500, search:"search-string") {
      edges {
        node {
          name
          id
        }
      }
    }
  }
}
```

Then, using the agent ID, stop the agent gracefully:

```graphql
mutation {
  agentStop(input: {
     id: "QWdlbnQtLS0wMThkYWUyZi02NjRjLTQxYjgtOWE4Ny1mMGY5ODhkZWRhM2Q=",
     graceful: true
  }) {
    agent{
      id,
      connectionState
    }
  }
}
```
