A job state can be one of the following values:

`pending`, `waiting`, `waiting_failed`, `blocked`, `blocked_failed`, `unblocked`, `unblocked_failed`, `limiting`, `limited`, `scheduled`, `assigned`, `accepted`, `running`, `finished`, `passed`, `failed`, `canceling`, `canceled`, `expired`, `timing_out`, `timed_out`, `skipped`, `broken`, `platform_limiting`, or `platform_limited`.

Note: `finished` is the internal lifecycle terminal state. The REST API maps `finished` to `passed` or `failed` based on the job's exit status, so REST API responses will show `passed` or `failed` instead of `finished`. The GraphQL API uses `finished` for all completed jobs regardless of exit status.
