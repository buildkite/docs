# Waterfall view

> 📘 Business/Enterprise feature
> Waterfall is only available on [Business or Enterprise](https://buildkite.com/pricing) plans.

## Overview

Waterfall view allows you to see your build data as a waterfall chart, providing enhanced visibility into your build's job processes, durations and dependencies.

To access waterfall view:

1. Navigate to any build page.
1. Select _View_.
1. Select _Waterfall_ from the dropdown menu.

Each row in the chart represents a job.
Grey bars represent the Waiting time:  a job spent waiting for an agent to be assigned.
Yellow represents the Dispatching time: time taken from when the agent is assigned to the job, and when the job started running.
Green represents the Running time: time it took from when the agent started running the job to when it finished running the job.

Hover over a bar to view a popover displaying the durations.

Time is rounded to the nearest second.

If a job is retried, the retry data will display in the existing row for that job.

Group, matrix and parallel jobs are represented as nested rows underneath a 'parent' row. This parent row displays a solid bar, representing the total duration of its child rows. If any child rows exhibit hard failures, it is red, otherwise, it is green.


