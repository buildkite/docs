# Agent lifecycle

The Buildkite agent goes through several stages during its operation: starting up, registering with Buildkite, polling for and running jobs, and shutting down. This page covers how the agent [handles signals](#signal-handling), the [exit codes](#exit-codes) it reports, and how to [troubleshoot](#troubleshooting) common lifecycle issues.

## Signal handling

When a build job is canceled the agent will send the build job process a `SIGTERM` signal to allow it to gracefully exit.

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

## Troubleshooting

One issue you sometimes need to troubleshoot is when Buildkite loses contact with an agent, resulting in a `-1` exit code. After registering with the Buildkite API, an agent regularly sends heartbeat updates to indicate that it is operational. If the Buildkite API does not receive any heartbeat requests from an agent for three consecutive minutes, that agent is marked as lost within the next 60 seconds, and will not be assigned any further jobs.

Various factors can cause an agent to fail to send heartbeat updates. Common reasons include networking issues and resource constraints, such as CPU, memory, or I/O limitations on the infrastructure hosting the agent.

In such cases, check the agent logs and examine metrics related to networking, CPU, memory, and I/O to help identify the cause of the failed heartbeat updates.

If the agents run on the [Elastic CI Stack for AWS](/docs/agent/self-hosted/aws/elastic-ci-stack) with spot instances, the abrupt termination of spot instances can also result in marking agents as lost. To investigate this issue, you can use the [log collector script](https://github.com/buildkite/elastic-ci-stack-for-aws?tab=readme-ov-file#collect-logs-via-script) to gather all relevant logs and metrics from the Elastic CI Stack for AWS.

### Timeouts

Occasionally, a job may time out if it exceeds the maximum allowed [command step timeout](/docs/pipelines/configure/build-timeouts). Depending on the `cancel-grace-period` set on the agent, the job may not complete gracefully, resulting in an unexpected exit code (`-1`).
