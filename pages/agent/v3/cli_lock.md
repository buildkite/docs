# buildkite-agent lock

The Buildkite Agent's `lock` subcommands provide the ability to coordinate multiple concurrent builds on the same host that access shared resources.

> 🛠 Experimental feature
> The agent-api experiment must be enabled to use the `lock` command. To enable the agent-api experiment, include the `--experiment=agent-api` flag when starting the agent.

With the `lock` command, processes can acquire and release a lock using the `acquire` and `release` subcommands. For the special case of performing setup once for the life of the agent (and waiting until it is complete), there are the `do` and `done` subcommands. These provide an alternative to using `flock` or OS-dependent locking mechanisms.

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

