# buildkite-agent env

The Buildkite Agent's `env` subcommands provide the ability to inspect environment variables.

From version 3.64.0 of the Buildkite Agent, jobs can inspect and modify their environment variables using the `get`, `set`, and `unset` sub-commands. These provide an alternative to using shell commands to inspect and modify environment variables.

## Printing env

This command is used internally by the agent and isn't recommended for use in your builds.

<%= render 'agent/v3/help/env_dump' %>

## Getting a job's environment variables

<%= render 'agent/v3/help/env_get' %>

## Setting a job's environment variables

<%= render 'agent/v3/help/env_set' %>

## Removing environment variables from a job

<%= render 'agent/v3/help/env_unset' %>
