# Migrate from GitHub Actions

This page is for people who are familiar with or already use GitHub Actions, want to migrate to the Buildkite Pipelines, and have some questions regarding the key differences between these two CI/CD platforms.

## Understand the differences

Most of the concepts are similar between GitHub Actions and Buildkite Pipelines, but there are some differences to understand about the approaches.

### System architecture

While GitHub Actions is a fully hosted CI/CD solution integrated directly into GitHub, Buildkite Pipelines uses a hybrid model:

- A software-as-a-service (SaaS) platform for visualization and management of CI/CD pipelines.
- Agents for executing jobs—hosted by you, either on-premises or in the cloud.

At a high level, Buildkite follows a similar architecture to GitHub Actions:

- A central control plane that coordinates work and displays results through a web interface.
    * **GitHub Actions:** GitHub's hosted infrastructure.
    * **Buildkite:** The _Buildkite dashboard_.
- A program that executes the work it receives from the control plane.
    * **GitHub Actions:** _Runners_ (GitHub-hosted or self-hosted).
    * **Buildkite:** _Buildkite Agents_.

However, while GitHub manages both components in GitHub Actions, Buildkite manages the control plane as a SaaS offering (through the Buildkite dashboard). This reduces the operational burden on your team, as Buildkite takes care of platform maintenance, updates, and availability. The Buildkite dashboard also handles monitoring tools like logs, user access, and notifications.

The program that executes work is called an _agent_ in Buildkite (also known as the [_Buildkite Agent_](/docs/agent/v3)). An agent is a small, reliable, and cross-platform build runner that connects your infrastructure to Buildkite. The Buildkite Agent polls Buildkite for work, runs jobs, and reports results. You can install these agents on local machines, cloud servers, or other remote machines. The Buildkite Agent code is open-source, and is [accessible from GitHub](https://github.com/buildkite/agent).

More recently, Buildkite has provided its own [hosted agents](/docs/pipelines/architecture#buildkite-hosted-architecture) feature (as an alternative to this self-hosted, hybrid architecture, described above), as a managed solution that suits smaller teams, including those wishing to get up and running with Pipelines more rapidly.

See [Buildkite Pipelines architecture](/docs/pipelines/architecture) to learn more about how you can set up Buildkite to work with your organization.

### The difference in default checkout behaviors

The Buildkite checkout process might appear slower (job and build times appearing slower) in a one-to-one migration comparison with GitHub Actions. This difference stems from default checkout strategies and Git configurations used by each platform.

> 📘
> While the following comparison focuses on GitHub Actions, if your current CI/CD platform uses shallow clones, skips LFS by default, or has other optimized checkout defaults, you'll likely notice similar differences when migrating to Buildkite Pipelines.

If you look at GitHub Actions' default checkout behavior, it:

- Uses a shallow clone with `--depth=1` so it only fetches what is necessary for the current commit or PR.
- Automatically fetches PR references and tags — so doesn't require an extra git fetch process.
- Skips Git LFS downloads unless `lfs: true` is set:

```yaml
- uses: actions/checkout@v4
  with:
    lfs: false # default
    fetch-depth: 1 # default
```

As a result, in GitHub Actions, the checkout process running on all defaults will be faster because it is shallow and LFS-free, unless explicitly requested.

Compared to GitHub Actions' default checkout behavior, in Buildkite Pipelines:

- Git LFS is enabled by default. You can override this by setting an environment variable (`GIT_LFS_SKIP_SMUDGE=1`).

```yaml
env:
  GIT_LFS_SKIP_SMUDGE: "1"
```

- Agent checks out the full working repository. Shallow clone can be configured using an environment variable or the [Git Shallow Clone plugin](https://buildkite.com/resources/plugins/peakon/git-shallow-clone-buildkite-plugin/).
- Other Buildkite plugins you can use to override or customize the default checkout behavior are:

    * [Sparse Checkout Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/sparse-checkout-buildkite-plugin/) that performs a sparse checkout so that only selected paths are fetched and checked out, reducing time and bandwidth on large repositories.
    * [Custom Checkout Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/custom-checkout-buildkite-plugin/) that overrides the default agent checkout by setting a custom `refspec` and then doing a `git lfs pull`.

- An agent checkout hook can be used to replicate some of the default checkout options used by GitHub Actions which include `--depth=1`, `--single-branch`, and `--no-recurse-submodules`.
- [Git mirrors](/docs/agent/v3/self-hosted/configure/git-mirrors) can also be used for checkout optimization, but it doesn't offer a considerable improvement in terms of checkout speed.

Understanding these differences helps you optimize your checkout strategy when migrating from GitHub Actions to Buildkite Pipelines, whether that means matching GitHub Actions' faster defaults or taking advantage of Buildkite's flexibility to customize the checkout behavior for your specific needs.

You can learn more about checkout strategies for Buildkite Pipelines in [Git checkout optimization](/docs/pipelines/best-practices/git-checkout-optimization).


### Security

Buildkite's hybrid architecture, which combines the centralized Buildkite SaaS platform with your own [self-hosted Buildkite Agents](/docs/pipelines/architecture#self-hosted-hybrid-architecture), provides a unique approach to security. Buildkite takes care of the security of the SaaS platform, including user authentication, pipeline management, and the web interface. Self-hosted Buildkite Agents, which run on your infrastructure, allow you to maintain control over the environment, security, and other build-related resources.

While Buildkite provides its own secrets management capabilities through the Buildkite platform, the Buildkite platform can also be configured so that it doesn't store your secrets. Furthermore, Buildkite does not have or need access to your source code. Only the agents you host within your infrastructure would need access to clone your repositories, and your secrets that provide this access can also be managed through secrets management tools hosted within your infrastructure.

See the [Security](/docs/pipelines/security) and [Secrets](/docs/pipelines/security/secrets) sections of these docs to learn more about how you can secure your Buildkite build environment, as well as manage secrets in your own infrastructure.

### Pipeline configuration concepts

When migrating your CI/CD pipelines from GitHub Actions to Buildkite, it's important to understand the differences in pipeline configuration concepts.

Like GitHub Actions, Buildkite lets you create pipeline definitions in the web interface or one or more related files checked into a repository. Most people prefer the latter, which allows pipeline definitions to be kept with the code base it builds, managed in source control. The equivalent of a GitHub Actions workflow file (`.github/workflows/*.yml`) in Buildkite is a `pipeline.yml`. You'll learn more about these differences further on in the [Files and syntax](#pipeline-translation-fundamentals-files-and-syntax) section.

In GitHub Actions, the core description of work is a _workflow_ containing _jobs_, each with multiple _steps_. Buildkite uses similar terms in different ways, where a _pipeline_ is the core description of work.

A Buildkite pipeline contains different types of [_steps_](/docs/pipelines/configure/step-types) for different tasks:

- **Command step:** Runs one or more shell commands on one or more agents.
- **Wait step:** Pauses a build until all previous jobs have completed.
- **Block step:** Pauses a build until unblocked.
- **Input step:** Collects information from a user.
- **Trigger step:** Creates a build on another pipeline.
- **Group step:** Displays a group of sub-steps as one parent step.

Triggering a Buildkite pipeline creates a _build_, and any command steps are dispatched as _jobs_ to run on agents. A common practice is to define a pipeline with a single step that uploads the `pipeline.yml` file in the code repository. The `pipeline.yml` contains the full pipeline definition and can be generated dynamically.

### Try out Buildkite

With a basic understanding of the differences between Buildkite and GitHub Actions, if you haven't already done so, run through the [Getting started with Pipelines](/docs/pipelines/getting-started/) guide to get yourself set up to run pipelines in Buildkite, and [create your own pipeline](/docs/pipelines/create-your-own).

## Provision agent infrastructure

Buildkite Agents:

- Are where your builds, tests, and deployments run.
- Can either run as [Buildkite hosted agents](/docs/agent/v3/buildkite-hosted), or on your infrastructure (known as _self-hosted_), providing flexibility and control over the environment and resources. Operating agents in a self-hosted environment is similar in approach to hosting self-hosted runners in GitHub Actions.

If running self-hosted Buildkite Agents, you'll need to consider the following:

- **Infrastructure type:** Agents can run on various infrastructure types, including on-premises, cloud (AWS, GCP, Azure), or container platforms (Docker, Kubernetes). Based on your analysis of the existing GitHub Actions runners, choose the infrastructure type that best suits your organization's needs and constraints.

- **Resource usage:** Agent infrastructure is similar to the requirements for self-hosted runners in GitHub Actions. Evaluate your current runner resource usage (CPU, memory, and disk space) to determine the requirements for your Buildkite Agent infrastructure.

- **Platform dependencies:** To run your pipelines, you'll need to ensure the agents have the necessary dependencies, such as programming languages, build tools, and libraries. Take note of the tools and dependencies used in your GitHub Actions workflows (via `actions/setup-*` actions or direct installation commands). This information will help you configure your Buildkite Agents.

- **Network configurations:** Review the network configurations of your current runners, including firewalls, proxy settings, and network access to external resources. The Buildkite Agent works by polling Buildkite's [agent API](/docs/apis/agent-api) over HTTPS. There is no need to forward ports or provide incoming firewall access.

- **Agent scaling:** Evaluate the number of concurrent jobs and the queue length in your GitHub Actions workflows to estimate the number of Buildkite Agents needed. Keep in mind that you can scale Buildkite Agents independently, allowing you to optimize resource usage and reduce build times.

- **Build isolation and security:** Consider using separate agents for different projects or environments to ensure build isolation and security. You can use [agent tags](/docs/agent/v3/cli/reference/start#setting-tags) and [clusters](/docs/pipelines/security/clusters) to target specific agents for specific pipeline steps, allowing for fine-grained control over agent allocation.

You'll continue to adjust the agent configuration as you monitor performance to optimize build times and resource usage for your needs.

See the [Installation](/docs/agent/v3/self-hosted/install/) guides when you're ready to install an agent and follow the instructions for your infrastructure type.

## Pipeline translation fundamentals

A pipeline is a container for modeling and defining workflows. Both GitHub Actions and Buildkite can read a pipeline (configuration) file checked into a repository, which defines a workflow.

Before translating any workflow over from GitHub Actions to Buildkite, you should be aware of the following fundamental differences in how pipelines are written, and how their steps are executed and built by agents.

### Files and syntax

This table outlines the fundamental differences in pipeline files and their syntax between GitHub Actions and Buildkite.

| Pipeline aspect | GitHub Actions | Buildkite |
|-----------------|----------------|-----------|
| **Configuration file** | `.github/workflows/*.yml` | `pipeline.yml` (typically in `.buildkite/`) |
| **Syntax** | YAML with GitHub-specific expressions | YAML |
| **Expressions** | `${{ expression }}` syntax | Shell variables and Buildkite interpolation |
| **Triggers** | Defined in workflow file (`on:` block) | Configured in Buildkite UI or API |

Buildkite's pipeline syntax is simpler and more human-readable. Furthermore, you can generate pipeline definitions at build-time with the power and flexibility of [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines).

### Step execution

By default, GitHub Actions runs jobs in parallel (unless you specify `needs`), while steps within a job run sequentially. Buildkite runs all steps in parallel by default on any available agents that can run them.

To make a Buildkite pipeline run its steps in a specific order, use the [`depends_on` attribute](/docs/pipelines/configure/dependencies#defining-explicit-dependencies) or a [`wait` step](/docs/pipelines/configure/dependencies#implicit-dependencies-with-wait-and-block). For instance, in the following Buildkite pipeline example, the `Lint` and `Test` steps are run in parallel (by default) first, whereas the `Build` step is run after the `Lint` and `Test` steps have completed.

```yaml
# Buildkite: Explicit sequencing is required to make steps run in sequence
steps:
  - label: "Lint"
    key: lint
    command: npm run lint

  - label: "Test"
    key: test
    command: npm test

  - label: "Build"
    depends_on: [lint, test] # Explicit dependency
    command: npm run build
```

### Workspace state

In GitHub Actions, all steps within a job share the same workspace. This means that dependencies installed in one step are automatically available in subsequent steps within the same job.

```yaml
# GitHub Actions: All steps in a job share the same workspace.
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm install  # Creates node_modules
      - run: npm test     # Uses the node_modules installed above
```

In Buildkite, each step is executed in a fresh workspace on potentially different agents. Therefore, artifacts from previously processed steps won't be automatically available in subsequent steps.

```yaml
# This won't work reliably in Buildkite
steps:
  - label: Install dependencies
    command: npm install

  - wait

  - label: Run tests
    command: npm test # May fail because node_modules might not be there
```

However, there are several options for sharing state between steps:

- **Reinstall per step:** Simple for fast-installing dependencies like `npm ci` (instead of `npm install`).

    ```yaml
    steps:
      - label: Run tests
        command:
          - npm ci   # (Re-)installs node_modules
          - npm test # node_modules will be available
    ```

- **Buildkite artifacts:** You can upload [build artifacts](/docs/pipelines/configure/artifacts) from one step, which can be used in a subsequently processed step. This works best with small files and build outputs.

- **Cache plugin:** Similar to `actions/cache`, you can use the [Buildkite cache plugin](https://buildkite.com/resources/plugins/buildkite-plugins/cache-buildkite-plugin/), which is ideal for larger dependencies using cloud storage (S3, GCS).

- **External storage:** Custom solutions for complex state management.

### Agent targeting

GitHub Actions uses a specification-based model with `runs-on` to select runners by labels. Conversely, Buildkite uses a pull-based agent targeting model, where agents poll queues for work using the `agents` attribute.

This pull-based agent targeting model approach provides better security (no incoming connections to agents), easier scaling (through [ephemeral agents](/docs/pipelines/glossary#ephemeral-agent)), and more resilient networking. However, this difference between GitHub Actions and Buildkite may require you to rethink your agent topology when [provisioning your agent infrastructure](#provision-agent-infrastructure).

## Translate an example GitHub Actions workflow

This section guides you through the process of translating a GitHub Actions workflow example (which builds a [Node.js](https://nodejs.org/) app) into a Buildkite pipeline. This workflow demonstrates typical features found in many GitHub Actions workflows.

### Step 1: Understand the source workflow

Consider the following GitHub Actions workflow:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20, 22]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      - run: npm ci
      - run: npm test
      - uses: actions/upload-artifact@v4
        with:
          name: coverage-${{ matrix.node-version }}
          path: coverage/

  build:
    needs: [lint, test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run build
      - uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/
```

### Step 2: Create a basic Buildkite pipeline structure

Create a `.buildkite/pipeline.yml` file in your repository. Start with a basic structure that maps each GitHub Actions job to a Buildkite step:

```yaml
steps:
  - label: "\:eslint\: Lint"
    key: lint
    command:
      - echo "Lint step placeholder"

  - label: "\:test_tube\: Test"
    key: test
    command:
      - echo "Test step placeholder"

  - label: "\:package\: Build"
    key: build
    command:
      - echo "Build step placeholder"
```

Notice the immediate differences in this pipeline syntax from GitHub Actions:

- No `on:` block—triggers are configured in the Buildkite UI or API.
- No `actions/checkout`—Buildkite checks out code automatically.
- Emoji support in labels using Buildkite's [emoji syntax](https://buildkite.com/docs/pipelines/emojis).
- Key assignment for dependency references.

### Step 3: Configure the step dependencies

The build step should run only after lint and test complete successfully. Configure explicit dependencies on the build step:

```yaml
  - label: "\:package\: Build"
    key: build
    depends_on:
      - lint
      - test
    command:
      - echo "Build step placeholder"
```

Without this [`depends_on` attribute](/docs/pipelines/configure/dependencies#defining-explicit-dependencies), all three steps would run simultaneously, due to [Buildkite's parallel-by-default behavior](#pipeline-translation-fundamentals-step-execution).

### Step 4: Add the actual commands

Replace the placeholder commands with real commands. Since Buildkite assumes tools are pre-installed on agents (or you use Docker), there's no equivalent to `actions/setup-node`:

```yaml
  - label: "\:eslint\: Lint"
    key: lint
    command:
      - npm ci
      - npm run lint
```

> 📘
> Buildkite agents should be pre-configured with required tools. Alternatively, use the [Docker plugin](https://github.com/buildkite-plugins/docker-buildkite-plugin) with an appropriate image like `node:20`.

### Step 5: Implement a build matrix

Now implement the [build matrix](/docs/pipelines/configure/workflows/build-matrix) for Node.js 18, 20, and 22:

```yaml
  - label: "\:test_tube\: Test (Node {{matrix.node_version}})"
    key: test
    matrix:
      setup:
        node_version:
          - "18"
          - "20"
          - "22"
    command:
      - npm ci
      - npm test
```

Buildkite's build matrix syntax is simpler than GitHub Actions—just specify the values in an array under `matrix.setup`. The `{{matrix.node_version}}` template variable gets replaced at runtime, creating separate jobs for each Node.js version.

### Step 6: Implement artifact collection

Now implement [build artifact](/docs/pipelines/configure/artifacts) collection to capture test coverage and build outputs using the [`artifact_paths` attribute](/docs/pipelines/configure/artifacts#upload-artifacts-with-a-command-step):

```yaml
  - label: "\:test_tube\: Test (Node {{matrix.node_version}})"
    key: test
    matrix:
      setup:
        node_version:
          - "18"
          - "20"
          - "22"
    command:
      - npm ci
      - npm test
    artifact_paths:
      - coverage/**/* # Collect test coverage
```

Buildkite provides native artifact support—no separate upload action required, just specify the glob patterns for files you want to preserve.

### Step 7: Add caching

Replace `actions/cache` (or the cache option in `actions/setup-node`) with the [cache plugin](https://github.com/buildkite-plugins/cache-buildkite-plugin):

```yaml
  - label: "\:eslint\: Lint"
    key: lint
    plugins:
      - cache:
          manifest: package-lock.json
          path: node_modules
    command:
      - npm ci
      - npm run lint
```

### Step 8: Review the complete pipeline

Here's the complete translated pipeline:

```yaml
steps:
  - label: "\:eslint\: Lint"
    key: lint
    plugins:
      - cache:
          manifest: package-lock.json
          path: node_modules
    command:
      - npm ci
      - npm run lint

  - label: "\:test_tube\: Test (Node {{matrix.node_version}})"
    key: test
    matrix:
      setup:
        node_version:
          - "18"
          - "20"
          - "22"
    plugins:
      - cache:
          manifest: package-lock.json
          path: node_modules
    command:
      - npm ci
      - npm test
    artifact_paths:
      - coverage/**/*

  - label: "\:package\: Build"
    depends_on:
      - lint
      - test
    plugins:
      - cache:
          manifest: package-lock.json
          path: node_modules
    command:
      - npm ci
      - npm run build
    artifact_paths:
      - dist/**/*
```

### Step 9: Refactor with YAML aliases

To eliminate duplication, you can use YAML aliases:

```yaml
common:
  cache: &cache
    - cache:
        manifest: package-lock.json
        path: node_modules

steps:
  - label: "\:eslint\: Lint"
    key: lint
    plugins: *cache
    command:
      - npm ci
      - npm run lint

  - label: "\:test_tube\: Test (Node {{matrix.node_version}})"
    key: test
    matrix:
      setup:
        node_version:
          - "18"
          - "20"
          - "22"
    plugins: *cache
    command:
      - npm ci
      - npm test
    artifact_paths:
      - coverage/**/*

  - label: "\:package\: Build"
    depends_on:
      - lint
      - test
    plugins: *cache
    command:
      - npm ci
      - npm run build
    artifact_paths:
      - dist/**/*
```

## Key mappings reference

This table provides quick mappings between common GitHub Actions concepts and their Buildkite equivalents:

| GitHub Actions | Buildkite |
|----------------|-----------|
| `jobs.<id>` | `steps` array item with `key: "<id>"` |
| `jobs.<id>.name` | `label` |
| `jobs.<id>.runs-on` | `agents: { queue: "..." }` |
| `jobs.<id>.env` | `env` |
| `jobs.<id>.timeout-minutes` | `timeout_in_minutes` |
| `needs` | `depends_on` |
| `continue-on-error: true` | `soft_fail: true` |
| `${{ secrets.NAME }}` | `${NAME}` (configured on agent) |
| `working-directory: ./dir` | Prepend `cd dir &&` to commands |
| `actions/upload-artifact` | `artifact_paths` on the step |
| `actions/download-artifact` | `buildkite-agent artifact download` command |
| `actions/cache` | `cache` plugin |
| `strategy.matrix` | `matrix` attribute |
| `${{ github.sha }}` | `${BUILDKITE_COMMIT}` |
| `${{ github.ref }}` | `${BUILDKITE_BRANCH}` |
| `${{ github.event.pull_request.number }}` | `${BUILDKITE_PULL_REQUEST}` |

## Translating triggers

GitHub Actions supports many webhook event triggers through the `on:` block. Buildkite natively supports:

- `push` (branches)
- `pull_request`
- `tag` (via "Build tags" setting)
- `schedule` (cron)

These are configured in the Buildkite UI under Pipeline Settings, not in the YAML file.

| GitHub Actions trigger | Buildkite configuration |
|------------------------|------------------------|
| `push` | UI → Pipeline Settings → GitHub |
| `pull_request` | UI → Pipeline Settings → GitHub |
| `schedule` | UI → Pipeline Settings → Schedules |
| `workflow_dispatch` | `input` step + "New Build" button/API |
| `release` / `create` (tags) | UI → Build tags setting |

For triggers not natively supported by Buildkite (`issues`, `issue_comment`, `workflow_run`, etc.), you can:

1. **Keep in GitHub Actions:** Best for GitHub-specific automation.
2. **Configure webhook:** Set up an endpoint to call the Buildkite API.
3. **Use trigger step:** Chain from another pipeline.

## Translating context variables

GitHub Actions provides context objects (`github.*`, `runner.*`, `env.*`). Buildkite provides environment variables:

| GitHub Actions context | Buildkite environment variable |
|------------------------|-------------------------------|
| `github.repository` | `BUILDKITE_REPO` or `BUILDKITE_PIPELINE_SLUG` |
| `github.sha` | `BUILDKITE_COMMIT` |
| `github.ref` | `BUILDKITE_BRANCH` |
| `github.ref_name` | `BUILDKITE_BRANCH` |
| `github.actor` | `BUILDKITE_BUILD_CREATOR` |
| `github.run_id` | `BUILDKITE_BUILD_ID` |
| `github.run_number` | `BUILDKITE_BUILD_NUMBER` |
| `github.job` | `BUILDKITE_STEP_KEY` |
| `github.workflow` | `BUILDKITE_PIPELINE_SLUG` |
| `github.event.pull_request.number` | `BUILDKITE_PULL_REQUEST` |

## Translating conditionals

GitHub Actions conditionals use the `if:` attribute with expressions. Buildkite also supports `if:` but with different syntax:

| GitHub Actions | Buildkite |
|----------------|-----------|
| `if: github.ref == 'refs/heads/main'` | `if: build.branch == "main"` |
| `if: github.event_name == 'push'` | `if: build.source == "webhook"` |
| `if: github.event_name == 'pull_request'` | `if: build.pull_request.id != null` |
| `if: contains(github.ref, 'release')` | `if: build.branch =~ /release/` |

For complex conditionals that can't be expressed in Buildkite's `if:` syntax, use shell conditionals in your commands or [dynamic pipeline uploads](/docs/pipelines/configure/dynamic-pipelines).

## Translating matrix builds

Buildkite has native matrix support that maps directly to GitHub Actions' `strategy.matrix`:

| GitHub Actions | Buildkite |
|----------------|-----------|
| `strategy.matrix` | `matrix.setup` |
| `strategy.matrix.include` | `matrix.adjustments` (add combinations) |
| `strategy.matrix.exclude` | `matrix.adjustments` with `skip: true` |
| `${{ matrix.<name> }}` | `{{matrix.<name>}}` |
| `continue-on-error` per matrix combo | `soft_fail` in `adjustments` |
| `fail-fast: false` | Default behavior (sibling jobs aren't cancelled) |

**Example multi-dimensional matrix:**

```yaml
# GitHub Actions
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest]
    node: [18, 20]

# Buildkite
steps:
  - label: "test {{matrix.os}} node-{{matrix.node}}"
    command: npm test
    agents:
      queue: "{{matrix.os}}"
    matrix:
      setup:
        os:
          - "linux"
          - "macos"
        node:
          - "18"
          - "20"
```

## Translating services

Convert GitHub Actions `services` to the Docker Compose plugin:

```yaml
# docker-compose.ci.yml
version: '3.8'
services:
  app:
    build: .
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      DATABASE_URL: postgres://postgres:postgres@postgres:5432/test

  postgres:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: postgres
    healthcheck:
      test: ["CMD", "pg_isready"]
      interval: 10s
      timeout: 5s
      retries: 5
```

```yaml
# Buildkite pipeline
steps:
  - label: "test"
    plugins:
      - docker-compose:
          run: app
          config: docker-compose.ci.yml
    command:
      - npm test
```

## Translating job outputs

GitHub Actions uses `$GITHUB_OUTPUT` and `jobs.<id>.outputs` to pass data between jobs. Buildkite uses meta-data:

```yaml
# GitHub Actions
jobs:
  setup:
    outputs:
      version: ${{ steps.get-version.outputs.version }}
    steps:
      - id: get-version
        run: echo "version=1.2.3" >> $GITHUB_OUTPUT

# Buildkite
steps:
  - label: "setup"
    key: "setup"
    command:
      - buildkite-agent meta-data set "version" "1.2.3"

  - label: "build"
    depends_on: "setup"
    command:
      - VERSION=$(buildkite-agent meta-data get "version")
      - echo "Building version $VERSION"
```

## Translating step summaries

GitHub Actions uses `$GITHUB_STEP_SUMMARY` to add content to the workflow summary. Buildkite uses annotations:

```yaml
# GitHub Actions
- run: echo "## Build Complete" >> $GITHUB_STEP_SUMMARY

# Buildkite
- command:
    - echo "## Build Complete" | buildkite-agent annotate --style "success"
```

## Key differences and benefits of migrating to Buildkite

This [example pipeline translation](#translate-an-example-github-actions-workflow) demonstrates several important advantages of Buildkite's approach:

- **Simpler pipeline configuration:** Buildkite YAML is straightforward with fewer special syntax rules.
- **Execution model:** Buildkite's steps are parallel by default with explicit sequencing, similar to GitHub Actions jobs but applied at the step level.
- **Native features:** Buildkite provides native artifact handling and build visualization without additional actions.
- **Agent flexibility:** Full control over your build environment with self-hosted agents.

For larger deployments, these differences become more significant:

- The fresh workspace model avoids state leakage between builds.
- The pull-based agent model simplifies scaling and security.
- Pipeline-specific plugin versioning eliminates dependency conflicts.

Be aware of common pipeline-translation mistakes, which might include:

- Forgetting about fresh workspaces (leading to missing dependencies).
- Assuming tools are installed (when you need Docker or pre-configured agents).
- Over-parallelizing interdependent steps.

## Next steps

Explore these Buildkite resources to learn more about Buildkite's features and functionality, and how to enhance your Buildkite pipelines translated from GitHub Actions:

- [Defining your pipeline steps](/docs/pipelines/defining-steps) for an advanced guide on how to configure Buildkite pipeline steps.
- [Buildkite Agent overview](/docs/agent/v3) page for more information about the Buildkite Agent and guidance on how to configure it.
- [Plugins directory](https://buildkite.com/resources/plugins/) for a catalog of Buildkite- as well as community-developed plugins to enhance your pipeline functionality.
- [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) to learn more about how to generate pipeline definitions at build-time, and how to facilitate this feature with the [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk).
- [Buildkite Agent hooks](/docs/agent/v3/self-hosted/hooks) to extend or override the default behavior of Buildkite Agents at different stages of its lifecycle.
- [Using conditions](/docs/pipelines/configure/conditionals) to run pipeline builds or steps only when specific conditions have been met.
- [Annotations](/docs/agent/v3/cli/reference/annotate) that allow you to add additional information to your build result pages using Markdown.
- [Security](/docs/pipelines/security) and [Secrets](/docs/pipelines/security/secrets) overview pages, which lead to details on how to manage secrets within your Buildkite infrastructure, as managing [permissions](/docs/pipelines/security/permissions) for your teams and Buildkite pipelines themselves.
- [Integrations](/docs/pipelines/integrations) to integrate Buildkite's functionality with other third-party tools, for example, notifications that automatically let your team know about the success of your pipeline builds.
- After configuring Buildkite Pipelines for your team, learn how to obtain actionable insights from the tests running in pipelines using [Test Engine](/docs/test-engine).

If you need further assistance with your GitHub Actions migration processes and plans, please don't hesitate to reach out to our Buildkite support team at support@buildkite.com. We're here to help you use Buildkite to build your dream CI/CD workflows.

If you would like to get a hands-on understanding of the differences and how GitHub Actions workflows map onto Buildkite Pipelines, try out the [Buildkite pipeline converter](/docs/pipelines/migration/converter/github-actions).
