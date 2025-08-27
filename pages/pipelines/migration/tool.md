# Buildkite migration tool overview

The Buildkite migration tool helps you start the transition of pipelines from other CI providers to Buildkite Pipelines by demonstrating how workflows from other CI/CD platforms map to Buildkite Pipelines concepts and architecture. It serves as a compatibility layer, enabling the conversion of some of your existing CI configurations into a format compatible with Buildkite's pipeline definition.

Rather than serving as a complete automated migration solution, the Buildkite migration tool helps you visualize how configurations from from [GitHub Actions](/docs/pipelines/migration/tool/github-actions), [CircleCI](/docs/pipelines/migration/tool/circleci), [Bitbucket Pipelines](/docs/pipelines/migration/tool/bitbucket-pipelines), and Jenkins (currently in beta) could be structured in Buildkite pipeline configuration format.

The Buildkite migration tool can be used as a standalone tool or potentially integrated into your [Buildkite Migration Services](https://buildkite.com/resources/migrations/) process, offering a way to leverage existing CI configurations within the Buildkite ecosystem.

## Interactive web-based version

The fastest way of getting started with the Buildkite migration tool is to use it as an [interactive web tool](https://buildkite.com/resources/migrate/).

<%= image "migration-tool-web.png", alt: "Buildkite migration tool's web UI" %>

The Buildkite migration tool currently supports the following CI providers:

- [GitHub Actions](/docs/pipelines/migration/tool/github-actions)
- [CircleCI](/docs/pipelines/migration/tool/circleci)
- [Bitbucket Pipelines](/docs/pipelines/migration/tool/bitbucket-pipelines)
- Jenkins (currently in Beta)

To start translating your existing pipeline configuration into a Buildkite pipeline:

1. In the drop-down list, select your CI/CD platform.
1. Enter a pipeline definition you would like to translate into a Buildkite pipeline definition on the left side of the tool.
1. Click the **Convert** button.
1. You'll see the translated pipeline definition on the right side of the tool.
1. You can copy the resulting yaml pipeline definition and [create](/docs/pipelines/configure) a [new Buildkite pipeline](https://www.buildkite.com/new) with it.

In the following chapters, you will find example pipeline snippets from GitHub Actions, CircleCI, and Bitbucket pipeline definitions and the results you are expected to get after converting them to Buildkite pipeline configurations by running the Buildkite migration tool. In each example, two steps are decidedly easily translatable to Buildkite pipeline configuration and one is not. This approach should give you an idea of what you'll see when translating a real-world pipeline configuration where some parts map well to Buildkite while other parts do not have an exact equivalent in Buildkite.

### GitHub Actions conversion example

Here is a short example of a GitHub Actions pipeline configuration that demonstrates both convertible and non-convertible features:

```yaml
name: CI Pipeline
on: #  ❌ Not supported - Buildkite uses trigger steps instead
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env: # ✅ Supported - Converted to build-level environment variables
  NODE_VERSION: "18"

jobs:
  test:
    runs-on: ubuntu-latest # ✅ Supported - Mapped to agent targeting tags
    environment: # ❌ Not supported - No direct equivalent in Buildkite
      name: production
      url: https://example.com
    steps:
      - uses: actions/checkout@v4 # ❌ Not supported - Uses directive not supported
      - name: Setup Node.js
        uses: actions/setup-node@v4 # ❌ Not supported - Uses directive not supported
        with:
          node-version: ${{ env.NODE_VERSION }}
      - name: Install dependencies
        run: npm ci # ✅ Supported - Converted to command step commands
      - name: Run tests
        run: npm test # ✅ Supported - Converted to command step commands

  build:
    runs-on: ubuntu-latest # ✅ Supported - Mapped to agent targeting tags
    needs: test # ✅ Supported - Converted to depends_on in Buildkite
    steps:
      - uses: actions/checkout@v4 # ❌ Not supported - Uses directive not supported
      - name: Build application
        run: | # ✅ Supported - Converted to command step commands
          echo "Building application..."
          npm run build
      - name: Upload artifacts
        uses: actions/upload-artifact@v4 # ❌ Not supported - Uses directive not supported
        with:
          name: build-files
          path: dist/
```

If you paste the following GitHub Actions example into the Buildkite migration tool, this is the output you will get:

```yaml
env:
  NODE_VERSION: '18'
steps:
  - commands:
      - "# action actions/checkout@v4 is not necessary in Buildkite"
      - echo '~~~ Install dependencies'
      - npm ci
      - echo '~~~ Run tests'
      - npm test
    plugins:
      - docker#v5.10.0:
          image: node:${{ env.NODE_VERSION }}
    agents:
      runs-on: ubuntu-latest
    label: ":github: test"
    key: test
    branches: main develop
  - artifact_paths:
      - dist/**/*
    commands:
      - "# action actions/checkout@v4 is not necessary in Buildkite"
      - echo '~~~ Build application'
      - echo "Building application..."
      - npm run build
    depends_on:
      - test
    agents:
      runs-on: ubuntu-latest
    label: ":github: build"
    key: build
    branches: main develop
```

What the Buildkite migration tool _can_ convert:

- `env` variables - the `NODE_VERSION: "18"` will be converted to build-level environment variables in Buildkite.
- `runs-on: ubuntu-latest` - this will be mapped to agent targeting tags like `runs-on: ubuntu-latest` in the generated Buildkite pipeline.

What the Buildkite migration tool _cannot_ convert:

- `uses: actions/setup-node@v4` - the migration tool doesn't support GitHub Actions' `uses` directive for calling external actions. This would need to be manually converted to appropriate commands or Buildkite plugins.

The resulting Buildkite pipeline would have the environment variables and agent targeting, but you'd need to replace the `uses` steps with equivalent commands or plugins manually.

### CircleCI conversion example

Here is a short example of a CircleCI pipeline configuration that demonstrates both convertible and non-convertible features:

```yml
version: 2.1

# ✅ Supported: Commands are fully supported
commands:
  run_tests:
    description: "Run the test suite"
    steps:
      - run:
          name: Install dependencies
          command: npm install
      - run:
          name: Run tests
          command: npm test

# ✅ Supported: Jobs with Docker executor
jobs:
  test:
    docker:
      - image: node:16
    environment:
      NODE_ENV: test
    steps:
      - checkout
      - run_tests

  build:
    docker:
      - image: node:16
    steps:
      - checkout
      - run:
          name: Build application
          command: npm run build

# ❌ Unsupported: Pipeline-level parameters
parameters:
  deploy_environment:
    type: string
    default: "staging"

# ✅ Supported: Workflows with dependencies
workflows:
  version: 2
  test_and_build:
    jobs:
      - test
      - build:
          requires:
            - test
```

If you paste the following GitHub Actions example into the Buildkite migration tool, this is the output you will get:

```yml
steps:
  - commands:
      - "# No need for checkout, the agent takes care of that"
      - echo '~~~ Install dependencies'
      - npm install
      - echo '~~~ Run tests'
      - npm test
    plugins:
      - docker#v5.10.0:
          image: node:16
    agents:
      executor_type: docker
    env:
      NODE_ENV: test
    key: test
  - commands:
      - "# No need for checkout, the agent takes care of that"
      - echo '~~~ Build application'
      - npm run build
    depends_on:
      - test
    plugins:
      - docker#v5.10.0:
          image: node:16
    agents:
      executor_type: docker
    key: build
```

What the Buildkite migration tool _can_ convert:
- `commands` - the `run_tests` command with parameters and steps will be fully supported and translated to Buildkite command steps
- `workflows` with `requires` - the workflow dependency where `build` requires `test` to complete will be translated to explicit step dependencies using Buildkite's `depends_on` key

What the Buildkite migration tool _cannot_ convert:
- `parameters` - the pipeline-level `deploy_environment` parameter is explicitly listed as "No" support in the documentation and will need manual translation.

### Bitbucket Pipelines conversion example

Here is a short example of a Bitbucket pipeline configuration that demonstrates both convertible and non-convertible features:

```yml
pipelines:
  default:
    - step:
        name: "Build and Test"
        # ✅ Supported: Will be converted to Buildkite command step label
        script:
          - npm install
          - npm test
        # ✅ Supported: Will be converted to timeout_in_minutes in Buildkite
        max-time: 10
        # ❌ Not supported: Will NOT be converted - no equivalent in Buildkite
        after-script:
          - echo "Cleanup after step completion"
        # ✅ Supported: Will be converted to artifact_paths in Buildkite
        artifacts:
          - test-results/**
          - coverage/**
```

If you paste the following Bitbucket Pipelines example into the Buildkite migration tool, this is the output you will get:

```yml
steps:
  - artifact_paths:
      - test-results/**
      - coverage/**
    commands:
      - npm install
      - npm test
      - "# The after-script property should be configured as a pre-exit repository hook"
      - "# IMPORTANT: artifacts are not automatically downloaded in future steps"
    label: Build and Test
    timeout_in_minutes: 10
```

What the Buildkite migration tool _can_ convert:
- `name` - Converts to Buildkite command step `label`
- `max-time` - Converts to `timeout_in_minutes` in Buildkite
- `artifacts` - Converts to `artifact_paths` in Buildkite command step

What the Buildkite migration tool _cannot_ convert:
- `after-script` - According to the docs, this has no direct equivalent in Buildkite and won't be converted (the docs suggest using a repository-level `pre-exit` hook instead)

Here the `script` section will also convert (each command becomes an entry in the Buildkite `commands` array), and the top-level `image` will convert using the docker-buildkite-plugin.

## Local API-based version

If you would like to run the Buildkite migration tool locally, you can clone the [Buildkite migration tool repository](https://github.com/buildkite/migration) to run the migration tool's API via a HTTP API using `puma` from the `app` folder of this repository.

You start the web UI with either of the following Docker commands:

```sh
docker compose up webui
```

> 📘
> If you are using `docker run`, you will need to override the entrypoint:

```shell
$ docker run --rm -ti -p 9292:9292 --entrypoint '' --workdir /app $IMAGE:$TAG puma --port 9292
```

After that, you will be able to access a web interface at `http://localhost:9292`.

You can also programmatically interact with it (and even pipe the output directly to `buildkite-agent pipeline upload`):

```shell
$ curl -X POST -F 'file=@app/examples/circleci/legacy.yml' http://localhost:9292
---
steps:
- commands:
  - "# No need for checkout, the agent takes care of that"
  - pip install -r requirements/dev.txt
  plugins:
  - docker#v5.7.0:
      image: circleci/python:3.6.2-stretch-browsers
  agents:
    executor_type: docker
  key: build
```

## Next steps

For more tools and recommendations regarding migrating from your existing CI/CD platform to Buildkite, see:

- [Migrate to Buildkite Pipelines](/docs/pipelines/migration)
- [Buildkite Migration Services](https://buildkite.com/resources/migrations/)
- [Migration from Jenkins - a step-by-step guide](/docs/pipelines/migration/from-jenkins)
- [Migration from Bamboo - a step-by-step guide](https://buildkite.com/docs/pipelines/migration/from-bamboo)
