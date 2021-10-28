### Usage

`buildkite-agent step get <attribute> [options...]`

### Description

Retrieve the value of an attribute in a step. If no attribute is passed, the
entire step will be returned.

In the event a complex object is returned (an object or an array),
you'll need to supply the --format option to tell the agent how it should
output the data (currently only JSON is supported).

### Example

    $ buildkite-agent step get "label" --step "key"
    $ buildkite-agent step get --format json
    $ buildkite-agent step get "retry" --format json
    $ buildkite-agent step get "state" --step "my-other-step"

### Options

* `--step value` - The step to get. Can be either its ID (BUILDKITE_STEP_ID) or key (BUILDKITE_STEP_KEY) [`$BUILDKITE_STEP_ID`]
* `--build value` - The build to look for the step in. Only required when targeting a step using its key (BUILDKITE_STEP_KEY) [`$BUILDKITE_BUILD_ID`]
* `--format value` - The format to output the attribute value in (currently only JSON is supported) [`$BUILDKITE_STEP_GET_FORMAT`]
* `--agent-access-token value` - The access token used to identify the agent [`$BUILDKITE_AGENT_ACCESS_TOKEN`]
* `--endpoint value` - The Agent API endpoint (default: "`https://agent.buildkite.com/v3`") [`$BUILDKITE_AGENT_ENDPOINT`]
* `--no-http2` - Disable HTTP2 when communicating with the Agent API. [`$BUILDKITE_NO_HTTP2`]
* `--debug-http` - Enable HTTP debug mode, which dumps all request and response bodies to the log [`$BUILDKITE_AGENT_DEBUG_HTTP`]
* `--no-color` - Don't show colors in logging [`$BUILDKITE_AGENT_NO_COLOR`]
* `--debug` - Enable debug mode [`$BUILDKITE_AGENT_DEBUG`]
* `--experiment value` - Enable experimental features within the buildkite-agent [`$BUILDKITE_AGENT_EXPERIMENT`]
* `--profile value` - Enable a profiling mode, either cpu, memory, mutex or block [`$BUILDKITE_AGENT_PROFILE`]

