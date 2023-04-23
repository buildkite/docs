# Buildkite Documentation [![Build status](https://badge.buildkite.com/b1b9e3ef9d893c087f5e5c0a2d04c258ba393bed2379273f63.svg?branch=main)](https://buildkite.com/buildkite/docs)

The source files for the [Buildkite Documentation](https://buildkite.com/docs).

To contribute, send a pull request! :heart:

## Development

### Before you start

For containerized development, you need Docker and Docker Compose.
Most desktop installations of Docker include Docker Compose by default.
On some platforms, you may need to prefix `docker` commands with `sudo` or add your user to the `docker` group.

For non-containerized development, you need Ruby.
See [`.ruby-version`](.ruby-version) for the current required version
or use [`rbenv`](https://github.com/rbenv/rbenv) to automatically select the correct version of Ruby

### Run the development server

1. Get the source. Run:

   ```bash
   git clone git@github.com:buildkite/docs.git
   cd docs
   git submodule update --init
   ```

2. Build and run the server.

   For non-containerized development, run:

   ```bash
   # Install the dependencies
   bundle

   # Start the app
   foreman start
   ```

   Or with Docker, run:

   ```bash
   # Start the app on http://localhost:3000/
   docker-compose up --build
   ```

Open `http://localhost:3000` to preview the docs site.
After modifying a page, refresh to see your changes.

**Note:** By default, search (through Algolia) does not work in development.

## Updating buildkite-agent CLI Docs

With the development dependencies installed you can update the CLI docs using
`scripts/update-agent-help.sh`:

```bash
# Set a custom PATH to select a locally built buildkite-agent
PATH="$HOME/Projects/buildkite/agent:$PATH" ./scripts/update-agent-help.sh
```

## Linting

We spell-check the docs (American English) and run a few automated checks for repeated words, common errors, and markdown and filename inconsistencies.

You can run most of these checks with `./scripts/vale.sh`.

If you've added a new valid word that showing up as a spelling error, add it to `vale/vocab.txt`.

## Style guide

Our documentation is based on the principles of common sense, clarity, and brevity.

The [style guide](/styleguide/STYLE.md) should provide you a general idea and an insight into using custom formatting elements.

## Search index

The search index is updated once a day by a scheduled build using the config in `config/algolia.json`.

To test changes to the indexing configuration:

1. Make sure you have an API key in `.env` like:

    ```env
    APPLICATION_ID=APP_ID
    API_KEY=YOUR_API_KEY
    ```

2. Run `bundle exec rake update_test_index`.

## License

See [LICENSE.md](LICENSE.md) (MIT)
