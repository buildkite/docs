A build state can be one of of the following values:

`creating`, `scheduled`, `running`, `passed`, `failing`, `failed`, `blocked`, `canceling`, `canceled`, `skipped`, `not_run`.

You can query for `finished` builds to return builds in any of the following states: `passed`, `failed`, `blocked`, or `canceled`.

> 🚧
> When a [triggered build](/docs/pipelines/configure/step-types/trigger-step) fails, the step that triggered it will be stuck in the `running` state forever.
> When all the steps in a build are skipped (either by using skip attribute or by using `if` condition), the build state will be marked as `not_run`.
> Unlike the [`notify` attribute](/docs/pipelines/notifications), the build state value for a [`steps` attribute](/docs/pipelines/configure/defining-steps) may differ depending on the state of a pipeline. For example, when a build is blocked within a `steps` section, the `state` value in the [API response for getting a build](/docs/apis/rest-api/builds#get-a-build) retains its last value (for example, `passed`), rather than having the value `blocked`, and instead, the response also returns a `blocked` field with a value of `true`.
