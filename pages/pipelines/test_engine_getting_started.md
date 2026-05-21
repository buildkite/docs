# Getting started with Test Engine

This tutorial walks you through the three steps to start using [Test Engine](/docs/pipelines/configure/tests), the testing layer of [Buildkite Pipelines](/docs/pipelines):

1. Create a [test suite](/docs/pipelines/configure/tests/test-suites) in Buildkite.
1. Configure a [test collector](/docs/pipelines/configure/tests/test-collection) in your development project so its test results flow into the suite.
1. Automate the test runner with Buildkite Pipelines so each build populates the suite.

## Before you start

To complete this tutorial, you'll need:

- A Buildkite account and a basic familiarity with [Buildkite Pipelines](/docs/pipelines). If you don't already have a Buildkite account and want to gain some familiarity with this product, run through the [Getting started with Pipelines](/docs/pipelines/getting-started) tutorial first.

    Otherwise, you can create a free personal Buildkite account from the <a href="<%= url_helpers.signup_path %>">sign-up page</a>.

- [Git](https://git-scm.com/downloads), to work with a locally cloned project you want to implement Test Engine test suites on.

## Create a test suite

To begin creating a new test suite:

1. Select **Test Suites** in the global navigation to access the **Test Suites** page.
1. Select **New test suite**.
1. On the **Identify, track and fix problematic tests** page, enter an optional **Application name**, for example, `My project`.
1. Enter a mandatory **Test suite name**, for example, `My project test suite`.
1. Enter the **Default branch name**, which is the default branch that Test Engine shows trends for, and can be changed any time, for example (and usually), `main`.
1. Enter an optional **Suite emoji**, using [emoji syntax](/docs/pipelines/emojis), for example, `\:test_tube\:` for a test tube emoji.
1. Enter an optional **Suite color**, using the `#RRGGBB` syntax. See the [HTML Color Codes](https://htmlcolorcodes.com/) page to help you choose a color.

    **Note:** At this point, you can select one of the buttons towards the end of this page which match your project's testing framework (or test runners) for instructions on how to set up [test collection](/docs/pipelines/configure/tests/test-collection) for your project. This opens up the relevant documentation page with detailed instructions on how to set up test collection for your test runners, which you'll be doing in the next section. Otherwise, if your project's testing framework is not listed, see [Collecting test data from other test runners](/docs/pipelines/configure/tests/test-collection/other-collectors) for details on how to implement test collection for other testing frameworks. Regardless, keep the relevant documentation page/s open.

1. Select **Set up suite**.
1. If your Buildkite organization has the [teams feature](/docs/platform/team-management/permissions) enabled, select the relevant **Teams** to be granted access to this test suite, followed by **Continue**.

    The new test suite's **Complete test suite setup** page is displayed, requesting you to [configure your test collector within your development project](#configure-your-project-with-its-test-collector).

## Configure your project with its test collector

Next, configure your project's test runners with its Buildkite test collector:

1. On the **Complete test suite setup** page, under **Set up an integrated test collector**, select the test collector option for your test runners.
1. Follow the instructions on the right of the page (along with the relevant documentation page you opened above for more detailed information) to implement the relevant test collection capabilities for your project.

    **Note:** When instructed to add the `BUILDKITE_ANALYTICS_TOKEN` to your CI environment, this is referring to the **Test Suite API Token** at the top of this **Complete test suite setup** page. You'll be using this in the last step of this section, as well as in the section on how to [Automate your test runner with Buildkite Pipelines](#automate-your-test-runner-with-buildkite-pipelines).

1. Add and commit your test collector changes to your project to a new branch. For example:

    ```bash
    git add .
    git commit -m "Install and set up test collector for Buildkite Test Engine"
    git push
    ```

1. At this point, you can now run your project's test runner at the command line, by passing in `BUILDKITE_ANALYTICS_TOKEN=<your-test-suites-api-token-value>` as an environment variable to the test runner command. Once the test runner has completed running, check your test suite page to see the results collected by your Test Engine test suite!

## Automate your test runner with Buildkite Pipelines

You can automate your test suite by automating builds of your project in Buildkite Pipelines. To do this:

1. Follow the [Create your own pipeline](/docs/pipelines/create-your-own) instructions to create a Buildkite pipeline that at least builds your project and runs its test runners.

1. Copy the value of your **Test Suite API Token** (which you can later retrieve through your test suite's **Settings** > **Suite token** page) and configure it as a [Buildkite secret](/docs/pipelines/security/secrets/buildkite-secrets). You can create this secret with a name like `MY_PROJECT_TEST_SUITE_TOKEN`, and reference it in a pipeline using syntax like:

    ```yaml
    steps:
      - label: "Run tests"
        command:
          - test-runner-execution-command
          # Assumes your agent is running the required resources for this.
        secrets:
          BUILDKITE_ANALYTICS_TOKEN: MY_PROJECT_TEST_SUITE_TOKEN
    ```

    Learn more about how to create a Buildkite secret and use it in a Buildkite pipeline in [Create a secret](/docs/pipelines/security/secrets/buildkite-secrets#create-a-secret) and [Use a Buildkite secret in a job](/docs/pipelines/security/secrets/buildkite-secrets#use-a-buildkite-secret-in-a-job), respectively.

## Next steps

That's it! You've created a test suite, configured your project with a test collector, sent test data to the suite, and automated the process in Buildkite Pipelines. 🎉

From here:

- Browse the [Test Engine overview](/docs/pipelines/configure/tests) for the full set of features available on your suite, including [workflows](/docs/pipelines/configure/tests/workflows) for flaky test detection and [bktec](/docs/pipelines/speed-up-builds-with-bktec) for test splitting.
- Review the [CI environment variables](/docs/pipelines/configure/tests/test-collection/ci-environments) that collectors auto-detect when running under CI/CD.
- Give AI coding agents the context they need to work with Buildkite in [Getting started with coding agents](/docs/pipelines/getting-started-with-coding-agents).
