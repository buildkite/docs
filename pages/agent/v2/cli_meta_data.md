# buildkite-agent meta-data

> 🚧 This page references the out-of-date Buildkite Agent v2.
> For docs referencing the Buildkite Agent v3, <a href="/docs/agent/v3/cli_meta_data">see the latest version of this document</a>.

The Buildkite Agent's `meta-data` command provides your build pipeline with a powerful key/value data-store that works across build steps and build agents, no matter the machine or network.

See the [Using build meta-data](/docs/pipelines/configure/build-meta-data) guide for a step-by-step example.

## Setting data

Use this command in your build scripts to save string data in the Buildkite meta-data store.

```
$ buildkite-agent meta-data set --help
Usage:

   buildkite-agent meta-data set <key> [value] [arguments...]

Description:

   Set arbitrary data on a build using a basic key/value store.

   You can supply the value as an argument to the command, or pipe in a file or
   script output.

Example:

   $ buildkite-agent meta-data set "foo" "bar"
   $ buildkite-agent meta-data set "foo" < ./tmp/meta-data-value
   $ ./script/meta-data-generator | buildkite-agent meta-data set "foo"

Options:

   --job value                 Which job should the meta-data be set on [$BUILDKITE_JOB_ID]
   --agent-access-token value  The access token used to identify the agent [$BUILDKITE_AGENT_ACCESS_TOKEN]
   --endpoint value            The Agent API endpoint (default: "https://agent.buildkite.com/v3") [$BUILDKITE_AGENT_ENDPOINT]
   --no-color                  Don't show colors in logging [$BUILDKITE_AGENT_NO_COLOR]
   --debug                     Enable debug mode [$BUILDKITE_AGENT_DEBUG]
   --debug-http                Enable HTTP debug mode, which dumps all request and response bodies to the log [$BUILDKITE_AGENT_DEBUG_HTTP]
```

## Getting data

Use this command in your build scripts to get a previously saved value from the Buildkite meta-data store.

```
$ buildkite-agent meta-data get --help
Usage:

   buildkite-agent meta-data get <key> [arguments...]

Description:

   Get data from a builds key/value store.

Example:

   $ buildkite-agent meta-data get "foo"

Options:

   --default value             If the meta-data value doesn't exist return this instead
   --job value                 Which job should the meta-data be retrieved from [$BUILDKITE_JOB_ID]
   --agent-access-token value  The access token used to identify the agent [$BUILDKITE_AGENT_ACCESS_TOKEN]
   --endpoint value            The Agent API endpoint (default: "https://agent.buildkite.com/v3") [$BUILDKITE_AGENT_ENDPOINT]
   --no-color                  Don't show colors in logging [$BUILDKITE_AGENT_NO_COLOR]
   --debug                     Enable debug mode [$BUILDKITE_AGENT_DEBUG]
   --debug-http                Enable HTTP debug mode, which dumps all request and response bodies to the log [$BUILDKITE_AGENT_DEBUG_HTTP]
```
