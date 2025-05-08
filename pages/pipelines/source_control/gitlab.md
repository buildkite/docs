# GitLab

You can use Buildkite to run builds on [GitLab](https://about.gitlab.com/) commits.

## GitLab repositories

If you host your repositories on [gitlab.com](https://gitlab.com/) enter your gitlab.com repository URL when you create your pipeline in Buildkite (for example, `git@gitlab.com:your/repo.git`) and follow the instructions provided on that page to set up webhooks.

## GitLab Community and GitLab Enterprise editions

>📘
> The earliest supported version of GitLab is <a href=https://about.gitlab.com/2014/10/22/gitlab-7-4-released/>7.4</a>.

1. Open your Buildkite organization's **Settings** and choose [**Repository Providers**](https://buildkite.com/organizations/-/repository-providers).
1. Select **GitLab Community/Enterprise Edition**.
1. Select the **GitLab Edition Type** (**Community Edition** or **Enterprise Edition**) you want to connect to your Buildkite organization.
1. Enter the URL to your GitLab installation (for example, `https://git.example.org`).
1. You can optionally specify a list of IP addresses to restrict where builds can be triggered from. This field accepts a space separated list of networks in [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing).

    <%= image "gitlab-org-settings.png", width: 1744/2, height: 916/2, alt: "Screen of Buildkite Organization GitLab Settings" %>

1. Select **Save Settings** before leaving this page.
1. Create a new pipeline on Buildkite using your GitLab repository's URL (for example, `git@git.mycompany.com:your/repo.git`) and follow the instructions on the pipeline creation page.

## Branch configuration and settings

<%= render_markdown partial: 'pipelines/source_control/branch_config_settings' %>

## Using one repository in multiple pipelines and organizations

<%= render_markdown partial: 'pipelines/source_control/one_repo_multi_org' %>

## Build skipping

<%= render_markdown partial: 'pipelines/source_control/build_skipping' %>

## Commit statuses

Buildkite can update commit statuses on GitLab. You can then see the status of your builds from your GitLab.com commits and merge requests with direct links back to your Buildkite build.

For GitLab.com, connect your Buildkite user account to your GitLab user account from your user > **Connected Apps** page:

    <%= image "gitlab-connected-app.png", width: 1164/2, height: 369/2, alt: "Screen of Buildkite User Connected Apps with GitLab.com connected" %>

Then go to **Pipelines** > your specific pipeline > **Settings** > your Git service provider and enable **Update commit statuses**:

    <%= image "gitlab-update-commit-status.png", width: 1499/2, height: 962/2, alt: "Screen of Buildkite User Connected Apps with GitLab.com connected" %>

For self-managed GitLab, make sure you have configured API authentication on your GitLab repository provider on your organization > **Settings** > **Repository Providers** > **GitLab** page:

    <%= image "gitlab-repository-provider-authentication.png", width: 1168/2, height: 1129/2, alt: "Screen of Buildkite GitLab repository provider settings page with authentication configured" %>

Then follow the same procedure as above.
