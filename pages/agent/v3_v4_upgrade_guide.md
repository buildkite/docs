# Agent v3 to v4 upgrade guide

> 🚧 Pre-release software
> Version 4 of the Buildkite Agent is in beta, and this upgrade guide should not be considered final.

## Breaking changes in v4

Read the following breaking changes carefully to determine if your agent setup, pipelines, or [plugins](/docs/pipelines/integrations/plugins) need updating for v4.

### Changes to job handling

- The [deprecated Docker integration](https://github.com/buildkite/agent/blob/497e6a42125a733d4615814faf9aab27fc9a7532/internal/job/docker.go) has been removed. The `docker` and `docker-compose` plugins remain supported. The integration used the `BUILDKITE_DOCKER` and `BUILDKITE_DOCKER_COMPOSE_CONTAINER` environment variables and had been deprecated since 2017. All current Docker usage for jobs known to Buildkite uses the `docker` and `docker-compose` plugins. If you use the deprecated Docker integration, switch to one of these plugins.
- On Windows, the exit status of a canceled job is now `1` instead of `0`. Canceled jobs now appear as failed, consistent with jobs that run on other platforms.
- The `--cancel-grace-period` and `--signal-grace-period-seconds` flags and configuration options (the `BUILDKITE_CANCEL_GRACE_PERIOD` and `BUILDKITE_SIGNAL_GRACE_PERIOD_SECONDS` environment variables) have been replaced with `--cancel-signal-timeout` and `--cancel-cleanup-timeout` (the `BUILDKITE_CANCEL_SIGNAL_TIMEOUT` and `BUILDKITE_CANCEL_CLEANUP_TIMEOUT` environment variables). The timeouts have increased slightly to a ten-second signal timeout and a five-second cleanup timeout. Both flags now accept non-negative durations. The maximum grace period after job cancellation is the sum of the two timeouts. Negative signal grace periods are no longer supported.

### Changes to job logs

- Timestamp options for logs have been simplified. The agent now always emits ANSI timestamp codes into the job log stream. The flags to disable ANSI timestamps (`--no-ansi-timestamps` and `BUILDKITE_NO_ANSI_TIMESTAMPS`) and enable plaintext timestamps (`--timestamp-lines` and `BUILDKITE_TIMESTAMP_LINES`) have been removed. Separate uploads of header times have also been removed.

### Changes to checkout

- After repository checkout, the agent resolves `BUILDKITE_COMMIT` to a commit hash. This change is useful when the initial value is a refspec such as `HEAD`.
- The OpenSSH option `StrictHostKeyChecking=accept-new` has replaced the built-in SSH key scan and `known-hosts` file updater in the default checkout process. The default checkout process now requires OpenSSH version 7.6 or later unless you enable `--no-ssh-keyscan` or `BUILDKITE_NO_SSH_KEYSCAN`. OpenSSH 7.6 was released in 2017.

### Changes to agent parallelism

- The `--spawn-with-priority` flag (the `BUILDKITE_AGENT_SPAWN_WITH_PRIORITY` environment variable) no longer accepts a Boolean value. It now accepts `static`, `ascending`, or `descending`:
    * `--spawn-with-priority=static` is equivalent to the v3 `--spawn-with-priority=false` and spawns all agent workers with the same priority.
    * `--spawn-with-priority=ascending` is equivalent to the v3 `--spawn-with-priority=true` and spawns agent workers with an increasing sequence of priority values (`1`, `2`, `3`, and so on).
    * `--spawn-with-priority=descending` is equivalent to the v3 `--spawn-with-priority=true --experiment=descending-spawn-priority` and spawns agent workers with a decreasing sequence of priority values (`-1`, `-2`, `-3`, and so on). Combined with different `--spawn` values, this option can spread jobs across machines with different hardware capabilities. When the number of jobs is low, jobs tend to be evenly distributed across all machines. When the number of jobs is high, more jobs are assigned to agents on the more powerful machines with higher `--spawn` values.

### Changes to observability

- The agent no longer supports OpenTracing or direct connections to DogStatsD and no longer includes Datadog-related tracing workarounds. Use OpenTelemetry instead.
    * Enable OpenTelemetry tracing with the `--opentelemetry-tracing` flag or `BUILDKITE_OPENTELEMETRY_TRACING` environment variable.
    * `--tracing-service-name` (`BUILDKITE_TRACING_SERVICE_NAME`) has been renamed to `--telemetry-service-name` (`BUILDKITE_TELEMETRY_SERVICE_NAME`).
    * `--tracing-backend` (`BUILDKITE_TRACING_BACKEND`) has been removed. Only OpenTelemetry is supported.
    * `--tracing-propagate-traceparent` (`BUILDKITE_TRACING_PROPAGATE_TRACEPARENT`) has been removed. Its function, accepting a trace parent from the Buildkite platform, is now always enabled.
    * Configure the OpenTelemetry OTLP endpoint and protocol with the [standard `OTEL_EXPORTER_OTLP_*` environment variables](https://opentelemetry.io/docs/languages/sdk-configuration/otlp-exporter/).
- OpenTelemetry now uses a single `jobs.finished` metric instead of the `jobs.success` and `jobs.failed` counters. Use the `exit_status` tag on the metric to determine whether the job succeeded or failed.
- The `buildkite_agent_jobs_started_total` and `buildkite_agent_jobs_ended_total` Prometheus metrics now have `priority` and `queue` labels. These metrics replace `buildkite_agent_jobs_started_with_labels_total` and `buildkite_agent_jobs_ended_with_labels_total`.

### Changes to pipeline uploads

- By default, the agent now immediately fails a `pipeline upload` command when it detects secrets. To allow secrets in pipeline uploads, pass the `--allow-secrets` flag or set the `BUILDKITE_AGENT_PIPELINE_UPLOAD_ALLOW_SECRETS` environment variable. The agent no longer supports the `--reject-secrets` flag or the `BUILDKITE_AGENT_PIPELINE_UPLOAD_REJECT_SECRETS` environment variable.

### Changes to artifacts

- The agent now translates Windows path separators (`\`) into forward slashes (`/`) for storage, for example, in S3. The agent already translates forward slashes back to Windows path separators when downloading artifacts, so this change should not break agent-side behavior. However, the change may break workflows that assume specific storage paths.
- The `--follow-symlinks` flag for the `artifact upload` command (the `BUILDKITE_AGENT_ARTIFACT_SYMLINKS` environment variable) has been removed. Use the equivalent `--glob-resolve-follow-symlinks` flag (the `BUILDKITE_AGENT_ARTIFACT_GLOB_RESOLVE_FOLLOW_SYMLINKS` environment variable) instead.

### Changes to plugins and hooks

- The agent now writes the names, but not the values, of various agent environment variables to `BUILDKITE_ENV_FILE`. This change automatically propagates the variables to child environments, for example, when using the `docker` and `docker-compose` plugins. The change may break hooks, such as a pre-bootstrap hook, that assume every line in the file contains an equal sign (`=`) and a variable value.
- Deprecated environment variables generated for plugin configuration have been removed. When running a plugin, the agent generates environment variables that reflect the plugin configuration. The deprecated form removed consecutive underscores. For example, it changed `VAR__NAME` to `VAR_NAME`, making the environment variable for a plugin configuration key harder to predict. The new form, which preserves consecutive underscores, has existed for some time. Plugins should not depend on the deprecated variables. This change may break plugins that still use them.
- Post-checkout, post-command, and pre-exit hooks now run in reverse order relative to pre-checkout and pre-command hooks. This ordering makes it easier to pair setup and cleanup hooks, particularly when using multiple instances of the same plugin. The change may break some combinations of hooks or plugins. To use the previous ordering, enable the new `legacy-post-hook-order` experiment. The following section provides an example.

#### New hook ordering example

Suppose a step specifies plugins A and B in that order and has agent and repository hooks. Under v3, pre-checkout, post-checkout, pre-command, post-command, and pre-exit hooks all execute in this order: agent, repository, plugin A, plugin B.

1. Agent pre-checkout
1. No repository pre-checkout hook
1. Plugin A pre-checkout
1. Plugin B pre-checkout
1. Checkout
1. Agent post-checkout
1. Repository post-checkout
1. Plugin A post-checkout
1. Plugin B post-checkout
1. Agent pre-command
1. Repository pre-command
1. Plugin A pre-command
1. Plugin B pre-command
1. Command
1. Agent post-command
1. Repository post-command
1. Plugin A post-command
1. Plugin B post-command
1. Agent pre-exit
1. Repository pre-exit
1. Plugin A pre-exit
1. Plugin B pre-exit

In v4, the default execution order is reversed for post-checkout, post-command, and pre-exit hooks. The key differences are in _italics_:

1. Agent pre-checkout
1. No repository pre-checkout hook
1. Plugin A pre-checkout
1. Plugin B pre-checkout
1. Checkout
1. Plugin _B_ post-checkout
1. Plugin _A_ post-checkout
1. _Repository_ post-checkout
1. _Agent_ post-checkout
1. Agent pre-command
1. Repository pre-command
1. Plugin A pre-command
1. Plugin B pre-command
1. Command
1. Plugin _B_ post-command
1. Plugin _A_ post-command
1. _Repository_ post-command
1. _Agent_ post-command
1. Plugin _B_ pre-exit
1. Plugin _A_ pre-exit
1. _Repository_ pre-exit
1. _Agent_ pre-exit

### Changes to job metadata

- The output from `buildkite-agent meta-data get` now includes a trailing newline. This change may break code that assumes there is no trailing whitespace after fetching a metadata value with this command.

### Changes to experiments

- `legacy-post-hook-order`: Enable this new experiment to revert to the v3 hook ordering. See [Changes to plugins and hooks](/docs/agent/v3-v4-upgrade-guide#breaking-changes-in-v4-changes-to-plugins-and-hooks).
- `allow-artifact-path-traversal`: Removed. The insecure behavior it enabled is no longer supported.
- `normalised-upload-paths`: Removed because normalized upload paths are now the default behavior. See [Changes to artifacts](/docs/agent/v3-v4-upgrade-guide#breaking-changes-in-v4-changes-to-artifacts).
- `override-zero-exit-on-cancel`: Removed because its behavior is now the default. See [Changes to job handling](/docs/agent/v3-v4-upgrade-guide#breaking-changes-in-v4-changes-to-job-handling).
- `resolve-commit-after-checkout`: Removed because its behavior is now the default. See [Changes to checkout](/docs/agent/v3-v4-upgrade-guide#breaking-changes-in-v4-changes-to-checkout).
- `propagate-agent-config-vars`: Removed because its behavior is now the default. See [Changes to plugins and hooks](/docs/agent/v3-v4-upgrade-guide#breaking-changes-in-v4-changes-to-plugins-and-hooks).
- `descending-spawn-priority`: Removed. Use the `--spawn-with-priority` flag for equivalent functionality. See [Changes to agent parallelism](/docs/agent/v3-v4-upgrade-guide#breaking-changes-in-v4-changes-to-agent-parallelism).

### Changes to flags, environment variables, and agent configuration

The agent now uses a new version of the underlying CLI flag processing package. This change is not expected to cause problems.

These CLI flags, environment variables, and agent configuration options have been removed:

- `cancel-grace-period` (`BUILDKITE_CANCEL_GRACE_PERIOD`): Removed. See [Changes to job handling](/docs/agent/v3-v4-upgrade-guide#breaking-changes-in-v4-changes-to-job-handling).
- `signal-grace-period-seconds` (`BUILDKITE_SIGNAL_GRACE_PERIOD_SECONDS`): Removed. See [Changes to job handling](/docs/agent/v3-v4-upgrade-guide#breaking-changes-in-v4-changes-to-job-handling).
- `no-ansi-timestamps` (`BUILDKITE_NO_ANSI_TIMESTAMPS`): Removed. See [Changes to job logs](/docs/agent/v3-v4-upgrade-guide#breaking-changes-in-v4-changes-to-job-logs).
- `timestamp-lines` (`BUILDKITE_TIMESTAMP_LINES`): Removed. See [Changes to job logs](/docs/agent/v3-v4-upgrade-guide#breaking-changes-in-v4-changes-to-job-logs).
- `trace-context-encoding` (`BUILDKITE_TRACE_CONTEXT_ENCODING`): Removed with OpenTracing support. There is no replacement because trace context encoding is no longer configurable.
- `tracing-service-name` (`BUILDKITE_TRACING_SERVICE_NAME`): Renamed to `telemetry-service-name` (`BUILDKITE_TELEMETRY_SERVICE_NAME`). See [Changes to observability](/docs/agent/v3-v4-upgrade-guide#breaking-changes-in-v4-changes-to-observability).
- `tracing-backend` (`BUILDKITE_TRACING_BACKEND`): Removed. See [Changes to observability](/docs/agent/v3-v4-upgrade-guide#breaking-changes-in-v4-changes-to-observability).
- `tracing-propagate-traceparent` (`BUILDKITE_TRACING_PROPAGATE_TRACEPARENT`): Removed because its behavior is now always enabled. See [Changes to observability](/docs/agent/v3-v4-upgrade-guide#breaking-changes-in-v4-changes-to-observability).
- `kubernetes-log-collection-grace-period` (`BUILDKITE_KUBERNETES_LOG_COLLECTION_GRACE_PERIOD`): Removed after brief use with Agent Stack for Kubernetes. There is no replacement.
- `no-automatic-ssh-fingerprint-verification` (`BUILDKITE_NO_AUTOMATIC_SSH_FINGERPRINT_VERIFICATION`): Use the equivalent `no-ssh-keyscan` option (`BUILDKITE_NO_SSH_KEYSCAN`) instead.
- `meta-data` (`BUILDKITE_AGENT_META_DATA`): Use the equivalent `tags` option (`BUILDKITE_AGENT_TAGS`) instead.
- `meta-data-ec2` (`BUILDKITE_AGENT_META_DATA_EC2`): Use the equivalent `tags-from-ec2-meta-data` option (`BUILDKITE_AGENT_TAGS_FROM_EC2_META_DATA`) instead.
- `meta-data-ec2-tags` (`BUILDKITE_AGENT_META_DATA_EC2_TAGS`): Use the equivalent `tags-from-ec2-tags` option (`BUILDKITE_AGENT_TAGS_FROM_EC2_TAGS`) instead.
- `meta-data-gcp` (`BUILDKITE_AGENT_META_DATA_GCP`): Use the equivalent `tags-from-gcp-meta-data` option (`BUILDKITE_AGENT_TAGS_FROM_GCP_META_DATA`) instead.
- `tags-from-ec2` (`BUILDKITE_AGENT_TAGS_FROM_EC2`): Use the equivalent `tags-from-ec2-meta-data` option (`BUILDKITE_AGENT_TAGS_FROM_EC2_META_DATA`) instead.
- `tags-from-gcp` (`BUILDKITE_AGENT_TAGS_FROM_GCP`): Use the equivalent `tags-from-gcp-meta-data` option (`BUILDKITE_AGENT_TAGS_FROM_GCP_META_DATA`) instead.
- `disconnect-after-job-timeout` (`BUILDKITE_AGENT_DISCONNECT_AFTER_JOB_TIMEOUT`): Use the equivalent `disconnect-after-idle-timeout` option instead.

## How to test v4 in beta

You can test Buildkite agent v4 in several ways, depending on how you installed or use the agent.

### Hosted agents

Buildkite hosted agents do not support Buildkite agent v4 before its stable release.

### Self-hosted installations

#### With Agent Stack for Kubernetes

In the `values.yaml` file used to deploy the Agent Stack for Kubernetes Helm chart, set the `config.image` option to a beta-tagged agent image. For example:

```yaml
config:
  image: ghcr.io/buildkite/agent:beta
```

If you use a custom image derived from the agent image, build a new image based on the beta.

#### With Elastic CI Stack for AWS

When configuring Elastic CI Stack for AWS, set the `BuildkiteAgentRelease` parameter to `beta`.

Each stack release includes a specific beta release of the agent. Update to the latest release of Elastic CI Stack to access a more recent beta.

#### Using the installation script

Set the `BETA` environment variable to `true` when executing the [installation script](https://github.com/buildkite/agent/blob/main/install.sh). For example:

```console
$ curl https://raw.githubusercontent.com/buildkite/agent/refs/heads/main/install.sh | BETA=true bash
```

#### Ubuntu and Debian

In the APT source list file for the Buildkite agent, usually `/etc/apt/sources.list.d/buildkite-agent.list`, change `stable` to `unstable`. For example:

```diff
-deb [signed-by=/usr/share/keyrings/buildkite-agent-archive-keyring.gpg] https://apt.buildkite.com/buildkite-agent stable main
+deb [signed-by=/usr/share/keyrings/buildkite-agent-archive-keyring.gpg] https://apt.buildkite.com/buildkite-agent unstable main
```

Then run `sudo apt update` and `sudo apt install buildkite-agent`.

#### Red Hat, CentOS, and Amazon Linux

When following the [self-hosted installation guide](/docs/agent/self-hosted/install/redhat), replace `/stable/` with `/unstable/` in the command that adds the Yum repository. For example, to install the `x86_64` variant:

```console
$ sudo sh -c 'echo -e "[buildkite-agent]\nname = Buildkite Pty Ltd\nbaseurl = https://yum.buildkite.com/buildkite-agent/unstable/x86_64/\nenabled=1\ngpgcheck=0\nrepo_gpgcheck=0\npriority=1" > /etc/yum.repos.d/buildkite-agent.repo'
```

#### FreeBSD

Buildkite agent v4 is not yet available in the `pkg` system. Manually download and install a FreeBSD binary from the latest v4 [release on GitHub](https://github.com/buildkite/agent/releases).

#### macOS

Use Homebrew to install or upgrade to a v4 release with the `@4` suffix. For example:

```console
$ brew install buildkite/buildkite/buildkite-agent@4
```

The latest v3 release is available using `@3`.

#### Windows

In an Administrator PowerShell session, set the `buildkiteAgentBeta` environment variable to `true` before running the installation script. For example:

```console
PS> $env:buildkiteAgentToken = "xxx-yyy-zzz"
PS> $env:buildkiteAgentBeta = true
PS> Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/buildkite/agent/main/install.ps1'))
```

#### From source

Use the Go compiler to build and install Buildkite agent v4 from source. For example:

```console
$ go install github.com/buildkite/agent/v4@latest
```

This command typically installs the v4 agent at `~/go/bin/agent`.

#### Validating the installation

Check the installed version of the Buildkite agent with the `--version` flag:

```console
$ buildkite-agent --version
buildkite-agent version 4.0.0-beta.3+12492.5228a73b6906effe729cfe48cfd900f3291b3c3a
```

## How to stay on v3 after v4 is stable

After v4 becomes stable, you can remain on Buildkite agent v3 in several ways, depending on how you installed or use the agent.

### Hosted agents

You cannot choose the agent version used by Buildkite hosted agents.

### Self-hosted installations

#### With Agent Stack for Kubernetes

In the `values.yaml` file used to deploy the Agent Stack for Kubernetes Helm chart, set the `config.image` option to an agent image tagged with `oldstable`, `3`, or a related tag. For example:

```yaml
config:
  image: ghcr.io/buildkite/agent:oldstable
  # Or use:
  # image: ghcr.io/buildkite/agent:3
```

If you use a custom image derived from the agent image, build it from one of these images.

#### With Elastic CI Stack for AWS

Elastic CI Stack for AWS version 6.69.0 and later supports `oldstable` as a value for the `BuildkiteAgentRelease` parameter. With this value, instances download and install the most recent `oldstable` binary.

#### Using the installation script

The [installation script](https://github.com/buildkite/agent/blob/main/install.sh) does not choose the most recent release in the `oldstable` release channel. Set the `BUILDKITE_AGENT_VERSION` environment variable to choose a specific version:

```console
$ curl https://raw.githubusercontent.com/buildkite/agent/refs/heads/main/install.sh | BUILDKITE_AGENT_VERSION=3.132.0 bash
```

#### Ubuntu and Debian

In the APT source list file for the Buildkite agent, usually `/etc/apt/sources.list.d/buildkite-agent.list`, change `stable` to `oldstable`. For example:

```diff
-deb [signed-by=/usr/share/keyrings/buildkite-agent-archive-keyring.gpg] https://apt.buildkite.com/buildkite-agent stable main
+deb [signed-by=/usr/share/keyrings/buildkite-agent-archive-keyring.gpg] https://apt.buildkite.com/buildkite-agent oldstable main
```

Then run `sudo apt update` and `sudo apt install buildkite-agent`.

#### Red Hat, CentOS, and Amazon Linux

When following the [self-hosted installation guide](/docs/agent/self-hosted/install/redhat), replace `/stable/` with `/oldstable/` in the command that adds the Yum repository. For example, to install the `x86_64` variant:

```console
$ sudo sh -c 'echo -e "[buildkite-agent]\nname = Buildkite Pty Ltd\nbaseurl = https://yum.buildkite.com/buildkite-agent/oldstable/x86_64/\nenabled=1\ngpgcheck=0\nrepo_gpgcheck=0\npriority=1" > /etc/yum.repos.d/buildkite-agent.repo'
```

#### FreeBSD

Manually download and install a FreeBSD binary from the latest v3 [release on GitHub](https://github.com/buildkite/agent/releases).

#### macOS

Use Homebrew to install a v3 release with the `@3` suffix. For example:

```console
$ brew install buildkite/buildkite/buildkite-agent@3
```

#### Windows

The script does not choose the most recent release in the `oldstable` release channel. Set the `buildkiteAgentVersion` environment variable to choose a specific version. In an Administrator PowerShell session, set the environment variable before running the installation script. For example:

```console
PS> $env:buildkiteAgentToken = "xxx-yyy-zzz"
PS> $env:buildkiteAgentVersion = "3.132.0"
PS> Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/buildkite/agent/main/install.ps1'))
```

#### From source

Use the Go compiler to build and install Buildkite agent v3 from source. For example:

```console
$ go install github.com/buildkite/agent/v3@latest
```

This command typically installs the agent at `~/go/bin/agent`.

#### Validating the installation

Check the installed version of the Buildkite agent with the `--version` flag:

```console
$ buildkite-agent --version
buildkite-agent version 3.132.0+13129.e1b2453685eda0e266338a4a5dda2f51afc7081a
```
