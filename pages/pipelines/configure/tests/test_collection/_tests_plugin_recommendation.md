<!--
TODO(tests-buildkite-plugin): The links to the Tests Buildkite plugin and the
Test Collector Buildkite plugin below are placeholders pending the release of
the new Tests Buildkite plugin (formal name pending). Update both URLs once
the plugins are published to https://buildkite.com/resources/plugins/.
-->

> 📘 Recommended setup
> The fastest way to get test data flowing into [Buildkite Test Engine](/docs/test-engine) is to add the [Tests Buildkite plugin](https://buildkite.com/resources/plugins/tests-buildkite-plugin) together with the [Test Collector Buildkite plugin](https://buildkite.com/resources/plugins/test-collector-buildkite-plugin) to your pipeline. That path is configuration-only—you can get a test suite running through changes to `pipeline.yml` alone, with no modifications to your application code.
>
> Use the language-specific test collector documented on this page when you want deeper framework integration—such as custom execution tags, span annotations, or richer per-framework data. Adding a language-specific collector requires changes to your application code.
