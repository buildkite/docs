<!--
TODO(tests-buildkite-plugin): The links to the Tests Buildkite plugin and the
Test Collector Buildkite plugin below are placeholders pending the release of
the new Tests Buildkite plugin (formal name pending). Update both URLs once
the plugins are published to https://buildkite.com/resources/plugins/.
-->

> 📘 Recommended setup
> The recommended way to get test data flowing into [Buildkite Test Engine](/docs/test-engine) is to add the [Tests Buildkite plugin](https://buildkite.com/resources/plugins/tests-buildkite-plugin). This is the golden path for new test suites: it works with every runner that [bktec](/docs/pipelines/configure/tests/bktec/installing-and-using-the-client) supports, and the entire setup is configuration-only — you can get a test suite running through changes to `pipeline.yml` alone, with no modifications to your application code.
> Use the language-specific test collector documented on this page when you want deeper framework integration — such as custom execution tags, span annotations, or richer per-framework data. Language-specific collectors still pair well with the Tests Buildkite plugin, but adding one requires changes to your application code.
