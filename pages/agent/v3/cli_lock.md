# `buildkite-agent lock`

The Buildkite Agent's `lock` subcommands provide the ability to coordinate multiple concurrent builds on the same host that access shared resources.

With the agent-api experiment enabled, processes can acquire and release a lock with `acquire` and `release` subcommands. For the special case of performing setup once for the life of the agent (and waiting until it is complete) there are the `do` and `done` subcommands. These provide an alternative to using `flock` or OS-dependent locking mechanisms. To enable the agent-api experiment, include the `--experiment=agent-api` flag when starting the agents.

## Inspecting the state of a lock

<%= render 'agent/v3/help/lock_get' %>

## Acquiring a lock

<%= render 'agent/v3/help/lock_acquire' %>

## Releasing a previously-acquired lock

<%= render 'agent/v3/help/lock_release' %>

## Starting a do-once section

<%= render 'agent/v3/help/lock_do' %>

## Completing a do-once section

<%= render 'agent/v3/help/lock_done' %>

