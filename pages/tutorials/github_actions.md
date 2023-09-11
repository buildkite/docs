# Triggering pipelines using GitHub Actions

[GitHub Actions](https://github.com/features/actions) is a GitHub-based workflow automation platform. You can use the GitHub actions [Trigger Buildkite Pipeline](https://github.com/marketplace/actions/trigger-buildkite-pipeline) to trigger a build on a Buildkite pipeline.
 

The Trigger Buildkite Pipeline GitHub Action allows you to:

* Create builds in Buildkite pipelines and set `commit`, `branch`, `message`.
* Save the build JSON response to `${HOME}/${GITHUB_ACTION}.json` for downstream actions.

## Prerequisites

This tutorial assumes some familiarity with GitHub and using GitHub Actions. You can find the official GitHub Actions documentation [here](https://docs.github.com/en/actions/learn-github-actions).

## Using the Trigger Buildkite Pipeline GitHub Action

1. Search for Trigger Buildkite Pipeline on [GitHub Marketplace](https://github.com/marketplace) or follow [this link](https://github.com/marketplace/actions/trigger-buildkite-pipeline).

2. On the [Trigger Buildkite Pipeline](https://github.com/marketplace/actions/trigger-buildkite-pipeline) page, click "Use latest version".

3. Create and paste the following snippet into your trigger-pipeline-action.yml file.

```yml
- name: Trigger Buildkite Pipeline
  uses: buildkite/trigger-pipeline-action@v1.6.0
```
{: codeblock-file="trigger-pipeline-action.yml"}

<%= image "trigger-buildkite-pipeline.png", width: 2630/2, height: 1692/2, alt: "Trigger Buildkite Pipeline GitHub Action on GitHub" %>

## Creating the workflow for Buildkite GitHub Actions

1. Create a `.github/workflows` directory in your repo to store the workflow files for Buildkite Pipeline Action

2. Create a [Buildkite API access token](/docs/apis/rest-api#authentication) with `write_builds` [scope](/docs/apis/managing-api-tokens#token-scopes), and save it to your GitHub repository’s Settings in Secrets. You can read more about [Creating encrypted secrets for a repository in GitHub](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository).

2. Configure your GitHub Actions workflow with the details of the pipeline to be triggered, and the settings for the build.

For example, the following workflow creates a new Buildkite build on every commit (change `my-org/my-deploy-pipeline` to the slug of your org and pipeline, and `TRIGGER_BK_BUILD_TOKEN` to the secrets env var you have defined):

```yaml
on: [push]

steps:
  - name: Trigger a Buildkite Build
    uses: "buildkite/trigger-pipeline-action@v1.6.0"
    env:
      BUILDKITE_API_ACCESS_TOKEN: ${{ secrets.TRIGGER_BK_BUILD_TOKEN }} 
      PIPELINE: "my-org/my-deploy-pipeline"
      BRANCH: "master"
      COMMIT: "HEAD"
      MESSAGE:  ":github: Triggered from a GitHub Action"  
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
|BUILD_ENV_VARS|Additional environment variables to set on the build, in JSON format. e.g. `{"FOO": "bar"}`. Optional. ||
|BUILD_META_DATA|Meta data to set on the build, in JSON format. e.g. `{"FOO": "bar"}`. Optional. ||
|IGNORE_PIPELINE_BRANCH_FILTER | Ignore pipeline branch filtering when creating a new build. true or false. Optional. ||

From v1.6.0, optional input parameters can now be used to pass in the configuration options. However, configuration defined as environment variables take precedence over the input parameters.

```
on: [push]

steps:
  - name: Trigger a Buildkite Build
    uses: "buildkite/trigger-pipeline-action@v1.6.0"
    with:
      buildkite-token: ${{ secrets.TRIGGER_BK_BUILD_TOKEN }} 
      pipeline: "my-org/my-deploy-pipeline"
      branch: "master"
      commit: "HEAD"
      message:  ":github: Triggered from a GitHub Action"
      build-env-vars: '{"TRIGGERED_FROM_GHA": "true"}'
      build-meta-data: '{"FOO": "bar"}'
      ignore-pipeline-branch-filter: true     
```
      
See [Trigger-pipeline-action](https://github.com/buildkite/trigger-pipeline-action) for more details, code, or to contribute to or raise an issue for the Buildkite GitHub Action.
