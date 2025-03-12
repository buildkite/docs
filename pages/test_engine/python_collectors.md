---
toc: false
---

# Python collectors

To use Test Engine with your Python projects use the [`buildkite-test-collector`](https://pypi.org/project/buildkite-test-collector/) package with pytest.

You can also upload test results by importing [JSON](/docs/test-engine/importing-json) or [JUnit XML](/docs/test-engine/importing-junit-xml).

## pytest collector

pytest is a testing framework for Python.
If you're already using pytest, then you can install `buildkite-test-collector` to collect test results into your Test Engine dashboard.

Before you start, make sure pytest runs with access to [CI environment variables](/docs/test-engine/ci-environments).

To get started with `buildkite-test-collector`:

1. In your CI environment, set the `BUILDKITE_ANALYTICS_TOKEN` environment variable [securely](/docs/pipelines/security/secrets/managing) to your Buildkite Test Engine API token.

1. Add `buildkite-test-collector` to your list of dependencies. Some examples:

    <ul>
      <li>
          <p>If you're using a <code>requirements.txt</code> file, add
          <code>buildkite-test-collector</code> on a new line.</p>
      </li>
      <li>
          <p>
          If you're using a <code>setup.py</code> file, add
          <code>buildkite-test-collector</code> to the
          <code>extras_require</code> argument, like this:
          </p>
          <pre><code>extras_require={&quot;dev&quot;: [&quot;pytest&quot;, &quot;buildkite-test-collector&quot;]}</code></pre>
      </li>
      <li>
          <p>If you're using Pipenv, run
          <code>pipenv install --dev buildkite-test-collector</code>.</p>
      </li>
    </ul>
    <p>
    If you're using another tool, see your dependency management system's
    documentation for help.
    </p>

1. Commit and push your changes:

    ```shell
    $ git add .
    $ git commit -m "Install and set up Buildkite Test Engine"
    $ git push
    ```

Once you're done, in your Test Engine dashboard, you'll see analytics of test executions on all branches that include this code.

If you don't see branch names, build numbers, or commit hashes in Test Engine, then read [CI environments](/docs/test-engine/ci-environments) to learn more about exporting your environment to the collector.
