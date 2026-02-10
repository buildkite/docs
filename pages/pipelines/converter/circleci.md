# CircleCI

The [Buildkite pipeline converter](/docs/pipelines/converter) helps you convert your CircleCI pipelines into Buildkite pipelines. Because CircleCI configurations can include complex combinations of jobs, workflows, executors, orbs, and reusable commands, an AI Large Language Model (LLM) is used to achieve the best results in the translation process.

The LLM analyzes the CircleCI configuration to understand its structure and intent, and then generates a functionally equivalent Buildkite pipeline. The AI model _does not_ use any submitted data for its own training.

The goal of the Buildkite pipeline converter is to give you a starting point, so you can see how patterns you're used to in CircleCI would function in Buildkite Pipelines. In cases where CircleCI features don't have a direct Buildkite Pipelines equivalent, the pipeline converter includes comments with suggestions about possible solutions and alternatives.

## Using the Buildkite pipeline converter with CircleCI

To start converting a CircleCI configuration into Buildkite Pipelines format:

1. Open the [Buildkite pipeline converter](https://buildkite.com/resources/convert/) in a new browser tab.
1. Ensure that **CircleCI** is selected at the top of the left panel.
1. Copy your CircleCI configuration and paste it into the left panel.
1. Select **Convert** to reveal the translated pipeline configuration in the **Buildkite Pipeline** panel.

## How the translation works

Here are some examples of translations that the Buildkite pipeline converter will perform:

- **Jobs** become Buildkite Pipelines [command steps](/docs/pipelines/configure/step-types/command-step) with `key` attributes. The `key` enables dependency references between steps. Multiple `run` steps within a job are combined into a single `command` array.

- **Workflows** are flattened into Buildkite Pipelines [step dependencies](/docs/pipelines/configure/dependencies). Job dependencies specified with `requires` become `depends_on` attributes. When multiple workflows exist, they may be organized using [group steps](/docs/pipelines/configure/step-types/group-step).

- **Checkout** steps are removed since Buildkite Agents automatically check out the repository.

- **Executors** are translated to the [Docker plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-buildkite-plugin/) configuration. The `docker[].image` becomes the plugin's `image` parameter, `resource_class` is documented for agent queue configuration, and `working_directory` becomes the plugin's `workdir` parameter.

- **Orbs** require case-by-case handling. Common orb commands are translated to equivalent Buildkite Pipelines [plugins](/docs/pipelines/integrations/plugins) or native commands. For example, AWS and GCP orb commands may translate to their respective Buildkite plugins. Orbs without direct equivalents include comments indicating manual configuration is required.

- **Matrix strategies** are translated to the native [build matrix](/docs/pipelines/configure/workflows/build-matrix) feature of Buildkite Pipelines. CircleCI's `matrix.parameters` becomes `matrix.setup`, and `matrix.exclude` becomes `matrix.adjustments` with `skip: true`.

- **Environment variables** at the job level become step-level `env` blocks. CircleCI pipeline values (such as `<< pipeline.git.revision >>`) are translated to Buildkite Pipelines equivalents (such as `${BUILDKITE_COMMIT}`).

- **Contexts** (CircleCI's secrets management mechanism) become environment variable references with comments indicating they must be configured on your agents or through a secrets manager. See [managing secrets](/docs/pipelines/security/secrets/managing) for configuration options.

- **Workspace persistence** (`persist_to_workspace` and `attach_workspace`) is translated to `buildkite-agent artifact upload` and `buildkite-agent artifact download` commands.

- **Caching** (`save_cache` and `restore_cache`) is translated to the [cache plugin](https://buildkite.com/resources/plugins/buildkite-plugins/cache-buildkite-plugin/).

- **Artifacts** (`store_artifacts`) are translated to `artifact_paths` on the step.

- **Test results** (`store_test_results`) are documented with guidance on configuring [Buildkite Test Engine](/docs/test-engine) for test analytics and insights.

- **Branch and tag filters** (`filters.branches` and `filters.tags`) are translated to step [conditionals](/docs/pipelines/configure/conditionals) using `if:` expressions.

- **Approval jobs** (jobs with `type: approval`) are translated to [block steps](/docs/pipelines/configure/step-types/block-step).

- **Parallelism** is translated using Buildkite Pipelines' native `parallelism` attribute. Test splitting with `circleci tests split` requires [Buildkite Test Engine](/docs/test-engine) for equivalent functionality.

- **Scheduled workflows** are documented with guidance on configuring [scheduled builds](/docs/pipelines/configure/workflows/scheduled-builds) through the Buildkite Pipelines web interface.

- **Reusable commands** are translated to inline scripts or YAML anchors for simple cases. Complex parameterized commands may require [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) for full flexibility.

- **Dynamic configuration** (`setup: true`) patterns are translated using [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) with `buildkite-agent pipeline upload`.
