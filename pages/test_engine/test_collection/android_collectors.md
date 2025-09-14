---
toc: false
---

# Android collectors

To use Test Engine with your Android projects use the :github: [`test-collector-android`](https://github.com/buildkite/test-collector-android) package.

You can also upload test results by importing [JSON](/docs/test-engine/test-collection/importing-json) or [JUnit XML](/docs/test-engine/test-collection/importing-junit-xml).

## Android

Before you start, make sure your tests run with access to [CI environment variables](/docs/test-engine/test-collection/ci-environments).

1. [Create a test suite](/docs/test-engine) and copy the test suite API token.

1. [Securely](/docs/pipelines/security/secrets/managing) set the `BUILDKITE_ANALYTICS_TOKEN` secret on your CI to the API token from the previous step.

    This will need to be on your CI server, if running the BuildKite collector via CI, or otherwise on your local machine.

1. **Unit Test Collector.** In your top-level build.gradle.kts file, add the following to your classpath:

    ```
    buildScript {
        ...
        dependencies {
            ...
            classpath("com.buildkite.test-collector-android:unit-test-collector-plugin:0.1.0")
        }
    }
    ```

    Then, in your app-level build.gradle.kts, add the following plugin:

    ```
    plugins {
        id("com.buildkite.test-collector-android.unit-test-collector-plugin")
    }
    ```

    That's it!

1. **Instrumented Test Collector.** In your app-level build.gradle.kts file,

    Add the following dependency:

    ```
    androidTestImplementation("com.buildkite.test-collector-android:instrumented-test-collector:0.1.0")
    ```

    ```
    android {
        ...

        defaultConfig {
            ...

            buildConfigField(
                "String",
                "BUILDKITE_ANALYTICS_TOKEN",
                "\"${System.getenv("BUILDKITE_ANALYTICS_TOKEN")}\""
            )
        }
    }
    ```

    Sync Gradle, and rebuild the project to ensure the `BuildConfig` is generated.

    Create the following class in your `androidTest` directory,
    i.e. `src/androidTest/java/com/myapp/MyTestCollector.kt`

    ```
    class MyTestCollector : InstrumentedTestCollector(
        apiToken = BuildConfig.BUILDKITE_ANALYTICS_TOKEN
    )
    ```

    Again, in your app-level build.gradle.kts file, instruct Gradle to use your test collector:

    ```
    testInstrumentationRunnerArguments += mapOf(
        "listener" to "com.mycompany.myapp.MyTestCollector" // Make sure to use the correct package name here
    )
    ```

    Note: This test collector uploads test data via the device under test. Make sure your Android
    device/emulator has network access.

1. Commit and push your changes:

    ```bash
    git checkout -b add-buildkite-test-engine
    git commit -am "Add Buildkite Test Engine"
    git push origin add-buildkite-test-engine
    ```

Once you're done, in your Test Engine dashboard, you'll see analytics of test executions on all branches that include this code.

If you don't see branch names, build numbers, or commit hashes in Test Engine, then read [CI Environments](/docs/test-engine/test-collection/ci-environments) to learn more about exporting your environment to the collector.

### Debugging

To enable debugging output, create and set `BUILDKITE_ANALYTICS_DEBUG_ENABLED` environment variable to `true` on your test environment (CI server or local machine).

For instrumented tests debugging, access the variable using `buildConfigField` and pass it through your `MyTestCollector` class. Refer the [example project](https://github.com/buildkite/test-collector-android/tree/main/example) for implementation.
