Build state can be one of `creating`, `scheduled`, `running`, `passed`, `failing`, `failed`, `blocked`, `canceling`, `canceled`, `skipped`, `not_run`.
You can query for `finished` builds to return builds in any of the following states: `passed`, `failed`, `blocked`, or `canceled`.

> 🚧
> When a [triggered build](/docs/pipelines/trigger-step) fails, the step that triggered it will be stuck in the `running` state forever.
> When all the steps in a build are skipped (either by using skip attribute or by using `if` condition), the build state will be marked as `not_run`.
