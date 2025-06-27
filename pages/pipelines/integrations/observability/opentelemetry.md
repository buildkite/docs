---
keywords: OpenTelemetry, tracing, observability, Datadog, honeycomb, otlp
---

# OpenTelemetry

[OpenTelemetry](https://opentelemetry.io/) is an open standard for instrumenting, processing and collecting observability data.

Buildkite supports sending [OpenTelemetry Traces](https://opentelemetry.io/docs/concepts/signals/traces/) directly from the Buildkite agent, and (in Private Preview) the Buildkite control plane to your OTLP endpoint.

## OpenTelemetry tracing from Buildkite agent

See [Tracing in the Buildkite Agent](/docs/agent/v3/tracing#using-opentelemetry-tracing).

### Required agent flags / environment variables

To propagate traces from the Buildkite control plane through to the agent running the job, include the following CLI flags to `buildkite-agent start` and include the appropriate environment variables to specify OpenTelemetry collector details.

| Flag                              | Environment Variable                      | Value                                              |
| --------------------------------- | ----------------------------------------- | -------------------------------------------------- |
| `--tracing-backend`               | `BUILDKITE_TRACING_BACKEND`               | `opentelemetry`                                    |
| `--tracing-propagate-traceparent` | `BUILDKITE_TRACING_PROPAGATE_TRACEPARENT` | `true` (default: `false`)                          |
| `--tracing-service-name`          | `BUILDKITE_TRACING_SERVICE_NAME`          | `buildkite-agent` (default)                        |
|                                   | `OTEL_EXPORTER_OTLP_ENDPOINT`             | `http://otel-collector:4317`                       |
|                                   | `OTEL_EXPORTER_OTLP_HEADERS`              | `"Authorization=Bearer <token>,x-my-header=value"` |
|                                   | `OTEL_EXPORTER_OTLP_PROTOCOL`             | `grpc`                                             |

### Propagating traces to Buildkite agents

Propagating trace spans from the OpenTelemetry Notification service requires Buildkite agent [v3.100](https://github.com/buildkite/agent/releases/tag/v3.100.0) or newer, and the `--tracing-propagate-traceparent` flag or equivalent environment variable.

### Buildkite hosted agents

To export OpenTelemetry traces from hosted agents, this currently requires using a custom Agent Image with the following Environment variables set.

```dockerfile
# this is the same as --tracing-backend opentelemetry
ENV BUILDKITE_TRACING_BACKEND="opentelemetry"

# this is the same as --tracing-propagate-traceparent
ENV BUILDKITE_TRACING_PROPAGATE_TRACEPARENT="true"

# service name is configurable
ENV OTEL_SERVICE_NAME="buildkite-agent"

# the agent OpenTelemetry exporter only supports gRPC transport
ENV OTEL_EXPORTER_OTLP_PROTOCOL="grpc"

# the gRPC transport requires a port to be specified in the URL
ENV OTEL_EXPORTER_OTLP_ENDPOINT="http://otel-collector:4317"

# authentication of traces is done via tokens in headers
ENV OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer <token>,x-my-header=value"
```

## OpenTelemetry tracing notification service

> 📘 Preview feature
> OpenTelemetry Tracing Notification Service is currently in Private Preview. Please contact support@buildkite.com or your account team for access.

To provide a build-wide view of Build performance, enable the OpenTelemetry Tracing

### Creating a new service

[Create a new OpenTelemetry Notification Service](https://buildkite.com/organizations/~/services/) in your organization's Notification Services settings (under Integrations).

<%= image "form.png", width: 1110/2, height: 1110/2, alt: "Screenshot of OpenTelemetry Notification Service settings" %>

### Endpoint

Please provide the base URL for your OTLP endpoint. Do not include the `/v1/traces` path as that automatically appended by the Buildkite OpenTelemetry exporter.

#### Limitations

- We currently only support the [OTLP/HTTP](https://opentelemetry.io/docs/specs/otlp/#otlphttp) binary protobuf encoding.
- We currently only support sending [trace](https://opentelemetry.io/docs/concepts/signals/traces/) data, but may introduce other OpenTelemetry signals in the future.
- The endpoint must be accessible over the internet. Contact support@buildkite.com if you would like to send traces to a [AWS PrivateLink endpoint](https://docs.aws.amazon.com/vpc/latest/privatelink/what-is-privatelink.html).

### Headers

Add any additional HTTP headers to the request. Depending on the destination, you may need to specify API keys or other headers to influence the behaviour of the downstream collector. Values for headers are always stored encrypted server-side.

Here are some common examples.

#### Bearer token

Key: `Authorization`
Value: `Bearer <your-token>`

See [Bearer Token example](https://github.com/buildkite/opentelemetry-notification-service-examples/blob/main/collector-config/bearer-token-auth-debug.yml) for example OpenTelemetry Collector configuration.

#### Basic auth

First, create a base64 encoded string of the username and password separated by a colon.

```bash
echo -n "${USER}:${PASSWORD}" | base64
```

Key: `Authorization`
Value: `Basic <base64 encoded ${USER}:${PASSWORD})>`

See [Basic Authentication example](https://github.com/buildkite/opentelemetry-notification-service-examples/blob/main/collector-config/basic-auth-debug.yml) for example OpenTelemetry Collector configuration.

### Honeycomb

Set the Endpoint to `https://api.honeycomb.io`, or `https://api.eu1.honeycomb.io ` if your Honeycomb team is in the EU instance.

Add the require header:

| Key                | Value                 |
| ------------------ | --------------------- |
| `x-honeycomb-team` | `<Honeycomb API key>` |

For more information, see the honeycomb documentation: https://docs.honeycomb.io/send-data/opentelemetry/#using-the-honeycomb-opentelemetry-endpoint

### Datadog agent-less OpenTelemetry

Endpoint: `https://trace.agent.datadoghq.com/api/v0.2/traces`

Add the required headers:

| Key              | Value               |
| ---------------- | ------------------- |
| `dd-protocol`    | `otlp`              |
| `dd-api-key`     | `<Datadog API key>` |
| `dd-otlp-source` | `${YOUR_SITE}`      |

Replace `${YOUR_SITE}` with the organization name you received from Datadog.

For more information, see the Datadog documentation:

https://docs.datadoghq.com/opentelemetry/setup/agentless/traces/

### Datadog APM via OpenTelemetry collector

See [Bearer token Datadog example](https://github.com/buildkite/opentelemetry-notification-service-examples/blob/main/collector-config/bearer-token-auth-datadog.yml) for more information on forwarding traces to Datadog APM using the Datadog exporter.

### Computing metrics from OpenTelemetry traces

The OpenTelemetry collector can be used to process incoming trace spans and generate custom metrics on the fly using the [signaltometrics](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/connector/signaltometricsconnector) processor, which can be stored in metric stores like Prometheus or InfluxDB.

See [signaltometrics example](https://github.com/buildkite/opentelemetry-notification-service-examples/blob/main/collector-config/bearer-token-auth-signal-to-metrics-otlp.yml)

### OpenTelemetry collector

The OpenTelemetry collector is an open source service for collecting, exporting and processing telemetry signals.

See [collector-config](https://github.com/buildkite/opentelemetry-notification-service-examples/tree/main/collector-config) for examples of OpenTelemetry collector configuration.

If using the `otel/opentelemetry-collector-contrib` Docker image, you can configure the collector by mounting the your config file at `/etc/otelcol-contrib/config.yaml` or by overriding the `command` to `--config=env:OTEL_CONFIG` and setting the `OTEL_CONFIG` environment variable to the _contents_ of your config file.

Consult the [Deployment](https://opentelemetry.io/docs/collector/deployment/) guide in the OpenTelemetry documentation for more information about hosting the collector.

The OpenTelemetry collector also supports many downstream data stores via [exporters](https://opentelemetry.io/docs/collector/configuration/#exporters) including StatsD, Prometheus, Kafka, Tempo, OTLP as well as many other observability tools and vendors. See the [OpenTelemetry registry](https://opentelemetry.io/ecosystem/registry/?s=&component=exporter&language=collector) for a more complete list of supported exporters.

#### References

- https://opentelemetry.io/docs/collector/
- https://github.com/open-telemetry/opentelemetry-collector
- https://github.com/open-telemetry/opentelemetry-collector-contrib
- https://opentelemetry.io/docs/collector/configuration/#authentication
- https://hub.docker.com/r/otel/opentelemetry-collector-contrib

#### Validating OpenTelemetry collector configuration

`otelcol validate` lets you validate your [collector configuration](https://opentelemetry.io/docs/collector/configuration/).

For example, to validate one of the example configuration files in [examples repository](https://github.com/buildkite/opentelemetry-notification-service-examples/tree/main/collector-config), say `basic-auth-debug.yml` you could run the following command:

```bash
docker run --rm -it -v $(pwd)/collector-config:/config otel/opentelemetry-collector-contrib validate --config=/config/basic-auth-debug.yml && echo "config valid"
```

Or for a configuration file like `bearer-token-auth-datadog.yml` that references environment variables, you would run the following command, noting the `-e` flags to provide the environment variables:

```bash
docker run --rm -e DD_API_KEY=abcd -e OTLP_HTTP_BEARER_TOKEN=example -it -v $(pwd)/collector-config:/config otel/opentelemetry-collector-contrib validate --config=/config/bearer-token-auth-datadog.yml && echo "config valid"
config valid
```

There is also an online validation tool available at https://www.otelbin.io/
