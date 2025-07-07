# Unclustered agent tokens

> 🚧 This page documents a deprecated Buildkite feature
> _It is not be possible to create and work with unclustered agents for any new Buildkite organizations created after the official release of clusters on February 26, 2024._ Therefore, unclustered agent tokens are not relevant to these organizations.
> Previously, agents only connected directly to Buildkite via a token which was created and managed by the processes described on this page. These tokens are now a deprecated feature of Buildkite, and are referred to as _unclustered agent tokens_. Unclustered agent tokens, however, are still available to customers who have not yet migrated their pipelines to a [cluster](/docs/pipelines/clusters).
> _Agent tokens_ are now associated with clusters, and connect to Buildkite through a specific cluster within an organization. Learn more about how to manage agent tokens for clusters in [Agent tokens](/docs/agent/v3/tokens) and how to [migrate your unclustered agents across to a cluster](/docs/pipelines/clusters/migrate-from-unclustered-to-clustered-agents).

Any Buildkite organization created before February 26, 2024 has an **Unclustered** area for managing _unclustered agents_, accessible through **Agents** (from the global navigation) > **Unclustered** of the Buildkite interface, where an _unclustered agent_ refers to any agent that is not associated with a cluster.

A Buildkite agent requires a token to connect to Buildkite and register for work. If you need to connect an _unclustered agent_ to Buildkite, then you need to create an _unclustered agent token_ to do so.

## The default token

<!-- Is this section still valid? Should this instead be called the 'initial unclustered agent token'? -->

Your Buildkite organization's unclustered agent tokens page, accessible through **Agents** (from the global navigation) > **Unclustered** > **Agent Tokens**, may have the **Default agent registration token**, which is the original default token when your organization was created. If you had previously saved this token's value in a safe place, this token can be used for testing and development. However, it's recommended that you [create new, specific tokens](#create-a-token) for each new environment.

## Using and storing tokens

An unclustered agent token is used by the Buildkite agent's [start](/docs/agent/v3/cli-start#starting-an-agent) command, and can be provided on the command line, set in the [configuration file](/docs/agent/v3/configuration), or provided using the [environment variable](/docs/pipelines/configure/environment-variables) `BUILDKITE_AGENT_TOKEN`.

It's recommended you use your platform's secret storage (such as the [AWS Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-paramstore.html)) to allow for easier rollover and management of your agent tokens.

## Create a token

New unclustered agent tokens can be created using the [GraphQL API](/docs/apis/graphql-api) with the `agentTokenCreate` mutation.

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

> 📘 An unclustered agent token's value is only displayed once
> As soon as the unclustered agent token's value is displayed, copy its value and save it in a secure location.
> If you forget to do this, you'll need to create a new token to obtain its value.

You can find your `organization-id` in your Buildkite organization settings page, or by running the following GrapqQL query:

```graphql
query GetOrgID {
  organization(slug: "organization-slug") {
    id
  }
}
```

<!--alex ignore clearly-->

The token description should clearly identify the environment the token is intended to be used for (for example, `Read-only token for static site generator`), and is listed on the **Agent tokens** page of the **Agents** (from the global navigation) > **Unclustered** area.

It is possible to create multiple unclustered agent tokens using the GraphQL API.

## Revoke a token

Unclustered agent tokens can be revoked using the [GraphQL API](/docs/apis/graphql/cookbooks/agents#revoke-an-unclustered-agent-token) query with the `agentTokenRevoke ` mutation.

You need to pass your unclustered agent token as the ID in the mutation.

First, you can retrieve a list of agent token IDs using this query:

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

Then, using the token ID, revoke the unclustered agent token:

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

Unclustered agent tokens are specific to each Buildkite organization (created before February 26, 2024), and can be used to register an agent with any [unclustered queue](/docs/agent/v3/queues). Unclustered agent tokens can not be shared between organizations.

## Session and job tokens

During registration, the unclustered agent exchanges its unclustered agent token for a session token. The session token lasts for the lifetime of the agent and is used to request and start new jobs. When each job is started, the unclustered agent gets a job token specific to that job. The job token is exposed to the job as the [environment variable](/docs/pipelines/configure/environment-variables) `BUILDKITE_AGENT_ACCESS_TOKEN`, and is used by various CLI commands (including the [annotate](/docs/agent/v3/cli-annotate), [artifact](/docs/agent/v3/cli-artifact), [meta-data](/docs/agent/v3/cli-meta-data), and [pipeline](/docs/agent/v3/cli-pipeline) commands).

Job tokens are valid until the job finishes. To ensure job tokens have a limited lifetime, you can set a default or maximum [command timeout](/docs/pipelines/configure/build-timeouts#command-timeouts).

<table>
  <tr>
    <th>Token type</th>
    <th>Use</th>
    <th>Lifetime</th>
  </tr>
  <tr>
    <td>Unclustered agent token</td>
    <td>Registering new unclustered agents.</td>
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

> 📘 Job tokens not supported in agents prior to v3.39.0
> Agents prior to v3.39.0 use the session token for the `BUILDKITE_AGENT_ACCESS_TOKEN` environment variable and the job APIs.
