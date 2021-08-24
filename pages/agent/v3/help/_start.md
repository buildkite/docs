## Usage

`buildkite-agent start [options...]`

## Description

When a job is ready to run it will call the "bootstrap-script"
and pass it all the environment variables required for the job to run.
This script is responsible for checking out the code, and running the
actual build script defined in the pipeline.

The agent will run any jobs within a PTY (pseudo terminal) if available.

## Example

    $ buildkite-agent start --token xxx

## Options

* `--config value` - Path to a configuration file [`$BUILDKITE_AGENT_CONFIG`]
* `--name value` - The name of the agent [`$BUILDKITE_AGENT_NAME`]
* `--priority value` - The priority of the agent (higher priorities are assigned work first) [`$BUILDKITE_AGENT_PRIORITY`]
* `--acquire-job value` - Start this agent and only run the specified job, disconnecting after it's finished [`$BUILDKITE_AGENT_ACQUIRE_JOB`]
* `--disconnect-after-job` - Disconnect the agent after running a job [`$BUILDKITE_AGENT_DISCONNECT_AFTER_JOB`]
* `--disconnect-after-idle-timeout value` - If no jobs have come in for the specified number of seconds, disconnect the agent (default: 0) [`$BUILDKITE_AGENT_DISCONNECT_AFTER_IDLE_TIMEOUT`]
* `--cancel-grace-period value` - The number of seconds a canceled or timed out job is given to gracefully terminate and upload its artifacts (default: 10) [`$BUILDKITE_CANCEL_GRACE_PERIOD`]
* `--shell value` - The shell command used to interpret build commands, e.g /bin/bash -e -c (default: "/bin/bash -e -c") [`$BUILDKITE_SHELL`]
* `--tags value` - A comma-separated list of tags for the agent (e.g. "linux" or "mac,xcode=8") [`$BUILDKITE_AGENT_TAGS`]
* `--tags-from-host` - Include tags from the host (hostname, machine-id, os) [`$BUILDKITE_AGENT_TAGS_FROM_HOST`]
* `--tags-from-ec2-meta-data value` - Include the default set of host EC2 meta-data as tags (instance-id, instance-type, ami-id, and instance-life-cycle) [`$BUILDKITE_AGENT_TAGS_FROM_EC2_META_DATA`]
* `--tags-from-ec2-meta-data-paths value` - Include additional tags fetched from EC2 meta-data via tag & path suffix pairs, e.g "tag_name=path/to/value" [`$BUILDKITE_AGENT_TAGS_FROM_EC2_META_DATA_PATHS`]
* `--tags-from-ec2-tags` - Include the host's EC2 tags as tags [`$BUILDKITE_AGENT_TAGS_FROM_EC2_TAGS`]
* `--tags-from-gcp-meta-data value` - Include the default set of host Google Cloud instance meta-data as tags (instance-id, machine-type, preemptible, project-id, region, and zone) [`$BUILDKITE_AGENT_TAGS_FROM_GCP_META_DATA`]
* `--tags-from-gcp-meta-data-paths value` - Include additional tags fetched from Google Cloud instance meta-data via tag & path suffix pairs, e.g "tag_name=path/to/value" [`$BUILDKITE_AGENT_TAGS_FROM_GCP_META_DATA_PATHS`]
* `--tags-from-gcp-labels` - Include the host's Google Cloud instance labels as tags [`$BUILDKITE_AGENT_TAGS_FROM_GCP_LABELS`]
* `--wait-for-ec2-tags-timeout value` - The amount of time to wait for tags from EC2 before proceeding (default: 10s) [`$BUILDKITE_AGENT_WAIT_FOR_EC2_TAGS_TIMEOUT`]
* `--wait-for-ec2-meta-data-timeout value` - The amount of time to wait for meta-data from EC2 before proceeding (default: 10s) [`$BUILDKITE_AGENT_WAIT_FOR_EC2_META_DATA_TIMEOUT`]
* `--wait-for-gcp-labels-timeout value` - The amount of time to wait for labels from GCP before proceeding (default: 10s) [`$BUILDKITE_AGENT_WAIT_FOR_GCP_LABELS_TIMEOUT`]
* `--git-clone-flags value` - Flags to pass to the "git clone" command (default: "-v") [`$BUILDKITE_GIT_CLONE_FLAGS`]
* `--git-clean-flags value` - Flags to pass to "git clean" command (default: "-ffxdq") [`$BUILDKITE_GIT_CLEAN_FLAGS`]
* `--git-fetch-flags value` - Flags to pass to "git fetch" command (default: "-v --prune") [`$BUILDKITE_GIT_FETCH_FLAGS`]
* `--git-clone-mirror-flags value` - Flags to pass to the "git clone" command when used for mirroring (default: "-v") [`$BUILDKITE_GIT_CLONE_MIRROR_FLAGS`]
* `--git-mirrors-path value` - Path to where mirrors of git repositories are stored [`$BUILDKITE_GIT_MIRRORS_PATH`]
* `--git-mirrors-lock-timeout value` - Seconds to lock a git mirror during clone, should exceed your longest checkout (default: 300) [`$BUILDKITE_GIT_MIRRORS_LOCK_TIMEOUT`]
* `--bootstrap-script value` - The command that is executed for bootstrapping a job, defaults to the bootstrap sub-command of this binary [`$BUILDKITE_BOOTSTRAP_SCRIPT_PATH`]
* `--build-path value` - Path to where the builds will run from [`$BUILDKITE_BUILD_PATH`]
* `--hooks-path value` - Directory where the hook scripts are found [`$BUILDKITE_HOOKS_PATH`]
* `--plugins-path value` - Directory where the plugins are saved to [`$BUILDKITE_PLUGINS_PATH`]
* `--timestamp-lines` - Prepend timestamps on each line of output. [`$BUILDKITE_TIMESTAMP_LINES`]
* `--health-check-addr value` - Start an HTTP server on this addr:port that returns whether the agent is healthy, disabled by default [`$BUILDKITE_AGENT_HEALTH_CHECK_ADDR`]
* `--no-pty` - Do not run jobs within a pseudo terminal [`$BUILDKITE_NO_PTY`]
* `--no-ssh-keyscan` - Don't automatically run ssh-keyscan before checkout [`$BUILDKITE_NO_SSH_KEYSCAN`]
* `--no-command-eval` - Don't allow this agent to run arbitrary console commands, including plugins [`$BUILDKITE_NO_COMMAND_EVAL`]
* `--no-plugins` - Don't allow this agent to load plugins [`$BUILDKITE_NO_PLUGINS`]
* `--no-plugin-validation` - Don't validate plugin configuration and requirements [`$BUILDKITE_NO_PLUGIN_VALIDATION`]
* `--no-local-hooks` - Don't allow local hooks to be run from checked out repositories [`$BUILDKITE_NO_LOCAL_HOOKS`]
* `--no-git-submodules` - Don't automatically checkout git submodules [`$BUILDKITE_NO_GIT_SUBMODULES`, `$BUILDKITE_DISABLE_GIT_SUBMODULES`]
* `--metrics-datadog` - Send metrics to DogStatsD for Datadog [`$BUILDKITE_METRICS_DATADOG`]
* `--metrics-datadog-host value` - The dogstatsd instance to send metrics to via udp (default: "127.0.0.1:8125") [`$BUILDKITE_METRICS_DATADOG_HOST`]
* `--metrics-datadog-distributions` - Use Datadog Distributions for Timing metrics [`$BUILDKITE_METRICS_DATADOG_DISTRIBUTIONS`]
* `--log-format value` - The format to use for the logger output (default: "text") [`$BUILDKITE_LOG_FORMAT`]
* `--spawn value` - The number of agents to spawn in parallel (default: 1) [`$BUILDKITE_AGENT_SPAWN`]
* `--cancel-signal value` - The signal to use for cancellation (default: "SIGTERM") [`$BUILDKITE_CANCEL_SIGNAL`]
* `--redacted-vars value` - Pattern of environment variable names containing sensitive values (default: "*_PASSWORD", "*_SECRET", "*_TOKEN", "*_ACCESS_KEY", "*_SECRET_KEY") [`$BUILDKITE_REDACTED_VARS`]
* `--tracing-backend value` - The name of the tracing backend to use. [`$BUILDKITE_TRACING_BACKEND`]
* `--token value` - Your account agent token [`$BUILDKITE_AGENT_TOKEN`]
* `--endpoint value` - The Agent API endpoint (default: "`https://agent.buildkite.com/v3`") [`$BUILDKITE_AGENT_ENDPOINT`]
* `--no-http2` - Disable HTTP2 when communicating with the Agent API. [`$BUILDKITE_NO_HTTP2`]
* `--debug-http` - Enable HTTP debug mode, which dumps all request and response bodies to the log [`$BUILDKITE_AGENT_DEBUG_HTTP`]
* `--no-color` - Don't show colors in logging [`$BUILDKITE_AGENT_NO_COLOR`]
* `--debug` - Enable debug mode [`$BUILDKITE_AGENT_DEBUG`]
* `--experiment value` - Enable experimental features within the buildkite-agent [`$BUILDKITE_AGENT_EXPERIMENT`]
* `--profile value` - Enable a profiling mode, either cpu, memory, mutex or block [`$BUILDKITE_AGENT_PROFILE`]
* `--tags-from-ec2` - Include the host's EC2 meta-data as tags (instance-id, instance-type, and ami-id) [`$BUILDKITE_AGENT_TAGS_FROM_EC2`]
* `--tags-from-gcp` - Include the host's Google Cloud instance meta-data as tags (instance-id, machine-type, preemptible, project-id, region, and zone) [`$BUILDKITE_AGENT_TAGS_FROM_GCP`]

