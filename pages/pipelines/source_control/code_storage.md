# Code Storage

[Code Storage](https://code.storage) is a Git repository hosting service. Buildkite Pipelines integrates with Code Storage to create builds from branch and tag pushes, check out code on hosted agents, and publish build status as Git notes. An organization administrator connects a Code Storage organization once, then pipelines in that Buildkite organization can select repositories from the connection.

> 📘 Public preview
> The Code Storage integration is in public preview and available to all Buildkite organizations. Share feedback or report issues with the preview at [support@buildkite.com](mailto:support@buildkite.com?subject=Code%20Storage%20Feedback).

## Connect a Code Storage organization

Connecting a Code Storage organization requires [Buildkite organization administrator](/docs/platform/team-management/permissions#manage-teams-and-permissions-organization-level-permissions) access. Pipeline maintainer access alone does not grant permission to connect a repository provider.

### Create a private API key in Code Storage

1. Sign in to your [Code Storage dashboard](https://code.storage/auth/post-login).
1. Select **Developers** > **Keys**.
1. Create a new key for Buildkite, then copy its contents. Code Storage issues an ECDSA P-256 private key.

### Connect Code Storage to Buildkite

1. Select **Settings** in the global navigation, then select [**Repository Providers**](https://buildkite.com/organizations/~/repository-providers).
1. Select **Code Storage**.
1. In **Organization identifier**, enter the organization name from your Code Storage dashboard URL. For example, enter `acme` for `https://code.storage/acme/repositories`.
1. In **Private API key**, paste the key you created in Code Storage.
1. Select **Connect Code Storage**.

Buildkite validates the key by listing the organization's repositories before saving the connection. If validation fails, check the organization identifier and key, then try again.

Only one connection can exist per Code Storage organization within a Buildkite organization.

## Configure the webhook

A Code Storage connection needs a webhook to trigger builds from repository pushes. Configuring or replacing the webhook also requires organization administrator access.

1. From the connection settings page, select **Configure webhook**, or **Replace webhook** if a webhook is already configured.
1. Copy the **Webhook URL** shown in the dialog.
1. Follow the **Code Storage webhooks** link in the dialog. Create a webhook for the organization using the copied URL, with **push** events enabled.
1. Copy the signing secret that Code Storage generates for the webhook.
1. In Buildkite, paste the secret into **Webhook secret**, then select **Save webhook**.

Saving activates the new webhook URL and secret together. If you're replacing an existing webhook, the previous URL stops working as soon as you save, so remove it from Code Storage afterward.

Connecting Code Storage or replacing its private key does not affect an existing webhook.

### Webhook status

The connection settings page shows the webhook status:

- **Waiting for events**: The webhook is configured but hasn't received a verified push yet.
- **Active**: The connection has verified a push with the current secret. Replacing the webhook resets the status to **Waiting for events**.

To inspect delivery history, select **View deliveries in Code Storage** on the connection settings page.

## Replace the private key

To replace the private key:

1. Create a new key in your Code Storage dashboard, under **Developers** > **Keys**.
1. On the Code Storage connection settings page, select **Replace Private Key**.
1. Paste the new key, then select **Replace Private Key**.
1. Remove the previous key from your Code Storage dashboard.

## Create a pipeline

After connecting Code Storage, create a pipeline from one of its repositories:

1. Select **Pipelines** > **New Pipeline**.
1. From **Git scope**, select the Code Storage connection. It appears as **Code Storage (organization identifier)**.
1. From **Repository**, search for and select the repository.
1. Complete the remaining pipeline settings, then select **Create pipeline**.

Buildkite Pipelines saves the repository's canonical HTTPS checkout URL, for example `https://acme.code.storage/team/app.git`.

## Change a pipeline repository

To associate an existing pipeline with a different Code Storage repository:

1. Select **Pipelines** > your pipeline > **Settings** > **Code Storage**.
1. In **Repository Settings**, select the Code Storage connection and repository.
1. Select **Save Repository**.

If the pipeline's Code Storage connection is disconnected or unavailable, reconnect the Code Storage organization to restore push builds, hosted-agent checkout, and Git notes delivery.

Buildkite organization administrators also see a **Repository Provider** panel below **Repository Settings**. Select **Code Storage (organization identifier)** to manage the matching organization connection. Pipeline editors who aren't organization administrators don't see this panel.

## Configure build triggers

Select **Pipelines** > your pipeline > **Settings** > **Code Storage**. In **Code Storage Settings**, configure which events create builds:

- **Build branches**: Creates builds when commits are pushed to branches. This setting is enabled by default.
- **Build tags**: Creates builds when tags are pushed. This setting is disabled by default.

Select **Save Code Storage Settings** to apply your changes. You can also use a [conditional expression](/docs/pipelines/configure/conditionals#conditionals-in-pipelines) or [branch filter](/docs/pipelines/configure/workflows/branch-configuration) to limit which pushes create builds.

Deleted branches and tags don't create builds.

Code Storage triggers builds through the organization's webhook, so there's no per-pipeline webhook to configure.

## Publish build status as Git notes

By default, Buildkite Pipelines publishes build status as a [Git note](https://code.storage/docs/repos/git-notes) on the build's commit. The note is a single line that links back to the build, for example:

```text
[Build #3](https://buildkite.com/acme-inc/example-pipeline/builds/3) passed (1m 32s)
```

Is this Git notes format useful for your workflow? Would adding a JSON format option help? [Share your feedback](mailto:support@buildkite.com?subject=Code%20Storage%20Feedback).

Buildkite Pipelines maintains one note for the latest build of each commit and pipeline, rather than a history of notifications. The note is updated when a build is created, starts, starts failing, finishes, or is skipped. Status text includes `scheduled`, `started`, `is failing`, `passed`, `failed`, `canceled`, `skipped`, and blocked states. Passed, failed, and blocked builds include the run time when it's available.

Notes can be temporarily absent while an update is retried. Use the build page in Buildkite Pipelines to check its current status.

For builds triggered from an annotated tag, the note is attached to the tag's underlying commit rather than the immutable tag object. The pipeline's checkout is unaffected and still uses the original tag.

Notes are published to `refs/notes/buildkite/<org-slug>/<pipeline-slug>` on the connected repository, using your Buildkite organization and pipeline slugs. Renaming either starts a new ref for future notes rather than moving existing ones. See the Code Storage Git notes documentation for how to read notes.

To stop a pipeline from publishing Git notes:

1. Select **Pipelines** > your pipeline > **Settings** > **Code Storage**.
1. In **Code Storage Settings**, clear **Publish Git notes**.
1. Select **Save Code Storage Settings**.

Disabling this setting stops future notes but doesn't remove existing notes or disable push builds and checkout.

## Check out private repositories on hosted agents

Command jobs running on [Buildkite hosted agents](/docs/agent/buildkite-hosted) automatically receive a short-lived, read-only credential to check out a connected Code Storage repository. No SSH key or additional pipeline configuration is required.

Buildkite issues a credential scoped to the exact repository configured on the pipeline, valid for five minutes. Native authentication applies only to jobs running on Buildkite hosted agents.

## Disconnect Code Storage

To disconnect a Code Storage organization:

1. Select **Settings** > **Repository Providers** > the Code Storage connection.
1. In **Disconnect**, select **Disconnect**.

Disconnecting stops webhook-triggered builds, hosted-agent checkout, and Git notes delivery for pipelines using that connection. Existing notes remain in the repositories. Disconnecting doesn't remove the private key or webhook from Code Storage. Remove those separately in your Code Storage dashboard if you no longer need them.
