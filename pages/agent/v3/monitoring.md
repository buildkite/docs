# Monitoring and observing the Buildkite Agent

By default, the agent is only observable either through Buildkite or
 through log output on the host:

- Job logs, which relate to the jobs the agent runs, are uploaded to Buildkite,
 and are shown for each step in a build.
- Agent logs, which relate to how the agent itself is running, are not uploaded
 or saved (except where this is done by another process such as systemd or
 launchd).

## Health checking and status page

The agent can optionally run an HTTP service that describes the agent's state. The service is suitable for both automated health checks and human inspection.

You can enable the service with the `--health-check-addr` flag or
`$BUILDKITE_AGENT_HEALTH_CHECK_ADDR` environment variable:

```shell
buildkite-agent start --health-check-addr=:3901
```

For security reasons, we recommend that you do _not_ expose the service
directly to the internet. While there should be no ability to manipulate the
agent state using this service, it may expose information, or provide a vector
for a denial-of-service attack. We may also add new features to the service in
the future.

### Health checking service routes

- **`/`**: Returns HTTP status 200 with the text `OK: Buildkite agent is
  running`.
- **`/agent/(worker number)`**: Reports the time since the agent worker
  succeeded at sending a heartbeat. Workers are numbered starting from 1,
  and the number of workers is set with the `--spawn` flag. If the previous
  heartbeat for this worker failed, it returns HTTP status 500 and a description
  of the failure. Otherwise, it returns HTTP status 200.
- **`/status`**: A human-friendly page detailing various systems inside the
  agent. To aid debugging, this page does *not* automatically refresh—it shows
  the status of each agent internal at a particular moment in time.

The following shows the `/status` page for an agent:

<%= image 'status-page.png', size: '600x437', alt: 'Agent internal status page' %>

## Tracing

For Datadog APM or OpenTelemetry tracing, see [Tracing in the Buildkite Agent](/docs/agent/v3/tracing).
