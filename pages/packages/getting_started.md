# Getting started

👋 Welcome to Buildkite Packages! You can use Packages to house your [packages](/docs/packages#package-creation-tools) built through [Buildkite Pipelines](/docs/pipelines) or another CI/CD application, and manage them through dedicated registries. This tutorial takes you through creating package registry, cloning and running a simple Node.js package locally, and uploading this package to your new Node.js package registry.

## Before you start

To complete this tutorial, you'll need:

- A Buildkite account. If you don't have one already, <a href="<%= url_helpers.signup_path %>">create a free account</a>.

- [Git](https://git-scm.com/downloads), to clone the Node.js package example.

- [Node.js](https://nodejs.org/en/download)—macOS users can also install Node.js with [Homebrew](https://formulae.brew.sh/formula/node).

## Create a package registry

To create a new Node.js package registry:

1. Select _Packages_ in the global navigation to access the _Repositories_ page.
1. Select _New repository_.
1. On the _New Repository_ page, enter the mandatory name for your repository. For example, _My Node.js package registry_.

    **Note:** Since repository names cannot contain spaces or punctuation, hyphens will automatically be specified when the space key is pressed, and punctuation will not be entered.

1. Enter an optional _Description_ for the repository, which will appear under the name of the repository item on the _Repositories_ page. For example, _This is an example of a Node.js package registry_.
1. Select the required _Repo Type_ of _NodeJS (npm)_.
1. Select _Create Repository_.

    The new Node.js package repository's details page is displayed. Selecting _Packages_ in the global navigation opens the _Repositories_ page, where your new package repository will be listed.

## Clone the Node.js package example

To clone the Node.js package example:

1. Run the following command:

    ```bash
    git clone git@github.com:buildkite/nodejs-example-package.git
    ```

1. `cd` into the `nodejs-example-package` directory and run it from the `main` branch (to test that it works):

    ```bash
    npm run main
    ```



## Next steps



Learn more about how to work with Buildkite Packages in [Manage registries](/docs/packages/manage-registries).
