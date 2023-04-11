# Defining your pipeline steps

Pipeline steps are defined in YAML and are either stored in Buildkite or in your repository using a `pipeline.yml` file.

Defining your pipeline steps in a `pipeline.yml` file gives you access to more configuration options and environment variables than the web interface, and allows you to version, audit and review your build pipelines alongside your source code.


## Getting started

Create a pipeline from the Pipelines page of Buildkite using the ➕ button.

Required fields are _Name_ and _Repository_.

<%= image "new-pipeline-setup.png", width: 1768/2, height: 928/2, alt: "Screenshot of the 'New Pipeline' setup form" %>

You can set up webhooks at this point, but this step is optional. These webhook setup instructions can be found in pipeline settings on your specific repository provider page.

Both the REST API and GraphQL API can be used to create a pipeline programmatically. See the [Pipelines REST API](/docs/apis/rest-api/pipelines) and the [GraphQL API](/docs/apis/graphql-api) for details and examples.

## Adding steps

There are two ways to define steps in your pipeline: using the YAML step editor in Buildkite or with a `pipeline.yml` file. The web steps visual editor is still available if you haven't migrated to [YAML steps](https://buildkite.com/changelog/99-introducing-the-yaml-steps-editor) but will be deprecated in the future.

If you have not yet migrated to YAML Steps, you can do so on your pipeline's settings page. See the [Migrating to YAML steps guide](/docs/tutorials/pipeline-upgrade) for more information about the changes and the migration process.

However you add steps to your pipeline, keep in mind that steps may run on different agents. It is good practice to install your dependencies in the same step that you run them.

## Step defaults

If you're using [YAML steps](/docs/tutorials/pipeline-upgrade), you can set defaults which will be applied to every command step in a pipeline unless they are overridden by the step itself. You can set default agent properties and default environment variables:

* `agents` - A map of agent characteristics such as `os` or `queue` that restrict what agents the command will run on
* `env` - A map of <a href="/docs/pipelines/environment-variables">environment variables</a> to apply to all steps

For example, to set steps `blah.sh` and `blahblah.sh` to use the `something` queue and the step `yada.sh` to use the `other` queue:

```yml
agents:
  queue: "something"

steps:
  - command: "blah.sh"
  - command: "blahblah.sh"
  - label: "Yada"
    command: "yada.sh"
    agents:
      queue: "other"
```
{: codeblock-file="pipeline.yml"}


### YAML steps editor

To add steps using the YAML editor, click the 'Edit Pipeline' button on the Pipeline Settings page.

Starting your YAML with the `steps` object, you can add as many steps as you require of each different type. Quick reference documentation and examples for each step type can be found in the sidebar on the right.

### `pipeline.yml` file

Before getting started with a `pipeline.yml` file, you'll need to tell Buildkite where it will be able to find your steps.

In the YAML steps editor in your Buildkite dashboard, add the following YAML:

```yml
steps:
  - label: "\:pipeline\: Pipeline upload"
    command: buildkite-agent pipeline upload
```

When you eventually run a build from this pipeline, this step will look for a directory called `.buildkite` containing a file named `pipeline.yml`. Any steps it finds inside that file will be uploaded to Buildkite and will appear during the build.

>📘
> When using WSL2 or PowerShell Core, you cannot add a <code>buildkite-agent pipeline upload</code> command step directly in the YAML steps editor. To work around this, there are two options:
* Use the YAML steps editor alone
* Place the <code>buildkite-agent pipeline upload</code> command in a script file. In the YAML steps editor, add a command to run that script file. It will upload your pipeline.

Create your `pipeline.yml` file in a `.buildkite` directory in your repo.

If you're using any tools that ignore hidden directories, you can store your `pipeline.yml` file either in the top level of your repository, or in a non-hidden directory called `buildkite`. The upload command will search these places if it doesn't find a `.buildkite` directory.

The following example YAML defines a pipeline with one command step that will echo 'Hello' into your build log:

```yml
steps:
  - label: "Example Test"
    command: echo "Hello!"
```
{: codeblock-file="pipeline.yml"}

With the above example code in a `pipeline.yml` file, commit and push the file up to your repository. If you have set up webhooks, this will automatically create a new build. You can also create a new build using the 'New Build' button on the pipeline page.

<%= image "show-example-test.png", width: 968/2, height: 698/2, alt: "Screenshot of the build passing with pipeline upload step first, and then the example step" %>

For more example steps and detailed configuration options, see the example `pipeline.yml` below, or the step type specific documentation:

* [command steps](/docs/pipelines/command-step)
* [wait steps](/docs/pipelines/wait-step)
* [block steps](/docs/pipelines/block-step)
* [input steps](/docs/pipelines/input-step)
* [trigger steps](/docs/pipelines/trigger-step)

If your pipeline has more than one step and you have multiple agents available to run them, they will automatically run at the same time. If your steps rely on running in sequence, you can separate them with [wait steps](/docs/pipelines/wait-step). This will ensure that any steps before the 'wait' are completed before steps after the 'wait' are run.

>🚧 Explicit dependencies in uploaded steps
> If a step <a href="/docs/pipelines/dependencies">depends</a> on an upload step, then all steps uploaded by that step become dependencies of the original step. For example, if step B depends on step A, and step A uploads step C, then step B will also depend on step C.

When a step is run by an agent, it will be run with a clean checkout of the pipeline's repository. If your commands or scripts rely on the output from previous steps, you will need to either combine them into a single script or use [artifacts](/docs/pipelines/artifacts) to pass data between steps. This enables any step to be picked up by any agent and run steps in parallel to speed up your build.

## Build states

When you run a pipeline, a build is created. The following diagram shows you how builds progress from start to end.

<%= image "build-states.svg", size: "900x615", alt: "Build state diagram" %>


<%= render_markdown partial: 'pipelines/build_states' %>

## Job states

When you run a pipeline, a build is created. Each of the steps in the pipeline ends up as a job in the build, which then get distributed to available agents. Job states have a similar flow to [build states](#build-states) but with a few extra states. The following diagram shows you how jobs progress from start to end.

<%= image "job-states.svg", size: "1482x690", alt: "Job state diagram" %>

As well as the states shown in the diagram, the following progressions can occur:

can progress to `skipped`  | can progress to `canceling` or `canceled`
-------------------------- | -----------------------------------------
`pending`                  | `accepted`
`waiting`                  | `pending`
`blocked`                  | `limiting`
`limiting`                 | `limited`
`limited`                  | `blocked`
`accepted`                 | `unblocked`
`broken`                   |
{: class="two-column"}

Differentiating between `broken`, `skipped` and `canceled` states:

* Jobs become `broken` when their configuration prevents them from running. This might be because their branch configuration doesn't match the build's branch, or because a conditional returned false.
* This is distinct from `skipped` jobs, which might happen if a newer build is started and [build skipping](/docs/apis/rest-api/pipelines#create-a-yaml-pipeline) is enabled. Broadly, jobs break because of something inside the build, and are skipped by something outside the build.
* Jobs can be `canceled` intentionally, either using the Buildkite UI or one of the APIs.

>📘
> The <a href="/docs/apis/rest-api/builds">REST API</a> does not return <code>finished</code>, but returns <code>passed</code> or <code>failed</code> according to the exit status of the job. It also lists <code>limiting</code> and <code>limited</code> as <code>scheduled</code> for legacy compatibility.

<%= render_markdown partial: 'pipelines/job_states' %>

Each job in a build also has a footer that displays exit status information. It may include an exit signal reason, which indicates whether the Buildkite agent stopped or the job was canceled.

>🚧
> Exit status information available in the <a href="/docs/apis/graphql-api">GraphQL API</a> but not the <a href="/docs/apis/rest-api">REST API</a>.


## Example pipeline

Here's a more complete example based on [the Buildkite agent's build pipeline](https://github.com/buildkite/agent/blob/master/.buildkite/pipeline.yml). It contains script commands, wait steps, block steps, and automatic artifact uploading:

```yaml
steps:
  - label: "\:hammer\: Tests"
    command: scripts/tests.sh
    env:
      BUILDKITE_DOCKER_COMPOSE_CONTAINER: app

  - wait

  - label: "\:package\: Package"
    command: scripts/build-binaries.sh
    artifact_paths: "pkg/*"
    env:
      BUILDKITE_DOCKER_COMPOSE_CONTAINER: app

  - wait

  - label: "\:debian\: Publish"
    command: scripts/build-debian-packages.sh
    artifact_paths: "deb/**/*"
    branches: "master"
    agents:
      queue: "deploy"

  - block: "\:shipit\: Release"
    branches: "master"

  - label: "\:github\: Release"
    command: scripts/build-github-release.sh
    artifact_paths: "releases/**/*"
    branches: "master"

  - wait

  - label: "\:whale\: Update images"
    command: scripts/release-docker.sh
    branches: "master"
    agents:
      queue: "deploy"
```
{: codeblock-file="pipeline.yml"}

## Step types

Buildkite pipelines are made up of the following step types:

* [Command step](/docs/pipelines/command-step)
* [Wait step](/docs/pipelines/wait-step)
* [Block step](/docs/pipelines/block-step)
* [Input step](/docs/pipelines/input-step)
* [Trigger step](/docs/pipelines/trigger-step)
* [Group step](/docs/pipelines/group-step)

## Customizing the pipeline upload path

By default the pipeline upload step reads your pipeline definition from `.buildkite/pipeline.yml` in your repository. You can specify a different file path by adding it as the first argument:

```yml
steps:
  - label: "\:pipeline\: Pipeline upload"
    command: buildkite-agent pipeline upload .buildkite/deploy.yml
```

A common use for custom file paths is when separating test and deployment steps into two separate pipelines. Both `pipeline.yml` files are stored in the same repo and both Buildkite pipelines use the same repo URL. For example, your test pipeline's upload command could be:

```
buildkite-agent pipeline upload .buildkite/pipeline.yml
```

And your deployment pipeline's upload command could be:

```
buildkite-agent pipeline upload .buildkite/pipeline.deploy.yml
```

For a list of all command line options, see the [buildkite-agent pipeline upload](/docs/agent/v3/cli-pipeline#uploading-pipelines) documentation.

## Dynamic pipelines

Because the pipeline upload step runs on your agent machine, you can generate pipelines dynamically using scripts from your source code. This provides you with the flexibility to structure your pipelines however you require.

The following example generates a list of parallel test steps based upon the `test/*` directory within your repository:

```
#!/bin/bash

# exit immediately on failure, or if an undefined variable is used
set -eu

# begin the pipeline.yml file
echo "steps:"

# add a new command step to run the tests in each test directory
for test_dir in test/*/; do
  echo "  - command: \"run_tests "${test_dir}"\""
done
```
{: codeblock-file="pipeline.sh"}

To use this script, you'd save it to `.buildkite/pipeline.sh` inside your repository, ensure it is executable, and then update your pipeline upload step to use the new script:

```bash
.buildkite/pipeline.sh | buildkite-agent pipeline upload
```

When the build is running it will execute the script and pipe the output to the `pipeline upload` command. The upload command will insert the steps from the script into the build immediately after the upload step.

In the below `pipeline.yml` example, when the build runs it will execute the `.buildkite/pipeline.sh` script, then the test steps from the script will be added to the build before the wait step and command step. After the test steps have run, the wait and command step will run.

```yml
steps:
  - command: .buildkite/pipeline.sh | buildkite-agent pipeline upload
    label: "\:pipeline\: Upload"
  - wait
  - command: "other-script.sh"
    label: "Run other operations"
```
{: codeblock-file="pipeline.yml"}

## Dynamic pipeline templates

If you need the ability to use pipelines from a central catalog, or enforce certain configuration rules, you can either use dynamic pipelines and the [`pipeline upload`](/docs/agent/v3/cli-pipeline#uploading-pipelines) command to make this happen or [write custom plugins](/docs/plugins/writing) and share them across your organization.

To use dynamic pipelines and the pipeline upload command, you'd make a pipeline that looks something like this:

```yml
steps:
  - command: enforce-rules.sh | buildkite-agent pipeline upload
    label: "\:pipeline\: Upload"
```

Each team defines their steps in `team-steps.yml`. Your templating logic is in `enforce-rules.sh`, which can be written in any language that can pass YAML to the pipeline upload.

In `enforce-rules.sh` you can add steps to the YAML, require certain versions of dependencies or plugins, or implement any other logic you can program. Depending on your use case, you might want to get `enforce-rules.sh` from an external catalog instead of committing it to the team repository.

See how [Hasura.io](https://hasura.io) used [dynamic templates and pipelines](https://hasura.io/blog/what-we-learnt-by-migrating-from-circleci-to-buildkite/#dynamic-pipelines) to replace their YAML configuration with Go and some shell scripts.

## Targeting specific agents

To run [command steps](/docs/pipelines/command-step) only on specific agents:

1. In the agent configuration file, [tag the agent](/docs/agent/v3/cli-start#setting-tags)
2. In the pipeline command step, [set the agent property](/docs/agent/v3/cli-start#agent-targeting) in the command step

For example to run commands only on agents running on macOS:

```yaml
steps:
  - command: "script.sh"
    agents:
      os: "macOS"
```
{: codeblock-file="pipeline.yml"}

## Further documentation

You can also upload pipelines from the command line using the `buildkite-agent` command line tool. See the [buildkite-agent pipeline documentation](/docs/agent/v3/cli-pipeline) for a full list of the available parameters.
