# Tracing in the Buildkite Agent

Distributed tracing tools like [Datadog APM](https://www.datadoghq.com/product/apm/) or [OpenTelemetry](https://opentelemetry.io/) tracing allow you to gain more insight into the performance of your CI runs - what's fast, what's slow, what could be optimized, and more importantly, how these things are changing over time.

The Buildkite agent currently supports the two tracing backends listed above, Datadog APM (using OpenTracing) and OpenTelemetry. This doc will guide you through setting up tracing using either of these backends.

## Using Datadog APM

To use the Datadog Application Performance Monitoring (APM) integration, start the Buildkite agent with the `--tracing-backend datadog` option. This will enable Datadog APM tracing, and send the traces to a Datadog agent at `localhost:8126` by default. If your Datadog agent is located at another host, the Buildkite agent will respect the `DD_AGENT_HOST` and `DD_TRACE_AGENT_PORT` environment variables defined by [`dd-trace-go`](https://docs.datadoghq.com/tracing/trace_collection/library_config/go/#traces). Note that there will need to be a Datadog agent present at the above address to ingest these traces.

Once this is done, the agent will start sending tracing information to Datadog. You can observe traces as they come in in the APM > Traces screen in your Datadog instance.

## Using OpenTelemetry tracing

To use OpenTelemetry tracing, start the Buildkite Agent with the `--tracing-backend opentelemetry` option. This will enable OpenTelemetry tracing, and start sending traces to an OpenTelemetry collector.

The Buildkite agent's OpenTelemetry implementation uses the OTLP gRPC exporter to export trace information. This means that there must be a collector capable of ingesting OTLP gRPC traces accessible by the Buildkite agent. By default, the Buildkite agent will export trace information to `http://localhost:4317`, but this can be overridden by passing in an environment variable `OTEL_EXPORTER_OTLP_ENDPOINT` containing an updated endpoint for the collector when the agent is started.

See the OpenTelemetry documentation for more information on supported environment variables.

https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/
https://opentelemetry.io/docs/specs/otel/protocol/exporter/#endpoint-urls-for-otlphttp

> 🚧 Note on OTLP protocol
> The Buildkite agent currently only supports the `grpc` transport for OpenTelemetry, and cannot currently be overridden using the `OTEL_EXPORTER_OTLP_PROTOCOL` environment variable.

To set the OpenTelemetry service name, provide the `--tracing-service-name example-buildkite-agent`. The default service name when not specified is `buildkite-agent`.

If using the OpenTelemetry Tracing Notification Service, you can provide the `--tracing-propagate-traceparent` flag to propagate traces from the Buildkite control plane, and through to your Agent trace spans.

For more information on the OpenTelemetry integrations see: [OpenTelemetry](/docs/pipelines/integrations/observability/opentelemetry).
