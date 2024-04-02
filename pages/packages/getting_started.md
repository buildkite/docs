# Getting started

👋 Welcome to Buildkite Packages! You can use Packages to house your [packages](/docs/packages#package-creation-tools) built through [Buildkite Pipelines](/docs/pipelines) or another CI/CD application, and manage them through dedicated registries. This tutorial takes you through creating package registry, cloning and running a simple Node.js package locally, and uploading this package to your new Node.js package registry.

While this tutorial utilizes a Node.js package example, Buildkite Packages supports [other package ecosystems](/docs/packages/manage-registries#create-a-registry-manage-packages-in-a-registry) too.

## Before you start

To complete this tutorial, you'll need:

- A Buildkite account. If you don't have one already, <a href="<%= url_helpers.signup_path %>">create a free account</a>.

- [Git](https://git-scm.com/downloads), to clone the Node.js package example.

- [Node.js](https://nodejs.org/en/download)—macOS users can also install Node.js with [Homebrew](https://formulae.brew.sh/formula/node).

## Create a package registry

First, create a new Node.js package registry:

1. Select _Packages_ in the global navigation to access the _Repositories_ page.
1. Select _New repository_.
1. On the _New Repository_ page, enter the mandatory name for your registry. For example, _My Node.js package registry_.

    **Note:** Since registry names cannot contain spaces or punctuation, hyphens will automatically be specified when the space key is pressed, and punctuation will not be entered.

1. Enter an optional _Description_ for the registry, which will appear under the name of the registry item on the _Repositories_ page. For example, _This is an example of a Node.js package registry_.
1. Select the required _Repo Type_ of _NodeJS (npm)_.
1. Select _Create Repository_.

    The new Node.js package registry's details page is displayed. Selecting _Packages_ in the global navigation opens the _Repositories_ page, where your new package registry will be listed.

## Clone the Node.js package example

Then, clone the Node.js package example:

1. Run the following command:

    ```bash
    git clone git@github.com:buildkite/nodejs-example-package.git
    ```

1. Change directory (`cd`) into the `nodejs-example-package` directory.
1. (Optional) Run the Node.js package (`npm run`) on the `main` field of the `package.json` file (that is, the `index.js` file), to test that it works successfully:

    ```bash
    npm run main
    ```

    The command output should display `Hello world!`.

## Configure your Node.js environment and project

Next, configure your Node.js environment to publish Node.js packages to [the Node.js package registry you created above](#create-a-package-registry):

1. Access your Node.js package registry's details page. To do this, select _Packages_ in the global navigation > your Node.js package from the list.
1. Select _Publish a Nodejs Package_ to open the dialog with code boxes.
1. Use the copy icon at the top-right of the first code box to copy the `npm` command and submit it to configure your npm config settings file (`.npmrc`) to publish to your Node.js package registry in Buildkite Packages. This command has the following format:

    ```bash
    npm set "//buildkitepackages.com/{org.slug}/{registry.name}/npm/:_authToken" package-registry-write-token
    ```

    where:
    <%= render_markdown partial: 'packages/org_slug' %>
    <%= render_markdown partial: 'packages/nodejs_package_registry_name_and_token' %>

    **Note:**
    * If your `.npmrc` file doesn't exist, this command will automatically create it for you.
    * This step only needs to be conducted once for the life of your Node.js package registry.

1. Use the copy icon at the top-right of the second code box to copy the `publishConfig` field and its value, and paste it to the end of your Node.js package's `package.json` file. Alternatively, select and copy the line of code beginning `"publishConfig": ...`. For example:

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
      "publishConfig": {"registry": "https://buildkitepackages.com/{org.slug}/{registry.name}/npm/"}
    }
    ```

    **Note:** Don't forget to add the separating comma between `"publishConfig": ...` and the previous field, that is, `"license": ...` in this case.

## Publish the package

Last, in the `nodejs-example-package` directory, publish your Node.js package to your Node.js package registry by running the `npm` command:

```bash
npm publish
```

Your Node.js package is published to your Buildkite Node.js package registry in `.tgz` format.

## Check the end result

To confirm that your Node.js package was successfully published to your Buildkite Node.js package registry:

1. View your Node.js package registry's details page, refreshing the page if necessary. (To access this page, select _Packages_ in the global navigation > your Node.js package from the list.) The package name _nodejs.example-package-1.0.1.tgz_ should appear under _Packages_.
1. Click the package name to access its details, and note the following:
    * _Installation instructions_: this section of the _Installation_ tab provides command line instructions for installing the package you just published
    * _Details_ tab: provides various checksum values for this published package
    * _About this version_: obtained from the `description` field value of the `package.json` file
    * _Details_, which lists the following (where any field values are also obtained from the `package.json` file):
        - the name of the package, obtained from the `name` field value
        - the package version, obtained from the `version` field value
        - the registry the package is located in
        - the package's visibility (_Private_ by default)
        - the distribution name/version (just _node.js_ in this case)
        - the package's license, obtained from the `licence` field value
    * _Download_: select this to download the package locally.

To return to the your Node.js package registry details page (listing all packages published to this registry), select the registry's name at the top of the page.

### Publish a new version

As an optional extra, try incrementing the version number in your `packages.json` file, [re-publishing the package to your Node.js package registry](#publish-the-package), and [checking the end result](#check-the-end-result).

## Next steps

That's it! You've created a new Buildkite package registry, configured your Node.js environment and project to publish to your new Node.js package registry, and published a Node.js package to this registry. 🎉

Learn more about how to work with Buildkite Packages in [Manage registries](/docs/packages/manage-registries).
