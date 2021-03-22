## Usage

`buildkite-agent artifact download [options] <query> <destination>`

## Description

Downloads artifacts specified by <query> from Buildkite to <destination>
directory on the local machine.

Note: You need to ensure that your search query is surrounded by quotes if
using a wild card as the built-in shell path globbing will provide files,
which will break the download.

## Example

    $ buildkite-agent artifact download "pkg/*.tar.gz" . --build xxx

This will search across all the artifacts for the build with files that match that part.
The first argument is the search query, and the second argument is the download destination.

If you're trying to download a specific file, and there are multiple artifacts from different
jobs, you can target the particular job you want to download the artifact from:

    $ buildkite-agent artifact download "pkg/*.tar.gz" . --step "tests" --build xxx

You can also use the step's jobs id (provided by the environment variable $BUILDKITE_JOB_ID)

## Options

* `--step value` - Scope the search to a particular step by using either its name or job ID
* `--build value` - The build that the artifacts were uploaded to [`$BUILDKITE_BUILD_ID`]
* `--include-retried-jobs` - Include artifacts from retried jobs in the search [`$BUILDKITE_AGENT_INCLUDE_RETRIED_JOBS`]
* `--agent-access-token value` - The access token used to identify the agent [`$BUILDKITE_AGENT_ACCESS_TOKEN`]
* `--endpoint value` - The Agent API endpoint (default: "https://agent.buildkite.com/v3") [`$BUILDKITE_AGENT_ENDPOINT`]
* `--no-http2` - Disable HTTP2 when communicating with the Agent API. [`$BUILDKITE_NO_HTTP`2]
* `--debug-http` - Enable HTTP debug mode, which dumps all request and response bodies to the log [`$BUILDKITE_AGENT_DEBUG_HTTP`]
* `--no-color` - Don't show colors in logging [`$BUILDKITE_AGENT_NO_COLOR`]
* `--debug` - Enable debug mode [`$BUILDKITE_AGENT_DEBUG`]
* `--experiment value` - Enable experimental features within the buildkite-agent [`$BUILDKITE_AGENT_EXPERIMENT`]
* `--profile value` - Enable a profiling mode, either cpu, memory, mutex or block [`$BUILDKITE_AGENT_PROFILE`]

