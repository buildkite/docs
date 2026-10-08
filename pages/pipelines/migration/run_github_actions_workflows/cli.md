---
description: "Use the buildkite-gha CLI to validate GitHub Actions workflows, compile pipelines, migrate secrets, and upload workflows from a custom importer."
---

# Use the buildkite-gha CLI

The [GitHub Actions Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/github-actions-buildkite-plugin/) is the easiest way to run `buildkite-gha`. Use the CLI directly when you need to validate a workflow, inspect generated output, or build a custom importer.

| Command | Use it to |
| --- | --- |
| `validate` | Check one workflow and, optionally, production policy. |
| `validate-batch` | Check a large workflow corpus. |
| `compile` | Render pipeline YAML or compiler IR without uploading it. |
| `upload` | Upload workflows from a custom importer. |
| `migrate-secrets` | Copy GitHub Actions repository secrets into Buildkite secrets. |
| `help <command>` | Print the usage and description of one command. Run `buildkite-gha help` without a command, or `buildkite-gha --help`, to list all commands. |
| `--version` | Print the installed `buildkite-gha` version. |
{: class="responsive-table"}

The `run-job` command and the `upload --stage-digest` form are internal commands that generated steps run. Don't invoke them directly.

## Before you begin

Install `buildkite-gha` with `mise` 2026.5.12 or newer:

```bash
mise use -g --minimum-release-age 0s github:buildkite/buildkite-gha
```

The override avoids the default 24-hour release delay in `mise`. Without it, `mise` may select an older release that has no artifact for your platform.

Append `@<version>` to install an exact release. If a custom importer creates jobs for the other supported platform, it must download and verify that platform's distribution from the same release.

Jobs with JavaScript actions need `mise`. The runtime checks `BUILDKITE_GHA_MISE`, then `PATH`, then downloads a verified managed copy. Shell-only, native-adapter, and Docker-only jobs don't need it.

When a managed cache is configured, the runtime installs Node there rather than reusing system-wide `mise` installations. The install directory remains pinned even when an agent's `mise` wrapper overrides `MISE_DATA_DIR`.

Managed Node binaries require glibc 2.28 or newer. The Go CLI has no glibc requirement.

## Validate a workflow

Validate syntax, the static graph, and every declared trigger without an event:

```bash
buildkite-gha validate .github/workflows/ci.yml
```

This event-independent check validates syntax, triggers, and the static graph. It accepts valid push and pull request path filters because upload can evaluate them later with linked-webhook data and a verified local Git diff.

It doesn't:

- resolve actions
- evaluate event payload expressions
- claim that production policy would admit the workflow

Malformed filters, unsupported filter combinations, and unsupported pull request activity types still fail. See [Workflow names and triggers](/docs/pipelines/migration/run-github-actions-workflows/compatibility#workflow-names-and-triggers) for the exact trigger contract.

Resolve actions and apply production policy:

```bash
buildkite-gha validate \
  --profile hosted \
  --event-path .buildkite/events/current.json \
  .github/workflows/ci.yml
```

For a quick compatibility check, generate a minimal supported event snapshot:

```bash
buildkite-gha validate \
  --profile hosted \
  --event pull_request \
  .github/workflows/ci.yml
```

The `--event` option supports `push`, `pull_request`, `merge_group`, `release`, `deployment`, `deployment_status`, `create`, `delete`, `label`, `fork`, `public`, `gollum`, `page_build`, `watch`, `milestone`, `branch_protection_rule`, `discussion`, `discussion_comment`, `issues`, `issue_comment`, `pull_request_review`, `pull_request_review_comment`, `workflow_dispatch`, and `schedule`. It requires `--profile hosted` and can't be combined with `--event-path`.

The generated snapshot contains an example repository and the minimum event fields. It's useful for a quick check, but it's not a real payload. The release snapshot represents one stable, non-prerelease `published` event. The issues snapshot represents `opened`, review represents `submitted`, and both comment events represent `created`. Deployment snapshots use the `staging` branch and `preview` environment; deployment status represents `success`. Use `--event-path` when exact refs, activity, repository identity, or payload fields matter.

Use `--all-events` with `--profile hosted` to evaluate each declared supported event with its own generated snapshot:

```bash
buildkite-gha validate \
  --profile hosted \
  --all-events \
  .github/workflows/ci.yml
```

The `--all-events` option can't be combined with `--event` or `--event-path`. It doesn't evaluate `workflow_call` as a standalone event.

Each generated event is checked separately. The result doesn't cover every possible real payload. `context-required` means the available checks passed, but admission needs evidence the generated snapshot can't provide. Push and pull request path filters, for example, need linked-webhook data and a verified local Git diff.

Reuse downloaded immutable action source across profile validation runs:

```bash
mkdir -p .buildkite-gha-action-cache
buildkite-gha validate \
  --profile hosted \
  --all-events \
  --action-cache-dir .buildkite-gha-action-cache \
  .github/workflows/ci.yml
```

The `--action-cache-dir` option is available only with `--profile hosted`. It stores verified action source by immutable commit.

Mutable ref resolutions are cached for one hour under `$XDG_CACHE_HOME/buildkite-gha/action-ref-resolutions/v1`, or the platform's user cache directory. Concurrent validators can share this cache, so a moved tag or branch may use its previous commit for up to one hour. Uploads with `private-reusable-workflows` enabled skip this cache for called repositories and resolve their refs once per operation. Don't share either writable cache between untrusted validation jobs.

#### Validate options

| Option | Description |
| --- | --- |
| `--profile hosted` | Resolves actions and applies production upload policy without executing jobs or proving arbitrary action runtime compatibility. Without `--profile`, `validate` checks event-independent syntax, the static graph, and every declared trigger, and doesn't evaluate hosted admission. |
| `--event <name>` | Generates one minimal compatibility snapshot for the named event. Requires `--profile hosted`. |
| `--event-path <path>` | Uses an exact [event snapshot](#provide-an-event-snapshot). |
| `--all-events` | Evaluates every declared supported event separately. Requires `--profile hosted`. |
| `--action-cache-dir <path>` | Reuses verified immutable action source. Requires `--profile hosted`. |
| `--format <format>` | Selects `text` (the default) or `json` output. |
{: class="responsive-table"}

The `--event`, `--event-path`, and `--all-events` options are mutually exclusive. Generated snapshots are test inputs, not substitutes for real payloads.

#### Validate a workflow corpus

For a large workflow corpus, reuse one validator process and action resolver:

```bash
buildkite-gha validate-batch \
  --manifest workflows.jsonl \
  --output-dir reports \
  --corpus-id zenodo:20340547 \
  --action-cache-dir .buildkite-gha-action-cache \
  --action-cache-max-bytes 21474836480 \
  --action-resolution-snapshot .buildkite-gha-action-resolutions
```

Each JSON Lines manifest record requires `id`, `repository`, `path`, `hash`, and `source`. Batch validation:

- applies the hosted profile to every declared supported event
- writes one `processing-report/v3` JSON file per workflow
- uses one worker per CPU unless `--jobs` overrides it
- publishes each report atomically
- resumes reports only when the corpus, record, workflow dependencies, validator executable, and action-resolution generation still match

Records with unresolved local dependencies are processed again.

The `--action-cache-max-bytes` option requires `--action-cache-dir`. When the cache exceeds the limit, validation evicts the least recently used immutable action trees. Concurrent validators lock active entries. Maintenance removes abandoned partial entries but leaves active ones alone. The [public corpus script](https://github.com/buildkite/buildkite-gha/blob/main/scripts/validate-public-workflow-corpus) defaults to 20 GiB.

The required `--action-resolution-snapshot` option pins each mutable `owner/repository@ref` to the first commit it resolves. Reusing the same generation keeps those refs stable across validator versions. Exact commit references bypass the snapshot.

The snapshot records definitively missing public refs. It doesn't record network, cancellation, TLS, rate-limit, or server failures; those are retried. Rate-limited requests follow the [retry deadline of the action resolver](/docs/pipelines/migration/run-github-actions-workflows/compatibility#actions-action-sources-and-runtimes). Use `--refresh-action-resolution-snapshot` to start a new generation. The public corpus script then removes old report sets for that corpus record.

The snapshot pins action revisions only. It doesn't make the whole corpus run reproducible.

For authenticated GitHub API resolution, keep the token in an environment variable and name that variable without exposing its value:

```bash
GITHUB_TOKEN="$(your-secure-token-command)" \
  buildkite-gha validate-batch \
  --manifest workflows.jsonl \
  --output-dir reports \
  --corpus-id example \
  --action-resolution-snapshot .buildkite-gha-action-resolutions \
  --github-token-env GITHUB_TOKEN
```

The token authenticates GitHub API metadata requests only. It's not written to arguments, logs, reports, snapshots, or action caches. Validation doesn't run action subprocesses, and it still verifies that every action repository is public.

#### Batch validation options

| Option | Description |
| --- | --- |
| `--manifest <path>` | Required. The newline-delimited JSON manifest. |
| `--output-dir <path>` | Required. The directory for `processing-report/v3` results. |
| `--corpus-id <id>` | Required. The corpus ID that keys results. |
| `--action-resolution-snapshot <path>` | Required. The snapshot that pins mutable public action refs on first use. |
| `--refresh-action-resolution-snapshot` | Starts a new snapshot generation. |
| `--action-cache-dir <path>` | Reuses verified immutable action source. |
| `--action-cache-max-bytes <bytes>` | Limits the action cache size. Requires `--action-cache-dir`. |
| `--github-token-env <name>` | Reads a GitHub token from the named environment variable without placing it in arguments or reports. |
| `--jobs <count>` | Sets the number of workers. Defaults to one worker per CPU. |
{: class="responsive-table"}

#### Inspect validation results

Inspect the aggregate result and each event outcome:

```bash
buildkite-gha validate \
  --profile hosted \
  --all-events \
  --format json \
  .github/workflows/ci.yml |
  jq '{result, events: [.evaluations[] | {event, result: .report.result}]}'
```

Inspect diagnostics with their generated event names:

```bash
buildkite-gha validate \
  --profile hosted \
  --all-events \
  --format json \
  .github/workflows/ci.yml |
  jq -r '(.validation.diagnostics[] | "validation: \(.code): \(.message)"),
    (.evaluations[] | .event as $event | .report.diagnostics[] | "\($event): \(.code): \(.message)")'
```

The deprecated `hosted-tokenless` profile name remains an alias for `hosted`. Hosted validation uses the same runner preset as production upload.

Use `--format json` for a `buildkite-gha/processing-report/v2` report. The `--all-events` option emits v3, containing the event-independent report and one v2 report per generated event.

The top-level result is:

- `admitted` only when every event is admitted
- `context-required` when generated input can't measure an otherwise supported path, unless another finding takes precedence

Reports cover every stage from parsing through pipeline generation. If an earlier stage blocks a later one, the later stage is `not-evaluated`, not `failed`.

Warnings and errors become job-scoped Buildkite annotations. A failure that aborts `validate`, `compile`, or upload attaches to the current job. Generated failure steps attach their own diagnostics. Their logs identify the root workflow and the source location, job, matrix instance, action, and step of each diagnostic when available. Failure logs use bold red errors, amber warnings, and cyan workflow and source context, with blank lines between diagnostics. Importer logs and generated failure logs share annotations' human-readable explanations, source excerpts, and diagnostic details. Internal diagnostic codes remain in structured reports and telemetry rather than these logs. Warning-only importer output uses an amber `Workflow diagnostics` heading. Untrusted terminal control characters are removed without changing the underlying report data. If the CLI can't publish an annotation, it warns without changing the command result.

Repository source setup failures in uploads and all-events validation use `E_ENVIRONMENT`. Their diagnostic detail names the failed local operation and recognized causes, such as missing Git or unavailable temporary storage, without copying paths or arbitrary error text. Remediation applies if you manage the environment running the command; guidance for Buildkite hosted agents directs you to the Buildkite Support team at [support@buildkite.com](mailto:support@buildkite.com). Unrecognized causes identify the operation and direct you to support rather than guessing a network or credential problem.

For fetched public and private reusable workflows, source locations in annotations link to the resolved commit and line in the source repository, including nested local calls inside that repository. The link opens only for viewers with GitHub access to that repository. Generated failure logs make the source path and coordinates an OSC 8 terminal hyperlink to the same URL, without a separate URL line. Terminals without hyperlink support display the label. If the source couldn't be fetched, the CLI keeps the location without guessing a revision.

Local workflow links use the event's commit only when its file in the checkout's Git object database matches the bytes parsed. This includes local reusable workflows and early syntax errors. Logs and annotations display local source paths relative to the checkout when possible. They keep the location without a link for edited inputs, unavailable revisions, files outside the checkout, or files larger than the 1 MiB verification limit. Changes on disk after parsing don't change which source revision the diagnostic links to.

Annotations and generated failure logs include a real configuration excerpt where safe: literal action and workflow references in `uses`, standard Ubuntu, Windows, or macOS `runs-on` labels, and built-in step `shell` names. Excerpts retain the parsed line numbers, mark the offending line with `>`, and underline the reference, runner label, or shell with `^`. Standalone trigger filter keys, such as `branches:` and `types:`, also appear with an underline. Filter values and inline filter declarations are omitted. Rejected filters, invalid filter patterns, and unsupported activity types link to their filter key. Errors without a corresponding field retain the event declaration location. Only eligible adjacent lines are included. Scripts, `env`, `with`, comments, expressions, aliases, malformed YAML, and other unclassified content are omitted. Capture is limited to 240 bytes per line and 16 KiB per workflow; excerpts are excluded from JSON reports and telemetry. At annotation size limits, the excerpt is dropped before shortening the explanation.

Profile validation applies the upload trigger policy before compilation. `not-applicable` means the workflow doesn't declare the selected event and would become a skipped top-level step. Malformed event data is incompatible. An unsupported trigger beside a supported one produces a warning.

Validation may use the public network to resolve actions. It doesn't install Node or execute workflow code. It calls Buildkite only to publish annotations when it runs inside a Buildkite job.

## Migrate GitHub Actions secrets

For the step-by-step workflow using the `bk secret migrate github-actions` command of the Buildkite CLI, see [Migrate GitHub Actions secrets](/docs/pipelines/migration/github-actions-secrets). This section describes the equivalent `buildkite-gha migrate-secrets` command. Prefer the Buildkite CLI command for new migrations. The two commands generate compatible workflows, so either CLI can run a migration workflow that the other prepared.

The GitHub API lists repository secret names but can't export their values. The `migrate-secrets` command uses `gh` and `bk` to generate and run a reviewable, one-use workflow without storing a Buildkite API token in GitHub.

Authenticate both CLIs, then prepare the workflow from the GitHub repository:

```bash
gh auth login
bk auth login

buildkite-gha migrate-secrets prepare \
  --match 'DEPLOY_*' \
  --secret API_KEY \
  --output .github/workflows/migrate-buildkite-secrets.yml
```

The Buildkite API token used by `bk` needs the `read_pipelines`, `read_secrets_details`, and `write_secrets` scopes. Its user also needs `manage_cluster` permission for the destination cluster. Large custom policies require a `bk` release that supports `api --data -` (reading request data from stdin). Until that release is installed, use a smaller policy; ordinary grants still work with existing `bk` versions.

Without `--secret` or `--match`, the command lists the repository's Actions secret names and prompts for a selection. It selects a Buildkite pipeline associated with the repository, uses that pipeline's cluster, and creates a pipeline-scoped secret access policy. Use `--organization`, `--pipeline`, and `--cluster` to make selection explicit. Use `--policy-file` for a different non-empty [Buildkite secret access policy](/docs/pipelines/security/secrets/buildkite-secrets/access-policies).

Each workflow can migrate up to 40 secrets. Use multiple workflows for larger sets.

The command checks destination names before writing the workflow and refuses to replace an existing workflow file. Review the generated static secret allowlist and policy, then commit and merge it into the repository's default branch. The command never commits or pushes it.

Run the committed workflow:

```bash
buildkite-gha migrate-secrets run \
  --workflow .github/workflows/migrate-buildkite-secrets.yml
```

The `run` subcommand verifies that the local file matches the workflow at a resolved default-branch commit, allowing the Git CRLF checkout conversion on Windows. It creates a short-lived, one-use Buildkite migration grant bound to that commit, then dispatches the default branch through `gh`. The workflow obtains a GitHub-signed OIDC identity and sends all selected values to Buildkite in one in-memory HTTPS request. Values never enter local CLI output, workflow inputs, files, artifacts, or command arguments.

The grant fixes the organization, cluster, access policy, names, immutable GitHub repository IDs, workflow path and commit, default branch, and `workflow_dispatch` event. Existing destination keys are never overwritten. Buildkite prevalidates the exact batch and atomically creates all visible secret records while consuming the grant. A rolled-back request can leave unreachable encrypted objects for normal storage lifecycle cleanup, but no usable partial keys. After a successful run, remove the workflow from the default branch.

`GITHUB_TOKEN` can't be migrated. `buildkite-gha` obtains it through its separate short-lived, permission-scoped workflow-token path.

#### Secrets migration options

| Subcommand | Option | Description |
| --- | --- | --- |
| `prepare` | `--organization <slug>` | The lowercase Buildkite organization slug. |
| `prepare` | `--cluster <id>` | The Buildkite cluster UUID. |
| `prepare` | `--pipeline <slug>` | The lowercase Buildkite pipeline slug. |
| `prepare` | `--policy-file <path>` | A non-empty secret access policy to use instead of the generated pipeline-scoped policy. |
| `prepare` | `--secret <name>` | Repeatable. A secret name to migrate. |
| `prepare` | `--match <glob>` | Repeatable. A glob that selects secret names. |
| `prepare` | `--output <path>` | The path of the generated workflow file. |
| `run` | `--workflow <path>` | Required. The committed migration workflow to dispatch. |
{: class="responsive-table"}

The `prepare` subcommand discovers secret names through `gh` and destinations through `bk`, then writes reviewable workflow YAML. Neither subcommand commits, pushes, merges, or deletes repository files.

## Provide an event snapshot

The `compile` command, and profile validation with `--event-path`, need a bounded event snapshot:

```json
{
  "provider": "github",
  "event": "push",
  "repository": {
    "owner": "acme",
    "name": "widgets",
    "clone_url": "https://github.com/acme/widgets.git",
    "default_branch": "main"
  },
  "ref": "refs/heads/main",
  "sha": "0123456789abcdef0123456789abcdef01234567",
  "actor": "octocat",
  "payload": {
    "ref": "refs/heads/main"
  }
}
```

The snapshot supplies compile-time context. Plans retain the event name, repository, refs, SHA, actor, and a payload digest. Upload stores the snapshot's payload once as a content-addressed artifact and marks each job to load it for [`GITHUB_EVENT_PATH`](/docs/pipelines/migration/run-github-actions-workflows/compatibility#expressions-and-contexts-event-file), even without event expressions.

The snapshot is compatibility data, not authorization.

## Compile a pipeline

Render Buildkite pipeline YAML:

```bash
buildkite-gha compile \
  --event-path .buildkite/events/current.json \
  .github/workflows/ci.yml
```

Inspect compiler IR:

```bash
buildkite-gha compile \
  --event-path .buildkite/events/current.json \
  --format ir-json \
  .github/workflows/ci.yml
```

The `--event-path` option is required. The `--format` option accepts `pipeline` (the default) or `ir-json`. Pipeline output references content-addressed plans.

Inside a Buildkite job, the IR includes the resolved [repository and organization variables](/docs/pipelines/migration/run-github-actions-workflows/compatibility#job-syntax-repository-and-organization-variables) when the workflow references `vars`.

Workflows whose jobs declare a GitHub [`environment`](/docs/pipelines/migration/run-github-actions-workflows/compatibility#job-syntax-deployment-environments) need GitHub environment access at compile time. Inside a Buildkite job, `upload` and `compile` resolve environments automatically through the job-scoped Agent API; no GitHub token reaches the importer. Outside a job, `compile` fails for such workflows with an error naming the job and its environment; there is no token option.

The `compile` command doesn't upload the executable, plans, or pipeline, so piping its YAML directly to `buildkite-agent pipeline upload` is incomplete.

A workflow with a [matrix](/docs/pipelines/migration/run-github-actions-workflows/compatibility#job-syntax-matrices-from-job-outputs) or [runner selection](/docs/pipelines/migration/run-github-actions-workflows/compatibility#job-syntax-runners-from-job-outputs) from a job output has jobs that only exist after a deferred step runs inside the build, so `compile` renders its IR but not its pipeline YAML:

```text
buildkite-gha: compile: job "build" takes its matrix from a job output, so upload expands it with a deferred step inside the build; the pipeline format cannot render it. Use --format ir-json to inspect the compiled graph.
```

The IR lists the deferred step and its jobs under `continuations`.

## Upload from a custom importer

The `upload` command is the public in-build command for custom importers:

```bash
buildkite-gha upload .github/workflows/ci.yml
```

The importer must run on Linux/amd64, Linux/arm64, or Darwin/arm64 with Buildkite agent v3.129 or newer, `BUILDKITE=true`, and `BUILDKITE_STEP_KEY`. The plugin wrapper starts the importer only on Linux/amd64 or Darwin/arm64.

#### Upload options

| Option | Description |
| --- | --- |
| `--event-path <path>` | Uses an explicit event snapshot. See [Select the effective event](#upload-from-a-custom-importer-select-the-effective-event). |
| `--runner-queue <runs-on>=<queue>` | Repeatable. Maps one supported `runs-on` label to a Buildkite queue and overrides automatic resolution. Duplicate or unsupported mappings fail. |
| `--runner-image <runs-on>=<immutable-image>` | Repeatable. Overrides the preset image for a configured profile with an immutable image. |
| `--runtime-distribution <platform>=<absolute-path>` | Repeatable. Binds `linux/amd64`, `linux/arm64`, `darwin/arm64`, or `windows/amd64` to a verified executable. |
| `--private-reusable-workflows` | Enables importer-only Git fallback for private reusable workflows with the job's existing Git credentials. It doesn't enable private actions. |
| `--experimental-runner-user=<boolean>` | Set to `false` to temporarily disable the non-root `runner` identity for generated Linux jobs. See [Run Linux jobs as a non-root user](#upload-from-a-custom-importer-run-linux-jobs-as-a-non-root-user). |
| `--runtime-queue hosted` | Deprecated. Accepted for plugin compatibility, but doesn't select a queue. |
| `--private-checkout` | Deprecated. Accepted as a no-op. Verified checkout jobs automatically use Buildkite repository-provider Git credentials when the job enables them. |
| `--` | Ends option parsing. See [Select workflows](#upload-from-a-custom-importer-select-workflows). |
{: class="responsive-table"}

#### Plugin entry point

The hidden, zero-argument `buildkite-gha plugin` entry point reads plugin configuration from `BUILDKITE_PLUGIN_CONFIGURATION`. It accepts:

- either one `workflow` path or a non-empty `workflows` array
- `runners` and `oidc`
- plugin-owned `version`, `source-ref`, and `minimum-release-age` fields
- the Boolean `experimental-runner-user` and `private-reusable-workflows` fields

| Field | Description |
| --- | --- |
| `workflow` | One non-empty workflow path. Mutually exclusive with `workflows`. |
| `workflows` | A non-empty array of non-empty workflow paths. Mutually exclusive with `workflow`. |
| `runners` | A non-empty array of runner mappings. Each mapping requires `runs-on` and `queue` strings, and accepts an optional `image` (an immutable registry `sha256` reference) and an optional [`cache`](#upload-from-a-custom-importer-configure-generated-job-cache-volumes) object. Each runner label can be configured only once. Windows mappings reject `cache`. |
| `oidc` | An object that accepts non-empty `claims` and `aws-session-tags` arrays of non-empty strings, and a non-empty `subject-claim` string. |
| `experimental-runner-user` | A Boolean. Defaults to `true`. |
| `private-reusable-workflows` | A Boolean. Defaults to `false`. |
| `version`, `source-ref`, `minimum-release-age` | Plugin-owned fields. |
{: class="responsive-table"}

Unknown fields fail.

### Pipeline trigger selection

Server-selected workflow imports run in builds created by a GitHub Actions pipeline trigger. To set up a GitHub Actions pipeline trigger, see [Trigger builds from workflow events](/docs/pipelines/migration/run-github-actions-workflows#add-a-github-actions-workflow-to-a-pipeline-trigger-builds-from-workflow-events).

Without an explicit selector, `BUILDKITE_GITHUB_WORKFLOW_PATH` marks a GitHub Actions pipeline trigger selection. The server also supplies:

- `GITHUB_EVENT_NAME`: One of `push`, `pull_request`, `issues`, `issue_comment`, `pull_request_review`, `pull_request_review_comment`, `release`, `merge_group`, `deployment`, `deployment_status`, `create`, `delete`, `label`, `fork`, `public`, `gollum`, `page_build`, `watch`, `milestone`, `branch_protection_rule`, `discussion`, or `discussion_comment`.
- `GITHUB_WORKFLOW`: The workflow `name`, or its repository-relative path when `name` is absent.
- `GITHUB_WORKFLOW_REF`: The value `<owner>/<repo>/<repository-relative-path>@<event-ref>`.
- `GITHUB_WORKFLOW_SHA`: The full commit used to match the workflow.
- `BUILDKITE_GITHUB_EVENT`: A compatibility duplicate of `GITHUB_EVENT_NAME`.
- `BUILDKITE_GITHUB_ACTION`: The event activity. Push and deployment events, plus `create`, `delete`, `fork`, `public`, `gollum`, and `page_build`, omit it.

The `GITHUB_*` values take precedence when present. The plugin derives the selected path from `GITHUB_WORKFLOW_REF`, checks `GITHUB_WORKFLOW` against the checked-out file, and requires `GITHUB_WORKFLOW_SHA` to match the checkout commit. A malformed preferred value fails instead of falling back.

For pull requests, `GITHUB_WORKFLOW_REF` and imported jobs' `GITHUB_REF` retain `refs/pull/<number>/merge`, while `GITHUB_WORKFLOW_SHA`, `GITHUB_SHA`, and the Buildkite checkout use the pull request head commit. Review and inline review-comment events use the same PR-head contract. They require both workflow identity fields and the original `buildkite:webhook` payload. The PR number, head SHA, head and base branches, activity, and all three repository identities must agree with the build. Missing payloads (including rebuilds without retained webhook data) fail closed, not as synthetic PR events.

For `issues` and `issue_comment`, the ref is the current repository default branch and the SHA is its server-verified tip. Both identity fields are required. The linked payload action and repository must match the Buildkite environment, and `issue_comment` accepts both issue and pull request conversation comments.

For `release`, both workflow identity fields and the original linked payload are required. The ref identifies the release tag; the SHA identifies its server-resolved peeled commit. Repository, tag, branch, and activity must agree. Draft releases reject `created`, `edited`, `deleted`, and `unpublished`. See [release compatibility](/docs/pipelines/migration/run-github-actions-workflows/compatibility#workflow-names-and-triggers).

Deployment events require both workflow identity fields and the original linked payload. Workflows use the deployment commit and branch or tag ref, or an empty Actions ref for SHA-only deployments. SHA-only workflow identity uses `@<sha>`. See [deployment compatibility](/docs/pipelines/migration/run-github-actions-workflows/compatibility#workflow-names-and-triggers) for provenance checks and inactive-status suppression.

For `merge_group`, both workflow identity fields and the original linked payload are required. The selected ref and SHA identify the speculative head; the distinct base branch and SHA must match the Buildkite merge-queue metadata. `BUILDKITE_GITHUB_ACTION` must match the payload's actual `checks_requested` or `destroyed` action. Only tokenless workflows are supported. See [merge-group compatibility](/docs/pipelines/migration/run-github-actions-workflows/compatibility#workflow-names-and-triggers) and the [destruction rollout boundary](/docs/pipelines/migration/run-github-actions-workflows/compatibility#workflow-names-and-triggers-merge-group-destruction).

`BUILDKITE_GITHUB_WORKFLOW_PATH` remains the path fallback because GitHub has no `GITHUB_WORKFLOW_PATH`. `BUILDKITE_GITHUB_ACTION` remains the action source because the GitHub `GITHUB_ACTION` variable has a different meaning. An explicit `workflow` or `workflows` value takes precedence over server workflow selection.

The plugin also validates these values before upload:

- `BUILDKITE_GITHUB_WORKFLOW_PATH` must be a non-empty path without surrounding whitespace. If any of `GITHUB_EVENT_NAME`, `GITHUB_WORKFLOW`, `GITHUB_WORKFLOW_REF`, or `GITHUB_WORKFLOW_SHA` is set without it, the import fails.
- `GITHUB_EVENT_NAME` or `BUILDKITE_GITHUB_EVENT` is required.
- `GITHUB_WORKFLOW_REF` must name the same repository as a `github.com` `BUILDKITE_REPO`, and its event ref must match the event: `refs/heads/` or `refs/tags/` for `push` and `create`; `refs/pull/<number>/merge` for pull request and review events; `refs/tags/` for `release`; `refs/heads/` for the other events. Deployment events also accept a full commit SHA.
- `GITHUB_WORKFLOW_SHA` must be a full lowercase 40-character hexadecimal commit. Every event other than `push` and `pull_request` requires both `GITHUB_WORKFLOW_REF` and `GITHUB_WORKFLOW_SHA`.

Use the plugin shorthand to request server selection:

```yaml
steps:
  - label: "\:github\:"
    plugin: github-actions
```

This server-selected form doesn't require the importer step to have a `key`. The plugin uploads the event, runtime, and plan artifacts before uploading the dynamic pipeline, and scopes artifact reads to the importer job. It doesn't use the job ID as a dependency key. Explicit-selector importers still require a step `key`, and generated workflow groups depend on it.

Missing or untracked explicitly configured workflow paths warn and are skipped. If every configured path is missing or untracked, the plugin succeeds without uploading a pipeline. A missing or untracked server-selected path fails. Every present path must be a regular, tracked `.yml` or `.yaml` file inside the repository. Directories, tracked files missing from the checkout, symlinks, and globs are rejected. The optional `oidc` object accepts non-empty `claims`, `aws-session-tags`, and `subject-claim` values. Unknown fields and invalid values fail before upload.

The plugin resolves relative workflow paths from `BUILDKITE_BUILD_CHECKOUT_PATH`, not the command hook's working directory.

The importer reuses its verified executable for jobs on the same platform. It downloads the other platform's distribution from the same release only when a workflow needs it. Runner mappings apply to generated jobs, not the importer.

### Configure generated-job cache volumes

An explicit runner mapping can attach one Buildkite hosted agents cache volume to each generated job using that mapping:

```yaml
plugins:
  - github-actions#latest:
      workflow: .github/workflows/ci.yml
      runners:
        - runs-on: ubuntu-latest
          queue: hosted
          cache:
            paths:
              - /home/runner/.gradle/caches
              - /home/runner/.gradle/wrapper
            name: gradle-dependencies
            size: 40g
```

The `cache.paths` field is a required, non-empty list of unique absolute paths. The `name` and `size` fields are optional. Names follow the Buildkite 100-character letters-numbers-hyphens format and may contain `${BUILDKITE_*}` variables. Sizes use `Ng` and must be at least `20g`. Without a name or size, Buildkite uses its pipeline-scoped name and 20 GB defaults.

Each Buildkite Pipelines step supports one cache volume. When a job also needs the internally managed `mise` cache, `buildkite-gha` adds the `mise` path to the same volume. A configured name and size apply to that combined volume; otherwise, the managed `mise` name and the Buildkite default size remain unchanged. Jobs with neither configuration emit no `cache` attribute.

Runner cache volumes aren't supported for workflow jobs that set `container`.

Generated Linux jobs run as `runner`. Configured cache paths are made writable by that user after the bootstrap verifies that they target the Buildkite cache volume. Prefer narrowly scoped paths. For example, caching an entire Gradle User Home also persists `init.d` scripts and other executable configuration, increasing the impact of cache poisoning. Caching only `caches` and `wrapper` reduces that exposure, but a cache-volume miss doesn't provide the `setup-gradle` archive-cache fallback once the mounted `caches` directory exists.

Cache volumes are best-effort accelerators, scoped to the Buildkite pipeline and cluster. They commit after successful jobs and are abandoned after failed jobs. Don't use them as durable or trusted storage. See [Cache volumes](/docs/agent/buildkite-hosted/cache-volumes).

### Select workflows

Pass every workflow path explicitly:

```bash
buildkite-gha upload -- \
  .github/workflows/ci.yml \
  .github/workflows/release.yml
```

Every operand must name one regular `.yml` or `.yaml` file. For multiple workflows, every path must be tracked inside the repository. Upload canonicalizes, deduplicates, and sorts aliases, so argument order doesn't change the pipeline.

Directories, globs, missing files, other extensions, and symlinks fail before parsing or Buildkite commands run. Multiple-workflow uploads also reject untracked and outside paths.

The `--` separator ends option parsing. Use it before any externally supplied paths, and always when a path begins with `-`. Pass each path as its own argument; the CLI doesn't split one shell string or decode a JSON or YAML list.

Upload is atomic. Skipped workflows become top-level skipped steps. Reusable-only files remain available to local callers but don't create groups. Selecting only reusable workflows is an error.

An explicit non-empty workflow `run-name` appends ` — <run-name>` to its group label after resolving [supported expressions](/docs/pipelines/migration/run-github-actions-workflows/compatibility#workflow-names-and-triggers). Workflow names, provider-check names, and the Buildkite build message remain unchanged.

See [Aggregate workflow upload](/docs/pipelines/migration/run-github-actions-workflows/compatibility#how-workflows-run-on-buildkite-pipelines-aggregate-workflow-upload) for workflow grouping, labels, provider checks, and failure behavior.

Private reusable workflows are off by default. Set the plugin's `private-reusable-workflows: true` field, or pass `upload --private-reusable-workflows` from a custom importer. See [Reusable workflows](/docs/pipelines/migration/run-github-actions-workflows/compatibility#workflow-syntax-reusable-workflows) for the access boundary and [Security](/docs/pipelines/migration/run-github-actions-workflows/security#repository-data-does-not-grant-authority) for the credential boundary.

A parse, compilation, or trigger-translation error in an aggregate upload replaces only that workflow with a failing top-level step. Compilation continues for later workflows. Single-workflow parse errors and event-input, admission, artifact, and upload failures abort the complete transaction; no partial pipeline is uploaded.

### Select the effective event

Event source precedence is:

1. `--event-path`
1. `buildkite:webhook` metadata reserved by Buildkite
1. A reduced snapshot derived from `BUILDKITE_*` variables when no linked webhook is available

Every event source remains unsigned. An explicit path never reads Buildkite metadata. Webhook metadata must be one valid JSON object no larger than 25 MiB. Malformed, unreadable, or oversized data stops upload instead of falling back. The Buildkite repository mapping, commit, and ref remain authoritative.

Raw webhook data isn't embedded in generated plans or pipeline YAML. Upload retains one content-addressed event artifact for linked webhooks and explicit snapshots, so every job and its retries can read the [event file](/docs/pipelines/migration/run-github-actions-workflows/compatibility#expressions-and-contexts-event-file). For reduced fallback snapshots, it retains the artifact only when runtime event expressions require it. Event data can't grant queues, secrets, or tokens.

The selected snapshot establishes one event for applicability, compilation, workflow conditions, provider-check names, and explicit run-name evaluation. An explicit event is never replaced with live Buildkite fields.

Linked webhook data can provide native `merge_group`, `release`, and `issues` events. GitHub Actions pipeline trigger identity additionally supports `merge_group`, `release`, `deployment`, `deployment_status`, `create`, `delete`, `label`, `fork`, `public`, `gollum`, `page_build`, `watch`, `milestone`, `branch_protection_rule`, `discussion`, `discussion_comment`, `issues`, `issue_comment`, and PR review events without native event settings. Merge groups and releases need matching Buildkite refs, commits, and activity. Release also needs a valid payload and a tag matching `BUILDKITE_TAG` and `BUILDKITE_BRANCH`. Issue and comment payloads need a valid action, object identity, and repository matching the Buildkite checkout. The GitHub Code Access App provides immutable server provenance and is required for hosted release `GITHUB_TOKEN` issuance.

See [Workflow names and triggers](/docs/pipelines/migration/run-github-actions-workflows/compatibility#workflow-names-and-triggers) for exact matching rules and the environment fallback.

A top-level workflow that doesn't declare the event becomes a skipped step with no plan artifacts. If none apply, upload succeeds with a skipped-only pipeline.

For an applicable workflow, only the selected event contributes a workflow condition. Supported branch, tag, base-branch, and activity filters add their constraints. A workflow whose path filters verifiably don't match becomes a skipped step without workflow jobs or plan artifacts. Conditions from different events are never combined.

Unsupported or uncertain filters replace only the affected workflow with a failing step. Push and pull request path filters need a linked webhook and a matching local checkout. Generated or explicit snapshots can report that need, but can't grant admission. Malformed event data stops the import.

Buildkite Pipelines owns schedule identity, so every `on.schedule` workflow is eligible for every Buildkite scheduled build. Scheduled groups select the preserved GitHub event or, when it's absent, the Buildkite schedule source.

After all applicable workflows have been attempted, the command uploads the exact executable, content-addressed plans, and synthetic failure steps in one artifact batch with a concurrency limit of 8. It then runs one:

```bash
buildkite-agent pipeline upload --no-interpolation
```

Buildkite agent v4 rejects pipeline uploads containing secrets by default.

### Choose runners and runtimes

Use repeatable mappings before the workflow path:

```bash
buildkite-gha upload \
  --runner-queue ubuntu-latest=hosted \
  --runner-queue ubuntu-24.04-arm=my-linux-arm64-queue \
  --runner-queue macos-14=macos-sonoma-arm64 \
  --runtime-distribution linux/arm64=/opt/buildkite-gha-linux-arm64 \
  --runtime-distribution darwin/arm64=/opt/buildkite-gha-darwin \
  .github/workflows/ci.yml
```

Linux arm64 mappings always require an explicit queue and never fall back to an amd64 image or emulation. The release plugin acquires and verifies `buildkite-gha_Linux_arm64.tar.gz` when a selected workflow needs that runtime. This artifact doesn't enable a Buildkite hosted agents Linux ARM64 queue.

The hosted preset accepts runner labels case-insensitively, so aliases such as `macOS-latest` and `Ubuntu-Latest` are equivalent to their lowercase forms. Local presets use Noble for `ubuntu-latest` and `ubuntu-24.04`, and Jammy for `ubuntu-22.04`. Backend resolution can instead select a native Linux environment through agent tags. Use `--runner-image` with an immutable digest to override the preset for a configured profile; backend tags never replace that explicit image. An explicit mapping declares its selector's platform from the known Linux, macOS, and Windows labels. The importer validates its queue and hosted platform through the job-scoped Agent API before upload, preserving the configured image and cache. An import using explicit mappings stops if that validation is unavailable. The Agent API owns compatibility and returns the complete target for every other selector. The importer publishes returned warnings as annotations. See [Compatibility](/docs/pipelines/migration/run-github-actions-workflows/compatibility#job-syntax-job-configuration) for runner behavior. Runtime distribution paths must be absolute executables. The importer's platform defaults to its running executable; other platforms have no direct-upload default. `BUILDKITE_GHA_TARGET_QUEUE` and `BUILDKITE_GHA_RUNTIME_IMAGE` are no longer supported.

Without Agent API resolution, unmapped supported Linux labels retain default agent targeting with the preset image, `macos-latest` falls back to the hosted `macos-medium` queue, and `macos-14` and `macos-15` accept explicit fallback queues. The `windows-latest` and `windows-2022` jobs require explicit queues or enabled Agent API resolution; they have no local preset.

For [Windows jobs](/docs/pipelines/migration/run-github-actions-workflows/compatibility#windows-jobs), map the workflow's label to an existing compatible Windows queue. For example, this plugin configuration imports a workflow using `runs-on: windows-2022`:

```yaml
steps:
  - label: Import Windows workflow
    key: import-windows-workflow
    agents:
      queue: my-linux-importer-queue
    plugins:
      - github-actions#latest:
          workflow: .github/workflows/ci.yml
          runners:
            - runs-on: windows-2022
              queue: my-windows-queue
```

Replace both queue names with queues in your pipeline's cluster. The importer runs on Linux or macOS, not Windows. If the workflow uses `windows-latest`, use that label in the mapping instead. For automatic routing, omit the Windows `runners` entry only after checking the [access and queue requirements](/docs/pipelines/migration/run-github-actions-workflows/compatibility#windows-jobs-configure-a-windows-runner).

For direct CLI upload from a Buildkite job, also supply the Windows x86-64 runtime executable from the same release, at an absolute path on the importer:

```bash
buildkite-gha upload \
  --event-path event.json \
  --runner-queue windows-2022=my-windows-queue \
  --runtime-distribution windows/amd64=/opt/buildkite-gha.exe \
  .github/workflows/ci.yml
```

The plugin acquires the Windows runtime from the same release only when a selected workflow requires it and verifies the release checksums. Direct CLI users must verify the Windows release archive against that release's checksum file before extracting `buildkite-gha.exe`. Development plugin runs use `BUILDKITE_GHA_PLUGIN_DEV_WINDOWS_RUNTIME` as an absolute path to a locally built Windows executable. Windows targets reject `--runner-image` and cache volumes. These mappings don't create queues or grant hosted Windows access.

The deprecated `--runtime-queue hosted` argument is accepted as a no-op for compatibility with plugin releases that pass it. Other values are rejected.

### Expand a matrix inside the build

When a workflow takes matrices or runner selections from job outputs, `upload` creates one deferred step per group of overlapping downstream jobs, in addition to the static jobs (see [Matrices from job outputs](/docs/pipelines/migration/run-github-actions-workflows/compatibility#job-syntax-matrices-from-job-outputs) and [Runners from job outputs](/docs/pipelines/migration/run-github-actions-workflows/compatibility#job-syntax-runners-from-job-outputs)). The importer needs `BUILDKITE_JOB_ID` for this. Every runtime platform the expanded jobs may need must already be configured with `--runtime-distribution`; a row that selects an unconfigured platform fails the deferred step. The importer resolves repository and organization variables when any job of the workflow, deferred or not, reads `vars` in the workflow or in an action it uses, and records the scopes for the deferred steps. Such a workflow is never uploaded job by job: when any of its jobs fails compilation, the whole workflow is replaced with one failing step, because a partial upload would drop the deferred steps.

The importer and every deferred step are stages of one compilation. Each stage compiles the whole workflow through the same compile path, uploads the jobs whose scheduling values it knows, and writes a stage record for each boundary the compiler still defers. The deferred step downloads the importer's executable, then runs the internal form of the same command:

```bash
buildkite-gha upload \
  --stage-digest sha256:<digest> \
  --stage-producer <job-id>
```

This form accepts no other options or operands. The `--stage-producer` option is the job whose artifacts hold the stage record: the importer for the first deferred step of a component, or the earlier deferred step when a matrix chains from a job that step compiled (see [Matrices from job outputs](/docs/pipelines/migration/run-github-actions-workflows/compatibility#job-syntax-matrices-from-job-outputs)). The event source and the runtimes always come from the importer the record names. Releases before this form emitted a separate `continue` command; a deferred step always runs the executable digest its own importer uploaded, so the two never mix inside one build.

A stage step runs inside a Buildkite job with `BUILDKITE=true`, `BUILDKITE_BUILD_ID`, `BUILDKITE_JOB_ID`, and the default checkout. It:

1. Downloads the stage record, verifies its digest and compiler version, and checks that the workflow in the checkout is byte-for-byte the one the importer compiled. The record also holds the action revisions and the variable scopes the importer resolved for the deferred jobs, so a stage never requests variables itself, and the rows every earlier stage of a chained component resolved.
1. Reads each producer's verified result through the same manifest path that `needs` outputs use, bound to its exact instance key and plan digest. A verified non-success result skips that root's downstream jobs, while a missing or invalid manifest fails the step before any upload. Earlier producers must still match their recorded results (see [matrix retries](/docs/pipelines/migration/run-github-actions-workflows/compatibility#job-syntax-matrices-from-job-outputs)).
1. Expands successful outputs with the static-matrix rules and limits, or evaluates the runner selection using an output of at most 1 KiB. It checks that the rows and dependents fit the share of the 1,024-job limit the record holds for this step (see [Matrices from job outputs](/docs/pipelines/migration/run-github-actions-workflows/compatibility#job-syntax-matrices-from-job-outputs)). It recompiles the workflow with the recorded event, variables, runner mappings, OIDC, and `private-reusable-workflows` settings and the recorded rows of earlier stages, reads remote reusable workflows and actions through the same repository source as `upload`, and resolves runners through the Agent API as `upload` does. It requires the jobs the earlier uploads created to compile identically, requires each deferred job to come from the workflow source the importer recorded, including the commit of a reusable workflow from another repository, and pins each deferred job's actions to the recorded revisions.
1. Uploads the plans and a pipeline holding only the deferred jobs whose scheduling values exist, including skipped placeholders where needed. Joins appear once, and outside prerequisites remain references to steps already in the build. When some deferred jobs read their matrix from a job this upload compiled, the pipeline also holds the next stage's deferred step, and the upload writes that step's stage record with the rows accepted so far and the unused part of this step's job share.

Buildkite Pipelines rejects an upload whose step keys already exist. When that happens, the stage confirms through `buildkite-agent step get` that each expected step carries the plan it just compiled and exits 0, so retrying the deferred step never duplicates jobs. For skipped jobs in a merged component, it also verifies the command marker bound to the stage record digest. A missing step or a different binding fails the replay. For [output-derived scheduling](/docs/pipelines/migration/run-github-actions-workflows/compatibility#job-syntax-scheduling-from-matrix-producer-outputs), it also compares the concurrency group and limit. Any other failure exits 1 with:

```text
Retry the whole build to expand this matrix again. If the matrix producer job was retried, only a new build can expand it.
```

Runner selection failures instead say:

```text
Retry the whole build to select this runner again. If the producer job was retried, only a new build can select it.
```

### Run Linux jobs as a non-root user

Generated Linux jobs use a dedicated `runner` user by default. This behavior requires `buildkite-gha` v0.13.7 or newer. Jobs can start as root or as an existing `runner` user with home `/home/runner` and passwordless `sudo`. For a non-root start, the bootstrap uses `sudo -n` for privileged setup. It creates the `runner` user when needed, grants passwordless `sudo` and Docker socket access when the socket exists, prepares the runner home, temp, `mise`, and tool-cache paths, then runs `buildkite-gha run-job` as `runner`. The verified executable and compiled plan remain root-owned and read-only to `runner`. Generated jobs skip the Buildkite checkout. When a workflow uses `actions/checkout`, the native adapter clones as `runner`, so the runtime doesn't recursively change workspace ownership. This behavior doesn't depend on a queue name and doesn't affect macOS or Windows jobs.

During the transition, set the plugin field to `false` to run as the agent's original user without this bootstrap:

```yaml
steps:
  - label: "\:github\: CI"
    plugins:
      - github-actions#latest:
          workflow: .github/workflows/ci.yml
          experimental-runner-user: false
```

For a custom importer, pass `upload --experimental-runner-user=false`. The bare `--experimental-runner-user` form and a plugin value of `true` remain accepted. The plugin value must be a YAML boolean, not a quoted string.

## Disable telemetry

In Buildkite jobs, the importer and runtime send best-effort completion telemetry through the job-authenticated Agent API. Events contain the command, outcome, client version, duration, and bounded diagnostics. Diagnostics can identify a rejected feature with a `blocker` slug and bounded `blocker_detail`, such as `runner_label` and `windows-latest`. Distinct rejected values remain separate diagnostics even when they share a diagnostic code. Unsupported events use `trigger` and the event name; path-filter evaluation failures use `path_filter` and the event name. Runner rejections name a label only when that label caused the rejection. Trust, conflicting-target, and Agent API rejections use `runner_policy` with a stable reason code instead. These fields are telemetry attribution, not fields in processing-report JSON.

Workflow diagnostics include their message and detail in `message`, even when the importer exits zero after uploading failing steps for rejected workflows. Messages are normalized to one line and retain at most their first 1,024 UTF-8 bytes; `message_truncated` is true when text was shortened. `workflow_path` identifies the root workflow being imported, relative to the checkout when possible. Paths over 1,024 bytes or containing invalid UTF-8 or control characters are omitted rather than shortened. Deduplication includes the bounded message and workflow path, subject to the limit of 20 diagnostics per command.

For an unsuccessful command, events also contain a normalized user-visible error message of at most 1,024 bytes. When a workflow diagnostic attributes the failure, the message is the text of that diagnostic, kept whole so later job output can't displace it. Otherwise it's the final bytes of the command's error output. `error_message_truncated` says whether part of the message was omitted.

Failed runs also carry a failure phase and a code from a fixed set. The code separates workflow-authored process exits (`E_STEP_PROCESS_EXIT`) from unsupported-feature rejections (`E_UNSUPPORTED_FEATURE`) and runtime integrity failures (`E_RUNTIME_INTEGRITY`), so a failing test suite isn't counted as a compatibility gap. Runtime rejections include the same blocker fields when the runtime can identify the rejected shell or action reference. Secret resolution failures use `E_SECRET_UNAVAILABLE`, making secret availability independently measurable. Workflow-token, OIDC-token, and cache credential acquisition failures use `E_WORKFLOW_TOKEN_UNAVAILABLE`, `E_OIDC_TOKEN_UNAVAILABLE`, and `E_CACHE_CREDENTIAL_UNAVAILABLE`, including Agent API client timeouts but not caller cancellation. A successful OIDC retry clears the recorded failure for that audience. Unsupported-feature and runtime integrity failures take precedence over token acquisition failures. When the failure code identifies a token or cache credential failure, `agent_api_http_status` contains the Agent API response status, if it's between 100 and 599. Invalid statuses are omitted without dropping the event. Other unclassified failures keep the `unknown` code and omit the status.

Buildkite adds organization, pipeline, build, and job identifiers on the server. The client doesn't send workflow or event content, environment variables, command text, or secrets as separate properties. Blocker details come from workflow-authored configuration. Event-derived runner labels and environment expressions are omitted.

Diagnostic messages and error output can include details already printed in the job log, such as workflow paths, action references, expressions, or invalid configuration values. Avoid putting secrets in error messages. Disable telemetry when this diagnostic context must stay inside the job.

Set `BUILDKITE_GHA_TELEMETRY_DISABLED=true` to disable telemetry. A missing Agent endpoint, job ID, or job token also disables it. Telemetry failures don't change command results.

### Bugsnag error reports

In `buildkite-gha` releases later than v0.100.0, when a Bugsnag ingestion key is configured, the client sends best-effort error reports directly to `https://notify.bugsnag.com`, independently of the Agent API. Tagged `buildkite-gha` releases embed the key at build time. The `BUGSNAG_API_KEY` environment variable overrides the embedded key. Without a valid key, no reports are sent. Setting `BUILDKITE_GHA_TELEMETRY_DISABLED=true` disables both Bugsnag reporting and completion telemetry.

Reports cover unexpected runtime errors, runtime integrity and token-acquisition failures, final artifact and pipeline uploads during the initial workflow import, and authoritative result-publication failures. Deferred-stage and skipped-job uploads aren't instrumented.

The following are excluded from reports:

- Ordinary workflow process exits, including tolerated failures.
- Unsupported features and import validation errors.
- Classified runtime file-command and output validation errors.
- Secret-availability errors.
- Caller cancellation.
- Workflow-owned job and step timeouts.

Agent HTTP client timeouts and cleanup deadlines remain reportable. Excluded branches of joined errors don't suppress independent unexpected failures. Warnings and unhandled panics aren't reported. Container termination failures remain reportable even when the job tolerates the step failure. Reporting doesn't change `continue-on-error` behavior.

Reports contain the CLI version, error type, stack locations, command, failure phase and code, valid Buildkite build and job IDs, and the applicable Agent API status. Development versions use the `development` release stage, and other versions use `production`. Standard Go errors have a stack at the reporting boundary, not the original failure site. Wrapped and joined errors retain the first captured stack in depth-first order when available. Command, phase, and failure code are part of the error class, so different categories don't share a group only because they reach the same reporting boundary.

Reports omit raw error messages and causes, job output, diagnostics, workflow and event contents, other environment values, and the hostname. Detailed error text remains in the job log. Automatic session tracking and the process-forking panic handler of the SDK aren't enabled.

Delivery is synchronous, with a 1.5-second network timeout per report, no retries, and no redirects. Reporting failures are silent and don't change command results.
