# Upload health

The **Upload health** page shows a rolling summary of test result uploads received by a suite over the current UTC hour and the preceding 23 hours. Use it to monitor upload volume, identify rejected or failed uploads, and understand the distribution of test executions across successful uploads.

The page is available to organization members who have private suite access. Anonymous viewers and organization members who are not assigned to the suite cannot access the page.

## Headline stats

Four summary cards appear at the top of the page:

- **Total uploads**: the combined count of all uploads received in the 24-hour window.
- **Successful uploads**: uploads that were accepted and processed.
- **Upload problems**: the count of uploads that were rejected or failed, broken down by rejected and failed counts.
- **Test executions**: the total number of test executions reported by successful uploads.

## Upload volume chart

The stacked bar chart displays 24 one-hour UTC-aligned buckets, each split by outcome:

- **Succeeded** (teal): uploads accepted and processed.
- **Rejected** (orange): uploads that were syntactically or semantically invalid.
- **Failed** (red): uploads that encountered a processing error.

The most recent bucket covers the current partial UTC hour and is visually distinguished from the completed buckets. Chart labels use your local timezone.

## Executions per successful upload

The histogram shows how successful uploads are distributed by the number of test executions they contained. It uses 18 predefined ranges (from 0 executions up to 100,000 or more). This section is hidden when there are no successful uploads in the period.

## Upload problems

The **Upload problems** table lists the top rejected and failed upload groups, sorted by count and grouped by result, reason code, and message. Up to 50 groups are shown.

The table includes:

- **Result**: `Rejected` or `Failed`.
- **Reason code**: the machine-readable code associated with the outcome, if available.
- **Message**: the human-readable description of the problem.
- **Uploads**: the number of uploads matching this result, reason code, and message combination.

Use this table to identify and fix recurring upload issues in your test collectors.
