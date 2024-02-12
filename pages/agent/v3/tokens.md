# Agent tokens

The Buildkite Agent requires an agent token to connect to Buildkite and register for work. If you are an admin of your Buildkite organization, you can view the tokens on your [Agents page](https://buildkite.com/organizations/-/agents).


## The default token

When you create a new organization in Buildkite, a default agent token is created. This token can be used for testing and development and is only revealed once, but it's recommended you [create new, specific tokens](#creating-tokens) for each new environment.

>📘 An agent token's value is only displayed once
> As soon as the agent token's value is displayed (including the default agent token), copy its value and save it in a secure location.
> If you forget to do this, you will need to create a new token to obtain its value.

## Using and storing tokens

The token is used by the Buildkite Agent's [start](/docs/agent/v3/cli-start#starting-an-agent) command, and can be provided on the command line, set in the [configuration file](/docs/agent/v3/configuration), or provided using the [environment variable](/docs/pipelines/environment-variables) `BUILDKITE_AGENT_TOKEN`.

It's recommended you use your platform's secret storage (such as the [AWS Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-paramstore.html)) to allow for easier rollover and management of your agent tokens.

## Creating tokens

New tokens can be created either using the _Agent Tokens_ page of the cluster, or via the [REST API](/docs/apis/rest-api)'s [create cluster token](/docs/apis/rest-api/clusters#cluster-tokens-create-a-token) feature.

For example:

```curl
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens" \
  -H "Content-Type: application/json" \
  -d '{ "description": "A description" }'
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

## Session and job tokens

During registration, the agent exchanges its agent token for a session token. The session token lasts for the lifetime of the agent and is used to request and start new jobs. When each job is started, the agent gets a job token specific to that job. The job token is exposed to the job as the [environment variable](/docs/pipelines/environment-variables) `BUILDKITE_AGENT_ACCESS_TOKEN`, and is used by various CLI commands (including the [annotate](/docs/agent/v3/cli-annotate), [artifact](/docs/agent/v3/cli-artifact), [meta-data](/docs/agent/v3/cli-meta-data), and [pipeline](/docs/agent/v3/cli-pipeline) commands).

Job tokens are valid until the job finishes. To ensure job tokens have a limited lifetime, you can set a default or maximum [command timeout](/docs/pipelines/build-timeouts#command-timeouts).

<table>
  <tr>
    <th>Token type</th>
    <th>Use</th>
    <th>Lifetime</th>
  </tr>
  <tr>
    <td>Agent token</td>
    <td>Registering new agents.</td>
    <td>Forever unless manually revoked.</td>
  </tr>
  <tr>
    <td>Session token</td>
    <td>Agent lifecycle APIs and starting jobs.</td>
    <td>Until the agent disconnects.</td>
  </tr>
  <tr>
    <td>Job token</td>
    <td>Job APIs (including <a href="/docs/agent/v3/cli-annotate">annotate</a>,  <a href="/docs/agent/v3/cli-artifact">artifact</a>,  <a href="/docs/agent/v3/cli-meta-data">meta-data</a> and  <a href="/docs/agent/v3/cli-pipeline">pipeline</a> commands).</td>
    <td>Until the job finishes.</td>
  </tr>
</table>

>📘 Job tokens not supported in agents prior to v3.39.0
> Agents prior to v3.39.0 use the session token for the `BUILDKITE_AGENT_ACCESS_TOKEN` environment variable and the job APIs.
