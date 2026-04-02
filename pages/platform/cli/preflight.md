# Preflight

Preflight runs your uncommitted changes against a real Buildkite CI pipeline — before you push. It streams failures back to your terminal as they happen, so you know exactly what to fix without leaving your editor or waiting for a pipeline notification.

## What Preflight is

Preflight is a subcommand of the Buildkite CLI (`bk preflight`) that:

- **Snapshots** your uncommitted changes (staged, unstaged, and untracked files) as a temporary commit — without touching your working tree.
- **Pushes** that commit to a temporary branch and triggers a real build on your chosen Buildkite pipeline.
- **Streams failures** back to your terminal in real time as jobs complete. Only failures are surfaced — passing jobs are silent.
- **Cleans up** the temporary branch automatically when the build finishes.

Your working tree is never disrupted. You can keep editing while the build runs.

## What Preflight is not

Preflight is not a local test runner. It does not:

- Run your test suite on your machine.
- Run your linter or formatter locally.
- Replace or act as a pre-commit git hook.
- Require any local language runtimes or dependencies to be installed.

Everything runs on your existing Buildkite infrastructure — the same agents, the same environment, the same pipeline steps. Preflight just gets your changes there faster.

## Before you begin

You'll need:

- The [Buildkite CLI](/docs/platform/cli/installation) version 3.34.0 or later.
- A [configured API access token](/docs/platform/cli/configuration) with `read_builds`, `write_builds`, and `read_pipelines` scopes.
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

## Enable the Preflight experiment

Preflight is currently behind an experiment flag. Enable it once with:

```bash
bk config set experiments preflight
```

Alternatively, set it per-invocation with an environment variable:

```bash
BUILDKITE_EXPERIMENTS=preflight bk preflight --pipeline my-org/my-pipeline
```

## Run a Preflight build

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
```

Preflight exits with code `0` if all jobs pass, or `9` if failures are detected. See [exit codes](#exit-codes) for the full list.

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
| `--no-cleanup` | `false` | Keep the remote preflight branch after the build |
| `--yes`, `-y` | `false` | Skip confirmation prompts |
| `--no-input` | `false` | Disable all interactive prompts |
| `--quiet`, `-q` | `false` | Suppress progress output |
| `--debug` | `false` | Enable debug output for API calls |
