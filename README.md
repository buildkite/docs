# Buildkite Documentation [![Build status](https://badge.buildkite.com/b1b9e3ef9d893c087f5e5c0a2d04c258ba393bed2379273f63.svg?branch=main)](https://buildkite.com/buildkite/docs)

The source files for the [Buildkite Documentation](https://buildkite.com/docs).

To contribute, send a pull request! :heart:

## Development

```bash
git clone https://github.com/buildkite/docs.git
cd docs
git submodule update --init
```

If you have Ruby installed:

```bash
# Navigate into the docs directory
# Install the dependencies
bundle
# Run the specs
bundle exec rspec
# Start the app on http://localhost:3000/
bin/rails server
```

> **Note**: Check [.ruby-version](.ruby-version) for the current required version. You also need Node installed. The current LTS (long term support) version should be ok.

Or if you have Docker installed:

```bash
# Run the specs
docker-compose run app bundle exec rspec
# Start the app on http://localhost:3000/
docker-compose up --build
# To start it in production mode on http://localhost:3000/
docker-compose -f docker-compose.production.yml up --build
```

## Updating buildkite-agent CLI Docs

With the development dependencies installed you can update the CLI docs using
`script/update-agent-help.sh`:

```bash
# Set a custom PATH to select a locally built buildkite-agent
PATH="$HOME/Projects/buildkite/agent:$PATH" ./script/update-agent-help.sh
```

## Linting

We spell-check the docs (American English) and run a few automated checks for repeated words and other common errors.

If you've added a new valid word that showing up as a spelling error, add it to `vale/vocab.txt`.

## Search index

The search index is updated once a day by a scheduled build using the config in `config/algolia.json`.
To test changes to the indexing configuration (you'll need an API key) run `rake update_test_index`.


## License

See [LICENSE.md](LICENSE.md) (MIT)
