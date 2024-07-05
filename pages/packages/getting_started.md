# Getting started

👋 Welcome to Buildkite Packages! You can use Packages to house your [packages](/docs/packages/background#package-creation-tools) built through [Buildkite Pipelines](/docs/pipelines) or another CI/CD application, and manage them through dedicated registries. This tutorial takes you through creating a JavaScript registry, cloning and running a simple Node.js package locally, and uploading this package to your new JavaScript registry.

While this tutorial uses a Node.js package example, Buildkite Packages supports [other package ecosystems](/docs/packages/manage-registries#create-a-registry-manage-packages-in-a-registry) too.

## Before you start

To complete this tutorial, you'll need:

- A Buildkite account. If you don't have one already, <a href="<%= url_helpers.signup_path %>">create a free account</a>.

- [Git](https://git-scm.com/downloads), to clone the Node.js package example.

- [Node.js](https://nodejs.org/en/download)—macOS users can also install Node.js with [Homebrew](https://formulae.brew.sh/formula/node).

## Create a registry

First, create a new JavaScript registry:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select **New registry**.
1. On the **New Registry** page, enter the mandatory **Name** for your registry. For example, `My JavaScript registry`.

    **Note:** Since registry names cannot contain spaces or punctuation, hyphens will automatically be specified when the space key is pressed, and punctuation will not be entered.

1. Enter an optional **Description** for the registry, which will appear under the name of the registry item on the **Registries** page. For example, `This is an example of a JavaScript registry`.
1. Select the required registry **Ecosystem** of **JavaScript (npm)**.
1. If your Buildkite organization has the [teams feature](/docs/packages/permissions) enabled, select the relevant **Teams** to be granted access to the new JavaScript registry.
1. Select **Create Registry**.

    The new JavaScript registry's details page is displayed. Selecting **Packages** in the global navigation opens the **Registries** page, where your new registry will be listed.

## Clone the Node.js package example

Then, clone the Node.js package example:

1. Run the following command:

    ```bash
    git clone git@github.com:buildkite/nodejs-example-package.git
    ```

1. Change directory (`cd`) into the `nodejs-example-package` directory.
1. (Optional) Run the following `npm` command to test that the package executes successfully:

    ```bash
    npm run main
    ```

    The command output should display `Hello world!`.

## Configure your Node.js environment and project

Next, configure your Node.js environment to publish Node.js packages to [the JavaScript registry you created above](#create-a-registry):

1. Access your JavaScript registry's details page. To do this, select **Packages** in the global navigation > your npm package from the list.
1. Select **Publish a JavaScript Package** to open the dialog with code boxes.
1. Copy the `npm` command in the first code box and run it to configure your npm config settings file (`.npmrc`). This configuration allows you to publish packages to your JavaScript registry. The `npm` command has the following format:

    ```bash
    npm set "//packages.buildkite.com/{org.slug}/{registry.slug}/npm/:_authToken" registry-write-token
    ```

    where:
    <%= render_markdown partial: 'packages/org_slug' %>
    <%= render_markdown partial: 'packages/javascript_registry_slug' %>
    <%= render_markdown partial: 'packages/javascript_registry_write_token' %>

    **Note:**
    * If your `.npmrc` file doesn't exist, this command will automatically create it for you.
    * This step only needs to be performed once for the life of your JavaScript registry.

1. Copy the `publishConfig` field and its value in the second code box and paste it to the end of your Node.js package's `package.json` file. Alternatively, select and copy the line of code beginning `"publishConfig": ...`. For example:

    ```json
    {
      "name": "nodejs-example-package",
      "version": "1.0.1",
      "description": "An example Node.js package for Buildkite Packages",
      "main": "index.js",
      "scripts": {
        "main": "node index.js"
      },
      "author": "A Person",
      "license": "MIT",
      "publishConfig": {"registry": "https://packages.buildkite.com/{org.slug}/{registry.slug}/npm/"}
    }
    ```

    **Note:** Don't forget to add the separating comma between `"publishConfig": ...` and the previous field, that is, `"license": ...` in this case.

## Publish the package

Last, in the `nodejs-example-package` directory, publish your Node.js package to your JavaScript registry by running the following `npm` commands:

```bash
npm pack
npm publish
```

Your Node.js package is published to your Buildkite JavaScript registry in `.tgz` format.

## Check the end result

To confirm that your Node.js package was successfully published to your Buildkite JavaScript registry:

1. View your JavaScript registry's details page, refreshing the page if necessary. To access this page, select **Packages** in the global navigation > your Node.js package from the list.

    The package name (for example, **nodejs.example-package-1.0.1.tgz**) should appear under **Packages**.

1. Click the package name to access its details, and note the following:
    * **Installation instructions**: this section of the **Installation** tab provides command line instructions for installing the package you just published.
    * **Details** tab: provides various checksum values for this published package.
    * **About this version**: obtained from the `description` field value of the `package.json` file.
    * **Details**, which lists the following (where any field values are also obtained from the `package.json` file):
        - The name of the package, obtained from the `name` field value.
        - The package version, obtained from the `version` field value.
        - The registry the package is located in.
        - The package's visibility (**Private** by default), based on its registry's visibility.
        - The distribution name/version (just **node.js** in this case).
        - The package's license, obtained from the `license` field value.
    * **Download**: select this to download the package locally.

To return to the your JavaScript registry details page (listing all packages published to this registry), select the registry's name at the top of the page.

### Publish a new version

As an optional extra, try incrementing the version number in your `packages.json` file, [re-publishing the package to your JavaScript registry](#publish-the-package), and [checking the end result](#check-the-end-result).

Your JavaScript registry's details page should show your new package with the incremented version number.

## Next steps

That's it! You've created a new Buildkite registry, configured your Node.js environment and project to publish to your new JavaScript registry, and published a Node.js package to this registry. 🎉

Learn more about how to work with Buildkite Packages in [Manage registries](/docs/packages/manage-registries).
