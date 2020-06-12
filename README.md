# Buildkite Documentation

The source files for the [Buildkite Documentation](https://buildkite.com/docs).

To contribute simply send a pull request! :heart:

## Development

```bash
git clone https://github.com/buildkite/docs.git
git submodule update --init
```

If you have Ruby installed:

```bash
# Install the dependencies
bundle
# Run the specs
bundle exec rspec
# Start the app on http://localhost:3000/
bin/rails server
```

Or if you have Docker installed:

```bash
# Run the specs
docker-compose run app bundle exec rspec
# Start the app on http://localhost:3000/
docker-compose up --build
# To start it in production mode on http://localhost:3000/
docker-compose -f docker-compose.production.yml up --build
```

## Linting

We spell-check the docs (American English) and run a few automated checks for repeated words and other common errors. 

If you've added a new valid word that showing up as a spelling error, add it to `vale/vocab.txt`.

## License

See [LICENSE.md](LICENSE.md) (MIT)
