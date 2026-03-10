# Monitoring and observability

This page covers the best practices regarding monitoring, observability, and logging in Buildkite Pipelines.

## Telemetry operational tips

- When implementing [telemetry](/docs/agent/self-hosted/monitoring-and-observability/tracing#using-opentelemetry-tracing), start by profiling the wait and checkout times for your queues as the biggest, cheapest wins.
- Include pipeline, queue, repo path, and commit metadata in spans and events to make troubleshooting easier.
- Stream Buildkite Pipeline's telemetry data to your standard observability stack so platform-level SLOs and alerts exist alongside the app telemetry, keeping one source of truth.

### Quick checklist for using telemetry

Choose integrations based on your existing [observability](/docs/pipelines/integrations/observability/overview) tooling and needs:

- Enable [Amazon EventBridge](/docs/pipelines/integrations/observability/amazon-eventbridge) for real-time alerting when you need to integrate with AWS-native tooling. Start with setting up notifications and subscribe your alerting pipeline.
- Turn on [OpenTelemetry (OTel)](/docs/pipelines/integrations/observability/opentelemetry) export when you need vendor-neutral observability that works with your existing OTel collector. Start with job spans and queue metrics.
- If you are using [Datadog](/docs/pipelines/integrations/observability/datadog), enable agent APM tracing.
- If you are using [Backstage](/docs/pipelines/integrations/other/backstage), integrate the [Buildkite Backstage plugin](https://github.com/buildkite/backstage-plugin) to surface pipeline health and build status directly in your developer portal.
- If you are using [Honeycomb](/docs/pipelines/integrations/observability/honeycomb), send build events and traces to enable high-cardinality analysis of pipeline performance and failures.

### Core pipeline telemetry recommendations

Establish standardized metrics collection across all pipelines to enable consistent [monitoring](/docs/agent/self-hosted/monitoring-and-observability) and analysis:

- Track build times by pipeline, step, and queue to identify performance bottlenecks with build duration metrics.
- Monitor agent availability and scaling efficiency across different workload types by tracking queue wait times.
- Measure success rates by pipeline, branch, and time period to identify reliability trends through failure rate analysis.
- Standardize retry counts for flaky tests and assign custom exit statuses that you can report on with your telemetry provider.
- Track retry success rates by exit code to differentiate between transient failures worth retrying and permanent failures that need fixing.
- Use [OTel integration](/docs/pipelines/integrations/observability/opentelemetry#opentelemetry-tracing-notification-service) to gain deep visibility into pipeline execution flows.

### Using analytics for performance improvement

- Monitor build duration, throughput, and success rate as key metrics. Use [OTel integration](/docs/pipelines/integrations/observability/opentelemetry) and [queue metrics](/docs/pipelines/insights/queue-metrics).
- You can also use [OTel integration](/docs/pipelines/integrations/observability/opentelemetry) to identify the slowest steps and optimize them through bottleneck analysis.
- Look for repeated error types with failure clustering.

## Logging and monitoring

- Favor JSON or other parsable formats for structured logs, as such formats can be easily queried when debugging. Use [log groups](/docs/pipelines/configure/managing-log-output#grouping-log-output) to better represent relevant sections in the logs visually.
- Differentiate between info, warnings, and errors by using appropriate log levels.
- Store logs, reports, and binaries as [artifacts](/docs/pipelines/configure/artifacts) for debugging and compliance.
- Use [cluster insights](/docs/pipelines/insights/clusters) or external tools to analyze durations and failure patterns to track trends.
- Avoid creating log files that are too large. Large log files make it harder to troubleshoot issues and are harder to manage in the Buildkite Pipelines' interface.
    * To avoid overly large log files, try not to use verbose output of apps and tools unless needed. See also [Managing log output](/docs/pipelines/configure/managing-log-output#log-output-limits).
    * If you are using Bazel, note that Bazel's log file is extremely verbose. Instead, consider using the [Bazel BEP Failure Analyzer Buildkite Plugin](https://buildkite.com/resources/plugins/buildkite-plugins/bazel-annotate-buildkite-plugin/) to get a simplified view of the error(s).

### Set relevant alerts

- Notify responsible teams for failing builds with [failure alerts](/docs/pipelines/configure/notifications#slack-channel-and-direct-messages-conditional-slack-notifications).
- Detect bottlenecks when builds queue too long by monitoring queue depth. You can use [queue metrics (insights)](/docs/pipelines/insights/queue-metrics) for this.
- Trigger alerts when agents go offline or degrade to monitor agent health. If individual agent health is less of a concern, then terminate an unhealthy instance and spin up a new one.

## Getting metrics out of Buildkite Pipelines

Buildkite Pipelines provides multiple ways to export CI/CD metrics depending on your needs (agent fleet health, build performance, trace correlation, test quality, and so on) and where you want the data (Datadog, Prometheus, Grafana, CloudWatch, your own OpenTelemetry collector, or Buildkite's built-in dashboards).

Most teams need two or three of these approaches working together, as they are complementary rather than competing. The following sections introduce each approach, explain when to use it, and link to detailed setup documentation.

### Decision matrix

What you want to measure | Best approach | Plan tier | Push or pull | Key destinations
--- | --- | --- | --- | ---
Agent fleet health (agents online, busy, idle per queue) | [buildkite-agent-metrics](/docs/agent/self-hosted/monitoring-and-observability#buildkite-agent-metrics-cli) | All | Pull (polls Buildkite API) | Prometheus, StatsD/DogStatsD to Datadog, CloudWatch
Agent process metrics (goroutines, memory, GC) | [Agent health check service](/docs/agent/self-hosted/monitoring-and-observability#health-checking-metrics-and-status-page) | All | Pull (Prometheus scrape) | Prometheus
Build and job lifecycle traces (spans, durations, wait times). The `buildkite.job` span includes the pipeline slug, build number, and a `wait_time_ms` attribute. You can also use a [Signals to Metrics Connector](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/10f63383121cea32bcbc32ecc76fe9e431332816/connector/signaltometricsconnector/README.md) to produce metrics from spans | [OpenTelemetry notification service](/docs/pipelines/integrations/observability/opentelemetry#opentelemetry-tracing-notification-service) | Enterprise | Push (OTel) | Any OTel-compatible collector ([Honeycomb](/docs/pipelines/integrations/observability/honeycomb), Grafana Tempo, [Datadog](/docs/pipelines/integrations/observability/datadog), and others)
Agent-side job execution traces | [OpenTelemetry agent tracing](/docs/agent/self-hosted/monitoring-and-observability/tracing) | All | Push (OTel) | Any OTel-compatible collector
Queue depth, wait times, concurrency | [Cluster insights](/docs/pipelines/insights/clusters) and [GraphQL API](/docs/apis/graphql-api) | Varies | Pull or UI | Built-in UI; GraphQL for custom dashboards
Build events for alerting and dashboards | [Webhooks](/docs/apis/webhooks) and [Amazon EventBridge](/docs/pipelines/integrations/observability/amazon-eventbridge) | All | Push | PagerDuty, Datadog, custom endpoints
Test performance and flaky tests | [Test Engine](/docs/test-engine) | Add-on | UI and API | Built-in UI; API for export
{: class="responsive-table"}

> 📘 buildkite-agent-metrics and the agent health check service are different tools
> The [buildkite-agent-metrics](/docs/agent/self-hosted/monitoring-and-observability#buildkite-agent-metrics-cli) tool gives you fleet-level queue and agent counts by polling the Buildkite API. The agent's [health check service](/docs/agent/self-hosted/monitoring-and-observability#health-checking-metrics-and-status-page) exposes per-agent process health through a Prometheus endpoint on the agent binary itself. You likely want both.

## Metrics approaches in detail

Each approach below covers a different aspect of CI/CD observability available in Buildkite Pipelines. Most teams combine two or three of these to get full coverage across fleet health, build performance, and test quality.

### Fleet health dashboard

[buildkite-agent-metrics](/docs/agent/self-hosted/monitoring-and-observability#buildkite-agent-metrics-cli) is a standalone binary (separate from the agent) that polls the Buildkite API and exports agent and queue metrics.

**Metrics provided:**

- Agents: total, busy, idle counts per queue
- Jobs: running, scheduled, waiting counts
- Queue depth and wait times

**Supported destinations:**

- **Prometheus** — exposes a `/metrics` endpoint for scraping
- **StatsD** — emits StatsD-format metrics, which is also the path to get metrics into [Datadog](/docs/pipelines/integrations/observability/datadog) (configure DogStatsD as the StatsD receiver)
- **CloudWatch** — publishes directly to AWS CloudWatch Metrics

Use this approach when you want a fleet-level view of agent capacity and [queue](/docs/agent/queues) health in your external monitoring tool. This is the primary path for getting agent metrics into Datadog, Prometheus, or CloudWatch.

> 📘 Getting agent metrics into Datadog
> To get Buildkite agent metrics into Datadog, configure `buildkite-agent-metrics` with the StatsD backend pointed at a DogStatsD receiver (the Datadog Agent's built-in StatsD server). See the [buildkite-agent-metrics CLI documentation](/docs/agent/self-hosted/monitoring-and-observability#buildkite-agent-metrics-cli) for setup details.

This tool polls the Buildkite API, so it shows point-in-time snapshots rather than event-level granularity. It doesn't cover build lifecycle events or trace data.

### Per-agent process health

The Buildkite agent's [health check service](/docs/agent/self-hosted/monitoring-and-observability#health-checking-metrics-and-status-page) includes a native Prometheus-compatible `/metrics` endpoint served by the agent process itself (available since agent version 3.113.0).

**Metrics provided:**

- Go runtime metrics: goroutines, memory allocation, GC pause times
- Agent process health: uptime, version info

Use this approach when you run Prometheus and want to monitor agent process health alongside your other infrastructure. It's useful for detecting agent crashes, memory leaks, or degraded agents.

This endpoint shows individual agent process health, not fleet-level queue or capacity data. For fleet-level metrics, use [buildkite-agent-metrics](/docs/agent/self-hosted/monitoring-and-observability#buildkite-agent-metrics-cli) alongside it.

### Build lifecycle traces with OpenTelemetry

The [OpenTelemetry tracing notification service](/docs/pipelines/integrations/observability/opentelemetry#opentelemetry-tracing-notification-service) pushes build and job lifecycle events as OpenTelemetry (OTel) traces to your collector.

**Data provided (as trace spans):**

- Build lifecycle: created, scheduled, running, finished
- Job lifecycle with durations, wait times, queue information
- Pipeline and organization metadata as span attributes

**Supported destinations:** Any OTel-compatible backend, including [Honeycomb](/docs/pipelines/integrations/observability/honeycomb), Grafana, [Datadog](/docs/pipelines/integrations/observability/datadog) APM, Jaeger, or your own OpenTelemetry collector.

Use this approach when you have an existing distributed tracing setup and want CI/CD events to appear as spans alongside your application traces. It's best for correlating build activity with deployments and service health.

> 🚧 Enterprise only feature
> The OpenTelemetry tracing notification service requires an Enterprise plan. It provides traces (spans), not traditional metrics (gauges or counters). If you need time-series metrics, you need to derive them from spans in your backend (for example, using span-to-metrics features in Datadog or Grafana).

### Agent-side execution traces

The Buildkite agent can emit [OpenTelemetry spans](/docs/agent/self-hosted/monitoring-and-observability/tracing) for job execution, providing execution-side trace context.

**Data provided (as trace spans):**

- Job checkout, plugin, command, and artifact upload phases as individual spans
- Execution timing for each phase

**Supported destinations:** Any OTel-compatible backend.

Use this approach when you want end-to-end trace context flowing from your application code through CI and back. This works alongside the [notification service](#build-lifecycle-traces-with-opentelemetry), as they are complementary:

- **Notification service** provides control-plane lifecycle (build created, scheduled, running)
- **Agent tracing** provides execution-side detail (checkout, plugins, command, artifacts)

### Built-in cluster insights dashboards

Buildkite's built-in [cluster insights](/docs/pipelines/insights/clusters) dashboards show queue health, wait times, agent utilization, and concurrency.

**Metrics provided:**

- Queue depth and wait times over time
- Agent utilization and concurrency
- Job throughput

Use this approach for quick visual checks of CI health without any external tooling. This is useful for debugging queue backups or capacity issues in real time. For queue-specific data, see [queue metrics](/docs/pipelines/insights/queue-metrics).

Note that some of the data shown in cluster insights is not yet available through an external export path (API, OpenTelemetry, or otherwise).

### Custom dashboards with the GraphQL API

Buildkite's [GraphQL API](/docs/apis/graphql-api) exposes build, job, agent, pipeline, and queue data for programmatic access.

**Data available:**

- Build and job metadata, statuses, timings
- Agent and queue information
- Pipeline configuration and metrics

Use this approach when building custom dashboards (for example, in Retool or Grafana using a JSON API datasource), automation scripts, or when feeding data into your own data warehouse.

This is a polling-based approach, so you need to build your own scheduling to keep data fresh. [Rate limits](/docs/apis/graphql/graphql-resource-limits#rate-limits) apply.

### Real-time events with webhooks and EventBridge

Buildkite pushes build, job, and agent lifecycle events to your HTTP endpoints ([webhooks](/docs/apis/webhooks)) or [Amazon EventBridge](/docs/pipelines/integrations/observability/amazon-eventbridge).

**Events available:**

- Build created, started, finished, blocked
- Job scheduled, started, finished, activated
- Agent connected, disconnected, stopped

**Supported destinations:** Any HTTP endpoint (PagerDuty, Datadog webhook intake, custom services), or Amazon EventBridge to Lambda, SQS, or SNS.

Use this approach for event-driven alerting (for example, notifying a team when a build fails), feeding CI events into incident management systems, or building custom integrations. You can also configure [pipeline-level notifications](/docs/pipelines/configure/notifications) directly in your pipeline YAML.

### Test-level performance metrics

[Buildkite Test Engine](/docs/test-engine) ingests test results and provides test-level metrics.

**Metrics provided:**

- Test duration trends
- Flaky test detection and rates
- Pass and fail rates over time
- Slowest tests

Use this approach when you care about test health independently from build infrastructure health. It's best for engineering teams focused on test suite reliability and performance.

Test Engine is a separate product from build and agent metrics. It covers test execution quality, not CI infrastructure health.

## Common metrics recipes

The following recipes show how to connect Buildkite Pipelines' metrics to popular destinations. Each one maps a common goal to the right approach and configuration.

### Agent metrics in Datadog

Configure [buildkite-agent-metrics](/docs/agent/self-hosted/monitoring-and-observability#buildkite-agent-metrics-cli) to emit StatsD metrics and point it at your Datadog Agent's DogStatsD listener (default: `localhost:8125`). This gives you agent counts, queue depth, and job counts as Datadog metrics that you can graph and alert on.

```bash
buildkite-agent-metrics -backend statsd \
  -statsd-host localhost:8125 \
  -token $BUILDKITE_AGENT_TOKEN
```

### Build traces in Honeycomb or Grafana Tempo

Set up the [OpenTelemetry tracing notification service](/docs/pipelines/integrations/observability/opentelemetry#opentelemetry-tracing-notification-service) to push to your OTel endpoint. For deeper execution-phase spans, also enable [agent-level OpenTelemetry tracing](/docs/agent/self-hosted/monitoring-and-observability/tracing). Together they provide control-plane lifecycle and execution detail.

### Queue wait times in Prometheus

Run [buildkite-agent-metrics](/docs/agent/self-hosted/monitoring-and-observability#buildkite-agent-metrics-cli) with the Prometheus backend and scrape its `/metrics` endpoint. You get queue-level wait time metrics. For more granular per-job wait times, use OpenTelemetry traces, which provide span durations rather than traditional gauges.

### Build failure alerts in PagerDuty

Configure a [webhook notification service](/docs/apis/webhooks) to send `build.finished` events to PagerDuty's Events API. Filter on `build.state == "failed"` in PagerDuty's event rules. You can also use [conditional notifications](/docs/pipelines/configure/notifications#conditional-notifications) in your pipeline YAML to send alerts to specific channels.

### Pipeline performance data collection

Poll the [GraphQL API](/docs/apis/graphql-api) for build and job data on a schedule and store it in your own data warehouse. The API has time window limits on queryable data, so start collecting early. For built-in historical views, [cluster insights](/docs/pipelines/insights/clusters) provides some data with limited time ranges.

### Per-agent process health in Prometheus

Enable the agent's [health check service](/docs/agent/self-hosted/monitoring-and-observability#health-checking-metrics-and-status-page) and add the `/metrics` endpoint to your Prometheus scrape config. This gives you Go runtime metrics for each agent process, which is useful for detecting degraded or unhealthy agents.

## Current limitations

The following are the areas where the current metrics capabilities have known limitations:

- **Metrics export parity:** [Cluster insights](/docs/pipelines/insights/clusters) shows data that can't be fully replicated through any external export path today. If you are building external dashboards, some metrics might not be available for export yet.
- **OpenTelemetry enrichment:** Additional span attributes such as build metadata, trigger context, and span links for triggered builds are being actively improved.
- **Historical data:** Current cluster insights and [queue metrics](/docs/pipelines/insights/queue-metrics) have limited lookback periods. If you need longer time windows for capacity planning, consider using the [GraphQL API](/docs/apis/graphql-api) to collect and store data in your own warehouse.
- **Traces and metrics gap:** OpenTelemetry exports are trace-based (spans), but some workflows require traditional time-series metrics (gauges, counters). Converting spans to metrics requires backend-side processing that not all observability stacks handle well.
- **Event payload coverage:** [Webhooks](/docs/apis/webhooks) and [Amazon EventBridge](/docs/pipelines/integrations/observability/amazon-eventbridge) event payloads don't include all metadata, such as retry context and manual-versus-automatic action flags.
