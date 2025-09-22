---
toc: false
---

# Swift collectors

To use Test Engine with your Swift projects use the :github: [`test-collector-swift`](https://github.com/buildkite/test-collector-swift) package with XCTest.

You can also upload test results by importing [JSON](/docs/test-engine/test-collection/importing-json) or [JUnit XML](/docs/test-engine/test-collection/importing-junit-xml).

## XCTest

[XCTest](https://developer.apple.com/documentation/xctest) is a test framework to write unit tests for your Xcode projects.

Before you start, make sure XCTest runs with access to [CI environment variables](/docs/test-engine/test-collection/ci-environments).

1. [Create a test suite](/docs/test-engine) and copy the test suite API token.

1. [Securely](/docs/pipelines/security/secrets/managing) set the `BUILDKITE_ANALYTICS_TOKEN` secret on your CI to the API token from the previous step.

    If you're testing an Xcode project, note that Xcode doesn't automatically pass environment variables to the test runner, so you need to add them manually.
    In your test scheme or test plan, go to the **Environment Variables** section and add the following key-value pair:

    ```yaml
    BUILDKITE_ANALYTICS_TOKEN: $(BUILDKITE_ANALYTICS_TOKEN)
     ```

1. In the `Package.swift` file, add `https://github.com/buildkite/test-collector-swift` to the dependencies and add `BuildkiteTestCollector` to any test target requiring analytics:

    ```swift
    let package = Package(
      name: "MyProject",
      dependencies: [
        .package(url: "https://github.com/buildkite/test-collector-swift", from: "0.3.0")
      ],
      targets: [
        .target(name: "MyProject"),
        .testTarget(
          name: "MyProjectTests",
          dependencies: [
            "MyProject",
            .product(name: "BuildkiteTestCollector", package: "test-collector-swift")
          ]
        )
      ]
    )
    ```

1. Commit and push your changes:

    ```bash
    git checkout -b add-buildkite-test-engine
    git commit -am "Add Buildkite Test Engine"
    git push origin add-buildkite-test-engine
    ```

Once you're done, in your Test Engine dashboard, you'll see analytics of test executions on all branches that include this code.

If you don't see branch names, build numbers, or commit hashes in Test Engine, then read [CI environments](/docs/test-engine/test-collection/ci-environments) to learn more about exporting your environment to the collector.

### Debugging

To enable debugging output, set the `BUILDKITE_ANALYTICS_DEBUG_ENABLED` environment variable to `true`.
