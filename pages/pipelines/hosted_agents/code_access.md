# Hosted agents code access

This page details changes that need to be made to the GitHub integration to provide code access to the Buildkite hosted agents.

To learn more about changes that may need to be completed at an individual pipeline level, see [Pipeline migration](/docs/pipelines/hosted-agents/pipeline-migration).

## Private repositories

During the trial, access to private repositories is only supported through GitHub. If you have requirements to access private repositories from another source control service, please contact support.

To use a private GitHub repository with Buildkite hosted agents, you'll need to authorize Buildkite to access your repository.

1. Navigate to your [Buildkite organization's settings page](https://buildkite.com/organizations/~/settings).
1. On the left hand menu select _Repository Providers_.
1. Select the _GitHub (with code access)_ option.
1. Follow the prompts to authorize the services on your GitHub account. You can restrict access to specific repositories during setup.

## Public repositories

Buildkite does not require any special permissions to access public repositories.
