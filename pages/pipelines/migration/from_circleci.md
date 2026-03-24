# Migrate from CircleCI

This guide is for people who are familiar with or already use [CircleCI](https://circleci.com) and want to migrate to Buildkite Pipelines.

Buildkite Pipelines is a modern and flexible continuous integration and deployment (CI/CD) platform that provides a powerful and scalable build infrastructure for your applications.

While CircleCI and Buildkite Pipelines have similar goals as CI/CD platforms, their approach differs. Buildkite Pipelines uses a hybrid model consisting of the following:

- A software-as-a-service (SaaS) platform for visualization and management of CI/CD pipelines.
- Agents for executing jobs—hosted by you, either on-premises or in the cloud.

Follow the steps in this guide for a smooth migration from CircleCI to Buildkite Pipelines.

## Understand the differences

Most concepts translate directly, but there are some differences to understand about the approaches.

### System architecture

CircleCI is a fully hosted CI/CD platform that runs jobs on CircleCI-managed or self-hosted runners.

Buildkite Pipelines uses a hybrid model:

- A SaaS platform (the _Buildkite dashboard_) for visualization and pipeline management.
- [Buildkite agents](/docs/agent) for executing jobs — through [Buildkite hosted agents](/docs/pipelines/architecture#buildkite-hosted-architecture) or through [self-hosted](/docs/pipelines/architecture#self-hosted-hybrid-architecture) agents in your own infrastructure as the [Buildkite agent](https://github.com/buildkite/agent) is open source and can run on local machines, cloud servers, or containers.

The program that executes work is called an _agent_ in Buildkite (also known as the [_Buildkite agent_](/docs/agent)). An agent is a small, reliable, and cross-platform build runner that connects your infrastructure to Buildkite. The Buildkite agent polls Buildkite for work, runs jobs, and reports results.

This hybrid architecture means your source code and secrets stay within your own environment and are not seen by the Buildkite platform.

More recently, Buildkite has provided its own [hosted agents](/docs/pipelines/architecture#buildkite-hosted-architecture) feature (as an alternative to this self-hosted, hybrid architecture), as a managed solution that suits smaller teams, including those wishing to get up and running with Pipelines more rapidly.

See [Buildkite Pipelines architecture](/docs/pipelines/architecture) for more details.

### Security

The hybrid architecture of Buildkite Pipelines, which combines the centralized Buildkite SaaS platform with your own Buildkite agents, provides a unique approach to security. Buildkite takes care of the security of the SaaS platform, including user authentication, pipeline management, and the web interface. The Buildkite agents, which run on your infrastructure, allow you to maintain control over the environment, security, and other build-related resources.

While Buildkite Pipelines provides its own secrets management capabilities, you are also able to configure Buildkite Pipelines so that it doesn't store your secrets. Buildkite Pipelines does not have or need access to your source code. Only the agents you host within your infrastructure would need access to clone your repositories, and your secrets that provide this access can also be managed through secrets management tools hosted within your infrastructure.

See the [Security](/docs/pipelines/security) and [Secrets](/docs/pipelines/security/secrets) sections to learn more.

### Pipeline configuration concepts

In CircleCI, the core description of work is a _workflow_ defined in `.circleci/config.yml`, containing _jobs_ with multiple _steps_. In Buildkite Pipelines, a [_pipeline_](/docs/pipelines/glossary#pipeline) is the core description of work, typically defined in a `pipeline.yml` file (usually in `.buildkite/`).

A Buildkite pipeline contains different types of [_steps_](/docs/pipelines/configure/step-types) for different tasks:

- [Command step](/docs/pipelines/configure/step-types/command-step): Runs one or more shell commands on one or more agents.
- [Wait step](/docs/pipelines/configure/step-types/wait-step): Pauses a build until all previous jobs have completed.
- [Block step](/docs/pipelines/configure/step-types/block-step): Pauses a build until unblocked.
- [Input step](/docs/pipelines/configure/step-types/input-step): Collects information from a user.
- [Trigger step](/docs/pipelines/configure/step-types/trigger-step): Creates a build on another pipeline.
- [Group step](/docs/pipelines/configure/step-types/group-step): Displays a group of sub-steps as one parent step.

Triggering a Buildkite pipeline creates a [_build_](/docs/pipelines/glossary#build), and any command steps are dispatched as [_jobs_](/docs/pipelines/glossary#job) to run on agents. A common practice is to define a pipeline with a single step that uploads the `pipeline.yml` file in the code repository. The `pipeline.yml` contains the full pipeline definition and can be generated [dynamically](/docs/pipelines/configure/dynamic-pipelines).

### Plugin system

Plugins are an essential part of both CircleCI and Buildkite, and they help you extend these products to further customize your CI/CD workflows.

CircleCI uses _orbs_, which are reusable packages that bundle jobs, commands, and executors together. Orbs are managed through CircleCI's registry and can include complex multi-step logic.

Buildkite uses [plugins](https://buildkite.com/resources/plugins/), which are referenced directly in pipeline definitions. Unlike orbs, Buildkite plugins focus on modifying agent behavior at the step level. They are shell-based, run on individual agents, and are pipeline- or step-specific with independent versioning. Plugin failures are isolated to individual builds, and compatibility issues are rare.

Common orb translations:

| Orb command | Buildkite equivalent |
|-------------|---------------------|
| `node/install-packages` | `npm ci` or cache plugin + `npm ci` |
| `docker/build` | `docker build` command |
| `docker/push` | `docker push` command |
| `aws-cli/setup` | AWS CLI pre-installed on agent |
| `slack/notify` | [Slack notification plugin](https://buildkite.com/resources/plugins/hasura/slack-notification) or `curl` to webhook |
| `continuation/continue` | `buildkite-agent pipeline upload` |

### Try out Buildkite

With a basic understanding of the differences between Buildkite and CircleCI, if you haven't already done so, run through the [Getting started with Pipelines](/docs/pipelines/getting-started) guide to get yourself set up to run pipelines in Buildkite, and [create your own pipeline](/docs/pipelines/create-your-own).

## Provision agent infrastructure

Buildkite agents run your builds, tests, and deployments. They can run as [Buildkite hosted agents](/docs/agent/buildkite-hosted) where the infrastructure is provided for you, or on your own infrastructure ([self-hosted](/docs/pipelines/architecture#self-hosted-hybrid-architecture)), similar to self-hosted runners in CircleCI.

For self-hosted agents, consider:

- **Infrastructure type:** On-premises, cloud ([AWS](/docs/agent/self-hosted/aws), [GCP](/docs/agent/self-hosted/gcp)), or container platforms ([Docker](/docs/agent/self-hosted/install/docker), [Kubernetes](/docs/agent/self-hosted/agent-stack-k8s)).
- **Resource usage:** Evaluate CPU, memory, and disk requirements based on your current CircleCI resource class usage.
- **Platform dependencies:** Ensure agents have required tools and libraries. Unlike CircleCI, where Docker images provide pre-configured environments, Buildkite agents require explicit tool installation or pre-built agent images.
- **Network:** Agents poll Buildkite's [agent API](/docs/apis/agent-api) over HTTPS so no incoming firewall access is needed.
- **Scaling:** Scale agents independently based on concurrent job requirements.
- **Build isolation:** Use [agent tags](/docs/agent/cli/reference/start#setting-tags) and [clusters](/docs/pipelines/security/clusters) to target specific agents.

See the [Getting started](/docs/agent/buildkite-hosted#getting-started-with-buildkite-hosted-agents) guide for Buildkite hosted agents or [Installation](/docs/agent/self-hosted/install/) guides for your infrastructure type for self-hosted agents.

## Pipeline translation fundamentals

Before translating your CircleCI configuration, understand these key differences.

### Files and syntax

This table outlines the fundamental differences in pipeline files and their syntax between CircleCI and Buildkite Pipelines.

| Pipeline aspect | CircleCI | Buildkite Pipelines |
|-----------------|----------|---------------------|
| **Configuration file** | `.circleci/config.yml` | `pipeline.yml` (typically in `.buildkite/`) |
| **Syntax** | YAML with CircleCI-specific keys | YAML |
| **Reusable logic** | Orbs, commands, executors | [Plugins](https://buildkite.com/resources/plugins/), YAML aliases, scripts |
| **Triggers** | Defined in config file or API | Configured in Buildkite UI or API |

The YAML-based pipeline syntax of Buildkite Pipelines is simpler and more human-readable. You can also generate pipeline definitions at build-time with [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines).

### Step execution

By default, CircleCI runs jobs within a workflow in parallel (unless you specify `requires`), while steps within a job run sequentially. Buildkite Pipelines runs all steps in parallel by default, on any available agents that can run them.

To make a Buildkite pipeline run its steps in a specific order, use the [`depends_on` attribute](/docs/pipelines/configure/dependencies#defining-explicit-dependencies) or a [`wait` step](/docs/pipelines/configure/dependencies#implicit-dependencies-with-wait-and-block).

In CircleCI, you express dependencies between jobs using `requires`:

```yaml
# CircleCI: Job dependencies with requires
workflows:
  build-and-test:
    jobs:
      - lint
      - test
      - build:
          requires:
            - lint
            - test
```

The equivalent in Buildkite Pipelines uses `depends_on`:

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

In CircleCI, `persist_to_workspace` and `attach_workspace` share files between jobs. Steps within a single job share the same working directory.

In Buildkite Pipelines, each step runs in a fresh workspace on potentially different agents. Artifacts from previous steps are not automatically available.

CircleCI workspaces translate to Buildkite artifacts using `buildkite-agent artifact upload` and `buildkite-agent artifact download`:

```yaml
# CircleCI
jobs:
  build:
    steps:
      - run: npm run build
      - persist_to_workspace:
          root: .
          paths:
            - dist/

  deploy:
    steps:
      - attach_workspace:
          at: .
      - run: npm run deploy

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

> 📘 Artifact tips
> For large directory trees, use tar and compression for faster upload and download. When matrix jobs produce overlapping paths, namespace artifacts by matrix value to avoid overwrites.

Other options for sharing state between steps:

- **Reinstall per step:** Simple for fast-installing dependencies like `npm ci`.
- **Cache plugin:** Similar to CircleCI's `save_cache`/`restore_cache`, use the [Buildkite cache plugin](https://buildkite.com/resources/plugins/buildkite-plugins/cache-buildkite-plugin/) for larger dependencies using cloud storage (S3, GCS).
- **External storage:** Custom solutions for complex state management.

#### Caching

CircleCI caches (for persisting dependencies across builds) translate to the Buildkite [cache plugin](https://buildkite.com/resources/plugins/buildkite-plugins/cache-buildkite-plugin/):

```yaml
# CircleCI
jobs:
  build:
    steps:
      - restore_cache:
          keys:
            - v1-deps-{{ checksum "package-lock.json" }}
            - v1-deps-
      - run: npm ci
      - save_cache:
          key: v1-deps-{{ checksum "package-lock.json" }}
          paths:
            - node_modules

# Buildkite Pipelines
steps:
  - label: "Build"
    plugins:
      - cache#v1.10.0:
          manifest: package-lock.json
          path: node_modules
          restore: file
          save: file
    command:
      - npm ci
```

The `manifest` attribute works like CircleCI's `{{ checksum }}` to generate a cache key from a file. The `restore` and `save` attributes control caching levels (`file`, `step`, `branch`, `pipeline`, `all`).

CircleCI's fallback key pattern (exact match, then prefix) maps to the cache plugin's hierarchical restore levels:

```yaml
# Buildkite Pipelines: restore checks levels in order (file → step → branch → pipeline)
plugins:
  - cache#v1.10.0:
      manifest: package-lock.json
      path: node_modules
      restore: pipeline
      save: file
```

> 📘 Hosted agents cache volumes
> If using Buildkite hosted agents, [cache volumes](/docs/agent/buildkite-hosted/cache-volumes) provide a simpler native caching mechanism. Cache volumes are retained up to 14 days and attached on a best-effort basis.

### Docker images and executors

CircleCI executors define the execution environment (Docker image, machine type, environment variables). Buildkite Pipelines separates these concerns:

| Executor component | Buildkite Pipelines equivalent |
|-------------------|-------------------------------|
| `docker[].image` | [Docker plugin](https://buildkite.com/resources/plugins/docker) `image` |
| `docker[].environment` | Docker plugin `environment` |
| `resource_class` | `agents: { queue: "..." }` |
| `working_directory` | Docker plugin `workdir` |

```yaml
# CircleCI
executors:
  node-executor:
    docker:
      - image: cimg/node:18.17
    resource_class: medium
    environment:
      NODE_ENV: test

jobs:
  test:
    executor: node-executor
    steps:
      - run: npm test

# Buildkite Pipelines
steps:
  - label: "Test"
    env:
      NODE_ENV: test
    plugins:
      - docker#v5.12.0:
          image: node:18
    command: npm test
```

For Docker-based builds, use the [Docker plugin](https://buildkite.com/resources/plugins/docker) or the [Docker Compose plugin](https://buildkite.com/resources/plugins/docker-compose) to run commands inside containers.

> 🚧 CircleCI `cimg/*` images require a login shell
> CircleCI convenience images (`cimg/node`, `cimg/python`, `cimg/ruby`, and so on) install language runtimes using version managers like `nvm`, `pyenv`, or `rvm`. These configure the PATH in shell profile files that are only sourced by login shells. The Buildkite Docker plugin defaults to `/bin/sh -e -c`, which does not source these profiles, causing commands like `node` or `python` to fail.
>
> Add the `shell` option to use a bash login shell:
>
> ```yaml
> plugins:
>   - docker#v5.12.0:
>       image: cimg/node:18.17
>       shell:
>         - "/bin/bash"
>         - "-l"
>         - "-e"
>         - "-c"
> ```
>
> Alternatively, use standard Docker Hub images (`node:18`, `python:3.11`, `ruby:3.2`) which install runtimes directly in the system PATH and don't require login shells.

> 🚧 CircleCI `cimg/*` images require UID/GID propagation
> CircleCI `cimg/*` images run as a non-root user (`circleci`, UID 3434). When the Buildkite Docker plugin mounts the checkout directory, it may be owned by a different UID, causing permission errors. Add `propagate-uid-gid: true` to run the container as the same UID/GID as the host:
>
> ```yaml
> plugins:
>   - docker#v5.12.0:
>       image: cimg/node:18.17
>       shell: ["/bin/bash", "-l", "-e", "-c"]
>       propagate-uid-gid: true
> ```

> 📘 Replacing `cimg/*` images
> During initial migration, it's reasonable to keep `cimg/*` images to minimize changes. However, consider replacing them with standard Docker Hub images (`node:18`, `python:3.11`, `ruby:3.2`, and so on) as a follow-up task. Standard images don't require login shell workarounds, don't have UID/GID permission issues, and are more portable across CI platforms.

### Machine executor and remote Docker

CircleCI's `machine` executor runs jobs on a dedicated VM instead of inside a Docker container. The `setup_remote_docker` step creates a remote Docker environment when running inside a Docker executor.

In Buildkite Pipelines, agents typically run on VMs where Docker is available natively. Translate both patterns by routing jobs to a VM-based agent queue:

```yaml
# CircleCI
jobs:
  integration-test:
    machine:
      image: ubuntu-2404:2024.04.4
    steps:
      - run: docker-compose up -d
      - run: ./run-integration-tests.sh

# Buildkite Pipelines
steps:
  - label: "Integration test"
    agents:
      queue: "linux-vm"
    commands:
      - docker-compose up -d
      - ./run-integration-tests.sh
```

No `checkout` step or `setup_remote_docker` step is needed. Buildkite agents check out code automatically and have Docker available on VM-based agents.

### Agent targeting

CircleCI uses `resource_class` and executors to define where jobs run:

```yaml
# CircleCI: Executor configuration
executors:
  node-executor:
    docker:
      - image: cimg/node:20.0
    resource_class: medium
```

Buildkite Pipelines uses a pull-based model where agents poll queues for work using the `agents` attribute. This provides better security (no incoming connections), easier scaling with [ephemeral agents](/docs/pipelines/glossary#ephemeral-agent), and more resilient networking:

```yaml
# Buildkite Pipelines: Agent targeting with queues
steps:
  - label: "Build"
    command: "make build"
    agents:
      queue: "default"
  - label: "Deploy"
    command: "make deploy"
    agents:
      queue: "production"
```

## Translate an example CircleCI configuration

This section guides you through the process of translating a CircleCI configuration example (which builds a [Node.js](https://nodejs.org/) app) into a Buildkite pipeline.

### Step 1: Understand the source configuration

Consider the following CircleCI configuration:

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
      - docker#v5.12.0:
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
      - docker#v5.12.0:
          image: "node:20"
    commands:
      - npm ci
      - npm test
    artifact_paths:
      - coverage/**/*
```

No separate upload step is required—just specify glob patterns.

### Step 7: Review the complete pipeline

Here is the complete translated pipeline:

```yaml
steps:
  - label: "\:eslint\: Lint"
    key: lint
    plugins:
      - docker#v5.12.0:
          image: "node:20"
    commands:
      - npm ci
      - npm run lint

  - label: "\:test_tube\: Test"
    key: test
    plugins:
      - docker#v5.12.0:
          image: "node:20"
    commands:
      - npm ci
      - npm test
    artifact_paths:
      - coverage/**/*

  - label: "\:wrench\: Build"
    depends_on: [lint, test]
    plugins:
      - docker#v5.12.0:
          image: "node:20"
    commands:
      - npm ci
      - npm run build
    artifact_paths:
      - dist/**/*
```

While this Buildkite pipeline YAML is substantially shorter than the original CircleCI configuration, there is still clear duplication in the Docker plugin configuration.

### Step 8: Refactor with YAML aliases

Eliminate the duplication using YAML aliases. This refactoring maintains the same functionality while improving the pipeline's maintainability:

```yaml
common:
  docker: &docker
    plugins:
      - docker#v5.12.0:
          image: "node:20"

steps:
  - label: "\:eslint\: Lint"
    key: lint
    <<: *docker
    commands:
      - npm ci
      - npm run lint

  - label: "\:test_tube\: Test"
    key: test
    <<: *docker
    commands:
      - npm ci
      - npm test
    artifact_paths:
      - coverage/**/*

  - label: "\:wrench\: Build"
    depends_on: [lint, test]
    <<: *docker
    commands:
      - npm ci
      - npm run build
    artifact_paths:
      - dist/**/*
```

The final result is shorter than the original CircleCI configuration, with no duplication and a cleaner, more readable structure.

## Translating common patterns

This section covers translation patterns for CircleCI features not covered in the [example walkthrough](#translate-an-example-circleci-configuration).

### Environment variables

CircleCI job-level `environment` maps to the `env` attribute in Buildkite Pipelines. CircleCI contexts (named collections of environment variables configured in the UI) translate to either Buildkite [cluster secrets](/docs/pipelines/security/secrets) or inline `env` values:

```yaml
# CircleCI
jobs:
  build:
    environment:
      NODE_ENV: production
      API_URL: https://api.example.com
    steps:
      - run: npm run build

# Buildkite Pipelines
steps:
  - label: "Build"
    env:
      NODE_ENV: production
      API_URL: https://api.example.com
    command: npm run build
```

For pipeline-wide environment variables, use a top-level `env` attribute:

```yaml
# Buildkite Pipelines: pipeline-level env
env:
  NODE_ENV: production

steps:
  - label: "Build"
    command: npm run build
```

> 🚧 Docker plugin environment variables
> When using the Docker plugin, step-level `env:` variables are not automatically available inside the container. Use explicit assignment in the Docker plugin's `environment:` list instead:
>
> ```yaml
> plugins:
>   - docker#v5.12.0:
>       image: node:20
>       environment:
>         - NODE_ENV=production
> ```

### Contexts and secrets

CircleCI contexts are named collections of environment variables attached to jobs at the workflow level. Buildkite Pipelines does not have a direct equivalent. Translate based on content type:

- **For secrets:** Use Buildkite [cluster secrets](/docs/pipelines/security/secrets) with the `secrets:` attribute in pipeline YAML, or an external secrets manager.
- **For non-secret variables:** Use the `env:` attribute directly. Use YAML anchors to share variables across steps.

```yaml
# CircleCI
workflows:
  deploy:
    jobs:
      - docker-build:
          context:
            - aws-credentials

# Buildkite Pipelines
steps:
  - label: "Docker build"
    commands:
      - docker build -t myapp .
      - docker push myapp
    secrets:
      - AWS_ACCESS_KEY_ID
      - AWS_SECRET_ACCESS_KEY
```

### Approval jobs

CircleCI's `type: approval` jobs create manual gates in a workflow. The equivalent in Buildkite Pipelines is a [block step](/docs/pipelines/configure/step-types/block-step):

```yaml
# CircleCI
workflows:
  deploy:
    jobs:
      - build
      - hold:
          type: approval
          requires:
            - build
      - deploy:
          requires:
            - hold

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
# CircleCI
jobs:
  test:
    parameters:
      node_version:
        type: string
    docker:
      - image: cimg/node:<< parameters.node_version >>
    steps:
      - run: npm test

workflows:
  test-matrix:
    jobs:
      - test:
          matrix:
            parameters:
              node_version: ["18", "20", "22"]

# Buildkite Pipelines
steps:
  - label: "Test (Node {{matrix.node_version}})"
    plugins:
      - docker#v5.12.0:
          image: node:{{matrix.node_version}}
    command: npm test
    matrix:
      setup:
        node_version:
          - "18"
          - "20"
          - "22"
```

### Resource classes and parallelism

CircleCI `resource_class` maps to agent queues, and `parallelism` maps to the `parallelism` attribute in Buildkite Pipelines:

```yaml
# CircleCI
jobs:
  test:
    resource_class: large
    parallelism: 4
    steps:
      - run: npm test

# Buildkite Pipelines
steps:
  - label: "Test"
    agents:
      queue: "large"
    parallelism: 4
    command: npm test
```

Buildkite parallelism creates multiple jobs with `BUILDKITE_PARALLEL_JOB` and `BUILDKITE_PARALLEL_JOB_COUNT` environment variables. For intelligent test distribution based on timing data (equivalent to `circleci tests split --split-by=timings`), use [Test Engine](/docs/test-engine).

### Branch and tag filtering

CircleCI supports `branches.only`, `branches.ignore`, and `tags.only` filters at the workflow level. Buildkite Pipelines offers two approaches to branch filtering.

**Step-level filtering with the `branches:` attribute:**

For simple patterns, use the `branches:` attribute with `!` prefix for negation:

```yaml
# CircleCI
workflows:
  main:
    jobs:
      - deploy:
          filters:
            branches:
              ignore:
                - dev
                - staging

# Buildkite Pipelines
steps:
  - label: "Deploy"
    command: "make deploy"
    branches: "!dev !staging"
```

**Step-level filtering with `if:` conditionals:**

For complex patterns or regex matching, use `if:` conditionals. The `branches:` and `if:` attributes cannot be used together on the same step.

```yaml
# Buildkite Pipelines: ignore branches matching a regex pattern
steps:
  - label: "Test"
    command: "make test"
    if: build.branch !~ /^feature\/experimental-/
```

**Tag-only builds:**

For the CircleCI pattern of running only on tags, use `build.tag`:

```yaml
# Buildkite Pipelines: run only on version tags
steps:
  - label: "Publish"
    command: "make publish"
    if: build.tag =~ /^v/
```

**Pipeline-level filtering:**

For pipeline-wide branch restrictions that should prevent builds from being created entirely, configure this in **Pipeline Settings** under **Branch Limiting**, not in YAML. This is equivalent to having `branches.only` or `branches.ignore` at the workflow level in CircleCI.

### Scheduled workflows

CircleCI scheduled workflows are configured in the YAML file. In Buildkite Pipelines, [scheduled builds](/docs/pipelines/configure/scheduled-builds) are configured in the Buildkite UI.

To migrate a CircleCI schedule, navigate to your pipeline's **Settings**, select **Schedules**, and create a new schedule with the cron expression, branch, and other options from your CircleCI configuration.

### Dynamic configuration

CircleCI's dynamic configuration pattern uses `setup: true` with the continuation orb to generate pipelines at runtime. Buildkite Pipelines handles this natively with `buildkite-agent pipeline upload`:

```yaml
# CircleCI
setup: true
orbs:
  continuation: circleci/continuation@0.3.1

jobs:
  setup:
    steps:
      - run:
          name: Generate config
          command: ./generate-config.sh > generated-config.yml
      - continuation/continue:
          configuration_path: generated-config.yml

# Buildkite Pipelines
steps:
  - label: ":pipeline: Generate pipeline"
    command: |
      ./generate-config.sh | buildkite-agent pipeline upload
```

For path-based dynamic configuration (similar to CircleCI's `path-filtering` orb), use [conditionals](/docs/pipelines/configure/conditionals) or [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) with change detection logic.

### Reusable commands

CircleCI `commands` are reusable step sequences with parameters. For simple reuse without parameters, use YAML anchors:

```yaml
# Buildkite Pipelines: YAML anchors for simple reuse
definitions:
  install_deps: &install_deps
    - npm ci
    - npm run bootstrap

steps:
  - label: "Build"
    command:
      - *install_deps
      - npm run build

  - label: "Test"
    command:
      - *install_deps
      - npm test
```

For parameterized reuse, use [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) where a step generates and uploads pipeline YAML at runtime using `buildkite-agent pipeline upload`.

### Windows and macOS jobs

CircleCI uses `machine` executors with specific images for Windows and macOS. In Buildkite Pipelines, use agent queues to route jobs to agents running on the appropriate platform:

```yaml
# Buildkite Pipelines
steps:
  - label: "Windows build"
    agents:
      queue: "windows"
    command: npm test

  - label: "macOS build"
    agents:
      queue: "macos"
    command: xcodebuild test
```

For mixed shell usage on Windows, invoke the shell directly in the command (for example, `bash ./script.sh` or `pwsh -Command "..."`).

## Concept mapping reference

This table provides a comprehensive mapping between CircleCI concepts and their Buildkite Pipelines equivalents:

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
| Scheduled workflows | [Scheduled builds](/docs/pipelines/configure/scheduled-builds) |
| Pipeline parameters (`<< pipeline.parameters.X >>`) | [Environment variables](/docs/pipelines/configure/environment-variables) (`${X}`) |
| `setup: true` + continuation orb | `buildkite-agent pipeline upload` ([dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines)) |
| `when: always` | `depends_on` with `allow_failure: true` |
| `$CIRCLE_SHA1` | `$BUILDKITE_COMMIT` |
| `$CIRCLE_BRANCH` | `$BUILDKITE_BRANCH` |
| `$CIRCLE_BUILD_NUM` | `$BUILDKITE_BUILD_NUMBER` |
| `$CIRCLE_PR_NUMBER` | `$BUILDKITE_PULL_REQUEST` |

## Key differences and benefits of migrating to Buildkite Pipelines

This [example pipeline translation](#translate-an-example-circleci-configuration) demonstrates several important advantages of the Buildkite approach:

- **Simpler pipeline configuration:** The resulting Buildkite YAML is shorter than the CircleCI configuration, with no need for `version`, `orbs`, `executors`, or `jobs` blocks.
- **Execution model:** Buildkite Pipelines steps are parallel by default with explicit sequencing, similar to CircleCI workflow jobs but applied at the step level.
- **No orb dependencies:** Orb commands like `node/install-packages` become simple shell commands (`npm ci`), removing a layer of abstraction and third-party dependency.
- **Native features:** Buildkite Pipelines provides native artifact handling, build visualization, and emoji support without additional configuration.
- **Agent flexibility:** Full control over your build environment with self-hosted agents, or use Buildkite hosted agents for a managed solution.

For larger deployments, these differences become more significant:

- The fresh workspace model avoids state leakage between builds.
- The pull-based agent model simplifies scaling and security.
- Pipeline-specific plugin versioning eliminates dependency conflicts.

Be aware of common pipeline-translation mistakes, which might include:

- Forgetting about fresh workspaces (leading to missing dependencies).
- Using `cimg/*` Docker images without login shell and UID/GID workarounds.
- Over-parallelizing interdependent steps.
- Assuming tools from orbs are available (when you need explicit installation).

## Next steps

Explore these Buildkite resources to enhance your migrated pipelines:

- [Defining your pipeline steps](/docs/pipelines/defining-steps) for an advanced guide on how to configure Buildkite pipeline steps.
- [Buildkite agent overview](/docs/agent) for more information about how to configure the Buildkite agent.
- [Plugins directory](https://buildkite.com/resources/plugins/) for a catalog of Buildkite- and community-developed plugins to enhance your pipeline functionality.
- [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) to learn more about generating pipeline definitions at build-time, and how to facilitate this feature with the [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk).
- [Buildkite agent hooks](/docs/agent/hooks) to extend or override the default behavior of Buildkite agents at different stages of the lifecycle.
- [Using conditions](/docs/pipelines/configure/conditionals) to run pipeline builds or steps only when specific conditions have been met.
- [Annotations](/docs/agent/cli/reference/annotate) that allow you to add additional information to your build result pages using Markdown.
- [Security](/docs/pipelines/security) and [Secrets](/docs/pipelines/security/secrets) overview pages for managing secrets within your Buildkite infrastructure, as well as [permissions](/docs/pipelines/security/permissions) for your teams and pipelines.
- [Integrations](/docs/pipelines/integrations) to integrate Buildkite with other third-party tools, for example, notifications that automatically let your team know about the success of your pipeline builds.
- After configuring Buildkite Pipelines for your team, learn how to obtain actionable insights from the tests running in pipelines using [Test Engine](/docs/test-engine).

If you need further assistance with your CircleCI migration, reach out to the Buildkite support team at support@buildkite.com.
