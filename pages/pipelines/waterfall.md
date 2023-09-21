# Waterfall view

> 📘 Business/Enterprise feature
> Waterfall is only available on [Business or Enterprise](https://buildkite.com/pricing) plans.

## Overview

Waterfall view allows you to see your build data as a waterfall chart, providing enhanced visibility into your build's job processes, durations and dependencies.

To access waterfall view:

1. Navigate to any build page.
1. Select _View_.
1. Select _Waterfall_ from the dropdown menu.

<!-- TODO: SCREENSHOT OF BASIC ROW WITH POPOVER GOES HERE -->

Most rows will show bars with three coloured sections.
The grey section represents the time a job spent waiting for an agent to be assigned.
The yellow section represents the time since the agent was assigned, and the time the agent started running the job.
The last section represents the time it took from when the agent started running the job to when it finished running the job. This section is green is the job passed, and red if it failed.

You can hover over a bar to view these durations. Time is rounded to the nearest second.

<!-- TODO: SCREENSHOT OF NESTED ROW WITH POPOVER GOES HERE -->

Group, matrix and parallel steps are shown with nested rows underneath a 'parent' row. This parent row displays a solid bar representing the total duration of its child rows. The bar is green if all child rows passed, and red if any of them failed.




