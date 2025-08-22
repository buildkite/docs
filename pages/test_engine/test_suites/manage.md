# Manage test suites

This page provides details on how to manage test suites within your Buildkite organization.

Test Engine manages your development project's tests through a test suite.

## Create a test suite

New test suites can be created through the **Test Suites** page of the Buildkite interface.

To create a new test suite:

1. Select **Test Suites** in the global navigation to access the **Test Suites** page.
1. Select **New test suite**.
1. On the **Identify, track and fix problematic tests** page, enter an optional **Application name**. This is only a consideration if you have a large development project that consists of more than one test suite.
1. Enter a mandatory **Test suite name**, which, together with the **Application name** (if specified), will appear on the test suite on the **Test Suites** page.
1. Enter the **Default branch name**, which is the default branch that Test Engine shows trends for, and can be changed any time.
1. Specify an optional **Suite emoji**, using [emoji syntax](/docs/pipelines/emojis), along with an optional **Suite color** (as a hex code) for the emoji's background.
1. Select **Set up suite**.
1. If your Buildkite organization has the [teams feature](/docs/test-engine/permissions) enabled, select the relevant **Teams** to be granted access to this test suite, followed by **Continue**.

    The new test suite's **Complete test suite setup** page is displayed, requesting you to configure [test collection](/docs/test-engine/test-collection) within your development project.
