# Monitoring and observability

## Logging best practices

* Structured logs: Favor JSON or other parsable formats. Use [log groups](/docs/pipelines/configure/managing-log-output#grouping-log-output) for better visual representation of the relevant sections in the logs.
* Appropriate log levels: Differentiate between info, warnings, and errors.
* Persist artifacts: Store logs, reports, and binaries for debugging and compliance.
* Track trends: Use [cluster insights](/docs/pipelines/insights/clusters) or external tools to analyze durations and failure patterns.
* Avoid having log files that are too large. Large log files make it harder to troubleshoot the issues and are harder to manage in the Buildkite Pipelines' UI.
To avoid overly large log files, try to not use verbose output of apps and tools unless needed. See also [Managing log output](/docs/pipelines/configure/managing-log-output#log-output-limits).
* Use the [Buildkite MCP server](/docs/apis/mcp-server) to get all of the information outlined above.

### Set relevant alerts

* Failure alerts: Notify responsible teams for failing builds (relevant links will be added here).
* Queue depth monitoring: Detect bottlenecks when builds queue too long - you can make use of the [Queue insights for this](/docs/pipelines/insights/queue-metrics).
* Agent health alerts: Trigger alerts when agents go offline or degrade. If individual agent health is less of a concern, then terminate an unhealthy instance and spin a new one.

## Telemetry operational tips

* Start where the pain is: profile queue wait and checkout time first. These are often the biggest, cheapest wins.
* Tag everything: include pipeline, queue, repo path, and commit metadata in spans and events to make drill‑downs trivial.
* Keep one source of truth: stream Buildkite to your standard observability stack so platform‑level SLOs and alerts live alongside app telemetry.
* Document the path: publish internal guidance for teams on reading the Pipeline metrics page and where to find org dashboards.

### Quick checklist for using telemetry

* Enable EventBridge and subscribe your alerting pipeline.
* Turn on OTEL export to your collector. Start with job spans and queue metrics.
* If you are a Datadog shop, enable agent APM tracing.
* Stand up a “CI SLO” dashboard with p95 queue wait and build duration per top pipelines.
* Document and socialize how developers should use the Pipeline metrics page for day‑to‑day troubleshooting.

### Core pipeline telemetry recommendations

Establish standardized metrics collection across all pipelines to enable consistent monitoring and analysis:

* Build duration metrics: track build times by pipeline, step, and queue to identify performance bottlenecks.
* Queue wait times: monitor agent availability and scaling efficiency across different workload types.
* Failure rate analysis: measure success rates by pipeline, branch, and time period to identify reliability trends.
* Retry effectiveness: track retry success rates by exit code to validate retry policy effectiveness.
* Resource utilization: monitor compute usage, artifact storage, and network bandwidth consumption.

Standardize the number of times test flakes are retried and have their custom exit statuses that you can report on with your telemetry provider. Use [OpenTelemetry integration](/docs/pipelines/integrations/observability/opentelemetry#opentelemetry-tracing-notification-service) to gain deep visibility into pipeline execution flows

### Use analytics for performance improvement

* Key metrics: Monitor build duration, throughput, and success rate (a mention of OTEL integration and queue insights that can help do this will be added here).
* Bottleneck analysis: Identify slowest (using the OTEL integration) steps and optimize them.
* Failure clustering: Look for repeated error types.
