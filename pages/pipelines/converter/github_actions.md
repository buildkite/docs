# GitHub Actions

The [Buildkite pipeline converter](/docs/pipelines/converter) helps you convert your GitHub Actions workflows into Buildkite pipelines. The Buildkite pipeline converter analyzes the GitHub Actions workflow to understand its structure and intent, and then generates a functionally equivalent Buildkite pipeline.


Because GitHub Actions workflows can include complex combinations of jobs, steps, matrix strategies, and reusable actions, an AI Large Language Model (LLM) is used to get the best results in the translation process. The AI model _does not_ use any submitted data for its own training.

The goal of the Buildkite pipeline converter is to give you a starting point, so you can see how patterns you're used to in GitHub Actions would function in Buildkite Pipelines. In cases where GitHub Actions features don't have a direct Buildkite Pipelines equivalent, the pipeline converter includes comments with suggestions about possible solutions.

## Using the Buildkite pipeline converter with GitHub Actions

To start translating your existing pipeline or workflow configuration into a Buildkite pipeline using the web version:

1. Open the [Buildkite pipeline converter](https://buildkite.com/resources/convert/) in a new browser tab.
1. Select your CI/CD platform (**GitHub Actions**) from from the dropdown list.
1. In the left panel, enter the pipeline definition to translate into a Buildkite pipeline definition.
1. Click the **Convert** button to reveal the translated pipeline definition in the right panel.
1. Copy the resulting Buildkite pipeline YAML configuration on the right and [create](/docs/pipelines/configure) a [new Buildkite pipeline](https://www.buildkite.com/new) with it.

## How the translation works

Here are some examples of translations that the pipeline converter will perform:

- **Jobs** become Buildkite Pipelines [command steps](/docs/pipelines/configure/step-types/command-step) with `key` attributes. Multiple `run` steps within a job are combined into a single `command` array. Job dependencies (`needs`) become `depends_on` attributes.

- **Checkout** steps (`actions/checkout`) are removed since Buildkite Agents automatically check out the repository. Non-default checkout options are translated to equivalent Git commands.

- **Triggers** (`on:` block) are removed and documented in a header comment, since Buildkite Pipelines configures triggers through the web interface rather than YAML.

- **Runners** (`runs-on` values) are listed in a header comment with guidance on configuring your `agents` blocks to target your Buildkite Agent [queues](/docs/pipelines/clusters/manage-queues).

- **Matrix strategies** are translated to the native [build matrix](/docs/pipelines/configure/workflows/build-matrix) feature of Buildkite Pipelines, including `include`/`exclude` configurations and per-combination `soft_fail` settings.

- **Environment variables** at the workflow level become a top-level `env` block. GitHub context variables (such as `${{ github.sha }}`) are translated to Buildkite Pipelines equivalents (such as `${BUILDKITE_COMMIT}`).

- **Secrets** (such as `${{ secrets.API_KEY }}`) become environment variable references (such as `${API_KEY}`) with comments indicating they must be configured on your agents. See [managing secrets](/docs/pipelines/security/secrets/managing) for configuration options.

- **Actions** require case-by-case handling. Setup actions assume tools are pre-installed on agents. Cache and artifact actions are translated to Buildkite Pipelines [plugins](/docs/pipelines/integrations/plugins) and commands. GitHub-specific actions (such as `github-script` or `codeql`) may require custom solutions in Buildkite Pipelines - [contact](mailto:support@buildkite.com) the Buildkite Support team for assistance.

- **Path filtering** (`paths`, `paths-ignore`, or `dorny/paths-filter`) is translated to `if_changed` attribute in Buildkite Pipelines.

- **Job outputs** (`$GITHUB_OUTPUT`, `jobs.<id>.outputs`) are translated to `buildkite-agent meta-data set/get` commands. Step summaries (`$GITHUB_STEP_SUMMARY`) become `buildkite-agent annotate` commands.
