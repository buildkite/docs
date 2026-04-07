# Agent lifecycle

The Buildkite agent goes through several stages during its operation: starting up, registering with Buildkite, receiving and running jobs, and shutting down. This page covers how the agent [receives jobs dispatched to it](#job-dispatch), [handles signals](#signal-handling), the [exit codes](#exit-codes) it reports, and how to [troubleshoot](#troubleshooting) common lifecycle issues.

## Job dispatch

By default, self-hosted agents poll the Buildkite API at regular intervals to check for available jobs. When a job is available, the agent accepts it and begins execution. The polling interval is set by Buildkite Pipelines (the Buildkite platform) during agent registration, and each poll includes random jitter to avoid multiple agents synchronizing their requests.

This polling-based approach is reliable and works across all network configurations, but introduces latency between a job becoming available and an agent picking it up.

### Streaming job dispatch

> 📘 Public preview
> Streaming job dispatch is in public preview and may change before general availability. If you have feedback or run into issues, contact [support@buildkite.com](mailto:support@buildkite.com).

Streaming job dispatch reduces job acceptance latency by maintaining a persistent connection between the agent and Buildkite Pipelines. Instead of the agent periodically asking for work, Buildkite Pipelines pushes jobs to idle agents as soon as they become available.

To opt in, point your agent at the streaming endpoint:

```bash
buildkite-agent start --endpoint https://agent-edge.buildkite.com/v3
```

You can also set this using the `BUILDKITE_AGENT_ENDPOINT` environment variable or by adding `endpoint=https://agent-edge.buildkite.com/v3` to your `buildkite-agent.cfg` file.

The agent's `--ping-mode` flag controls the dispatch behavior:

- `auto` (default): Uses streaming when available, and falls back to polling if the streaming connection fails.
- `poll-only`: Uses the classical polling-based dispatch only.
- `stream-only`: Uses streaming dispatch only, with no fallback. The agent stops if the streaming connection fails.

In `auto` mode, both the streaming and polling mechanisms run concurrently. The streaming connection takes priority when healthy, and the polling loop activates automatically if the streaming connection becomes unhealthy.

## Signal handling

When a build's job is canceled, the agent will send that job process a `SIGTERM` signal to allow it to exit gracefully.

If the process does not exit within the 10s grace period it will be forcefully terminated with a `SIGKILL` signal. If you require a longer grace period, it can be customized on [self-hosted agents](/docs/agent/self-hosted) using the [cancel-grace-period](/docs/agent/self-hosted/configure#configuration-settings) agent configuration option.

The agent also accepts the following two signals directly:

- `SIGTERM` - Instructs the agent to gracefully disconnect, after completing any job that it may be running.
- `SIGQUIT` - Instructs the agent to forcefully disconnect, canceling any job that it may be running.

## Exit codes

The agent reports its activity to Buildkite using exit codes. The most common exit codes and their descriptions can be found in the table below.

Exit code           | Description
------------------- | -------------------------------------------------------------------
0                   | The job exited with a status of 0 (success)
1                   | The job exited with a status of 1 (most common error status)
94                  | The checkout timed out waiting for a Git mirrors lock
128 + signal number | The job was terminated by a signal (see note below)
255                 | The agent was gracefully terminated
-1                  | Buildkite lost contact with the agent or it stopped reporting to us

> 📘 Jobs terminated by signals
> When a job is terminated by a signal, the exit code will be set to 128 + the signal number. For more information about how shells manage commands terminated by signals, see the Wiki page on <a href="https://en.wikipedia.org/wiki/Exit_status#Shell_and_scripts">Exit Signals</a>.

Exit codes for common signals:

Exit code | Signal | Name    | Description
--------- | ------ | ------- | --------------------------------------------
130       | 2      | SIGINT  | Terminal interrupt signal
137       | 9      | SIGKILL | Kill (cannot be caught or ignored)
139       | 11     | SIGSEGV | Segmentation fault; Invalid memory reference
141       | 13     | SIGPIPE | Write on a pipe with no one to read it
143       | 15     | SIGTERM | Termination signal (graceful)

### Job exit codes and hooks

The final exit code reported for a job depends on which phase of the [job lifecycle](/docs/agent/hooks#job-lifecycle-hooks) failed. The agent tracks exit codes through two environment variables as the job progresses:

- `BUILDKITE_COMMAND_EXIT_STATUS`: Set after the command phase is completed. Contains the exit code from the command or `command`-related hook. This value is available to `post-command` and `pre-exit` hooks.
- `BUILDKITE_LAST_HOOK_EXIT_STATUS`: Set after each hook is completed. Contains the exit code of the most recently executed hook.

The final exit code reported to Buildkite Pipelines is determined as follows:

- If a `pre-command` hook or earlier hook fails, its exit code becomes the job exit code. The command does not run.
- If the command fails but all `post-command` and `pre-exit` hooks pass, the command's exit code (from `BUILDKITE_COMMAND_EXIT_STATUS`) becomes the job exit code.
- If a `post-command` or `pre-exit` hook fails with a non-zero exit code, the hook's exit code **overrides** the job exit code. This is true even if the command also failed with a different exit code.

For example, if a command exits with code `4` and then a `pre-exit` hook exits with code `6`, the final job exit code reported to Buildkite Pipelines is `6`, not `4`. The original command exit code is still available in the `BUILDKITE_COMMAND_EXIT_STATUS` environment variable.

<%= render_markdown partial: 'agent/pre_exit_hook_job_exit_code' %>

## Troubleshooting

One issue you sometimes need to troubleshoot is when Buildkite loses contact with an agent, resulting in a `-1` exit code. After registering with the Buildkite API, an agent regularly sends heartbeat updates to indicate that it is operational. If the Buildkite API does not receive any heartbeat requests from an agent for three consecutive minutes, that agent is marked as lost within the next 60 seconds, and will not be assigned any further jobs.

Various factors can cause an agent to fail to send heartbeat updates. Common reasons include networking issues and resource constraints, such as CPU, memory, or I/O limitations on the infrastructure hosting the agent.

In such cases, check the agent logs and examine metrics related to networking, CPU, memory, and I/O to help identify the cause of the failed heartbeat updates.

If the agents run on the [Elastic CI Stack for AWS](/docs/agent/self-hosted/aws/elastic-ci-stack) with spot instances, the abrupt termination of spot instances can also result in marking agents as lost. To investigate this issue, you can use the [log collector script](https://github.com/buildkite/elastic-ci-stack-for-aws?tab=readme-ov-file#collect-logs-via-script) to gather all relevant logs and metrics from the Elastic CI Stack for AWS.

### Timeouts

Occasionally, a job may time out if it exceeds the maximum allowed [command step timeout](/docs/pipelines/configure/build-timeouts). Depending on the `cancel-grace-period` set on the agent, the job may not complete gracefully, resulting in an unexpected exit code (`-1`).
