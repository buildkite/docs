# Agent REST API overview

The agent REST API is used to retrieve agent metrics, register agents, deregister them, start jobs on agents, and finish jobs on them.

The agent REST API's publicly available endpoints include:

- [`/metrics`](/docs/apis/agent-api/metrics): Used to retrieve information about current self-hosted agents associated with a Buildkite cluster. The [Buildkite Agent Metrics](https://github.com/buildkite/buildkite-agent-metrics) CLI tool uses the data returned by the metrics endpoint for agent autoscaling.
- [`/stacks`](/docs/apis/agent-api/stacks): Used to implement a _stack_ on a self-hosted queue. A stack is a long-running controller process that watches the queue for jobs, and runs Buildkite agents on demand to run these jobs.

All other endpoints in the agent API are intended only for use by the Buildkite agent, therefore stability and backwards compatibility are not guaranteed, and changes won't be announced.

The agent also includes an internal API, called the [internal job API](/docs/apis/agent-api/internal-job), which is used to query and mutate the state of if a job running on the agent, using environment variables.

The current version of the agent API is v3.

## Schema

All API access is over HTTPS, and accessed from the `agent.buildkite.com` domain. All data is sent as JSON.

```bash
curl https://agent.buildkite.com
```

```json
{"message":"👋","timestamp":1719276157}
```

## Authentication

Unlike the [Buildkite REST API](/docs/apis/rest-api), which uses an [API access token](/docs/apis/rest-api#authentication), the agent REST API's _public_ endpoints use an [agent token](/docs/agent/v3/self-hosted/tokens) for authentication.

To authenticate using an agent token, set the `Authorization` HTTP header to the word `Token`, followed by a space, followed by the agent token. For example:

```bash
curl -H "Authorization: Token $TOKEN" https://agent.buildkite.com/v3/metrics
```
