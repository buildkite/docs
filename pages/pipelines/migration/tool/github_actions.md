# GitHub Actions

The [Buildkite migration tool](/docs/pipelines/migration/tool) helps you convert your GitHub Actions workflows into Buildkite pipelines. Because GitHub Actions workflows can include complex combinations of jobs, steps, matrix strategies, and reusable actions, we use an AI Large Language Model (LLM) to get the best results in the translation process.

The LLM analyzes the GitHub Actions workflow to understand its structure and intent, and then generates a functionally equivalent Buildkite pipeline. The AI model _does not_ use any submitted data for its own training.

The goal of the migration tool is to give you a starting point, so you can see how patterns you're used to in GitHub Actions would function in Buildkite. Where GitHub Actions features don't have a direct Buildkite equivalent, the migration tool includes comments with suggestions about possible solutions.

## Using the Buildkite migration tool with GitHub Actions

To start converting a GitHub Actions workflow into Buildkite Pipelines format:

1. Open the [Buildkite migration interactive web tool](https://buildkite.com/resources/migrate/) in a new browser tab.
1. Ensure that **GitHub Actions** is selected at the top of the left panel.
1. Copy your GitHub Actions workflow configuration and paste it into the left panel.
1. Select **Convert** to reveal the translated pipeline configuration in the **Buildkite Pipeline** panel.

## How the translation works

Here are some examples of translations that the migration tool will perform:

- **Jobs** become Buildkite [command steps](/docs/pipelines/configure/step-types/command-step) with `key` attributes. Multiple `run` steps within a job are combined into a single `command` array. Job dependencies (`needs`) become `depends_on` attributes.

- **Checkout** steps (`actions/checkout`) are removed since Buildkite agents automatically check out the repository. Non-default checkout options are translated to equivalent git commands.

- **Triggers** (`on:` block) are removed and documented in a header comment, since Buildkite configures triggers through the UI rather than YAML.

- **Runners** (`runs-on` values) are listed in a header comment with guidance on configuring your `agents` blocks to target your Buildkite agent queues.

- **Matrix strategies** are translated to Buildkite's native [build matrix](/docs/pipelines/configure/workflows/build-matrix) feature, including `include`/`exclude` configurations and per-combination `soft_fail` settings.

- **Environment variables** at the workflow level become a top-level `env` block. GitHub context variables (such as `${{ github.sha }}`) are translated to Buildkite equivalents (such as `${BUILDKITE_COMMIT}`).

- **Secrets** (such as `${{ secrets.API_KEY }}`) become environment variable references (such as `${API_KEY}`) with comments indicating they must be configured on your agents. See [managing secrets](/docs/pipelines/security/secrets/managing) for configuration options.

- **Actions** require case-by-case handling. Setup actions assume tools are pre-installed on agents. Cache and artifact actions are translated to Buildkite plugins and commands. GitHub-specific actions (such as `github-script` or `codeql`) may require custom solutions in Buildkite - our Support team can assist with this.

- **Path filtering** (`paths`, `paths-ignore`, or `dorny/paths-filter`) is translated to Buildkite's `if_changed` attribute.

- **Job outputs** (`$GITHUB_OUTPUT`, `jobs.<id>.outputs`) are translated to `buildkite-agent meta-data set/get` commands. Step summaries (`$GITHUB_STEP_SUMMARY`) become `buildkite-agent annotate` commands.
