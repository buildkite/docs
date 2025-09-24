# buildkite-agent step

The Buildkite agent's `step` command provides the ability to retrieve and update the attributes of steps in your `pipeline.yml` files.

## Updating a step

Use this command in your build scripts to update the `label` attribute of a step.

<%= render 'agent/v3/help/step_update' %>

label update works on a step level and not on the job level, it would not be possible to update each job in a step 
## Getting a step

Use this command in your build scripts to get the value of a particular attribute from a step. The following attributes values can be retrieved:

* `agents`
* `command`
* `concurrency_key`
* `concurrency_limit`
* `depends_on`
* `env`
* `if`
* `key`
* `label`
* `notify`
* `outcome`
* `parallelism`
* `state`
* `timeout`
* `type`

<%= render 'agent/v3/help/step_get' %>

## Getting the outcome of a step

If you're only interested in whether a step passed or failed, perhaps to use conditional logic inside your build script, you can use the same approach as above in [Getting a step](#getting-a-step).

For example, the following pipeline has one step that fails (`one`), and another that passes (`two`). After the `wait`, the next two steps print the `outcome` attribute of steps `one` and `two`, and the last step [annotates the build](/docs/agent/v3/cli-annotate#creating-an-annotation) if step `one` fails. Note that `step get` needs the `key` of the step to identify it, not the `label`.

The `outcome` is `passed`, `hard_failed` or `soft_failed`. A [soft fail](/docs/pipelines/configure/step-types/command-step#soft-fail-attributes) is a non-zero exit status that does not fail the build.

```yaml
steps:
  - label: 'Step 1'
    command: "false"
    key: 'one'
  - label: 'Step 2'
    command: "true"
    key: 'two'

  - wait:
    continue_on_failure: true

  - label: 'Step 3'
    command: 'echo `buildkite-agent step get "outcome" --step "one"`'
  - label: 'Step 4'
    command: 'echo `buildkite-agent step get "outcome" --step "two"`'
  - label: 'Step 5'
    command: |
      if [ $(buildkite-agent step get "outcome" --step "one") == "hard_failed" ]; then
        buildkite-agent annotate 'this build failed' --style 'error'
      fi
```

## Canceling a step

Use this command to programmatically cancel all jobs for a step. It is possible to issue graceful and forced cancel commands.

Force canceling a step can be used to cancel lost or hung jobs before their agents would otherwise be marked as lost.

<%= render 'agent/v3/help/step_cancel' %>
