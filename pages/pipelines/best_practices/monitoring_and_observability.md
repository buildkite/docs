# Monitoring and observability

This page covers the best practices regarding monitoring, observability, and logging in Buildkite Pipelines.

## Telemetry operational tips

- When implementing [telemetry](/docs/agent/v3/tracing#using-opentelemetry-tracing), start by profiling the wait and checkout times for your queues as the biggest, cheapest wins.
- Include pipeline, queue, repo path, and commit metadata in spans and events to make troubleshooting easier.
- Stream Buildkite Pipeline's telemetry data to your standard observability stack so platform-level SLOs and alerts exist alongside the app telemetry, keeping one source of truth.

### Quick checklist for using telemetry

Choose integrations based on your existing tooling and needs:

- Enable [Amazon EventBridge](/docs/pipelines/integrations/observability/amazon-eventbridge) for real time alerting when you need to integrate with AWS-native tooling. Start with setting up notifications and subscribe your alerting pipeline.
- Turn on [OpenTelemetry (OTEL)](/docs/pipelines/integrations/observability/opentelemetry) export when you need vendor-neutral observability that works with your existing OTEL collector. Start with job spans and queue metrics.
- If you are using [Datadog](https://buildkite.com/docs/pipelines/integrations/observability/datadog), enable agent APM tracing.
- If you are using [Backstage](/docs/pipelines/integrations/other/backstage), integrate the [Buildkite Backstage plugin](https://github.com/buildkite/backstage-plugin) to surface pipeline health and build status directly in your developer portal.
- If you are using [Honeycomb](/docs/pipelines/integrations/observability/honeycomb), send build events and traces to enable high-cardinality analysis of pipeline performance and failures.

### Core pipeline telemetry recommendations

Establish standardized metrics collection across all pipelines to enable consistent monitoring and analysis:

- Track build times by pipeline, step, and queue to identify performance bottlenecks with build duration metrics.
- Monitor agent availability and scaling efficiency across different workload types by tracking queue wait times.
- Measure success rates by pipeline, branch, and time period to identify reliability trends through failure rate analysis.
- Track retry success rates by exit code to identify transient failures that are worth retrying as opposed to permanent failures that need fixing.
- Standardize the number of times test flakes are retried and have their custom exit statuses that you can report on with your telemetry provider.
- Use [OpenTelemetry integration](/docs/pipelines/integrations/observability/opentelemetry#opentelemetry-tracing-notification-service) to gain deep visibility into pipeline execution flows.

### Using analytics for performance improvement

- Monitor build duration, throughput, and success rate as key metrics. Use the [OTEL integration](/docs/pipelines/integrations/observability/opentelemetry) and [queue metrics](/docs/pipelines/insights/queue-metrics).
- You can also use [OTEL integration](/docs/pipelines/integrations/observability/opentelemetry) to identify the slowest steps and optimize them through bottleneck analysis.
- Look for repeated error types with failure clustering.

## Logging and monitoring

- Favor JSON or other parsable formats for structured logs as such formats can be easily queried when debugging. Use [log groups](/docs/pipelines/configure/managing-log-output#grouping-log-output) to better represent relevant sections in the logs visually.
- Differentiate between info, warnings, and errors by using appropriate log levels.
- Store logs, reports, and binaries as [artifacts](/docs/pipelines/configure/artifacts) for debugging and compliance.
- Use [cluster insights](/docs/pipelines/insights/clusters) or external tools to analyze durations and failure patterns to track trends.
- Avoid creating log files that are too large. Large log files make it harder to troubleshoot issues and are harder to manage in the Buildkite Pipelines' interface.
    * To avoid overly large log files, try not to use verbose output of apps and tools unless needed. See also [Managing log output](/docs/pipelines/configure/managing-log-output#log-output-limits).
    * If you are using Bazel, note that Bazel's log file is extremely verbose. Instead, consider using the [Bazel BEP Failure Analyzer Buildkite Plugin](https://buildkite.com/resources/plugins/buildkite-plugins/bazel-annotate-buildkite-plugin/) to get a simplified view of the error(s).

### Set relevant alerts

- Notify responsible teams for failing builds with [failure alerts](/docs/pipelines/configure/notifications#slack-channel-and-direct-messages-conditional-slack-notifications).
- Detect bottlenecks when builds queue too long by monitoring queue depth—you can use [queue metrics (insights)](/docs/pipelines/insights/queue-metrics) for this.
- Trigger alerts when agents go offline or degrade to monitor agent health. If individual agent health is less of a concern, then terminate an unhealthy instance and spin up a new one.
