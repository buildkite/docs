# Bitbucket Server

Buildkite integrates with Bitbucket Server to provide automated builds based on your source control. This guide shows you how to set up your Bitbucket Server builds with Buildkite. You can run a build every time you push code to Bitbucket Server, using a webhook that you create in your Bitbucket Server.

> 📘 Buildkite plan availability and Bitbucket Server version
> Bitbucket Server is only available to Buildkite customers on [Pro or Enterprise](https://buildkite.com/pricing) plans.
> This guide is based on Bitbucket Server version 7.11.1. Earlier or later versions may have variations in the interface.

> 📘 Accessing private repositories
> Connecting Bitbucket Server to Buildkite configures webhooks and commit statuses. To give your agents access to clone private repositories, you need to configure code access separately. The recommended approach is to store an SSH key as a [Buildkite secret](/docs/pipelines/security/secrets/buildkite-secrets) and reference it with [`checkout.ssh_secret`](/docs/pipelines/configure/git-checkout#ssh-key-from-buildkite-secrets) in your pipeline YAML. For full setup instructions, see [self-hosted agent code access](/docs/agent/self-hosted/code-access) or [Buildkite hosted agent code access](/docs/agent/buildkite-hosted/code-access).

## Step 1: connect Bitbucket Server and set up a pipeline

1. Select **Settings** to open the **Organization Settings** page.
1. Navigate to **Repository Providers**.
1. Select **Bitbucket Server**.
1. In **URLs**, enter the address of your Bitbucket Server, including a port if needed. For example, `localhost:8000`. You can also restrict which network addresses are allowed to trigger builds using webhooks in **Allowed IP Addresses** in **Network Settings**.
1. Select **Save Settings**.
1. Set up a pipeline as normal. Refer to [Pipelines](/docs/pipelines) for more information.

## Step 2: confirm your setup

If your configuration worked, Buildkite automatically recognizes your repository URL as a Bitbucket Server repository. To check this, go to **Pipelines** > your specific pipeline > **Settings**. You should see **Bitbucket Server** on the side as a configurable area for your pipeline.

## Step 3: work through the in-app guide to set up your webhook

Buildkite includes built-in instructions on how to set up a Bitbucket Server webhook. This webhook allows Bitbucket Server to trigger Buildkite builds in response to events like code pushes and pull requests.

1. Navigate to **Pipelines** > your specific pipeline > **Settings** > **Bitbucket Server**.
1. Select **Bitbucket Server Setup Instructions**.
1. Follow the on screen instructions to configure your webhook.

## Branch configuration and settings

<%= render_markdown partial: 'pipelines/source_control/branch_config_settings' %>

## Using one repository in multiple pipelines and organizations

<%= render_markdown partial: 'pipelines/source_control/one_repo_multi_org' %>

## Build skipping

<%= render_markdown partial: 'pipelines/source_control/build_skipping' %>
