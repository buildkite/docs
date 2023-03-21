# `buildkite-agent env`

The Buildkite Agent's `env` subcommands provide the ability to inspect environment variables.


## Printing env

This command is used internally by the agent and isn't recommended for use in your builds.

<%= render 'agent/v3/help/env_dump' %>

## Inspecting and modifying env from within a job

Jobs can inspect and modify their environment variables using the `env get`, `set`, and `unset` commands, so long as the `job-api` experiment is enabled. These commands provide an alternative to using shell commands to inspect and modify environment variables.

### Getting a job's environment variables

<%= render 'agent/v3/help/env_get' %>

### Setting a job's environment variables

<%= render 'agent/v3/help/env_set' %>

### Removing environment variables from a job

<%= render 'agent/v3/help/env_unset' %>
