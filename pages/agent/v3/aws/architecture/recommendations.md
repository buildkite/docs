---
toc: false
---

# Recommendations

Optimizing your Buildkite agent infrastructure requires balancing performance, cost, and availability based on your team's specific needs and usage patterns. This section provides guidance on sizing your agent pools effectively, helping you avoid both resource waste from over-provisioning and delays from under-provisioning your CI/CD capacity.

## A note on recommended pool size

There is no exact recommended quantity of agents in a pool. An optimal pool size is the minimum number of available agents you would want to have ready to run jobs instantly.

You can start with one or two extra instances that are always available for running lightweight jobs (for example, pipeline uploads), and you can increase the number of agents per machine so that they can run in parallel.

For organizations where at any given moment there are engineers working (for example, for shift-based 24/7 schedules or in globally distributed teams), having a large pool of build agents always available makes sense. Otherwise, idly running agents overnight might be a waste of resources.
