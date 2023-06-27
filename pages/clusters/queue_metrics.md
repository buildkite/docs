# Queue metrics in clusters

Queue metrics show the most important statistics to help you optimize your agent setup and monitor a cluster's performance. These statistics are updated on the page every 10 seconds.

<%= image "cluster-queue-metrics.png", alt: "Screenshot of the queue metrics panel" %>

## Agents panel

_Agents Connected_ is the number of agents connected to the cluster queue. The circular chart represents the fraction of agents that are busy working on jobs compared to those that are idle and ready for a job. Hovering over the chart shows the _Agent Utilization_ panel, which displays the percentage values for each chart component.

<%= image "cluster-queue-metrics-agent-utilization.png", width: 530/2, height: 434/2, alt: "Screenshot of the agent utilization panel" %>

For agent utilization, agents are considered busy if they have a job ID assigned.

## Jobs panel

_Jobs Running_ shows the number of jobs assigned to agents. These are any jobs in the cluster queue in the following states:

- `ASSIGNED`
- `ACCEPTED`
- `RUNNING`
- `CANCELING`
- `TIMING_OUT`

_Jobs Waiting_ shows the number of jobs not yet assigned to an agent. These are any jobs for the cluster queue in the `SCHEDULED` state.

## Wait panel

_Wait_ shows the various job wait time percentiles for this cluster queue's waiting jobs. The percentiles represent how long it takes jobs to be assigned an agent. If there are no waiting jobs, dashes (`-`) are shown instead.
