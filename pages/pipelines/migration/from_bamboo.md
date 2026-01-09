---
keywords: docs, pipelines, tutorials, migration, bamboo
---

# Migrate from Bamboo

Migrating continuous integration tools can be challenging, so we've put together a guide to help you transition your Bamboo skills to Buildkite Pipelines.

## Plans to pipelines

<!--alex ignore easy-->

You can easily map most Bamboo workflows to Buildkite Pipelines. _Projects and Plans_ in Bamboo are called [pipelines](/docs/pipelines) in Buildkite (and **Pipelines** in the Buildkite dashboard). Bamboo deployments also become Buildkite's pipelines.

Buildkite's pipelines consist of different types of [_steps_](/docs/pipelines/configure/step-types) for different tasks:

- **Command step:** Runs one or more shell commands on one or more agents.
- **Wait step:** Pauses a build until all previous jobs have completed.
- **Block step:** Pauses a build until unblocked.
- **Input step:** Collects information from a user.
- **Trigger step:** Creates a build on another pipeline.
- **Group step:** Displays a group of sub-steps as one parent step, like stages.

For example, a test and deploy pipeline might consist of the following steps:

```yaml
steps:
  # First stage
  - command: test_1.sh
  - command: test_2.sh

  - wait

  # Second stage
  - command: deploy.sh
```
{: codeblock-file="pipeline.yml"}

Instead of the `wait` step above, you could use a `block` step to stop the build and require a user to manually _unblock_ the pipeline by clicking the **Continue** button in the Buildkite dashboard, or use the [Unblock Job](/docs/api/jobs#unblock-a-job) REST API endpoint. This is the equivalent of a _Manual Stage_ in Bamboo.

```yaml
steps:
  - command: test_1.sh
  - command: test_2.sh
  - block: 'Deploy to Production'
  - command: deploy.sh
```
{: codeblock-file="pipeline.yml"}

Let's look at an example Bamboo Plan:

<%= image "bamboo_stages_and_tasks.png", width: 680, height: 312, alt: "An example Bamboo plan" %>

You can map this plan to a Buildkite pipeline using a combination of `command`, `wait`, and `block` steps:

<%= image "buildkite_steps.png", width: 680, height: 312, alt: "The equivalent pipeline in Buildkite" %>

You could also define this Bamboo Plan using the following `pipeline.yml` file:

```yaml
steps:
  # The first stage is to run the "make" command - which will compile
  # the application and store the binaries in a `build` folder. Upload the
  # contents of that folder as an Artifact to Buildkite.
  - command: "make"
    artifact_paths: "build/*"

  # To prevent the "make test" stage from running before "make" has finished,
  # separate the command with a "wait" step.
  - wait

  # Before running `make test`, download the artifacts created in
  # the previous step. To do this, use `buildkite-agent artifact
  # download` command.
  - command: |
      mkdir build
      buildkite-agent artifact download "build/*" "build/"
      make test

  # By putting commands next to each other, you can make them run in parallel.
  - command: |
      mkdir build
      buildkite-agent artifact download "build/*" "build/"
      make lint

  - block: "Deploy to production"

  - command: "scripts/deploy.sh"
```
{: codeblock-file="pipeline.yml"}

Once your build pipelines are set up, you can update step labels to something more fun than plain text (see our [extensive list of supported emojis](https://github.com/buildkite/emojis)). :smiley:

<%= image("buildkite-pipeline.png", size: '653x436', alt: 'Screenshot of a Buildkite Build') %>

If you have many pipelines to migrate or manage at once, you can use the [Update pipeline](/docs/api/pipelines#update-a-pipeline) REST API.

## Steps and tasks

`command` steps are Buildkite's version of the _Command Task_ in Bamboo. They can run any commands you like on your build server, whether it's `rake test` or `make`. Buildkite doesn't have the concept of _Tasks_ in general. It's up to you to write scripts that perform the same tasks that your Bamboo Jobs have.

For example, you had the following set of Bamboo Tasks:

<%= image("bamboo_task_list.png", size: '610x267', alt: 'Screenshot of a Bamboo Task List') %>

You can rewrite this as a single script and then commit it to your repository. The Buildkite agent takes care of checking out the repository for you before each step, so the script would be as follows:

```bash
#!/bin/bash

# These commands are run within the context of your repository
echo "--- Running specs"
rake specs

echo "--- Running cucumber tests"
rake cucumber
```
{: codeblock-file="build.sh"}

If you'd like to learn more about how to write build scripts, see [Writing build scripts](/docs/builds/writing-build-scripts).

To trigger builds in other pipelines, you can use `trigger` steps. This way, you can create dependent pipelines. See the [trigger steps docs](/docs/pipelines/configure/step-types/trigger-step) for more information.

## Remote and Elastic agents

The [Buildkite agent](/docs/agent/v3) replaces your Bamboo _Remote Agents_. You can install agents onto any server to run your builds.

In Bamboo, you can target specific agents for your jobs using their _Capabilities_, and in Buildkite, you target them using [meta-data](/docs/agent/v3/cli-meta-data).

Like _Elastic Bamboo_, Buildkite can also manage a fleet of agents for you on AWS using the [Elastic CI Stack for AWS](/docs/agent/v3/self-hosted/aws/elastic-ci-stack). Buildkite doesn't limit the number of agents you can run at any one time, so by using the AWS Stack, you can auto-scale your build infrastructure, going from 0 to 1000s of agents within moments.

## Authentication and permissions

Buildkite supports SSO with a variety of different providers, as well as custom SAML setups. See the [SSO support guide](/docs/platform/sso) for detailed information.

For larger teams, it can be useful to control what users have access to which pipelines. Organization admins can enable Teams in the [organization's team settings](https://buildkite.com/organizations/~/teams).
