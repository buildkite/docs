---
toc: false
---

# Buildkite Agent prioritization

By setting an Agent's priority value you determine when it gets assigned build jobs compared to other agents.
Agents with a higher value priority number are assigned work first, with the last priority being given to Agents with the default value of `null`.

To set an Agent's priority you can set it in the configuration file:

```
priority=9
```

or with the `--priority` command line flag:

```
buildkite-agent start --priority 9
```

or with the `BUILDKITE_AGENT_PRIORITY` an environment variable:

```
env BUILDKITE_AGENT_PRIORITY=9 buildkite-agent start
```

## Load balancing

You can use the Agent priority value to load balance jobs across machines running multiple Agents. Be aware that this priority value is only set when the agents are started, as described above. The resulting load balancing is then determined internally by Buildkite Pipelines, and is unrelated to typical network load balancing mechanisms.

For example if you have 2 machines with 3 Agents on each machine, you would set one Agent on each machine to `priority=3`, one on each to `priority=2`, and one on each to `priority=1`.

Buildkite will then automatically load balance the jobs across machines, as it will assign jobs to the high priority agents first.
