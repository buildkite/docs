# Agent v3 to v4 upgrade guide

> 🛠 Pre-release software
> Version 4 of the Buildkite Agent is in beta, and this upgrade guide should not be considered final.

## How to test v4 in beta

You can test Buildkite Agent v4 a number of ways, depending how you installed or use Buildkite Agent.

### Hosted agents

We do not presently offer a way to use Buildkite Agent v4 in Hosted Agents in advance of the stable release.

### Self-hosted installations

#### With agent-stack-k8s

In the `values.yaml` used to deploy the agent-stack-k8s Helm chart, set the `config.image` option to a beta-tagged agent image, for example:

```yaml
config:
  image: ghcr.io/buildkite/agent:beta
```

If you are using a custom image derived from the agent image, you will need to build a new custom image based on the beta.

#### With Elastic CI Stack for AWS

When configuring Elastic CI Stack for AWS, set the `BuildkiteAgentRelease` parameter to `beta`.

Note that because the exact beta release of the agent is baked into each release of the stack, you must update to the latest release of Elastic CI Stack to access a more recent beta.

#### Using [install.sh](https://github.com/buildkite/agent/blob/main/install.sh)

Set the environment variable `BETA=true` when executing the install script, for example:

```console
$ curl https://raw.githubusercontent.com/buildkite/agent/refs/heads/main/install.sh | BETA=true bash
```

#### Ubuntu and Debian

In the APT source list file for Buildkite Agent (usually `/etc/apt/sources.list.d/buildkite-agent.list`), change `stable` to `unstable`, for example:

```diff
-deb [signed-by=/usr/share/keyrings/buildkite-agent-archive-keyring.gpg] https://apt.buildkite.com/buildkite-agent stable main"
+deb [signed-by=/usr/share/keyrings/buildkite-agent-archive-keyring.gpg] https://apt.buildkite.com/buildkite-agent unstable main"
```

Then proceed to `sudo apt update` and `sudo apt install buildkite-agent`.

#### Red Hat / CentOS / Amazon Linux

When following the [self-hosted install guide](/docs/agent/self-hosted/install/redhat), replace `/stable/` with `/unstable/` in the command for adding the Yum repository. For example, to install the x86_64 variant:

```console
$ sudo sh -c 'echo -e "[buildkite-agent]\nname = Buildkite Pty Ltd\nbaseurl = https://yum.buildkite.com/buildkite-agent/unstable/x86_64/\nenabled=1\ngpgcheck=0\nrepo_gpgcheck=0\npriority=1" > /etc/yum.repos.d/buildkite-agent.repo'
```

#### FreeBSD

v4 is not yet available in the `pkg` system. Manually download and install a FreeBSD binary from the latest v4 release.

#### macOS

Homebrew can be used to install or upgrade to a version 4 release with the `@4` suffix, for example:

```console
$ brew install buildkite/buildkite/buildkite-agent@4
```

(The latest release of version 3 is available using `@3`.)

#### Windows

Within an Administrator PowerShell session, add the environment variable `buildkiteAgentBeta=true` before running the installation script. For example:

```console
PS> $env:buildkiteAgentToken = "<your_token>"
PS> $env:buildkiteAgentBeta = true
PS> Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/buildkite/agent/main/install.ps1'))
```

#### From source

Using the Go compiler, you can build and install Buildkite Agent v4 from source. For example:

```console
$ go install github.com/buildkite/agent/v4@latest
```

typically installs the v4 agent at `~/go/bin/buildkite-agent`.

#### Validating the install

You can check which version of Buildkite Agent is installed with the `--version` flag:

```console
$ buildkite-agent --version
buildkite-agent version 4.0.0-beta.3+12492.5228a73b6906effe729cfe48cfd900f3291b3c3a
```

## Breaking changes in v4

Please read the following breaking changes carefully to determine if your agent setup, pipelines, or plugins need updating for version 4.

### Changes to job handling

- The [deprecated Docker integration](https://github.com/buildkite/agent/blob/497e6a42125a733d4615814faf9aab27fc9a7532/internal/job/docker.go) has been removed. (Note that the `docker` and `docker-compose` *plugins* are very much *not* deprecated nor removed!) The deprecated Docker integration has been considered deprecated since 2017, and used the environment variables `BUILDKITE_DOCKER` and `BUILDKITE_DOCKER_COMPOSE_CONTAINER`. All current Docker usage for jobs known to us uses the `docker` and `docker-compose` plugins - if you were using the deprecated Docker integration, please switch to using one of the plugins.
- On Windows, the exit status of a cancelled job is now 1, where it used to be 0. A consequence of this is that cancelled jobs will appear “failed”, making them consistent with jobs run on other platforms.
- The flags and config options `--cancel-grace-period` and `--signal-grace-period-seconds` (environment variables `BUILDKITE_CANCEL_GRACE_PERIOD` and `BUILDKITE_SIGNAL_GRACE_PERIOD_SECONDS`) have been replaced with `--cancel-signal-timeout` and `--cancel-cleanup-timeout` (`BUILDKITE_CANCEL_SIGNAL_TIMEOUT` and `BUILDKITE_CANCEL_CLEANUP_TIMEOUT`), and the timeouts have been increased slightly (10s signal timeout and 5s cleanup timeout). Both flags are now non-negative durations. The “total” maximum grace period following job cancellation is now the sum of the two timeouts. The “negative signal grace period” handling no longer exists.

### Changes to job logs

- Timestamp options for logs have been simplified. ANSI timestamp codes are now always emitted into the job log stream. Flags to disable ANSI timestamps (`--no-ansi-timestamps` , `BUILDKITE_NO_ANSI_TIMESTAMPS`) and enable plaintext timestamps (`--timestamp-lines` , `BUILDKITE_TIMESTAMP_LINES` ) have been removed, as has the separate uploading of “header times” .

### Changes to checkout

- After repository checkout, `BUILDKITE_COMMIT` is resolved to a commit hash, which is beneficial when the initial value is a refspec such as `HEAD`.

### Changes to agent parallelism

- The `--spawn-with-priority` flag (environment variable `BUILDKITE_AGENT_SPAWN_WITH_PRIORITY`) is no longer a boolean (true/false). It now takes a string value (one of `static`, `ascending`, or `descending`):
    + `--spawn-with-priority=static` is equivalent to the v3 `--spawn-with-priority=false` , and will spawn all agent workers with the same priority.
    + `--spawn-with-priority=ascending` is equivalent to the v3 `--spawn-with-priority=true` , and will spawn agent workers with an increasing sequence of priority values (1, 2, 3, …)
    + `--spawn-with-priority=descending` is equivalent to the v3 `--spawn-with-priority=true --experiment=descending-spawn-priority` , and will spawn agent workers with a decreasing sequence of priority values (-1, -2, -3, …). Combined with varying `--spawn`, this option can be useful for spreading jobs across machines with different hardware capabilities. When the number of jobs is low, jobs will tend to be evenly distributed across all machines, and when the number of jobs is high, more jobs will be assigned to agents running on the more powerful machines (those with higher `--spawn`).

### Changes to observability

- OpenTracing is no longer supported. Various Datadog-related tracing workarounds were also cleaned up. OpenTelemetry won - you should use that instead.
- Some Prometheus metrics have changed. `buildkite_agent_jobs_started_total` and `buildkite_agent_jobs_ended_total` now have `priority` and `queue` labels, replacing `buildkite_agent_jobs_started_with_labels_total` and `buildkite_agent_jobs_ended_with_labels_total`.

### Changes to pipeline uploads

- By default, secrets detected in a pipeline upload will now cause the pipeline upload to fail immediately. Secrets in pipeline uploads can be allowed again by passing the `--allow-secrets` flag (environment variable `BUILDKITE_AGENT_PIPELINE_UPLOAD_ALLOW_SECRETS`). The `--reject-secrets` flag (environment variable `BUILDKITE_AGENT_PIPELINE_UPLOAD_REJECT_SECRETS`) has been removed.

### Changes to artifacts

- Windows path separators (`\`) are now translated into forward slashes `/` for storage (for example in S3). We do not anticipate this breaking any agent-side behaviour. (The inverse translation back to Windows path separators (`\`) is already applied on artifact download.) But this change may break workflows that assume particular storage paths.
- The `artifact upload` command `--follow-symlinks` flag (`BUILDKITE_AGENT_ARTIFACT_SYMLINKS` environment variable) has been removed. Use `--glob-resolve-follow-symlinks` (`BUILDKITE_AGENT_ARTIFACT_GLOB_RESOLVE_FOLLOW_SYMLINKS`) instead, which is equivalent.

### Changes to plugins and hooks

- The names (but not values) of various agent environment variables are now written to `BUILDKITE_ENV_FILE`, so that they can be automatically propagated to child environments, for example with the `docker` and `docker-compose` plugins. This may break hooks (for example a pre-bootstrap hook) that assume all lines in the file will have an equal sign `=` and a variable value.
- Deprecated env vars generated for plugin configuration have been removed. When running a plugin, environment variables are generated reflecting the plugin configuration. The deprecated form of these variables eliminated any consecutive underscores (for example `VAR__NAME` was mangled into `VAR_NAME`), making it harder to predict the env var corresponding to a particular plugin config key.

The new form of these generated variables, where consecutive underscores are *preserved*, has existed for some time now. Plugins should not depend on the deprecated variables, but this change may break plugins we are not currently aware of if they still use the deprecated variables.
- Post-checkout, post-command, pre-exit hooks now run in "reverse" order (relative to pre-checkout, pre-command hooks).  See below for an example.

This change is aimed at making “setup/cleanup” pairing of hooks easier, particularly when using multiple instances of the same plugin. It may break some combinations of hooks or plugins that we are not currently aware of. The new ordering can be opted-out using the new  `legacy-post-hook-order` experiment.

#### New hook ordering example

Suppose a step specifies two plugins A and B (in that order), and there are also agent and repository hooks present. Under version 3, hooks for each of these hook types (pre-checkout, post-checkout, pre-command, post-command, pre-exit) execute in the same order as one another: agent, repository, plugin A, plugin B. In full:

1. agent pre-checkout
2. (pre-checkout is not possible for repository hooks)
3. plugin A pre-checkout
4. plugin B pre-checkout
5. (checkout)
6. agent post-checkout
7. repository post-checkout
8. plugin A post-checkout
9. plugin B post-checkout
10. agent pre-command
11. repository pre-command
12. plugin A pre-command
13. plugin B pre-command
14. (command)
15. agent post-command
16. repository post-command
17. plugin A post-command
18. plugin B post-command
19. agent pre-exit
20. repository pre-exit
21. plugin A pre-exit
22. plugin B pre-exit

In version 4, the default execution order is reversed for post-checkout, post-command, and pre-exit hooks (key differences in **bold**):

1. agent pre-checkout
2. (pre-checkout is not possible for repository hooks)
3. plugin A pre-checkout
4. plugin B pre-checkout
5. (checkout)
6. plugin **B** post-checkout
7. plugin **A** post-checkout
8. **repository** post-checkout
9. **agent** post-checkout
10. agent pre-command
11. repository pre-command
12. plugin A pre-command
13. plugin B pre-command
14. (command)
15. plugin **B** post-command
16. plugin **A** post-command
17. **repository** post-command
18. **agent** post-command
19. plugin **B** pre-exit
20. plugin **A** pre-exit
21. **repository** pre-exit
22. **agent** pre-exit

### Changes to job metadata

- A trailing newline has been added to the output from `buildkite-agent meta-data get`. This may break code that assumes there is no trailing whitespace after fetching a metadata value with this command.

### Changes to experiments

- A new experiment, `legacy-post-hook-order`, can be used to revert to the v3 hook ordering (see “Changes to plugins and hooks” above).
- `allow-artifact-path-traversal` has been removed. The insecure behaviour it enabled is no longer supported.
- `normalised-upload-paths` is now default behaviour and has been removed (see “Changes to artifacts” above) .
- `override-zero-exit-on-cancel` is now default behaviour and has been removed(see “Changes to job handling” above) .
- `resolve-commit-after-checkout` is now default behaviour and has been removed(see “Changes to checkout” above).
- `propagate-agent-config-vars` is now default behaviour and has been removed (see “Changes to plugins and hooks” above).
- `descending-spawn-priority` has been removed, with equivalent functionality now available using the `--spawn-with-priority` flag (see “Changes to agent parallelism” above).

### Changes to flags, environment variables, and agent configuration

The underlying CLI flag processing package has been upgraded to a new version. We don’t expect any problems to arise as a result.

These CLI flags, environment variables, and agent configuration options have been removed:

- `cancel-grace-period` (`BUILDKITE_CANCEL_GRACE_PERIOD` ) has been removed (see “Changes to job handling” above).
- `signal-grace-period-seconds` (`BUILDKITE_SIGNAL_GRACE_PERIOD_SECONDS` ) has been removed (see “Changes to job handling” above).
- `no-ansi-timestamps` (`BUILDKITE_NO_ANSI_TIMESTAMPS` ) has been removed (see “Changes to job logs” above).
- `timestamp-lines` (`BUILDKITE_TIMESTAMP_LINES`) has been removed (see “Changes to job logs” above).
- `trace-context-encoding` (`BUILDKITE_TRACE_CONTEXT_ENCODING`) - it applied to OpenTracing support, which was also removed in this version. There is no replacement flag, because there is no longer a trace context encoding to configure.
- `kubernetes-log-collection-grace-period` (`BUILDKITE_KUBERNETES_LOG_COLLECTION_GRACE_PERIOD`) has been removed. It was only briefly used with agent-stack-k8s before the functionality was removed. There is no replacement flag, it should not be used.
- `no-automatic-ssh-fingerprint-verification` (`BUILDKITE_NO_AUTOMATIC_SSH_FINGERPRINT_VERIFICATION`) - use `no-ssh-keyscan` (`BUILDKITE_NO_SSH_KEYSCAN`) instead, which is equivalent.
- `meta-data` (`BUILDKITE_AGENT_META_DATA`) - use `tags` (`BUILDKITE_AGENT_TAGS`) instead, which is equivalent.
- `meta-data-ec2` (`BUILDKITE_AGENT_META_DATA_EC2`) - use `tags-from-ec2-meta-data` (`BUILDKITE_AGENT_TAGS_FROM_EC2_META_DATA`) instead, which is equivalent.
- `meta-data-ec2-tags` (`BUILDKITE_AGENT_META_DATA_EC2_TAGS`) - use `tags-from-ec2-tags` (`BUILDKITE_AGENT_TAGS_FROM_EC2_TAGS`) instead, which is equivalent.
- `meta-data-gcp` (`BUILDKITE_AGENT_META_DATA_GCP`) - use `tags-from-gcp-meta-data` (`BUILDKITE_AGENT_TAGS_FROM_GCP_META_DATA`) instead, which is equivalent.
- `tags-from-ec2` (`BUILDKITE_AGENT_TAGS_FROM_EC2`) - use `tags-from-ec2-meta-data` (`BUILDKITE_AGENT_TAGS_FROM_EC2_META_DATA`) instead, which is equivalent.
- `tags-from-gcp` (`BUILDKITE_AGENT_TAGS_FROM_GCP`) - use `tags-from-gcp-meta-data` (`BUILDKITE_AGENT_TAGS_FROM_GCP_META_DATA`) instead, which is equivalent.
- `disconnect-after-job-timeout` (`BUILDKITE_AGENT_DISCONNECT_AFTER_JOB_TIMEOUT`) - use `disconnect-after-idle-timeout` instead, which is equivalent.
