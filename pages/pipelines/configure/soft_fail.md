# Soft fail

The `soft_fail` attribute of a [command step](/docs/pipelines/configure/step-types/command-step) allows a step to exit with a non-zero status without failing the build. The step is marked as passed, and the build continues as normal.

```yml
steps:
  - label: "Smoke tests"
    command: "smoke-test.sh"
    soft_fail: true
```
{: codeblock-file="pipeline.yml"}

## Soft fail attributes

The `soft_fail` attribute has the following optional attributes:

<table>
  <tr>
    <td><code>exit_status</code></td>
    <td>
      The exit status number that triggers a soft fail. Accepts a single integer or <code>"*"</code> (wildcard) to match any non-zero exit status.<br/>
      <em>Example:</em> <code>1</code><br/>
      <em>Example:</em> <code>"*"</code>
    </td>
  </tr>
</table>

### Allow all non-zero exit statuses

Set `soft_fail: true` to allow any non-zero exit status to pass without failing the build:

```yml
steps:
  - label: "Lint"
    command: "lint.sh"
    soft_fail: true
```
{: codeblock-file="pipeline.yml"}

### Allow specific exit statuses

Pass an array of `exit_status` values to only soft fail on particular exit codes.

In this example, the **Tests** step soft fails on an exit code of `1`, whereas the **Multiple exit statuses** step soft fails on either `1` or `42`:

```yml
steps:
  - label: "Tests"
    command: "tests.sh"
    soft_fail:
      - exit_status: 1

  - label: "Multiple exit statuses"
    command: "other-tests.sh"
    soft_fail:
      - exit_status: 1
      - exit_status: 42
```
{: codeblock-file="pipeline.yml"}

Use `exit_status: "*"` to match any non-zero exit status, which in this example, allows **Tests** to soft fail on any exit status:

```yml
steps:
  - label: "Tests"
    command: "tests.sh"
    soft_fail:
      - exit_status: "*"
```
{: codeblock-file="pipeline.yml"}

## Soft fail and dependencies

Setting `soft_fail` on a step also allows steps that depend on it to run, even when [`allow_dependency_failure: false`](/docs/pipelines/configure/dependencies#allowing-dependency-failures) is set on the subsequent step.

In the following example, `step-b` runs because `step-a` is soft failing. If `step-a` were to fail with a different exit code, `step-b` would not run.

```yml
steps:
  - key: "step-a"
    command: echo "soft fail" && exit 42
    soft_fail:
      - exit_status: 42

  - key: "step-b"
    command: echo "Running"
    depends_on: "step-a"
```
{: codeblock-file="pipeline.yml"}

## Soft fail in a build matrix

You can use `soft_fail` within a [build matrix](/docs/pipelines/configure/workflows/build-matrix) `adjustments` block to soft fail specific matrix combinations:

```yml
steps:
  - label: "Tests"
    command: "tests.sh"
    matrix:
      setup:
        os: ["linux", "windows"]
        arch: ["amd64", "arm64"]
    adjustments:
      - with:
          os: "windows"
          arch: "arm64"
        soft_fail: true
```
{: codeblock-file="pipeline.yml"}
