---
toc: false
---

# Python collectors

To use Buildkite Test Engine with your Python projects, use the [`buildkite-test-collector`](https://pypi.org/project/buildkite-test-collector/) package with pytest.

<%= render_markdown partial: 'pipelines/configure/tests/test_collection/tests_plugin_recommendation' %>

You can also upload test results by importing [JSON](/docs/pipelines/configure/tests/test-collection/importing-json) or [JUnit XML](/docs/pipelines/configure/tests/test-collection/importing-junit-xml).

## Tests Buildkite plugin example for pytest

The following step uses the [Tests Buildkite plugin](https://github.com/buildkite-plugins/tests-buildkite-plugin) to run a pytest suite through [bktec](/docs/pipelines/configure/tests/bktec/installing-and-using-the-client). The plugin downloads bktec, requests an OIDC token, ensures the test suite exists, and exports the environment variables that bktec expects, so the step's command only needs to invoke `bktec run`:

```yaml
steps:
  - label: "pytest"
    command: bktec run
    plugins:
      - tests#v1.0.0:
          test-runner: pytest
    parallelism: 4
```

See the [Tests Buildkite plugin page](https://github.com/buildkite-plugins/tests-buildkite-plugin) for the full plugin reference, including all supported options and dynamic parallelism with `bktec plan`.

## pytest collector

pytest is a testing framework for Python.
If you're already using pytest, then you can install `buildkite-test-collector` to collect test results into your Test Engine dashboard.

Before you start, make sure pytest runs with access to [CI environment variables](/docs/pipelines/configure/tests/test-collection/ci-environments).

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

If you don't see branch names, build numbers, or commit hashes in Test Engine, then read [CI environments](/docs/pipelines/configure/tests/test-collection/ci-environments) to learn more about exporting your environment to the collector.

### Upload custom tags for test executions

You can group test executions using custom tags to compare metrics across different dimensions, such as:

- Language versions
- Cloud providers
- Instance types
- Team ownership
- and more

We offer a tagging solution based on [pytest custom markers](https://docs.pytest.org/en/stable/example/markers.html).

#### Upload-level tags

In your `conftest.py` file, you can use `pytest` global hook to tag all your test executions in a centralized way.

```python
import pytest
import sys

def pytest_itemcollected(item):
  # add execution tag to all tests
  item.add_marker(pytest.mark.execution_tag("test.framework.name", "pytest"))
  item.add_marker(pytest.mark.execution_tag("test.framework.version", pytest.__version__))
  item.add_marker(pytest.mark.execution_tag("cloud.provider", "aws"))
  item.add_marker(pytest.mark.execution_tag("language.version", sys.version))
```

#### Execution-level tags

For more granular control, you can programmatically or statically add tags to target individual tests.

To do it statically, targeting a single test or module:

```python
import pytest

 @pytest.mark.execution_tag("team", "frontend")
 def test_add():
     assert 1 + 1 == 2
```

To do it programmatically, for example:

```python
import pytest
import sys

def pytest_itemcollected(item):
  # You can use the rich data provided by pytest to selectively add execution tag to tests
  if "e2e" in item.location[0]:
    item.add_marker(pytest.mark.execution_tag("type", "browser"))
```
