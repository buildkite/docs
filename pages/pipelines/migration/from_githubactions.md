# Migrate from GitHub Actions

This guide helps GitHub Actions users migrate to Buildkite Pipelines, covering key differences between the platforms.

## Understand the differences

### System architecture

GitHub Actions is fully hosted by GitHub. Buildkite Pipelines uses a hybrid model:

- A SaaS platform (the _Buildkite dashboard_) for visualization and pipeline management.
- [_Buildkite Agents_](/docs/agent/v3) for executing jobs—hosted by you or using [Buildkite hosted agents](/docs/pipelines/architecture#buildkite-hosted-architecture).

This separation reduces operational burden—Buildkite handles platform maintenance while you control the build environment. The [open-source agent](https://github.com/buildkite/agent) can run on local machines, cloud servers, or containers.

See [Buildkite Pipelines architecture](/docs/pipelines/architecture) for more details.

### The difference in default checkout behaviors

The Buildkite checkout process might appear slower in a one-to-one migration comparison with GitHub Actions due to different default checkout strategies.

GitHub Actions' `actions/checkout@v4` uses a shallow clone (`--depth=1`) and skips Git LFS by default. In Buildkite Pipelines:

- Git LFS is enabled by default. Disable with `GIT_LFS_SKIP_SMUDGE=1`.
- Agents check out the full repository. Configure shallow clones using the [Git Shallow Clone plugin](https://buildkite.com/resources/plugins/peakon/git-shallow-clone-buildkite-plugin/) or an agent checkout hook with `--depth=1`, `--single-branch`, and `--no-recurse-submodules`.
- Additional plugins: [Sparse Checkout](https://buildkite.com/resources/plugins/buildkite-plugins/sparse-checkout-buildkite-plugin/) and [Custom Checkout](https://buildkite.com/resources/plugins/buildkite-plugins/custom-checkout-buildkite-plugin/).

Learn more in [Git checkout optimization](/docs/pipelines/best-practices/git-checkout-optimization).


### Security

Buildkite's hybrid architecture, which combines the centralized Buildkite SaaS platform with your own [self-hosted Buildkite Agents](/docs/pipelines/architecture#self-hosted-hybrid-architecture), provides a unique approach to security. Buildkite takes care of the security of the SaaS platform, including user authentication, pipeline management, and the web interface. Self-hosted Buildkite Agents, which run on your infrastructure, allow you to maintain control over the environment, security, and other build-related resources.

While Buildkite Pipelines provides its own secrets management capabilities through the Buildkite platform, the Buildkite platform can also be configured so that it doesn't store your secrets. Furthermore, Buildkite does not have or need access to your source code. Only the agents you host within your infrastructure would need access to clone your repositories, and your secrets that provide this access can also be managed through secrets management tools hosted within your infrastructure.

See the [Security](/docs/pipelines/security) and [Secrets](/docs/pipelines/security/secrets) sections of these docs to learn more about how you can secure your Buildkite build environment, as well as manage secrets in your own infrastructure.

### Pipeline configuration concepts

Like GitHub Actions, Buildkite Pipelines lets you define pipelines in the web interface or in files checked into a repository. The equivalent of `.github/workflows/*.yml` is a `pipeline.yml` (typically in `.buildkite/`). See [Files and syntax](#pipeline-translation-fundamentals-files-and-syntax) for details.

In GitHub Actions, the core description of work is a _workflow_ containing _jobs_, each with multiple _steps_. In Buildkite, a _pipeline_ is the core description of work.

A Buildkite pipeline contains different types of [_steps_](/docs/pipelines/configure/step-types) for different tasks:

- **[Command step](/docs/pipelines/configure/step-types/command-step):** Runs one or more shell commands on one or more agents.
- **[Wait step](/docs/pipelines/configure/step-types/wait-step):** Pauses a build until all previous jobs have completed.
- **[Block step](/docs/pipelines/configure/step-types/block-step):** Pauses a build until unblocked.
- **[Input step](/docs/pipelines/configure/step-types/input-step):** Collects information from a user.
- **[Trigger step](/docs/pipelines/configure/step-types/trigger-step):** Creates a build on another pipeline.
- **[Group step](/docs/pipelines/configure/step-types/group-step):** Displays a group of sub-steps as one parent step.

Triggering a Buildkite pipeline creates a _build_, and any command steps are dispatched as _jobs_ to run on agents. A common practice is to define a pipeline with a single step that uploads the `pipeline.yml` file in the code repository. The `pipeline.yml` contains the full pipeline definition and can be generated dynamically.

## Provision agent infrastructure

Buildkite Agents run your builds, tests, and deployments. They can run as [Buildkite hosted agents](/docs/agent/v3/buildkite-hosted) or on your infrastructure (_self-hosted_), similar to GitHub Actions self-hosted runners.

For self-hosted agents, consider:

- **Infrastructure type:** On-premises, cloud (AWS, GCP, Azure), or container platforms (Docker, Kubernetes).
- **Resource usage:** Evaluate CPU, memory, and disk requirements based on your current runner usage.
- **Platform dependencies:** Ensure agents have required tools and libraries (note dependencies from `actions/setup-*` actions).
- **Network:** Agents poll Buildkite's [agent API](/docs/apis/agent-api) over HTTPS—no incoming firewall access needed.
- **Scaling:** Scale agents independently based on concurrent job requirements.
- **Build isolation:** Use [agent tags](/docs/agent/v3/cli/reference/start#setting-tags) and [clusters](/docs/pipelines/security/clusters) to target specific agents.

See the [Installation](/docs/agent/v3/self-hosted/install/) guides for your infrastructure type.

## Pipeline translation fundamentals

Before translating workflows, understand these key differences:

### Files and syntax

| Pipeline aspect | GitHub Actions | Buildkite |
|-----------------|----------------|-----------|
| **Configuration file** | `.github/workflows/*.yml` | `pipeline.yml` (typically in `.buildkite/`) |
| **Syntax** | YAML with GitHub-specific expressions | YAML |
| **Expressions** | `${{ expression }}` syntax | Shell variables and Buildkite interpolation |
| **Triggers** | Defined in workflow file (`on:` block) | Configured in Buildkite UI or API |

Buildkite's syntax is simpler. You can also generate pipeline definitions at build-time with [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines).

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

In GitHub Actions, all steps within a job share the same workspace. In Buildkite, each step runs in a fresh workspace on potentially different agents—artifacts from previous steps aren't automatically available.

Options for sharing state between steps:

- **Reinstall per step:** Simple for fast-installing dependencies like `npm ci`.
- **Buildkite artifacts:** Upload [build artifacts](/docs/pipelines/configure/artifacts) from one step for use in subsequent steps. Best for small files and build outputs.
- **Cache plugin:** Similar to `actions/cache`, use the [Buildkite cache plugin](https://buildkite.com/resources/plugins/buildkite-plugins/cache-buildkite-plugin/) for larger dependencies using cloud storage (S3, GCS).
- **External storage:** Custom solutions for complex state management.

### Agent targeting

GitHub Actions uses `runs-on` to select runners by labels. Buildkite uses a pull-based model where agents poll queues for work using the `agents` attribute. This provides better security (no incoming connections), easier scaling with [ephemeral agents](/docs/pipelines/glossary#ephemeral-agent), and more resilient networking.

## Translate an example GitHub Actions workflow

This section translates a GitHub Actions workflow (building a Node.js app) into a Buildkite pipeline.

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
      # ... artifact upload

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
      # ... artifact upload
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
> Buildkite Agents should be pre-configured with required tools. Alternatively, use the [Docker plugin](https://github.com/buildkite-plugins/docker-buildkite-plugin) with an appropriate image like `node:20`.

### Step 5: Implement a build matrix

Now, implement the [build matrix](/docs/pipelines/configure/workflows/build-matrix) for Node.js 18, 20, and 22:

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

The `{{matrix.node_version}}` template variable gets replaced at runtime, creating separate jobs for each Node.js version.

### Step 6: Implement artifact collection

Add [artifact collection](/docs/pipelines/configure/artifacts) using the `artifact_paths` attribute:

```yaml
    artifact_paths:
      - coverage/**/* # Collect test coverage
```

No separate upload action is required—just specify glob patterns.

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

For triggers not natively supported by Buildkite Pipelines (`issues`, `issue_comment`, `workflow_run`, etc.), you can:

1. **Keep in GitHub Actions:** Best for GitHub-specific automation.
2. **Configure webhook:** Set up an endpoint to call the Buildkite API.
3. **Use trigger step:** Chain from another pipeline.

## Translating context variables

GitHub Actions provides context objects (`github.*`, `runner.*`, `env.*`). Buildkite Pipelines provides environment variables:

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

GitHub Actions conditionals use the `if:` attribute with expressions. Buildkite Pipelines also supports `if:` but with different syntax:

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

GitHub Actions provides a `services` key that allows you to run containerized services (such as databases, caches, or message queues) alongside your job. These service containers are automatically started before your job runs and are accessible via their service name as a hostname.

Buildkite Pipelines handles service containers differently. Instead of a built-in `services` key, Buildkite uses the [Docker Compose plugin](https://github.com/buildkite-plugins/docker-compose-buildkite-plugin) to manage multi-container environments. This approach gives you full control over container orchestration using standard Docker Compose configuration files.

To migrate your GitHub Actions services:

1. Create a `docker-compose.ci.yml` file that defines your application and service containers.
1. Configure dependencies and health checks to ensure services are ready before your tests run.
1. Reference this configuration file in your Buildkite pipeline using the Docker Compose plugin.

The following example shows a Docker Compose configuration with a PostgreSQL service:

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

The following Buildkite pipeline configuration uses the Docker Compose plugin to run your tests. The `run` attribute specifies which service container to execute your commands in, while `config` points to your Docker Compose file. The plugin automatically starts all dependent services (in this case, PostgreSQL) and waits for health checks to pass before running your commands:

```yaml
# Buildkite pipeline
steps:
  - label: "test"
    plugins:
      - docker-compose#v5.5.0:
          run: app
          config: docker-compose.ci.yml
    command:
      - npm test
```

## Translating job outputs

GitHub Actions uses `$GITHUB_OUTPUT` and `jobs.<id>.outputs` to pass data between jobs. Buildkite Pipelines uses meta-data:

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

GitHub Actions uses `$GITHUB_STEP_SUMMARY` to add content to the workflow summary:

```yaml
# GitHub Actions
- run: echo "## Build Complete" >> $GITHUB_STEP_SUMMARY
```
Buildkite Pipelines uses [annotations](/docs/agent/v3/cli/reference/annotate):

```yaml
# Buildkite
- command:
    - echo "## Build Complete" | buildkite-agent annotate --style "success"
```

## Key differences and benefits of migrating to Buildkite Pipelines

This [example pipeline translation](#translate-an-example-github-actions-workflow) demonstrates several important advantages of Buildkite's approach:

- **Simpler pipeline configuration:** Buildkite YAML is straightforward with fewer special syntax rules.
- **Execution model:** Buildkite Pipelines' steps are parallel by default with explicit sequencing, similar to GitHub Actions jobs but applied at the step level.
- **Native features:** Buildkite Pipelines provides native artifact handling and build visualization without additional actions.
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

Explore these resources to enhance your migrated pipelines:

- [Defining your pipeline steps](/docs/pipelines/defining-steps)
- [Buildkite Agent overview](/docs/agent/v3)
- [Plugins directory](https://buildkite.com/resources/plugins/)
- [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) and the [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk)
- [Buildkite Agent hooks](/docs/agent/v3/self-hosted/hooks)
- [Using conditions](/docs/pipelines/configure/conditionals)
- [Annotations](/docs/agent/v3/cli/reference/annotate)
- [Security](/docs/pipelines/security), [Secrets](/docs/pipelines/security/secrets), and [permissions](/docs/pipelines/security/permissions)
- [Integrations](/docs/pipelines/integrations)
- [Test Engine](/docs/test-engine) for test insights

For hands-on practice, try the [Buildkite pipeline converter](/docs/pipelines/migration/converter/github-actions).

For migration assistance, contact support@buildkite.com.
