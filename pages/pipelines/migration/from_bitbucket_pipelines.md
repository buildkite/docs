# Migrate from Bitbucket Pipelines

This guide is for people who are familiar with or already use [Bitbucket Pipelines](https://bitbucket.org/product/features/pipelines) and want to migrate to Buildkite Pipelines.

Bitbucket Pipelines is a CI/CD service built into Bitbucket Cloud that uses a `bitbucket-pipelines.yml` file in your repository to define your build configuration. Buildkite Pipelines uses a similar YAML-based approach with `pipeline.yml`, but differs in its hybrid architecture, execution model, and how it handles containers and caching.

Follow the steps in this guide for a smooth migration from Bitbucket Pipelines to Buildkite Pipelines.

## Understand the differences

Most Bitbucket Pipelines concepts translate to Buildkite Pipelines directly, but there are key differences to understand before migrating.

### System architecture

Bitbucket Pipelines is a fully hosted CI/CD service that runs jobs on Atlassian-managed infrastructure using Docker containers.

Buildkite Pipelines uses a hybrid model:

- A SaaS platform (the _Buildkite dashboard_) for visualization and pipeline management.
- [Buildkite agents](/docs/agent) for executing jobs — through [Buildkite hosted agents](/docs/pipelines/architecture#buildkite-hosted-architecture) or through [self-hosted](/docs/pipelines/architecture#self-hosted-hybrid-architecture) agents in your own infrastructure. The [Buildkite agent](https://github.com/buildkite/agent) is open source and can run on local machines, cloud servers, or containers.

This hybrid model gives you more control over your build environment, scaling, and security compared to Bitbucket Pipelines' fully hosted approach.

See [Buildkite Pipelines architecture](/docs/pipelines/architecture) for more details.

### Security

Buildkite Pipelines' hybrid architecture provides a unique approach to security. Buildkite takes care of the security of the SaaS platform, including user authentication, pipeline management, and the web interface. Self-hosted Buildkite agents, which run on your infrastructure, allow you to maintain control over the environment, security, and other build-related resources.

Buildkite does not have or need access to your source code. Only the agents you host within your infrastructure need access to clone your repositories. Your secrets can be managed through Buildkite's own [secrets management](/docs/pipelines/security/secrets) or through secrets management tools hosted within your infrastructure.

Learn more about [Security](/docs/pipelines/security) and [Secrets](/docs/pipelines/security/secrets) in Buildkite Pipelines.

### Pipeline configuration concepts

The following table maps key Bitbucket Pipelines concepts to their Buildkite Pipelines equivalents.

| Bitbucket Pipelines | Buildkite Pipelines |
|---------------------|---------------------|
| `bitbucket-pipelines.yml` | `pipeline.yml` |
| `name` | `label` |
| `script` | `command` |
| `image` (global) | [Docker plugin](https://buildkite.com/resources/plugins/docker) per step |
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
