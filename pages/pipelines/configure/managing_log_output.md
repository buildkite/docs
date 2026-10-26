---
description: "Organize Buildkite Pipelines logs, find failures, save complete command output, reduce noisy logs, and configure redaction and private log archives."
---

# Managing log output

Organize Buildkite Pipelines logs to find failures faster. Save complete command output while filtering or truncating noisy logs.

- [Organize output](#grouping-log-output) into collapsible groups.
- [Manage large logs](#log-output-limits) without losing the original command output.
- [Protect sensitive values](#redacted-environment-variables) with log redaction.

## Grouping log output

Print a grouping marker at the start of a line to create a log heading. Output belongs to that group until the next heading.

Marker | Behavior
------ | --------
`---` | Starts a collapsed group
`+++` | Starts an expanded group
`~~~` | Starts a collapsed, de-emphasized group
`^^^ +++` | Expands the previous group, optionally updating its title
{: class="two-column"}

### Collapsed groups

Use `---` for output that readers can expand when needed:

```bash
echo "--- A section of the build"
```

### Expanded groups

Use `+++` for output that should be open by default:

```bash
echo "+++ A section of the build"
```

If no group is explicitly expanded (`+++`), the last regular collapsed group (`---`) opens instead. To prevent that fallback, add this empty-looking expanded group at the end of your output:

```bash
echo -e "+++ \032"
# The \032 escape emits ASCII SUB (0x1A), not a space
```

### De-emphasized groups

Use `~~~` for less important output. These groups start collapsed and use non-bold titles:

```bash
echo "~~~ An unimportant section of the build"
```

> 📘 Availability
> The controls in this section are available to organizations where de-emphasized job log groups are enabled in the new build experience.

On the [Buildkite Pipelines build page](/docs/pipelines/build-page#core-actions-viewing-step-details), consecutive de-emphasized groups are folded into inline expander rows. Folding hides the group headings as well as their output. Expanding a group opens its output without revealing other folded groups.

- Select an expander row to reveal those groups temporarily.
- Select **Show system groups** in the log toolbar to reveal all folded groups. Its tooltip shows the hidden group count. Select **Hide system groups** to fold them again.
- Select **Configure view** > **Show all system groups** to keep de-emphasized groups visible on future visits. This menu also controls the log theme and timestamps.
- Select **Expand groups** or **Collapse groups** to open or close all visible groups without revealing folded groups.

The default group that reports the running script, commands, or [command hooks](/docs/agent/hooks#job-lifecycle-hooks), such as **Running commands**, stays visible. Groups explicitly expanded with `^^^ +++` also stay visible. While a job runs, its active group stays visible until the job finishes.

Opening a link to a line inside a folded group reveals that group temporarily. Other groups remain folded. These actions don't change your saved **Show all system groups** preference.

### Advanced grouping techniques

Use these techniques to highlight failures and separate stages in long logs.

#### Opening previous groups

Use `^^^ +++` to open the previous group, for example, when a command fails. Add a title after the marker to rename the group:

```bash
echo "--- Bundling"
if bundle; then
  echo "Bundling complete"
else
  status=$?
  echo "^^^ +++ Bundling failed"
  exit "$status"
fi
```

The guarded command allows failure handling even with Bash's `-e` option enabled. Save the original exit status before printing messages, then return it so the job still fails. See [Capturing exit status](/docs/pipelines/configure/writing-build-scripts#capturing-exit-status) for more examples.

If the previous group is de-emphasized (`~~~`), expanding it with `^^^ +++` keeps it visible even when other de-emphasized groups are hidden.

#### Creating section boundaries

Combine group types to mark stages. Only print completion headings when the corresponding command succeeds:

```bash
echo "--- Starting deployment"
if ./scripts/deployment.sh; then
  echo "~~~ Deployment complete"
else
  status=$?
  echo "^^^ +++ Deployment failed"
  exit "$status"
fi

echo "--- Running tests"
if ./scripts/tests.sh; then
  echo "~~~ Tests succeeded"
else
  status=$?
  echo "^^^ +++ Tests failed"
  exit "$status"
fi
```

Use ANSI escape codes (terminal control codes) for colors and emoji shortcode syntax for group titles:

```bash
echo -e "--- Running \033[33mspecs\033[0m \:cow\:\:bell\:"
```

<%= image "collapsing_example.png", width: 522/2, height: 254/2, alt: "Screenshot of colored, emoji build output" %>

> 🚧 Emoji shortcode
> Buildkite Pipelines converts `:emoji_name:` shortcode syntax into emojis only in step labels and group header lines (text following `---`, `+++`, `~~~`, or `^^^ +++`). Use the actual Unicode character in regular command output.

```yaml
steps:
  - label: "\:rocket\: Deploy"
    command: |
      echo "--- \:rocket\: Running pre-flight checks"
      echo "Checking environment..."

      echo "+++ \:rocket\: Running deploy script"
      if ./deploy.sh; then
        echo "Deployment complete"
      else
        status=$?
        echo "^^^ +++"
        echo "🚀 Deploy failed. Check the logs above."
        exit "$$status"
      fi
```

The failure message uses the literal 🚀 character because a shortcode there would print as plain text. In pipeline YAML, `$$status` [defers variable expansion until the step runs](/docs/agent/cli/reference/pipeline#environment-variable-substitution-escaping-the-dollars-character).

## Searching log output

To find text on the Buildkite Pipelines build page:

1. Select **Search logs** above the build log.
1. Enter a search term.
1. Select **Previous** or **Next** to move between matches.

Select **Match case sensitivity** (**Aa**) to require an exact-case match.

Search includes text inside folded de-emphasized groups. Matching groups appear for the duration of the search. Closing search folds them again unless they were already visible.

## ANSI timestamps

Buildkite agent v4 always emits ANSI timestamp codes in job logs. The v3 options to disable them or use plain-text timestamps were removed. See [Changes to job logs](/docs/agent/v3-v4-upgrade-guide#breaking-changes-in-v4-changes-to-job-logs). To change timestamp visibility on the build page, use **Configure view**.

## Log output limits

Buildkite Pipelines renders only the last two MB of output on the build page. This display limit is separate from the default 1,024 MiB per-job log size limit. Pipelines cancels jobs whose logs exceed the per-job limit. See [Pipelines limits](/docs/platform/limits#pipelines-limits) for quotas and how to request an increase.

To retrieve an existing job's stored output, [download the raw log using the REST API](/docs/apis/rest-api/jobs#get-a-jobs-log-output). This cannot recover output filtered out before upload. For future builds, reduce unnecessary tool output or save the original output before filtering or truncating it.

## Storing the original log

Use `tee` to save command output to a file while also sending it to the job log. Merge standard error into standard output with `2>&1` so the file includes both streams:

```bash
#!/bin/bash

set -euo pipefail

your_build_command 2>&1 | tee build.log
```
{: codeblock-file="build.sh"}

The `pipefail` option makes the Bash pipeline fail if any command fails, including the build command or `tee`. The `-e` option then stops the script on that failure. Without `pipefail`, a successful final command can hide an earlier failure.

To upload `build.log` as a [build artifact](/docs/pipelines/configure/artifacts#upload-artifacts-with-a-command-step), add `artifact_paths` to the [command step](/docs/pipelines/configure/step-types/command-step) that runs the script:

```yaml
steps:
  - command: bash ./build.sh
    artifact_paths: "build.log"
```
{: codeblock-file="pipeline.yml"}

After the command step finishes, the agent uploads `build.log`. Download it from the **Artifacts** tab on the build page.

<%= image "large_build_log.png", width: 1022/2, height: 482/2, alt: "Screenshot of build log available in the Artifacts tab" %>

> 🚧 Review raw logs before uploading
> `tee` saves output before job-log redaction. Do not assume that saved logs or uploaded artifacts are redacted. Avoid printing secrets, and review files before uploading or sharing them.

## Filtering with grep

Use `grep` to show only matching lines in the Buildkite Pipelines job log while saving both output streams in `build.log`:

```bash
#!/bin/bash

set -euo pipefail

your_build_command 2>&1 | tee build.log | (
  status=0
  grep 'some pattern' || status=$?
  if [[ "$status" -eq 1 ]]; then
    exit 0
  fi
  exit "$status"
)
```

`grep` returns `1` when no lines match. The parenthesized filter treats that result as success but preserves actual `grep` errors. With `pipefail`, failures from the build command or `tee` still fail the script, even if no lines match.

## Truncating with tail

Use `tail` to send only the last 100,000 bytes of command output to the Buildkite Pipelines job log while saving the full output in `build.log`:

```bash
#!/bin/bash

set -euo pipefail

your_build_command 2>&1 | tee build.log | tail -c 100000
```

This retains the end of the output, not a live rolling view. `tail` waits for the command's output to end before printing the retained bytes. Other job output still counts toward the per-job log limit.

## Improving Xcode logs with xcpretty

[xcpretty](https://github.com/supermarin/xcpretty) reduces, formats, and color-codes [Xcode](https://developer.apple.com/xcode) build output. After installing it, pipe `xcodebuild` output through it. Replace `MyApp` with your scheme name:

```bash
#!/bin/bash

set -euo pipefail

xcodebuild -scheme MyApp build 2>&1 | tee build.log | xcpretty -c
```

Keep `pipefail` enabled so an `xcodebuild` failure fails the script even when xcpretty succeeds.

<%= image "xcpretty.png", width: 1640/2, height: 790/2, alt: "Screenshot of xcpretty output" %>

## Encryption and security

Buildkite-managed artifacts are stored in Amazon S3 with encryption at rest. See [Artifact storage, encryption, and retention](/docs/pipelines/configure/artifacts#storage-providers-encryption-and-retention) for key management and self-managed storage options.

Your organization controls the credentials and systems builds can access. Agent infrastructure responsibilities depend on whether agents are hosted or self-hosted. Review the [shared responsibility model](/docs/platform/security#shared-responsibility) for your setup.

## Redacted environment variables

The Buildkite agent redacts matching [environment variable](/docs/pipelines/configure/environment-variables) values before uploading job logs. Variable names must match a configured pattern.

Values shorter than six bytes are not redacted.

The default environment variable name patterns are:

<%= render_markdown partial: 'pipelines/configure/default_redacted_vars' %>

With these defaults, if you have an environment variable `MY_SECRET="topsecret"` and run a command that outputs `This is topsecret info`, the log output will be `This is [REDACTED] info`.

Setting [`redacted-vars`](/docs/agent/self-hosted/configure#redacted-vars) replaces the default patterns. To add `FOO` while keeping the defaults, include every default pattern you want to retain:

```sh
redacted-vars="*_PASSWORD, *_SECRET, *_TOKEN, *_PRIVATE_KEY, *_SSH_KEY, *_ACCESS_KEY, *_SECRET_KEY, *_CONNECTION_STRING, *_API_KEY, FOO"
```

Defaults differ between agent versions. Listing your patterns explicitly keeps the configuration consistent across your fleet.

<a id="setting-environment-variables"></a>

> 🚧 Secrets in pipeline definitions
> Log redaction does not hide secret values in uploaded pipeline definitions. Do not store secrets directly in `pipeline.yml` or substitute their values during upload. Follow the [guidance for referencing secrets in pipeline YAML](/docs/pipelines/security/secrets/risk-considerations#referencing-secrets-in-your-pipeline-yaml) to avoid exposing them outside the job log.

<a id="private-build-log-archive-storage"></a>

## Job log archive storage

By default, job logs are stored in encrypted form in Buildkite-managed Amazon S3 buckets. Customers on the [Enterprise](https://buildkite.com/pricing) plan can instead store archived job logs in their own private Amazon S3 bucket.

For setup instructions, including bucket requirements and the required bucket policy, see [Job log archiving](/docs/pipelines/governance/job-log-archiving).

## Next steps

- **Summarize failures**: [Create a build annotation](/docs/pipelines/configure/annotations#create-a-build-annotation-from-within-a-builds-job) to show key results without searching the log.
- **Open diagnostics directly**: [Add clickable links to log output](/docs/pipelines/configure/links-and-images-in-log-output#links) for reports and other saved artifacts.
