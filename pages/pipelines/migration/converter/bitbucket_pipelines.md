# Bitbucket Pipelines

The [Buildkite pipeline converter](/docs/pipelines/migration/pipeline-converter) helps you convert your Bitbucket pipelines into Buildkite pipelines. Because Bitbucket configurations can include complex combinations of steps, parallel execution, caching, artifacts, and deployment targets, an AI Large Language Model (LLM) is used to achieve the best results in the translation process.

The LLM analyzes the Bitbucket Pipelines configuration to understand its structure and intent, and then generates a functionally equivalent Buildkite pipeline. The AI model _does not_ use any submitted data for its own training.

The goal of the Buildkite pipeline converter is to give you a starting point, so you can see how patterns you're used to in Bitbucket Pipelines would function in Buildkite Pipelines. In cases where Bitbucket features don't have a direct Buildkite Pipelines equivalent, the pipeline converter includes comments with suggestions about possible solutions and alternatives.

## Using the Buildkite pipeline converter with Bitbucket Pipelines

To start converting a Bitbucket Pipelines configuration into Buildkite Pipelines format:

1. Open the [Buildkite pipeline converter](https://buildkite.com/resources/convert/) in a new browser tab.
1. Ensure that **Bitbucket Pipelines** is selected at the top of the left panel.
1. Copy your Bitbucket Pipelines configuration and paste it into the left panel.
1. Select **Convert** to reveal the translated pipeline configuration in the **Buildkite Pipeline** panel.

## How the translation works

Here are some examples of translations that the Buildkite pipeline converter will perform:

- **Steps** become Buildkite Pipelines [command steps](/docs/pipelines/configure/step-types/command-step). The `name` attribute becomes `label`, and `script` arrays become `command` arrays. Steps that need to be referenced by other steps are assigned a `key` attribute.

- **Global images** (`image` at the top level) are translated to the [Docker plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-buildkite-plugin/) on each step. Buildkite Pipelines has no global image setting, so the plugin is applied per-step or through a YAML anchor to avoid repetition.

- **Branch pipelines** (`pipelines.branches`) are translated using the `branches` attribute on individual steps. Branch patterns support wildcards (such as `release-*` or `feature/*`) and exclusions using the `!` prefix.

- **Pull request pipelines** (`pipelines.pull-requests`) require configuration in Buildkite's pipeline settings rather than YAML. PR-specific steps can use `if: build.pull_request.id != null` conditionals.

- **Parallel execution** (`parallel` blocks) is handled automatically in Buildkite Pipelines since steps without `depends_on` run in parallel by default. No special syntax is needed. Sequential dependencies are created using `depends_on` attributes.

- **Reusable step definitions** (`definitions.steps`) are translated to YAML anchors in a `common` section. Anchor syntax (`&name` and `*name`) works identically in both systems.

- **Caching** (`caches` and `definitions.caches`) is translated with TODO comments since Buildkite Pipelines caching requires additional setup. Hosted agents can enable container caching at the cluster level. Self-hosted agents can use the [cache plugin](https://buildkite.com/resources/plugins/buildkite-plugins/cache-buildkite-plugin/).

- **Artifacts** (`artifacts` with `download: true`) are translated to `artifact_paths` for uploads and `buildkite-agent artifact download` commands for downloads. Unlike Bitbucket Pipelines, Buildkite Pipelines requires explicit artifact downloads in subsequent steps.

- **Path-based conditions** (`condition.changesets.includePaths`) are translated to the native `if_changed` attribute in Buildkite Pipelines. This attribute is processed by the agent during `buildkite-agent pipeline upload`, so the converted YAML must be stored in the repository.

- **Step resource sizing** (`size: 2x`) is documented with TODO comments since resource allocation in Buildkite Pipelines depends on your agent infrastructure. Configure appropriately sized agent queues and target them using the `agents` attribute.

- **Timeouts** (`max-time` at the step level or `options.max-time` globally) are translated to `timeout_in_minutes` on each step. For global timeouts, configure a default timeout in the pipeline settings or use a YAML anchor.

- **Custom pipelines** (`pipelines.custom`) for manual triggers are translated with `if:` conditionals that check `build.source`. Steps can be configured to run only when triggered through the UI, API, or trigger step.

- **Deployment environments** (`deployment`) are translated to [deployment targets](/docs/pipelines/deployments) in Buildkite Pipelines. The `deployment` attribute provides tracking and environment-based concurrency.

- **Variables** defined in Bitbucket's repository settings are documented with guidance on configuring environment variables in Buildkite's pipeline settings. User-prompted variables (`variables` with `allowed-values`) are translated to [input steps](/docs/pipelines/configure/step-types/input-step) with fields.

- **After-script** commands are translated using shell `trap` for step-specific cleanup or documented with guidance on using repository hooks (`post-command`) for consistent cleanup across all steps.

- **Services** (`services` and `definitions.services`) for running sidecar containers are translated to the [Docker Compose plugin](https://buildkite.com/resources/plugins/docker-compose-buildkite-plugin/) or documented with guidance on configuring service containers.

- **Fast-fail behavior** (`fail-fast` in parallel blocks) is translated to `cancel_on_build_failing: true` on steps that should be cancelled when the build enters a failing state.

- **Pipes** (Bitbucket's reusable integration components) require case-by-case handling. Common pipes are translated to equivalent Buildkite Pipelines [plugins](/docs/pipelines/integrations/plugins) or native commands. Pipes without direct equivalents include comments indicating manual configuration is required.
