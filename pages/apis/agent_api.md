# Agent REST API overview

The Agent REST API is used for agent registration, agent deregistration, starting jobs on agents, finishing jobs on agents, and agent metrics.

The only publicly available endpoint is `/metrics`. The [Buildkite metrics agent](https://github.com/buildkite/buildkite-agent-metrics) uses the data returned by the metrics endpoint for agent autoscaling.

The current version of the Agent API is v3.


## Schema

All API access is over HTTPS, and accessed from the `agent.buildkite.com` domain. All data is sent as JSON.

```bash
curl https://agent.buildkite.com
```

```json
{
  "message":"👋"
}
```

## Authentication

Unlike the [Buildkite REST API](/docs/apis/rest-api), which uses an [API access token](/docs/apis/rest-api#authentication), the Agent REST API uses an [Agent registration token](/docs/agent/v3/tokens) for authentication.

To authenticate using an Agent registration token, set the `Authorization` HTTP header to the word `Token`, followed by a space, followed by the access token. For example:

```bash
curl -H "Authorization: Token $TOKEN" https://agent.buildkite.com/v3/metrics
```
