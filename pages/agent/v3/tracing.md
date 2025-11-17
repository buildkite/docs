# Tracing in the Buildkite Agent

Distributed tracing tools like [Datadog APM](https://www.datadoghq.com/product/apm/) or [OpenTelemetry](https://opentelemetry.io/) tracing allow you to gain more insight into the performance of your CI runs - what's fast, what's slow, what could be optimized, and more importantly, how these things are changing over time.

The Buildkite agent currently supports the two tracing backends listed above, Datadog APM (using OpenTracing) and OpenTelemetry. This doc will guide you through setting up tracing using either of these backends.

## Using Datadog APM

If you are looking to use Datadog's Application Performance Monitoring (APM) tracing with a Buildkite Agent, [Using Datadog APM](/docs/pipelines/integrations/observability/datadog#using-datadog-apm) section of Buildkite Pipelines' [Datadog integration](/docs/pipelines/integrations/observability/datadog) documentation.

## Using OpenTelemetry tracing

Before starting the Buildkite Agent, install and configure an OpenTelemetry Collector. Learn more about this from OpenTelemetry's [Install the Collector](https://opentelemetry.io/docs/collector/installation/) page of their documentation.

Once the Collector is up and running, start the Buildkite Agent with:

```bash
buildkite-agent start --tracing-backend opentelemetry
```

This will enable OpenTelemetry tracing, and start sending traces to an OpenTelemetry Collector.

The Buildkite Agent's OpenTelemetry implementation uses the OTLP gRPC exporter to export trace information. This means that there must be a Collector capable of ingesting OTLP gRPC traces accessible by the Buildkite Agent. By default, the Buildkite Agent will export trace information to `https://localhost:4317`, but this can be overridden by passing in an environment variable `OTEL_EXPORTER_OTLP_ENDPOINT` containing an updated endpoint for the Collector when the agent is started.
Once traces are being sent, you can view the internal state of the collector by visiting the TraceZ debug interface:

`http://localhost:55679/debug/tracez`

This interface shows active and sampled spans and is helpful for troubleshooting your OpenTelemetry trace pipeline.

<%= image "open-telemetry.png", size: "2202x444", alt: "Open telemetry dashboard with spans" %>

> 📘 Note on OTLP protocol
> The Buildkite Agent defaults to the `grpc` transport for OpenTelemetry, but can overridden using the `OTEL_EXPORTER_OTLP_PROTOCOL` environment variable to `http/protobuf` on [`v3.101.0`](https://github.com/buildkite/agent/releases/tag/v3.101.0) or later versions of the Buildkite Agent.

To set the OpenTelemetry service name, provide the `--tracing-service-name example-buildkite-agent`. The default service name when not specified is `buildkite-agent`.

If using the OpenTelemetry Tracing Notification Service, you can provide the `--tracing-propagate-traceparent` flag to propagate traces from the Buildkite control plane, and through to your Agent trace spans.

Learn more about configuring the OpenTelemetry integration with Buildkite Pipelines from the [OpenTelemetry](/docs/pipelines/integrations/observability/opentelemetry) integrations page.

### Sending OpenTelemetry traces to Honeycomb

To send traces to [Honeycomb](https://www.honeycomb.io/), in addition to starting the Buildkite Agent with the `--tracing-backend opentelemetry` option, you also need to add the following environment variables. The API token provided by Honeycomb will need to be replaced in the `OTEL_EXPORTER_OTLP_HEADERS` below.

```bash
# this is the same as --tracing-backend opentelemetry
export BUILDKITE_TRACING_BACKEND="opentelemetry"
# service name is configurable
export OTEL_SERVICE_NAME="buildkite-agent"
# the agent only supports GRPC transport
export OTEL_EXPORTER_OTLP_PROTOCOL="grpc"
# the GRPC transport requires a port to be specified in the URL
export OTEL_EXPORTER_OTLP_ENDPOINT="https://api.honeycomb.io:443"
# authentication of traces is done via the API key in this header
export OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=xxxxx"
```
