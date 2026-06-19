# Job early failure detection documentation plan

## Source priority

Use the [Promise failure docs Notion page](https://www.notion.so/buildkite/Promise-failure-docs-384b8dbc2c8980819d71dc5aab684397?source=copy_link) as the source of truth for customer-facing terminology, conceptual framing, and examples. The plan below has been updated from that page and should continue to defer to it where it conflicts with implementation notes or generated docs PRs.

Supporting sources:

- [Linear project: Job Early Failure Detection](https://linear.app/buildkite/project/job-early-failure-detection-af8613347dce/overview)
- [Notes with Wolfie: Promise Failure MCP](https://www.notion.so/buildkite/Notes-with-Wolfie-Promise-Failure-MCP-383b8dbc2c89806e9502d164d98f5f07?source=copy_link)
- [docs-private PR 1571](https://github.com/buildkite/docs-private/pull/1571): Webhooks and Amazon EventBridge docs for `job.promised_exit_status`
- [docs-private PR 1572](https://github.com/buildkite/docs-private/pull/1572): GraphQL fields for promised exit status on command jobs
- Buildkite Pipelines implementation in `buildkite/buildkite`
- Buildkite agent implementation in `buildkite/agent`
- Buildkite Test Engine Client implementation in `buildkite/test-engine-client`

Local checkout note: the Buildkite Pipelines and Test Engine Client repositories contain implemented surfaces for this feature. The local `agent` checkout did not contain `promise-failure` matches during this pass, so use the agent implementation branch or upstream PR before finalizing agent CLI reference docs.

Priority concepts from the Notion source:

- Promise failure is first a Buildkite agent CLI feature.
- The key customer value is early failure signaling while the job continues running so Buildkite Pipelines can still capture logs, artifacts, and complete test results.
- The feature needs two agent docs scopes: an API/reference page for the command and a usage guide for recommended integration patterns.
- Buildkite Test Engine Client users should be able to enable the feature with configuration rather than code changes.
- Preflight and promise failure should cross-link because promise failure makes Preflight faster.
- Customers and agents should query jobs directly for failed jobs instead of relying on nested jobs from the build endpoint.

## Customer-facing feature summary

Job early failure detection lets a still-running command job declare that it is expected to fail before the command exits. Buildkite Pipelines records a promised non-zero exit status for the running job, keeps the job state as `running`, and uses the declaration as an early signal for build rollup and downstream integrations.

For build-critical declarations, Buildkite Pipelines can move the build to `failing` before the job reaches a terminal state. This lets notifications, webhooks, Amazon EventBridge, Preflight, MCP workflows, and `cancel_on_build_failing` react earlier while the job can continue uploading logs, artifacts, JUnit XML, and Test Engine results.

Use this scenario as the primary explanation: if test 2 of 100 fails, the job can signal that the build is failing immediately, but the job should still run the remaining tests so engineers and agents can see the full failure set.

## Concepts to explain

### Early failure declaration

Explain that an early failure declaration is a signal from a running command job that the job is expected to finish with a non-zero exit status. The declaration records:

- The promised exit status.
- The time when the promised exit status was recorded.
- An optional human-readable reason.

Make clear that this is not a terminal result. The command continues to run until it exits, is canceled, times out, or otherwise reaches a terminal state.

### Promised exit status

Explain the promised exit status as the non-zero exit status a job declares before it finishes. Cover these constraints and semantics:

- The promised status must be a non-zero integer.
- A zero status is not a promised failure.
- A job should call the command only once.
- Repeating the same promised exit status is handled for debounce/idempotency, but docs should still tell customers to call it only once per job.
- Declaring a different value for the same job is a conflict.
- The declaration is valid only for running command jobs.
- The promised status is separate from the raw exit status reported when the command actually finishes.

### Running job with a failure signal

Explain the key status distinction:

- The job remains `running` after it declares early failure.
- The step or build can be shown as failing because the promised status counts toward failure rollup.
- The final job result is still determined when the command finishes, with promised-exit-status handling applied when needed.

This distinction should appear prominently because it prevents customers from reading the feature as a new job lifecycle state.

### Build failing rollup

Explain when a promised status changes build state:

- A promised hard failure can move a build to `failing` before the job exits.
- Soft-fail rules can prevent a promised status from counting as a hard failure.
- Automatic retry rules can prevent or delay the promised failure from affecting build state when the retry rule applies.
- The build can return from `failing` if the promised failure no longer counts, for example after a retry or later state transition.

Avoid describing internal feature flags in customer docs unless launch status requires a limited-availability note.

### Soft-fail behavior

Document that promised statuses respect `soft_fail` rules. If the promised exit status matches a soft-fail rule, Buildkite Pipelines should treat it like a soft failure for build-failing decisions.

Relevant docs surfaces:

- `/docs/pipelines/configure/soft-fail`
- `/docs/pipelines/configure/step-types/command-step`
- Any new early failure detection guide or concept page

### Automatic retry behavior

Document how automatic retry rules interact with promised failures:

- If a promised exit status would be retried automatically, customers should not assume the build will immediately become failing.
- If retries are exhausted and a hard failure remains, the declaration can count toward build failure.
- Tools such as the Buildkite Test Engine Client should declare early failure only after their own retry behavior has determined that hard failures remain.

Relevant docs surfaces:

- `/docs/pipelines/configure/retry`
- `/docs/pipelines/configure/step-types/command-step`
- Test Engine Client docs, if customer-facing usage is supported

### Terminal exit handling

Explain how Buildkite Pipelines handles the final command result after a job promised failure:

- A promised job still produces a terminal job event when it finishes.
- If a job promises a hard failure, it should ultimately exit as a hard failure. If it promises a soft failure, it should ultimately exit as a soft failure.
- If the agent exits with a different status code than promised, Buildkite Pipelines shows both the promised and actual exit statuses in the job timeline.
- If the job later reports success or a soft-failed status after promising hard failure, Buildkite Pipelines can preserve the promised non-zero status as the effective status.
- Docs should distinguish the actual command exit status from the effective status used by Buildkite Pipelines.

This concept likely belongs in a troubleshooting or FAQ section, not the first usage example.

### `cancel_on_build_failing`

Update docs for `cancel_on_build_failing` because early failure declarations can make cancellation happen earlier:

- A job with `cancel_on_build_failing: true` can be canceled when another running job declares a promised hard failure and the build becomes `failing`.
- This can happen before the declaring job exits.
- Customers using long-running parallel jobs can use this to save time and agent capacity.

Relevant docs surfaces:

- `/docs/pipelines/configure/step-types/command-step#cancel-on-build-failing`
- Migration docs that translate fail-fast behavior to `cancel_on_build_failing`

### Notifications and conditionals

Explain downstream notification behavior:

- Build-level notifications tied to `build.failing` can fire earlier.
- Step-level `step.failing` surfaces may appear earlier when a job promises hard failure.
- Conditional notification examples should remain correct when the build enters `failing` before terminal job exit.
- Do not propose a dedicated Slack notification event for promise failure. The Notion source says existing build-failure notifications already signal the important state change and a separate Slack event would add noise.

Relevant docs surfaces:

- `/docs/pipelines/configure/notify`
- Slack workspace integration docs, if examples mention `pipeline.started_failing`

### Webhooks

Document the new `job.promised_exit_status` webhook event:

- Event name: `job.promised_exit_status`.
- Fired when a running job declares an anticipated failure.
- Does not replace `job.finished`.
- The job object includes `promised_exit_status` and `promised_exit_status_at`.
- The top-level payload includes `promised_exit_status_reason`, which can be `null`.

Existing in-progress docs:

- PR 1571 updates `pages/apis/webhooks/pipelines/job_events.md`.
- PR 1571 updates `data/llm_descriptions.yml`.

Recommended follow-up:

- Verify examples use placeholder IDs and timestamps.
- Confirm whether the event is feature-flagged or generally available at launch.
- Confirm whether webhook event selectors expose this event to all customers.

### Amazon EventBridge

Document the EventBridge equivalent of the webhook event:

- Detail type: `Job Promised Exit Status`.
- The detail payload includes `promised_exit_status_reason` at the top level.
- The detail `job` object includes `promised_exit_status` and `promised_exit_status_at`.
- The event does not replace `Job Finished`.

Existing in-progress docs:

- PR 1571 updates `pages/pipelines/integrations/observability/amazon_eventbridge.md`.

Recommended follow-up:

- Confirm heading style. Docs style usually requires sentence case, while EventBridge detail-type names may need exact capitalization in prose or tables.
- Confirm example values and whether `passed: false` is expected while the job is still running.

### GraphQL API

Document GraphQL read surfaces for promised exit status:

- `JobTypeCommand.promisedExitStatus`
- `JobTypeCommand.promisedExitStatusAt`
- Job event type for promised exit status, if exposed in the schema and customer docs.
- Any promised-exit-status reason field on job events, if available through GraphQL.

Existing in-progress docs:

- PR 1572 updates `data/graphql/schema.graphql`.
- PR 1572 updates `pages/apis/graphql/schemas/object/jobtypecommand.md`.

Recommended follow-up:

- Confirm GraphQL field descriptions match the Notion source of truth.
- Add a short cookbook or example query only if customers are expected to query these fields directly.
- Confirm whether generated GraphQL reference pages are enough or whether a conceptual API page should link to them.

### REST API and Agent API

Document how customers or tools declare and observe early failure. This is a priority gap because PR 1571 and PR 1572 cover read/event surfaces, not the write path.

Important distinction from the Notion source:

- Declaring promise failure is currently customer-facing through the Buildkite agent CLI, not the REST API.
- Observing promise failure data is available through REST, GraphQL, webhooks, and Amazon EventBridge.
- Customer and agent workflows should prefer the jobs endpoint over the build endpoint for finding failed jobs, because nested jobs on the build endpoint are inefficient for large parallel builds.
- Job filtering for failed jobs should include both terminally failed jobs and running jobs that have promised failure.
- Job payloads should expose promised exit status and timestamp. The reason appears through the job event.

Areas to verify in `buildkite/buildkite` and `buildkite/agent`:

- Agent API endpoint used by `buildkite-agent job promise-failure`.
- Required authentication context. Current `bktec` code shells out to `buildkite-agent job promise-failure` and relies on the job environment, including `BUILDKITE_JOB_ID` and inherited agent authentication.
- Request fields: exit status and optional reason.
- Error cases: invalid status, non-running job, unsupported job type, duplicate declaration with different status.
- Response shape and status codes. Current Buildkite Pipelines code returns `204 No Content` on success, `404 Not Found` when the feature is disabled for the organization, `409 Conflict` for a different already-declared promised status, and `422 Unprocessable Entity` for validation errors.

Relevant docs surfaces:

- Agent API docs under `pages/apis/agent_api/`, if this is an Agent API endpoint.
- REST API docs under `pages/apis/rest_api/`, if public REST access exists.
- Buildkite agent CLI reference, if customers should use the CLI instead of calling the API directly.

### Buildkite agent CLI

Document the customer-facing command for declaring early failure. The Notion source says this needs two docs surfaces:

- API/reference docs for the command, arguments, options, call-once caveat, and debounce behavior.
- A usage guide for when to call it and how to integrate it into test runners, scripts, and pipelines.

Example command:

```bash
buildkite-agent job promise-failure 1 --reason "tests failed after retry"
```

Concepts to explain:

- Run the command from inside a running Buildkite Pipelines job.
- Use the command only after a tool knows the job will hard fail.
- The command does not stop the job.
- The command lets the job continue uploading logs, artifacts, and test results.
- The command should be called only once per job. Debounce/idempotency behavior is a safety net, not the recommended integration pattern.
- You cannot promise success. Exit status `0` is invalid.
- The promised exit status is evaluated against retry rules and soft-fail rules.

Relevant codebase:

- `buildkite/agent`. The local checkout did not contain the command yet, so confirm against the agent implementation PR or release branch.

Relevant docs surfaces:

- `/docs/agent/cli/reference`
- `/docs/agent` or a new guide linked from the agent CLI reference
- Any generated command reference for `buildkite-agent job promise-failure`

### Buildkite Test Engine Client

Document optional usage through Buildkite Test Engine Client if it is intended for customer adoption:

- The client can declare an early failure after retries are exhausted and hard test failures remain.
- The behavior is opt-in using `--promise-failure` or `BUILDKITE_TEST_ENGINE_PROMISE_FAILURE`.
- The Notion source called out `BUILDKITE_TEST_ENGINE_PROMISE_FAILURE=true` as the flag to document, and local code confirms that environment variable.
- The client shells out to `buildkite-agent job promise-failure 1 --reason "test_failure (<count> failed after retries)"`.
- The promise call has a five-second timeout and is best-effort. A promise failure should not change the Test Engine Client exit status.
- This path is useful because test tooling can know the job will fail before artifact and result uploads finish.
- Buildkite Test Engine Client accounts for muted tests and retries before declaring promise failure.
- This is especially valuable for long-running feature tests, mobile tests, and UI tests.

Versioning to document or verify:

- Customers need a recent Buildkite Test Engine Client version.
- Confirm whether hosted agents auto-pull the required Buildkite Test Engine Client version or require an image update.
- Confirm the required Buildkite agent version for both self-hosted and Buildkite hosted agents.

Relevant codebase:

- `buildkite/test-engine-client`

Relevant docs surfaces:

- Buildkite Test Engine Client docs, if present.
- Buildkite Test Engine test collection docs.
- Any `bktec` setup or usage docs.

### RSpec and Ruby collectors

Confirm whether Ruby test collectors or `rspec-buildkite` have a customer-facing early-failure path.

Current evidence:

- The Linear project tracked research into `rspec-buildkite` and `test-collector-ruby`.
- The searched `rspec-buildkite` checkout did not show a promised failure implementation.
- The searched `test-collector-ruby` checkout did not show a promised failure implementation.
- The Test Engine Client checkout does include an opt-in promise-failure path.

Plan:

- Do not document collector-specific setup until an implementation exists and is intended for customer use.
- If implementation ships later, add language to the relevant collector docs explaining how and when the collector declares early failure.

### Preflight and MCP workflows

Explain the benefit for AI and agentic workflows without exposing internal implementation details:

- Early failure detection lets remediation tools begin investigating while the original job is still running.
- Preflight and MCP workflows can inspect running jobs with promised failure signals, collect context, and start follow-up work sooner.
- Customers should still expect final logs, artifacts, and test results to arrive after the declaration.
- Agents should start remediation work early, but they should also audit the final build failure later for additional context.
- MCP server-side instructions should explain the "running but failing" condition so agents interpret it correctly.
- MCP should move toward the jobs endpoint because it is more efficient and supports pagination.

Relevant docs surfaces:

- `/docs/apis/mcp-server`
- Preflight docs, if public in docs-private
- A conceptual early failure guide or examples page

Cross-linking from the Notion source:

- Promise failure docs should mention Preflight and explain that the two features pair well together.
- Preflight docs should recommend promise failure as a way to make Preflight faster.
- Customers need the most recent Buildkite CLI once Preflight's jobs-endpoint changes are merged.

### Build page and UI treatment

Document what customers see in Buildkite Pipelines:

- A job can appear as running while also carrying an early failure signal.
- The build header and step list can show failing before the declaring job exits.
- The job timeline includes an event for the promised exit status.
- The job log exit information can explain when the promised status was used as the effective status.
- Build and job filters may include running jobs with promised hard failures in failure-oriented views.

Relevant codebase:

- `buildkite/buildkite` Build Show UI and job timeline components

Relevant docs surfaces:

- `/docs/pipelines/configure/defining-steps`
- `/docs/pipelines/dashboard-walkthrough`
- A new early failure detection guide, if screenshots are needed

### Observability and metrics

Document only customer-visible observability surfaces:

- Webhooks and Amazon EventBridge are customer-facing and should be documented.
- OpenTelemetry behavior should be reviewed because build stages can include `failing` before terminal job failure.
- Do not document internal Datadog metrics unless they are exposed in product docs or customer dashboards.
- Customers can measure impact by comparing the promised exit status timestamp with the build finished timestamp.
- At the build level, customers can compare `build.finished_at` with `build.failing_at` to measure how much earlier the build signaled failure.

Relevant docs surfaces:

- `/docs/pipelines/integrations/observability/amazon-eventbridge`
- `/docs/pipelines/integrations/observability/opentelemetry`
- Webhook docs under `/docs/apis/webhooks/pipelines`

### Examples and tutorials

Create at least one customer-facing example that shows why the feature exists.

Recommended example:

1. A test command detects a deterministic, build-critical failure early, such as test 2 of 100 failing.
1. The test runner confirms retries are exhausted and muted tests do not account for the failure.
1. The command declares a promised failure with `buildkite-agent job promise-failure`.
1. The command continues uploading JUnit XML, artifacts, and logs.
1. Buildkite Pipelines marks the build as `failing` early.
1. Other long-running jobs with `cancel_on_build_failing: true` are canceled.
1. A webhook, EventBridge rule, notification, or MCP tool reacts before terminal job exit.

Recommended use cases from the Notion source:

- Test suites where a failure can be known before the entire suite finishes.
- Jobs with expensive teardown, such as Selenium, browser, mobile, or UI test frameworks.
- Build scripts, linting, Docker builds, or other batch-processing jobs that can detect failure before all work completes.

Possible docs location:

- New page: `pages/pipelines/configure/early_failure_detection.md`
- Or a section under the command step docs if the feature should stay small at launch.

The Linear issue PB-2006 tracks example docs and PB-1913 tracks an example pipeline.

## Codebases and documentation responsibilities

### `buildkite/buildkite`

Customer concepts owned here:

- Promised exit status storage and validation.
- Job event creation and timeline display.
- Build rollup to `failing`.
- Step failing propagation.
- Effective terminal exit status handling.
- Webhook and EventBridge payloads.
- GraphQL read fields and job event types.
- Build Show UI and filters.

Docs to update:

- Pipeline configuration concepts.
- Command step `cancel_on_build_failing` reference.
- Soft-fail and retry pages if needed.
- Webhooks and EventBridge docs.
- GraphQL schema docs and possible examples.
- Build state or step state glossary entries if they need clarification.

### `buildkite/agent`

Customer concepts owned here:

- `buildkite-agent job promise-failure` command.
- How the command authenticates from a running job.
- CLI flags and arguments.
- Agent API call used to declare promised failure.
- Error output and retry/idempotency behavior.

Status note:

- Confirm against the agent implementation PR or release branch. The local `agent` checkout did not contain this command during discovery.

Docs to update:

- Agent CLI reference.
- Agent CLI usage guide or a new promise failure guide linked from the CLI reference.
- Agent API docs, if customers can or should call the endpoint directly.
- Any agent release note or version requirement language.

### `buildkite/test-engine-client`

Customer concepts owned here:

- Opt-in early failure declaration from `bktec`.
- Declaration after retries are exhausted.
- Reason generation from remaining hard failures.
- Required Buildkite agent version and environment.
- `--promise-failure` and `BUILDKITE_TEST_ENGINE_PROMISE_FAILURE` configuration.
- Best-effort behavior and timeout when invoking the agent CLI.

Docs to update:

- Test Engine Client setup and command docs.
- Test collection docs that recommend `bktec`.
- Example pipeline docs that combine Test Engine Client with early failure detection.
- Hosted agents docs if image or version requirements affect Buildkite hosted agents.

### `buildkite/rspec-buildkite` and `buildkite/test-collector-ruby`

Customer concepts owned here, if implemented:

- Collector-specific early failure declaration behavior.
- Interaction with retries and soft-fail rules.

Docs to update only after implementation:

- Ruby collector setup docs.
- RSpec integration docs.

### `buildkite/docs-private`

Documentation tasks owned here:

- Convert the Notion source of truth into customer-facing docs.
- Merge or replace generated docs PRs with reviewed content.
- Add navigation and LLM descriptions for any new page.
- Ensure style, terminology, and examples match docs guidelines.
- Keep API reference content aligned with generated schema and event payloads.

## Proposed docs changes

### Create a concept and usage page

Recommended page: `pages/pipelines/configure/early_failure_detection.md`

Purpose:

- Explain the feature in one place.
- Provide the customer workflow.
- Link to CLI, API, webhook, EventBridge, soft-fail, retry, and `cancel_on_build_failing` references.

Suggested outline:

```markdown
# Detect job failures early

## How early failure detection works

## Declare early failure from a job

## Use Buildkite Test Engine Client

## Continue uploading results after declaring failure

## Use early failure with automatic cancellation

## Use early failure with retries and soft failures

## Use early failure with Preflight

## React to early failure with notifications and integrations

## Measure time saved

## Troubleshooting
```

Prioritize action-oriented content: show how to use the feature before reference details and edge cases.

### Update command step docs

File: `pages/pipelines/configure/step_types/command_step.md`

Add or revise the `cancel_on_build_failing` section to explain that early failure declarations can trigger cancellation before the declaring job exits.

### Update soft-fail docs

File: `pages/pipelines/configure/soft_fail.md`

Add a small section or callout explaining that promised exit statuses respect soft-fail rules.

### Update retry docs

File: likely `pages/pipelines/configure/retry.md` or command step retry section

Add a small section explaining that automatic retry rules affect whether a promised exit status counts toward build failure.

### Update notification docs

File: `pages/pipelines/configure/notify.md`

Clarify that `build.failing` and `step.failing` notifications can happen earlier when a running job declares a promised hard failure.

### Update webhook docs

Files:

- `pages/apis/webhooks/pipelines/job_events.md`
- `pages/apis/webhooks/pipelines.md`, if the summary event list needs the new event
- `data/llm_descriptions.yml`

Use PR 1571 as the starting point, then reconcile with the Notion source of truth.

### Update Amazon EventBridge docs

File: `pages/pipelines/integrations/observability/amazon_eventbridge.md`

Use PR 1571 as the starting point, then reconcile with the Notion source of truth.

### Update GraphQL docs

Files:

- `data/graphql/schema.graphql`
- `pages/apis/graphql/schemas/object/jobtypecommand.md`
- Any generated job event type page, if generated
- Optional cookbook page if customers need example queries

Use PR 1572 as the starting point, then reconcile field descriptions with the Notion source of truth.

### Update agent CLI docs

Files to identify:

- `pages/agent/cli/reference/**`
- Any generated command reference source for `buildkite-agent`

Add `buildkite-agent job promise-failure` usage, arguments, options, examples, and version requirements.

### Update Agent API or REST API docs

Files to identify after confirming the public contract:

- `pages/apis/agent_api/**`
- `pages/apis/rest_api/**`

Document the declaration endpoint only if it is customer-facing. The Notion source says declaration is currently available through the Buildkite agent CLI, not the REST API.

REST docs still need updates for observation surfaces:

- Expose promised exit status and promised timestamp on job payloads.
- Explain that job events carry the reason.
- Explain failed job filtering should include running jobs that promised failure.
- Recommend the jobs endpoint over nested jobs on the build endpoint for large builds and agent/MCP workflows.

### Update MCP docs

Files:

- `pages/apis/mcp_server.md`
- Tool-specific pages under `pages/apis/mcp_server/**`, if applicable

Use the Wolfie notes to identify whether MCP docs need to mention promised failure fields, filtering running jobs with promised failure, or early remediation workflows.

### Update Test Engine docs

Files to identify:

- Buildkite Test Engine Client docs, if present.
- Test collection docs under `pages/test_engine/test_collection/**`.
- Any `bktec` usage docs.

Document opt-in early failure behavior when customers use `bktec`.

## Open questions

- What exact customer-facing name should docs use: "job early failure detection", "early failure declarations", "promise failure", or "promised exit status"? Prefer the Notion page terminology.
- Is the feature generally available at launch, or does it require a feature flag, agent version, organization enablement, or beta label?
- What is the minimum `buildkite-agent` version that includes `buildkite-agent job promise-failure`?
- Which Buildkite Test Engine Client version first supports `BUILDKITE_TEST_ENGINE_PROMISE_FAILURE`?
- Do Buildkite hosted agents include compatible Buildkite agent and Buildkite Test Engine Client versions, or is an image update required?
- Should customer docs mention internal feature flags during beta, or should enablement be handled through release/beta notes?
- Should the optional reason be documented as visible in the UI, API payloads, and integrations?
- What is the maximum length and allowed content for the reason string?
- Do webhooks expose `job.promised_exit_status` to all webhook configurations, or only when a feature flag is active?
- Does Amazon EventBridge use exact detail type `Job Promised Exit Status` at launch?
- Should OpenTelemetry spans or attributes change when a promised failure moves a build to `failing`?
- What exact MCP tool behavior should customers rely on?
- Which Test Engine collectors, if any, declare early failure at launch beyond Buildkite Test Engine Client?
- What is the final REST jobs endpoint contract for failed filtering and promised status fields?

## Sequencing

1. Reconcile this plan against the Promise failure docs Notion page.
1. Read the Wolfie MCP notes and add any missing MCP-specific docs surfaces.
1. Confirm the public write path: agent CLI only, Agent API, REST API, or more than one.
1. Confirm launch availability and minimum versions.
1. Draft the main concept and usage page.
1. Update focused reference docs: command step, soft fail, retry, notifications, webhooks, EventBridge, GraphQL, REST job payloads, agent CLI, Preflight, MCP, and Test Engine Client.
1. Add navigation and LLM descriptions for any new page.
1. Review all examples for safe placeholder data.
1. Run docs linting and link checks.
1. Merge or supersede PR 1571 and PR 1572 with final reviewed content.
