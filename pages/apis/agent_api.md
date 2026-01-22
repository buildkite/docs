# Agent REST API overview

The agent REST API endpoint is used for agent registration, agent deregistration, starting jobs on agents, finishing jobs on agents, and agent metrics.

The only publicly available endpoint is `/metrics`. The [Buildkite Agent Metrics](https://github.com/buildkite/buildkite-agent-metrics) CLI tool uses the data returned by the metrics endpoint for agent autoscaling.

All other endpoints in the agent API are intended only for use by the Buildkite Agent, therefore stability and backwards compatibility are not guaranteed, and changes won't be announced.

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

Unlike the [Buildkite REST API](/docs/apis/rest-api), which uses an [API access token](/docs/apis/rest-api#authentication), the agent REST API uses an [agent token](/docs/agent/v3/self-hosted/tokens) for authentication.

To authenticate using an agent token, set the `Authorization` HTTP header to the word `Token`, followed by a space, followed by the agent token. For example:

```bash
curl -H "Authorization: Token $TOKEN" https://agent.buildkite.com/v3/metrics
```
