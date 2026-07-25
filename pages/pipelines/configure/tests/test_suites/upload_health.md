# Upload health

The **Uploads** page shows a summary of test result uploads received by a suite over the selected period. Use it to monitor upload volume, identify rejected or failed uploads, and understand the distribution of test executions across successful uploads.

The page is available to organization members who have private suite access. Anonymous viewers and organization members who are not assigned to the suite cannot access the page.

Use the **1d** and **7d** options to switch between one-day and seven-day summaries. The **7d** option is disabled when your organization's maximum Test Engine time window is shorter than seven days.

## Headline stats

Four summary cards appear at the top of the page:

- **Total uploads**: The combined count of all uploads received in the selected period.
- **Successful uploads**: Uploads that were accepted and processed.
- **Upload problems**: The count of uploads that were rejected or failed, broken down by rejected and failed counts.
- **Test executions**: The total number of test executions reported by successful uploads.

## Upload volume chart

The stacked bar chart displays each time bucket split by outcome:

- **Succeeded** (teal): Uploads accepted and processed.
- **Rejected** (orange): Uploads that were syntactically or semantically invalid.
- **Failed** (red): Uploads that encountered a processing error.

The one-day summary uses 24 one-hour UTC-aligned buckets. The seven-day summary uses 84 two-hour UTC-aligned buckets. The most recent bucket covers the current partial period and is visually distinguished from completed buckets. The chart uses your local timezone for axis labels and the full dates and times shown on hover.

## Executions per successful upload

The histogram uses 18 predefined ranges (from zero executions up to 100,000 or more) to show how successful uploads are distributed by the number of test executions they contained. When there are no successful uploads in the period, the page shows a message instead of the histogram.

## Upload problems

The **Upload problems** table lists the top rejected and failed upload groups, sorted by count and grouped by result, reason code, and message. Up to 50 groups are shown.

The table includes:

- **Result**: `Rejected` or `Failed`.
- **Reason code**: The machine-readable code associated with the outcome, if available.
- **Message**: The human-readable description of the problem.
- **Uploads**: The number of uploads matching this result, reason code, and message combination.

Use this table to identify and fix recurring upload issues in your test collectors.
