# Using Buildkite with Honeycomb

[Honeycomb](https://www.honeycomb.io/) is an observability and application performance management (APM) platform that helps you monitor and debug your applications.

Honeycomb offers several advantages for Buildkite users:

- **Free plan available** - start monitoring your builds without additional costs.
- **Build grouping** - group traced jobs into a single build for better visibility.
- **Comprehensive tracing** - track performance and identify bottlenecks in your CI/CD pipeline.

## Honeycomb integration methods

You can integrate Honeycomb with Buildkite using three methods:

1. [**buildevents binary**](https://github.com/honeycombio/buildevents) - captures detailed trace telemetry for each build step.
2. [**OpenTelemetry tracing**](/docs/pipelines/integrations/observability/opentelemetry#opentelemetry-tracing-notification-service-honeycomb) - sends traces directly from the Buildkite agent.
3. [**Honeycomb Marker Buildkite plugin**](https://www.honeycomb.io/integration/buildkite-markers) - adds Buildkite markers to your traces. However, we do not recommend using this community-maintained plugin for the reasons of best security practices and frequency of updates and advise using the buildevents binary or OpenTelemetry-based approaches.

## Buildkite buildevents

The [buildevents binary](https://github.com/honeycombio/buildevents) generates trace telemetry for your builds. It captures invocation details and command outputs, creating a comprehensive trace of your entire build process.

### How it works

The Buildkite buildevents binary:

- Creates spans for each build section and subsection.
- Tracks the duration of each stage or command.
- Records success/failure status and additional metadata.
- Sends the complete trace to Honeycomb when the build finishes.

### Buildkite buildevents trace structure

Each trace contains:

- **Spans** - individual or grouped executed commands.
- **Duration data** - runtime for each stage or command.
- **Status information** - success or failure details.
- **Custom metadata** - additional data you choose to capture.

<%= image "honeycomb-buildevents.png", size: '1030x1236', alt: 'Buildkite buildevents in the Honeycomb interface' %>

The buildevents script needs a unique Trace ID to join together all of the steps and commands with the build. You can use Buildkite's `BUILDKITE_BUILD_ID` environment variable since it is both unique (even when re-running builds, you will get a new `BUILDKITE_BUILD_ID`) and is also a primary value that the build system uses to identify the build.

You can get started with using Buildkite buildevents by following the [installation instructions](https://github.com/honeycombio/buildevents?tab=readme-ov-file#installation).

Since Honeycomb maintains the buildevents integration, direct questions and feature requests to the [Honeycomb Support Portal](https://www.honeycomb.io/support).

## OpenTelemetry tracing

You can send traces from the Buildkite agent to Honeycomb with the help of OpenTelemetry by following these steps:

1. Enable OpenTelemetry tracing by setting the `--tracing-backend opentelemetry` flag on your Buildkite agent.
2. Set the following values in the environment where you are running the Buildkite agent:

```yaml
OTEL_EXPORTER_OTLP_TRACES_ENDPOINT="https://api.honeycomb.io"
OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=<api_key>"
OTEL_SERVICE_NAME="buildkite-agent"
```

Replace `<api_key>` with your actual Honeycomb API key.

For more details, see the [OpenTelemetry tracing documentation](/docs/agent/v3/tracing#using-opentelemetry-tracing).
