# Buildkite pipeline converter overview

The Buildkite pipeline converter serves as a compatibility layer, allowing you to try conversion of your existing CI configurations into a format compatible with Buildkite's pipeline definitions.

Rather than serving as a complete automated migration solution, the Buildkite pipeline converter demonstrates how configurations from these other CI/CD platforms could be structured in a Buildkite pipeline configuration format.

An AI Large Language Model (LLM) is used to achieve the best results in the translation process. The AI model _does not_ use any submitted data for its own training.

## CLI Buildkite pipeline converter

The [Buildkite CLI](/docs/platform/cli) provides the `bk pipeline convert` command, which lets you convert CI configurations from supported providers directly from your terminal. This is the recommended way to use the pipeline converter as part of a migration workflow.

### How to use the CLI Buildkite pipeline converter

To convert an existing CI configuration, use the [`bk pipeline convert` command](/docs/platform/cli/reference/pipeline#convert-pipeline) from the [Buildkite CLI](/docs/platform/cli).

1. [Install the Buildkite CLI](/docs/platform/cli/installation) if you haven't already:

    ```bash
    brew install buildkite/buildkite/bk
    ```

1. Run the `bk pipeline convert` command, specifying the path to your CI configuration file with `--file` and the originating CI provider with `--vendor`:

    ```bash
    # For a GitHub Actions workflow
    bk pipeline convert -F .github/workflows/ci.yml

    # Alternatively
    bk pipeline convert --file .github/workflows/ci.yml --vendor github

    # If you want to specify a custom output path and filename
    bk pipeline convert --file .github/workflows/ci.yml --vendor github -o .buildkite/custom-converted-pipeline-name.yml

    ```

    Supported vendors: `github`, `bitbucket`, `circleci`, `jenkins`, `gitlab`, `harness`, `bitrise`.

    If the converter can detect the vendor from the file path, you can omit the `--vendor` flag.

1. On a successful conversion, by default, the output is saved to `.buildkite/`:

    ```bash
    Submitting conversion job...
    Job submitted. Processing conversion...

    ✅ conversion completed successfully!
    Output saved to: .buildkite/pipeline.github.yml
    ```

In addition to the `--vendor` and `--output` (`-o`), other supported flags include `--timeout` and `--debug`. For more information and flag usage examples, see the CLI reference for [`bk pipeline convert` command](/docs/platform/cli/reference/pipeline#convert-pipeline).

### Compatibility

The Buildkite pipeline converter Supports the following CI providers:

- [GitHub Actions](/docs/pipelines/migration/tool/github-actions)
- [CircleCI](/docs/pipelines/migration/tool/circleci)
- [Bitbucket Pipelines](/docs/pipelines/migration/tool/bitbucket-pipelines)
- [Jenkins](/docs/pipelines/migration/tool/jenkins)
- Bitrise (beta)
- GitLab CI (beta)
- Harness (beta)

### Example conversion

The following GitHub Actions workflow:

```yaml
name: Node.js CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [18.x, 20.x]

    steps:
    - uses: actions/checkout@v4

    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'

    - name: Install dependencies
      run: npm ci

    - name: Run linter
      run: npm run lint

    - name: Run tests
      run: npm test

    - name: Build application
      run: npm run build

```

Will be converted by the Buildkite pipeline converter into the following Buildkite pipeline:

```yaml
# ============================================================================
# Translated from: Node.js CI
# ============================================================================
#
# TRIGGERS: Configure in Buildkite UI → Pipeline Settings → GitHub
#   - Push to branches: main, develop
#   - Pull requests to: main
#
# AGENT CONFIGURATION REQUIRED
# ============================================================================
# The original workflow used the following GitHub Actions runners:
#
#   Job                  | runs-on
#   ---------------------|----------------
#   build                | ubuntu-latest
#
# You must configure Buildkite agents to handle these workloads. Add an
# `agents` block to each step once your queues are set up. Example:
#
#   agents:
#     queue: "linux"
#
# Required tools on agents: Node.js 18.x, 20.x, npm
# Alternatively, use the Docker plugin with appropriate images.
# ============================================================================

steps:
  - label: ":nodejs: Build & Test node-{{matrix.node}}"
    key: "build-node-{{matrix.node}}"
    # Assumes Node.js is installed on the agent.
    # If not available, use the Docker plugin:
    #   plugins:
    #     - docker#5.13.0:
    #         image: "node:{{matrix.node}}"
    #         propagate-environment: true
    plugins:
      - cache#1.8.1:
          manifest: package-lock.json
          path: node_modules
          restore: pipeline
          save: pipeline
    command: |
      npm ci
      npm run lint
      npm test
      npm run build
    matrix:
      setup:
        node:
          - "18.x"
          - "20.x"
```

## Interactive web version

For a quick try of the Buildkite pipeline converter, you can also use the [interactive web version](https://buildkite.com/resources/convert/).

<%= image "pipeline-converter-web.png", alt: "Buildkite pipeline converter's web UI" %>

### How to use the web Buildkite pipeline converter

To start translating your existing pipeline or workflow configuration into a Buildkite pipeline using the web version:

1. Open the [Buildkite pipeline converter](https://buildkite.com/resources/convert/) in a new browser tab.
1. Select your CI/CD platform from the dropdown list.
1. In the left panel, enter the pipeline definition to translate into a Buildkite pipeline definition.
1. Click the **Convert** button to reveal the translated pipeline definition in the right panel.
1. Copy the resulting Buildkite pipeline YAML configuration on the right and [create](/docs/pipelines/configure) a [new Buildkite pipeline](https://www.buildkite.com/new) with it.

> 🚧 Conversion errors
> If the pipeline configuration you are trying to convert to a Buildkite pipeline contains syntax or other errors or is not a valid pipeline configuration, you will see an error message _"This doesn't look like valid YAML. Please paste your pipeline configuration."_ In this case, ensure that the original pipeline configuration you are translating to a Buildkite pipeline is a valid pipeline definition for the CI/CD platform you are migrating from.

## Next steps

The Buildkite pipeline converter can be used as a standalone tool or potentially integrated into your [Buildkite Migration Services](https://buildkite.com/resources/migrations/) process, offering a way to leverage existing CI configurations within the Buildkite ecosystem.

For more tools and recommendations regarding migrating from your existing CI/CD platform to Buildkite, see:

- [Migrate to Buildkite Pipelines](/docs/pipelines/migration)
- [Migration from GitHub Actions - a step-by-step guide](/docs/pipelines/migration/from-githubactions)
- [Migration from Jenkins - a step-by-step guide](/docs/pipelines/migration/from-jenkins)
- [Migration from Bamboo - a step-by-step guide](/docs/pipelines/migration/from-bamboo)
