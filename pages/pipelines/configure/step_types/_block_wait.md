If a block step follows or precedes a wait step in your build, the wait step will be ignored and only the block step will run, like in this example:

```yml
steps:
  - command: ".buildkite/steps/yarn"
  - wait: ~
  - block: "unblock me"
```
{: codeblock-file="pipeline.yml"}

But let's consider a different example. Now the wait step (with `continue_on_failure: true`) will be ignored, but the block step will _also not run_, because the 'previous' command step failed.


```yml
steps:
  - command: "exit -1"
  - wait: ~
    continue_on_failure: true
  - block: "unblock me"
```
{: codeblock-file="pipeline.yml"}

If you need to run a block step after a failed step, set [`soft_fail`](/docs/pipelines/configure/dependencies#allowed-failure-and-soft-fail) on the failing step:

```yml
steps:
  - command: "exit -1"
    soft_fail:
      - exit_status: "*"
  - block: "unblock me"
```
{: codeblock-file="pipeline.yml"}

Alternatively, it is possible to use a wait step with a block step if conditionals are used. In these cases, the wait step must come before the block step:

```yml
steps:
  - command: ".buildkite/steps/yarn"
  - wait:
    if: build.source == "schedule"
  - block: "Deploy changes?"
    if: build.branch == pipeline.default_branch && build.source != "schedule"
  - command: ".buildkite/scripts/deploy"
    if: build.branch == pipeline.default_branch
```
{: codeblock-file="pipeline.yml"}
