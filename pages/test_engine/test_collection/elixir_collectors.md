---
toc: false
---

# Elixir collectors

To use Test Engine with your Elixir projects use :github: [`test_collector_elixir`](https://github.com/buildkite/test_collector_elixir) with ExUnit.

You can also upload test results by importing [JSON](/docs/test-engine/test-collection/importing-json) or [JUnit XML](/docs/test-engine/test-collection/importing-junit-xml).

## ExUnit

[ExUnit](https://hexdocs.pm/ex_unit/) is a Elixir unit test library.

Before you start, make sure ExUnit runs with access to [CI environment variables](/docs/test-engine/test-collection/ci-environments).

1. Create a [test suite](/docs/test-engine/test-suites) and copy the API token that it gives you.

1. Add `buildkite_test_collector` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        {:buildkite_test_collector, "~> 0.3.1", only: [:test]}
      ]
    end
    ```

1. Set up your API token:

    In your `config/test.exs` (or other environment configuration as appropriate) add the Buildkite Test Engine API token. We suggest that you retrieve the token from the environment, and configure your CI environment accordingly (for example using secrets).

    ```elixir
    import Config


    config :buildkite_test_collector,
      api_key: System.get_env("BUILDKITE_ANALYTICS_TOKEN")
    ```

1. Add `BuildkiteTestCollectorFormatter` to your ExUnit configuration in `test/test_helper.exs`:

    ```elixir
    ExUnit.configure formatters: [BuildkiteTestCollector.Formatter, ExUnit.CLIFormatter]
    ExUnit.start
    ```

1. Run your tests like normal:

    Note that we attempt to detect the presence of several common CI environments. However if this fails you can set the `CI` environment variable to any value and it will work.

    ```sh
    $ mix test

    ...

    Finished in 0.01 seconds (0.003s on load, 0.004s on tests)
    3 tests, 0 failures

    Randomized with seed 12345
    ```

1. Verify that it works. If all is well, you should see the test run analytics on the Buildkite Test Engine dashboard.
