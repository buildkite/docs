# Monitoring and observing the Buildkite Agent

By default, the agent is only observable either through Buildkite or
through log output on the host:

- **Job logs:** Relate to the jobs the agent runs. These are uploaded to
  Buildkite and shown for each step in a build.
- **Agent logs:** Relate to how the agent itself is running. These are not
  uploaded or saved (except where the output from the agent is read or
  redirected by another process, such as [systemd] or [launchd]).

## Health checking, metrics, and status page

The agent can optionally run an HTTP service that describes the agent's state.
The service is suitable for both automated health checks and human inspection.

You can enable the service with the `--health-check-addr` flag or
`$BUILDKITE_AGENT_HEALTH_CHECK_ADDR` environment variable. For example, to
enable the service listening on local port 3901, you can use:

```shell
buildkite-agent start --health-check-addr=:3901
```

The flag expects [a "host:port" address](https://pkg.go.dev/net#Dial).
Passing `:0` allows the agent to choose a port, which will be logged at startup.

For security reasons, we recommend that you do _not_ expose the service
directly to the internet. While there should be no ability to manipulate the
agent state using this service, it may expose information, or provide a vector
for a denial-of-service attack. We may also add new features to the service in
the future.

### Health checking service routes

The URL paths available from the health checking service are as follows:

- **`/`**: Returns HTTP status 200 with the text `OK: Buildkite agent is
  running`.
- **`/agent/(worker number)`**: Reports the time since the agent worker
  succeeded at sending a heartbeat. Workers are numbered starting from 1,
  and the number of workers is set with the `--spawn` flag. If the previous
  heartbeat for this worker failed, it returns HTTP status 500 and a description
  of the failure. Otherwise, it returns HTTP status 200.
- **`/metrics`**: (Added in Buildkite Agent version 3.113.0)
  [Prometheus plain-text metrics](https://prometheus.io/docs/instrumenting/exposition_formats/)
  describing agent behaviour over time.
- **`/status`**: A human-friendly page detailing various systems inside the
  agent. To aid debugging, this page does _not_ automatically refresh—it shows
  the status of each internal component of the agent at a particular moment in
  time.

The following shows the `/status` page for an agent:

<%= image 'status-page.png', size: '600x437', alt: 'Agent internal status page' %>

### Prometheus metrics reference

Prometheus metrics were added to the health-checking service in Buildkite Agent version 3.113.0.

Metric | Type | Description
--- | --- | ---
`buildkite_agent_jobs_ended_total` | Counter | Count of jobs that ended in any way for any reason
`buildkite_agent_jobs_started_total` | Counter | Count of jobs started
`buildkite_agent_logs_bytes_uploaded_total` | Counter | Count of log bytes uploaded
`buildkite_agent_logs_bytes_uploads_errored_total` | Counter | Count of log bytes that were not uploaded due to an error
`buildkite_agent_logs_chunk_uploads_errored_total` | Counter | Count of log chunks that were not uploaded due to an error
`buildkite_agent_logs_chunks_uploaded_total` | Counter | Count of log chunks uploaded
`buildkite_agent_logs_upload_duration_seconds_total` | Histogram | Time taken to upload log chunks
`buildkite_agent_pings_actions_total` | Counter | Count of actions taken following a ping, by `action`
`buildkite_agent_pings_duration_seconds_total` | Histogram | Time taken to ping (the API call, not including the subsequent action)
`buildkite_agent_pings_errors_total` | Counter | Count of pings that failed due to an error
`buildkite_agent_pings_sent_total` | Counter | Count of pings sent
`buildkite_agent_pings_wait_duration_seconds_total` | Histogram | Time spent waiting prior to each ping (ping interval plus jitter)
`buildkite_agent_workers_ended_total` | Counter | Count of agent workers (i.e. `--spawn` flag) that have stopped running
`buildkite_agent_workers_started_total` | Counter | Count of agent workers (i.e. `--spawn` flag) that have started running

A count of currently-running agent workers can be found by subtracting `ended_total` from `started_total`:

```promql
sum(buildkite_agent_workers_started_total - buildkite_agent_workers_ended_total)
```

Similarly, a count of currently-running jobs using the same method:

```promql
sum(buildkite_agent_jobs_started_total - buildkite_agent_jobs_ended_total)
```

As all counter and histogram metrics are cumulative, information such as job or log throughput can be found using functions such as `rate`:

```promql
# Throughput of jobs started over 5m interval
sum(rate(buildkite_agent_jobs_started_total[5m]))

# Throughput of log bytes uploaded over 5m interval
sum(rate(buildkite_agent_logs_bytes_uploaded_total[5m]))
```

## Datadog metrics

The Buildkite Agent supports sending metrics to Datadog via DogStatsD for monitoring and observability.

To enable Datadog metrics, start the agent with the `--metrics-datadog` option or set `metrics-datadog=true` in the agent's configuration file.

```shell
buildkite-agent start --metrics-datadog
```

Additional configuration options:

Option                              | Description
----------------------------------- | -----------
`--metrics-datadog-host`           | The DogStatsD instance to send metrics to using UDP.<br>_Environment variable:_ `BUILDKITE_METRICS_DATADOG_HOST`<br>_Default:_ `127.0.0.1:8125`
`--metrics-datadog-distributions`  | Use [Datadog Distributions](https://docs.datadoghq.com/metrics/types/?tab=distribution#metric-types) for timing metrics. This is recommended when running multiple agents to prevent metrics from multiple agents from being rolled up and appearing to have the same value.<br>_Environment variable:_ `BUILDKITE_METRICS_DATADOG_DISTRIBUTIONS`<br>_Default:_ `false`
{: class="responsive-table"}

Once enabled, the agent will generate the following metrics (duration measured in milliseconds):

- `buildkite.jobs.success`
- `buildkite.jobs.duration.success.avg`
- `buildkite.jobs.duration.success.max`
- `buildkite.jobs.duration.success.count`
- `buildkite.jobs.duration.success.median`
- `buildkite.jobs.duration.success.95percentile`

## Tracing

For Datadog APM or OpenTelemetry tracing, see [Tracing in the Buildkite Agent](/docs/agent/v3/self-hosted/tracing).

[systemd]: https://www.freedesktop.org/software/systemd/man/systemd-journald.service.html
[launchd]: https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html
