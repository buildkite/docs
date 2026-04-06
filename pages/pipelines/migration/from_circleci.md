# Migrate from CircleCI

This guide helps CircleCI users migrate to Buildkite Pipelines, covering key differences between the platforms.

## Understand the differences

Most concepts translate directly, but there are differences to understand about the approaches.

### System architecture

CircleCI is a fully hosted CI/CD platform that runs jobs on CircleCI-managed or self-hosted runners.

Buildkite Pipelines uses a hybrid model:

- A SaaS platform (the _Buildkite dashboard_) for visualization and pipeline management.
- [Buildkite agents](/docs/agent) for executing jobs — through [Buildkite hosted agents](/docs/pipelines/architecture#buildkite-hosted-architecture) or through [self-hosted](/docs/pipelines/architecture#self-hosted-hybrid-architecture) agents in your own infrastructure as the [Buildkite agent](https://github.com/buildkite/agent) is open source and can run on local machines, cloud servers, or containers.

This hybrid architecture means your source code and secrets stay within your own environment and are not seen by the Buildkite platform.

Learn more about [Buildkite Pipelines architecture](/docs/pipelines/architecture).

### Security

The hybrid architecture of Buildkite Pipelines provides a unique approach to security. Buildkite Pipelines takes care of the security of the SaaS platform, including user authentication, pipeline management, and the web interface. The Buildkite agents, which run on your infrastructure, allow you to maintain control over the environment, security, and other build-related resources.

While Buildkite Pipelines provides its own secrets management capabilities, you can also configure Buildkite Pipelines so that it doesn't store your secrets. Buildkite Pipelines does not have or need access to your source code. Only the agents you host within your infrastructure would need access to clone your repositories, and your secrets that provide this access can also be managed through secrets management tools hosted within your infrastructure.

Learn more about [Security](/docs/pipelines/security) and [Secrets](/docs/pipelines/security/secrets).

### Pipeline configuration concepts

In CircleCI, the core description of work is a _workflow_ defined in `.circleci/config.yml`, containing _jobs_ with multiple _steps_. In Buildkite Pipelines, a [_pipeline_](/docs/pipelines/glossary#pipeline) is the core description of work, typically defined in a `pipeline.yml` file (usually in `.buildkite/`).

A Buildkite pipeline contains different types of [_steps_](/docs/pipelines/configure/step-types) for different tasks:

- [Command step](/docs/pipelines/configure/step-types/command-step): Runs one or more shell commands on one or more agents.
- [Wait step](/docs/pipelines/configure/step-types/wait-step): Pauses a build until all previous jobs have completed.
- [Block step](/docs/pipelines/configure/step-types/block-step): Pauses a build until unblocked.
- [Input step](/docs/pipelines/configure/step-types/input-step): Collects information from a user.
- [Trigger step](/docs/pipelines/configure/step-types/trigger-step): Creates a build on another pipeline.
- [Group step](/docs/pipelines/configure/step-types/group-step): Displays a group of sub-steps as one parent step.

While CircleCI traditionally maps each project one-to-one to a repository, Buildkite pipelines are fully decoupled from repositories. You can create multiple pipelines per repository, trigger pipelines across repositories, or run pipelines independently of any repository.

Triggering a Buildkite pipeline creates a [_build_](/docs/pipelines/glossary#build), and any command steps are dispatched as [_jobs_](/docs/pipelines/glossary#job) to run on agents. A common practice is to define a pipeline with a single step that uploads the `pipeline.yml` file in the code repository. The `pipeline.yml` contains the full pipeline definition and can be generated [dynamically](/docs/pipelines/configure/dynamic-pipelines).

### Plugin system

CircleCI uses _orbs_, which are reusable packages that bundle jobs, commands, and executors together. Buildkite Pipelines uses [Buildkite plugins](https://buildkite.com/resources/plugins/), which are referenced directly in pipeline definitions. Unlike orbs, Buildkite plugins focus on modifying agent behavior at the step level. They are shell-based, run on individual agents, and are pipeline- or step-specific with independent versioning. Plugin failures are isolated to individual builds, and compatibility issues are rare.

## Provision agent infrastructure

Buildkite agents run your builds, tests, and deployments. They can run as [Buildkite hosted agents](/docs/agent/buildkite-hosted) where the infrastructure is provided for you, or on your own infrastructure ([self-hosted](/docs/pipelines/architecture#self-hosted-hybrid-architecture)), similar to self-hosted runners in CircleCI.

For self-hosted agents, consider:

- **Infrastructure type:** On-premises, cloud ([AWS](/docs/agent/self-hosted/aws), [GCP](/docs/agent/self-hosted/gcp)), or container platforms ([Docker](/docs/agent/self-hosted/install/docker), [Kubernetes](/docs/agent/self-hosted/agent-stack-k8s)).
- **Resource usage:** Evaluate CPU, memory, and disk requirements based on your current CircleCI resource class usage.
- **Platform dependencies:** Ensure agents have required tools and libraries. Unlike CircleCI, where Docker images provide pre-configured environments, Buildkite agents require explicit tool installation or pre-built agent images.
- **Network:** Agents poll the Buildkite [agent API](/docs/apis/agent-api) over HTTPS so no incoming firewall access is needed.
- **Scaling:** Scale agents independently based on concurrent job requirements.
- **Build isolation:** Use [agent tags](/docs/agent/cli/reference/start#setting-tags) and [clusters](/docs/pipelines/security/clusters) to target specific agents.

For Buildkite hosted agents, see the [Getting started](/docs/agent/buildkite-hosted#getting-started-with-buildkite-hosted-agents) guide. For self-hosted agents, see the [Installation](/docs/agent/self-hosted/install/) guides for your infrastructure type.

## Pipeline translation fundamentals

Before translating your CircleCI configuration, understand these key differences.

### Files and syntax

This table outlines the fundamental differences in pipeline files and their syntax between CircleCI and Buildkite Pipelines.

| Pipeline aspect | CircleCI | Buildkite Pipelines |
|-----------------|----------|---------------------|
| **Configuration file** | `.circleci/config.yml` | `pipeline.yml` (typically in `.buildkite/`) |
| **Reusable logic** | Orbs, commands, executors | [Plugins](https://buildkite.com/resources/plugins/), YAML aliases, scripts |
| **Dynamic configuration** | Pipeline parameters for conditional workflows | [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) generate steps at runtime using any language |
| **Triggers** | Defined in config file or API | Configured in the web interface or API |

The YAML-based pipeline syntax of Buildkite Pipelines is simpler. Where CircleCI relies on `parameters` to conditionally include or exclude jobs and workflows, Buildkite Pipelines uses dynamic pipelines to generate the entire pipeline definition at build time using scripts written in any language. This approach provides more flexibility without the complexity of parameter declarations and conditional logic scattered throughout your configuration.

### Step execution

Both CircleCI and Buildkite Pipelines run steps in parallel by default. In CircleCI, steps within a job run sequentially, but jobs within a workflow run in parallel unless you specify `requires`. In Buildkite Pipelines, all steps run in parallel unless you add explicit ordering.

Each Buildkite step is fully isolated from other steps, similar to how CircleCI jobs are isolated from each other. Steps can run on different agents, with no shared filesystem or state between them.

To make a Buildkite pipeline run its steps in a specific order, use the [`depends_on` attribute](/docs/pipelines/configure/dependencies#defining-explicit-dependencies) or a [`wait` step](/docs/pipelines/configure/dependencies#implicit-dependencies-with-wait-and-block).

```yaml
# Buildkite Pipelines: Explicit sequencing with depends_on

steps:
  - label: "Lint"
    key: lint
    command: npm run lint

  - label: "Test"
    key: test
    command: npm test

  - label: "Build"
    depends_on: [lint, test]
    command: npm run build
```

### Workspace and artifact handling

In CircleCI, `persist_to_workspace` and `attach_workspace` share files between jobs. In Buildkite Pipelines, each step runs in a fresh workspace on potentially different agents. Use `buildkite-agent artifact upload` and `buildkite-agent artifact download` to share [artifacts](/docs/pipelines/configure/artifacts):

```yaml
# Buildkite Pipelines
steps:
  - label: "Build"
    key: "build"
    command:
      - npm run build
      - buildkite-agent artifact upload "dist/**/*"

  - label: "Deploy"
    depends_on: "build"
    command:
      - buildkite-agent artifact download "dist/**/*" .
      - npm run deploy
```

Other options for sharing state between steps:

- **Reinstall per step:** Simple for fast-installing dependencies like `npm ci`.
- **Meta-data:** Use [meta-data](/docs/pipelines/configure/build-meta-data) to exchange lightweight key-value pairs between steps at runtime without file-based sharing.
- **Cache plugin:** Similar to CircleCI's `save_cache`/`restore_cache`, use the [Buildkite cache plugin](https://buildkite.com/resources/plugins/buildkite-plugins/cache-buildkite-plugin/) for larger dependencies using cloud storage (S3, GCS). The plugin's `manifest` attribute works like CircleCI's `{{ checksum }}` to generate a cache key from a file.
- **External storage:** Custom solutions for complex state management.

> 📘 Hosted agents cache volumes
> If using Buildkite hosted agents, [cache volumes](/docs/agent/buildkite-hosted/cache-volumes) provide a simpler native caching mechanism. Cache volumes are retained up to 14 days and attached on a best-effort basis.

### Docker images and executors

CircleCI executors define the execution environment (Docker image, resource class, environment variables). Buildkite Pipelines separates these concerns:

| Executor component | Buildkite Pipelines equivalent |
|-------------------|-------------------------------|
| `docker[].image` | [Docker plugin](https://buildkite.com/resources/plugins/docker) `image` |
| `docker[].environment` | Docker plugin `environment` |
| `resource_class` | `agents: { queue: "..." }` |
| `working_directory` | Docker plugin `workdir` |
| `machine` executor | VM-based agent queue |

For example, in Buildkite Pipelines:

```yaml
# Buildkite Pipelines
steps:
  - label: "Test"
    env:
      NODE_ENV: test
    plugins:
      - docker#v5.13.0:
          image: node:18
    command: npm test
```

For Docker-based builds, use the [Docker plugin](https://buildkite.com/resources/plugins/docker) or the [Docker Compose plugin](https://buildkite.com/resources/plugins/docker-compose) to run commands inside containers.

> 🚧 CircleCI `cimg/*` images require workarounds
> CircleCI convenience images (`cimg/node`, `cimg/python`, and so on) install runtimes using version managers that require login shells. The Buildkite Docker plugin defaults to `/bin/sh -e -c`, which does not source these profiles. Add a `shell` option for bash login shells and `propagate-uid-gid: true` to avoid permission errors:
>
> ```yaml
> plugins:
>   - docker#v5.13.0:
>       image: cimg/node:18.17
>       shell: ["/bin/bash", "-l", "-e", "-c"]
>       propagate-uid-gid: true
> ```
>
> Consider replacing `cimg/*` images with standard Docker Hub images (`node:18`, `python:3.11`) which don't require these workarounds.

### Agent targeting

CircleCI uses `resource_class` and executors to control where jobs run:

```yaml
# CircleCI
jobs:
  build:
    docker:
      - image: cimg/node:20.0
    resource_class: large
    steps:
      - checkout
      - run: make build

  deploy:
    machine:
      image: ubuntu-2204:current
    resource_class: medium
    steps:
      - checkout
      - run: make deploy
```

Buildkite Pipelines uses a pull-based model where agents poll [queues](/docs/agent/queues) for work using the `agents` attribute. Map CircleCI resource classes to queues with agents sized to match your workload requirements. This model provides better security (no incoming connections), easier scaling with [ephemeral agents](/docs/pipelines/glossary#ephemeral-agent), and more resilient networking:

```yaml
# Buildkite Pipelines
steps:
  - label: "Build"
    command: "make build"
    agents:
      queue: "large"
  - label: "Deploy"
    command: "make deploy"
    agents:
      queue: "production"
```

You can also use custom [agent tags](/docs/agent/cli/reference/start#setting-tags) beyond `queue` to target agents by capability, for example `agents: { os: "linux", arch: "arm64" }`. For Windows or macOS jobs, route to platform-specific queues using `agents: { queue: "windows" }` or `agents: { queue: "macos" }`.

## Translate an example CircleCI configuration

This section guides you through the process of translating a CircleCI configuration example (which builds a [Node.js](https://nodejs.org/) app) into a Buildkite pipeline. If you want to see the finished result first, skip to the [complete pipeline](#step-7-review-the-complete-pipeline) or the [refactored version with YAML aliases](#step-8-refactor-with-yaml-aliases).

### Step 1: Understand the source configuration

The following CircleCI configuration shows an example:

```yaml
version: 2.1

orbs:
  node: circleci/node@5.2

executors:
  node-executor:
    docker:
      - image: cimg/node:20.0

jobs:
  lint:
    executor: node-executor
    steps:
      - checkout
      - node/install-packages
      - run: npm run lint

  test:
    executor: node-executor
    steps:
      - checkout
      - node/install-packages
      - run: npm test
      - store_test_results:
          path: test-results
      - store_artifacts:
          path: coverage

  build:
    executor: node-executor
    steps:
      - checkout
      - node/install-packages
      - run: npm run build
      - store_artifacts:
          path: dist

workflows:
  ci:
    jobs:
      - lint
      - test
      - build:
          requires:
            - lint
            - test
```

This workflow lints, tests, and builds a Node.js application, with the build job depending on lint and test completing first.

### Step 2: Create a basic Buildkite pipeline structure

Create a `.buildkite/pipeline.yml` file in your repository. Start with a basic structure that maps each CircleCI job to a Buildkite Pipelines step:

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

  - label: "\:wrench\: Build"
    key: build
    command:
      - echo "Build step placeholder"
```

Notice the immediate differences in this pipeline syntax from CircleCI:

- No `version:` declaration needed.
- No `orbs:`, `executors:`, or `jobs:` blocks.
- No `checkout` step—Buildkite agents check out code automatically.
- Emoji support in labels without plugins.
- Key assignment for dependency references.

### Step 3: Configure the step dependencies

The build step should run only after lint and test complete successfully. Configure explicit dependencies on the build step, which prevents it from running if either the lint or test steps fail:

```yaml
  - label: "\:wrench\: Build"
    key: build
    depends_on: [lint, test]
    command:
      - echo "Build step placeholder"
```

Without this [`depends_on` attribute](/docs/pipelines/configure/dependencies#defining-explicit-dependencies), all three steps would run simultaneously, due to the [parallel-by-default behavior of Buildkite Pipelines](#pipeline-translation-fundamentals-step-execution).

### Step 4: Add the actual commands

Replace the placeholder commands with real commands. The `node/install-packages` orb command becomes `npm ci`:

```yaml
  - label: "\:eslint\: Lint"
    key: lint
    commands:
      - npm ci
      - npm run lint
```

> 📘
> Unlike CircleCI, where orbs like `circleci/node` handle package installation, Buildkite Pipelines requires explicit commands. Tools should be pre-installed on agents or provided through Docker images.

### Step 5: Add the Docker plugin for container builds

Replace the CircleCI executor with the [Docker plugin](https://buildkite.com/resources/plugins/docker) to run commands inside a container:

```yaml
  - label: "\:eslint\: Lint"
    key: lint
    plugins:
      - docker#v5.13.0:
          image: "node:20"
    commands:
      - npm ci
      - npm run lint
```

### Step 6: Implement artifact collection

Add [artifact collection](/docs/pipelines/configure/artifacts) using the `artifact_paths` attribute. This replaces CircleCI's `store_artifacts`:

```yaml
  - label: "\:test_tube\: Test"
    key: test
    plugins:
      - docker#v5.13.0:
          image: "node:20"
    commands:
      - npm ci
      - npm test
    artifact_paths:
      - coverage/**/*
```

### Step 7: Review the complete pipeline

The complete example CircleCI pipeline translated to a Buildkite pipeline:

```yaml
steps:
  - label: "\:eslint\: Lint"
    key: lint
    plugins:
      - docker#v5.13.0:
          image: "node:20"
    commands:
      - npm ci
      - npm run lint

  - label: "\:test_tube\: Test"
    key: test
    plugins:
      - docker#v5.13.0:
          image: "node:20"
    commands:
      - npm ci
      - npm test
    artifact_paths:
      - coverage/**/*

  - label: "\:wrench\: Build"
    depends_on: [lint, test]
    plugins:
      - docker#v5.13.0:
          image: "node:20"
    commands:
      - npm ci
      - npm run build
    artifact_paths:
      - dist/**/*
```

### Step 8: Refactor with YAML aliases

Eliminate the duplication using YAML aliases:

```yaml
common:
  docker: &docker
    - docker#v5.13.0:
        image: "node:20"

steps:
  - label: "\:eslint\: Lint"
    key: lint
    plugins: *docker
    commands:
      - npm ci
      - npm run lint

  - label: "\:test_tube\: Test"
    key: test
    plugins: *docker
    commands:
      - npm ci
      - npm test
    artifact_paths:
      - coverage/**/*

  - label: "\:wrench\: Build"
    depends_on: [lint, test]
    plugins: *docker
    commands:
      - npm ci
      - npm run build
    artifact_paths:
      - dist/**/*
```

By anchoring the plugin array rather than the `plugins` key, individual steps can override or extend their plugin list when needed. The final result is shorter than the original CircleCI configuration, with no duplication and a cleaner, more readable structure.

## Translating common patterns

This section covers translation patterns for CircleCI features not covered in the [example walkthrough](/docs/pipelines/migration/from-circleci#translate-an-example-circleci-configuration).

### Environment variables

CircleCI job-level `environment` maps to the `env` attribute in Buildkite Pipelines. For more information, see [environment variables](/docs/pipelines/configure/environment-variables). For pipeline-wide variables, use a top-level `env` attribute.

You can also define environment variables at the agent level using [agent hooks](/docs/agent/hooks), making them available to all pipelines running on those agents. If you use the [Elastic CI Stack for AWS](/docs/agent/self-hosted/aws/elastic-ci-stack), you can scope agent-level variables to specific pipelines.

```yaml
# Buildkite Pipelines
env:
  NODE_ENV: production

steps:
  - label: "Build"
    command: npm run build
```

> 🚧 Docker plugin environment variables
> When using the Docker plugin, step-level `env:` variables are not automatically available inside the container. Use the Docker plugin's `environment:` list instead.

### Contexts and secrets

CircleCI contexts are named collections of environment variables attached to jobs at the workflow level. Translate based on content type:

- **For secrets:** Use Buildkite [cluster secrets](/docs/pipelines/security/secrets) with the `secrets:` attribute in pipeline YAML, or an external secrets manager.
- **For non-secret variables:** Use the `env:` attribute directly. Use YAML anchors to share variables across steps.

### Approval jobs

CircleCI's `type: approval` jobs create manual gates in a workflow. The equivalent in Buildkite Pipelines is a [block step](/docs/pipelines/configure/step-types/block-step):

```yaml
# Buildkite Pipelines
steps:
  - label: "Build"
    key: "build"
    command: npm run build

  - block: ":rocket: Deploy to production?"
    key: "hold"
    depends_on: "build"

  - label: "Deploy"
    depends_on: "hold"
    command: npm run deploy
```

### Matrix builds

CircleCI matrix jobs translate to the native [build matrix](/docs/pipelines/configure/workflows/build-matrix) support in Buildkite Pipelines:

| CircleCI | Buildkite Pipelines |
|----------|---------------------|
| `matrix.parameters` | `matrix.setup` |
| `matrix.exclude` | `matrix.adjustments` with `skip: true` |
| `<< matrix.X >>` | `{{matrix.X}}` |

```yaml
# Buildkite Pipelines
steps:
  - label: "Test (Node {{matrix.node_version}})"
    plugins:
      - docker#v5.13.0:
          image: node:{{matrix.node_version}}
    command: npm test
    matrix:
      setup:
        node_version:
          - "18"
          - "20"
          - "22"
```

### Parallelism

CircleCI's `parallelism` key maps to the [`parallelism` attribute](/docs/pipelines/configure/step-types/command-step#parallelism) in Buildkite Pipelines:

```yaml
# Buildkite Pipelines
steps:
  - label: "Test"
    parallelism: 4
    command: npm test
```

Buildkite Pipelines parallelism creates multiple jobs with `BUILDKITE_PARALLEL_JOB` and `BUILDKITE_PARALLEL_JOB_COUNT` environment variables. For intelligent test distribution based on timing data (equivalent to `circleci tests split --split-by=timings`), use [Test Engine](/docs/test-engine).

### Branch and tag filtering

Buildkite Pipelines offers two approaches to step-level filtering:

- **`branches:` attribute:** For simple patterns, with `!` prefix for negation (for example, `branches: "!dev !staging"`).
- **`if:` conditionals:** For complex patterns or regex matching (for example, `if: build.branch !~ /^feature\/experimental-/`). The `branches:` and `if:` attributes cannot be used together on the same step.

For tag-only builds, use `if: build.tag =~ /^v/`.

For pipeline-wide branch restrictions that prevent builds from being created entirely, configure this in **Pipeline Settings** under **Branch Limiting**, not in YAML.

### Scheduled workflows

CircleCI supports scheduled pipelines configured through the CircleCI UI, API, or the legacy `triggers:` key in YAML. In Buildkite Pipelines, [scheduled builds](/docs/pipelines/configure/scheduled-builds) are configured in the Buildkite UI under your pipeline's **Settings** > **Schedules**.

### Dynamic configuration

CircleCI's dynamic configuration pattern uses `setup: true` with the continuation orb to generate pipelines at runtime. Buildkite Pipelines handles this natively with `buildkite-agent pipeline upload`:

```yaml
# Buildkite Pipelines
steps:
  - label: ":pipeline: Generate pipeline"
    command: |
      ./generate-config.sh | buildkite-agent pipeline upload
```

For path-based dynamic configuration (similar to CircleCI's `path-filtering` orb), use [conditionals](/docs/pipelines/configure/conditionals), [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) with change detection logic, or the declarative [`if_changed` attribute](/docs/pipelines/configure/step-types/command-step#agent-applied-attributes). For monorepos, the [Monorepo Diff plugin](https://buildkite.com/resources/plugins/monorepo-diff) watches for changes across directories and triggers the appropriate pipelines automatically.

### Reusable commands

CircleCI `commands` are reusable step sequences with parameters. For simple reuse in Buildkite Pipelines, use [YAML anchors](/docs/pipelines/integrations/plugins/using#using-yaml-anchors-with-plugins). For parameterized reuse, use [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) where a step generates and uploads pipeline YAML at runtime using `buildkite-agent pipeline upload`.

## Concept mapping reference

This table provides a mapping between CircleCI concepts and their Buildkite Pipelines equivalents:

| CircleCI | Buildkite Pipelines |
|----------|---------------------|
| `.circleci/config.yml` | `.buildkite/pipeline.yml` |
| Workflow | Pipeline |
| Job | [Command step](/docs/pipelines/configure/step-types/command-step) |
| Step (`run:`) | Shell command within a command step |
| Executor | Agent queue or [Docker plugin](https://buildkite.com/resources/plugins/docker) |
| Orb | [Plugin](https://buildkite.com/resources/plugins/) |
| `requires` | [`depends_on`](/docs/pipelines/configure/dependencies) |
| `type: approval` | [Block step](/docs/pipelines/configure/step-types/block-step) |
| `store_artifacts` | [`artifact_paths`](/docs/pipelines/configure/artifacts) |
| `store_test_results` | [Test Engine](/docs/test-engine) |
| `persist_to_workspace` | `buildkite-agent artifact upload` |
| `attach_workspace` | `buildkite-agent artifact download` |
| `save_cache` / `restore_cache` | [Cache plugin](https://buildkite.com/resources/plugins/buildkite-plugins/cache-buildkite-plugin/) |
| `when` conditions | [Conditionals](/docs/pipelines/configure/conditionals) |
| `matrix` | [Build matrix](/docs/pipelines/configure/workflows/build-matrix) |
| Contexts | [Cluster secrets](/docs/pipelines/security/secrets) and `env` |
| `resource_class` | `agents: { queue: "..." }` |
| Serial groups (pipeline-number ordering) | [`priority`](/docs/pipelines/configure/step-types/command-step#priority) attribute |
| Scheduled workflows | [Scheduled builds](/docs/pipelines/configure/scheduled-builds) |
| Pipeline parameters (`<< pipeline.parameters.X >>`) | [Environment variables](/docs/pipelines/configure/environment-variables) or [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) |
| `setup: true` + continuation orb | `buildkite-agent pipeline upload` ([dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines)) |
| `when: always` | `depends_on` with `allow_failure: true` |
| `$CIRCLE_SHA1` | `$BUILDKITE_COMMIT` |
| `$CIRCLE_BRANCH` | `$BUILDKITE_BRANCH` |
| `$CIRCLE_BUILD_NUM` | `$BUILDKITE_BUILD_NUMBER` |
| `$CIRCLE_PR_NUMBER` | `$BUILDKITE_PULL_REQUEST` |

## Key differences and benefits of migrating to Buildkite Pipelines

This [example pipeline translation](#translate-an-example-circleci-configuration) demonstrates several important advantages of the Buildkite Pipelines approach:

- **Less boilerplate:** The Buildkite pipeline doesn't require `version`, `executors`, or `jobs` blocks, and agents check out code automatically — no explicit `checkout` step needed.
- **Emoji in step labels:** Step labels support native emoji (for example, `\:test_tube\:`) for visual identification in the dashboard.
- **Plugins replace executors and orbs:** The [Docker plugin](https://buildkite.com/resources/plugins/docker) replaces CircleCI executors, and other [plugins](https://buildkite.com/resources/plugins/) can replace orb functionality. Some orbs encapsulate significant logic, so review what each orb does and check for an equivalent plugin before replacing it with shell commands.

For larger deployments, the pull-based agent model simplifies scaling and security, since agents connect outbound to Buildkite with no incoming firewall access required.

Be aware of common pipeline-translation mistakes, which might include:

- Forgetting about fresh workspaces (leading to missing dependencies).
- Using `cimg/*` Docker images without login shell and UID/GID workarounds.
- Over-parallelizing interdependent steps.
- Assuming tools from orbs are available (when you need explicit installation).

## Next steps

Explore these resources to enhance your migrated pipelines:

- [Defining your pipeline steps](/docs/pipelines/defining-steps)
- [Buildkite agent overview](/docs/agent)
- [Plugins directory](https://buildkite.com/resources/plugins/)
- [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) and the [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk)
- [Buildkite agent hooks](/docs/agent/hooks)
- [Using conditions](/docs/pipelines/configure/conditionals)
- [Annotations](/docs/agent/cli/reference/annotate)
- [Security](/docs/pipelines/security), [Secrets](/docs/pipelines/security/secrets), and [permissions](/docs/pipelines/security/permissions)
- [Integrations](/docs/pipelines/integrations)
- [Test Engine](/docs/test-engine) for test insights

You can try the [Buildkite pipeline converter](/docs/pipelines/migration/pipeline-converter) to see how your existing CircleCI configuration might look converted to Buildkite Pipelines.

With a basic understanding of the differences between Buildkite Pipelines and CircleCI, if you haven't already done so, run through the [Getting started with Pipelines](/docs/pipelines/getting-started) guide to get yourself set up to run pipelines in Buildkite Pipelines, and [create your own pipeline](/docs/pipelines/create-your-own).

For migration assistance, contact support@buildkite.com.
