---
description: "Supported workflow syntax, triggers, actions, defaults, and limits for GitHub Actions Compatibility in Buildkite Pipelines."
---

# GitHub Actions Compatibility reference

GitHub Actions Compatibility runs a supported subset of GitHub Actions workflows as native Buildkite Pipelines jobs. Use this reference to check whether your workflow can run, what needs to change, and which restrictions apply.

This page covers the current released `buildkite-gha` runtime and server-side workflow selection, distinguishing advanced runtime capabilities from native setup defaults. Minimum versions and required pipeline settings or server capabilities are noted with each feature. Treat unlisted functionality as unsupported.

For setup without configuring a plugin or installing the runtime, see [GitHub Actions Compatibility](/docs/pipelines/migration/run-github-actions-workflows). For optional diagnostics and advanced custom importers, see the [CLI reference](/docs/pipelines/migration/run-github-actions-workflows/cli). The [security guide](/docs/pipelines/migration/run-github-actions-workflows/security) describes credential and job-isolation requirements.

GitHub's [workflow syntax reference](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax) describes the original syntax. This page describes the subset that runs on Buildkite Pipelines.

<a id="support-matrix"></a>

## Compatibility at a glance

Use this table to identify migration work, then check the linked restrictions and setup. _Accepted, no effect_ means the syntax doesn't change execution. [Browse or report compatibility issues](https://github.com/buildkite/buildkite-gha/issues?q=is%3Aissue%20state%3Aopen%20label%3Acompatibility).

| Feature | Support | Main restriction or setup | Details |
| --- | --- | --- | --- |
| Runners and tools | Linux x86-64/arm64, macOS arm64, Windows Server 2022 x86-64 | Agent v3.129+; Linux arm64 needs an explicit queue mapping and support contact for native setup. Labels don't reproduce GitHub images or tools. | [Runners and tools](#runners-and-tools) |
| Events and filters | Listed events and bounded filters | Native manual runs require matching `push` without `workflow_dispatch`. Delivery can require backend support and webhook setup. Path filters need linked data and local history. | [Events and triggers](#events-and-triggers) |
| Actions | Local and public JavaScript/composite actions; Linux Docker actions | Private actions and direct workflow `docker://` calls are unsupported. Admission doesn't guarantee GitHub service access. | [Action sources and runtimes](#actions-artifacts-and-caching-action-sources-and-runtimes) |
| Checkout | Native adapter for the event repository | Pull requests check out the head, not a merge. No alternate repositories or persisted credentials. | [Checkout action](#actions-artifacts-and-caching-checkout-action) |
| Artifacts | Native ZIP upload and download | Downloads require verified direct `needs` producers; no cross-run/repository or GitHub artifact API access. | [Upload](#actions-artifacts-and-caching-upload-artifact-action), [download](#actions-artifacts-and-caching-download-artifact-action) |
| Caching | Admitted cache-v2 clients use Buildkite Results | Client versions and tools matter. Cache mode is best-effort, not authorization. | [Cache action](#actions-artifacts-and-caching-cache-action) |
| Repositories and GitHub tokens | Public GitHub; authorized private GitHub/Origin access | Public workflow-token support requires eligible hosted GitHub.com jobs, the token setting enabled, and top-level permissions. | [Repositories](#credentials-and-deployments-repositories), [GitHub token](#credentials-and-deployments-github-token) |
| Secrets and OIDC | Buildkite Secrets; Buildkite-issued OIDC | GitHub secrets aren't copied. Cloud trust must use the Buildkite issuer and claims. | [Secrets and OIDC](#credentials-and-deployments-other-secrets-and-oidc) |
| Deployment environments | Literal top-level-job names and approval gates | GitHub reviewer identity isn't enforced; several protection rules are rejected. URL is accepted but ignored; no deployment records are created. | [Deployment environments](#credentials-and-deployments-deployment-environments) |
| Reusable workflows | Local, public, and approved private sources | Four-level nesting; private source access is off by default in native setup and requires support contact. Remote secret forwarding is unsupported. | [Reusable workflows](#workflow-syntax-reference-reusable-workflows) |
| Jobs, matrices, steps, and expressions | Listed syntax and bounded dynamic forms | Context access varies by field. Deferred expansion has source, graph, and scheduling limits. | [Workflow syntax reference](#workflow-syntax-reference), [jobs](#job-syntax), [steps](#step-syntax), [expressions](#expressions-and-contexts) |
| Concurrency and fail-fast | Queued concurrency groups; fail-fast syntax accepted | Workflow `cancel-in-progress: true` warns but doesn't cancel. Matrix `fail-fast` has no cancellation effect. | [Concurrency](#workflow-syntax-reference-concurrency), [matrices](#job-syntax-matrix-strategies) |
{: class="responsive-table"}

<a id="how-workflows-run-on-buildkite-pipelines"></a>

## Important differences from GitHub Actions

Buildkite Pipelines reads workflow event declarations and creates one build per matching workflow. Workflow files remain in `.github/workflows/`; the server manages selection and preparation. This doesn't create a shadow GitHub Actions run.

| GitHub Actions concept | Buildkite Pipelines behavior |
| --- | --- |
| Trigger | Server-side matching of supported GitHub events, or a manual workflow selection |
| Workflow run | One Buildkite build per selected workflow |
| Job or matrix instance | Buildkite command job |
| `needs` | Dependencies with verified upstream results and outputs |
| Step | Runs within the job, sharing its workspace, environment files, state, and cleanup |
{: class="responsive-table"}

Check these differences before migrating:

- **Action access:** [Private actions](#actions-artifacts-and-caching-action-sources-and-runtimes) are unsupported, even inside private reusable workflows. An admitted public action can still depend on [unsupported GitHub services](#credentials-and-deployments-github-services).
- **Runner parity:** Labels select a platform, not GitHub image, toolchain, hardware, or Xcode parity. Supply tools through your [queue and image](#runners-and-tools).
- **Pull request checkout:** Workflows and [checkout](#actions-artifacts-and-caching-checkout-action) use the head commit, not GitHub's synthetic merge commit. Review events also use the head, not the reviewed commit.
- **Secrets and tokens:** GitHub secrets aren't copied. Migrate them to [Buildkite Secrets](#credentials-and-deployments-other-secrets-and-oidc). Public [GitHub workflow-token support](#credentials-and-deployments-github-token) requires eligible hosted jobs and the pipeline's token setting enabled; immutable top-level [permissions](#credentials-and-deployments-permissions) apply to every receiving job.
- **Cloud identity:** OIDC uses the [Buildkite issuer and claims](#credentials-and-deployments-other-secrets-and-oidc), not GitHub's. Update cloud trust before deploying.
- **Deployment approval:** [Environment gates](#credentials-and-deployments-deployment-environments) don't enforce GitHub reviewer lists, self-review restrictions, or administrator bypass. Any user who can unblock the pipeline can approve.
- **Cancellation:** Workflow [cancel-in-progress](#workflow-syntax-reference-concurrency) doesn't cancel superseded builds. Matrix `fail-fast` is accepted but has no cancellation effect.
- **Trigger coverage:** `pull_request_target` is intentionally unsupported. Pipeline triggers don't support `repository_dispatch`, `workflow_run`, `check_run`, or `check_suite`. Check [event delivery and filtering](#events-and-triggers), including accepted-but-ignored filters, rather than assuming every GitHub trigger runs.

<a id="validation"></a>

## Check your workflow

Check syntax, triggers, and the static graph without an event:

```bash
buildkite-gha validate .github/workflows/ci.yml
```

Apply the production profile with an exact event snapshot:

```bash
buildkite-gha validate \
  --profile hosted \
  --event-path .buildkite/events/current.json \
  .github/workflows/ci.yml
```

`--event` generates a minimal supported snapshot instead of reading `--event-path`; the options are mutually exclusive. `--all-events` checks every declared supported event separately. Generated snapshots don't cover every activity/payload and can't substitute for linked webhook/local-diff evidence.

| Result | Meaning |
| --- | --- |
| Compilable | Syntax, triggers, and static graph can be translated; not proof of hosted admission. |
| Not applicable | The selected event isn't declared; upload skips the workflow. |
| Admitted | Resolved actions and generated plans pass production policy; action code hasn't been executed. |
| Context required | Compilation/policy checks pass, but this input lacks evidence for admission, such as path-filter webhook data. |
{: class="responsive-table"}

Admission isn't execution, and a runtime release isn't proof of the version selected by a hosted build. Use the [CLI reference](/docs/pipelines/migration/run-github-actions-workflows/cli#validate-a-workflow) for representative snapshots and reports, and check the build's importer/runtime version when diagnosing differences.

## Runners and tools

Buildkite agent v3.129 or newer is required. Generated jobs support Linux x86-64, Linux arm64 with an explicit queue mapping, native macOS arm64, and Windows Server 2022 x86-64. Contact the Buildkite Support team for Linux arm64 mapping in native pipeline setup. Buildkite Pipelines manages workflow preparation on Linux x86-64 or macOS arm64; an advanced custom importer can also run on Linux arm64. Windows agents run generated jobs only.

### Queue selection and mappings

Native pipeline setup uses automatic runner resolution and doesn't expose custom mappings or generated-job cache volume configuration. Contact the Buildkite Support team if automatic resolution doesn't meet your requirements. Workflow-level caching is described under [Cache action](#actions-artifacts-and-caching-cache-action).

Advanced custom importers can use [explicit CLI mappings](/docs/pipelines/migration/run-github-actions-workflows/cli#upload-from-a-custom-importer-choose-runners-and-runtimes) to override automatic selection. They declare Linux x86-64 except for known Linux arm64 labels (`ubuntu-24.04-arm`, `ubuntu-22.04-arm`, and suffixes `-arm64` or `-aarch64`), known macOS labels, and Windows labels. Linux arm64 requires an explicit queue; arm64, macOS, and Windows mappings reject images. macOS x86-64 is unsupported.

During upload the job-scoped Agent API validates mapped queues in the importing cluster, including OS and architecture for hosted queues. Self-hosted validation checks existence only; operators must supply the declared platform. Mapped queue, image, and cache settings are preserved. Mapping validation must be acknowledged by a compatible backend or import fails.

Other selectors use the complete Agent API target and any fallback warnings. Eligible Linux queues can select native GitHub Actions images without a step image; immutable image targets remain supported elsewhere. Job `container.image` is separate from the host image. Labels don't provision queues or promise provider hardware, tools, caches, or networking.

| Runner rejection | Next step |
| --- | --- |
| `missing_queue` | Create the named hosted queue or configure a compatible mapping. |
| `incompatible_labels` | Correct unsupported labels; for Windows, also check eligibility and routing. |
| `no_cluster` | Use a cluster containing compatible queues. |
| `queue_not_found` | Correct the mapping to an active queue in the importing cluster. |
| `queue_platform_mismatch` | Map to a matching hosted OS and architecture. |
{: class="responsive-table"}

An explicit rejection doesn't fall back to presets. Without mappings, an unreachable API can warn and fall back to local presets: `ubuntu-latest`, `ubuntu-24.04`, `ubuntu-22.04`, and `macos-latest`. Linux presets use corresponding Noble or Jammy hosted-toolchains images; configured immutable images can override them. Offline `validate` and `compile` don't verify cluster queues. `validate --profile hosted` admits only these local presets.

An advanced custom importer's explicit mapping can attach one [hosted cache volume](/docs/agent/buildkite-hosted/cache-volumes), outside workflow syntax. Job containers and Windows jobs don't support these volumes.

<a id="runtime-behavior-and-limits-runner-tools"></a>

### Runner tools

Host tools come from the selected queue/image, not the label alone. macOS and Windows must provide shell tools and compatible native dependencies. Generated Linux jobs use a dedicated `runner` user. If you manage a custom execution environment, see the [runtime bootstrap requirements](/docs/pipelines/migration/run-github-actions-workflows/cli#upload-from-a-custom-importer-run-linux-jobs-as-a-non-root-user).

From v0.105.2, host shell, JavaScript, and composite steps inherit host `JAVA_HOME` when set. Explicit workflow/job/step values and `GITHUB_ENV`, including empty values, override it. This doesn't add `JAVA_HOME` to the expression `env` context, forward it to containers, select/install Java, or inherit version-specific or Java option variables such as `JAVA_TOOL_OPTIONS`.

Linux tool cache selection follows the runner target. Hosted cache requests use `/opt/hostedtoolcache`, which must exist; targets disabling it use a job-private cache without changing preinstalled host tools. Native Namespace targets use private caches. Older image targets without a cache choice retain their hosted-toolcache behavior. macOS bootstrap creates writable `/Users/runner/hostedtoolcache` and needs noninteractive `sudo`, preserving prefixes required by actions such as `ruby/setup-ruby`. Windows uses a job-private cache.

On native Namespace runners, the runtime enables `default-load=true` for stored single-node buildx builders using `remote`, `docker-container`, or `kubernetes`, so plain `docker build` loads the image for later `docker run`. Explicit `--push` or `--output` still controls output. Multi-node builders aren't changed and can still require explicit output/load choices. Setup problems warn rather than fail the job.

<a id="windows-jobs"></a>

### Windows jobs

`windows-latest` and `windows-2022` support Windows Server 2022 x86-64 through an explicit queue mapping or enabled Agent API routing. There is no local Windows preset or silent Linux fallback. The queue must provide PowerShell 7 (`pwsh`) and Git on `PATH`. [Buildkite hosted Windows access](/docs/agent/buildkite-hosted/windows) is separate from runtime support.

With Windows routing enabled, `windows-2025` and Depot `depot-windows-2025` labels, including `-4`, `-8`, `-16`, `-32`, and `-64`, can resolve through the Agent API to the same `windows-medium` queue. A warning explains that execution may use Server 2022 and doesn't preserve Depot hardware, caches, or networking. These aliases require an eligible existing hosted queue and Agent API resolution; they have no local preset or explicit Windows mapping. Native Server 2025 and Windows arm64 execution remain unsupported.

<a id="windows-jobs-runtime-boundaries"></a>

#### Runtime boundaries

Windows defaults to `pwsh`. Explicit `pwsh`, Windows PowerShell (`powershell`), [MSYS2 custom shells](#step-syntax-commands-and-actions), JavaScript actions, and composite actions are supported. `cmd`, containers, services, Docker actions, custom images, and cache volumes are unsupported.

Use UTF-8 for environment files. Windows PowerShell needs `Out-File -Encoding utf8 -Append`, not its default UTF-16 redirection. Environment names match case-insensitively, but the winning assignment's spelling is preserved. This includes the last assignment through `GITHUB_ENV`. Runtime identity variables remain protected from overrides.

<a id="windows-jobs-configure-a-windows-runner"></a>

#### Configure a Windows runner

For a native GitHub Actions pipeline, confirm hosted Windows Medium access and automatic routing availability with the Buildkite Support team at [support@buildkite.com](mailto:support@buildkite.com). The pipeline's cluster needs an active hosted Windows AMD64 **Medium** queue named `windows-medium`. A self-hosted, differently sized, wrong-platform, or other-cluster queue doesn't qualify.

Advanced custom importers can use [explicit CLI mappings](/docs/pipelines/migration/run-github-actions-workflows/cli#upload-from-a-custom-importer-choose-runners-and-runtimes) for `windows-latest` or `windows-2022`. These aren't part of native setup. The Agent API validates that the queue exists in the importing job's cluster and, for hosted queues, matches `windows/amd64`.

Runner resolution doesn't provision queues, grant access, or bypass trust policy. Isolate generated-job queues from protected credentials and previous jobs, including on self-hosted agents. Don't change a Windows-only job to Linux just to pass admission.

| Diagnostic | Next step |
| --- | --- |
| No Windows runner target is configured | Check hosted Windows access and routing with the Buildkite Support team. Offline validation has no Windows preset; this failure alone doesn't establish runtime incompatibility. |
| `missing_queue` | Check the importing cluster and hosted queue requirements, or map a compatible existing queue. |
| `no_cluster` | Move the pipeline to a cluster containing compatible queues. |
| Queue not found or platform mismatch | Correct the mapping to an active compatible queue in that cluster. |
| Incompatible labels | Check the requested variant. For `windows-latest` or `windows-2022`, also check hosted access and routing availability. |
| Windows variant has no local mapping | Use Agent API routing for the documented 2025 aliases, or select a 2022 label only if Server 2022 is suitable. |
{: class="responsive-table"}

For support, include the build or job URL, workflow path, `runs-on`, importer version, and complete diagnostic. A generic rejection alone doesn't identify an entitlement, queue, or runtime problem.

<a id="workflow-names-and-triggers"></a>

## Events and triggers

Buildkite Pipelines can match incoming GitHub events against workflow `on` declarations and create a build for each matching workflow. Alternatively, explicitly selected workflows run inside builds created by other Buildkite triggers, schedules, or manual requests. Event support differs between these routes. Start with the event table, then check delivery requirements, activity defaults, and filters. Event selection doesn't grant tokens or secrets.

Native manual runs currently require a matching `push` declaration without `workflow_dispatch`. If `workflow_dispatch` is declared, the server selects it, but the released runtime rejects it during preparation. See [Run a workflow manually](/docs/pipelines/migration/run-github-actions-workflows#add-a-github-actions-workflow-to-a-pipeline-run-a-workflow-manually) for the release boundary and supported alternatives. Compiler support for dispatch inputs doesn't establish native manual-run support.

| Event | Selection, defaults, and limits |
| --- | --- |
| `push` | `branches`, `branches-ignore`, `tags`, and `tags-ignore` select their ref kind. Include arrays support ordered negative patterns. Branch-push path filters require the [local-diff conditions](#events-and-triggers-push-path-filters). Tag pushes ignore path filters. |
| `pull_request` | Pipeline triggers [reject fork pull requests before creating a build](/docs/pipelines/migration/run-github-actions-workflows/security#fork-pull-requests). Branch filters match the base branch. Default activities are `opened`, `synchronize`, and `reopened`. Explicit supported activities are listed below. [Path filters](#events-and-triggers-pull-request-path-filters) require linked data and local history. Tag and workflow filters are rejected. Checkout uses the head commit, not the synthetic merge. |
| `merge_group` | Pipeline triggers require a compatible backend. Native builds require merge queue builds and **Merge groups** webhook delivery in pipeline GitHub settings. Branch filters match the base branch; default activity is `checks_requested`. Explicit `destroyed` is supported with the [qualification below](#events-and-triggers-merge-group-destruction). Path filters are ignored with a warning. Tag and workflow filters and unknown activities are rejected. |
| `release` | Pipeline triggers accept `published`, `unpublished`, `created`, `edited`, `deleted`, `prereleased`, and `released`, all by default. Native builds require **Additional Webhooks** > **Releases** and **Code** trigger mode and deliver only `published`, `created`, and `released`; other selections warn with `W_NATIVE_RELEASE_ACTIVITIES_UNDELIVERED`. Draft `created`, `edited`, `deleted`, and `unpublished` deliveries don't run. |
| `deployment`, `deployment_status` | Pipeline triggers with a compatible backend, or explicit snapshots. No activity types or other event filters. Statuses are `error`, `failure`, `in_progress`, `queued`, `pending`, `success`, and `waiting`; `inactive` doesn't run. Use conditions on payload environment or state, not trigger environment filters. No deployment creation or environment orchestration is added. |
| `create`, `delete` | [Branch and tag lifecycle](#events-and-triggers-branch-and-tag-lifecycle-events). No activity types or other filters. |
| `label` | [Repository label lifecycle](#events-and-triggers-repository-label-lifecycle-events). `created`, `edited`, and `deleted`, all by default. |
| `fork` | [Repository forks](#events-and-triggers-repository-fork-events). No nonempty activity types or other filters. |
| `public` | [Repository visibility](#events-and-triggers-repository-visibility-events). No nonempty activity types or other filters. |
| `gollum` | [Wiki pages](#events-and-triggers-wiki-page-events). No nonempty activity types or other filters. |
| `page_build` | [GitHub Pages builds](#events-and-triggers-github-pages-build-events). No nonempty activity types or other filters. |
| `watch` | [Repository stars](#events-and-triggers-repository-star-events). Only `started`, also the default. |
| `milestone` | [Milestone lifecycle](#events-and-triggers-milestone-lifecycle-events). `created`, `closed`, `opened`, `edited`, and `deleted`, all by default. |
| `branch_protection_rule` | [Branch protection rules](#events-and-triggers-branch-protection-rule-events). `created`, `edited`, and `deleted`, all by default. |
| `discussion`, `discussion_comment` | [Discussions and comments](#events-and-triggers-discussion-events). All listed activities by default. |
| `issues` | All GitHub Actions issue activities by default: `opened`, `edited`, `deleted`, `transferred`, `pinned`, `unpinned`, `closed`, `reopened`, `assigned`, `unassigned`, `labeled`, `unlabeled`, `locked`, `unlocked`, `milestoned`, `demilestoned`, `typed`, `untyped`, `field_added`, and `field_removed`. Explicit `types` selects a subset. |
| `issue_comment` | Issue and pull request conversation comments. `created`, `edited`, and `deleted`, all by default. Pipeline triggers don't inherit native command-word, trusted-commenter, or pull-request-only gating. |
| `pull_request_review` | Pipeline triggers support `submitted`, `edited`, and `dismissed`, all by default. `types` selects activities, not review states. For approval-only execution, use `if: github.event.review.state == 'approved'`. |
| `pull_request_review_comment` | Pipeline triggers support inline diff-comment `created`, `edited`, and `deleted`, all by default. Distinct from submitted reviews and conversation comments. |
| `workflow_dispatch` | Custom importers can select this event from an explicit snapshot or authoritative `GITHUB_EVENT_NAME` or `BUILDKITE_GITHUB_EVENT`. Native manual runs currently fail during preparation. Branch, tag, type, and workflow filters are unsupported. |
| `schedule` | Buildkite Pipelines owns cron configuration. Every `on.schedule` workflow is eligible for every scheduled build; the runtime can't identify which cron expression started it. |
| `workflow_call` | Reusable-workflow interface, not a top-level trigger for reusable-only files. |
| `pull_request_target` | Intentionally unsupported. Its privileged base-repository execution model requires a separate trust boundary. Switching to `pull_request` alone doesn't make untrusted checkout safe. |
| `repository_dispatch`, `workflow_run`, `check_run`, `check_suite` | Unsupported by pipeline triggers. Imported workflows don't create GitHub workflow runs or emit workflow-run events. Native builds on completed check runs are a separate integration. Consider Buildkite trigger steps for cross-pipeline orchestration. |
| Other events | Warn with `W_TRIGGER_EVENT_UNSUPPORTED` when mixed with supported events. Unsupported-only workflows fail event-independent validation and become skipped items on upload. |
{: class="responsive-table table--no-wrap responsive-table--single-column-rows"}

Explicit `pull_request` activities may be `assigned`, `unassigned`, `labeled`, `unlabeled`, `opened`, `edited`, `closed`, `reopened`, `synchronize`, `converted_to_draft`, `locked`, `unlocked`, `enqueued`, `dequeued`, `milestoned`, `demilestoned`, `ready_for_review`, `review_requested`, `review_request_removed`, `auto_merge_enabled`, or `auto_merge_disabled`.

Review events require v0.64.0 or later and don't support fork pull requests. Workflows and checkout use the head SHA, not the reviewed commit or synthetic merge commit; the ref remains `refs/pull/<number>/merge`. No default-branch-only requirement applies. Use payload head and base refs for branch conditions. CI-skip commit directives don't suppress review events. Same-repository reviews retain the pull request `contents: read` token ceiling, including approvals.

Release pipeline triggers require the GitHub Code Access App and use the peeled tag commit with `refs/tags/<tag_name>`. The tag, build, payload, and workflow identities must agree. Native builds without the App resolve the provided symbolic `HEAD` from checkout as a compatibility fallback. Deployment events use `deployment.sha` and its branch or tag ref. SHA-only deployments have empty Actions `ref` and `ref_name`, with workflow identity `<owner>/<repo>/<path>@<sha>`; no branch tip is substituted. Genuine deployment and status payload fields remain available in `github.event`.

<a id="workflow-names-and-triggers-merge-group-destruction"></a>

### Merge-group destruction

Explicit selection supports either or both activities:

```yaml
on:
  merge_group:
    types:
      - checks_requested
      - destroyed
    branches:
      - stable
```

Omitted, null, or empty `types` selects only `checks_requested`. The runtime doesn't restrict `destroyed` by `reason`. Pipeline trigger delivery requires a compatible backend and retained original payload; CLI acceptance alone doesn't establish hosted availability. Check backend availability with support if this event isn't delivered.

Both activities retain the speculative head ref, head SHA, and immutable workflow identity. Default checkout fetches the recorded SHA even after queue-ref deletion; it doesn't substitute the base branch. Execution still depends on GitHub retaining that object. Don't assume automatic-cancellation behavior matches GitHub for every destruction reason. Hosted merge-queue workflow-token requests remain denied, including for descendants; tokenless workflows can run.

The repository events in the following sections require a compatible pipeline trigger backend, original linked payload, and pinned workflow identity. Unless stated otherwise, workflow selection and checkout use the source repository's resolved default-branch commit. Explicit snapshots must supply that resolved `repository.default_branch`; the runtime doesn't resolve mutable refs. Missing, malformed, foreign, or contradictory identity fails, including on rebuilds. Existing webhooks may need an added event subscription. These events don't grant token or secret access.

<a id="workflow-names-and-triggers-repository-fork-events"></a>

### Repository fork events

`fork` runs for a fork of the source repository, never on the forkee's commit. The payload retains `github.event.forkee`. Explicit snapshots also need a full commit SHA. This doesn't enable fork pull requests or `pull_request_target`.

<a id="workflow-names-and-triggers-repository-visibility-events"></a>

### Repository visibility events

`public` runs when a private repository becomes public. The payload must identify the source repository, mark it public, and omit `action`.

<a id="workflow-names-and-triggers-wiki-page-events"></a>

### Wiki page events

`gollum` requires a nonempty `pages` array with valid names, actions, and wiki commit SHAs. Page data remains in `github.event.pages`; execution doesn't use a wiki commit or add a wiki checkout.

<a id="workflow-names-and-triggers-github-pages-build-events"></a>

### GitHub Pages build events

`page_build` requires the Pages build ID, commit, and status. Failed builds can trigger workflows. `github.event.build` retains status and error data. Execution doesn't use the Pages build commit or deploy Pages.

<a id="workflow-names-and-triggers-repository-star-events"></a>

### Repository star events

`watch` selects stars (`started`), not notification subscriptions. Removing a star doesn't trigger workflows. The payload remains available through `github.event`.

<a id="workflow-names-and-triggers-milestone-lifecycle-events"></a>

### Milestone lifecycle events

`milestone` selects the activities in the event table, not issue or pull request milestone assignment. Milestone data remains in `github.event.milestone`.

<a id="workflow-names-and-triggers-branch-protection-rule-events"></a>

### Branch protection rule events

`branch_protection_rule` requires a positive rule ID, a name, and a `repository_id` matching the source repository. Execution doesn't use the rule's branch pattern. Rule data remains in `github.event.rule`.

<a id="workflow-names-and-triggers-discussion-events"></a>

### Discussion events

`discussion` supports `created`, `edited`, `deleted`, `transferred`, `pinned`, `unpinned`, `labeled`, `unlabeled`, `locked`, `unlocked`, `category_changed`, `answered`, `unanswered`, `closed`, and `reopened`. `discussion_comment` supports `created`, `edited`, and `deleted`.

The payload needs a discussion ID, number, and title; comments need a positive ID and matching `discussion_id`. There is no command-word or trusted-commenter gating. Transfers produce separate source `transferred` and destination `created` events; each uses that repository's default branch. Original discussion and comment data are retained. GitHub lists these webhooks as public preview.

<a id="workflow-names-and-triggers-repository-label-lifecycle-events"></a>

### Repository label lifecycle events

`label` selects repository label creation, editing, or deletion, not issue or pull request `labeled` actions. Label data remains in `github.event.label`.

<a id="workflow-names-and-triggers-branch-and-tag-lifecycle-events"></a>

### Branch and tag lifecycle events

`create` and `delete` refer to Git refs, not repository creation or deletion. GitHub doesn't deliver them when more than three tags are created or deleted at once.

`create` uses the created ref's resolved commit, peeled for annotated tags. `delete` uses the resolved default branch, never the deleted ref; the deleted name remains in `github.event.ref`, while `github.ref` names the default branch. Explicit snapshots need a full SHA and matching repository identity.

<a id="workflow-names-and-triggers-ignored-event-filters-and-native-evidence"></a>
<a id="workflow-names-and-triggers-ignored-event-filters"></a>

### Ignored event filters

Except for `push`, `pull_request`, `merge_group`, `workflow_dispatch`, and `schedule`, the webhook events listed above accept but ignore `branches`, `branches-ignore`, `tags`, `tags-ignore`, `paths`, and `paths-ignore`. These filters don't protect execution or credentials. Activity selection and identity checks still apply. Unknown keys and unsupported activities are rejected. `pull_request` and `merge_group` tag filters remain unsupported.

Pipeline trigger `issues` and `issue_comment` builds select the latest verified default-branch SHA without native Buildkite issue/comment build gating, branch filters, or path filters. Native issue builds remain supported with linked payloads and their own build-creation settings.

<a id="workflow-names-and-triggers-activity-defaults-and-native-evidence"></a>
<a id="workflow-names-and-triggers-activity-defaults"></a>

### Activity defaults

Scalar or array event declarations, null event configuration, and empty event maps select the defaults in the event table. Where activity selection is supported, omitted `types`, literal `types: null`, and an empty `types` array also select those defaults. A nonempty string or array selects its exact supported activities. Null normalization for `issues`, `issue_comment`, `label`, `release`, both review events, `pull_request`, and `merge_group` requires v0.90.0 or later and a compatible backend.

Defaults aren't all activities: pull requests exclude `edited` and `closed`; merge groups exclude `destroyed`. Quoted `'null'`, arrays containing null, malformed types, and unknown activities are rejected. This doesn't admit activity filters on events that reject them, such as `push`, `create`, `delete`, or deployment events. `fork`, `public`, `gollum`, and `page_build` accept null or empty types but reject nonempty types.

<a id="workflow-names-and-triggers-push-path-filters"></a>

### Push path filters

Branch-push `paths` and `paths-ignore` require linked GitHub webhook data, complete non-shallow local history, and checkout and workflow content matching the pushed commit. The webhook repository, ref, commit range, force state, and complete commit set must match the build. `origin` must match the repository, but its current branch tip may have advanced.

Normal and force pushes compare `before..after`. A new branch uses the parent of the oldest pushed commit only when the complete pushed set has one clear single-parent boundary. Added, modified, deleted, and type-changed paths can match. Ordered positive and negative patterns apply as for pull requests.

A new branch with an explicitly empty webhook `commits` array has no changed paths. Workflows with `paths` or `paths-ignore` are skipped; workflows without path filters remain eligible. This does not apply to missing commit data or force pushes.

Unsupported cases fail rather than guessing whether to run:

- Deleted refs, non-GitHub sources, missing or shallow history, or mismatched identities
- Incomplete pushed-commit data, ambiguous new-branch history, or more than 1,000 pushed commits
- More than 3,000 changed files or 2 MiB of Git changed-path output
- Renames, diffs containing both additions and deletions, invalid patterns, or malformed Git output
- Explicit or generated snapshots and environment fallbacks instead of linked webhook data

A verified nonmatch produces a skipped workflow without running its jobs. Tag pushes ignore path filters. GitHub's run-anyway fallback for more than 1,000 commits or diff timeouts isn't reproduced.

| Diagnostic detail | Next step |
| --- | --- |
| Requires linked webhook data | Use a GitHub push build with the original payload, not a manual build or snapshot. |
| Requires complete non-shallow checkout | Check `git rev-parse --is-shallow-repository` in the importer. Ask the agent administrator to fetch full history there if shallow. Workflow checkout runs too late to fix filtering. |
| Requires complete pushed commits, before commit unavailable, or rename-conformance restriction | Contact support with the build URL and full diagnostic. Workflow checkout settings can't supply missing webhook data or remove compatibility limits. |
| More than 1,000 commits or 3,000 files | Split the push or diff into smaller changes. |
{: class="responsive-table"}

If a checkout isn't shallow or the history check fails unexpectedly, contact support. Removing a path filter changes which workflows run; it isn't a repair for missing evidence.

<a id="workflow-names-and-triggers-pull-request-path-filters"></a>

### Pull request path filters

Ordered GitHub patterns can include and then exclude paths:

```yaml
on:
  pull_request:
    paths:
      - "src/**"
      - "!src/generated/**"
```

The importer compares pinned base and head commits using `base...head`. Linked data must include full SHAs with one common merge base verified as an ancestor of both. Checkout and workflow content must match the head. Evaluation uses existing Git access, not GitHub API requests or Buildkite `if_changed`, and doesn't depend on `merge_commit_sha` or `mergeable`. Conflicting and closed pull requests retain these rules. Workflows without path filters don't require diff history.

Matching added, modified, deleted, or type-changed paths and copied destinations are supported. Renames, combined additions and deletions, shallow or missing history, multiple merge bases, unrelated history, identity mismatches, backslashes in paths or patterns, invalid patterns, malformed Git output, more than 3,000 changed files, and more than 2 MiB of Git changed-path output are rejected. The limits don't promise GitHub's file ordering or diff-timeout fallback.

An empty diff or verified nonmatch skips the workflow. An unsupported or inexact filter fails only the affected workflow and never broadens execution. Fetch missing history in the importer; reduce an oversized diff or remove the filter only if its broader execution is acceptable. Identity failures remain errors even when another filter excludes the workflow. Once identity is verified, branch or activity exclusions don't require diff history.

Workflows that don't declare the event skip before event-dependent compilation. A declared event can retain a workflow group even if its branch, tag, base-branch, or activity condition later excludes execution. If every directly runnable workflow excludes the event, upload succeeds with a skipped-only pipeline.

### Event identity and fallback

The effective event comes from, in order:

1. An explicit `--event-path` snapshot.
1. The event name attached to linked Buildkite webhook data.
1. The Buildkite environment fallback.

The fallback prefers `GITHUB_EVENT_NAME`. It preserves `push`, `pull_request`, `workflow_dispatch`, and `schedule` from `BUILDKITE_GITHUB_EVENT`; preserving `issues` or `issue_comment` also requires complete pipeline trigger workflow identity. Otherwise pull request builds use `pull_request`, scheduled builds use `schedule`, and all other sources, including `ui`, `api`, and `trigger_job`, use `push`. The fallback can't infer merge-group, release, issue, or comment payloads.

Explicit snapshots don't consult contradictory live event fields. Pipeline trigger events require matching repository, workflow path, immutable ref and SHA, and event-specific identity. Review, release, deployment, merge-group, and default-branch repository events require the original linked payload; rebuilds without it fail rather than inventing an event. A payload or workflow mismatch also fails. These checks don't grant tokens or secrets.

### Workflow names

`name` supplies workflow labels and `github.workflow`. `run-name` accepts compile-time `github`, `inputs`, and repository or organization `vars` expressions. A nonempty result changes only the workflow group label, not check identity, the importer label, or the build message:

```yaml
name: Deploy
run-name: Deploy ${{ inputs.target || 'default' }} by @${{ github.actor }}
on:
  workflow_dispatch:
    inputs:
      target:
        type: string
        default: staging
```

Omitted or blank run names keep the static label. On non-dispatch events, declared dispatch inputs use typed zero values, not dispatch defaults. Missing properties in a known input set are empty; needs-derived inputs remain unresolved until available. Skipped workflows don't synthesize dispatch inputs.

<a id="actions"></a>

## Actions, artifacts, and caching

Action admission doesn't guarantee that arbitrary code inside an action can use every GitHub service. Source, runtime, input, and service limits all apply. Start with action behavior and restrictions below; each native adapter's release inventory follows its usage details.

<a id="actions-action-sources-and-runtimes"></a>

### Action sources and runtimes

| Action type | Support |
| --- | --- |
| Local `./...` | Source and workflow content verified at execution. |
| Public `owner/repo[/path]@ref` | Resolved to an exact commit and source digest. |
| Private action | Unsupported, including within a private reusable workflow. |
| JavaScript | `node16`, `node20`, or `node24`, with pre/main/post, inputs, outputs, state, and LIFO posts. |
| Composite | Supported shell steps and locked local/public children; literal `continue-on-error`. |
| Docker | Verified Dockerfile or public prebuilt-image metadata on Linux only. |
| Workflow `uses: docker://...` | Unsupported. |
| Top-level action metadata `env` | Accepted, no effect. Not evaluated or injected and grants no credentials. Other unknown metadata fields remain errors. |
{: class="responsive-table"}

Public refs lock during upload. Anonymous source access can use a shared importer action-source token for public metadata outside the credential repository; codeload and credential-repository requests remain anonymous. Unavailable token issuance falls back to anonymous access. Exact lowercase commit pins need no API ref lookup. Rate limits can delay new lookups; cached refs and exact pins remain usable. Runtime verifies complete action trees.

Local composites can call only local children. Public composites can call local children or other public actions. Every child is locked, with nested local action depth limited to ten.

Local actions must exist when compiled, not be created by an earlier checkout, download, or command. Runtime local action and workflow bytes must match the compiled source; checking out an older workflow can fail even if the action is unchanged. Use a pinned public action or a verified self-repository reference when appropriate.

Managed Node 16.20.2 runs `node16` with an end-of-job deprecation warning. `node20` and `node24` both run managed Node 24.18.0. Other declarations are rejected.

JavaScript `pre-if` and `post-if` accept listed condition functions, including `hashFiles()`, direct workflow inputs, environment, GitHub fields, service context, matrix, runner, steps, and event-rooted dynamic access. `job.status` requires v0.103.0. Other whole/dynamic contexts are errors. Empty lifecycle conditions always run without an implicit success guard. Preparation hooks use preparation-time status/environment; posts use final status/environment, including `GITHUB_ENV`, and root posts see final workflow step state. Nested composites retain isolated steps. Posts run LIFO, and cancellation stays distinct from failure.

Prebuilt images are declared in action metadata:

```yaml
name: Check formatting
inputs:
  path:
    default: .
runs:
  using: docker
  image: docker://ghcr.io/example/formatter@sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
  entrypoint: /usr/local/bin/formatter
  args:
    - ${{ inputs.path }}
```
{: codeblock-file="action.yml"}

Images pull anonymously without ambient Docker credentials. Private images are unsupported. Mutable tags can drift between jobs; use digests. Dockerfile actions require exact `runs.image: Dockerfile` and can't declare an explicit entrypoint. Prebuilt actions may override entrypoint.

`runs.args` is an ordered string array with literals or action-input expressions and pure functions. Each item remains one literal argument without shell evaluation. Omitted/empty args preserve image `CMD`; nonempty args replace it while retaining `ENTRYPOINT`. Other contexts, credentials, status functions, and `hashFiles()` are rejected even in unreachable branches. Docker actions can't declare lifecycle hooks, credentials, volumes, arbitrary Docker options, or privileged mode. An argument named `--privileged` doesn't become a Docker option.

<a id="step-syntax-self-repository-actions"></a>

### Self-repository actions

`uses: $/.github/actions/build` loads the action from the repository and exact commit containing the workflow without requiring checkout. `$/` selects the repository root. Inside a remote composite it means that action's repository and commit, not the caller's. Ordinary `./` actions remain checkout-relative.

Self references require verification that local workflow bytes match the same path at the event commit; modified source fails, and neither Git `HEAD` nor workspace contents substitute for identity. Remote reusable workflows provide their own pinned identity. Synthetic `validate --event` has no source identity; use an exact `--event-path` snapshot. Self paths can't contain traversal, backslashes, or `@ref`. Private reusable access doesn't authorize private self actions.

Nested self actions in a remote composite retain its requested `github.action_ref`. Direct workflow or local-composite self calls expose the containing workflow commit instead. `GITHUB_ACTION_REF` isn't populated; pass the context through `env` when needed. Self actions retain ordinary action depth, capability, and access limits.

<a id="actions-repository-archive-symlinks"></a>

### Repository archive symlinks

Extraction omits relative symlinks targeting extracted regular files or directories within the repository. It never creates or follows aliases. An action requiring an alias path is unsupported; unused tooling or fixture aliases can be omitted. This intentionally differs from GitHub runner extraction/copy behavior.

Dangling links, chains, absolute or escaping targets, hardlinks, special files, duplicate/case-colliding paths, and aliases that are ancestors of other entries remain rejected. Size, entry, and path limits include omitted aliases.

<a id="actions-checkout-action"></a>

### Checkout action

`actions/checkout` uses a native adapter, not upstream JavaScript. Checkout remains detached at the workspace root or a fresh nested directory in the event repository. Alternate checkout repositories, GitHub Enterprise Server, persisted credentials, and existing-directory reuse are unsupported. See [checkout security](/docs/pipelines/migration/run-github-actions-workflows/security#checkout-and-submodules).

Inputs must exist in the selected commit's contract before the following restrictions apply:

| Input | Supported values |
| --- | --- |
| `repository` | Omitted or the event `owner/repo`. |
| `ref` | Omitted/empty, lowercase 40-hex commit, or static branch in the event repository. Direct `github.sha` or needs-output expressions must resolve to the exact event SHA. Tags and other dynamic commits are unsupported. |
| `token` | Omitted only. |
| `ssh-key`, `ssh-known-hosts` | Omitted or empty. |
| `ssh-strict`, `set-safe-directory` | Omitted or `true`. |
| `ssh-user` | Omitted or `git`. |
| `persist-credentials`, `allow-unsafe-pr-checkout` | Omitted or `false`. |
| `path` | Omitted/empty or a clean workspace-relative directory without `.git` segments or symlink-parent traversal. |
| `clean` | Omitted, `true`, or `false`; root workspace must be empty or nested target absent. Existing-directory reuse is unsupported even with `false`. |
| `filter` | Omitted/empty or one partial-clone filter without controls. |
| `sparse-checkout` | Omitted/empty or at most 1,000 nonempty patterns totaling 1 MiB. |
| `sparse-checkout-cone-mode`, `fetch-tags`, `show-progress` | Omitted, `true`, or `false`. |
| `fetch-depth` | Omitted or nonnegative integer; zero means full history. Historical runner-plugin commits default to full history. |
| `lfs` | Omitted, `true`, or `false`; true requires installed Git LFS. |
| `submodules` | Omitted, `false`, `true`, or `recursive`, trimmed and case-insensitive. |
| `github-server-url` | Omitted/empty or `https://github.com`. |
{: class="responsive-table"}

Authorized repository-provider Git credentials are scoped to fetch, LFS, and submodule commands and never persisted; otherwise access is anonymous. Statically false job conditions can bypass checkout input restrictions, but step/runtime conditions don't hide invalid adapter inputs.

Submodules use native Git depth and relative URLs: true selects direct children, recursive selects nested children. Public/private GitHub submodules use job-authorized access. External HTTPS is anonymous; `git@github.com:` rewrites to HTTPS. Other SSH and non-HTTPS transports are unsupported.

Sparse checkout defaults to `blob:none` unless a filter is explicit. Cone mode selects directories; non-cone mode uses Git ignore patterns. LFS installs repository-local filters without push/locking hooks and downloads selected materialized paths.

```yaml
steps:
  - uses: actions/checkout@v7
    with:
      path: sources/application
      filter: blob:limit=1m
      fetch-depth: 20
      show-progress: false
  - uses: actions/checkout@v7
    with:
      path: sources/docs
      sparse-checkout: |
        docs
        schemas
```

#### Checkout release contracts

Frozen historical release/development commits across v1–v7 retain their exact declared inputs, outputs, and history defaults. These principal releases are supported:

| Release | Immutable commit |
| --- | --- |
| v1.2.0 | [`50fbc622fc4ef5163becd7fab6573eac35f8462e`](https://github.com/actions/checkout/tree/50fbc622fc4ef5163becd7fab6573eac35f8462e) |
| v2.8.0 | [`0717577d45739eb3c851188b29f50ed6c0b2194e`](https://github.com/actions/checkout/tree/0717577d45739eb3c851188b29f50ed6c0b2194e) |
| v3.7.0 | [`a37ce9120846195fa4ece8f58b268e6043cb2f26`](https://github.com/actions/checkout/tree/a37ce9120846195fa4ece8f58b268e6043cb2f26) |
| v4 | [`11d5960a326750d5838078e36cf38b85af677262`](https://github.com/actions/checkout/tree/11d5960a326750d5838078e36cf38b85af677262) |
| v5 | [`fbc6f3992d24b796d5a048ff273f7fcc4a7b6c09`](https://github.com/actions/checkout/tree/fbc6f3992d24b796d5a048ff273f7fcc4a7b6c09) |
| v6 | [`d23441a48e516b6c34aea4fa41551a30e30af803`](https://github.com/actions/checkout/tree/d23441a48e516b6c34aea4fa41551a30e30af803) |
| v7.0.0 snapshot pin | [`9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0`](https://github.com/actions/checkout/tree/9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0) |
| v7.0.1 | [`3d3c42e5aac5ba805825da76410c181273ba90b1`](https://github.com/actions/checkout/tree/3d3c42e5aac5ba805825da76410c181273ba90b1) |
{: class="responsive-table"}

Other valid resolved immutable commits use the stable v7.0.1 contract and emit `W_CHECKOUT_UNKNOWN_COMMIT_FALLBACK`. That contract can differ from the requested upstream manifest; pin a listed commit for a known contract. Known historical commits never use fallback. Snapshots refresh with runtime releases. v1.2.0 and v2.8.0 warn with `W_CHECKOUT_LEGACY_RELEASE`; v1 fetches full history by default and neither exposes `ref` or `commit` outputs. Those outputs require a declaring contract, introduced upstream in v4.2.0; fallback exposes both.

<a id="actions-upload-artifact-action"></a>

### Upload artifact action

`actions/upload-artifact` uses a native ZIP adapter. Frozen historical commits retain declared inputs/outputs, hidden-file defaults, and v1 path behavior.

| Input | Supported values when declared by the contract |
| --- | --- |
| `name` | Required by v1; later contracts default to `artifact`. |
| `path` | Required. v1 accepts one literal file/directory; later contracts accept literals and bounded `*`, `?`, character classes, and `**` globs. |
| `if-no-files-found` | `warn`, `error`, or `ignore`. v1 fails on a missing literal and uploads an existing empty directory. |
| `retention-days` | Nonnegative integer; advisory only. |
| `compression-level` | Zero through nine. |
| `overwrite` | Omitted or `false`. |
| `include-hidden-files` | GitHub Actions Boolean; default false. Earlier contracts without the input retain hidden paths. |
| `archive` | Omitted or `true`. |
{: class="responsive-table"}

Native jobs accept workspace-relative or absolute platform paths, including Windows drives. Absolute globs archive relative to their literal search root; multiple selections use their least common ancestor. Job-container uploads require workspace-relative paths, even if an absolute container path would exist. Host jobs with services retain native path support.

At most 32 path roots, 10,000 files per artifact, and 64 artifacts per job are supported. Source and ZIP bytes have no separate runtime limit; agent/storage limits apply. Exclusions, symlinks, traversal, UNC and drive-relative paths, alternate data streams, braces, extglobs, leading glob comments, special files, and cross-volume Windows selections are unsupported. Hidden segments are excluded unless enabled by the selected contract.

`artifact-id` and `artifact-digest` exist only when declared by the contract; early versions can omit later inputs/outputs. `artifact-url` is empty because there is no GitHub run URL. Merge, raw upload, overwrite, and effective retention control are unsupported. Downloads verify archive size, digest, members, and filesystem safety before extraction, without a separate fixed expansion-byte policy.

#### Upload artifact release contracts

Principal releases are:

| Release | Immutable commit |
| --- | --- |
| v1.0.0 | [`3446296876d12d4e3a0f3145a3c87e67bf0a16b5`](https://github.com/actions/upload-artifact/tree/3446296876d12d4e3a0f3145a3c87e67bf0a16b5) |
| v2.3.1 | [`82c141cc518b40d92cc801eee768e7aafc9c2fa2`](https://github.com/actions/upload-artifact/tree/82c141cc518b40d92cc801eee768e7aafc9c2fa2) |
| v3.2.1 | [`ff15f0306b3f739f7b6fd43fb5d26cd321bd4de5`](https://github.com/actions/upload-artifact/tree/ff15f0306b3f739f7b6fd43fb5d26cd321bd4de5) |
| v4.6.0 | [`65c4c4a1ddee5b72f698fdd19549f0f0fb45cf08`](https://github.com/actions/upload-artifact/tree/65c4c4a1ddee5b72f698fdd19549f0f0fb45cf08) |
| v4.6.2 | [`ea165f8d65b6e75b540449e92b4886f43607fa02`](https://github.com/actions/upload-artifact/tree/ea165f8d65b6e75b540449e92b4886f43607fa02) |
| v5.0.0 | [`330a01c490aca151604b8cf639adc76d48f6c5d4`](https://github.com/actions/upload-artifact/tree/330a01c490aca151604b8cf639adc76d48f6c5d4) |
| v6.0.0 | [`b7c566a772e6b6bfb58ed0dc250532a479d7789f`](https://github.com/actions/upload-artifact/tree/b7c566a772e6b6bfb58ed0dc250532a479d7789f) |
| v7.0.1 | [`043fb46d1a93c77aae656e7c1c64a875d1fc6a0a`](https://github.com/actions/upload-artifact/tree/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a) |
{: class="responsive-table"}

Unknown valid resolved commits use stable v7.0.1 with `W_UPLOAD_ARTIFACT_UNKNOWN_COMMIT_FALLBACK`; the manifest can differ from upstream, but adapter limits don't widen and upstream JavaScript doesn't run. Malformed commits are rejected. Principal v1–v3 versions warn with `W_UPLOAD_ARTIFACT_LEGACY_RELEASE`. v3.2.2 and v3.2.2-node20 remain unsupported GitHub Enterprise Server-only backports. Snapshot refreshes follow runtime updates.

<a id="actions-download-artifact-action"></a>

### Download artifact action

`actions/download-artifact` uses producer-bound native ZIP downloads. Artifacts must come from verified direct `needs` producers and the supported upload adapter.

| Input | Supported values |
| --- | --- |
| `name` | Exact unique name, mutually exclusive with `pattern`; runtime expressions allowed. |
| `pattern` | Bounded name glob with required `merge-multiple: true`; runtime expressions allowed. |
| `path` | Optional literal workspace-relative destination. |
| `merge-multiple` | Omitted/false with `name`; true with `pattern`. |
| v8 `skip-decompress` | Omitted or false. |
| v8 `digest-mismatch` | Omitted or `error`. |
{: class="responsive-table"}

Patterns can select at most 64 distinct names using `*`, `?`, character classes, `**`, or one leading nonnested alternation of two through eight literal prefixes with a glob suffix, such as `{backend,product}-*`. Other brace expansion is unsupported. Case-insensitive duplicate artifact names are rejected.

All selected archives together may contain at most 10,000 files. Every archive is validated and staged before the destination changes. Exact member-path collisions are resolved deterministically: the later artifact by name wins. Digest or ZIP failure is fatal. `download-path` is supported. Artifact-ID, all-artifact, cross-run/repository, raw, REST, and non-merged pattern modes are unsupported.

#### Download artifact release contracts

These root action revisions use the adapter:

| Release | Immutable commit |
| --- | --- |
| v4.3.0 | [`d3f86a106a0bac45b974a628896c90dbdf5c8093`](https://github.com/actions/download-artifact/tree/d3f86a106a0bac45b974a628896c90dbdf5c8093) |
| v5.0.0 | [`634f93cb2916e3fdff6788551b99b062d0335ce0`](https://github.com/actions/download-artifact/tree/634f93cb2916e3fdff6788551b99b062d0335ce0) |
| v6.0.0 | [`018cc2cf5baa6db3ef3c5f8a56943fffe632ef53`](https://github.com/actions/download-artifact/tree/018cc2cf5baa6db3ef3c5f8a56943fffe632ef53) |
| v7.0.0 | [`37930b1c2abaa49bbe596cd826c3c89aef350131`](https://github.com/actions/download-artifact/tree/37930b1c2abaa49bbe596cd826c3c89aef350131) |
| v8.0.0 | [`70fc10c6e5e1ce46ad2ea6f2b72d43f7d47b13c3`](https://github.com/actions/download-artifact/tree/70fc10c6e5e1ce46ad2ea6f2b72d43f7d47b13c3) |
| v8.0.1 | [`3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c`](https://github.com/actions/download-artifact/tree/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c) |
{: class="responsive-table"}

Unknown lowercase 40-hex resolved commits use stable v8.0.1 with `W_DOWNLOAD_ARTIFACT_UNKNOWN_COMMIT_FALLBACK`. The fallback can differ from upstream inputs but doesn't widen adapter limits. Malformed commits are unsupported.

<a id="actions-cache-action"></a>

### Cache action

`actions/cache`, `/restore`, and `/save` run admitted stock cache-v2 JavaScript clients against the Buildkite Results service. Root restore/post-save and separate entry points are supported, with tar and zstd-or-gzip versioning.

Workflow/job `cache-mode` supports the following best-effort client behavior; jobs override workflow values. Reusable calls and workflows declaring `workflow_call` don't support this key.

| Mode | Restore | Save |
| --- | --- | --- |
| `read` | Allowed | Skipped |
| `write` | Allowed | Allowed |
| `write-only` | Skipped | Allowed |
| `none` | Skipped | Skipped |
{: class="responsive-table"}

The effective value overrides action/workflow `ACTIONS_CACHE_MODE` in JavaScript lifecycle invocations, not Docker actions. Omission preserves client behavior; there is no trigger-based default. Clients must honor the variable: the known [6.2.0 client bundle](https://github.com/actions/cache/commit/3edfce9056124e459a23f683a21433670d47daca) does, while listed v6.1.0 and older clients ignore it. Skipped restores are misses and can still fail with `fail-on-cache-miss: true`.

> 🚧 Cache mode isn't authorization
> Cache mode doesn't change cache-token issuance or provenance-based server authorization. Clients or direct requests that ignore it remain governed by the server, not the requested mode.

Compatible JavaScript and Docker actions can receive job-bound cache credentials when available; ordinary shell steps and native adapters don't. Root `actions/setup-node`, `setup-java`, `setup-python`, `setup-go`, and `setup-dotnet` invocations can receive a subprocess-only synthetic `GITHUB_SERVER_URL` to select cache v2. Workflow expressions retain the real provider URL. This is a repository-level allowlist, not a guarantee that every accepted revision or bundled dependency has been individually audited.

Windows cache tools use a restricted path containing Git's `usr\bin` and zstd under Program Files, then System32. Install Git for Windows and zstd there for GNU tar/zstd. From v0.105.3, the runtime also accepts `tools\zstd\zstd.exe` on the system volume only for the official [zstd 1.5.7 Windows x64](https://github.com/facebook/zstd/releases/tag/v1.5.7) binary with SHA-256 `8076aae03feac7c66b319579e82172eed168deed2a3f25e5e2d3c60f55e84111`. Each lifecycle invocation uses a temporary verified copy, not that writable directory or its siblings. No download/install occurs; missing or different bytes don't add the tool.

Without admitted zstd, clients use gzip; without Git tar, they can use System32 tar. Cross-OS archives require GNU tar and zstd, but cross-OS or cross-worker persistence isn't guaranteed by this reference. Compression changes can cause one-time misses. Workflow paths, `GITHUB_PATH`, and package-manager shims don't select these tools. Keep Program Files outside workflow write access. Tool selection isn't a sandbox against administrators or processes sharing the runner account and doesn't enable Windows cache volumes.

#### Cache release contracts

Known compatible historical development/release snapshots include these releases:

| Major | Principal admitted releases | Exact recommended pin |
| --- | --- | --- |
| v3 | [3.4.0](https://github.com/actions/cache/tree/f4b3439a656ba812b8cb417d2d49f9c810103092), [3.4.2](https://github.com/actions/cache/tree/387e18722e6ff315b24a3b8b071feddd27b7bf7e), [3.4.3](https://github.com/actions/cache/tree/2f8e54208210a422b2efd51efaa6bd6d7ca8920f), [3.5.0](https://github.com/actions/cache/tree/6f8efc29b200d32929f49075959781ed54ec270c) | [`6f8efc29b200d32929f49075959781ed54ec270c`](https://github.com/actions/cache/tree/6f8efc29b200d32929f49075959781ed54ec270c) (v3.5.0) |
| v4 | [4.2.0](https://github.com/actions/cache/tree/1bd1e32a3bdc45362d1e726936510720a7c30a57), [4.2.1](https://github.com/actions/cache/tree/0c907a75c2c80ebcb7f088228285e798b750cf8f), [4.2.2](https://github.com/actions/cache/tree/d4323d4df104b026a6aa633fdb11d772146be0bf), [4.2.3](https://github.com/actions/cache/tree/5a3ec84eff668545956fd18022155c47e93e2684), [4.2.4](https://github.com/actions/cache/tree/0400d5f644dc74513175e3cd8d07132dd4860809), [4.3.0](https://github.com/actions/cache/tree/0057852bfaa89a56745cba8c7296529d2fc39830) | [`0057852bfaa89a56745cba8c7296529d2fc39830`](https://github.com/actions/cache/tree/0057852bfaa89a56745cba8c7296529d2fc39830) (v4.3.0) |
| v5 | [5.0.0](https://github.com/actions/cache/tree/a7833574556fa59680c1b7cb190c1735db73ebf0), [5.0.1](https://github.com/actions/cache/tree/9255dc7a253b0ccc959486e2bca901246202afeb), [5.0.2](https://github.com/actions/cache/tree/8b402f58fbc84540c8b491a91e594a4576fec3d7), [5.0.3](https://github.com/actions/cache/tree/cdf6c1fa76f9f475f3d7449005a359c84ca0f306), [5.0.4](https://github.com/actions/cache/tree/668228422ae6a00e4ad889ee87cd7109ec5666a7), [5.0.5](https://github.com/actions/cache/tree/27d5ce7f107fe9357f9df03efb73ab90386fccae), [5.1.0](https://github.com/actions/cache/tree/caa296126883cff596d87d8935842f9db880ef25) | [`caa296126883cff596d87d8935842f9db880ef25`](https://github.com/actions/cache/tree/caa296126883cff596d87d8935842f9db880ef25) (v5.1.0) |
| v6 | [6.0.0](https://github.com/actions/cache/tree/2c8a9bd7457de244a408f35966fab2fb45fda9c8), [6.1.0](https://github.com/actions/cache/tree/55cc8345863c7cc4c66a329aec7e433d2d1c52a9) | [`55cc8345863c7cc4c66a329aec7e433d2d1c52a9`](https://github.com/actions/cache/tree/55cc8345863c7cc4c66a329aec7e433d2d1c52a9) (v6.1.0) |
{: class="responsive-table"}

Versions before v3.4.0/v4.2.0 use unsupported cache-v1 clients. Withdrawn [v3.4.1](https://github.com/actions/cache/releases/tag/v3.4.1) is excluded because upstream published it with an incorrect SHA. v3 uses managed Node 16 with a deprecation warning; Node 20 declarations use Node 24.

Unknown resolved cache commits don't run directly. Compilation substitutes the newest principal release for the requested admitted major, or v6.1.0 for an unrecognized major, branch, or bare commit. For example, `v5.2.0` substitutes v5.1.0. `W_CACHE_UNKNOWN_COMMIT_SUBSTITUTED` names both commits and a pin to remove the warning. The substitute must resolve to its recorded commit or compilation fails. This includes floating refs, pre-v2 clients, withdrawn versions, and unknown exact pins. Pin a listed commit to avoid substitution. Snapshot refreshes follow runtime releases.

<a id="repositories-credentials-and-github-services"></a>

## Credentials and deployments

Repository access, workflow tokens, ordinary secrets, cache credentials, and OIDC are separate boundaries. An event payload or repository file doesn't grant authority. Check each boundary and the deployment protection differences before running trusted workflows.

<a id="repositories-credentials-and-github-services-repositories"></a>

### Repositories

Public GitHub event repositories are supported. Private GitHub repositories require authorized repository-provider Git credentials, available to jobs on Buildkite hosted agents. Internal/private Origin repositories require those credentials and the exact pipeline `BUILDKITE_REPO` URL `https://origin.cursor.com/git/<namespace>/<repository>.git`. GitHub Enterprise Server and unlisted providers are unsupported.

Alternate checkout repositories and private actions are unsupported. Approved private reusable sources are importer-only; see [reusable access](#workflow-syntax-reference-reusable-workflows). Public actions remain subject to their source and runtime limits.

<a id="repositories-credentials-and-github-services-github-token"></a>

### GitHub token

A job requests one short-lived event-repository token when it statically references `secrets.GITHUB_TOKEN`, workflow-authored `github.token`, or an effective action input default that can reach `github.token` for that provider. A provider guard can exclude GitHub token use for Origin. Native adapters ignore upstream defaults, so checkout alone doesn't request it. Tokens aren't automatically placed in the initial environment.

Public support is limited to running command jobs on [Buildkite hosted agents](/docs/agent/buildkite-hosted) in `github.com` pipelines using the full-access **GitHub** repository provider. The pipeline's **Allow workflow-authorized GitHub access tokens** setting must be enabled. Existing pipelines default off; pipelines created with GitHub Actions setup mode default on.

The immutable top-level workflow must be a simple `.yml` or `.yaml` directly under `.github/workflows/`. Its [permission policy](#credentials-and-deployments-permissions) applies to every receiving job, including reusable jobs. Pull requests and their triggered/rebuilt descendants have a `contents: read` ceiling. Merge queues and descendants can't request workflow tokens. Backend provenance checks remain authoritative.

```yaml
permissions:
  contents: read
jobs:
  inspect:
    runs-on: ubuntu-latest
    steps:
      - env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: gh api repos/{owner}/{repo}
```

Follow the actual rejection diagnostic. A disabled-setting error links to the pipeline repository setting. From v0.104.0 with a compatible backend, known denial reasons identify who can act; older servers retain generic guidance. Permission or App-access errors can require checking top-level permissions and the Buildkite GitHub App's repository access; these checks aren't a universal fix for provenance, policy, rate-limit, or service failures. For an unexplained rejection, send support the diagnostic and build URL.

From v0.102.1, acquisition retries Agent API 503 responses and 429 responses with valid `Retry-After`, at most three attempts in 45 seconds with 15-second attempt limits. Cancellation and earlier job deadlines apply. Delays use one- and two-second bases plus bounded jitter, respecting `Retry-After` seconds or dates without exceeding the remaining budget. Other statuses, transport failures, and invalid success responses aren't retried. Action-source requests and checkout don't use this retry policy. Every attempt remains authorized and counts against the server's request limit.

> 🚧 Use write tokens only with trusted code
> Job binding doesn't prove an arbitrary commit is trusted. Restrict who can create builds and enable write access only when eligible branch builds run trusted code. Pull request and merge-queue restrictions don't replace that policy.

<a id="workflow-syntax-permissions"></a>

### Permissions

Repository permissions apply when a job references a [workflow token](#credentials-and-deployments-github-token), including an effective action input default that reaches `github.token`. Declaring permissions alone doesn't request a token.

```yaml
permissions:
  contents: read
  pull-requests: write
```

Supported repository names are `actions`, `artifact-metadata`, `attestations`, `checks`, `contents`, `deployments`, `discussions`, `issues`, `packages`, `pages`, `pull-requests`, `security-events`, and `statuses`, with `read`, `write`, or `none`. The separate `id-token` permission controls OIDC.

| Top-level declaration | Token scope |
| --- | --- |
| Omitted | Exactly `contents: read`; GitHub repository and organization defaults aren't inherited. |
| Explicit map | Requested supported permissions. Write access requires this form. |
| `read-all` | CLI expansion to read access for the supported repository names above, excluding `id-token`, `models`, `repository-projects`, `code-quality`, `metadata`, and `vulnerability-alerts`. |
| Empty map or all `none` | No token. A job that requests one fails compilation rather than receiving an empty token. |
| `write-all` | Accepted by the compiler but rejected for hosted token issuance. |
{: class="responsive-table"}

Every receiving job uses the immutable top-level requesting workflow's repository policy. Job maps and called-workflow maps can't narrow or expand it; compilation warns about differences or ineffective narrowing. You can't give individual jobs different repository scopes. The separate `id-token` policy retains job-level behavior and called-workflow narrowing.

<a id="repositories-credentials-and-github-services-other-secrets-and-oidc"></a>

### Other secrets and OIDC

Direct jobs support static `${{ secrets.NAME }}`. Local reusable calls can [inherit or map names](#workflow-syntax-reference-reusable-workflows). Runtime retrieves destination-job Buildkite secrets and registers redaction before use. Missing or denied secrets fail without printing values or the agent error; diagnostics distinguish migration/access issues from temporary service failures. See [Migrate GitHub Actions secrets](/docs/pipelines/migration/github-actions-secrets).

These aren't GitHub repository, environment, event, or fork-scoped secrets. [Buildkite secret access policies](/docs/pipelines/security/secrets/buildkite-secrets/access-policies) authorize the destination job, whose code can also call `buildkite-agent secret get`. Environment-prefixed names remain ordinary Buildkite secrets. `GITHUB_TOKEN` is separate and can't be replaced with an ordinary secret.

Dynamic, whole-context, filtered, or projected secret access; conditions/compile-time secret use; and remote secret forwarding are unsupported. Explicit reusable mappings must be direct secret references, not literals or values derived through other contexts. Action metadata can't add secret authority; a secret used only by an optional action input is empty unless another field requires it.

`id-token: write` exposes `getIDToken()` to host JavaScript actions, including composite children. It returns a [Buildkite OIDC token](/docs/pipelines/security/oidc) for the requested audience, not GitHub issuer/claims. `read`, `none`, or omission doesn't expose the endpoint. Cloud trust configuration must use the Buildkite issuer and claims. See [AWS setup](/docs/pipelines/migration/run-github-actions-workflows#supported-functionality-and-limitations-use-oidc-with-aws).

Tokens use the default Buildkite claims and subject without plugin configuration. Native pipeline setup doesn't expose custom claims, AWS session tags, or subject overrides. Contact the Buildkite Support team for custom OIDC requirements. Configuration doesn't grant `id-token: write`.

Endpoint variables are lifecycle-invocation scoped: shell steps, Docker actions, and actions inside job containers don't receive them. Container `getIDToken()` fails with a missing-endpoint diagnostic.

<a id="job-syntax-deployment-environments"></a>

### Deployment environments

Literal environment names are supported on top-level workflow jobs, with optional `url`. Expression names and reusable-workflow job environments are rejected. Inside a Buildkite job, `upload` and `compile` resolve GitHub.com protection rules, secret names, and variables through the job-scoped Agent API. Only configuration and names reach the importer, not GitHub credentials or secret values. The pipeline repository is the only source.

Resolution fails closed, including outside a Buildkite job or on GitHub Enterprise Server. One upload batches distinct environments, at most 20 per request, subject to backend per-job and per-installation hourly budgets. Backend rejection fails compilation; there is no unprotected fallback or user-supplied GitHub token option.

| Environment feature | Behavior |
| --- | --- |
| Required reviewers | One block step per workflow/environment. Any user who can unblock the pipeline can approve; GitHub reviewer lists, `prevent_self_review`, and administrator bypass aren't enforced. |
| Secret names | Environment-defined names resolve to prefixed Buildkite secrets as described below. Other names remain unchanged. |
| Variables | Available in runtime fields, not job conditions or compile-time fields; see [variable scopes](#job-syntax-repository-and-organization-variables). |
| Wait timers, deployment branch policies, custom protection rules | Rejected during compilation. |
| `environment.url`, GitHub deployments and statuses | Accepted, no effect; no deployment records are created. |
{: class="responsive-table"}

Environment `production` secret `DEPLOY_KEY` uses Buildkite secret `PRODUCTION_DEPLOY_KEY`. Uppercase the environment name, replace characters outside `A-Z`, `0-9`, and `_` with `_`, and prefix `_` when it starts with a digit. For example, `1st` produces `_1ST_DEPLOY_KEY`. Compilation rejects keys over 255 characters or beginning with `BK` or `BUILDKITE`, and distinct environments that produce the same prefix. Rename the environment or secret to remove the conflict. Environment names that differ only in case identify the same environment. Buildkite secret access policies govern values.

Approval gates use running block state so unrelated jobs continue. A gate appears even if its job condition later skips. Matrix instances share one gate. Gated jobs can't be retried manually; create a new build for fresh approval. Configuration changes apply at the next compile. Buildkite OIDC tokens don't add a GitHub `environment` claim.

<a id="repositories-credentials-and-github-services-github-services"></a>

### GitHub services

No general GitHub Packages, Releases, Checks, deployments, or GitHub artifact API emulation is provided beyond the integrations above. An admitted action can still fail if it requires an unsupported service.

<a id="workflow-syntax"></a>

## Workflow syntax reference

The following sections cover workflow-level configuration, then [jobs](#job-syntax), [steps](#step-syntax), and [expressions and contexts](#expressions-and-contexts). Repository [permissions](#credentials-and-deployments-permissions) and [cache mode](#actions-artifacts-and-caching-cache-action) are described with their credential and action behavior.

<a id="workflow-syntax-reusable-workflows"></a>

### Reusable workflows

Calls support local `./.github/workflows/...` files, verified self-repository `$/.github/workflows/...` files, and literal public or approved private `owner/repository/.github/workflows/file.yml@ref` references. Remote files must be `.yml` or `.yaml` directly under `.github/workflows`. References resolve to a pinned commit for the operation; nested local paths stay in that repository. Dynamic paths are unsupported. Nesting is limited to four levels.

Private source access is separate from workflow-token permission and disabled by default in native GitHub Actions pipelines. Contact the Buildkite Support team before relying on private reusable workflows. Advanced custom importers can enable it with the [CLI upload option](/docs/pipelines/migration/run-github-actions-workflows/cli#upload-from-a-custom-importer-select-workflows).

When enabled, access covers the pipeline repository and cross-repository sources available to the importer's existing Git credentials. Repository-provider credential access is approved per repository. Git access can also resolve public sources after anonymous API limits. Missing and denied repositories, refs, and paths use the same error. Private reusable access doesn't enable private actions or forward importer credentials into jobs. Access is repository-wide, not workflow-path scoped; restrict importer credentials to approved repositories. See [reusable-source credential boundaries](/docs/pipelines/migration/run-github-actions-workflows/security#repository-data-does-not-grant-authority).

| Interface | Supported behavior |
| --- | --- |
| Inputs | `boolean`, `number`, and `string`; static caller values and supported compile-time expressions. Defaults are literals or compile-time `github` and `vars` expressions, not references to `inputs`. |
| Needs-derived string inputs | Direct declared `needs.<job>.outputs.<name>` references, templates, or pure expressions whose other parts resolve before execution, including `github`, `vars`, matrix, and static parent inputs. Runtime-only values such as `github.run_id` can't be mixed in. |
| Needs-derived Boolean or number inputs | One expression returning the declared type, such as `fromJSON(needs.detect.outputs.count)` or `needs.detect.outputs.deps == 'true'`. A raw output string isn't a Boolean or number. |
| Nested deferred input forwarding | Exactly `${{ inputs.name }}` with the same declared type. Combining it with other text is unsupported. |
| Outputs | Direct mappings from `jobs.<job>.outputs.<name>`. Literal or compound output expressions are unsupported. |
| Call matrix | Static matrices, including composition with static callee matrices. Dynamic call matrices are unsupported. |
| Secrets | Repository-local inheritance or explicit mappings as described below. Public and private remote forwarding is unsupported. |
| Call result | Aggregate result visible to the caller. |
{: class="responsive-table"}

Every needs-derived input must name a declared direct dependency. `needs.<job>.result` and whole output objects aren't supported as input values. A call's scheduling dependencies don't appear in the callee's `needs` context: called jobs see only their own declared dependencies.

```yaml
on:
  workflow_call:
    inputs:
      target:
        type: string
        required: true
    outputs:
      image:
        value: ${{ jobs.build.outputs.image }}
jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      image: ${{ steps.image.outputs.value }}
    steps:
      - id: image
        run: echo "value=app-${{ inputs.target }}" >> "$GITHUB_OUTPUT"
```
{: codeblock-file=".github/workflows/build.yml"}

```yaml
jobs:
  prepare:
    runs-on: ubuntu-latest
    outputs:
      target: ${{ steps.target.outputs.value }}
    steps:
      - id: target
        run: echo 'value=production' >> "$GITHUB_OUTPUT"
  call:
    needs: prepare
    uses: ./.github/workflows/build.yml
    with:
      target: ${{ needs.prepare.outputs.target }}
```

Calls support `if` over caller `github`, `inputs`, `vars`, direct `needs`, and status functions, with the implicit success guard. Conditions run before call-matrix expansion and can't use `matrix`, `strategy`, callee contexts, `steps`, `env`, `runner`, or `secrets`. False calls skip all descendants, including jobs with `always()`, and expose `skipped` and empty outputs. Nested conditions apply outer to inner; callee results don't change an outer condition. An implicit success check doesn't require unambiguous matrix output values.

Local calls can use `secrets: inherit` or map declared aliases to one direct `${{ secrets.NAME }}` or `${{ secrets['NAME'] }}` reference. Required aliases need a mapping; unmapped optional aliases are empty. Every nested edge must explicitly inherit or map again. Omission removes ordinary secret access below that edge; it doesn't affect direct caller jobs or `GITHUB_TOKEN`. Nested mappings retain the original Buildkite secret name, and a missing mapping can't recover a same-named secret. Literal, compound, dynamic, and non-secret mapping values are unsupported.

Verified `$/` calls within the root repository retain local secret-forwarding scope through nested `$/` and `./` calls. Explicit `owner/repository/...@ref` calls leave that scope, even when they name the same repository and commit; nested calls can't restore it. `${{ secrets.GITHUB_TOKEN }}` can map to a declared alias but remains a workflow token, not an ordinary secret.

<a id="workflow-syntax-environment-and-defaults"></a>

### Environment and defaults

Workflow, job, and step `env` maps use most-specific-wins precedence. Individual values support [field-specific expressions](#expressions-and-contexts-runtime-interpolation); an entire map can't be expression-valued. Workflow and job `defaults.run.shell` and `defaults.run.working-directory` set run defaults, subject to shell and path restrictions. Windows defaults to `pwsh`, other host jobs to `bash`, and job containers to `sh`.

```yaml
env:
  GOFLAGS: -mod=readonly
defaults:
  run:
    shell: bash
    working-directory: ./src
jobs:
  test:
    runs-on: ubuntu-latest
    env:
      GOFLAGS: -race
    steps:
      - run: go test ./...
```

<a id="workflow-syntax-concurrency"></a>

### Concurrency

Static groups become repository-scoped, case-insensitive Buildkite Pipelines concurrency groups. They support compile-time `github`, `vars`, static reusable inputs, supported operators and pure functions, and job-level concrete `matrix` and `strategy` values. Ordinary runtime `needs` groups are unsupported; [matrix-producer scheduling](#job-syntax-scheduling-from-matrix-producer-outputs) is a bounded exception.

From v0.106.0, workflow-level concurrency during hosted upload also accepts `github.run_id`, such as `group: codeql-${{ github.run_id }}`. This uses the owning Buildkite build ID: repeated imports in one build share a group, and different builds get different groups. Offline validation and compilation need a Buildkite build identity. This doesn't admit run identity in other compile-time fields, or admit `github.run_number` or `github.run_attempt` in concurrency.

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: ${{ startsWith(github.ref, 'refs/pull/') }}
```

Buildkite Pipelines queues every waiting entry rather than replacing GitHub's pending entry. `queue` is unsupported. Workflow-level `cancel-in-progress: true`, including a true expression, warns and leaves superseded builds running. Job-level `cancel-in-progress` is unsupported.

Called workflows retain workflow-level concurrency around all their jobs, including static call-matrix instances and nested calls. Jobs inside a call remain parallel except for their own dependencies and job groups. Reusing an enclosing workflow group in a job or nested call is unsupported.

Calls with `needs` require prerequisites with no concurrency or provably disjoint groups. Shared or unresolved groups and cycles involving dependencies and ordered queues are rejected, including transitive and matrix prerequisites. This check covers the generated pipeline, not other pipelines or later manual uploads.

The call's gate waits for all external prerequisites, including failed and skipped ones, but reserves its queue position at upload, earlier than GitHub. Later calls can wait behind unfinished prerequisites; `W_REUSABLE_WORKFLOW_CONCURRENCY_QUEUED_BEFORE_PREREQUISITES` reports this difference. A statically false call omits its gate. A runtime-dependent call still enters and holds the group until its jobs finish, even if it skips; `W_REUSABLE_WORKFLOW_CONCURRENCY_ENTERED_BEFORE_CALL_CONDITION` reports this behavior.

Workflow concurrency can't enclose or depend on deferred expansion as described under [matrices from outputs](#job-syntax-matrices-from-job-outputs). Cancel the whole build, not an individual job, when a workflow gate is active.

Leave [Cancel Intermediate Builds](/docs/pipelines/configure/canceling-builds#cancel-running-intermediate-builds) and **Skip Intermediate Builds** disabled for server-side dispatch. These settings work by branch, not workflow concurrency group, and can cancel or skip sibling workflow builds from the same event.

## Job syntax

Jobs support static dependencies, outputs, runner selection, matrices, configuration variables, environments, and Linux containers within the following limits.

### Job configuration

| Key | Supported behavior |
| --- | --- |
| `name` | Static `github`, reusable inputs, and concrete matrix and scalar strategy values. |
| `needs` | One static job ID or an array. Matrix fan-out and fan-in are automatic. |
| `runs-on` | Accepted label or label array, including concrete matrix/strategy values or the bounded [output-derived form](#job-syntax-runners-from-job-outputs). Labels match case-insensitively. |
| `if` | Evaluated before the job starts; see [conditions](#expressions-and-contexts-conditions). |
| `outputs` | [Output expressions](#expressions-and-contexts-runtime-interpolation) for downstream `needs`. Ambiguous matrix values fail rather than selecting a winner. See [size limits](#limits-and-troubleshooting-key-limits). |
| `env`, `defaults.run` | [Normal precedence and field-specific expressions](#workflow-syntax-reference-environment-and-defaults). |
| `timeout-minutes` | Literal number, at most 360. Expressions are rejected. |
| `continue-on-error` | Boolean literal or Boolean-valued expression. Tolerated failures remain visible as soft failures but report downstream success. |
| `environment` | Literal top-level-job environment, resolved during compilation. |
| `snapshot` | Accepted, no effect. Custom image creation isn't implemented. |
{: class="responsive-table"}

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      image: ${{ steps.image.outputs.value }}
    steps:
      - id: image
        run: echo 'value=app:latest' >> "$GITHUB_OUTPUT"
  deploy:
    needs: build
    if: github.ref == 'refs/heads/main' && success()
    runs-on: ubuntu-latest
    steps:
      - env:
          IMAGE: ${{ needs.build.outputs.image }}
        run: echo "$IMAGE"
```

Results and outputs come from verified producer results. Retrying one producer can make selection ambiguous; retry the whole build. A tolerated job failure stops ordinary steps, runs eligible failure/always steps and post-actions, publishes outputs, and reports `success` through `needs`. It soft-fails with reserved exit status `78`. Whole-job timeout remains `cancelled` and isn't tolerated.

See [queue selection and mappings](#runners-and-tools-queue-selection-and-mappings) for runner setup and [deployment environments](#credentials-and-deployments-deployment-environments) for protection rules, approvals, and secret naming.

### Runners from job outputs

A non-matrix job can select a runner from one declared output of a prerequisite with exactly one static instance:

```yaml
jobs:
  plan:
    runs-on: ubuntu-latest
    outputs:
      runner: ${{ steps.select.outputs.runner }}
    steps:
      - id: select
        run: echo 'runner=["ubuntu-22.04"]' >> "$GITHUB_OUTPUT"
  build:
    needs: plan
    runs-on: ${{ fromJSON(needs.plan.outputs.runner) }}
    steps:
      - run: echo ready
```

A direct output can supply one label. Templates, label arrays, and supported pure functions also work, but every reference, even in an unselected branch, must name that same producer output. A reusable string input can forward the value unchanged without adding the producer to the callee's `needs` context.

The deferred `runs-on` step waits for the producer and uploads the consumer and its transitive dependants. `W_RUNS_ON_DEFERRED` identifies this behavior. The output is limited to 1 KiB and supplies scheduling data only: normal runner mapping, platform, admission, and credential rules still apply. Missing outputs, invalid label types, or rejected targets fail before those jobs upload.

The [deferred matrix rules](#job-syntax-matrices-from-job-outputs) also govern committed source, snapshots, graph budgets, retries, and skipped producers. Independent runner and matrix components can coexist, but a component with dynamic runner selection can't join or start another deferred stage. Its consumer can't also have a matrix. Root workflow concurrency, or called-workflow concurrency enclosing or depending on deferred work, is unsupported. This doesn't enable dynamic environments or general output-derived concurrency.

Use `validate` or `compile --format ir-json` to inspect the graph; `compile --format pipeline` can't emit it. See [deferred upload setup](/docs/pipelines/migration/run-github-actions-workflows/cli#upload-from-a-custom-importer-expand-a-matrix-inside-the-build).

### Repository and organization variables

`${{ vars.NAME }}` reads configuration, not secrets. Within a Buildkite job, applicable workflows, reusable calls, and action input defaults that reference `vars` trigger one repository/organization lookup per upload. Providers other than GitHub.com don't make that request. The backend uses its own repository-restricted credentials.

| Position | Precedence |
| --- | --- |
| Job and reusable-call `if` | Repository over organization; no environment scope. Check environment values in a step condition. |
| Job `env`, run defaults, outputs, service `env` and credentials, step fields, action input defaults | Environment over repository over organization. |
| Compile-time `run-name`, runners, strategy, concurrency, job names, container images, reusable inputs | Repository over organization; environment names remain literal. |
{: class="responsive-table"}

These are the runtime's supported scopes; don't assume environment values affect pre-job selection. Names match case-insensitively. Missing names are empty strings, including in compile-time fallbacks. Dynamic indexing, projections, and `toJSON(vars)` use the same scope. Matrix instances share their job's scope; reusable jobs don't have environment scope.

The lookup accepts at most 500 repository and 1,000 organization names, 48 KiB per value, and 256 KiB combined. Rate limits, including ten requests per job per hour, and outages fail workflows using `vars`; other workflows can still upload. `E_VARIABLE_RESOLUTION` retains specific backend errors and any retry delay. A generic resolution error needs support investigation, not an assumed installation or permission fix.

A missing endpoint or organization opt-out returns empty scopes on 404. Outside a Buildkite job, runtime references are empty and compile-time references fail for lack of a source. This differs from declared environments, which fail closed.

```yaml
jobs:
  deploy:
    runs-on: ${{ vars.RUNNER || 'ubuntu-latest' }}
    if: vars.DEPLOY_ENABLED == 'true'
    environment: production
    env:
      AWS_REGION: ${{ vars.AWS_REGION }}
    steps:
      - if: vars.TIER == 'gold'
        run: echo "$AWS_REGION"
```

Variables don't reduce token or secret requests: conditions using `vars` remain runtime decisions. Values are stored in job artifacts and printed by `compile --format ir-json`. Compile-time uses can also appear in labels, pipeline YAML, or runner diagnostics. Don't store credentials in variables. See [variable visibility](/docs/pipelines/migration/run-github-actions-workflows/security#credential-boundaries-variables).

### Matrix strategies

Static matrices support `include`, `exclude`, and definitions derived from compile-time `github`, event data, reusable inputs, and `fromJSON`. Whole dimensions and include/exclude arrays must resolve during compilation, except for the bounded output-derived forms below. A job can expand to 256 instances.

```yaml
strategy:
  max-parallel: 2
  matrix:
    go:
      - "1.25"
      - "1.26"
    os:
      - ubuntu-22.04
      - ubuntu-24.04
    exclude:
      - go: "1.25"
        os: ubuntu-24.04
```

Ordinary job matrices accept literal `max-parallel`; [matrix-producer outputs](#job-syntax-scheduling-from-matrix-producer-outputs) provide a limited dynamic form. Call matrices with multiple instances can't use `max-parallel`, because invocation-level parallelism can't be preserved. Static call and callee matrices compose, including nested calls.

`fail-fast` is accepted but has no cancellation effect. Scalar `strategy` properties report `job-index` (zero-based final expansion order), `job-total`, configured `fail-fast` (default `true`), and `max-parallel` (default final row count). A non-matrix job uses index zero, total one, and parallel limit one. Reporting `fail-fast: true` doesn't enable it.

### Matrices from job outputs

Exactly `fromJSON(needs.<job>.outputs.<name>)` can supply a whole matrix or its whole `include` array after a prerequisite runs:

```yaml
jobs:
  plan:
    runs-on: ubuntu-latest
    outputs:
      matrix: ${{ steps.plan.outputs.matrix }}
    steps:
      - id: plan
        run: echo 'matrix=[{"target":"amd64","runner":"ubuntu-latest"}]' >> "$GITHUB_OUTPUT"
  build:
    needs: plan
    runs-on: ${{ matrix.runner }}
    strategy:
      matrix:
        include: ${{ fromJSON(needs.plan.outputs.matrix) }}
    steps:
      - run: ./build "${{ matrix.target }}"
  publish:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: ./publish
```

Upload creates the producer and a deferred `\:github\: matrix · build` step. After the producer succeeds, that step expands and uploads the matrix and its downstream jobs. `W_MATRIX_DEFERRED` explains the delay. `validate` and `compile --format ir-json` show the graph; pipeline-format compilation can't render deferred uploads. Expanded jobs use ordinary matrix labels, checks, dependencies, runner admission, and credential restrictions.

Independent components expand separately. Components with shared downstream jobs merge so each job uploads once; sharing only a producer doesn't merge them. Matrices can chain when a later producer is itself deferred. Each stage uploads jobs whose rows are known and waits for later producers before adding later stages. Prerequisites outside the deferred downstream graph remain in the initial upload.

The following limits apply to every stage:

- The producer has exactly one instance and a declared output. It must run on Linux or macOS because its queue also runs the deferred importer. Expanded jobs may use enabled Windows targets.
- Matrix JSON is at most 64 KiB from v0.102.3. Each nonempty row has at most 64 properties containing strings, finite numbers, or booleans. Strings are at most 1 KiB. Null, nested arrays/objects, ambiguous keys, duplicate instances, zero rows, malformed JSON, and missing outputs fail the deferred step.
- The 256-instance and 1,024-expanded-job limits still apply. Deferred components share the remaining workflow budget equally after upfront jobs; chained stages consume that same component budget. Exceeding a share fails before upload, even if another component hasn't used its share.
- The workflow must be tracked inside the repository and match the build commit. Outside, untracked, staged-only, or modified workflow source can't use deferred expansion.
- Deferred execution uses the original event, variable snapshot, runner mappings, OIDC settings, workflow source, reusable source commits, and locked action revisions. Changed sources or incompatible graph changes fail with instructions to retry the build. Outputs never become workflow source or credential authority.
- Root workflow concurrency is unsupported. A called workflow with workflow concurrency can't contain a deferred matrix or depend on deferred work; its gate would close before later jobs finish.
- Generated job, placeholder, continuation, and approval-gate keys must remain unique. Collisions fail before execution. Protected environment jobs retain their shared approval gate through deferred uploads.
- A failed, skipped, or cancelled producer skips its downstream placeholders, including `always()` dependants whose matrix is unknown. Healthy branches in a merged component still expand; shared joins skip. Earlier completed stages remain unchanged. Missing or invalid producer results are errors, not skips.
- Any compilation error fails the whole deferred workflow rather than uploading only its static jobs. Other workflows in an aggregate upload can continue.
- Retrying a deferred step verifies its previous upload and doesn't duplicate jobs. Retrying a producer after expansion invalidates the earlier result, even if the new output is identical. Retry the whole build instead.

Matrices derived from `steps`, compound needs expressions, or other dynamic sources remain unsupported. See [deferred upload setup](/docs/pipelines/migration/run-github-actions-workflows/cli#upload-from-a-custom-importer-expand-a-matrix-inside-the-build) for importer and runtime requirements.

### Scheduling from matrix-producer outputs

A real output-derived matrix can use other declared outputs of its same ordinary single-instance producer for scheduling:

```yaml
jobs:
  build:
    needs: plan
    runs-on: ubuntu-latest
    strategy:
      max-parallel: ${{ fromJSON(needs.plan.outputs.parallel) }}
      matrix:
        include: ${{ fromJSON(needs.plan.outputs.matrix) }}
    steps:
      - run: ./build "${{ matrix.target }}"
```

`parallel` must be a JSON integer from 1 through 256. The limit applies to this matrix in this build. Alternatively, `concurrency: ${{ needs.plan.outputs.group }}` supplies a nonempty repository-scoped, case-insensitive group. Templates and pure functions may use that producer's direct output references, but no other expression contexts. All instances in a group run one at a time; `max-parallel` can't raise that limit. See the complete [parallelism](https://github.com/buildkite/buildkite-gha/blob/main/testdata/scheduling/.github/workflows/parallel.yml) and [group](https://github.com/buildkite/buildkite-gha/blob/main/testdata/scheduling/.github/workflows/group.yml) examples.

The deferred step waits for every upfront workflow job, not only the producer, and holds no concurrency slot. This avoids deadlocks in ordered queues. Missing, ambiguous, or invalid scheduling outputs fail expansion.

This subset requires one matrix and one expansion stage in the component: no joins, chains, projected reusable outputs, or other producers. Static matrices, non-matrix jobs, downstream jobs, and reusable calls can't use it. Independent components without dynamic scheduling keep their ordinary join/chain support. Workflow concurrency, including called-workflow gates anywhere in the workflow, remains unsupported. Cancellation and retry behavior doesn't change.

### Containers and services

Linux supports job containers and services. macOS and Windows reject containers, services, Docker actions, and Docker capability. Job-container images must provide `sh` and run the mounted self-contained Linux runtime. Runner-mapped cache volumes can't be used with job containers.

```yaml
services:
  postgres:
    image: postgres:16
    env:
      POSTGRES_PASSWORD: test
    ports:
      - 5432
    options: >-
      --health-cmd pg_isready
      --health-interval 2s
      --health-timeout 5s
      --health-retries 10
```

Job containers accept `image`, `env`, `ports`, `volumes`, and `options`. Services also accept `credentials`, `command`, and `entrypoint`.

| Field | Expressions and behavior |
| --- | --- |
| Job image | Compile-time `github`, inputs, scalar strategy, matrix, and scoped compile-time variables. Null or exactly empty evaluated images select the host without container `env` or ports. Literal empty or whitespace-only images are invalid. Secrets, needs, step outputs, and whole/dynamic contexts aren't supported. |
| Service fields | Compile-time contexts and runtime `needs` outputs, including image fallbacks. Empty evaluated images omit the service. |
| Service `env` | Job environment, scoped runtime variables, needs outputs, and named secrets, including combined pure expressions. Evaluated after job `env`, before standard step variables; sibling service entries aren't visible. |
| Whole service map | A non-credential map can use `fromJSON` with needs-output expressions and pure functions. Credentials must remain declared statically. |
| Credentials | `github`, runtime `vars`, named secrets, job `env`, needs, known matrix, scalar strategy, and compile-known named inputs. Dynamic secret names and direct `github.token` are rejected; authorized `secrets.GITHUB_TOKEN` is the supported token spelling. |
{: class="responsive-table"}

From v0.104.1, credentials support named `inputs.name` or `inputs['name']` when known during compilation, including typed dispatch values/defaults and static reusable inputs. Computed, whole-context, unknown, and deferred input references are rejected, even in unreachable branches. `${{ secrets[inputs.name] }}` remains unsupported even for a known input: use a static secret name. Needs-derived reusable inputs can instead flow through job `env`, with credentials reading that environment value. Input values derived from variables keep their compile-time snapshot; direct credential `vars` uses runtime scope.

Service startup doesn't support `runner`, `job`, step outputs, or `hashFiles()`. Named secrets stay required and redacted even in unused fallback branches. Unsupported references fail even in unreachable branches. Credentials use a private per-job Docker configuration, never ambient Docker credentials; passwords go to `docker login` on standard input. Implicit GHCR authentication isn't supported. Mutable image tags resolve at job start; use a digest for immutability.

Container environment names start with a letter or underscore and otherwise contain letters, digits, underscores, or dots, such as `discovery.type`. Service IDs are at most 255 ASCII characters, start with a lowercase letter or underscore, and otherwise contain lowercase letters, digits, underscores, hyphens, or dots. Dotted IDs remain distinct from hyphenated IDs; index them with brackets, for example `${{ job.services['s3.docker.test'].ports[6379] }}`.

Each job uses a private Docker bridge. Container jobs address services by name; host jobs use published ports, with dynamic host ports when omitted. `job.services.<id>` exposes `id`, `network`, and `ports`. Health-checked services must become healthy before steps start; others must start. Startup failures include bounded status, health, port, and log diagnostics.

| Container setting | Limit or restriction |
| --- | --- |
| Job volumes | `DESTINATION` for anonymous volumes or `SOURCE:DESTINATION[:ro\|rw]`; absolute destination, and Docker volume name or absolute host source. At most 128 unique declarations; no expressions. |
| Job options | Passed to `docker create`, except `--network`, `--net`, and `--entrypoint`, including equals forms. No expressions, line breaks, NUL, or more than 65,536 bytes. Double quotes group arguments; single quotes are literal. No shell evaluation. |
| Service options | Passed through except network overrides. May grant privileges, mount host paths, publish ports, or alter resources. |
| Services per job | 32 |
| Service environment | 256 entries per service |
| Service ports or volumes | 128 each per service; named, anonymous, and absolute bind volumes supported. |
{: class="responsive-table"}

Cleanup emits bounded masked logs and removes job containers, services, networks, private Docker configuration, and attributable volumes. Pre-existing named volumes remain. Job volumes created with custom drivers, or named only through `options`, can remain when ownership is ambiguous; unrelated volumes aren't deleted to recover them. Remaining owned resources fail the job. Docker isn't a security or resource-isolation boundary: [isolate the whole job](/docs/pipelines/migration/run-github-actions-workflows/security#isolate-the-whole-job) and enforce host CPU, memory, disk, and network limits.

## Step syntax

Steps support commands, supported actions, conditions, environments, and bounded background work.

### Step configuration

| Key | Supported behavior |
| --- | --- |
| `name`, `id` | IDs must be unique within a job. Use them for outputs and background controls. |
| `if` | Step status, outputs, environment, and service ports in addition to the listed job-condition contexts. |
| `env` | Overrides job and workflow values; supports field-specific expressions and fallbacks. |
| `continue-on-error` | Boolean literal or Boolean-valued expression. Failure gives `outcome: failure`, `conclusion: success`, then continues. |
| `timeout-minutes` | Literal or expression returning a number greater than zero and at most 360. |
{: class="responsive-table"}

Tolerated failures, including evaluation failures before a process starts, produce masked log and annotation warnings without changing the conclusion. This includes composite children and JavaScript `pre` hooks.

```yaml
steps:
  - id: test
    run: go test ./...
    continue-on-error: true
  - if: steps.test.outcome == 'failure'
    run: ./scripts/report-failure
```

### Commands and actions

Linux and macOS support `bash`, `sh`, `pwsh`, `powershell`, `python`, and custom templates such as `Rscript {0}`, `julia --color=yes {0}`, or `bash -l {0}`. The interpreter must already be installed and on `PATH`; PowerShell, R, and Julia aren't installed automatically. Named PowerShell shells use their exact executable without fallback. Unsupported shells fail during compilation when known, or before their step when resolved at runtime.

Custom templates use `command [options] {0} [options]`, where `{0}` receives the script path. Single quotes, double quotes, and backslash escapes group arguments without shell expansion. Named PowerShell runs UTF-8 `.ps1` scripts, sets `$ErrorActionPreference = 'stop'`, and propagates the last native exit status. Custom PowerShell templates control their own error handling.

Windows defaults to `pwsh` and supports explicit `powershell` and MSYS2 custom shells; `cmd` is unsupported. Windows executable templates can use drive-absolute paths such as `D:\cygwin\bin\bash.exe '{0}'`. Quote paths containing spaces. A single backslash after the drive prefix selects literal executable separators; templates with an escaped first backslash retain escape rules.

`msys2/setup-msys2@v2` can install `msys2 {0}`, including for `defaults.run.shell`. Its `.cmd` wrapper resolves from step `PATH`, including `GITHUB_PATH`, and receives an extensionless unmodified script and Windows working directory. MSYS2 owns login setup, errors, and path conversion. Windows `.cmd` custom wrappers must forward directly without `CALL` or delayed expansion. Arguments can contain spaces and `%`, `!`, `&`, and `^`, but not double quotes, line breaks, NUL, or a trailing backslash. These argument limits don't restrict script contents.

Workflow working directories stay within the workspace. Composite actions can also select an absolute directory inside their own verified source repository; relative paths still use the workspace. Traversal and symlink escapes are rejected.

```yaml
steps:
  - name: Test
    shell: bash
    working-directory: ./src
    run: go test ./...
```

`uses` accepts supported local and public actions with expression-valued `with` inputs. Direct workflow `uses: docker://...` is rejected; prebuilt images belong in locked action metadata. See [action sources and runtimes](#actions-artifacts-and-caching-action-sources-and-runtimes) and [self-repository actions](#actions-artifacts-and-caching-self-repository-actions) for source verification and access restrictions.

### Background and parallel steps

The `background`, `wait`, `wait-all`, `cancel`, and `parallel` extensions are supported outside composite actions, with at most ten active background steps:

```yaml
steps:
  - id: server
    run: ./scripts/start-server
    background: true
  - run: ./scripts/test
  - cancel: server
  - parallel:
      - run: ./scripts/lint
      - run: ./scripts/check-format
```

Use `wait: <id>` for selected work or `wait-all:` for all active work. Outputs, environment changes, and failures become visible at the covering wait. Remaining work joins before post-action cleanup.

### Environment files

`GITHUB_OUTPUT`, `GITHUB_ENV`, `GITHUB_PATH`, `GITHUB_STATE`, and `GITHUB_STEP_SUMMARY` support multiline values. File commands ignore a leading UTF-8 BOM, not BOMs inside values. `NODE_OPTIONS` can't be set using `GITHUB_ENV`. The total job summary limit is 1 MiB.

<a id="runtime-behavior-and-limits-default-environment"></a>

### Default environment

`GITHUB_REF`, `GITHUB_REF_NAME`, and `GITHUB_REF_TYPE` follow the context values. `GITHUB_WORKFLOW` is the top-level name or repository-relative path; `GITHUB_WORKFLOW_REF` and `GITHUB_WORKFLOW_SHA` retain top-level caller identity through reusable calls. `GITHUB_WORKSPACE`, build run variables, and runner identity follow the [runtime context table](#expressions-and-contexts-runtime-interpolation). Workflow, job, step, action, and environment-file values can't override protected runtime identity variables.

### Workflow commands

| Command | Behavior |
| --- | --- |
| `add-mask`, `stop-commands` | Supported. |
| `warning`, `error` | Buildkite build annotations. |
| `group`, `endgroup` | Linear log sections. |
| Debug and matcher commands | Accepted, no presentation effect. |
| `notice`, command echo control, other legacy commands | Unsupported. |
{: class="responsive-table"}

## Expressions and contexts

Conditions, runtime fields, and compile-time fields have different context access. An expression supported in one position isn't necessarily supported in another.

| Syntax | Availability |
| --- | --- |
| `!`, `&&`, `\|\|`, `==`, `!=`, `<`, `<=`, `>`, `>=` | Conditions, listed runtime fields, and fully resolvable compile-time fields. |
| `always()`, `success()`, `failure()`, `cancelled()` | Conditions, without arguments. |
| `startsWith()`, `contains()`, `endsWith()`, `format()`, `join()`, `toJSON()`, `fromJSON()`, `case()` | Conditions and listed runtime/compile-time fields, subject to context and result-type restrictions. |
| `hashFiles()` | Workflow/composite step fields and conditions, plus JavaScript lifecycle conditions; not general compile-time fields. |
{: class="responsive-table"}

### Conditions

Conditions use GitHub-style truthiness, loose numeric coercion, case-insensitive string comparisons, operand-returning `&&`/`||`, primitive string conversion, array search in `contains()`, and lazy `case()` with 3–255 odd-numbered arguments and Boolean predicates. Unlisted functions are unsupported. Every branch is validated before lazy evaluation, so an unreachable branch can't hide an unsupported context or function.

Missing properties in available contexts evaluate to null; unavailable contexts are errors. Computed object indexes, numeric array indexes, whole `matrix` and `needs` objects, step-scoped `steps`, and `.*` projections are supported. Missing indexes yield null, projections omit absent children, and another wildcard flattens one level. `[*]` is unsupported. Whole/dynamic `github` is unsupported except access rooted at `github.event`; whole `inputs` and `strategy` are unsupported.

| Context | Job condition | Step condition |
| --- | --- | --- |
| `github.actor`, `base_ref`, `event_name`, `head_ref`, `ref`, `ref_name`, `ref_type`, `repository`, `repository_owner`, `sha`, `workflow_ref`, `workflow_sha` | Yes | Yes |
| `github.event`, including projected/dynamic properties | Yes | Yes |
| `github.server_url` | No | Composite steps only, from v0.105.0. |
| `runner.os`, `runner.arch`, `runner.environment` | Yes | Yes |
| `runner.temp`, `runner.debug` | No | Yes; debug is always absent. |
| `needs.<job>.result`, `needs.<job>.outputs.<name>` | Yes | Yes |
| Matrix values | Yes | Yes |
| Scalar `strategy` properties | No | Workflow steps only. |
| `vars` | Repository/organization scope | Environment/repository/organization scope. |
| Named or computed input access | Yes | Yes |
| Step outcome, conclusion, and outputs | No | Yes |
| `env` | No | Yes |
| `job.status`, `job.services` IDs, networks, ports | No | Yes |
| `secrets`, other unlisted contexts | No | No |
{: class="responsive-table"}

`hashFiles()` conditions accept 1–255 literal or direct-reference arguments. Reusable-call conditions use the narrower [caller scope](#workflow-syntax-reference-reusable-workflows). Event data remains the original event, including whole or dynamic access.

Composite `github.server_url` conditions can distinguish providers, such as `github.server_url == 'https://github.com'`. Workflow job/step, reusable-call, and JavaScript lifecycle conditions don't gain this field. A composite condition doesn't grant token authority to its run body.

### Runtime interpolation

Workflow step `run`, `env`, `with`, `name`, explicit `shell`, `working-directory`, `continue-on-error`, and `timeout-minutes` accept the supported operators and pure functions. Computed indexes and projections over available `matrix`, `inputs`, `env`, `vars`, and `runner` values are supported. Computed/projected `needs` and computed/whole/projected `steps` access aren't. Unavailable background outputs are errors.

`toJSON(needs)` serializes direct dependencies only, each with `result` and an `outputs` object. Transitive dependencies aren't included. The following job fields use the same operators and pure functions with narrower contexts:

| Job field | Contexts |
| --- | --- |
| `continue-on-error` | `github`, `needs`, `strategy`, `matrix`, `vars`, `inputs` |
| `env` | `github`, `needs`, `strategy`, `matrix`, `vars`, `secrets`, `inputs` |
| `defaults.run` | `github`, `needs`, `strategy`, `matrix`, `env`, `vars`, `inputs` |
| `outputs` | `github`, `needs`, `strategy`, `matrix`, `job`, `runner`, `env`, `vars`, `secrets`, `steps`, `inputs` |
{: class="responsive-table"}

Workflow `env` follows job-env rules except `strategy`. Workflow run defaults support direct context references only. Scalar strategy properties and static bracket access work in listed workflow step and job fields, not job conditions, workflow-level fields, reusable-call inputs, or action-authored metadata including composite steps. Whole, computed, and projected strategy access is unsupported.

Null event members interpolate as empty strings. Event values and substituted inputs can't create new expression regions. `||` selects the right operand for false, zero, empty string, or null; it doesn't recover from evaluation errors, retrieve missing secrets, or admit expressions in literal-only fields. Expression-valued step timeouts must be numeric; `continue-on-error` must be Boolean.

From [v0.103.0](https://github.com/buildkite/buildkite-gha/releases/tag/v0.103.0), workflow/composite step fields, JavaScript lifecycle conditions, and job outputs can read `job.status` as `success`, `failure`, or `cancelled`. Outputs see final status after posts. Job/reusable-call conditions, job env, defaults, containers/services, and Docker action arguments can't read it. Action input defaults support one direct `${{ job.status }}` expression. Other job fields are unsupported except the listed service context and empty `job.check_run_id` input defaults.

`job.status` doesn't replace status functions. Use `always()` when a step must run after failure:

```yaml
steps:
  - if: always()
    env:
      STATUS: ${{ job.status }}
    run: echo "Job status is $STATUS"
```

Inside a composite, a child failure can make `failure()` true while `job.status` stays at the enclosing job's status until the composite finishes. Step timeout isn't whole-job cancellation; whole-job cancellation sets `cancelled`.

Workflow-authored `github.token` references are step-only. Effective action input defaults can also request it. Exact case-insensitive `toJSON(github)` is supported in step runtime fields and includes the retained context and token, sorted with two-space indentation. It requests token authority and fails without authorization; composite metadata can't independently grant that authority. Job fields, action defaults, bare/dynamic/projected `github`, and passing whole `github` to other functions remain unsupported, except event-rooted access.

| Retained runtime context | Value |
| --- | --- |
| `github.actor`, `event_name`, `ref`, `repository`, `sha` | Event identity. |
| `github.repository_owner` | Owner from repository identity. |
| `github.server_url` | Event repository provider URL. |
| `github.job`, `github.workflow` | Job ID and workflow name or fallback path. |
| `github.workflow_ref`, `github.workflow_sha` | Top-level caller workflow identity, retained through reusable calls. |
| `github.head_ref`, `github.base_ref` | Pull request branches; empty for other events. |
| `github.ref_name`, `github.ref_type` | Short ref and branch/tag kind. Pull request short refs use `<number>/merge` or `/head`. SHA-only deployments use empty ref/name with type `branch`. |
| `github.action_path` | Composite directory within its steps; empty elsewhere. |
| `github.action` | From v0.104.0, the invoking workflow step's authored ID or generated name in runtime step expressions. Nested composites and pre/main/post hooks retain it. Conditions and compile-time expressions don't support it. |
| `github.action_repository`, `github.action_ref` | Remote composite repository and requested ref; empty for local composites or outside composite steps, subject to self-reference behavior. |
| `github.workspace` | Host checkout or fixed job-container workspace. |
| `github.run_id`, `run_number`, `run_attempt` | Buildkite build ID, number, and retry count plus one; require a Buildkite build. These aren't GitHub run IDs or valid GitHub run URLs. |
| `github.token` | Authorized token only. |
| `github.event` | Original verified event payload. |
| `runner.os`, `runner.arch` | `Linux`/`X64`, `Linux`/`ARM64`, `macOS`/`ARM64`, or `Windows`/`X64`. |
| `runner.environment` | `self-hosted`, including Buildkite hosted agents. |
| `runner.temp` | Canonical `RUNNER_TEMP`, available after setup in step fields and job outputs. |
| `runner.debug` | Always absent; interpolation is empty and comparison to enabled value `1` is false. Available in step fields, outputs, lifecycle conditions, and action input defaults. |
{: class="responsive-table"}

This isn't the full GitHub context. `job.check_run_id` action input defaults, including static indexing, return an empty string because there is no GitHub Actions check run.

`hashFiles()` is available in workflow and composite step fields and conditions, not job fields, action input defaults, or composite output metadata. It sees earlier workspace changes and may evaluate separately for JavaScript `pre` and `main`. Composite patterns use the workspace, not the action directory or working directory.

Patterns apply in order: `!` excludes, later positives can reinclude, directories include descendants, hidden files match, and overlapping matches hash once. Matching is case-insensitive on Windows only. No match returns an empty string. When a lockfile is required, check for an empty hash before caching:

```yaml
steps:
  - id: lockfile
    shell: sh
    env:
      HASH: ${{ hashFiles('package-lock.json') }}
    run: |
      if [ -z "$HASH" ]; then
        echo "package-lock.json missing; check checkout order and pattern" >&2
        exit 1
      fi
      printf 'digest=%s\n' "$HASH" >> "$GITHUB_OUTPUT"
  - uses: actions/cache@v5
    with:
      path: ~/.npm
      key: npm-${{ runner.os }}-${{ steps.lockfile.outputs.digest }}
```

Hashing uses SHA-256 file digests in lexical path order; multi-file results can differ from GitHub's unspecified traversal order. Patterns can't be absolute or contain `..` or ASCII controls. Traversal stays inside the workspace and doesn't enter symlink directories; matching a symlink or special file fails deliberately, unlike GitHub's file-symlink support.

Traversal starts at each positive pattern's literal prefix. Negative patterns don't prune traversal. [Entry and time budgets](#limits-and-troubleshooting-key-limits) count inspected nonmatching entries and cover traversal, matching, sorting, hashing, and verification. Use narrower positive paths after a budget failure. Earlier deadlines and cancellation still apply; blocked filesystem calls can't be interrupted between operations. Errors identify step/field context and affected patterns.

### Event file

With a linked webhook or explicit event snapshot, the complete event payload is available as a JSON file. Access its path with either the `GITHUB_EVENT_PATH` environment variable or the `${{ github.event_path }}` expression.

```yaml
steps:
  - name: Read the event file with an environment variable
    run: jq . "$GITHUB_EVENT_PATH"
  - name: Read the event file with an expression
    env:
      EVENT_FILE: ${{ github.event_path }}
    run: jq . "$EVENT_FILE"
```

The file contains the payload object, not the snapshot wrapper; formatting can differ. Each job has its own file outside the checkout and writable runner temp. The file remains available through action posts and is removed at teardown. Environment overrides cannot replace its path. Environment fallback events create no file; the expression returns an empty string.

`github.event_path` is available in runtime environment values, step expressions and conditions, action input defaults, JavaScript lifecycle conditions, and composite and job outputs. Graph-time fields such as `runs-on` and concurrency, and job or reusable-call conditions evaluated before setup, cannot use the expression.

Shell steps, JavaScript lifecycle hooks, composites, and Docker actions can read the file. Host jobs use the host path; job containers use `/github/workflow/event.json`. Containers mount the file read-only. Docker action environment paths, including `INPUT_*`, translate to the mount; arguments stay literal. Pass the expression through an input and read its environment variable, or read `GITHUB_EVENT_PATH` inside the action.

See [event payload security](/docs/pipelines/migration/run-github-actions-workflows/security#repository-data-does-not-grant-authority-source-and-event-checks).

### Compile-time expressions

Statically resolvable fields support `github.actor`, `base_ref`, `event_name`, `head_ref`, `ref`, `ref_name`, `ref_type`, `repository`, `repository_owner`, `sha`, and `workflow`, plus event data and the field-specific matrix, input, strategy, and variable contexts described above. Workflow concurrency has the additional [build-ID exception](#workflow-syntax-reference-concurrency) from v0.106.0. Computed indexes and projections work only when the complete value resolves before execution. Whole/dynamic `github` requires an event root. Action and workflow `uses` references remain static, regardless of event data.

<a id="runtime-behavior-and-limits"></a>

## Limits and troubleshooting

Use the result and diagnostic guidance below when a workflow validates but doesn't run as expected. Check the selected importer/runtime version and event evidence before changing workflow permissions or filters.

<a id="runtime-behavior-and-limits-results-retries-and-cancellation"></a>

### Results, retries, and cancellation

- A runtime-skipped job remains successful in Buildkite Pipelines, appends `(skipped)` to its label, and publishes logical `skipped` to downstream imported jobs.
- Retry the whole build after ambiguous producer results/artifacts or a retried producer whose deferred jobs already expanded. A deferred step itself can be retried safely.
- Cancellation targets the process tree. Linux/macOS send `SIGINT`, then `SIGTERM` after 7.5 seconds, then `SIGKILL` after another 2.5 seconds. Windows terminates through a Job Object without signal grace.
- Summary, annotation, or skipped-label publication failures warn without changing completed job results.

<a id="how-workflows-run-on-buildkite-pipelines-compatibility-diagnostics"></a>

### Compatibility diagnostics

Diagnostics include a concise `message` and, when available, a `detail` explaining the restriction or resolved action version. Text and JSON reports and job annotations retain both; provider check summaries show the message. Follow guidance for the specific diagnostic rather than treating every rejection as a permissions or installation problem.

<a id="how-workflows-run-on-buildkite-pipelines-aggregate-workflow-upload"></a>

### Aggregate workflow upload

Native GitHub Actions pipelines run one server-selected workflow per build. The server supplies workflow identity and event metadata, which the runtime checks against the repository and checkout. Customers don't configure these values. A missing or untracked server-selected workflow fails preparation. See [pipeline trigger selection](/docs/pipelines/migration/run-github-actions-workflows/cli#upload-from-a-custom-importer-pipeline-trigger-selection) for the read-only identity fields.

The remaining aggregate-upload behavior describes advanced custom importers and older explicit-workflow pipelines, not native setup. A custom importer can pass explicit workflow paths to the [CLI upload command](/docs/pipelines/migration/run-github-actions-workflows/cli#upload-from-a-custom-importer). Explicit selections require an importer step key, and their generated groups depend on it.

Explicit paths must be regular, tracked `.yml` or `.yaml` files inside the repository. Missing or untracked configured paths warn and are omitted; if all are omitted, upload succeeds without adding a pipeline. A missing server-selected workflow fails. Directories, tracked-but-missing files, outside paths, symlinks, and globs fail. A custom importer may use one explicit outside or untracked file, except when [deferred jobs](#job-syntax-matrices-from-job-outputs) require committed source. Paths are normalized, sorted, and deduplicated.

Server-selected workflows have no workflow group. Explicit selections keep groups, including a single selection, and require an importer step key. Server-selected importers don't require a key. Group labels use `\:github\: workflow · <workflow-name-or-path>` and append a nonempty `run-name`. The importer label and build message don't change. Provider checks use `<workflow-name-or-path> / <job-id> (<event>)`, with matrix values appended to the job ID. GitHub and Origin events publish checks to their respective providers.

A workflow that doesn't declare the event becomes one top-level skipped step. The importer annotation links to skipped workflows and explains event or filter exclusions, including when all workflows skip. Reusable-only files remain callable but don't create groups; selecting only reusable workflows is an error.

In an aggregate upload, a parse, compilation, or trigger-translation error replaces the affected workflow with a failing item, redacted diagnostics, and a `Workflow could not be run` check. Check summaries are limited to 65,535 bytes. Other workflows can continue. Within a fully expanded static graph, job-level compilation errors can fail only the affected jobs and skip their dependants while independent jobs run. Workflows with deferred jobs fail as a whole on compilation errors. Errors before the graph is known also fail the workflow as a whole.

Single-workflow parse errors, invalid paths, event-input errors, admission failures, artifact failures, and upload failures abort the upload transaction. Upload doesn't publish a partial transaction. A compiler error takes precedence over a same-workflow filter exclusion.

<a id="runtime-behavior-and-limits-key-limits"></a>

### Key limits

| Item | Limit |
| --- | --- |
| Workflow file | 1 MiB |
| Expanded jobs per workflow | 1,024 |
| Matrix instances per job | 256 |
| Reusable nesting | Four levels |
| Nested local actions | Ten levels |
| Active background steps | Ten |
| Job outputs | 64 values, 1 MiB each, 4 MiB combined from v0.102.3 |
| Output-derived matrix JSON | 64 KiB from v0.102.3; row strings at most 1 KiB |
| Output-derived runner selection | 1 KiB |
| Job or step timeout | 360 minutes |
| Artifacts per job | 64 |
| Upload files | 10,000 per artifact |
| Download files | 10,000 across all selected artifacts |
| Artifact source data or ZIP bytes | No separate runtime limit; agent/storage limits apply. |
| Job summary | 1 MiB |
| `hashFiles()` patterns | 255 per call, 1 KiB each, 64 KiB combined |
| `hashFiles()` inspected entries | 1,000,000 per call |
| `hashFiles()` execution | 30 seconds per call |
| `hashFiles()` matches | 10,000 files per call |
| `hashFiles()` selected bytes | 1 GiB per call |
{: class="responsive-table"}

<a id="compatibility-policy"></a>

### Compatibility policy

`buildkite-gha` follows exposed, reproducibly observed GitHub Actions behavior within the supported subset on this page. Intentional differences and security restrictions are stated where they apply. Unsupported functionality is a Buildkite Pipelines limit, not a claim that GitHub rejects the same workflow.

This reference covers GitHub Actions Compatibility and the `hosted` profile used by `upload`. A runtime release doesn't by itself enable backend capabilities or update existing webhook subscriptions.

This public reference owns shipped support and user limits, and is updated when released behavior or prerequisites change. The [contributor compatibility contract](https://github.com/buildkite/buildkite-gha/blob/main/docs/compatibility-contract.md) defines implementation obligations, evidence requirements, and documentation ownership.
