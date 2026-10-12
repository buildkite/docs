# Starting a new build

A [build](/docs/pipelines/glossary#build) is a single run of a pipeline. This page explains the most common ways to start a new build of an existing pipeline:

- [Pushing code](#start-a-build-by-pushing-code) to your repository.
- Selecting **New Build** in the [Buildkite interface](#start-a-build-from-the-buildkite-interface).
- Running a command with the [Buildkite CLI](#start-a-build-using-the-buildkite-cli).
- Sending a request to the [Buildkite APIs](#start-a-build-using-the-buildkite-apis).

If you don't have a pipeline yet, follow the [Getting started](/docs/pipelines/getting-started) tutorial first. If a build doesn't start, or starts but doesn't run, see [Troubleshooting](#troubleshooting).

## Start a build by pushing code

When your pipeline's [source control provider](/docs/pipelines/source-control) sends webhook events to Buildkite Pipelines, each push to your repository starts a new build automatically. This is the most common way to start a build.

If you created your pipeline from a GitHub repository in the Buildkite interface, Buildkite Pipelines creates this webhook for you by default (see [Auto-create build triggers](/docs/pipelines/configure/auto-create-build-triggers)). For other source control providers, follow the webhook setup instructions shown after you create the pipeline, or see the setup page for your provider in [Source control](/docs/pipelines/source-control).

To start a build by pushing code:

1. Commit a change to your repository:

    ```bash
    git commit -am "Update the build script"
    ```

1. Push the commit:

    ```bash
    git push
    ```

1. In Buildkite, select **Pipelines** in the global navigation, and then select your pipeline. A new build for your commit appears at the top of the builds list, and uses your commit message as its build message.

You can also start builds from pull requests and other repository events. For GitHub, see [Running builds on pull requests](/docs/pipelines/source-control/github#running-builds-on-pull-requests).

## Start a build from the Buildkite interface

Start a build from the Buildkite interface when you haven't configured webhooks. This method is also useful when you want to build a specific commit or branch, or set environment variables for a single build.

To start a build from the Buildkite interface:

1. Select **Pipelines** in the global navigation, and then select your pipeline.
1. Select **New Build**.
1. In the **New Build** dialog, complete the following fields:
    * **Message**: A description of the build. If you leave this field blank, the commit message is used once the build starts.
    * **Commit**: The commit to build. The default value is `HEAD`, which is the latest commit on the branch.
    * **Branch**: The branch to build. The default value is your pipeline's default branch.
1. Optionally, select **Options** to set **Environment Variables** for this build only (one `KEY=value` pair per line), or select **Clean checkout** to force the agent to remove any existing build directory and check out the repository again.
1. If your pipeline's steps begin with a [block step](/docs/pipelines/configure/step-types/block-step) or [input step](/docs/pipelines/configure/step-types/input-step) that has fields, complete these fields in the **Build inputs** section of the dialog. Fields marked as **Required** must be completed.
1. Select **Create Build**. The build page opens and the build begins.

<%= image "new_build_form.png", width: 1378/2, height: 1292/2, alt: "New Build dialog with Message, Commit, Branch, and Build inputs fields" %>

To pre-populate the dialog's message and build input fields using a URL that you can bookmark, see [Using build input parameters](/docs/pipelines/configure/build-meta-data#using-build-input-parameters).

> 📘 Rebuilding an existing build
> To run a build again with the same commit, branch, message, and environment variables, open the build and select **Rebuild**. A rebuild doesn't fetch new changes from your source control provider. Learn more in [Rebuilding a build](/docs/pipelines/dashboard-walkthrough#build-page-rebuilding-a-build).

## Start a build using the Buildkite CLI

The [Buildkite CLI](/docs/platform/cli) (`bk`) lets you start builds from your terminal, which is useful for scripting and for working without leaving the command line.

To start a build using the Buildkite CLI:

1. [Install](/docs/platform/cli/installation) the Buildkite CLI.
1. [Authenticate](/docs/platform/cli/configuration) the Buildkite CLI with your Buildkite organization:

    ```bash
    bk auth login
    ```

1. Create a build, replacing `my-pipeline` with your pipeline's slug:

    ```bash
    bk build create --pipeline my-pipeline --message "Build started from the CLI"
    ```

    By default, the build uses the `HEAD` commit of your pipeline's default branch. Use `--branch` and `--commit` to build a different branch or commit, `--env` to set environment variables, and `--web` to open the new build in your browser.

For all available flags, see the [`bk build create` reference](/docs/platform/cli/reference/build#create-a-build).

## Start a build using the Buildkite APIs

To start builds from scripts, other tools, or your own services, use the Buildkite APIs. To use the REST API, you need an [API access token](/docs/apis/managing-api-tokens) with the `write_builds` scope. To use the GraphQL API, you need an API access token with GraphQL API access enabled.

### REST API

Send a `POST` request to the [create a build](/docs/apis/rest-api/builds#create-a-build) endpoint. The `commit` and `branch` properties are required:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds" \
  -H "Content-Type: application/json" \
  -d '{
    "commit": "HEAD",
    "branch": "main",
    "message": "Build started from the REST API"
  }'
```

### GraphQL API

Use the `buildCreate` mutation. For a complete example, see [Create a build on a pipeline](/docs/apis/graphql/cookbooks/builds#create-a-build-on-a-pipeline) in the GraphQL cookbook.

## Other ways to start a build

Buildkite Pipelines can also start builds in the following ways:

- **Schedules**: Start builds at regular intervals, such as nightly. See [Scheduled builds](/docs/pipelines/configure/workflows/scheduled-builds).
- **Trigger steps**: Start a build of another pipeline from a step in the current build. See [Trigger step](/docs/pipelines/configure/step-types/trigger-step).
- **Pipeline triggers**: Start builds from incoming webhooks sent by external systems, such as monitoring or deployment tools. See [Pipeline triggers](/docs/apis/webhooks/incoming/pipeline-triggers).
- **Git hooks**: Start builds from Git servers that Buildkite Pipelines doesn't integrate with directly. See [Other Git servers](/docs/pipelines/source-control/git).
- **AI tools**: Start builds from AI coding tools using the `create_build` tool of the [Buildkite MCP server](/docs/apis/mcp-server).
- **Visual Studio Code**: Start builds from your editor using the [Buildkite VS Code extension](/docs/platform/vscode-extension).

## Troubleshooting

This section covers common reasons why a build doesn't start, or starts but doesn't run any jobs. If you still have trouble, contact support at support@buildkite.com.

### Pushing code doesn't start a build

If a push to your repository doesn't create a new build, check the following:

- **Webhook setup**: Make sure the webhook from your source control provider to Buildkite Pipelines exists and is delivering events. Your provider's webhook settings usually list recent deliveries and any errors. See the setup page for your provider in [Source control](/docs/pipelines/source-control).
- **Build triggers**: Make sure the pipeline's source control settings allow builds for the event, such as pushes to branches. Select your pipeline's **Settings**, and then select your source control provider.
- **Branch filters**: If the pipeline has a branch filter pattern, pushes to branches that don't match the pattern don't create builds. See [Branch configuration](/docs/pipelines/configure/workflows/branch-configuration).
- **Skipped commits**: A commit message that contains `[skip ci]`, `[ci skip]`, `[skip-ci]`, or `[ci-skip]` doesn't create a build. See [Ignore a commit](/docs/pipelines/configure/skipping#ignore-a-commit).

To confirm that the pipeline itself works, start a build [from the Buildkite interface](#start-a-build-from-the-buildkite-interface).

### The build starts but its jobs don't run

If a build is created but its jobs don't start, check the following:

- **Agent availability**: Each job needs an agent connected to the [queue](/docs/agent/queues) that the job targets. If no agent is available on that queue, the job waits until one becomes available. Check that your agents are running and connected to the correct queue, or use [Buildkite hosted agents](/docs/agent/buildkite-hosted).
- **Block steps**: If the build reaches a block step, the build pauses until someone unblocks it. Select the block step on the build page to unblock it and continue the build.
