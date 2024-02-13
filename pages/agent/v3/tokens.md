# Agent tokens

A Buildkite agent requires an agent token to connect to Buildkite and register for work. Agent tokens connect to Buildkite via a [cluster](/docs/clusters/overview), and can be accessed from the cluster's _Agent Tokens_ page.


## The default token

When you create a new organization in Buildkite, a default agent token is created. This token can be used for testing and development and is only revealed once, but it's recommended you [create new, specific tokens](#creating-tokens) for each new environment.

>📘 An agent token's value is only displayed once
> As soon as the agent token's value is displayed (including the default agent token), copy its value and save it in a secure location.
> If you forget to do this, you will need to create a new token to obtain its value.

## Using and storing tokens

The token is used by the Buildkite Agent's [start](/docs/agent/v3/cli-start#starting-an-agent) command, and can be provided on the command line, set in the [configuration file](/docs/agent/v3/configuration), or provided using the [environment variable](/docs/pipelines/environment-variables) `BUILDKITE_AGENT_TOKEN`.

It's recommended you use your platform's secret storage (such as the [AWS Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-paramstore.html)) to allow for easier rollover and management of your agent tokens.

## Creating tokens

New tokens can be created either using the _Agent Tokens_ page of the cluster, or via the [REST API](/docs/apis/rest-api)'s [create agent token](/docs/apis/rest-api/clusters#agent-tokens-create-a-token) feature.

For example:

```curl
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens" \
  -H "Content-Type: application/json" \
  -d '{ "description": "A description" }'
```

- The `$TOKEN` value is an [API access token](https://buildkite.com/user/api-access-tokens) scoped to the relevant _Organization_ and _REST API Scopes_ that your agent needs access to in Buildkite.

- The `{org.slug}` value can be obtained from the end of your Buildkite URL after accessing the _Pipelines_ page of your organization in Buildkite.

    Alternatively, you can run the [List organizations](/docs/apis/rest-api/organizations#list-organizations) REST API query to obtain this value from `slug` in the response. For example:

    ```curl
    curl -H "Authorization: Bearer $TOKEN" "https://api.buildkite.com/v2/organizations"
    ```

- The `{cluster.id}` value can be obtained from the _Cluster Settings_ page of your specific cluster that the agent will connect to. This page can be accessed by selecting _Agents_ > the specific cluster tile > _Settings_. Once on the _Cluster Settings_ page, copy the `id` parameter value from the _GraphQL API Integration_ section, which is the `{cluster.id}` value. 

    Alternatively, you can run the [List clusters](/docs/apis/rest-api/clusters#clusters-list-clusters) REST API query and obtain this value from the `id` in the response associated with the name of your cluster (specified by the `name` value in the response). For example:

    ```curl
    curl -H "Authorization: Bearer $TOKEN" "https://api.buildkite.com/v2/organizations/{org.slug}/clusters"
    ```

<!--alex ignore clearly-->

- The token description should clearly identify the environment the token is intended to be used for (for example, `Read-only token for static site generator`), and is listed on the _Agent tokens_ page of your specific cluster the agent connects to. This page can be accessed by selecting _Agents_ > the specific cluster tile > _Agent Tokens_.

It is possible to create multiple agent tokens (for any cluster) using either its _Agent Tokens_ page or the [REST API](/docs/apis/rest-api/clusters#agent-tokens-create-a-token).

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
