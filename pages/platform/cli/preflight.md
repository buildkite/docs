# Preflight

Preflight runs your uncommitted changes against a Buildkite CI pipeline. It monitors failures as they happen, so your AI agent knows what to fix.

> 📘 Experimental command
> The preflight command is currently experimental. It is subject to change or removal without notice. To provide feedback, please contact Buildkite's Support team at [support@buildkite.com](mailto:support@buildkite.com).

## What preflight is

Preflight is a subcommand of the Buildkite CLI (`bk preflight`) that:

- Snapshots your uncommitted changes (staged changes, changes that are not staged, and new files) as a temporary commit on a new branch, without touching your working tree.
- Pushes that commit to a temporary branch and triggers a real build on your chosen Buildkite pipeline.
- Monitors failures in your terminal in real time as jobs complete. Exits if the build starts failing.
- Cleans up the temporary branch automatically when the build finishes.

Preflight is designed to be used with a coding agent, to run a build against your local working tree, and provide actionable failures for the agent to iterate against.

## Before you begin

You'll need:

- The [Buildkite CLI](/docs/platform/cli/installation) version 3.38.1 or later.
- A [configured API access token](/docs/platform/cli/configuration) with `read_builds`, `write_builds`, and `read_pipelines` scopes. To use with Test Engine the `read_suites` is required.
- Git commit and push access to the repository.

## Install or upgrade the Buildkite CLI

To check your current version:

```bash
bk version
```

Upgrade via Homebrew:

```bash
brew upgrade buildkite/buildkite/bk@3
```

Or with mise:

```bash
mise use -g github:buildkite/cli@latest
```

## Enable the preflight experiment

Preflight is currently behind an experiment flag. Enable it once with:

```bash
bk config set experiments preflight
```

Alternatively, set it per-invocation with an environment variable:

```bash
BUILDKITE_EXPERIMENTS=preflight bk preflight --pipeline my-org/my-pipeline
```

## Run a preflight build

```bash
bk preflight --pipeline my-org/my-pipeline --watch
```

The `--pipeline` flag accepts either `{org-slug}/{pipeline-slug}` or just `{pipeline-slug}` if your org is already set in your `bk` config.

```bash
# Watch for failures in real time
bk preflight --pipeline my-org/my-pipeline --watch

# Start the build and exit immediately (don't wait)
bk preflight --pipeline my-org/my-pipeline --no-watch

# Skip confirmation prompts
bk preflight --pipeline my-org/my-pipeline --watch --yes

# Use plain text output in non-interactive environments
bk preflight --pipeline my-org/my-pipeline --watch --text

# Use JSONL output when another tool needs structured events
bk preflight --pipeline my-org/my-pipeline --watch --json

# Wait for 30s for Test Engine results after build completion
bk preflight --pipeline my-org/my-pipeline --watch --await-test-results

# Don't cancel the build or remove the branch on exit
bk preflight --pipeline my-org/my-pipeline --watch --no-cleanup

# Wait for the build to run to completion, skip exit on failing.
bk preflight --pipeline my-org/my-pipeline --watch --exit-on build-terminal
```

In watch mode, by default Preflight will exit with code `10` when the build enters the failing state. Preflight exits with code `0` if all jobs pass, or `9` if failures are detected. See [exit codes](#exit-codes) for the full list.

## Test results

Preflight considers a test with one passed execution as passed and a test with only failed executions as failed in the test run summary. This is intended to exclude tests that passed on retry from being considered failures. Tests with only a pending, skipped, or unknown execution are excluded from being considered passed or failed.

Preflight reports up to 10 test failures in the TUI, and up to 100 test failures in JSON events.

## Customizing pipelines for preflight

Preflight sets the following environment variable when creating the build. This allows you to customize your pipeline for preflight builds.

- `PREFLIGHT` - Set to `true`
- `PREFLIGHT_SOURCE_COMMIT` - The HEAD commit when Preflight was run.
- `PREFLIGHT_SOURCE_BRANCH` - The current branch when Preflight was run.

These environment variables can be used with [Conditionals](/docs/pipelines/configure/conditionals) and [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) to customize Preflight builds to run a subset of a pipeline, or to modify it's behaviour.

To skip linting on builds triggered by Preflight:

```yaml
steps:
  - command: ./scripts/lint.sh
    label: lints
    if: build.env("PREFLIGHT") != "true"
```
{: codeblock-file="pipeline.yml"}

To run a test suite with `--fast-fail` when Preflight is in use:

```yaml
steps:
  - label: ":test_tube: Tests"
    command: |
      if [ "$PREFLIGHT" = "true" ]; then
        ./scripts/test.sh --fast-fail
      else
        ./scripts/test.sh
      fi
```
{: codeblock-file="pipeline.yml"}


## Capturing local changes

Preflight captures staged changes, changes that are not staged, and untracked files in your working directories into a temporary commit. It respects `.gitignore` and will not commit ignored files. Preflight will push snapshot commits to the remote `origin` configured in the repository, and will push changes to a branch prefixed with `bk/preflight/`.

## Exit codes

| Exit code | Meaning |
|-----------|---------|
| `0` | All jobs passed |
| `1` | Generic error |
| `9` | Build completed with failures |
| `10` | Build incomplete — failures already detected |
| `11` | Build incomplete — still running or blocked |
| `12` | Unknown build state |
| `130` | Aborted by user (Ctrl+C) |

## Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--pipeline`, `-p` | — | Pipeline slug (`{slug}` or `{org}/{slug}`) — required |
| `--watch` / `--no-watch` | — | Watch the build until completion |
| `--interval` | `2` | Polling interval in seconds |
| `--exit-on` | `build-failing` | Exit when a condition is met. Options: build-failing (default, exits when a build enters the failing state), build-terminal (exits when the build reaches a terminal state). |
| `--no-cleanup` | `false` | Keep the remote preflight branch after the build |
| `--await-test-results` | — | Wait for Test Engine summaries after build completion |
| `--text` | `false` | Use plain text output |
| `--json` | `false` | Emit one JSON object per event (JSONL) |
| `--yes`, `-y` | `false` | Skip confirmation prompts |
| `--no-input` | `false` | Disable all interactive prompts |
| `--quiet`, `-q` | `false` | Suppress progress output |
| `--debug` | `false` | Enable debug output for API calls |
