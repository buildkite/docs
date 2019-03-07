# Buildkite Documentation

The source files for the [Buildkite Documentation](https://buildkite.com/docs).

To contribute simply send a pull request! :heart:

## Development

If you have Ruby installed:

```bash
# Install the dependencies
bundle
# Start the app on http://localhost:3000/
bin/rails server
```

Or if you have Docker installed:

```bash
# Run the specs
docker-compose run app rspec
# Start the app on http://localhost:3000/
docker-compose run --service-ports app
```

## License

See [LICENSE.md](LICENSE.md) (MIT)
