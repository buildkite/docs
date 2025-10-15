---
keywords: OpenTelemetry, tracing, observability, Datadog, honeycomb, otlp
---

# OpenTelemetry

[OpenTelemetry](https://opentelemetry.io/) is an open standard for instrumenting, processing and collecting observability data.

Buildkite supports sending [OpenTelemetry Traces](https://opentelemetry.io/docs/concepts/signals/traces/) directly from the Buildkite agent, and from the Buildkite control plane, to your OTLP endpoint.

## OpenTelemetry tracing from Buildkite agent

See [Tracing in the Buildkite Agent](/docs/agent/v3/tracing#using-opentelemetry-tracing).

### Required agent flags / environment variables

To propagate traces from the Buildkite control plane through to the agent running the job, include the following CLI flags to `buildkite-agent start` and include the appropriate environment variables to specify OpenTelemetry collector details.

| Flag                              | Environment Variable                      | Value                                   |
| --------------------------------- | ----------------------------------------- | --------------------------------------- |
| `--tracing-backend`               | `BUILDKITE_TRACING_BACKEND`               | `opentelemetry`                         |
| `--tracing-propagate-traceparent` | `BUILDKITE_TRACING_PROPAGATE_TRACEPARENT` | `true` (default: `false`)               |
| `--tracing-service-name`          | `BUILDKITE_TRACING_SERVICE_NAME`          | `buildkite-agent` (default)             |
|                                   | `OTEL_EXPORTER_OTLP_ENDPOINT`             | `http://otel-collector:4317`            |
|                                   | `OTEL_EXPORTER_OTLP_HEADERS`              | See [Authentication](#authentication).  |
|                                   | `OTEL_EXPORTER_OTLP_PROTOCOL`             | `grpc` (default) or `http/protobuf`     |
|                                   | `OTEL_RESOURCE_ATTRIBUTES`                | `key1=value1,key2=value2`               |

Note: `http/protobuf` protocol is only supported on Buildkite agent [v3.101.0](https://github.com/buildkite/agent/releases/tag/v3.101.0) or newer.

See [OpenTelemetry SDK documentation](https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/) for more information on available environment variables.

#### Authentication

Authentication headers vary by provider. Below are the most commonly used authentication patterns. For specific requirements, consult the provider's documentation.

##### Bearer token

For [Honeycomb](https://docs.honeycomb.io/get-started/), [Lightstep](https://docs.lightstep.com/), and most other providers:

```bash
OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer <your-api-token>"
```

##### Basic authentication

[Grafana Cloud](https://grafana.com/docs/grafana-cloud/) requires Basic authentication with an instance ID and token, base64-encoded in the format `instance_id:token`:

```bash
OTEL_EXPORTER_OTLP_HEADERS="Authorization=Basic <base64(instance_id:token)>"
```

To encode the token in base64, run the following command:

```bash
echo -n "your-instance-id:your-token" | base64
```

##### Custom headers

Some providers (such as Honeycomb) also support custom headers:

```bash
OTEL_EXPORTER_OTLP_HEADERS="x-honeycomb-team=<your-api-key>"
```

##### Multiple headers

Multiple headers can be specified by separating values with commas:

```bash
OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer <token>,x-custom-header=value"
```

### Propagating traces to Buildkite agents

Propagating trace spans from the OpenTelemetry Notification service requires Buildkite agent [v3.100](https://github.com/buildkite/agent/releases/tag/v3.100.0) or newer, and the `--tracing-propagate-traceparent` flag or equivalent environment variable.

### Buildkite hosted agents

To export OpenTelemetry traces from hosted agents, this currently requires using a custom Agent Image with the following Environment variables set. Custom images can be created in Cluster settings, and is currently supported for Linux only.

```dockerfile
# this is the same as --tracing-backend opentelemetry
ENV BUILDKITE_TRACING_BACKEND="opentelemetry"

# this is the same as --tracing-propagate-traceparent
ENV BUILDKITE_TRACING_PROPAGATE_TRACEPARENT="true"

# service name is configurable
ENV OTEL_SERVICE_NAME="buildkite-agent"

# http/protobuf available on Buildkite agent v3.101.0 or newer
ENV OTEL_EXPORTER_OTLP_PROTOCOL="grpc"

# the gRPC transport requires a port to be specified in the URL
ENV OTEL_EXPORTER_OTLP_ENDPOINT="http://otel-collector:4317"

# Authentication can vary by provider - see the authentication examples above
# Bearer is the most common method of Authentication:
ENV OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer <token>"
# For Grafana Cloud, use Basic Authentication instead:
ENV OTEL_EXPORTER_OTLP_HEADERS="Authorization=Basic <base64(instance_id:token)>"
```

## OpenTelemetry tracing notification service

> 📘 Preview feature
> OpenTelemetry Tracing Notification Service is currently in Preview.

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

### Trace structure

OpenTelemetry traces from the Buildkite notification service follow a hierarchical span structure. All spans within a build share the same trace ID, allowing you to view the complete execution flow in your observability platform.

```
─ buildkite.build
  └─ buildkite.build.stage
    ├─ buildkite.step
    │  └─ buildkite.job
    └─ buildkite.step.group
       └─ buildkite.step
          └─ buildkite.job
```

> 📘 Build stages
> Buildkite builds that have finished may be resumed at a later time, eg. by unblocking a `block` step, or manually retrying a failed job. To represent that in the OpenTelemetry format, we add an extra `buildkite.build.stage` span for each period of time that the build is in the `running`, `scheduled`, `canceling` or `failing` state. We also include a `buildkite.build.stage` span attribute to indicate how many times the build has been resumed.

The following attributes are included in OpenTelemetry traces from the Buildkite notification service:

#### Resource attributes

[Resource](https://opentelemetry.io/docs/concepts/resources/) attributes are included in all spans and provide context about the organization, pipeline, and build:

| Key                             | Description                                          |
| ------------------------------- | ---------------------------------------------------- |
| `service.name`                  | Service name (configurable, defaults to `buildkite`) |
| `buildkite.organization.slug`   | Organization slug                                    |
| `buildkite.organization.name`   | Organization name                                    |
| `buildkite.organization.id`     | Organization ID                                      |
| `buildkite.pipeline.slug`       | Pipeline slug                                        |
| `buildkite.pipeline.name`       | Pipeline name                                        |
| `buildkite.pipeline.id`         | Pipeline ID                                          |
| `buildkite.pipeline.repo`       | Pipeline repository URL                              |
| `buildkite.pipeline.graphql_id` | Pipeline GraphQL ID                                  |
| `buildkite.pipeline.web_url`    | Pipeline web URL                                     |
| `buildkite.cluster.id`          | Cluster ID (if pipeline uses a cluster)              |
| `buildkite.cluster.name`        | Cluster name (if pipeline uses a cluster)            |
| `buildkite.cluster.graphql_id`  | Cluster GraphQL ID (if pipeline uses a cluster)      |

#### Span attributes

[Span attributes](https://opentelemetry.io/docs/concepts/signals/traces/#attributes) are specific to certain span types:

| Key                                  | Spans                                                                              | Description                                                 |
| ------------------------------------ | ---------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| `buildkite.build.number`             | All                                                                                | Build number                                                |
| `buildkite.build.commit`             | All                                                                                | Build commit SHA                                            |
| `buildkite.build.message`            | All                                                                                | Build commit message                                        |
| `buildkite.build.branch`             | All                                                                                | Build branch                                                |
| `buildkite.build.source`             | All                                                                                | Build source (`ui`, `api`, `webhook`, etc.)                 |
| `buildkite.build.graphql_id`         | All                                                                                | Build GraphQL ID                                            |
| `buildkite.build.web_url`            | All                                                                                | Build web URL                                               |
| `buildkite.build.creator.id`         | All (when build creator exists)                                                    | Build creator ID                                            |
| `buildkite.build.creator.email`      | All (when build creator exists)                                                    | Build creator email                                         |
| `buildkite.build.creator.name`       | All (when build creator exists)                                                    | Build creator name                                          |
| `buildkite.build.creator.graphql_id` | All (when build creator exists)                                                    | Build creator GraphQL ID                                    |
| `buildkite.build.state`              | `buildkite.build`, `buildkite.build.stage`                                         | Build state (running, passed, failed, etc.)                 |
| `buildkite.build.blocked_state`      | `buildkite.build`, `buildkite.build.stage` (when blocked)                          | Build blocked state (if blocked)                            |
| `buildkite.build.stage`              | `buildkite.build.stage`, `buildkite.job`, `buildkite.step.group`, `buildkite.step` | Build stage/phase number                                    |
| `buildkite.step.id`                  | `buildkite.job`, `buildkite.step`, `buildkite.step.group`                          | Step ID                                                     |
| `buildkite.step.key`                 | `buildkite.job`, `buildkite.step`, `buildkite.step.group`                          | Step key                                                    |
| `buildkite.step.command`             | `buildkite.job`, `buildkite.step` (command steps only)                             | Step command script                                         |
| `buildkite.step.label`               | `buildkite.job`, `buildkite.step`, `buildkite.step.group`                          | Step label                                                  |
| `buildkite.step.type`                | `buildkite.step`, `buildkite.step.group`                                           | Step type                                                   |
| `buildkite.step.matrix`              | `buildkite.step`, `buildkite.step.group` (matrix steps)                            | Whether step uses matrix (true)                             |
| `buildkite.step.group.label`         | `buildkite.step`, `buildkite.step.group` (group steps)                             | Group step label                                            |
| `buildkite.step.group.key`           | `buildkite.step`, `buildkite.step.group` (group steps)                             | Group step key                                              |
| `buildkite.job.id`                   | `buildkite.job`                                                                    | Job ID                                                      |
| `buildkite.job.graphql_id`           | `buildkite.job`                                                                    | Job GraphQL ID                                              |
| `buildkite.job.type`                 | `buildkite.job`                                                                    | Job type (script, manual, waiter, etc.)                     |
| `buildkite.job.label`                | `buildkite.job`                                                                    | Job label/name                                              |
| `buildkite.job.command`              | `buildkite.job`                                                                    | Job command                                                 |
| `buildkite.job.agent_query_rules`    | `buildkite.job`                                                                    | Job agent query rules                                       |
| `buildkite.job.exit_status`          | `buildkite.job`                                                                    | Job exit status                                             |
| `buildkite.job.passed`               | `buildkite.job`                                                                    | Whether job passed                                          |
| `buildkite.job.soft_failed`          | `buildkite.job`                                                                    | Whether job soft failed                                     |
| `buildkite.job.state`                | `buildkite.job`                                                                    | Job state                                                   |
| `buildkite.job.runnable_at`          | `buildkite.job`                                                                    | When job became runnable                                    |
| `buildkite.job.started_at`           | `buildkite.job`                                                                    | When job started                                            |
| `buildkite.job.finished_at`          | `buildkite.job`                                                                    | When job finished                                           |
| `buildkite.job.wait_time_ms`         | `buildkite.job`                                                                    | Job wait time in milliseconds                               |
| `buildkite.job.unblocked_by`         | `buildkite.job` (when unblocked)                                                   | User who unblocked job (object with uuid, graphql_id, name) |
| `buildkite.job.retried_in_job_id`    | `buildkite.job` (when retried)                                                     | ID of retry job (if retried)                                |
| `buildkite.job.signal_reason`        | `buildkite.job` (when terminated by signal)                                        | Signal reason (if terminated by signal)                     |
| `buildkite.job.matrix`               | `buildkite.job` (matrix jobs only)                                                 | Job matrix configuration (JSON)                             |
| `buildkite.agent.name`               | `buildkite.job` (when agent assigned)                                              | Agent name                                                  |
| `buildkite.agent.id`                 | `buildkite.job` (when agent assigned)                                              | Agent ID                                                    |
| `buildkite.agent.queue`              | `buildkite.job` (when agent assigned)                                              | Agent queue                                                 |
| `buildkite.agent.meta_data`          | `buildkite.job` (when agent assigned)                                              | Agent metadata                                              |
| `error.type`                         | All (when error status)                                                            | Error type description                                      |

### Headers

Add any additional HTTP headers to the request. Depending on the destination, you may need to specify API keys or other headers to influence the behaviour of the downstream collector. Values for headers are always stored encrypted server-side.

Here are some common examples.

#### Bearer token

Key: `Authorization`
Value: `Bearer <your-token>`

See [Bearer Token example](https://github.com/buildkite/opentelemetry-notification-service-examples/blob/main/collector-config/bearer-token-auth-debug.yml) for example OpenTelemetry Collector configuration.

#### Basic auth

First, create a base64-encoded string of the username and password separated by a colon.

```bash
echo -n "${USER}:${PASSWORD}" | base64
```

Key: `Authorization`
Value: `Basic <base64 encoded ${USER}:${PASSWORD})>`

See [Basic Authentication example](https://github.com/buildkite/opentelemetry-notification-service-examples/blob/main/collector-config/basic-auth-debug.yml) for example OpenTelemetry Collector configuration.

### Honeycomb

Set the Endpoint to `https://api.honeycomb.io`, or `https://api.eu1.honeycomb.io ` if your Honeycomb team is in the EU instance.

Add the required header:

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

You can also use an online validation tool available at https://www.otelbin.io/.
