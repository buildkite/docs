# Queue metrics
Queue metrics show you the most important statistics to help you optimize your agent setup and
monitor your cluster's performance. These statistics are updated on the page every 10 seconds.

## Agents panel
Agents Connected is the number of agents connected to this cluster queue. The circular chart
represents the fraction of agents that are busy working on jobs compared to those that are idle and
ready for a job. Hovering over the Agents Connected chart pops up the Agent Utilization panel which
shows the same information as the circular chart but with the numerical percentages of agents in
use vs idle.

For the purposes of agent utilization agents are considered busy if they have a job id assigned
to them.

## Jobs panel
Jobs Running and Jobs Waiting shows the number of jobs assigned to an agent, and the number of jobs
not yet assigned to an agent respectively. Jobs Running are any jobs for this cluster queue which
are in a state of RUNNING, CANCELING, TIMING_OUT, ACCEPTED, or ASSIGNED. Jobs Waiting are any jobs
for this cluster queue which are in a state of SCHEDULED.

## Wait panel
Wait shows the various job wait time percentiles for this cluster queue. They represent how long
jobs wait after they are created to be assigned to an agent.
