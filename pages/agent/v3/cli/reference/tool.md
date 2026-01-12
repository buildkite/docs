# buildkite-agent tool

The Buildkite Agent's `tool` subcommands are used for performing tasks that are expected to be called by a human as part of setting up a pipeline, rather than during the execution of a job. Any and all of these subcommand may be removed in the future into a separate CLI tool, so they should all be considered experimental.

> 🛠 Experimental feature
> The `tool` subcommand may be removed from the Buildkite Agent in the future.

<!-- vale off -->
## Generate a JSON Web Key Set
<!-- vale on -->

<%= render 'agent/v3/cli/help/tool_keygen' %>

## Sign a pipeline

<%= render 'agent/v3/cli/help/tool_sign' %>
