# Agent tokens

The Buildkite Agent requires an agent token to connect to Buildkite and register for work. If you are an admin of your Buildkite organization, you can view the tokens on your [Agents page](https://buildkite.com/organizations/-/agents).


## The default token

When you create a new organization in Buildkite, a default agent token is created. This token can be used for testing and development, but it's recommended to [create new, specific tokens](#creating-tokens) for each new environment.

## Using and storing tokens

The token is used by the Buildkite Agent's [start](/docs/agent/v3/cli-start#starting-an-agent) command, and can be provided on the command line, set in the [configuration file](/docs/agent/v3/configuration), or provided using the [environment variable](/docs/pipelines/environment-variables) `BUILDKITE_AGENT_TOKEN`.

It's recommended you use your platform's secret storage (such as the [AWS Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-paramstore.html)) to allow for easier rollover and management of your agent tokens.

## Creating tokens
There is a grace period of 10 minutes after you create a token. Even if you reload the page, the token remains visible during the grace period.

New tokens can be created using the [GraphQL API](/docs/apis/graphql-api) with the `agentTokenCreate` mutation.

For example:

```graphql
mutation {
  agentTokenCreate(input: {
    organizationID: "organization-id",
    description: "A description"
  }) {
    tokenValue
    agentTokenEdge {
      node {
        id
      }
    }
  }
}
```

You can find your `organization-id` in your Buildkite organization settings page, or by running the following GrapqQL query:

```graphql
query GetOrgID {
  organization(slug: "organization-slug") {
    id
  }
}
```

<!--alex ignore clearly-->

The token description should clearly identify the environment the token is intended to be used for, and is shown on your [Agents page](https://buildkite.com/organizations/-/agents) (for example, `Read-only token for static site generator`).  

It is possible to create multiple agent tokens using the GraphQL API. These tokens will show up on the [Agents page](https://buildkite.com/organizations/-/agents) in the UI, but can only be managed (created or revoked) using the API.

## Revoking tokens

Tokens can be revoked using the [GraphQL API](/docs/apis/graphql-api) with the `agentTokenRevoke ` mutation.

You need to pass your agent token as the ID in the mutation. You can get the token from your Buildkite dashboard, in _Agents_ > _Reveal Agent Token_, or you can retrieve a list of agent token IDs using this query:

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

Then, using the token ID, revoke the agent token:

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

Once a token is revoked, no new agents will be able to start with that token. Revoking a token does not affect any connected agents.

## Scope of access

Agent tokens are specific to each Buildkite organization, and can be used to register an agent with any [queue](/docs/agent/v3/queues). Agent tokens can not be shared between organizations.

## Session tokens

During registration, the agent exchanges the agent token for a session token. The session token is exposed to the job as the [environment variable](/docs/pipelines/environment-variables) `BUILDKITE_AGENT_ACCESS_TOKEN`, and is used by the [annotate](/docs/agent/v3/cli-annotate), [artifact](/docs/agent/v3/cli-artifact), [meta-data](/docs/agent/v3/cli-meta-data) and [pipeline](/docs/agent/v3/cli-pipeline) commands. Session tokens are scoped to a specific agent, and are valid for the duration the agent is connected.
