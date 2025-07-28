# Tracing in the Buildkite Agent

Distributed tracing tools like [Datadog APM](https://www.datadoghq.com/product/apm/) or [OpenTelemetry](https://opentelemetry.io/) tracing allow you to gain more insight into the performance of your CI runs - what's fast, what's slow, what could be optimized, and more importantly, how these things are changing over time.

The Buildkite agent currently supports the two tracing backends listed above, Datadog APM (using OpenTracing) and OpenTelemetry. This doc will guide you through setting up tracing using either of these backends.

## Using Datadog APM

> 📘
> If you are looking for the information on using Datadog Application Performance Monitoring (APM) tracing with Buildkite agent, you can find it in [Using Datadog APM](/docs/pipelines/integrations/observability/datadog).

## Using OpenTelemetry tracing

Before starting the agent, install and configure an OpenTelemetry Collector from the officcial [guide](https://opentelemetry.io/docs/collector/installation/). 
Once the collector is running, start the Buildkite Agent with:

```bash
buildkite-agent start --tracing-backend opentelemetry 
```

 This will enable OpenTelemetry tracing, and start sending traces to an OpenTelemetry collector.

The Buildkite agent's OpenTelemetry implementation uses the OTLP gRPC exporter to export trace information. This means that there must be a collector capable of ingesting OTLP gRPC traces accessible by the Buildkite agent. By default, the Buildkite agent will export trace information to `https://localhost:4317`, but this can be overridden by passing in an environment variable `OTEL_EXPORTER_OTLP_ENDPOINT` containing an updated endpoint for the collector when the agent is started.
Once traces are being sent, you can view the internal state of the collector by visiting the tracez debug interface:

`http://localhost:55679/debug/tracez`

This UI shows active and sampled spans and is helpful for troubleshooting your OpenTelemetry trace pipeline.

<%= image "open-telemetry.png", size: "2772x61", alt: "Open telemetry dashboard with spans" %>

> 📘 Note on OTLP protocol
> The Buildkite agent defaults to the `grpc` transport for OpenTelemetry, but can overridden using the `OTEL_EXPORTER_OTLP_PROTOCOL` environment variable to `http/protobuf` on [`v3.101.0`](https://github.com/buildkite/agent/releases/tag/v3.101.0) or more recent.

To set the OpenTelemetry service name, provide the `--tracing-service-name example-buildkite-agent`. The default service name when not specified is `buildkite-agent`.

If using the OpenTelemetry Tracing Notification Service, you can provide the `--tracing-propagate-traceparent` flag to propagate traces from the Buildkite control plane, and through to your Agent trace spans.

For more information on the OpenTelemetry integrations see: [OpenTelemetry](/docs/pipelines/integrations/observability/opentelemetry).
