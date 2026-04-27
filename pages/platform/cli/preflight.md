# Preflight

> 🚧 Experimental feature
> The Preflight feature is currently in experimental stage. Its behavior is subject to change without notice. To provide feedback, please contact Buildkite's Support team at [support@buildkite.com](mailto:support@buildkite.com).

Preflight is a subcommand of the Buildkite CLI (`bk preflight`) that runs your uncommitted local changes against Buildkite Pipelines and monitors failures as they happen. It is designed for use with a coding agent, providing a real build against your working tree and surfacing actionable failures for the agent to iterate against.

The Preflight (`bk preflight`) command:

- Snapshots your uncommitted changes (staged, unstaged, and untracked files) as a temporary commit on a new branch, without touching your working tree. Files matched by `.gitignore` are excluded.
- Pushes that commit to a branch prefixed with `bk/preflight/` on the repository's `origin` remote, then triggers a build on your chosen Buildkite pipeline.
- Streams failures to your terminal in real time and exits as soon as the build starts failing.
- Cleans up the temporary branch automatically when the build finishes.

## Before you begin

You'll need:

- The [Buildkite CLI](/docs/platform/cli/installation) version 3.38.1 or later.
- A [configured API access token](/docs/platform/cli/configuration) with the `read_builds`, `write_builds`, and `read_pipelines` scopes. The `read_suites` scope is also required to use Preflight with Buildkite Test Engine.
- Git commit and push access to the repository.

## Install or upgrade the Buildkite CLI

To check your current Buildkite CLI version, run:

```bash
bk version
```

To upgrade using Homebrew:

```bash
brew upgrade buildkite/buildkite/bk@3
```

To upgrade using mise:

```bash
mise use -g github:buildkite/cli@latest
```

## Enable the preflight experiment

Preflight is currently behind an experiment flag. To enable it globally, run:

```bash
bk config set experiments preflight
```

Alternatively, enable Preflight per invocation with an environment variable:

```bash
BUILDKITE_EXPERIMENTS=preflight bk preflight --pipeline my-org/my-pipeline
```

## Run a Preflight build

To run a build with Preflight enabled:

```bash
bk preflight --pipeline my-org/my-pipeline --watch
```

The `--pipeline` flag accepts either `{org-slug}/{pipeline-slug}` or just `{pipeline-slug}` if your Buildkite organization is already set in your `bk` config.

In `--watch` mode, Preflight exits with code `0` if all jobs pass, `10` when the build first enters the failing state (the default), or `9` if the build completes with failures. See [exit codes](#exit-codes) for the full list.

The following examples show common variations:

```bash
# Start the build and exit immediately (don't wait)
bk preflight --pipeline my-org/my-pipeline --no-watch

# Skip confirmation prompts
bk preflight --pipeline my-org/my-pipeline --watch --yes

# Use plain text output in non-interactive environments
bk preflight --pipeline my-org/my-pipeline --watch --text

# Use JSONL output when another tool needs structured events
bk preflight --pipeline my-org/my-pipeline --watch --json

# Wait up to 30s for Test Engine results after build completion
bk preflight --pipeline my-org/my-pipeline --watch --await-test-results

# Don't cancel the build or remove the branch on exit
bk preflight --pipeline my-org/my-pipeline --watch --no-cleanup

# Wait for the build to reach a terminal state instead of exiting on first failure
bk preflight --pipeline my-org/my-pipeline --watch --exit-on build-terminal
```

## Build summary

On exit, Preflight prints a summary of the jobs that failed. When integrated with Buildkite [Test Engine](/docs/test-engine), the summary also includes test results. This integration requires the `read_suites` scope on your [API access token](/docs/platform/cli/configuration).

A test with at least one passed execution is treated as passed, and a test with only failed executions is treated as failed. Tests that pass on retry are not counted as failures. Tests with only pending, skipped, or unknown executions are excluded from the summary.

Preflight reports up to 10 test failures in the terminal output, and up to 100 test failures in JSON events.

## Customizing pipelines for Preflight

Preflight sets the following environment variables on the build, so you can customize pipeline behavior for preflight runs:

- `PREFLIGHT`: Set to `true`.
- `PREFLIGHT_SOURCE_COMMIT`: The HEAD commit when Preflight was run.
- `PREFLIGHT_SOURCE_BRANCH`: The current branch when Preflight was run.

Use these with [conditionals](/docs/pipelines/configure/conditionals) and [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) to run a subset of a pipeline or otherwise modify its behavior under Preflight.

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
| `--exit-on` | `build-failing` | Condition that triggers exit. `build-failing` exits when the build enters the failing state; `build-terminal` exits when the build reaches a terminal state. |
| `--no-cleanup` | `false` | Keep the remote preflight branch after the build |
| `--await-test-results` | — | Wait for Test Engine summaries after build completion |
| `--text` | `false` | Use plain text output |
| `--json` | `false` | Emit one JSON object per event (JSONL) |
| `--yes`, `-y` | `false` | Skip confirmation prompts |
| `--no-input` | `false` | Disable all interactive prompts |
| `--quiet`, `-q` | `false` | Suppress progress output |
| `--debug` | `false` | Enable debug output for API calls |
