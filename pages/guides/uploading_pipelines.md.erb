# Uploading Build Pipelines

In addition to defining your build pipelines via the web you can use your Buildkite agent’s `pipeline upload` command to read them from your source code, or even dynamically generate them using a script. This allows you to version, audit and review your build pipelines alongside your source code.

<%= toc %>

## Getting started

To get started on a new pipeline create a single step and have it run `buildkite-agent pipeline upload`:

<%= image("pipeline-upload-step.png", width: 612/2, height: 484/2) %>

This will add a step to your pipeline containing the correct `buildkite-agent pipeline upload` command. When this command runs on an agent it reads in the pipeline file located in your repository at `.buildkite/pipeline.yml`. For example, here is a pipeline that simply prints “Hello!”:

```yml
steps:
  - name: Example Test
    command: echo "Hello!"
```

To test your new `.buildkite/pipeline.yml` simply commit the file, push the commit, and run a new build:

<%= image("show-example-test.png", width: 422/2, height: 270/2) %>

## Example pipeline

Here’s a more complete example based off the Buildkite Agent’s pipeline which contains script commands, wait steps, "Click to unblock" steps, and artifacting uploading:

```yaml
steps:
  - name: '\:hammer\: Tests'
    command: 'scripts/tests.sh'
    env:
      DOCKER_COMPOSE_CONTAINER: app

  - wait

  - name: '\:package\: Package'
    command: 'scripts/build-binaries.sh'
    artifact_paths: 'pkg/*'
    env:
      DOCKER_COMPOSE_CONTAINER: app

  - wait

  - name: '\:debian\: Publish'
    command: 'scripts/build-debian-packages.sh'
    artifact_paths: 'deb/**/*'
    branches: 'master'
    agents:
      queue: 'deploy'

  - block: '\:shipit\: Release'

  - name: '\:github\: Release'
    command: 'scripts/build-github-release.sh'
    artifact_paths: 'releases/**/*'
    branches: 'master'

  - wait
  
  - name: '\:whale\: Update images'
    command: 'scripts/release-docker.sh'
    branches: 'master'
    agents:
      queue: 'deploy'
```

See the [Buildkite Agent pipelines documentation](/docs/agent/build-pipelines) for a full list of step types and supported options.

## Dynamic pipelines

You can generate pipelines dynamically from your source code thanks to the fact that pipelines are uploaded by running a command on one of your Buildkite agents. This provides you with a large amount of flexiblity to structure your pipelines as you wish.

For example you could generate a list of parallel test steps based upon the `test/*` directories within your repository. To do this you'd have a single step in your pipeline settings:

```
./scripts/buildkite_test_pipeline | buildkite-agent pipeline upload
```

The `scripts/buildkite_test_pipeline` would be an executable file checked into your source repository, and could look something like the following:

```
#!/bin/bash

# Generates a pipeline step for each test directory, allowing the tests to be
# split up and run across distributed build agents

set -eu

echo "steps:"

for test_dir in test/*/; do
  echo "  - command: \"run_tests "${test_dir}"\"
done
```

When this is run on an agent it will output the pipeline, which is then piped to the `buildkite-agent pipeline upload` command.

## Migrating existing pipelines

To migrate to checked in pipelines without interrupting existing branches you can add a new step at the start of the pipeline. This new step is reponsible for checking if a pipeline file exists and replacing the currently running pipeline (the old configuration, defined via the web) with the new configuration read from the file.

To do this, create a step with the following command:

```bash
[[ -f ".buildkite/pipeline.yml" ]] && buildkite-agent pipeline upload --replace || true
```

If the pipeline file exists then we execute the `pipeline upload --replace` command which will replace any steps that were defined via the web UI after this step.

## Further documentation

See the [Buildkite Agent pipelines documentation](/docs/agent/build-pipelines) for a full list of options and details of Buildkite’s pipeline command support.
