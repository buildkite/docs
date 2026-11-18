# JavaScript collectors

To use Buildkite Test Engine with your JavaScript (npm) projects, use the :github: [`test-collector-javascript`](https://github.com/buildkite/test-collector-javascript) package with a supported test framework. Buildkite Test Engine supports the following test frameworks:

- [Jest](https://jestjs.io/)
- [Jasmine](https://jasmine.github.io/)
- [Mocha](https://mochajs.org/)
- [Cypress](https://www.cypress.io)
- [Playwright](https://playwright.dev)
- [Vitest](https://vitest.dev/)

<%= render_markdown partial: 'pipelines/configure/tests/test_collection/tests_plugin_recommendation' %>

You can also upload test results by importing [JSON](/docs/pipelines/configure/tests/test-collection/importing-json) or [JUnit XML](/docs/pipelines/configure/tests/test-collection/importing-junit-xml).

## Tests Buildkite plugin example for Jest

The following step uses the [Tests Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/tests-buildkite-plugin/) to run a Jest suite through [bktec](/docs/pipelines/configure/tests/bktec/installing-and-using-the-client). The plugin downloads bktec, requests an OIDC token, ensures the test suite exists, and exports the environment variables that bktec expects, so the step's command only needs to invoke `bktec run`:

```yaml
steps:
  - label: "Jest"
    command: bktec run
    plugins:
      - tests#v1.0.0:
          test-runner: jest
          result-path: jest-results.json
    parallelism: 4
```

See the [Tests Buildkite plugin page](https://buildkite.com/resources/plugins/buildkite-plugins/tests-buildkite-plugin/) for the full plugin reference, including all supported options, running tests inside Docker, and dynamic parallelism with `bktec plan`.

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

1. Make sure Jest runs with access to [CI environment variables](/docs/pipelines/configure/tests/test-collection/ci-environments).
1. Add `"buildkite-test-collector/jest/reporter"` to [Jest's `reporters` configuration array](https://jestjs.io/docs/configuration#reporters-arraymodulename--modulename-options) (typically found in `jest.config.js`, `jest.config.js`, or `package.json`):

    ```json
    {
        "reporters": ["default", "buildkite-test-collector/jest/reporter"],
        "testLocationInResults": true,
    }
    ```
    **Note:** The `"testLocationInResults": true` setting enables column and line capture for Test Engine.

### Collecting Jest tests with OpenTelemetry

The JavaScript collector can send Jest results to Buildkite Test Engine as [OpenTelemetry spans](/docs/pipelines/configure/tests/test-collection/opentelemetry). Each test execution becomes a root span. Optional child spans show operations inside the test, such as HTTP requests and database queries.

Use Jest 29 or 30 with the default `jest-circus` runner. OpenTelemetry collection requires `buildkite-test-collector` version `1.13.0` or later. The setup below uses version `1.16.0`. OpenTelemetry collection is disabled by default.

1. [Create a test suite](/docs/pipelines/getting-started#add-a-test-suite-create-a-test-suite) if you do not have one. Configure [OIDC authentication](/docs/pipelines/configure/tests/test-collection/oidc), or store your suite API token securely as `BUILDKITE_ANALYTICS_TOKEN` in the environment that runs Jest.

1. Install the collector and its optional OpenTelemetry SDK 3.x dependencies. SDK 3 requires Node.js 22.15 or later and OpenTelemetry API 1.10 or later:

    ```bash
    npm install --save-dev buildkite-test-collector@1.16.0 \
      '@opentelemetry/api@^1.10' \
      '@opentelemetry/sdk-trace@^3' \
      '@opentelemetry/context-async-hooks@^3' \
      '@opentelemetry/exporter-trace-otlp-proto@~0.301.0'
    ```

    For older Node.js versions, use SDK 2.9 or later in the 2.x release line instead. These dependencies require Node.js 18.19 or later in the 18.x release line, or Node.js 20.6 or later:

    ```bash
    npm install --save-dev buildkite-test-collector@1.16.0 \
      '@opentelemetry/api@~1.9.0' \
      '@opentelemetry/sdk-trace@^2.9' \
      '@opentelemetry/context-async-hooks@^2' \
      '@opentelemetry/exporter-trace-otlp-proto@~0.223.0'
    ```

    **Note:** If upgrading from `@opentelemetry/sdk-trace-base`, replace that direct dependency with `@opentelemetry/sdk-trace` using one of the package sets above. Since collector 1.15.0, OpenTelemetry mode warns and uploads nothing without it. Collector configuration is unchanged.

1. Configure both the reporter and the runtime in `jest.config.js`. Replace an existing Buildkite reporter entry instead of adding a second one:

    ```javascript
    module.exports = {
      reporters: [
        'default',
        ['buildkite-test-collector/jest/reporter', { otelEnabled: true }],
      ],
      testEnvironment: 'node',
      runtime: 'buildkite-test-collector/jest/runtime',
      testLocationInResults: true,
    };
    ```

    Keep your existing `testEnvironment` setting, such as `node`, `jsdom`, or a custom environment. If you used an earlier beta, remove `testEnvironment: 'buildkite-test-collector/jest/environment'` and add the runtime shown above. No environment wrapper is needed.

    With Jest 29 and `jsdom` or `happy-dom`, SDK 3 package instrumentation is skipped with a warning. Test results, HTTP, and fetch spans still work.

1. Run Jest with its token and CI environment variables available:

    ```bash
    npx jest
    ```

1. Open the new run in your Buildkite Test Engine suite. For upload problems, check the collector's warnings and the suite's [**Uploads** page](/docs/pipelines/configure/tests/test-suites/upload-health).

See the [collector's OpenTelemetry guide](https://github.com/buildkite/bktest/blob/main/test-collector-javascript/docs/opentelemetry.md) for more details.

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

1. Update your test script to use the Buildkite reporter using mocha-multi-reporters:

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

1. Make sure Cypress runs with access to [CI environment variables](/docs/pipelines/configure/tests/test-collection/ci-environments).
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

1. Make sure Playwright runs with access to [CI environment variables](/docs/pipelines/configure/tests/test-collection/ci-environments).
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

### Collecting Playwright tests with OpenTelemetry

The JavaScript collector can send Playwright results to Buildkite Test Engine as OpenTelemetry spans. Each test attempt, including retries and skipped tests, becomes a root span. Playwright steps, hooks, fixtures, assertions, and actions become nested child spans.

OpenTelemetry collection requires `buildkite-test-collector` version `1.14.0` or later and is disabled by default. The setup below uses version `1.16.0`. Use Playwright 1.41.2 or later.

1. [Create a test suite](/docs/pipelines/getting-started#add-a-test-suite-create-a-test-suite) if you do not have one. Configure [OIDC authentication](/docs/pipelines/configure/tests/test-collection/oidc), or store your suite API token securely as `BUILDKITE_ANALYTICS_TOKEN` in the environment that runs Playwright.

1. Install the collector and its optional OpenTelemetry SDK 3.x dependencies. SDK 3 requires Node.js 22.15 or later and OpenTelemetry API 1.10 or later:

    ```bash
    npm install --save-dev buildkite-test-collector@1.16.0 \
      '@opentelemetry/api@^1.10' \
      '@opentelemetry/sdk-trace@^3' \
      '@opentelemetry/exporter-trace-otlp-proto@~0.301.0'
    ```

    For older Node.js versions, use SDK 2.9 or later in the 2.x release line instead. These dependencies require Node.js 18.19 or later in the 18.x release line, or Node.js 20.6 or later. Your Playwright version may require a newer Node.js version:

    ```bash
    npm install --save-dev buildkite-test-collector@1.16.0 \
      '@opentelemetry/api@~1.9.0' \
      '@opentelemetry/sdk-trace@^2.9' \
      '@opentelemetry/exporter-trace-otlp-proto@~0.223.0'
    ```

    **Note:** If upgrading from `@opentelemetry/sdk-trace-base`, replace that direct dependency with `@opentelemetry/sdk-trace` using one of the package sets above. Since collector 1.15.0, OpenTelemetry mode warns and uploads nothing without it. Collector configuration is unchanged. Playwright does not need `@opentelemetry/context-async-hooks`.

1. Enable OpenTelemetry on the reporter in `playwright.config.js`. Replace an existing Buildkite reporter entry instead of adding a second one:

    ```javascript
    module.exports = {
      reporter: [
        ['line'],
        ['buildkite-test-collector/playwright/reporter', { otelEnabled: true }],
      ],
    };
    ```

    No fixture changes or custom runtime are needed. Collection happens in the reporter and does not capture automatic HTTP or database spans, manual spans inside workers, or browser application traces.

1. Run Playwright with its token and [CI environment variables](/docs/pipelines/configure/tests/test-collection/ci-environments) available:

    ```bash
    npx playwright test
    ```

1. Open the new run in your Buildkite Test Engine suite. For upload problems, check the collector's warnings and the suite's [**Uploads** page](/docs/pipelines/configure/tests/test-suites/upload-health).

Configuration or upload failures do not fall back to JSON uploads. To return to JSON reporting, disable `otelEnabled`.

See the [collector's OpenTelemetry guide](https://github.com/buildkite/bktest/blob/main/test-collector-javascript/docs/opentelemetry.md#playwright) for more details.

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

### Collecting Vitest tests with OpenTelemetry

The JavaScript collector can send Vitest results to Buildkite Test Engine as OpenTelemetry spans. Each test becomes a root span, with hook phases, HTTP requests, package calls such as database queries, and custom instrumentation recorded as child spans.

OpenTelemetry collection requires `buildkite-test-collector` version `1.14.0` or later and is disabled by default. The setup below uses version `1.16.0`, which adds package instrumentation. Use Vitest 4.0.11 or later to collect child spans. Vitest 5 requires Node.js 22.12 or later.

1. [Create a test suite](/docs/pipelines/getting-started#add-a-test-suite-create-a-test-suite) if you do not have one. Configure [OIDC authentication](/docs/pipelines/configure/tests/test-collection/oidc), or store your suite API token securely as `BUILDKITE_ANALYTICS_TOKEN` in the environment that runs Vitest.

1. Install the collector and its optional OpenTelemetry SDK 3.x dependencies. SDK 3 requires Node.js 22.15 or later and OpenTelemetry API 1.10 or later, including with Vitest 4:

    ```bash
    npm install --save-dev buildkite-test-collector@1.16.0 \
      '@opentelemetry/api@^1.10' \
      '@opentelemetry/sdk-trace@^3' \
      '@opentelemetry/context-async-hooks@^3' \
      '@opentelemetry/exporter-trace-otlp-proto@~0.301.0'
    ```

    For older Node.js versions, use SDK 2.9 or later in the 2.x release line instead. These dependencies require Node.js 18.19 or later in the 18.x release line, or Node.js 20.6 or later. Your Vitest version may require a newer Node.js version:

    ```bash
    npm install --save-dev buildkite-test-collector@1.16.0 \
      '@opentelemetry/api@~1.9.0' \
      '@opentelemetry/sdk-trace@^2.9' \
      '@opentelemetry/context-async-hooks@^2' \
      '@opentelemetry/exporter-trace-otlp-proto@~0.223.0'
    ```

    **Note:** If upgrading from `@opentelemetry/sdk-trace-base`, replace that direct dependency with `@opentelemetry/sdk-trace` using one of the package sets above. Since collector 1.15.0, OpenTelemetry mode warns and uploads nothing without it. Collector configuration is unchanged.

1. Enable the reporter and native tracing in `vitest.config.js`. Replace an existing Buildkite reporter entry instead of adding a second one:

    ```javascript
    import { createRequire } from 'node:module';
    import { defineConfig } from 'vitest/config';

    const require = createRequire(import.meta.url);

    export default defineConfig({
      test: {
        reporters: [
          'default',
          ['buildkite-test-collector/vitest/reporter', { otelEnabled: true }],
        ],
        includeTaskLocation: true,
        experimental: {
          openTelemetry: {
            enabled: true,
            sdkPath: require.resolve('buildkite-test-collector/vitest/otel.js'),
          },
        },
      },
    });
    ```

    `require.resolve` supplies the filesystem path Vitest needs, including with pnpm and Yarn. For a CommonJS configuration, omit `createRequire` and use `require.resolve` directly. For multiple projects, configure tracing in the root configuration. When using Yarn without a `node_modules` directory, declare the dependencies in the root workspace.

1. To capture HTTP and fetch calls with SDK 3, install:

    ```bash
    npm install --save-dev \
      '@opentelemetry/instrumentation-http@^0.301.0' \
      '@opentelemetry/instrumentation-undici@^0.35.0'
    ```

    For SDK 2, use these versions instead:

    ```bash
    npm install --save-dev \
      '@opentelemetry/instrumentation-http@^0.223.0' \
      '@opentelemetry/instrumentation-undici@^0.33.0'
    ```

    For package instrumentation, including Express, GraphQL, PostgreSQL (`pg`), and Redis, install `@opentelemetry/auto-instrumentations-node@0.83.1` with SDK 3, or `@opentelemetry/auto-instrumentations-node@~0.81.0` with SDK 2. Declare instrumentation dependencies in the project's `package.json` or a parent workspace's `package.json`. Use `OTEL_NODE_ENABLED_INSTRUMENTATIONS` and `OTEL_NODE_DISABLED_INSTRUMENTATIONS` to select instrumentation.

    Package spans depend on module loading. CommonJS `require()` records spans for the tested packages. ES module and TypeScript imports work for packages such as `pg` and `redis`, but `express` and `ioredis` need `require()` (using `createRequire` in ES modules). GraphQL imports need a resolver that selects its CommonJS build for both `graphql` and its subpaths. Packages inlined with `server.deps.inline` can lose package spans without a warning. When using Yarn without a `node_modules` directory, package tracing is best-effort. See the [guide's package instrumentation section](https://github.com/buildkite/bktest/blob/main/test-collector-javascript/docs/opentelemetry.md#vitest-package-instrumentation) for the resolver and other limitations.

1. Run Vitest with its token and [CI environment variables](/docs/pipelines/configure/tests/test-collection/ci-environments) available:

    ```bash
    npx vitest run
    ```

    Do not pass `--reporter` flags, which override the reporters in the configuration. Watch mode is not supported.

1. Open the new run in your Buildkite Test Engine suite. For upload problems, check the collector's warnings and the suite's [**Uploads** page](/docs/pipelines/configure/tests/test-suites/upload-health).

Retries share one execution per test, with each attempt's phases and child spans underneath. Browser mode, VM pools (`vmThreads` and `vmForks`), and Vitest 3 send test spans only. Use `threads` or `forks` to collect child spans. A custom SDK or missing native tracing configuration also limits collection to test spans. Vitest 1 and 2 do not upload results in OpenTelemetry mode. Configuration or upload failures do not fall back to JSON uploads. To return to JSON reporting, disable `otelEnabled`.

See the [collector's OpenTelemetry guide](https://github.com/buildkite/bktest/blob/main/test-collector-javascript/docs/opentelemetry.md#vitest) for more details, including configuration for bktec.

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

If you don't see branch names, build numbers, or commit hashes in the Test Engine dashboard, see [CI environments](/docs/pipelines/configure/tests/test-collection/ci-environments) to learn more about exporting your environment.

## Upload custom tags for test executions

You can group test executions using custom tags to compare metrics across different dimensions, such as:

- Language versions
- Cloud providers
- Instance types
- Team ownership
- and more

### Upload-level tags

Tags configured on the collector will be included in each upload batch, and will be applied server-side to every execution therein. This is an efficient way to tag every execution with values that don't vary within one configuration, for example, cloud environment details, language/framework versions. Upload-level tags may be overwritten by execution-level tags.

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
