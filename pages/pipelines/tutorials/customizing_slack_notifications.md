---
keywords: docs, pipelines, tutorials, slack, notifications, customize, pull request
---

# Customizing Slack notifications

This page is a collection of how-tos for customizing Slack notifications in Buildkite Pipelines. Each section addresses a specific use case independently. Pick the ones that match your needs and combine the relevant `notify` attributes into your own `pipeline.yml`. The use cases are not designed to be applied all at once.

The how-tos cover:

- [Sending a Slack message on build failure](#send-a-slack-message-on-build-failure).
- Mentioning the [pull request creator](#mention-the-pull-request-creator) or the [user who unblocked a build](#mention-the-user-who-unblocked-a-build).
- [Restricting notifications to specific failure scenarios](#notify-only-specific-failure-scenarios) using conditionals.
- [Combining multiple notification rules](#combine-multiple-notification-rules) to route different events to different channels.
- [Posting notifications from dynamically generated steps](#notifications-in-dynamic-pipelines).
- [Guaranteeing that a final notification step runs](#guarantee-a-final-slack-notification-runs) regardless of build outcome.

For the full reference of `notify` attributes and conditionals, see [Triggering notifications](/docs/pipelines/configure/notify) and [Conditionals](/docs/pipelines/configure/conditionals).

## Before you start

Before configuring Slack notifications in your pipeline, make sure you have:

- An existing pipeline in Buildkite Pipelines that builds pull requests. To set up pull request builds, see [Source control](/docs/pipelines/source-control).
- A Slack notification service connected to your Buildkite organization. Either of the following options works for this tutorial:

    * The [Slack Workspace](/docs/pipelines/integrations/notifications/slack-workspace) notification service, which requires a once-off configuration per Slack workspace and lets you notify any channel or user.
    * One or more [Slack](/docs/pipelines/integrations/notifications/slack) notification services, each configured for a specific channel or user.

- Familiarity with the [`notify` attribute](/docs/pipelines/configure/notify) and [conditionals](/docs/pipelines/configure/conditionals) in `pipeline.yml`.

> 📘 Required permissions
> Setting up a Slack notification service requires Buildkite organization admin access. Once a service is configured, any user who can edit the pipeline's YAML can add `notify` attributes to it.

## Send a Slack message on build failure

The simplest way to notify a Slack channel when a build fails is to add a build-level `notify` attribute that uses the `if` conditional to match failed builds.

Add the following to your `pipeline.yml`:

```yaml
notify:
  - slack: "developer-team#builds"
    if: build.state == "failed"

steps:
  - label: "Tests"
    command: "npm test"
```
{: codeblock-file="pipeline.yml"}

This sends a notification to the `#builds` channel in the `developer-team` workspace whenever a build finishes in the `failed` state. Replace the workspace and channel name with values that match your own Slack notification service.

> 🚧
> When using only a channel name, you must specify this name in quotes. Otherwise, the `#` will cause the channel name to be treated as a YAML comment.

## Mention the pull request creator

To draw the attention of the user who opened the pull request, include a Slack user mention in a custom message. Slack mentions use the `<@user-id>` syntax, where `user-id` is the Slack user ID of the person to mention. See the [Slack documentation on mentioning users](https://api.slack.com/reference/surfaces/formatting#mentioning-users) for how to find a particular user's ID.

The following example posts a custom message to `#builds` and mentions a specific Slack user when the build fails:

```yaml
notify:
  - slack:
      channels:
        - "developer-team#builds"
      message: "Build failed for `${BUILDKITE_BRANCH}` <@U018FG***>, please take a look."
    if: build.state == "failed"
```
{: codeblock-file="pipeline.yml"}

> 🚧 Build creator environment variable
> You cannot substitute a Slack user mention with the build creator environment variable value directly. To dynamically mention the user who created the build, maintain a mapping from Buildkite user identifiers (such as `build.creator.email` or `build.creator.id`) to Slack user IDs in your build script, then use [annotations](/docs/pipelines/configure/annotations) or a [dynamic pipeline](/docs/pipelines/configure/dynamic-pipelines) step to upload a `notify` block that includes the resolved Slack user ID.

For an overview of available build creator and author variables, see [Supported variables](/docs/pipelines/configure/conditionals#variable-and-syntax-reference-variables).

### Dynamically mention the build creator

To mention the build creator at runtime, generate the `notify` block from a script that translates the Buildkite creator email or ID into the corresponding Slack user ID, then upload the result using `buildkite-agent pipeline upload`.

The following example uses a `pre-command` step to look up the Slack user ID and emit a dynamic pipeline:

```yaml
steps:
  - label: "Tests"
    command: "npm test"
  - wait: ~
    continue_on_failure: true
  - label: ":slack: Notify creator on failure"
    command: ".buildkite/notify-creator.sh | buildkite-agent pipeline upload"
```
{: codeblock-file="pipeline.yml"}

The example `notify-creator.sh` script below reads `BUILDKITE_BUILD_CREATOR_EMAIL` from the environment, looks up the corresponding Slack user ID from a JSON map file checked into the repository, and emits a YAML pipeline fragment containing a `notify` attribute with the resolved `<@user-id>` mention.

The map file `.buildkite/slack-user-map.json` lists the email-to-Slack-user-ID pairs:

```json
{
  "alex@example.com": "U045*****",
  "sam@example.com": "U07DCC***"
}
```
{: codeblock-file=".buildkite/slack-user-map.json"}

The script uses [`jq`](https://jqlang.org/) to perform the lookup:

```bash
#!/usr/bin/env bash
set -euo pipefail

email="${BUILDKITE_BUILD_CREATOR_EMAIL:-}"
map_file=".buildkite/slack-user-map.json"

if [[ -z "$email" ]]; then
  echo "BUILDKITE_BUILD_CREATOR_EMAIL is not set; skipping creator mention." >&2
  exit 0
fi

slack_user_id=$(jq -r --arg email "$email" '.[$email] // empty' "$map_file")

if [[ -z "$slack_user_id" ]]; then
  echo "No Slack user ID mapped for $email; skipping creator mention." >&2
  exit 0
fi

cat <<EOF
notify:
  - slack:
      channels:
        - "developer-team#builds"
      message: "Build #\${BUILDKITE_BUILD_NUMBER} failed. <@$slack_user_id>, please take a look."
    if: build.state == "failed"
EOF
```
{: codeblock-file=".buildkite/notify-creator.sh"}

The `\${BUILDKITE_BUILD_NUMBER}` reference uses a backslash to escape the variable so the shell does not interpolate it at script run time. The agent then interpolates it when it processes the uploaded pipeline. The `$slack_user_id` reference is interpolated by the shell so the resolved Slack user ID is baked into the uploaded YAML.

If you do not maintain a JSON map file, replace the `jq` lookup with a Slack API call (`users.lookupByEmail`) or any other directory that maps Buildkite emails to Slack user IDs.

For more on generating pipeline configuration at runtime, see [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines).

### Send a Slack DM to the user who triggered the build

You cannot supply environment variables or [build meta-data](/docs/pipelines/configure/build-meta-data) directly to the `notify` attribute. To send a Slack direct message to the user who triggered the build—on events such as build started, discovery finished, a test failure, or build finished—use a [dynamic pipeline](/docs/pipelines/configure/dynamic-pipelines) upload that interpolates the resolved Slack user ID into a generated `notify` block.

The following example uses a shell `<<EOF` here document to upload a step whose `notify` attribute references a `SLACK_USER_ID` environment variable. Set `SLACK_USER_ID` earlier in the build (for example, by mapping `BUILDKITE_BUILD_CREATOR_EMAIL` to a Slack user ID in a hook or a preceding step):

```yaml
steps:
  - label: ":slack: Notify triggering user"
    command: |
      buildkite-agent pipeline upload <<EOF
      steps:
        - command: "echo 'Notifying user...'"
          notify:
            - slack:
                channels:
                  - "${SLACK_USER_ID}"
                message: |
                  Your custom message here.
      EOF
```
{: codeblock-file="pipeline.yml"}

Repeat this pattern at different points in the pipeline to send a DM on each event of interest, such as discovery finishing, a specific test failing, or the build completing. Use `if` conditionals on the generated step to fire the DM only when the corresponding outcome occurs.

## Mention the user who unblocked a build

The `BUILDKITE_UNBLOCKER` environment variable is only set after a [block step](/docs/pipelines/configure/step-types/block-step) is unblocked, so it cannot be resolved at the time the initial `pipeline.yml` is uploaded. To include the unblocker's name in a Slack message, add a step after the block step that uploads a dynamic pipeline fragment containing the `notify` attribute. Escape the variable with `$$` so the agent passes it through to the uploaded pipeline, where it is resolved at run time:

```yaml
steps:
  - block: ":warning: Unblock this pipeline"

  - label: ":slack: Unblocker notification"
    command: |
      buildkite-agent pipeline upload <<EOF
      notify:
        - slack:
            channels:
              - "developer-team#builds"
            message: '$$BUILDKITE_UNBLOCKER has unblocked the pipeline.'
      EOF

  - label: "Build"
    command: "make build"
```
{: codeblock-file="pipeline.yml"}

The same pattern works for the related `BUILDKITE_UNBLOCKER_EMAIL`, `BUILDKITE_UNBLOCKER_ID`, and `BUILDKITE_UNBLOCKER_TEAMS` variables. To mention the unblocker as a Slack user instead of including their name, map `BUILDKITE_UNBLOCKER_EMAIL` to a Slack user ID using the same approach described in [Dynamically mention the build creator](#mention-the-pull-request-creator-dynamically-mention-the-build-creator).

## Notify only specific failure scenarios

By default, restricting notifications to `build.state == "failed"` only sends one notification per failed build. The following sections show how to refine that behavior for common scenarios. For the full list of supported conditionals (including patterns such as "all failures and first successful pass"), see [Conditional Slack notifications](/docs/pipelines/configure/notify#slack-channel-and-direct-messages-conditional-slack-notifications) in the `notify` reference.

### Notify on first failure only

If a pipeline fails repeatedly, you might not want a notification for every failed build. The `pipeline.started_failing` conditional sends a notification only when a pipeline transitions from a passing state to a failing state:

```yaml
notify:
  - slack:
      channels:
        - "developer-team#builds"
      message: ":rotating_light: `${BUILDKITE_PIPELINE_SLUG}` started failing on `main`."
    if: build.branch == "main" && pipeline.started_failing
```
{: codeblock-file="pipeline.yml"}

The `pipeline.started_failing` conditional is only available with the [Slack Workspace](/docs/pipelines/integrations/notifications/slack-workspace) notification service.

> 📘 Limiting by consecutive failures
> Buildkite Pipelines supports limiting Slack notifications to the first failure (`pipeline.started_failing`) and to the first pass after a failure (`pipeline.started_passing`). There is no built-in conditional for triggering a notification only after _N_ consecutive failed or passed builds.
>
> If you have configured automatic [job retries](/docs/pipelines/configure/retry), one workaround is to use a [`post-command` or `pre-exit` hook](/docs/agent/hooks) to perform a dynamic `buildkite-agent pipeline upload` of a command step that posts a Slack notification once `BUILDKITE_RETRY_COUNT` reaches a threshold. This approach checks consecutive failures at the job level rather than the build level.

### Notify when a previously failing build passes

To follow up the previous notification with confirmation that the pipeline has recovered, use the `pipeline.started_passing` conditional:

```yaml
notify:
  - slack:
      channels:
        - "developer-team#builds"
      message: ":white_check_mark: `${BUILDKITE_PIPELINE_SLUG}` is back to passing on `main`."
    if: build.branch == "main" && pipeline.started_passing
```
{: codeblock-file="pipeline.yml"}

### Notify on pull request branches only

To restrict failure notifications to pull request builds, combine `build.state` and `build.pull_request.id`:

```yaml
notify:
  - slack:
      channels:
        - "developer-team#pr-failures"
      message: "Build #${BUILDKITE_BUILD_NUMBER} for PR #${BUILDKITE_PULL_REQUEST} failed."
    if: build.state == "failed" && build.pull_request.id != null
```
{: codeblock-file="pipeline.yml"}

This pattern is useful for separating noisy `main` branch notifications from focused per-pull-request alerts.

### Notify when a specific step fails

To send a Slack message immediately when a single step fails, attach a step-level `notify` attribute and use the `step.outcome` conditional:

```yaml
steps:
  - label: "Integration tests"
    command: "./scripts/integration-tests.sh"
    notify:
      - slack:
          channels:
            - "developer-team#qa"
          message: "Integration tests failed in build #${BUILDKITE_BUILD_NUMBER}."
        if: step.outcome == "hard_failed"
```
{: codeblock-file="pipeline.yml"}

> 🚧
> To trigger conditional notifications to a Slack channel, you must first configure [Conditional notifications for Slack](/docs/pipelines/integrations/notifications/slack#conditional-notifications). Build-state conditionals (`build.state`) cannot be used on step-level notifications, since a step cannot know the state of the entire build.

### Notify on soft-failed steps

A [soft-failed](/docs/pipelines/configure/soft-fail) step does not fail the overall build, but you might still want a Slack message to record the event:

```yaml
steps:
  - label: "Lint"
    command: "./scripts/lint.sh"
    soft_fail: true
    notify:
      - slack:
          channels:
            - "developer-team#builds"
          message: "Lint reported issues but the build continued."
        if: step.outcome == "soft_failed"
```
{: codeblock-file="pipeline.yml"}

## Combine multiple notification rules

You can declare more than one `notify` entry to route different events to different channels. The following example notifies a broad team channel on the first failure, mentions a specific on-call user for `main` branch failures, and sends per-pull-request alerts to a separate channel:

```yaml
notify:
  - slack:
      channels:
        - "developer-team#builds"
      message: ":rotating_light: `${BUILDKITE_PIPELINE_SLUG}` started failing."
    if: build.branch == "main" && pipeline.started_failing
  - slack:
      channels:
        - "developer-team#oncall"
      message: "On-call <@U045GK***>, the `main` branch build failed."
    if: build.branch == "main" && build.state == "failed"
  - slack:
      channels:
        - "developer-team#pr-failures"
      message: "PR #${BUILDKITE_PULL_REQUEST} build failed: ${BUILDKITE_BUILD_URL}"
    if: build.state == "failed" && build.pull_request.id != null

steps:
  - label: "Tests"
    command: "npm test"
```
{: codeblock-file="pipeline.yml"}

Each entry is evaluated independently, so a single failed build can trigger more than one of these messages.

## Notifications in dynamic pipelines

Build-level `notify` in your initial `pipeline.yml` covers the whole build, including any steps added by `buildkite-agent pipeline upload`. You do not need to repeat the build-level `notify` in each uploaded fragment.

Step-level `notify` is different. To send a notification when a specific generated step fails, your generator script must include `notify` on that step as it is not inherited from the initial `pipeline.yml`. Only Slack, GitHub checks, GitHub commit statuses, and Basecamp are available at step level. Email, PagerDuty, and webhook notifications are build-level only, so configure those in the initial `pipeline.yml`.

The following example shows a generated step that posts to Slack when it hard-fails:

```yaml
steps:
  - label: ":rocket: Deploy to production"
    command: "make deploy"
    notify:
      - slack:
          channels:
            - "developer-team#deploys"
          message: "Production deploy failed."
        if: step.outcome == "hard_failed"
```
{: codeblock-file="pipeline.yml"}

### Post a final Slack summary after dynamically generated steps

When earlier steps in a build use `buildkite-agent pipeline upload` to generate more steps, you might want a final step that waits for everything to finish and then posts a Slack summary. To make the final step wait for the generated steps, declare the upload steps, the `wait`, and the summary step together in a single parent `pipeline.yml`.

The following parent pipeline runs two steps that each generate and upload more steps, waits for all uploaded steps to complete, then runs a validation step that posts a Slack message:

```yaml
steps:
  - label: "Part 1"
    command: ".buildkite/generate-part1.sh | buildkite-agent pipeline upload"

  - label: "Part 2"
    command: ".buildkite/generate-part2.sh | buildkite-agent pipeline upload"

  - wait

  - label: ":white_check_mark: Validation"
    command: ".buildkite/validate.sh"
    notify:
      - slack:
          channels:
            - "developer-team#builds"
          message: "Build #${BUILDKITE_BUILD_NUMBER} validation summary posted."
        if: step.outcome == "passed" || step.outcome == "hard_failed"
```
{: codeblock-file="pipeline.yml"}

Each `Part N` step can upload as many steps as needed. Because the `wait` and the validation step are declared in the parent `pipeline.yml`, the validation step only runs after every uploaded step has finished. Keep the `wait` and the final summary step at the end of the parent pipeline so the summary always runs after everything else, regardless of how many chunked upload steps precede them.

## Guarantee a final Slack notification runs

If an earlier step hard-fails, Buildkite Pipelines does not run subsequent steps in the build, so a trailing Slack notification step never executes. The following patterns ensure a final notification always runs and can report on the overall outcome.

### Use a wait step with `continue_on_failure`

Place a `wait` step with `continue_on_failure: true` before the final notification step so the notification step still runs even if earlier steps hard-fail. Use `buildkite-agent step get state --step <key>` from the notification step's command to inspect the outcome of a specific earlier step (identified by its `key`, or by `BUILDKITE_STEP_ID` for the current step), instead of relying on the overall build state:

```yaml
steps:
  - label: "Tests"
    key: "tests"
    command: "npm test"

  - wait: ~
    continue_on_failure: true

  - label: ":slack: Final report"
    command: |
      tests_state=$(buildkite-agent step get state --step tests)
      echo "Tests step finished with state: $tests_state"
    notify:
      - slack:
          channels:
            - "developer-team#builds"
          message: "Build #${BUILDKITE_BUILD_NUMBER} finished. Check the final report step for per-step outcomes."
```
{: codeblock-file="pipeline.yml"}

If you would prefer subsequent steps to keep running without `wait` and `continue_on_failure`, mark the earlier steps with [`soft_fail`](/docs/pipelines/configure/step-types/command-step#soft-fail-attributes). Soft-failed steps do not stop the build, so a downstream notification step runs normally.

### Send notifications from a job hook

For notifications that should fire after every job, not just at the end of the build, use a [`post-command` or `pre-exit` agent hook](/docs/agent/hooks). The `post-command` hook runs immediately after each step's command, and `pre-exit` runs just before the job ends. Both have access to the job's exit status and the `BUILDKITE_*` environment variables, so a shell script can call the Slack API directly without adding any steps to `pipeline.yml`. This approach is best when the same notification logic should apply across many pipelines or jobs.

### Wrap pipeline upload to inject a final step

To enforce a final Slack notification across every pipeline in your organization without per-pipeline configuration, wrap `buildkite-agent pipeline upload` with a script that reads the YAML being uploaded, appends a `wait` step with `continue_on_failure: true` followed by the notification step, then forwards the modified YAML to the real `buildkite-agent pipeline upload`. Invoke the wrapper from an agent hook so it intercepts every upload automatically.

> 🚧 Wrapper script considerations
> A wrapper around `buildkite-agent pipeline upload` is powerful but adds operational complexity. The wrapper must handle YAML parsing, error cases, and pipelines that already include their own final notification step, and it can be difficult to debug when something goes wrong. Reserve this approach for environments where consistent end-of-build behavior is mandatory and per-pipeline configuration is not viable.

## Verify your notifications

After applying any of the how-tos above, confirm the resulting notifications behave as expected:

1. Commit and push your `pipeline.yml` changes to a branch.
1. Trigger a build that exercises the scenario you configured. For failure-related conditionals, this might mean introducing a failing test; for unblocker mentions, this means unblocking a block step; for `pipeline.started_passing`, this means pushing a fix after a previous failure.
1. Confirm that the configured Slack channels receive the expected messages, and that any user mentions resolve to the correct Slack users.

If a notification does not arrive, check the following:

- The relevant Slack notification service is connected and includes the pipeline in its **Pipelines** filter.
- The Slack channel exists and the Buildkite app has been invited to it.
- The `if` expression matches the build state at the moment the notification event fires. See [Supported variables](/docs/pipelines/configure/conditionals#variable-and-syntax-reference-variables) for the full list of conditionals.

## Next steps

- Read more about the [`notify` attribute](/docs/pipelines/configure/notify) for the full reference of supported notification targets and conditional patterns.
- Configure additional channels with the [Slack notification service](/docs/pipelines/integrations/notifications/slack) or simplify per-pipeline configuration with the [Slack Workspace notification service](/docs/pipelines/integrations/notifications/slack-workspace).
- Combine Slack notifications with [build annotations](/docs/pipelines/configure/annotations) to share rich context, such as failing test output, alongside each Slack message.
