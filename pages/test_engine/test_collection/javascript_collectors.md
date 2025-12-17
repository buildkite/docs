# JavaScript collectors

To use Test Engine with your JavaScript (npm) projects, use the :github: [`test-collector-javascript`](https://github.com/buildkite/test-collector-javascript) package with a supported test framework. Test Engine supports the following test frameworks:

- [Jest](https://jestjs.io/)
- [Jasmine](https://jasmine.github.io/)
- [Mocha](https://mochajs.org/)
- [Cypress](https://www.cypress.io)
- [Playwright](https://playwright.dev)
- [Vitest](https://vitest.dev/)

You can also upload test results by importing [JSON](/docs/test-engine/test-collection/importing-json) or [JUnit XML](/docs/test-engine/test-collection/importing-junit-xml).


## Add the test collector package

Whichever test framework you use, you first need to add and authenticate the [`buildkite-test-collector`](https://www.npmjs.com/package/buildkite-test-collector).

To add the test collector package:

1. In your CI environment, set the `BUILDKITE_ANALYTICS_TOKEN` environment variable to your Test Engine API token.
   To learn how to set environment variables securely in Pipelines, see [Managing pipeline secrets](/docs/pipelines/security/secrets/managing).

1. On the command line, create a new branch by running:

    ```
    git checkout -b install-buildkite-test-engine
    ```

1. Install [`buildkite-test-collector`](https://www.npmjs.com/package/buildkite-test-collector) using your package manager.

    For npm, run:

    ```shell
    npm install --save-dev buildkite-test-collector
    ```

    For yarn, run:

    ```shell
    yarn add --dev buildkite-test-collector
    ```

## Configure the test framework

With the test collector installed, you need to configure it in the test framework.

### Jest

If you're already using Jest, you can add `buildkite-test-collector/jest/reporter` to the list of reporters to collect test results into your Test Engine dashboard.

To configure Jest:

1. Make sure Jest runs with access to [CI environment variables](/docs/test-engine/test-collection/ci-environments).
1. Add `"buildkite-test-collector/jest/reporter"` to [Jest's `reporters` configuration array](https://jestjs.io/docs/configuration#reporters-arraymodulename--modulename-options) (typically found in `jest.config.js`, `jest.config.js`, or `package.json`):

    ```json
    {
        "reporters": ["default", "buildkite-test-collector/jest/reporter"],
        "testLocationInResults": true,
    }
    ```
    **Note:** The `"testLocationInResults": true` setting enables column and line capture for Test Engine.

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

1. Make sure Cypress runs with access to [CI environment variables](/docs/test-engine/test-collection/ci-environments).
1. Update your [Cypress configuration](https://docs.cypress.io/guides/references/configuration).

    ```js
    // cypress.config.js

    // Send results to Test Engine
    reporter: "buildkite-test-collector/cypress/reporter",
    ```

    **Note:** To pass in the API token using a custom environment variable, add the `reporterOptions` option to your Cypress configuration:

    ```js
    // cypress.config.js

    // Send results to Test Engine
    reporterOptions: {
      token_name: "CUSTOM_ENV_VAR_NAME"
    }
    ```

### Playwright

If you're already using Playwright, you can add `buildkite-test-collector/playwright/reporter` to the list of reporters to collect test results into your Test Engine dashboard.

To configure Playwright:

1. Make sure Playwright runs with access to [CI environment variables](/docs/test-engine/test-collection/ci-environments).
1. Add `"buildkite-test-collector/playwright/reporter"` to [Playwright's `reporter` configuration array](https://playwright.dev/docs/test-reporters#multiple-reporters) (typically found in `playwright.config.js`):

    ```js
    // playwright.config.js
    {
      "reporter": [
        ["line"],
        ["buildkite-test-collector/playwright/reporter"]
      ]
    }
    ```

### Vitest

If you are already using Vitest, you can add `buildkite-test-collector/vitest/reporter` to the list of reporters to collect test results in your Test Engine dashboard.

To configure Vitest:

Update your [Vitest configuration](https://vitest.dev/config/):

```js
// vitest.config.js OR vite.config.js OR vitest.workspace.js

test: {
  // Send results to Test Engine
   reporters: [
     'default',
     'buildkite-test-collector/vitest/reporter'
   ],
   // Enable column + line capture for Test Engine
   includeTaskLocation: true,
}
```

If you would like to pass in the API token using a custom environment variable, you can do so using the report options.

```js
// vitest.config.js OR vite.config.js OR vitest.workspace.js
test: {
   // Send results to Test Engine
   reporters: [
     'default',
     [
       "buildkite-test-collector/vitest/reporter",
       { token: process.env.CUSTOM_ENV_VAR },
     ],
   ],
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
    git commit -m "Install and set up Buildkite Test Engine"
    ```

1. Push the changes by running:

    ```shell
    git push
    ```

## View the results

After completing these steps, you'll see the analytics of test executions on all branches that include this code in the Test Engine dashboard.

If you don't see branch names, build numbers, or commit hashes in the Test Engine dashboard, see [CI environments](/docs/test-engine/test-collection/ci-environments) to learn more about exporting your environment.

## Upload custom tags for test executions

You can group test executions using custom tags to compare metrics across different dimensions, such as:

- Language versions
- Cloud providers
- Instance types
- Team ownership
- and more

### Upload-level tags

Tags configured on the collector will be included in each upload batch, and will be applied server-side to every execution therein. This is an efficient way to tag every execution with values that don't vary within one configuration, e.g. cloud environment details, language/framework versions. Upload-level tags may be overwritten by execution-level tags.

```js
// Jest -- jest.config.js
reporters: [
  'default',
  'buildkite-test-collector/jest/reporter'
  ['buildkite-test-collector/jest/reporter', {
    tags: { hello: "jest" }
  }]
],

// Cypress -- cypress.config.js
reporterOptions: {
  tags: { "hello": "cypress" },
},

// Mocha -- config.js
"buildkiteTestCollectorMochaReporterReporterOptions": {
  "tags": {
    "hello": "mocha"
  }
}

// Playwright -- playwright.config.js
reporter: [
  ['line'],
  ['buildkite-test-collector/playwright/reporter', {
    tags: { "hello": "playwright" }
  }]
],
```
## Troubleshooting missing test executions and --forceExit

Using the [`--forceExit`](https://jestjs.io/docs/cli#--forceexit) option when running Jest could result in missing test executions from Test Engine.

`--forceExit` could potentially terminate any ongoing processes that are attempting to send test executions to Buildkite.

We recommend using [`--detectOpenHandles`](https://jestjs.io/docs/cli#--detectopenhandles) to track down open handles which are preventing Jest from exiting cleanly.
