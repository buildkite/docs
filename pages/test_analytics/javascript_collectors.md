# JavaScript collectors

To use Test Analytics with your JavaScript (npm) projects use the :github: [`test-collector-javascript`](https://github.com/buildkite/test-collector-javascript) package with Jest.

You can also upload test results by importing [JSON](/docs/test-analytics/importing-json) or [JUnit XML](/docs/test-analytics/importing-junit-xml).

{:toc}

## Set up
Test Analytics ships with [Jest](https://jestjs.io/), [Jasmine](https://jasmine.github.io/) and [Mocha](https://mochajs.org/) test collectors.

1. In your CI environment, set the `BUILDKITE_ANALYTICS_TOKEN` environment variable [securely](/docs/pipelines/secrets) to your Buildkite Test Analytics API token.

1. Create a new branch:

```
$ git checkout -b install-buildkite-test-analytics
```

1. Install [`buildkite-test-collector`](https://www.npmjs.com/package/buildkite-test-collector) using your package manager.

**npm**:

```shell
$ npm install --dev buildkite-test-collector
```

**Yarn**:

```shell
$ yarn add --dev buildkite-test-collector
```

## Jest collector
If you're already using Jest, then you can add `buildkite-collector/jest/reporter` to your list of reporters to collect your test results into your Test Analytics dashboard.

Before you start, make sure Jest runs with access to [CI environment variables](/docs/test-analytics/ci-environments).

Add `"buildkite-test-collector/jest/reporter"` to [Jest's `reporters` configuration array](https://jestjs.io/docs/configuration#reporters-arraymodulename--modulename-options) (typically found in `jest.config.js`, `jest.config.js`, or `package.json`):

```json
{
    "reporters": ["default", "buildkite-test-collector/jest/reporter"]
}
```

## Jasmine collector
[Add the Buildkite reporter to Jasmine](https://jasmine.github.io/setup/nodejs.html#reporters):<br>

```js
// SpecHelper.js
var BuildkiteReporter = require("buildkite-test-collector/jasmine/reporter");
var buildkiteReporter = new BuildkiteReporter();

jasmine.getEnv().addReporter(buildkiteReporter);
```

If you would like to pass in the API token using a custom environment variable, you can do so using the report options.

```js
// SpecHelper.js
var buildkiteReporter = new BuildkiteReporter(undefined, {
    token: process.env.CUSTOM_ENV_VAR,
});
   ```

## Mocha collector

   [Install mocha-multi-reporters](https://github.com/stanleyhlng/mocha-multi-reporters) in your project:<br>

   ```
     npm install mocha-multi-reporters --save-dev
   ```

   and configure it to run your desired reporter and the Buildkite reporter

   ```js
     // config.json
     {
       "reporterEnabled": "spec, buildkite-test-collector/mocha/reporter"
     }
   ```

   Now update your test script to use the Buildkite reporter via mocha-multi-reporters:

   ```js
     // package.json
     "scripts": {
       "test": "mocha --reporter mocha-multi-reporters --reporter-options configFile=config.json"
     },
   ```

   If you would like to pass in the API token using a custom environment variable, you can do so using the report options.

   Since the reporter options are passed in as a json file, we ask you to put the environment variable name as a string value in the `config.json`, which will be retrieved using [dotenv](https://github.com/motdotla/dotenv) in the mocha reporter.

   ```js
     // config.json
     {
       "reporterEnabled": "spec, buildkite-test-collector/mocha/reporter",
       "buildkiteTestCollectorMochaReporterReporterOptions": {
         "token_name": "CUSTOM_ENV_VAR_NAME"
       }
     }
   ```

When your collector is installed, commit and push your changes:

```shell
$ git add .
$ git commit -m "Install and set up Buildkite Test Analytics"
$ git push
```

Once you're done, in your Test Analytics dashboard, you'll see analytics of test executions on all branches that include this code.

If you don't see branch names, build numbers, or commit hashes in the Test Analytics UI, then see [CI environments](/docs/test-analytics/ci-environments) to learn more about exporting your environment to Jest.

## Troubleshooting missing test executions and `--forceExit`

Using the [`--forceExit`](https://jestjs.io/docs/cli#--forceexit) option when running Jest could result in missing test executions from Test Analytics.

`--forceExit` could potentially terminate any ongoing processes that are attempting to send test executions to Buildkite.

We recommend using [`--detectOpenHandles`](https://jestjs.io/docs/cli#--detectopenhandles) to track down open handles which are preventing Jest from exiting cleanly.

