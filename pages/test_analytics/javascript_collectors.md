# JavaScript collectors

To use Test Analytics with your JavaScript (npm) projects, use the :github: [`test-collector-javascript`](https://github.com/buildkite/test-collector-javascript) package with a supported test framework. Test Analytics supports the following test frameworks:

- [Jest](https://jestjs.io/)
- [Jasmine](https://jasmine.github.io/)
- [Mocha](https://mochajs.org/)
- [Cypress](https://www.cypress.io)
- [Playwright](https://playwright.dev)

You can also upload test results by importing [JSON](/docs/test-analytics/importing-json) or [JUnit XML](/docs/test-analytics/importing-junit-xml).


## Add the test collector package

Whichever test framework you use, you first need to add and authenticate the [`buildkite-test-collector`](https://www.npmjs.com/package/buildkite-test-collector).

To add the test collector package:

1. In your CI environment, set the `BUILDKITE_ANALYTICS_TOKEN` environment variable to your Test Analytics API token.
   To learn how to set environment variables securely in Pipelines, see [Managing pipeline secrets](/docs/pipelines/security/secrets/managing).

1. On the command line, create a new branch by running:

    ```
    git checkout -b install-buildkite-test-analytics
    ```

1. Install [`buildkite-test-collector`](https://www.npmjs.com/package/buildkite-test-collector) using your package manager.

    For npm, run:

    ```shell
    npm install --dev buildkite-test-collector
    ```

    For yarn, run:

    ```shell
    yarn add --dev buildkite-test-collector
    ```

## Configure the test framework

With the test collector installed, you need to configure it in the test framework.

### Jest

If you're already using Jest, you can add `buildkite-test-collector/jest/reporter` to the list of reporters to collect test results into your Test Analytics dashboard.

To configure Jest:

1. Make sure Jest runs with access to [CI environment variables](/docs/test-analytics/ci-environments).
1. Add `"buildkite-test-collector/jest/reporter"` to [Jest's `reporters` configuration array](https://jestjs.io/docs/configuration#reporters-arraymodulename--modulename-options) (typically found in `jest.config.js`, `jest.config.js`, or `package.json`):

    ```json
    {
        "reporters": ["default", "buildkite-test-collector/jest/reporter"],
        "testLocationInResults": true,
    }
    ```
    **Note:** The `"testLocationInResults": true` setting enables column and line capture for Test Analytics.

### Jasmine

To configure Jasmine:

1. Follow the [Jasmine docs](https://jasmine.github.io/setup/nodejs.html#reporters) to add the Buildkite reporter. For example:

    ```js
    // SpecHelper.js
    var BuildkiteReporter = require("buildkite-test-collector/jasmine/reporter");
    var buildkiteReporter = new BuildkiteReporter();

    jasmine.getEnv().addReporter(buildkiteReporter);
    ```

1. (Optional) To pass in the API token using a custom environment variable, use the following report options:

    ```js
    // SpecHelper.js
    var buildkiteReporter = new BuildkiteReporter(undefined, {
        token: process.env.CUSTOM_ENV_VAR,
    });
    ```

### Mocha

To configure Mocha:

1. Install the [mocha-multi-reporters](https://github.com/stanleyhlng/mocha-multi-reporters) in your project by running:

    ```
    npm install mocha-multi-reporters --save-dev
    ```

1. Configure it to run your desired reporter and the Buildkite reporter:

    ```js
    // config.json
    {
      "reporterEnabled": "spec, buildkite-test-collector/mocha/reporter"
    }
    ```

1. Update your test script to use the Buildkite reporter via mocha-multi-reporters:

    ```js
    // package.json
    "scripts": {
      "test": "mocha --reporter mocha-multi-reporters --reporter-options configFile=config.json"
    },
    ```

1. (Optional) To pass in the API token using a custom environment variable, use the report options. Since the reporter options are passed in as a JSON file, we recommend you put the environment variable name as a string value in the `config.json`, which is retrieved using [dotenv](https://github.com/motdotla/dotenv) in the mocha reporter.

    ```js
    // config.json
    {
      "reporterEnabled": "spec, buildkite-test-collector/mocha/reporter",
      "buildkiteTestCollectorMochaReporterReporterOptions": {
        "token_name": "CUSTOM_ENV_VAR_NAME"
      }
    }
    ```

### Cypress
To configure Cypress:

1. Make sure Cypress runs with access to [CI environment variables](/docs/test-analytics/ci-environments).
1. Update your [Cypress configuration](https://docs.cypress.io/guides/references/configuration).

    ```js
    // cypress.config.js

    // Send results to Test Analytics
    reporter: "buildkite-test-collector/cypress/reporter",
    ```

    **Note:** To pass in the API token using a custom environment variable, add the `reporterOptions` option to your Cypress configuration:

    ```js
    // cypress.config.js

    // Send results to Test Analytics
    reporterOptions: {
      token_name: "CUSTOM_ENV_VAR_NAME"
    }
    ```

### Playwright

If you're already using Playwright, you can add `buildkite-test-collector/playright/reporter` to the list of reporters to collect test results into your Test Analytics dashboard.

To configure Playwright:

1. Make sure Playwright runs with access to [CI environment variables](/docs/test-analytics/ci-environments).
1. Add `"buildkite-test-collector/playwright/reporter"` to [Playwright's `reporters` configuration array](https://playwright.dev/docs/test-reporters#multiple-reporters) (typically found in `playwright.config.js`):

    ```js
    // playwright.config.js
    {
      "reporter": [
        ["line"],
        ["buildkite-test-collector/playwright/reporter"]
      ]
    }
    ```

## Save the changes

When your collector is installed, commit and push your changes:

1. Add the changes to the staging area by running:

    ```shell
    git add .
    ```

1. Commit the changes by running:

    ```shell
    git commit -m "Install and set up Buildkite Test Analytics"
    ```

1. Push the changes by running:

    ```shell
    git push
    ```

## View the results

After completing these steps, you'll see the analytics of test executions on all branches that include this code in the Test Analytics dashboard.

If you don't see branch names, build numbers, or commit hashes in the Test Analytics dashboard, see [CI environments](/docs/test-analytics/ci-environments) to learn more about exporting your environment.

## Troubleshooting missing test executions and --forceExit

Using the [`--forceExit`](https://jestjs.io/docs/cli#--forceexit) option when running Jest could result in missing test executions from Test Analytics.

`--forceExit` could potentially terminate any ongoing processes that are attempting to send test executions to Buildkite.

We recommend using [`--detectOpenHandles`](https://jestjs.io/docs/cli#--detectopenhandles) to track down open handles which are preventing Jest from exiting cleanly.
