### Usage

`buildkite-agent step update <attribute> <value> [options...]`

### Description

Update an attribute of a step in the build

### Example

    $ buildkite-agent step update "label" "New Label"
    $ buildkite-agent step update "label" " (add to end of label)" --append
    $ buildkite-agent step update "label" < ./tmp/some-new-label
    $ ./script/label-generator | buildkite-agent step update "label"

### Options

* `--step value` - The step to update. Can be either its ID (BUILDKITE_STEP_ID) or key (BUILDKITE_STEP_KEY) [`$BUILDKITE_STEP_ID`]
* `--build value` - The build to look for the step in. Only required when targeting a step using its key (BUILDKITE_STEP_KEY) [`$BUILDKITE_BUILD_ID`]
* `--append` - Append to current attribute instead of replacing it [`$BUILDKITE_STEP_UPDATE_APPEND`]
* `--agent-access-token value` - The access token used to identify the agent [`$BUILDKITE_AGENT_ACCESS_TOKEN`]
* `--endpoint value` - The Agent API endpoint (default: "`https://agent.buildkite.com/v3`") [`$BUILDKITE_AGENT_ENDPOINT`]
* `--no-http2` - Disable HTTP2 when communicating with the Agent API. [`$BUILDKITE_NO_HTTP2`]
* `--debug-http` - Enable HTTP debug mode, which dumps all request and response bodies to the log [`$BUILDKITE_AGENT_DEBUG_HTTP`]
* `--no-color` - Don't show colors in logging [`$BUILDKITE_AGENT_NO_COLOR`]
* `--debug` - Enable debug mode [`$BUILDKITE_AGENT_DEBUG`]
* `--experiment value` - Enable experimental features within the buildkite-agent [`$BUILDKITE_AGENT_EXPERIMENT`]
* `--profile value` - Enable a profiling mode, either cpu, memory, mutex or block [`$BUILDKITE_AGENT_PROFILE`]

