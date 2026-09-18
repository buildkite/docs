# Elastic CI Stack v6 to v7 upgrade guide

Elastic CI Stack for AWS v7 upgrades the bundled Linux and Windows Buildkite agents from v3 to v4. This guide covers the stack-specific changes. Read the [Agent v3 to v4 upgrade guide](/docs/agent/v3-v4-upgrade-guide) for changes that affect your pipelines, hooks, plugins, and custom agent configuration.

If you need Buildkite agent v3, remain on Elastic CI Stack v6. Stack v7 no longer supports agent v3 or the `oldstable` release channel.

## Prepare the upgrade

1. Export your current stack parameters:

    ```bash
    aws cloudformation describe-stacks \
      --stack-name YOUR_STACK_NAME \
      --query 'Stacks[0].Parameters' \
      --output json > stack-parameters-backup.json
    ```

    Sensitive parameters such as `BuildkiteAgentToken` appear as `****` in this output. Keep their original values available separately if you need to supply them again.

1. Update your parameter files and deployment automation using [Parameter changes](#parameter-changes). CloudFormation rejects parameter names that do not exist in the v7 template. Do not carry forward every v6 parameter unchanged.
1. If you set `ImageId` or `ImageIdParameter`, [rebuild your custom AMI](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/creating-custom-amis) from the v7 base AMI and update the image parameter in the same stack update. A v6-based AMI cannot boot under the v7 template.
1. Review any settings supplied through [`AgentEnvFileUrl`](#agent-environment-configuration). CloudFormation cannot validate those settings.
1. Preview the update with a [CloudFormation change set](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-changesets.html). Follow [Updating your stack](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/managing-elastic-ci-stack#updating-your-stack) with your migrated parameters and the v7 template.

If you are upgrading from an earlier v6 release, also review the [stack changelog](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/main/CHANGELOG.md) for changes between your current version and v7.

## Parameter changes

Update the following CloudFormation parameters before upgrading:

v6 parameter | v7 replacement | Migration
------------ | -------------- | ---------
`BuildkiteAgentTimestampLines` | Removed | Remove the parameter. Agent v4 always emits ANSI timestamps.
`BuildkiteAgentTracingBackend` | `BuildkiteAgentOpenTelemetryTracing` | Replace an empty string with `false`, or `opentelemetry` with `true`. For `datadog`, follow [Datadog tracing](#datadog-tracing).
`BuildkiteAgentCancelGracePeriod` and `BuildkiteAgentSignalGracePeriod` | `BuildkiteAgentCancelSignalTimeout` and `BuildkiteAgentCancelCleanupTimeout` | Convert the values using [Cancellation timing](#cancellation-timing). These are not one-to-one renames.
`BuildkiteAgentRelease=oldstable` | `BuildkiteAgentRelease=stable`, `beta`, or `edge` | Use `stable` for the stable agent release. Remain on stack v6 if you need agent v3.
{: class="responsive-table"}

## Cancellation timing

Elastic CI Stack v7 separates cancellation into two timeouts:

- `BuildkiteAgentCancelSignalTimeout` controls how long the job process has to stop before it is forcibly terminated.
- `BuildkiteAgentCancelCleanupTimeout` gives a stopping agent extra time to upload logs and artifacts.

The defaults are `10s` for the signal timeout and `5s` for cleanup on both platforms. The total default cancellation time changes from 60 to 15 seconds on Linux and from ten to 15 seconds on Windows.

To preserve the v6 defaults, set:

Platform | `BuildkiteAgentCancelSignalTimeout` | `BuildkiteAgentCancelCleanupTimeout`
-------- | ---------------------------------- | -----------------------------------
Linux | `59s` | `1s`
Windows | `9s` | `1s`
{: class="responsive-table"}

The v6 cancellation parameters applied only to Linux. Windows used agent v3 defaults unless you overrode them through custom agent configuration.

For custom v6 Linux parameter values:

- If `BuildkiteAgentSignalGracePeriod` was `-1`, subtract one second from `BuildkiteAgentCancelGracePeriod` for the new signal timeout and use `1s` for cleanup.
- Otherwise, use the old signal grace period as the signal timeout. Set the cleanup timeout to the old cancel grace period minus the signal timeout.

For example, `BuildkiteAgentCancelGracePeriod=120` and `BuildkiteAgentSignalGracePeriod=30` become `BuildkiteAgentCancelSignalTimeout=30s` and `BuildkiteAgentCancelCleanupTimeout=90s`. The new parameters accept durations such as `30s` and `1m30s`.

## Datadog tracing

Agent v4 sends traces using OpenTelemetry instead of the native Datadog backend. You can continue using your existing Datadog Agent. You do not need a separate OpenTelemetry collector.

1. Enable [OpenTelemetry Protocol (OTLP) ingestion on your Datadog Agent](https://docs.datadoghq.com/opentelemetry/setup/otlp_ingest_in_the_agent/) if it is not already enabled. OTLP ingestion is disabled by default, even if the Datadog Agent already receives traces through its native backend.
1. Replace `BuildkiteAgentTracingBackend=datadog` with `BuildkiteAgentOpenTelemetryTracing=true` in your stack parameters.
1. Use `AgentEnvFileUrl` to set `OTEL_EXPORTER_OTLP_ENDPOINT` to the OTLP endpoint on your Datadog Agent. Set `OTEL_EXPORTER_OTLP_PROTOCOL` to the matching protocol, such as `grpc` or `http/protobuf`. Ensure the endpoint is reachable from the Buildkite agent.
1. If you set `BUILDKITE_TRACING_SERVICE_NAME`, rename it to `BUILDKITE_TELEMETRY_SERVICE_NAME` to preserve the service name.

## Agent environment configuration

The [`AgentEnvFileUrl` parameter](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/managing-elastic-ci-stack#configuring-agent-environment-variables) still works. Its values configure the agent directly and can override the configuration generated by the stack. Review every custom setting against the Agent v3 to v4 upgrade guide, including:

- Remove `BUILDKITE_NO_ANSI_TIMESTAMPS` and `BUILDKITE_TIMESTAMP_LINES`.
- Replace `BUILDKITE_TRACING_BACKEND` with `BUILDKITE_OPENTELEMETRY_TRACING`, using `true` or `false`, and configure the OTLP endpoint and protocol.
- Rename `BUILDKITE_TRACING_SERVICE_NAME` to `BUILDKITE_TELEMETRY_SERVICE_NAME` and remove `BUILDKITE_TRACING_PROPAGATE_TRACEPARENT`.
- Migrate any direct DogStatsD metrics configuration to OpenTelemetry as described in the [agent observability changes](/docs/agent/v3-v4-upgrade-guide#breaking-changes-in-v4-changes-to-observability).
- Replace `BUILDKITE_CANCEL_GRACE_PERIOD` and `BUILDKITE_SIGNAL_GRACE_PERIOD_SECONDS` with `BUILDKITE_CANCEL_SIGNAL_TIMEOUT` and `BUILDKITE_CANCEL_CLEANUP_TIMEOUT`, using the [timing conversion](#cancellation-timing).

Also review any custom [agent experiments](/docs/agent/self-hosted/configure/experiments) before replacing your instances.
