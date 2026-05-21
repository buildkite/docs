# Slack Workspace

The Slack Workspace notification service is the recommended way to send Buildkite Pipelines build notifications to [Slack](https://slack.com/). It requires a single, once-off configuration per Slack workspace, after which any pipeline can use the [`notify` attribute](/docs/pipelines/configure/notify#slack-channel-and-direct-messages) in its `pipeline.yml` to post messages to any channel or user in that workspace.

> 📘
> If you are still using one or more individual [Slack (legacy)](/docs/pipelines/integrations/notifications/slack) notification services—where each service is bound to a single channel or user—Buildkite recommends migrating to the Slack Workspace notification service for a simpler configuration experience and access to additional features such as [`pipeline.started_failing` and `pipeline.started_passing`](#customizing-notifications-notify-only-specific-failure-scenarios) conditionals.

## Connect Slack workspace

The Slack Workspace integration lets you receive notifications in your [Slack](https://slack.com/) workspace. This integration supports:

- [Pipelines build notifications](/docs/pipelines/integrations/notifications/slack-workspace)
- [Test Engine workflow Slack notification](/docs/pipelines/configure/tests/workflows/actions#send-slack-notification)

[Adding a **Slack Workspace** notification service](https://buildkite.com/organizations/-/services/slack_workspace/new) will authorize access for your entire Slack app for a given Slack workspace. You only need to set up this integration once per Slack workspace, after which, you can then configure notifications to be sent to any Slack channels or users.

> 📘
> Setting up a Workspace requires Buildkite organization admin access.

1. Select **Settings** in the global navigation and select **Notification Services** in the left sidebar.

1. Select the **Add** button on **Slack Workspace**.

    <%= image "buildkite-add-slack-workspace.png", width: 1458/2, height: 142/2, alt: "Screenshot of the 'Add' button for adding a Slack workspace service to Buildkite" %>

1. Select the **Add to Slack** button:

    <%= image "buildkite-add-to-slack-workspace.png", width: 1458/2, height: 358/2, alt: "Screenshot of 'Add Slack workspace service' screen on Buildkite. It shows an 'Add to Slack workspace' button" %>

    This action redirects you to Slack.

1. Log in to Slack and grant Buildkite permission to post across your workspace.

1. After granting access, you can then configure [Pipeline build notifications](/docs/pipelines/integrations/notifications/slack-workspace) and [Test Engine workflow Slack notifications](/docs/pipelines/configure/tests/workflows/actions#send-slack-notification).

## Configuring notifications

Once the Slack workspace is connected, use the `notify` attribute in the YAML syntax of your pipelines to [configure specific notifications](/docs/pipelines/configure/notify#slack-channel-and-direct-messages):

```yaml
notify:
  - slack:
      channels:
        - "buildkite-community#general"
        - "buildkite-community#announcements"
```
{: codeblock-file="pipeline.yml"}

### Mentions in build notifications

Mentions occur when there's a corresponding Slack account using one of the emails connected to the Buildkite account that triggered a build.

Provide the Slack user ID, which you can access from **User > More options > Copy member ID**.

```yaml
notify:
  - slack: "U123ABC456"
```
{: codeblock-file="pipeline.yml"}

### Notify in private channels

You can notify individuals in private channels by inviting the Buildkite Builds Slack App into the channel with `/invite @Buildkite Builds`.

Build-level notifications:

```yaml
notify:
  # Notify private channel
  - slack: "buildkite-community#private-channel"
```
{: codeblock-file="pipeline.yml"}

You can also use a channel ID (prefixed with `C`) to target a private channel. Channel IDs are more stable than names as they remain valid if the channel is renamed. See [Notify using a Slack channel or conversation ID](/docs/pipelines/configure/notify#slack-channel-and-direct-messages-notify-using-a-slack-channel-or-conversation-id) for details.

## Conditional notifications

Use the `notify` YAML attribute in your `pipeline.yml` file to configure conditional notifications.

See the [Slack channel message](/docs/pipelines/configure/notify#slack-channel-and-direct-messages) section of the Notifications guide for the configuration information.

### Conditional notifications with pipeline states

You can control conditional notifications using `pipeline.started_passing` and `pipeline.started_failing` in the `if` attribute of the `notify` key of your `pipeline.yml`. With the previous Slack integration this was done in the user interface.

See [Conditional Slack notifications](/docs/pipelines/configure/notify#slack-channel-and-direct-messages-conditional-slack-notifications) for more examples.

## Customizing notifications

The following sections are a collection of how-tos for customizing Slack notifications in Buildkite Pipelines. Each section addresses a specific use case independently. Pick the ones that match your needs and combine the relevant `notify` attributes into your own `pipeline.yml`. The use cases are not designed to be applied all at once.

The how-tos cover:

- [Sending a Slack message on build failure](#customizing-notifications-send-a-slack-message-on-build-failure).
- Mentioning the [pull request creator](#customizing-notifications-mention-the-pull-request-creator) or the [user who unblocked a build](#customizing-notifications-mention-the-user-who-unblocked-a-build).
- [Restricting notifications to specific failure scenarios](#customizing-notifications-notify-only-specific-failure-scenarios) using conditionals.
- [Combining multiple notification rules](#customizing-notifications-combine-multiple-notification-rules) to route different events to different channels.
- [Posting notifications from dynamically generated steps](#customizing-notifications-notifications-in-dynamic-pipelines).
- [Guaranteeing that a final notification step runs](#customizing-notifications-guarantee-a-final-slack-notification-runs) regardless of build outcome.

For the full reference of `notify` attributes and conditionals, see [Triggering notifications](/docs/pipelines/configure/notify) and [Conditionals](/docs/pipelines/configure/conditionals).

### Send a Slack message on build failure

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

This sends a notification to the `#builds` channel in the `buildkite-community` workspace whenever a build finishes in the `failed` state. Replace the workspace and channel name with values that match your own Slack workspace.

> 🚧
> When using only a channel name, you must specify this name in quotes. Otherwise, the `#` will cause the channel name to be treated as a YAML comment.

### Mention the pull request creator

To draw the attention of the user who opened the pull request, include a Slack user mention in a custom message. Slack mentions use the `<@user-id>` syntax, where `user-id` is the Slack user ID of the person to mention. See the [Slack documentation on mentioning users](https://api.slack.com/reference/surfaces/formatting#mentioning-users) for how to find a particular user's ID.

The following example posts a custom message to `#builds` and mentions a specific Slack user when the build fails:

```yaml
notify:
  - slack:
      channels:
        - "buildkite-community#builds"
      message: "Build failed for `${BUILDKITE_BRANCH}` <@U018FG***>, please take a look."
    if: build.state == "failed"
```
{: codeblock-file="pipeline.yml"}

> 🚧 Build creator environment variable
> You cannot substitute a Slack user mention with the build creator environment variable value directly. To dynamically mention the user who created the build, maintain a mapping from Buildkite user identifiers (such as `build.creator.email` or `build.creator.id`) to Slack user IDs in your build script, then use [annotations](/docs/pipelines/configure/annotations) or a [dynamic pipeline](/docs/pipelines/configure/dynamic-pipelines) step to upload a `notify` block that includes the resolved Slack user ID.

For an overview of available build creator and author variables, see [Supported variables](/docs/pipelines/configure/conditionals#variable-and-syntax-reference-variables).

#### Dynamically mention the build creator

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

The example `notify-creator.sh` script below reads `BUILDKITE_BUILD_CREATOR_EMAIL` from the environment, calls Slack's [`users.lookupByEmail`](https://api.slack.com/methods/users.lookupByEmail) API to resolve the email to a Slack user ID, and emits a YAML pipeline fragment containing a `notify` attribute with the `<@user-id>` mention. This avoids maintaining a separate email-to-user-ID map.

The script needs a Slack bot token with the `users:read.email` scope. Store the token as a [secret](/docs/pipelines/security/secrets) and expose it to the script as the `SLACK_BOT_TOKEN` environment variable:

```bash
#!/usr/bin/env bash
set -euo pipefail

email="${BUILDKITE_BUILD_CREATOR_EMAIL:-}"
token="${SLACK_BOT_TOKEN:-}"

if [[ -z "$email" || -z "$token" ]]; then
  echo "Email or Slack bot token is not set; skipping creator mention." >&2
  exit 0
fi

slack_user_id=$(curl --silent --get \
  --data-urlencode "email=$email" \
  --header "Authorization: Bearer $token" \
  https://slack.com/api/users.lookupByEmail \
  | jq -r 'select(.ok) | .user.id')

if [[ -z "$slack_user_id" ]]; then
  echo "No Slack user found for $email; skipping creator mention." >&2
  exit 0
fi

cat <<EOF
notify:
  - slack:
      channels:
        - "buildkite-community#builds"
      message: "Build #\${BUILDKITE_BUILD_NUMBER} failed. <@$slack_user_id>, please take a look."
    if: build.state == "failed"
EOF
```
{: codeblock-file=".buildkite/notify-creator.sh"}

The `\${BUILDKITE_BUILD_NUMBER}` reference uses a backslash to escape the variable so the shell does not interpolate it at script run time. The agent interpolates it when it processes the uploaded pipeline. The `$slack_user_id` reference is interpolated by the shell so the resolved Slack user ID is baked into the uploaded YAML.

If provisioning a Slack bot token is not viable, replace the `curl` call with a `jq` lookup against a JSON map file (for example, `.buildkite/slack-user-map.json`) checked into the repository.

For more on generating pipeline configuration at runtime, see [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines).

#### Send a Slack DM to the user who triggered the build

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

### Mention the user who unblocked a build

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
              - "buildkite-community#builds"
            message: '$$BUILDKITE_UNBLOCKER has unblocked the pipeline.'
      EOF

  - label: "Build"
    command: "make build"
```
{: codeblock-file="pipeline.yml"}

The same pattern works for the related `BUILDKITE_UNBLOCKER_EMAIL`, `BUILDKITE_UNBLOCKER_ID`, and `BUILDKITE_UNBLOCKER_TEAMS` variables. To mention the unblocker as a Slack user instead of including their name, map `BUILDKITE_UNBLOCKER_EMAIL` to a Slack user ID using the same approach described in [Dynamically mention the build creator](#customizing-notifications-mention-the-pull-request-creator-dynamically-mention-the-build-creator).

### Notify only specific failure scenarios

By default, restricting notifications to `build.state == "failed"` only sends one notification per failed build. The following sections show how to refine that behavior for common scenarios. For the full list of supported conditionals (including patterns such as "all failures and first successful pass"), see [Conditional Slack notifications](/docs/pipelines/configure/notify#slack-channel-and-direct-messages-conditional-slack-notifications) in the `notify` reference.

#### Notify on first failure only

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

> 📘 Limiting by consecutive failures
> Buildkite Pipelines supports limiting Slack notifications to the first failure (`pipeline.started_failing`) and to the first pass after a failure (`pipeline.started_passing`). There is no built-in conditional for triggering a notification only after _N_ consecutive failed or passed builds.
>
> If you have configured automatic [job retries](/docs/pipelines/configure/retry), one workaround is to use a [`post-command` or `pre-exit` hook](/docs/agent/hooks) to perform a dynamic `buildkite-agent pipeline upload` of a command step that posts a Slack notification once `BUILDKITE_RETRY_COUNT` reaches a threshold. This approach checks consecutive failures at the job level rather than the build level.

#### Notify when a previously failing build passes

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

#### Notify on pull request branches only

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

#### Notify when a specific step fails

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
> Build-state conditionals (`build.state`) cannot be used on step-level notifications, since a step cannot know the state of the entire build.

#### Notify on soft-failed steps

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

### Combine multiple notification rules

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
      message: "On-call <@U045GK***>, the `main` branch build failed."
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

### Notifications in dynamic pipelines

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
            - "buildkite-community#deploys"
          message: "Production deploy failed."
        if: step.outcome == "hard_failed"
```
{: codeblock-file="pipeline.yml"}

#### Post a final Slack summary after dynamically generated steps

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
            - "buildkite-community#builds"
          message: "Build #${BUILDKITE_BUILD_NUMBER} validation summary posted."
        if: step.outcome == "passed" || step.outcome == "hard_failed"
```
{: codeblock-file="pipeline.yml"}

Each `Part N` step can upload as many steps as needed. Because the `wait` and the validation step are declared in the parent `pipeline.yml`, the validation step only runs after every uploaded step has finished. Keep the `wait` and the final summary step at the end of the parent pipeline so the summary always runs after everything else, regardless of how many chunked upload steps precede them.

### Guarantee a final Slack notification runs

If an earlier step hard-fails, Buildkite Pipelines does not run subsequent steps in the build, so a trailing Slack notification step never executes. The following patterns ensure a final notification always runs and can report on the overall outcome.

#### Use a wait step that continues on failure

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
            - "buildkite-community#builds"
          message: "Build #${BUILDKITE_BUILD_NUMBER} finished. Check the final report step for per-step outcomes."
```
{: codeblock-file="pipeline.yml"}

If you would prefer subsequent steps to keep running without `wait` and `continue_on_failure`, mark the earlier steps with [`soft_fail`](/docs/pipelines/configure/step-types/command-step#soft-fail-attributes). Soft-failed steps do not stop the build, so a downstream notification step runs normally.

#### Send notifications from a job hook

For notifications that should fire after every job, not just at the end of the build, use a [`post-command` or `pre-exit` agent hook](/docs/agent/hooks). The `post-command` hook runs immediately after each step's command, and `pre-exit` runs just before the job ends. Both have access to the job's exit status and the `BUILDKITE_*` environment variables, so a shell script can call the Slack API directly without adding any steps to `pipeline.yml`. This approach is best when the same notification logic should apply across many pipelines or jobs.

#### Wrap pipeline upload to inject a final step

To enforce a final Slack notification across every pipeline in your organization without per-pipeline configuration, wrap `buildkite-agent pipeline upload` with a script that reads the YAML being uploaded, appends a `wait` step with `continue_on_failure: true` followed by the notification step, then forwards the modified YAML to the real `buildkite-agent pipeline upload`. Invoke the wrapper from an agent hook so it intercepts every upload automatically.

> 🚧 Wrapper script considerations
> A wrapper around `buildkite-agent pipeline upload` is powerful but adds operational complexity. The wrapper must handle YAML parsing, error cases, and pipelines that already include their own final notification step, and it can be difficult to debug when something goes wrong. Reserve this approach for environments where consistent end-of-build behavior is mandatory and per-pipeline configuration is not viable.

### Verify your notifications

After applying any of the how-tos above, confirm the resulting notifications behave as expected:

1. Commit and push your `pipeline.yml` changes to a branch.
1. Trigger a build that exercises the scenario you configured. For failure-related conditionals, this might mean introducing a failing test; for unblocker mentions, this means unblocking a block step; for `pipeline.started_passing`, this means pushing a fix after a previous failure.
1. Confirm that the configured Slack channels receive the expected messages, and that any user mentions resolve to the correct Slack users.

If a notification does not arrive, check the following:

- The Slack workspace is connected and the relevant pipeline is included in the workspace's notification settings.
- The Slack channel exists and the **Buildkite Builds** Slack app has been invited to it.
- The `if` expression matches the build state at the moment the notification event fires. See [Supported variables](/docs/pipelines/configure/conditionals#variable-and-syntax-reference-variables) for the full list of conditionals.

## Privacy policy

For details on how Buildkite handles your information, please see Buildkite's [Privacy Policy](https://buildkite.com/about/legal/privacy-policy/).

## Next steps

- Read more about the [`notify` attribute](/docs/pipelines/configure/notify) for the full reference of supported notification targets and conditional patterns.
- Combine Slack notifications with [build annotations](/docs/pipelines/configure/annotations) to share rich context, such as failing test output, alongside each Slack message.
