# Migrate from Bitbucket Pipelines

This guide helps [Bitbucket Pipelines](https://bitbucket.org/product/features/pipelines) users migrate to Buildkite Pipelines, and covers key differences between the platforms.

Bitbucket Pipelines is a CI/CD service built into [Bitbucket Cloud](https://bitbucket.org/product/) that uses a `bitbucket-pipelines.yml` file in your repository to define your build configuration. Buildkite Pipelines uses a similar YAML-based approach with `pipeline.yml`, but differs in its [hybrid architecture offering](/docs/pipelines/architecture), execution model, and how it handles containers and caching.

Follow the steps in this guide for a smooth migration from Bitbucket Pipelines to Buildkite Pipelines.

## Understand the differences

Most Bitbucket Pipelines concepts translate to Buildkite Pipelines directly, but there are key differences to understand before migrating.

### System architecture

Bitbucket Pipelines is a fully hosted CI/CD service that runs jobs on Atlassian-managed infrastructure using Docker containers.

Buildkite Pipelines offers a hybrid model:

- A SaaS platform (the _Buildkite dashboard_) for visualization and pipeline management.
- [Buildkite agents](/docs/agent) for executing jobs—through [Buildkite hosted agents](/docs/agent/buildkite-hosted) as a fully-managed service, or [self-hosted](/docs/agent/self-hosted) agents (as a hybrid model architecture) that you manage in your own infrastructure. The [Buildkite agent](https://github.com/buildkite/agent) is open source and can run on local machines, cloud servers, or containers.

The hybrid model gives you more control over your build environment, scaling, and security compared to Bitbucket Pipelines' fully hosted approach.

See [Buildkite Pipelines architecture](/docs/pipelines/architecture) for more details.

### Security

The hybrid architecture of Buildkite Pipelines provides a unique approach to security. Buildkite Pipelines takes care of the security of its SaaS platform, including user authentication, pipeline management, and the web interface. Self-hosted Buildkite agents, which run on your infrastructure, allow you to maintain control over the environment, security, and other build-related resources.

Buildkite does not have or need access to your source code. Only the agents you host within your infrastructure need access to clone your repositories. Your secrets can be managed through Buildkite's own [secrets management](/docs/pipelines/security/secrets) or through secrets management tools hosted within your infrastructure.

Learn more about [Security](/docs/pipelines/security) and [Secrets](/docs/pipelines/security/secrets) in Buildkite Pipelines.

### Pipeline configuration concepts

The following table maps key Bitbucket Pipelines concepts to their Buildkite Pipelines equivalents.

| Bitbucket Pipelines | Buildkite Pipelines |
|---------------------|---------------------|
| `bitbucket-pipelines.yml` | `pipeline.yml` |
| `name` | `label` |
| `script` | `command` |
| `image` (global) | [Docker plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-buildkite-plugin/) per step |
| `parallel` | Steps without `depends_on` (parallel by default) |
| `caches` | [Cache plugin](https://buildkite.com/resources/plugins/buildkite-plugins/cache-buildkite-plugin) |
| `artifacts` | `artifact_paths` / `buildkite-agent artifact` |
| `deployment` | `concurrency_group` + `block` step |
| `condition.changesets` | `if_changed` |
| `max-time` | `timeout_in_minutes` |
| `definitions.steps` | YAML anchors in `common:` section |
| `pipelines.custom` | `block` step or triggered pipeline |

A Buildkite pipeline contains different types of [steps](/docs/pipelines/configure/step-types):

- [Command step](/docs/pipelines/configure/step-types/command-step): Runs one or more shell commands on one or more agents.
- [Wait step](/docs/pipelines/configure/step-types/wait-step): Pauses a build until all previous jobs have completed.
- [Block step](/docs/pipelines/configure/step-types/block-step): Pauses a build until unblocked.
- [Input step](/docs/pipelines/configure/step-types/input-step): Collects information from a user.
- [Trigger step](/docs/pipelines/configure/step-types/trigger-step): Creates a build on another pipeline.
- [Group step](/docs/pipelines/configure/step-types/group-step): Displays a group of sub-steps as one parent step.

### Plugin system

Bitbucket Pipelines extends its built-in functionality through [Pipes](https://bitbucket.org/product/features/pipelines/integrations)—pre-packaged Docker containers for common tasks. Buildkite Pipelines uses shell-based [plugins](/docs/pipelines/integrations/plugins) that hook into the agent's [job lifecycle](/docs/agent/hooks#job-lifecycle-hooks) and are versioned per step. Both are declared directly in pipeline YAML. For detailed comparisons and examples, see [Plugins](#pipeline-translation-fundamentals-plugins) in pipeline translation fundamentals below.

### Try out Buildkite

With a basic understanding of the differences between Buildkite and Bitbucket Pipelines, if you haven't already done so, run through the [Getting started with Pipelines](/docs/pipelines/getting-started) guide to get yourself set up to run pipelines in Buildkite, and [create your own pipeline](/docs/pipelines/create-your-own).

## Pipeline translation fundamentals

Before translating any pipeline from Bitbucket Pipelines to Buildkite Pipelines, be aware of the following fundamental differences.

### Files and syntax

| Pipeline aspect | Bitbucket Pipelines | Buildkite Pipelines |
|-----------------|---------------------|---------------------|
| **Configuration file** | `bitbucket-pipelines.yml` | `pipeline.yml` |
| **Syntax** | YAML | YAML |
| **Location** | Repository root | `.buildkite/` directory (by convention) |

Both platforms use YAML, making the syntax transition straightforward. The main differences are in the attribute names and structure.

### Step execution

Bitbucket Pipelines runs steps sequentially by default, requiring an explicit `parallel` block for concurrent execution. Buildkite Pipelines runs steps in parallel by default, requiring explicit `depends_on` for sequential execution.

**Bitbucket Pipelines:**

```yaml
# Bitbucket: Explicit parallel block required
- parallel:
    - step:
        name: Unit tests
        script:
          - npm run test:unit
    - step:
        name: Integration tests
        script:
          - npm run test:integration
```

**Buildkite Pipelines:**

```yaml
# Buildkite: Steps run in parallel by default
steps:
  - label: "Unit tests"
    key: "unit-tests"
    command: "npm run test:unit"

  - label: "Integration tests"
    key: "integration-tests"
    command: "npm run test:integration"

  - label: "Deploy"
    command: "./deploy.sh"
    depends_on:
      - "unit-tests"
      - "integration-tests"
```

### Plugins

Bitbucket Pipelines extends its functionality through [Pipes](https://bitbucket.org/product/features/pipelines/integrations)—pre-packaged Docker containers that perform common tasks like deploying to AWS or sending Slack notifications. Pipes are referenced directly in your pipeline YAML:

```yaml
# Bitbucket Pipelines: Using a Pipe
- pipe: atlassian/aws-s3-deploy:1.1.0
  variables:
    AWS_DEFAULT_REGION: "us-east-1"
    S3_BUCKET: "my-bucket"
    LOCAL_PATH: "dist"
```

Buildkite Pipelines uses [plugins](/docs/pipelines/integrations/plugins)—shell-based extensions that hook into the agent's [job lifecycle](/docs/agent/hooks#job-lifecycle-hooks). Like Pipes, plugins are referenced directly in pipeline YAML and versioned per step:

```yaml
# Buildkite Pipelines: Using a plugin
steps:
  - label: "Deploy to S3"
    plugins:
      - aws-s3-deploy#v1.0.0:
          bucket: "my-bucket"
          local-path: "dist"
```

Key differences between the two approaches:

- Bitbucket Pipes run as separate Docker containers within a step. Buildkite plugins are shell-based hooks that run directly on the agent, giving them more flexibility to modify the build environment.
- Bitbucket bakes many capabilities into the platform natively (caching, artifacts, services, deployments). In Buildkite Pipelines, some of these capabilities are provided through plugins, such as the [Docker plugin](https://buildkite.com/resources/plugins/docker), [cache plugin](https://buildkite.com/resources/plugins/buildkite-plugins/cache-buildkite-plugin), and [Docker Compose plugin](https://buildkite.com/resources/plugins/docker-compose).
- Buildkite plugin failures are isolated to individual builds, with no system-wide plugin management required.

Browse available plugins in the [plugins directory](https://buildkite.com/resources/plugins/).

### Container images

Bitbucket Pipelines supports a global `image` that applies to all steps. Buildkite Pipelines has no global image setting. Instead, use the [Docker plugin](https://buildkite.com/resources/plugins/docker) on each step, or a YAML anchor to avoid repetition.

**Bitbucket Pipelines:**

```yaml
image: node:20

pipelines:
  default:
    - step:
        name: Build
        script:
          - npm run build
```

**Buildkite Pipelines (with YAML anchor):**

```yaml
common:
  - docker_plugin: &docker
      docker#v5.12.0:
        image: node:20

steps:
  - label: "Build"
    command:
      - npm run build
    plugins:
      - *docker
```

### Workspace state

In Bitbucket Pipelines, artifacts can be passed between steps automatically. In Buildkite Pipelines, each step runs in a fresh workspace, requiring explicit artifact upload and download.

**Bitbucket Pipelines:**

```yaml
- step:
    name: Build
    script:
      - npm run build
    artifacts:
      - dist/**

- step:
    name: Deploy
    script:
      - ./deploy.sh
```

**Buildkite Pipelines:**

```yaml
steps:
  - label: "Build"
    key: "build"
    command:
      - npm run build
    artifact_paths:
      - "dist/**"

  - label: "Deploy"
    depends_on: "build"
    command:
      - buildkite-agent artifact download "dist/**" .
      - ./deploy.sh
```

### Branch filtering

Bitbucket Pipelines uses `pipelines.branches` to define different step lists per branch. In Buildkite Pipelines, use the `branches` attribute on individual steps.

**Bitbucket Pipelines:**

```yaml
pipelines:
  branches:
    main:
      - step:
          name: Deploy to production
          script:
            - ./deploy.sh prod
    develop:
      - step:
          name: Run tests
          script:
            - npm test
```

**Buildkite Pipelines:**

```yaml
steps:
  - label: "Deploy to production"
    command: "./deploy.sh prod"
    branches: "main"

  - label: "Run tests"
    command: "npm test"
    branches: "develop"
```

### Path-based conditional execution

Bitbucket Pipelines uses `condition.changesets.includePaths`. Buildkite Pipelines provides a native `if_changed` attribute.

**Bitbucket Pipelines:**

```yaml
- step:
    name: Build client
    condition:
      changesets:
        includePaths:
          - "client/**"
    script:
      - cd client && npm run build
```

**Buildkite Pipelines:**

```yaml
steps:
  - label: "Build client"
    if_changed:
      - "client/**"
    command:
      - cd client && npm run build
```

> 📘 if_changed requires dynamic pipeline upload
> The `if_changed` attribute is processed only by `buildkite-agent pipeline upload`. Store your pipeline YAML in the repository (for example, `.buildkite/pipeline.yml`) and use a pipeline upload step.

### Caching

Bitbucket Pipelines provides built-in caching with `definitions.caches`. Buildkite Pipelines uses the [cache plugin](https://buildkite.com/resources/plugins/buildkite-plugins/cache-buildkite-plugin) for self-hosted agents, or container caching for [Buildkite hosted agents](/docs/agent/buildkite-hosted).

**Bitbucket Pipelines:**

```yaml
definitions:
  caches:
    node-modules: node_modules

pipelines:
  default:
    - step:
        name: Build
        caches:
          - node-modules
        script:
          - npm install && npm run build
```

**Buildkite Pipelines (self-hosted agents):**

```yaml
steps:
  - label: "Build"
    command:
      - npm install && npm run build
    plugins:
      - cache#v1.3.0:
          path: node_modules
          key: "node-{{ checksum 'package-lock.json' }}"
```

### Service containers

Bitbucket Pipelines uses `definitions.services` and `services` to run sidecar containers. In Buildkite Pipelines, use the [Docker Compose plugin](https://buildkite.com/resources/plugins/docker-compose) with a `docker-compose.yml` file.

### Deployment environments

Bitbucket Pipelines uses `deployment` to tag steps for environment tracking, and `trigger: manual` for manual approval. In Buildkite Pipelines, use `concurrency_group` for deployment serialization and [`block` steps](/docs/pipelines/configure/step-types/block-step) for manual approval.

**Bitbucket Pipelines:**

```yaml
- step:
    name: Deploy to production
    deployment: production
    trigger: manual
    script:
      - ./deploy.sh production
```

**Buildkite Pipelines:**

```yaml
steps:
  - block: "Deploy to production?"
    branches: "main"

  - label: "Deploy to production"
    command: "./deploy.sh production"
    branches: "main"
    concurrency: 1
    concurrency_group: "deploy-production"
```

### Timeouts

Bitbucket Pipelines uses `options.max-time` for a global timeout and `max-time` per step. In Buildkite Pipelines, use `timeout_in_minutes` on each step, or configure a default timeout in pipeline settings.

### Reusable step definitions

Bitbucket Pipelines defines reusable steps under `definitions.steps` using YAML anchors. Buildkite Pipelines supports the same pattern using a `common` section (which Buildkite ignores) to hold YAML anchors.

### Fail-fast behavior

Bitbucket Pipelines uses `fail-fast: true` on a `parallel` block. In Buildkite Pipelines, use `cancel_on_build_failing: true` on each step that should be canceled when the build is failing.

### Cleanup commands

Bitbucket Pipelines uses `after-script` for commands that run regardless of step success or failure. In Buildkite Pipelines, use a shell `trap` within your command or a repository `post-command` [hook](/docs/agent/hooks).

## Translate an example Bitbucket Pipelines configuration

This section walks through translating a typical Bitbucket Pipelines configuration for a Node.js application into a Buildkite pipeline. The example Bitbucket pipeline demonstrates common features, including:

- A global `image` applied to all steps.
- A `parallel` block for running tests concurrently.
- Built-in `caches` for `node_modules`.
- `artifacts` passed between steps.
- A `deployment` step with `trigger: manual` for production releases.

### The original Bitbucket pipeline

Here is the complete `bitbucket-pipelines.yml`:

```yaml
image: node:20

definitions:
  caches:
    app-node: app/node_modules

pipelines:
  branches:
    main:
      - parallel:
          - step:
              name: Lint
              caches:
                - app-node
              script:
                - cd app && npm ci
                - npm run lint
          - step:
              name: Test
              caches:
                - app-node
              script:
                - cd app && npm ci
                - npm test
              artifacts:
                - app/coverage/**
      - step:
          name: Build
          caches:
            - app-node
          script:
            - cd app && npm ci
            - npm run build
          artifacts:
            - app/dist/**
      - step:
          name: Deploy to production
          deployment: production
          trigger: manual
          script:
            - ./deploy.sh production
```

This pipeline runs lint and test in parallel, builds the application after both pass, and then waits for manual approval before deploying to production.

### Step 1: Create a basic Buildkite pipeline structure

Start by creating a `.buildkite/pipeline.yml` file with the basic step structure, translating `name` to `label` and `script` to `command`:

```yaml
steps:
  - label: "Lint"
    command:
      - echo "Lint placeholder"

  - label: "Test"
    command:
      - echo "Test placeholder"

  - label: "Build"
    command:
      - echo "Build placeholder"
```

Notice that there is no `parallel` block. In Buildkite Pipelines, these three steps will run in parallel by default.

### Step 2: Add step dependencies

The build step should only run after lint and test complete. Add `key` attributes and a `depends_on` to the build step:

```yaml
steps:
  - label: "Lint"
    key: "lint"
    command:
      - echo "Lint placeholder"

  - label: "Test"
    key: "test"
    command:
      - echo "Test placeholder"

  - label: "Build"
    depends_on:
      - "lint"
      - "test"
    command:
      - echo "Build placeholder"
```

Without `depends_on`, all three steps would run simultaneously. This gives you the same execution order as the Bitbucket pipeline: lint and test in parallel, then build.

### Step 3: Add the Docker plugin for the container image

Bitbucket Pipelines' global `image: node:20` must be applied per step in Buildkite Pipelines using the [Docker plugin](https://buildkite.com/resources/plugins/docker). Use a YAML anchor to avoid repetition:

```yaml
common:
  - docker_plugin: &docker
      docker#v5.12.0:
        image: node:20

steps:
  - label: "Lint"
    key: "lint"
    command:
      - cd app && npm ci
      - npm run lint
    plugins:
      - *docker

  - label: "Test"
    key: "test"
    command:
      - cd app && npm ci
      - npm test
    plugins:
      - *docker

  - label: "Build"
    depends_on:
      - "lint"
      - "test"
    command:
      - cd app && npm ci
      - npm run build
    plugins:
      - *docker
```

The `common` section is ignored by Buildkite but allows you to define reusable YAML anchors. This replaces Bitbucket's global `image` with an equivalent per-step configuration.

### Step 4: Add artifact handling

Bitbucket Pipelines makes artifacts automatically available to subsequent steps. In Buildkite Pipelines, use `artifact_paths` to upload and `buildkite-agent artifact download` to retrieve them:

```yaml
  - label: "Test"
    key: "test"
    command:
      - cd app && npm ci
      - npm test
    plugins:
      - *docker
    artifact_paths:
      - "app/coverage/**"

  - label: "Build"
    depends_on:
      - "lint"
      - "test"
    command:
      - cd app && npm ci
      - npm run build
    plugins:
      - *docker
    artifact_paths:
      - "app/dist/**"
```

The deploy step will need to explicitly download the build artifacts before deploying:

```yaml
  - label: "Deploy to production"
    command:
      - buildkite-agent artifact download "app/dist/**" .
      - ./deploy.sh production
```

### Step 5: Add the deployment gate

Bitbucket Pipelines uses `trigger: manual` for manual approval. In Buildkite Pipelines, use a [`block` step](/docs/pipelines/configure/step-types/block-step) and `concurrency_group` to serialize deployments:

```yaml
  - block: "Deploy to production?"
    depends_on: "build"

  - label: "Deploy to production"
    command:
      - buildkite-agent artifact download "app/dist/**" .
      - ./deploy.sh production
    concurrency: 1
    concurrency_group: "deploy-production"
```

### Step 6: Add branch filtering

The Bitbucket pipeline runs only on the `main` branch. In Buildkite Pipelines, add `branches: "main"` to each step, or configure branch filtering in your pipeline settings.

### Step 7: Review the complete result

Here is the complete translated Buildkite pipeline:

```yaml
common:
  - docker_plugin: &docker
      docker#v5.12.0:
        image: node:20

steps:
  - label: ":eslint: Lint"
    key: "lint"
    branches: "main"
    command:
      - cd app && npm ci
      - npm run lint
    plugins:
      - *docker

  - label: ":test_tube: Test"
    key: "test"
    branches: "main"
    command:
      - cd app && npm ci
      - npm test
    plugins:
      - *docker
    artifact_paths:
      - "app/coverage/**"

  - label: ":package: Build"
    key: "build"
    branches: "main"
    depends_on:
      - "lint"
      - "test"
    command:
      - cd app && npm ci
      - npm run build
    plugins:
      - *docker
    artifact_paths:
      - "app/dist/**"

  - block: ":rocket: Deploy to production?"
    branches: "main"
    depends_on: "build"

  - label: ":rocket: Deploy to production"
    branches: "main"
    command:
      - buildkite-agent artifact download "app/dist/**" .
      - ./deploy.sh production
    concurrency: 1
    concurrency_group: "deploy-production"
```

Compared to the original Bitbucket pipeline, this Buildkite pipeline:

- Replaces the global `image` with a Docker plugin YAML anchor.
- Removes the explicit `parallel` block, since Buildkite steps run in parallel by default.
- Uses `depends_on` for sequential ordering instead of relying on step position.
- Makes artifact passing explicit with `artifact_paths` and `buildkite-agent artifact download`.
- Replaces `trigger: manual` with a `block` step for deployment approval.
- Replaces `deployment: production` with `concurrency_group` for deployment serialization.

> 📘 Caching
> The Bitbucket pipeline used built-in `caches` for `node_modules`. For Buildkite hosted agents, enable container caching in your queue settings. For self-hosted agents, use the [cache plugin](https://buildkite.com/resources/plugins/buildkite-plugins/cache-buildkite-plugin). Since each step already runs `npm ci`, caching is an optimization you can add later.

## Next steps

Explore these Buildkite resources to help you enhance your migrated pipelines:

- [Defining your pipeline steps](/docs/pipelines/defining-steps) for an advanced guide on how to configure Buildkite pipeline steps.
- [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) to learn how to generate pipeline definitions at build-time.
- [Plugins directory](https://buildkite.com/resources/plugins/) for a catalog of Buildkite- and community-developed plugins to enhance your pipeline functionality.
- [Buildkite agent hooks](/docs/agent/hooks) to extend or override the default behavior of Buildkite agents.
- [Using conditionals](/docs/pipelines/configure/conditionals) to run pipeline builds or steps only when specific conditions are met.
- [Security](/docs/pipelines/security) and [Secrets](/docs/pipelines/security/secrets) overview pages for managing security and secrets within your Buildkite infrastructure.
- After configuring Buildkite Pipelines for your team, learn how to obtain actionable insights from the tests running in pipelines using [Test Engine](/docs/test-engine).

If you need further assistance with your Bitbucket Pipelines migration, reach out to the Buildkite support team at support@buildkite.com.
