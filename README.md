# Buildkite Documentation [![Build status](https://badge.buildkite.com/b1b9e3ef9d893c087f5e5c0a2d04c258ba393bed2379273f63.svg?branch=main)](https://buildkite.com/buildkite/docs)

The source files for the [Buildkite Documentation](https://buildkite.com/docs).

To contribute, please send a pull request! :heart:

## Development

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

After completing the relevant 'Before you start' steps above:

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

## Updating `buildkite-agent` CLI docs

With the development dependencies installed you can update the CLI docs with the following:

```bash
# Set a custom PATH to select a locally built buildkite-agent
PATH="$HOME/Projects/buildkite/agent:$PATH" ./scripts/update-agent-help.sh
```

## Updating GraphQL API docs

GraphQL API documentation is generated from a local version of the [Buildkite GraphQL API schema](./data/graphql/schema.graphql).

This repository is kept up-to-date with production based on a [daily scheduled build](https://buildkite.com/buildkite/docs-graphql). The build fetches the latest GraphQL schema, generates the documentation, and publishes a pull request for review.

If you need to fetch the latest schema you can either:

- Manually trigger a build on [`buildkite/docs-graphql`](https://buildkite.com/buildkite/docs-graphql); or
- Run the following in your local environment:

```sh
# Fetch latest schema
API_ACCESS_TOKEN=xxx  bundle exec rake graphql:fetch_schema >| data/graphql/schema.graphql

# Generate docs based on latest schema
bundle exec rake graphql:generate
```

## Linting

We spell-check the docs (US English) and run a few automated checks for repeated words, common errors, and markdown and filename inconsistencies.

You can run most of these checks with `./scripts/vale.sh`.

If you've added a new valid word that showing up as a spelling error, add it to `./vale/styles/vocab.txt`.

## Style guides

Our documentation is based on the principles of common sense, clarity, and brevity.

The [writing](/styleguides/writing-style.md) and [Markdown syntax](/styleguides/markdown-syntax-style.md) style guides should provide you a general idea and an insight into our language and writing style, as well as the Markdown syntax we use (including custom formatting elements).

## Search index

**Note:** By default, search (through Algolia) references the production search index.

The search index is updated once a day by a scheduled build using the config in `config/algolia.json`.

To test changes to the indexing configuration:

1. Make sure you have an API key in `.env` like:

    ```env
    APPLICATION_ID=APP_ID
    API_KEY=YOUR_API_KEY
    ```

2. Run `bundle exec rake update_test_index`.

## Updating the navigation

The navigation is split into the following files:

- `nav_graphql.yml`: For the GraphQL API content.
- `nav.yml`: For everything else.

A combined navigation is generated when the application starts.

Otherwise, to update the general navigation:

1. Edit `nav.yml` with your changes.
1. Restart the application.

## Content keywords

We render content keywords in `data-content-keywords` in the `body` tag to highlight the focus keywords of each page with content authors.

This helps the content team to quickly inspect to see the types of content we're providing across different channels.

Keywords are added as [Frontmatter](https://rubygems.org/gems/front_matter_parser) meta data using the `keywords` key, e.g.:

```md
keywords: docs, tutorial, pipelines, 2fa
```

If no keywords are provided it falls back to comma-separated URL path segments.

## License

See [LICENSE.md](LICENSE.md) (MIT)
