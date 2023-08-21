# How to Trigger a Buildkite Pipeline Using GitHub Actions

[GitHub Actions](https://github.com/features/actions) is a GitHub-based workflow automation platform. You can use the [Buildkite GitHub Action](https://github.com/actions) to trigger a build on a Buildkite pipeline.

{:toc}

The Buildkite GitHub Action allows you to:

* Create builds in Buildkite pipelines and set `commit`, `branch`, `message`.
* Save the build JSON response to `${HOME}/${GITHUB_ACTION}.json` for downstream actions.

## Prerequisites

This tutorial assumes some familiarity with GitHub and using GitHub Actions. You can find the official GitHub Actions documentation [here](https://docs.github.com/en/actions/learn-github-actions).

## Installing the Buildkite GitHub Action

1. To install the action on GitHub, in your repository, create a `.github/workflows` directory to store the workflow files for Buildkite Pipeline Action

2. Search for Trigger Buildkite Pipeline on [GitHub Marketplace](https://github.com/marketplace) or follow [this link](https://github.com/marketplace/actions/trigger-buildkite-pipeline).

3. On the [Trigger Buildkite Pipeline](https://github.com/marketplace/actions/trigger-buildkite-pipeline) page, click "Use latest version".

4. Create and paste the following snippet into your trigger-pipeline-action.yml file.

```yml
- name: Trigger Buildkite Pipeline
  uses: buildkite/trigger-pipeline-action@v1.2.0
```
{: codeblock-file="trigger-pipeline-action.yml"}

<%= image "trigger-buildkite-pipeline.png", width: 2630/2, height: 1692/2, alt: "Trigger Buildkite Pipeline GitHub Action on GitHub" %>

## Creating the workflow for Buildkite GitHub Actions

1. Create a [Buildkite API access token](/docs/apis/rest-api#authentication) with `write_builds` [scope](/docs/apis/managing-api-tokens#token-scopes), and save it to your GitHub repository’s Settings in Secrets.

2. Configure your GitHub Actions workflow with the details of the pipeline to be triggered, and the settings for the build.

For example, the following workflow creates a new Buildkite build on every commit (change `my-org` to the slug of your org):

```yaml
workflow "Trigger a Buildkite Build" {
  on = "push"
  resolves = ["Build"]
}

action "Build" {
  uses = "buildkite/trigger-pipeline-action@v1.2.0"
  secrets = ["BUILDKITE_API_ACCESS_TOKEN"]
  env = {
    PIPELINE = "my-org/my-deploy-pipeline"
    COMMIT = "HEAD"
    BRANCH = "master"
    MESSAGE = ":github: Triggered from a GitHub Action"
  }
}
```
{: codeblock-file="trigger-pipeline-action.yml"}

## Configuring the workflow

Use the following configuration options:

|Env var|Description|Default|
|-|-|-|
|PIPELINE|The pipeline to create a build on, in the format `<org-slug>/<pipeline-slug>`||
|COMMIT|The commit SHA of the build. Optional.|`$GITHUB_SHA`|
|BRANCH|The branch of the build. Optional.|`$GITHUB_REF`|
|MESSAGE|The message for the build. Optional.||
|BUILD_ENV_VARS|Additional environment variables to set on the build, in JSON format. For example, `{"FOO": "bar"}`. Optional. ||

See [Trigger-pipeline-action](https://github.com/buildkite/trigger-pipeline-action) for more details, code, or to contribute to or raise an issue for the Buildkite GitHub Action.
