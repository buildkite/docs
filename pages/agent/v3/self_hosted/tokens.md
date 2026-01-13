# Agent tokens

A Buildkite agent running in a [self-hosted architecture](/docs/pipelines/getting-started#understand-the-architecture) requires an _agent token_ to connect to Buildkite and register for work. Agent tokens connect to Buildkite via a [cluster](/docs/pipelines/security/clusters), and can be accessed from the cluster's **Agent Tokens** page.

A user who is a Buildkite organization administrator or a [maintainer of a cluster](/docs/pipelines/security/clusters/manage#manage-maintainers-on-a-cluster) within the organization can manage agent tokens for that cluster.

If you are managing agents in an unclustered environment, refer to [unclustered tokens](/docs/agent/v3/self-hosted/unclustered-tokens) instead.

## The initial agent token

When you create a new organization in Buildkite, an initial agent token is created (called **Initial agent token** within the **Default cluster**). This token can be used for testing and development and is only revealed once during the organization setup process. It's recommended that you [create new, specific tokens](#create-a-token) for each new environment.

## Using and storing tokens

An agent token is used by the Buildkite Agent's [start](/docs/agent/v3/cli/reference/start#starting-an-agent) command, and can be provided on the command line, set in the [configuration file](/docs/agent/v3/self-hosted/configure), or provided using the [environment variable](/docs/pipelines/configure/environment-variables) `BUILDKITE_AGENT_TOKEN`.

It's recommended you use your platform's secret storage (such as the [AWS Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-paramstore.html)) to allow for easier rollover and management of your agent tokens.

## Create a token

New agent tokens can be created by a [cluster maintainer](/docs/pipelines/security/clusters/manage#manage-maintainers-on-a-cluster) or Buildkite organization administrator using the [**Agent Tokens** page of a cluster](#create-a-token-using-the-buildkite-interface), as well as Buildkite's [REST API](#create-a-token-using-the-rest-api) or [GraphQL API](#create-a-token-using-the-graphql-api).

For these API requests, the _cluster ID_ value submitted as part of the request is the target cluster the token is associated with.

> 📘 An agent token's value is only displayed once
> As soon as the agent token's value is displayed, copy its value and save it in a secure location.
> If you forget to do this, you'll need to create a new token to obtain its value.

It is possible to create multiple agent tokens (for your Default cluster or any other cluster in your Buildkite organization) using the processes described in this section.

### Using the Buildkite interface

To create an agent token for a cluster using the Buildkite interface:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster that will be associated with this agent token.
1. Select **Agent Tokens** > **New Token**.
1. In the **Description** field, enter an appropriate description for the agent token.

    **Note:** The token description should clearly identify the environment the token is intended to be used for (for example, `Read-only token for static site generator`), as it is listed on the **Agent Tokens** page of your specific cluster the agent connects to. This page can be accessed by selecting **Agents** (in the global navigation) > the specific cluster > **Agent Tokens**.

1. If you need to restrict which network addresses are allowed to use this agent token, enter these addresses (using [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)) into the **Allowed IP Addresses** field.

    **Note:** Leave this field empty if there is no need to restrict the use of this agent token by network address. Learn more about this feature in [Restrict an agent token's access by IP address](/docs/pipelines/security/clusters/manage#restrict-an-agent-tokens-access-by-ip-address).

1. Select **Create Token**.

    Follow the instructions to copy and save your token to a secure location and select **Okay, I'm done!**. The new agent token appears on the cluster's **Agent Tokens** page.

### Using the REST API

To [create an agent token](/docs/apis/rest-api/clusters/agent-tokens#create-a-token) using the [REST API](/docs/apis/rest-api), run the following example `curl` command:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "A description",
    "expires_at": "2026-01-01T00:00:00Z",
    "allowed_ip_addresses": "0.0.0.0/0"
  }'
```

where:

<%= render_markdown partial: 'apis/descriptions/rest_access_token' %>

<%= render_markdown partial: 'apis/descriptions/rest_org_slug' %>

<%= render_markdown partial: 'apis/descriptions/rest_cluster_id' %>

<!--alex ignore clearly-->

- <%= render_markdown partial: 'apis/descriptions/common_agent_token_description_required' %>

- <%= render_markdown partial: 'apis/descriptions/rest_agent_token_expires_at' %>

- <%= render_markdown partial: 'apis/descriptions/rest_allowed_ip_addresses' %>

The new agent token appears on the cluster's **Agent Tokens** page.

### Using the GraphQL API

To [create an agent token](/docs/apis/graphql/cookbooks/clusters#create-agent-token-with-an-expiration-date) using the [GraphQL API](/docs/apis/graphql-api), run the following example mutation:

```graphql
mutation {
  clusterAgentTokenCreate(
    input: {
      organizationId: "organization-id"
      clusterId: "cluster-id"
      description: "A description"
      expiresAt: "2026-01-01T00:00:00Z"
      allowedIpAddresses: "0.0.0.0/0"
    }
  ) {
    clusterAgentToken {
      id
      uuid
      description
      allowedIpAddresses
      cluster {
        id
        uuid
        organization {
          id
          uuid
        }
      }
      createdBy {
        id
        uuid
        email
      }
    }
    tokenValue
  }
}
```

where:

<%= render_markdown partial: 'apis/descriptions/graphql_organization_id' %>

<%= render_markdown partial: 'apis/descriptions/graphql_cluster_id' %>

- <%= render_markdown partial: 'apis/descriptions/common_agent_token_description_required' %>

- <%= render_markdown partial: 'apis/descriptions/graphql_agent_token_expiresat' %>

- <%= render_markdown partial: 'apis/descriptions/graphql_allowed_ip_addresses' %>

The new agent token appears on the cluster's **Agent Tokens** page.

## Update a token

Agent tokens can be updated by a [cluster maintainer](/docs/pipelines/security/clusters/manage#manage-maintainers-on-a-cluster) or Buildkite organization administrator using the [**Agent Tokens** page of a cluster](#update-a-token-using-the-buildkite-interface), as well as Buildkite's [REST API](#update-a-token-using-the-rest-api) or [GraphQL API](#update-a-token-using-the-graphql-api).

Only the **Description** and **Allowed IP Addresses** of an existing agent token can be updated. **Expiration date** for a token cannot be updated.

For these API requests, the _cluster ID_ value submitted as part of the request is the target cluster the token is associated with.

### Using the Buildkite interface

To update a cluster's agent token using the Buildkite interface:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster containing the agent token to update.
1. Select **Agent Tokens** and on this page, expand the agent token to update.
1. Select **Edit** and update the following fields as required:
    * **Description** should clearly identify the environment the token is intended to be used for (for example, `Read-only token for static site generator`), as it is listed on the **Agent tokens** page of your specific cluster the agent connects to. This page can be accessed by selecting **Agents** (in the global navigation) > the specific cluster > **Agent Tokens**.
    * **Allowed IP Addresses** is/are the IP addresses which agents must be accessible through to access this agent token and be able to connect to Buildkite via your cluster. Use space-separated [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) to enter IP addresses for this field value.

        Leave this field empty if there is no need to restrict the use of this agent token by network address. Learn more about this feature in [Restrict an agent token's access by IP address](/docs/pipelines/security/clusters/manage#restrict-an-agent-tokens-access-by-ip-address).

1. Select **Save Token** to save your changes.

    The agent token's updates will appear on the cluster's **Agent Tokens** page.

### Using the REST API

To [update an agent token](/docs/apis/rest-api/clusters/agent-tokens#update-a-token) using the [REST API](/docs/apis/rest-api), run the following example `curl` command:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens/{id}" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "A description",
    "allowed_ip_addresses": "202.144.0.0/24 198.51.100.12"
  }'
```

where:

<%= render_markdown partial: 'apis/descriptions/rest_access_token' %>

<%= render_markdown partial: 'apis/descriptions/rest_org_slug' %>

<%= render_markdown partial: 'apis/descriptions/rest_cluster_id' %>

<%= render_markdown partial: 'apis/descriptions/rest_agent_token_id' %>

- <%= render_markdown partial: 'apis/descriptions/rest_agent_token_description_optional' %>

- <%= render_markdown partial: 'apis/descriptions/rest_allowed_ip_addresses' %>

    This field can be omitted (where the default value is `0.0.0.0/0`) if there is no need to restrict the use of this agent token by network address, or change the field's current value. Learn more about this feature in [Restrict an agent token's access by IP address](/docs/pipelines/security/clusters/manage#restrict-an-agent-tokens-access-by-ip-address).

### Using the GraphQL API

To [update an agent token](/docs/apis/graphql/schemas/mutation/clusteragenttokenupdate) using the [GraphQL API](/docs/apis/graphql-api), run the following example mutation:

```graphql
mutation {
  clusterAgentTokenUpdate(
    input: {
      organizationId: "organization-id"
      id: "token-id"
      description: "A description"
      allowedIpAddresses: "202.144.0.0/24 198.51.100.12"
    }
  ) {
    clusterAgentToken {
      id
      uuid
      description
      allowedIpAddresses
      cluster {
        id
        uuid
        organization {
          id
          uuid
        }
      }
      createdBy {
        id
        uuid
        email
      }
    }
  }
}
```

where:

<%= render_markdown partial: 'apis/descriptions/graphql_organization_id' %>

<%= render_markdown partial: 'apis/descriptions/graphql_agent_token_id' %>

- <%= render_markdown partial: 'apis/descriptions/common_agent_token_description_required' %>

    If you do not need to change the existing `description` value, specify the existing field value in the request.

- <%= render_markdown partial: 'apis/descriptions/graphql_allowed_ip_addresses' %>

    This field can be omitted (where the default value is `0.0.0.0/0`) if there is no need to restrict the use of this agent token by network address, or change the field's current value. Learn more about this feature in [Restrict an agent token's access by IP address](/docs/pipelines/security/clusters/manage#restrict-an-agent-tokens-access-by-ip-address).

The agent token's updates will appear on the cluster's **Agent Tokens** page.

## Revoke a token

Agent tokens can be revoked by a [cluster maintainer](/docs/pipelines/security/clusters/manage#manage-maintainers-on-a-cluster) or Buildkite organization administrator using the [**Agent Tokens** page of a cluster](#revoke-a-token-using-the-buildkite-interface), as well as Buildkite's [REST API](#revoke-a-token-using-the-rest-api) or [GraphQL API](#revoke-a-token-using-the-graphql-api).

For these API requests, the _cluster ID_ value submitted as part of the request is the target cluster the token is associated with.

Once a token is revoked, no new agents will be able to start with that token. Revoking a token does not affect any connected agents.

### Using the Buildkite interface

To revoke a cluster's agent token using the Buildkite interface:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster containing the agent token to revoke.
1. Select **Agent Tokens** and on this page, expand the agent token to revoke.
1. Select **Revoke** > **Revoke Token** in the confirmation message.

### Using the REST API

To [revoke an agent token](/docs/apis/rest-api/clusters/agent-tokens#revoke-a-token) using the [REST API](/docs/apis/rest-api), run the following example `curl` command:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens/{id}"
```

where:

<%= render_markdown partial: 'apis/descriptions/rest_access_token' %>

<%= render_markdown partial: 'apis/descriptions/rest_org_slug' %>

<%= render_markdown partial: 'apis/descriptions/rest_cluster_id' %>

<%= render_markdown partial: 'apis/descriptions/rest_agent_token_id' %>

### Using the GraphQL API

To [revoke an agent token](/docs/apis/graphql/cookbooks/clusters#revoke-an-agent-token) using the [GraphQL API](/docs/apis/graphql-api), run the following example mutation:

```graphql
mutation {
  clusterAgentTokenRevoke(
    input: {
      organizationId: "organization-id"
      id: "token-id"
    }
  ) {
    deletedClusterAgentTokenId
  }
}
```

where:

<%= render_markdown partial: 'apis/descriptions/graphql_organization_id' %>

<%= render_markdown partial: 'apis/descriptions/graphql_agent_token_id' %>

## Scope of access

An agent token is specific to the cluster it was associated when created (within a Buildkite organization), and can be used to register an agent with any [queue](/docs/agent/v3/queues) defined in that cluster. Agent tokens can not be shared between different clusters within an organization, or between different organizations.

## Agent token lifetime

Agent tokens [created using the Buildkite interface](#create-a-token-using-the-buildkite-interface) do not expire and need to be rotated manually.

However, using Buildkite's APIs, you can specify an optional expiration date attribute with a timestamp value in your API call to create an agent token—[`expires_at` using the REST API](#create-a-token-using-the-rest-api) or [`expiresAt` using the GraphQL API](#create-a-token-using-the-graphql-api). The ability to set an expiration timestamp on an agent token is a security compliance and token lifecycle management feature, which allows you to implement an automated token rotation process using the Buildkite API, replacing any previous, more manual rotation processes for long-lived agent tokens. Note that the existing agent tokens will continue to work without expiration, unless they are manually revoked.

There is no maximum expiration duration for an agent token, although a minimum of 10 minutes from the current time is required. After an agent token has expired, it is displayed with the following message in the Buildkite interface:

⚠️ **This token expired on ...**

An expired agent token will prevent agents configured with this token from being able to re-connect to its Buildkite cluster. However, agents currently connected to their cluster at the time of expiration won't be affected.

> 📘 Agent token expiration format
> The timestamp must be set in ISO8601 format (for example, `2025-01-01T00:00:00Z`). This timestamp value cannot be changed on an existing agent token. An error is returned if an attempt is made to update the expiration date field of an existing agent token.

## Additional agent tokens

In addition to the initial agent token, the Buildkite Agent automatically generates and manages two internal types of tokens during its operation. These tokens are session tokens and job tokens.

### Session tokens

Session tokens are internal tokens that last for the lifetime of the agent connection. They are used by the agent to request and start new jobs, and remain valid until the agent disconnects from Buildkite.

### Job tokens

Job tokens are internal agent access tokens that are generated for each individual job when it starts. They are exposed to the job as the [environment variable](/docs/pipelines/configure/environment-variables) `BUILDKITE_AGENT_ACCESS_TOKEN` and are used by the Buildkite Agent's local Job API, which provides access to various CLI commands (including [annotate](/docs/agent/v3/cli/reference/annotate), [artifact](/docs/agent/v3/cli/reference/artifact), [meta-data](/docs/agent/v3/cli/reference/meta-data), and [pipeline](/docs/agent/v3/cli/reference/pipeline) commands). Job tokens are scoped to a single job for security reasons, limiting both the duration and the scope of access, and are valid until the job finishes.

You can set a default or maximum [command timeout](/docs/pipelines/configure/build-timeouts#command-timeouts) to further scope the lifetime of job tokens.

### Token exchange process

When an agent starts, it follows the token exchange process:

1. The agent connects to the Buildkite Agent API to register itself using its configured **agent token** (`BUILDKITE_AGENT_TOKEN`).
1. The Agent API generates and returns a **session token** to the agent.
1. The agent uses this session token to poll for available jobs and manage its connection to Buildkite.
1. When the agent accepts a job, Buildkite generates a **job token** specific to that job.

<table>
  <tr>
    <th>Token type</th>
    <th>Generated by</th>
    <th>Use</th>
    <th>Lifetime</th>
  </tr>
  <tr>
    <td>Agent token</td>
    <td>Buildkite organization admin or cluster maintainer</td>
    <td>Initial agent registration and authentication.</td>
    <td>Forever unless expiration date is set during creation with GraphQL or REST API, or is manually revoked.</td>
  </tr>
  <tr>
    <td>Session token (internal)</td>
    <td>Buildkite Agent API during registration</td>
    <td>Agent lifecycle APIs, polling for jobs, and starting jobs.</td>
    <td>Until the agent disconnects.</td>
  </tr>
  <tr>
    <td>Job token (internal)</td>
    <td>Buildkite Agent API when job is accepted</td>
    <td>Local Job API access for CLI commands (including <a href="/docs/agent/v3/cli/reference/annotate">annotate</a>,  <a href="/docs/agent/v3/cli/reference/artifact">artifact</a>,  <a href="/docs/agent/v3/cli/reference/meta-data">meta-data</a>, and  <a href="/docs/agent/v3/cli/reference/pipeline">pipeline</a> commands).</td>
    <td>Until the job finishes.</td>
  </tr>
</table>

>📘 Job tokens are not supported in agents prior to v3.39.0
> Agents prior to v3.39.0 use the session token for the `BUILDKITE_AGENT_ACCESS_TOKEN` environment variable and the job APIs.
