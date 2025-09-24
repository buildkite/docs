# Linear workspace

The Linear workspace integration lets you synchronize issues between [Linear](https://linear.app) and Buildkite. This integration supports the creation of Linear issues based on [Test Engine workflows](docs/test-engine/workflows/actions#creating-a-linear-issue).

When adding a Linear workspace integration through the [**Add Linear Notification** page](https://buildkite.com/organizations/-/services/linear/new), access for your entire Linear workspace will be authorized, along with all the teams contained within this workspace. You only need to set up this integration once per Linear workspace, after which, you can then configure action for any Linear team.

> 📘
> Setting up a Workspace requires Buildkite organization admin access.

## Connect Linear workspace

1. Select **Settings** in the global navigation and select **Notification Services** in the left sidebar.

1. Select the **Add** button on **Linear Workspace**.

    <%= image "add-linear-workspace.png", alt: "Screenshot of the 'Add' button for adding a Linear workspace service to Buildkite" %>

1. Select the **Add to Linear** button:

    <%= image "add-to-linear-workspace.png", alt: "Screenshot of 'Add Linear workspace service' screen on Buildkite. It shows an 'Add to Linear workspace' button" %>

    This action redirects you to Linear.

1. Log in to Linear and grant Buildkite permission to access your workspace.

1. After granting access, you can then configure the [Test Engine workflow Linear action](/docs/test-engine/workflows/actions#creating-a-linear-issue).

## Privacy policy

For details on how Buildkite handles your information, please see Buildkite's [Privacy Policy](https://buildkite.com/about/legal/privacy-policy/).
