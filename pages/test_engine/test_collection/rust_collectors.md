---
toc: false
---

# Rust collector

To use Test Engine with your [Rust](https://www.rust-lang.org/) projects use the :github: [`test-collector-rust`](https://github.com/buildkite/test-collector-rust) package with `cargo test`.

You can also upload test results by importing [JSON](/docs/test-engine/test-collection/importing-json) or [JUnit XML](/docs/test-engine/test-collection/importing-junit-xml).

Before you start, make sure Rust runs with access to [CI environment variables](/docs/test-engine/test-collection/ci-environments).

1. Create a [test suite](/docs/test-engine/test-suites) and copy the API token that it gives you.

1. Install the `buildkite-test-collector` crate:

    ```sh
    $ cargo install buildkite-test-collector
    # or
    $ cargo install --git https://github.com/buildkite/test-collector-rust buildkite-test-collector
    ```

1. Configure your environment:

    Set the `BUILDKITE_ANALYTICS_TOKEN` environment variable to contain the token provided by the analytics project settings.

    We try and detect several common CI environments based in the environment variables which are present. If this detection fails then the application will crash with an error. To force the use of a "generic CI environment" set the `CI` environment variable to any non-empty value.

1. Change your test output to JSON format:

    In your CI environment you will need to change your output format to `JSON` and add `--report-time` to include execution times in the output. Unfortunately, these are currently unstable options for Rust, so some extra command line options are needed. Once you have the JSON output you can pipe it through the `buildkite-test-collector` binary - the input JSON is echoed back to STDOUT so that you can still operate upon it if needed.

    ```sh
    $ cargo test -- -Z unstable-options --format json --report-time | buildkite-test-collector
    ```

1. Confirm correct operation. Verify that the run is visible in the Buildkite Test Engine dashboard.
