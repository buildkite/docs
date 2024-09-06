# Buildkite Documentation [![Build status](https://badge.buildkite.com/b1b9e3ef9d893c087f5e5c0a2d04c258ba393bed2379273f63.svg?branch=main)](https://buildkite.com/buildkite/docs)

The source files for the [Buildkite Documentation](https://buildkite.com/docs), aka the Buildkite Docs, or just docs.

To contribute, please send a pull request! :heart:

## Local docs development environment

### Before you start

There are two ways to develop and contribute to the Buildkite Documentation—non-containerized and containerized.

#### Non-containerized development

You will need both Ruby and Yarn.

See [`.ruby-version`](.ruby-version) for the current required version. Use/install [rbenv](https://github.com/rbenv/rbenv) to install the correct version of Ruby.

Ensure you have installed [Yarn](https://classic.yarnpkg.com/en/) too. If you use macOS, [you can do this conveniently with Homebrew](https://formulae.brew.sh/formula/yarn).

#### Containerized development

You will need [Docker](https://www.docker.com/) and Docker Compose.
Most desktop installations of Docker include Docker Compose by default.
On some platforms (for example, Linux-based ones), you may need to prefix `docker` commands with `sudo` or add your user to the `docker` group.

#### Get the Buildkite Docs source

Clone the Buildkite Docs source locally. To do so, run these commands:

```bash
git clone git@github.com:buildkite/docs.git

cd docs

git submodule update --init
```

### Run the development server

After completing all the relevant [Before you start](#before-you-start) steps above:

1. Build and run your local Buildkite Docs development server environment.

   For non-containerized development, run the following:

   ```bash
   # Check that you have Xcode Command Line Tools installed - required to build dependencies
   xcode-select -p

   # If not, install them
   xcode-select --install

   # Install dependencies
   bin/setup

   # Start the app
   foreman start
   ```

   **Note:** After stopping the non-containerized server, simply run `foreman start` to re-start the server again. If, however, the `foreman start` command fails to run successfully, try re-running the `bin/setup` command again to update any dependencies before running `foreman start` again.

   For containerized development, run the following:

   ```bash
   # Start the app on http://localhost:3000/
   docker-compose up --build
   ```

1. Open `http://localhost:3000` to preview the docs site.

1. After saving your modifications to a page, refresh the relevant page on this site to see your changes.

> [!NOTE]
> If you ever make more significant changes than just page updates (for example, adding a new page), you may need to stop and restart the Buildkite Docs development server to see these changes.

Learn how to contribute to the Buildkite Docs in the [CONTRIBUTING guide](./CONTRIBUTING.md).

## Contributing to the docs and style guides

The Buildkite Docs is based on the principles of common sense, clarity, and brevity.

Refer to the:

- [Contributing to the Buildkite Docs](CONTRIBUTING.md) guide for details on how to start making a contribution in a new pull request.

- [Writing](/styleguides/writing-style.md) and [Markdown syntax](/styleguides/markdown-syntax-style.md) style guides, which should provide a general idea and an insight into the language and writing style used throughout the Buildkite Docs, as well as the Markdown syntax used (including custom formatting elements).

## License

See [LICENSE.md](LICENSE.md) (MIT)
