# The Buildkite CLI

The Buildkite CLI is a command-line interface (CLI) tool for interacting directly with the Buildkite platform itself. This tool provides command line/terminal access to work with a subset of the Buildkite platform's features, as you normally would through its web interface.

Using the Buildkite CLI, you can manage Buildkite agents and their configuration, work with a Buildkite pipeline's builds, control job execution, and manipulate its artifacts, along with several other actions.

## Installation

The Buildkite CLI can be installed on all major platforms. Learn more about how to install the tool on your platform in [Buildkite CLI installation](/docs/platform/cli/installation).

## Usage

Run `bk` to list commands, or append `--help` to a command for its arguments and flags. See the [Command-line reference](/docs/platform/cli/reference) for the full reference, including global flags.

### Create a pipeline from a repository

From a Git checkout, create a pipeline using the repository URL and name inferred from `origin`:

```bash
bk pipeline create
```

Interactive creation offers a project-aware local starter when no pipeline file exists. To select a starter explicitly without prompts:

```bash
bk pipeline create --no-input --template go
```

Use `--repository` and a positional name to override the inferred defaults. Use `--team SLUG=ACCESS_LEVEL` to assign team access. Non-admin users in organizations with Teams enabled must assign a team when creating a pipeline:

```bash
bk pipeline create "Example pipeline" \
  --repository git@github.com:example-org/example-repo.git \
  --team developers=build_and_read
```

`bk init` creates only a local starter without creating a remote pipeline. Both commands support `go`, `node`, `pipenv`, `ruby`, and `empty` templates and leave existing pipeline files unchanged. Agents need the corresponding runtime and package manager installed. The empty template contains `steps: []` and needs editing.

Review, commit, and push generated files before starting a build. Creating a pipeline does not publish local files. `bk pipeline create --dry-run` does not write files or create a pipeline or webhook, but still requires authentication and can perform API reads.

### Build and investigate failures

Create a build, then watch it using the build number returned by Buildkite Pipelines:

```bash
bk build create --pipeline my-org/my-pipeline --branch main
bk build watch 123 --pipeline my-org/my-pipeline --timeout 20m
```

The watch timeout stops monitoring, not the build. Use `--summary` for lightweight state checks:

```bash
bk build view my-org/my-pipeline/123 --summary --json
bk build list --pipeline my-org/my-pipeline --summary --json
```

To investigate a known build:

```bash
bk job list --pipeline my-org/my-pipeline --build 123 --state failed --json
bk job log JOB_UUID --no-timestamps
bk build annotations my-org/my-pipeline/123 --json
bk build step-uploads my-org/my-pipeline/123 --json
bk build compare my-org/my-pipeline/123 --baseline 120 --json
```

Build comparison matches final job attempts, not all retry attempts. Without `--baseline`, it searches up to 500 candidates for an earlier-created build on the same branch that is currently passed. Steps without keys use heuristic name matching. A comparison does not establish the cause of a failure or whether retrying is safe.

Use `bk build view my-org/my-pipeline/123 --recursive --json` to find hard-failed and timed-out command jobs across current trigger attempts. Inaccessible descendants produce partial output with `complete: false` and a nonzero exit status. The command links to logs without downloading them.

For [Test Engine](/docs/pipelines/configure/tests) data, `bk build failed-tests` includes tests with at least one failed execution, even if they passed on retry. `bk job flaky-tests JOB_UUID` lists failed tests currently labeled flaky for a failed job. Both require `read_builds` and `read_suites`. Empty results do not prove that no tests failed or that a failure was not flaky.

> 🚧 Retrying can repeat side effects
> `bk build retry-failed-jobs my-org/my-pipeline/123` queues retries in the existing build and requires confirmation unless you pass `--yes`. It does not check whether jobs are safe to rerun, including deployment jobs. The returned `retried_jobs_count` counts queued retries, not successful retries. Use `bk build watch` to follow the build.

### Test uncommitted changes

Use [Preflight](/docs/platform/cli/preflight) to snapshot local changes, push a temporary branch, and run a build without modifying your working tree:

```bash
bk preflight --pipeline my-org/my-pipeline --watch
```

Preflight is experimental. Unlike a normal build, it pushes local changes to `origin` and can cancel the build and delete its temporary branch on early exit. Review the Preflight guide before using it.

### Migrate repository secrets

`bk secret migrate github-actions` prepares and dispatches a reviewed, one-use workflow that transfers selected repository secret values directly from GitHub Actions to Buildkite secrets. Follow [Migrate GitHub Actions secrets](/docs/pipelines/migration/github-actions-secrets) for prerequisites, review steps, and completion checks.

## Configuration

Authenticate with `bk auth login` using OAuth, or supply an API access token. See [Buildkite CLI configuration](/docs/platform/cli/configuration) for headless login, credential storage, automation, and selecting organizations.
