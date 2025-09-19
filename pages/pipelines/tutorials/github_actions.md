# Triggering pipelines using GitHub Actions

[GitHub Actions](https://github.com/features/actions) is a GitHub-based workflow automation platform. You can use the GitHub actions [Trigger Buildkite Pipeline](https://github.com/marketplace/actions/trigger-buildkite-pipeline) to trigger a build on a Buildkite pipeline.

The Trigger Buildkite Pipeline GitHub Action allows you to:

* Create builds in Buildkite pipelines and set `commit`, `branch`, `message`.
* Save the build JSON response to `${HOME}/${GITHUB_ACTION}.json` for downstream actions.

Find the Trigger Buildkite Pipeline on [GitHub Marketplace](https://github.com/marketplace) or follow [this link](https://github.com/marketplace/actions/trigger-buildkite-pipeline) directly.

<%= image "trigger-buildkite-pipeline.png", width: 2630/2, height: 1692/2, alt: "Trigger Buildkite Pipeline GitHub Action on GitHub" %>

## Before you start

This tutorial assumes some familiarity with GitHub and using GitHub Actions. Learn more about GitHub Actions from their [documentation](https://docs.github.com/en/actions/learn-github-actions).

## Creating the workflow for Buildkite GitHub Actions

1. If a workflow directory does not exist yet, create the `.github/workflows` directory in your repo to store the workflow files for Buildkite Pipeline Action.
1. Create a [Buildkite API access token](/docs/apis/rest-api#authentication) with `write_builds` [scope](/docs/apis/managing-api-tokens#token-scopes), and save it to your GitHub repository's Settings in Secrets. Learn more about this in [Creating secrets for a repository](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets#creating-secrets-for-a-repository) in GitHub's documentation.
1. Define your GitHub Actions workflow with the details of the pipeline to be triggered. To ensure that the latest version is always used, click "Use latest version" on the [Trigger Buildkite Pipeline](https://github.com/marketplace/actions/trigger-buildkite-pipeline) page. Copy and paste the code snippet provided.
1. Configure the workflow by setting the applicable configuration options.

## Example workflow

The following workflow creates a new Buildkite build on every commit (change `my-org/my-deploy-pipeline` to the slug of your org and pipeline, and `TRIGGER_BK_BUILD_TOKEN` to the secrets env var you have defined):

```yml
on: [push]

steps:
   - name: Trigger a Buildkite Build on Push using v2.0.0
        uses: buildkite/trigger-pipeline-action@v2.0.0
        with:
          buildkite_api_access_token:  ${{ secrets.TRIGGER_BK_BUILD_TOKEN }} 
          pipeline: "lzrinc/experimental-pipeline"      
          branch: master
          commit: HEAD
          message:  ":buildkite::github: 🚀🚀🚀 Triggered from a GitHub Action"     
```
{: codeblock-file="trigger-pipeline-action.yml"}

## Configuring the workflow

Refer to the [action.yml](https://github.com/buildkite/trigger-pipeline-action/blob/master/action.yml) for the input parameters required.

See [Trigger-pipeline-action](https://github.com/buildkite/trigger-pipeline-action) for more details, code, or to contribute to or raise an issue for the Buildkite GitHub Action.
