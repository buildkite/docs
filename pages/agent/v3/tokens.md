# Agent tokens

The Buildkite Agent requires an agent token to connect to Buildkite and register for work. If you are an admin of your Buildkite organization, you can view the tokens on your [Agents page](https://buildkite.com/organizations/-/agents).


## Finding and creating tokens

When you create a new organization in Buildkite, a default agent token is created. You can use this token for testing and development, but creating new, specific tokens for each new environment is recommended.

Tokens can be found and managed on your [Agent Tokens page](https://buildkite.com/organizations/-/agent-tokens).

Tokens can also be created using [the GraphQL API](/docs/apis/graphql/schemas/mutation/agenttokencreate).

## Using and storing tokens

The token is used by the Buildkite Agent's [start](/docs/agent/v3/cli-start#starting-an-agent) command, and can be provided on the command line, set in the [configuration file](/docs/agent/v3/configuration), or provided using the [environment variable](/docs/pipelines/environment-variables) `BUILDKITE_AGENT_TOKEN`.

It's recommended you use your platform's secret storage (such as the [AWS Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-paramstore.html)) to allow for easier rollover and management of your agent tokens.

## Revoking tokens

Tokens can be revoked from your [Agent Tokens page](https://buildkite.com/organizations/-/agent-tokens). Once a token is revoked, no new agents will be able to start with that token. Revoking a token does not affect any connected agents.

Tokens can also be revoked using [the GraphQL API](/docs/apis/graphql/schemas/mutation/agenttokenrevoke).

## Scope of access

Agent tokens are specific to each Buildkite organization, and can be used to register an agent with any [queue](/docs/agent/v3/queues). Agent tokens can not be shared between organizations.

## Session tokens

During registration, the agent exchanges the agent token for a session token. The session token is exposed to the job as the [environment variable](/docs/pipelines/environment-variables) `BUILDKITE_AGENT_ACCESS_TOKEN`, and is used by the [annotate](/docs/agent/v3/cli-annotate), [artifact](/docs/agent/v3/cli-artifact), [meta-data](/docs/agent/v3/cli-meta-data) and [pipeline](/docs/agent/v3/cli-pipeline) commands. Session tokens are scoped to a specific agent, and are valid for the duration the agent is connected.
