# GitHub

Buildkite can connect to a GitHub repository in your GitHub account or GitHub organization and use GitHub's [REST API endpoints for commit statuses](https://docs.github.com/en/rest/commits/statuses) to update the status of commits in pull requests.

To complete this integration, you need admin privileges for your GitHub repository.

## Connecting Buildkite and GitHub

You can use the [Buildkite app for GitHub](#connect-your-buildkite-account-to-github-using-the-github-app) to connect a Buildkite organization to a GitHub organization.

> 📘 Benefits of using the GitHub App
> Using GitHub App removes the reliance on individual user connections to report build statuses. See the <a href="https://buildkite.com/changelog/102-github-app-integration">changelog announcement</a>.

If you want to [connect using OAuth](#connect-your-buildkite-account-to-github-using-oauth) you can still do so from your **Personal Settings**.

## Connect your Buildkite account to GitHub using the GitHub App

Connecting Buildkite and GitHub using the GitHub App lets your GitHub organization admins see permissions and manage access on a per-repository basis.

> 📘 Required permissions for adding a provider
> The user adding the provider needs to be a Buildkite user connected to a GitHub user who has administrative privileges on both Buildkite and the GitHub organizations.

1. Open your Buildkite organization's **Settings**.
1. Select [**Repository Providers**](https://buildkite.com/organizations/~/repository-providers) > **GitHub (Limited Access)**.
    <%= image "repository-providers.png", width: 2338/2, height: 1600/2, alt: "Screenshot of the Buildkite Repository Providers" %>
1. Select **Connect to a new GitHub Account**. If you have never connected your Buildkite and GitHub accounts before, you will first need to select **Connect** and authorize Buildkite.
1. Select the GitHub organization you want to connect to your Buildkite organization.
1. Choose which repositories Buildkite should have access to, then select **Install**.

You can now [set up a pipeline](#set-up-a-new-pipeline-for-a-github-repository).

## Buildkite GitHub permissions

When you connect your GitHub organization, Buildkite needs the following permissions:

- Read access to metadata. Learn more about this from [GitHub's documentation](https://docs.github.com/en/rest/authentication/permissions-required-for-github-apps#repository-permissions-for-metadata).

- Read and write access to checks, commit statuses, deployments, pull requests, and repository hooks: this is needed for Buildkite to perform tasks such as running a build on pull requests and reporting that build status directly on the PR on GitHub.

## Set up a new pipeline for a GitHub repository

1. Select **Pipelines** > **New pipeline**.
1. Enter your pipeline details, including your GitHub repository URL in the form `git@github.com:your/repo`.

    <%= image "new-pipeline.png", width: 1550/2, height: 846/2, alt: "Screenshot of adding a new pipeline " %>

1. If you are still using the web steps visual editor, add at least one step to your pipeline. Refer to [Defining Steps - Adding steps](/docs/pipelines/configure/defining-steps#adding-steps) for more information.
1. Select **Create Pipeline**.
1. Follow the onscreen instructions to set up a webhook:

    1. Add a new webhook in GitHub.
    1. Paste in the provided webhook URL.
    1. Select `application/json` as the content type of the webhook.
    1. Select **Deployments**, **Merge groups**, **Pull requests**, and **Pushes** as events to trigger the webhook.

    The repository webhook is required so that the Buildkite GitHub app does not need read access to your repository.

1. If using the YAML steps editor, add at least one step to your pipeline, then select **Save and Build**. Refer to [Defining Steps - Adding steps](/docs/pipelines/configure/defining-steps#adding-steps) for more information.

If you need to set up the webhook again, you can find the instructions linked at the bottom of the pipeline GitHub settings page.

You can edit your pipeline configuration at any time in your pipeline's **Settings**.

## Branch configuration and settings

<%= render_markdown partial: 'pipelines/source_control/branch_config_settings' %>

## Running builds on pull requests

To run builds for GitHub pull requests, edit the GitHub settings for your Buildkite pipeline and choose the **Build Pull Requests** checkbox.

Optionally, select one or more of the following:

- **Limit pull request branches**
- **Skip pull request builds for existing commits**
- **Rebuild pull requests when they become ready for review**
- **Build when pull request base branch is changed**
- **Build when pull request labels are changed**
- **Build pull requests from third-party forked repositories**. Make sure to check the [managing secrets](/docs/pipelines/security/secrets/managing) guide if you choose to do this.

If you want to control which third-party forks can trigger builds in GitHub, you can prefix the branches from third-party forks with the contributor's username. For example, the `main` branch from `some-user` becomes `some-user:main`. You can then detect these using a pre-command hook or something similar before running a build. To enable prefixing the branch names, go to the GitHub settings for the pipeline and select **Prefix third-party fork branch names**.

If you want to run builds only on pull requests, set the **Branch Filter Pattern** in the pipeline to a branch name that will never occur (such as "this-branch-will-never-occur"). Pull request builds ignore the **Branch Filter Pattern**, and all pushes to other branches that don't match the pattern are ignored.

When you create a pull request, two builds are triggered: one for the pull request and one for the most recent commit. However, any commit made after the pull request is created only triggers one build.

> 📘 Webhook events from GitHub pull requests that trigger Buildkite pipeline builds
> A Buildkite pipeline's build can be triggered by pull request-related events, such as when a pull request (PR) is opened, a PR's stage is changed from **Draft** to **Open** (using **Ready for review**), and when a PR's labels are changed (if this setting is enabled in your pipeline's settings).

## Running builds on merge queues

To enable merge queue builds, edit the GitHub settings for the pipeline and select **Build merge queues**.

> 🚧 Ensure GitHub webhook has _Merge groups_ events enabled
> Buildkite relies on receiving `merge_group` webhook events from GitHub to create builds for merge groups in the merge queue. Ensure your pipeline's [webhook](/docs/pipelines/source-control/github#set-up-a-new-pipeline-for-a-github-repository) has the _Merge groups_ event enabled before enabling merge queue builds.

Enabling this will prevent ordinary code pushes to `gh-readonly-queue/*` branches from creating builds, instead builds will be created in response to `merge_group` webhook events from GitHub. Merge queue builds ignore any pipeline-level branch filter settings and do not support [skipping via a commit message](/docs/pipelines/configure/skipping#ignore-a-commit).

To cancel running builds when the corresponding GitHub merge queue entry is destroyed, select the **Cancel builds for destroyed merge groups** option. The way the agent handles the [`if_changed` attribute](/docs/agent/v3/cli-pipeline#apply-if-changed) during pipeline uploads can also be influenced via the **Use base commit when making `if_changed` comparisons** setting.

For more information about the interaction between GitHub merge queues and Buildkite, see our [merge queue tutorial](/docs/pipelines/tutorials/github-merge-queue).

## Running builds on git tags

Builds are only run for tags when a [`push` event is triggered](https://docs.github.com/en/developers/webhooks-and-events/webhook-events-and-payloads#push). To enable builds for `push` events for git tags, edit the **GitHub settings** for your Buildkite pipeline, and choose the **Build Tags** checkbox.

Before triggering builds for git tags from the [API](/docs/apis/rest-api/builds#create-a-build) or a [scheduled build](/docs/pipelines/configure/workflows/scheduled-builds), make sure your agent is configured to fetch git tags: `BUILDKITE_GIT_FETCH_FLAGS="-v --prune --tags"`.

> 📘 Build tags and `BUILDKITE_BRANCH`
> When a build is triggered from a GitHub tag `push` event webhook, both the `BUILDKITE_TAG` and `BUILDKITE_BRANCH` environment variables are set to the name of the git tag being built.

## Noreply email handling

When you [connect your GitHub account to Buildkite](#connecting-buildkite-and-github) the email address associated with the GitHub account is added to your Buildkite account. If you've got GitHub set not to display your email, `[username]@users.noreply.github.com` or the more recent `[username+id]@users.noreply.github.com` is added instead. The email address of a commit is one of the ways Buildkite matches webhook builds to users.

## Customizing commit statuses

The commit status is the label used to identify the Buildkite checks on your commits and pull requests on GitHub. Normally, Buildkite autogenerates these statuses.

For example, if you select **Update commit statuses** in your **Pipeline Settings**:

<%= image "update-commit-statuses-on.png", alt: "Screenshot of GitHub build settings with Update commit statuses enabled" %>

Your checks will appear on your pull request as **buildkite/your-pipeline-name**:

<%= image "github-default-status.png", alt: "Screenshot of the resulting GitHub pull request statuses" %>

You can customize the commit statuses, for example to reuse the same pipeline for multiple components in a monorepo, at both the build and step level, using the [`notify`](/docs/pipelines/configure/notifications) attribute in your `pipeline.yml`.

### Build level

1. Add the following to your `pipeline.yml`, at the top level:

    ```yaml
    notify:
      - github_commit_status:
          context: "my-custom-status"
    ```

1. In **Pipeline** > your specific pipeline > **Settings** > **GitHub**, make sure **Update commit statuses** is not selected. Note that this prevents Buildkite from automatically creating and sending statuses for this pipeline, meaning you will have to handle all commit statuses through the `pipeline.yml`.
1. When you make a new commit or pull request, you should see **my-custom-status** as the commit status:
    <%= image "github-custom-status.png", alt: "Screenshot of GitHub build settings and the resulting GitHub pull request statuses" %>

In a setup for a repository containing one codebase and one `pipeline.yml`, this customizes the commit status for the pipeline. However, if you have multiple `pipeline.yml` files in one repo, feeding in to the same Buildkite pipeline, this allows you to have different statuses when building different sections of the repo.

For example, if you have a monorepo containing three applications, you could use the same pipeline, with different `pipeline.yml` files for each application. Each `pipeline.yml` can contain a different GitHub status.

When a _build level_ GitHub commit status has been set (as part of an [uploaded pipeline YAML file](/docs/agent/v3/cli-pipeline#uploading-pipelines)), as opposed to a _pipeline level_ GitHub commit status, where the `notify` block is defined within the [YAML step editor of the Buildkite Pipelines interface](/docs/pipelines/configure/defining-steps#adding-steps), then the GitHub status is only reported _after_ the build has completed, because the `notify` block is evaluated after the build has started. By moving the GitHub status notification block to the pipeline level (in the YAML step editor of the Buildkite Pipelines interface), the `notify` block will be evaluated when the build starts and sends off the commit status to GitHub.

### Step level

1. Add `notify` to a command in your `pipeline.yml`:

    ```yaml
    steps:
      - label: "Example Script"
        command: "script.sh"
        notify:
          - github_commit_status:
              context: "my-custom-status"
    ```
1. In **Pipeline** > your specific pipeline > **Settings** > **GitHub**, you can choose to either:
    + Make sure **Update commit statuses** is not selected. Note that this prevents Buildkite from automatically creating and sending statuses for this pipeline, meaning you will have to handle all commit statuses through the `pipeline.yml`.
    + Enable both **Update commit statuses** and **Create a status for each job**. Buildkite sends its default statuses as well as your custom status.
1. When you make a new commit or pull request, you should see **my-custom-status** as the commit status:
    <%= image "github-custom-status.png", alt: "Screenshot of GitHub build settings and the resulting GitHub pull request statuses" %>

You can also define the commit status in a group step:

```yaml
steps:
  - group: "\:lock_with_ink_pen\: Security Audits"
    key: "audits"
    notify:
    - github_commit_status:
        context: "group status"

    steps:
      - label: "\:brakeman\: Brakeman"
        command: ".buildkite/steps/brakeman"
      - label: "\:bundleaudit\: Bundle Audit"
        command: ".buildkite/steps/bundleaudit"
      - label: "\:yarn\: Yarn Audit"
        command: ".buildkite/steps/yarn"
      - label: "\:yarn\: Outdated Check"
        command: ".buildkite/steps/outdated"
```

When you set a custom commit status on a group step, GitHub only displays one status for the group. A passing result only shows when all jobs in the group pass. If you want to show custom commit statuses for each job, set them on the individual step.

## Using one repository in multiple pipelines and organizations

<%= render_markdown partial: 'pipelines/source_control/one_repo_multi_org' %>

<%= render_markdown partial: 'pipelines/source_control/one_repo_multi_org_github' %>

## Build skipping

<%= render_markdown partial: 'pipelines/source_control/build_skipping' %>

## Connect your Buildkite account to GitHub using OAuth

To connect your GitHub account:

1. Open your [Buildkite **Personal Settings**](https://buildkite.com/user/settings).
1. Select [**Connected Apps**](https://buildkite.com/user/connected-apps).
1. Select the GitHub **Connect** button:
    <%= image "personal-settings.png", width: 1650/2, height: 642/2, alt: "Screenshot of the Buildkite Connected Apps screen" %>
1. Select **Authorize Buildkite**. GitHub redirects you back to your **Connected Apps** page.

You can now [set up a pipeline](#set-up-a-new-pipeline-for-a-github-repository).

## Using GitHub App installation access tokens

> 📘 The difference between repository authentication and account connection
> Configuring a GitHub App for repository authentication is different from using the [Buildkite GitHub App](#connect-your-buildkite-account-to-github-using-the-github-app) to connect your Buildkite account to GitHub.

An alternative to using SSH keys for accessing your private repositories is to use the GitHub App and GitHub's [installation access tokens](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-an-installation-access-token-for-a-github-app). This approach requires a private key for generating a JSON Web Token (JWT) that is exchanged for an installation access token. The repository permissions of the GitHub App can be scoped to read-only, and every generated installation access token can be set to expire after 1 hour.

### Configuring a GitHub App for repository authentication

> 📘 GitHub Organization access prerequisites
> You need to be an Admin of the GitHub Organization to be able to create and install the GitHub App and follow the steps outlined in this instruction.

#### Create the GitHub App

To register a GitHub App, follow the GitHub [documentation](https://docs.github.com/en/enterprise-cloud@latest/apps/creating-github-apps/registering-a-github-app/registering-a-github-app#registering-a-github-app). Configure a new GitHub App:

- GitHub App name: choose a unique name (for example, buildkite-agent-ro-access)
- Homepage URL: your company's homepage
- Webhook:
    + Uncheck **Active** (webhooks are not required)
    + Webhook URL (leave blank)
    + Secret (leave blank)
- Permissions:
    + Repository Permissions:
        - Contents: choose either `Read-only` or `Read and write`, depending on whether write access will be required to push files
        - Metadata: select `Read-only` (required for basic repository info)
        - Pull requests: choose either `Read-only` or `Read and write`, depending on whether read or write access will be required for pull requests
- Where can this GitHub App be installed?
    + Choose "Only on this account"

After the GitHub App has been configured with the settings outlined above, click the **Create GitHub App** button. You will see the **General settings** of the new GitHub App.

> 📘 GitHub App's Client ID
> The value of the GitHub App's Client ID displayed on the General settings page will be required for generating installation access tokens. Make sure you have this value available.

#### Generate authentication keys

In order to create a JWT that can be exchanged for an installation access token, a private key must be generated for the GitHub App. This private key can then be stored in [Buildkite Secrets](/docs/pipelines/security/secrets/buildkite-secrets) and securely accessed by a Buildkite Agent. To generate a private key:

- In your GitHub App's **General settings**, scroll to **Private keys**
- Click the **Generate a private key** button
- This will download a `.pem` file of the newly generated private key
- Create a new [Buildkite Secret](/docs/pipelines/security/secrets/buildkite-secrets) in the [Cluster(s)](/docs/pipelines/clusters) containing the Buildkite Agents that require access to your private repositories
    + Add the contents of the `.pem` file as the secret's _Value_

> 📘 Private key Buildkite Secret
> The value of the Buildkite Secret's name contains the private key and will be required when generating installation access tokens. Make sure you have this value available as it will be referenced by `buildkite-agent secret get <bk-secret-name>` command in the agent environment hook.

#### Install the newly created GitHub App

After creating the GitHub App, you can install this app into your account. To install the GitHub App, go to the app's settings and select **Install App** from the left-hand menu. Choose the account into which you want to install the GitHub App. Choose the repositories that the GitHub App will have access to, based on the repository permissions selected during the GitHub App's creation. After selecting the GitHub App's repository access, click the **Install** button.

> 📘 GitHub App's Installation ID
> The value of the GitHub App's Installation ID will be required for generating installation access tokens. This value can be found at the end of the URL after installation is complete: `.../settings/installations/<installation_id>`. Make sure you have this value available.

### Generating tokens

The GitHub documentation describes the [process](https://docs.github.com/en/enterprise-cloud@latest/apps/creating-github-apps/authenticating-with-a-github-app/generating-an-installation-access-token-for-a-github-app#generating-an-installation-access-token) of generating a JWT and then exchanging it for an installation access token. There are a few examples available that show how you can [generate a JWT](https://docs.github.com/en/enterprise-cloud@latest/apps/creating-github-apps/authenticating-with-a-github-app/generating-a-json-web-token-jwt-for-a-github-app#generating-a-json-web-token-jwt) using some common programming languages. The example that follows will be using Bash to configure a `pre-checkout` [agent hook](/docs/agent/v3/hooks#hook-locations-agent-hooks).

#### Configure agent hook

> 📘 OpenSSL package requirement
> The `pre-checkout` hook example below requires the `openssl` package to be installed and available to the Buildkite Agent performing the checkout.

In order to have the agent generate a GitHub App installation token, add the following code to your [agent hooks directory](/docs/agent/v3/hooks#hook-locations) as a `pre-checkout` hook, configuring the variables at the beginning of the hook with the GitHub App's Client ID (`client_id`), Installation ID (`installation_id`), and Buildkite Secret name (`private_key_secret_name`):

```bash
#!/usr/bin/env bash

set -o pipefail

echo "~~~ \:lock_with_ink_pen\: Generating JWT for GitHub App access token exchange"
client_id= # Client ID of GitHub App
private_key_secret_name= # Buildkite Secret containing private key
installation_id= # Installation ID of GitHub App

pem=$( buildkite-agent secret get ${private_key_secret_name} )

now=$(date +%s)
iat=$((${now} - 60)) # Issues 60 seconds in the past
exp=$((${now} + 600)) # Expires 10 minutes in the future

b64enc() { openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n'; }

header_json='{
    "typ":"JWT",
    "alg":"RS256"
}'
# Header encode
header=$( echo -n "${header_json}" | b64enc )

payload_json="{
    \"iat\":${iat},
    \"exp\":${exp},
    \"iss\":\"${client_id}\"
}"
# Payload encode
payload=$( echo -n "${payload_json}" | b64enc )

# Signature
header_payload="${header}"."${payload}"
signature=$(
    openssl dgst -sha256 -sign <(echo -n "${pem}") \
    <(echo -n "${header_payload}") | b64enc
)

# Create JWT
JWT="${header_payload}"."${signature}"

echo "~~~ \:github\: Requesting GitHub App installation access token"
# Exchange your JWT for the installation access token
access_token=$(curl -sS --request POST \
    --url "https://api.github.com/app/installations/${installation_id}/access_tokens" \
    --header "Accept: application/vnd.github+json" \
    --header "Authorization: Bearer ${JWT}" \
    --header "X-GitHub-Api-Version: 2022-11-28" | awk -F'"' '/"token"/ {print $4}')

echo "~~~ \:git\: Configuring Git credential helper to use installation access token"
# Store the installation access token in ~/.git-credentials and configure the credential helper
echo "https://x-access-token:${access_token}@github.com" > ~/.git-credentials
git config --global url."https://github.com/".insteadOf git@github.com:
git config --global credential.helper store
```
