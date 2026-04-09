# Job dispatch

By default, self-hosted agents poll the Buildkite API at regular intervals to check for available jobs. When a job is available, the agent accepts it and begins execution. The polling interval is set by Buildkite Pipelines (the Buildkite platform) during agent registration, and each poll includes random jitter to avoid multiple agents synchronizing their requests.

This polling-based approach is reliable and works across all network configurations, but introduces latency between a job becoming available and an agent picking it up.

## Streaming job dispatch

Streaming job dispatch reduces job acceptance latency by maintaining a persistent connection between the agent and Buildkite Pipelines. Instead of the agent periodically asking for work, Buildkite Pipelines pushes jobs to idle agents as soon as they become available.

To opt in to this feature, when [starting your self-hosted agent](/docs/agent/cli/reference/start), point your agent at the streaming endpoint using the [`--endpoint` option](/docs/agent/cli/reference/start#endpoint):

```bash
buildkite-agent start --endpoint https://agent-edge.buildkite.com/v3
```

You can also set this using the [`BUILDKITE_AGENT_ENDPOINT` environment variable](/docs/agent/self-hosted/configure#endpoint) or by adding `endpoint=https://agent-edge.buildkite.com/v3` to your `buildkite-agent.cfg` file.

The agent's [`--ping-mode` option](/docs/agent/cli/reference/start#ping-mode) controls the dispatch behavior:

- `auto` (the default when the `--ping-mode` option is omitted): Uses streaming when available, and falls back to polling if the streaming connection fails. This is the recommended option.
- `poll-only`: Uses the classical polling-based dispatch only. Specify this option if network issues prevent streaming from working effectively.
- `stream-only`: Uses streaming dispatch only, with no fallback. The agent stops if the streaming connection fails.

In `auto` mode, both the streaming and polling mechanisms run concurrently. The streaming connection takes priority when healthy, and the polling loop activates automatically if the streaming connection becomes unhealthy.
