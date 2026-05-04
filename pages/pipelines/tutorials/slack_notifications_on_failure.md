---
keywords: docs, pipelines, tutorials, slack, notifications, failure, pull request
---

# Sending Slack notifications on failure

This tutorial walks through configuring Buildkite Pipelines to send custom Slack notifications when a build fails, including how to mention the pull request creator and how to handle different failure scenarios.

By the end of this tutorial, you will have a `pipeline.yml` file that posts targeted Slack messages on failure events, mentions the user who created the build, and avoids notification fatigue by restricting which events trigger messages.

## Before you start

Before configuring failure notifications in your pipeline, make sure you have:

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
  - slack: "buildkite-community#builds"
    if: build.state == "failed"

steps:
  - label: "Tests"
    command: "npm test"
```
{: codeblock-file="pipeline.yml"}

This sends a notification to the `#builds` channel in the `buildkite-community` workspace whenever a build finishes in the `failed` state. Replace the workspace and channel name with values that match your own Slack notification service.

> 🚧
> When using only a channel name, you must specify this name in quotes. Otherwise, the `#` will cause the channel name to be treated as a YAML comment.

## Mention the pull request creator

To draw the attention of the user who opened the pull request, include a Slack user mention in a custom message. Slack mentions use the `<@user-id>` syntax, where `user-id` is the Slack user ID of the person to mention. See the [Slack documentation on mentioning users](https://api.slack.com/reference/surfaces/formatting#mentioning-users) for how to find a particular user's ID.

The following example posts a custom message to `#builds` and mentions a specific Slack user when the build fails:

```yaml
notify:
  - slack:
      channels:
        - "buildkite-community#builds"
      message: "Build failed for `${BUILDKITE_BRANCH}` <@U024BE7LH>, please take a look."
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

The `notify-creator.sh` script (not shown) is responsible for:

1. Reading `BUILDKITE_BUILD_CREATOR_EMAIL` from the environment.
1. Mapping that email to a Slack user ID using whatever directory you maintain (for example, a JSON file in the repository or a Slack API call).
1. Emitting a YAML pipeline fragment that contains a `notify` attribute with a `<@user-id>` mention.

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

## Notify only specific failure scenarios

By default, restricting notifications to `build.state == "failed"` only sends one notification per failed build. The next sections show how to refine that behavior for common scenarios.

### Notify on first failure only

If a pipeline fails repeatedly, you might not want a notification for every failed build. The `pipeline.started_failing` conditional sends a notification only when a pipeline transitions from a passing state to a failing state:

```yaml
notify:
  - slack:
      channels:
        - "buildkite-community#builds"
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
        - "buildkite-community#builds"
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
        - "buildkite-community#pr-failures"
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
            - "buildkite-community#qa"
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
            - "buildkite-community#builds"
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
        - "buildkite-community#builds"
      message: ":rotating_light: `${BUILDKITE_PIPELINE_SLUG}` started failing."
    if: build.branch == "main" && pipeline.started_failing
  - slack:
      channels:
        - "buildkite-community#oncall"
      message: "On-call <@U024BE7LH>, the `main` branch build failed."
    if: build.branch == "main" && build.state == "failed"
  - slack:
      channels:
        - "buildkite-community#pr-failures"
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

Step-level `notify` is different. To send a notification when a specific generated step fails, your generator must include `notify` on that step—it is not inherited from the initial `pipeline.yml`. Only Slack, GitHub checks, GitHub commit statuses, and Basecamp are available at step level. Email, PagerDuty, and webhook notifications are build-level only, so configure those in the initial `pipeline.yml`.

The following example shows a generated step that posts to Slack when it hard-fails:

```yaml
steps:
  - label: ":rocket: Deploy to production"
    command: "make deploy"
    notify:
      - slack:
          channels:
            - "buildkite-community#deploys"
          message: "Production deploy failed."
        if: step.outcome == "hard_failed"
```
{: codeblock-file="pipeline.yml"}

## Verify your notifications

To confirm the notifications work as expected:

1. Commit and push your `pipeline.yml` changes to a branch.
1. Open a pull request that intentionally fails the build (for example, by introducing a failing test).
1. Confirm that the configured Slack channels receive the expected messages, and that any user mentions resolve to the correct Slack users.
1. Push a fix to the same branch and confirm that recovery notifications (such as `pipeline.started_passing`) fire as expected.

If a notification does not arrive, check the following:

- The relevant Slack notification service is connected and includes the pipeline in its **Pipelines** filter.
- The Slack channel exists and the Buildkite app has been invited to it.
- The `if` expression matches the build state at the moment the notification event fires. See [Supported variables](/docs/pipelines/configure/conditionals#variable-and-syntax-reference-variables) for the full list of conditionals.

## Next steps

- Read more about the [`notify` attribute](/docs/pipelines/configure/notify) for the full reference of supported notification targets and conditional patterns.
- Configure additional channels with the [Slack notification service](/docs/pipelines/integrations/notifications/slack) or simplify per-pipeline configuration with the [Slack Workspace notification service](/docs/pipelines/integrations/notifications/slack-workspace).
- Combine Slack notifications with [build annotations](/docs/pipelines/configure/annotations) to share rich context, such as failing test output, alongside each Slack message.
