# Command step

A command step runs one or more shell commands on one or more agents.

Each command step can run either a shell command like `npm test`, or an executable file, or script like `build.sh`.

A command step can be defined in your pipeline settings, or in your [pipeline.yml](/docs/pipelines/configure/defining-steps) file.

```yml
steps:
  - command: "tests.sh"
```
{: codeblock-file="pipeline.yml"}

To have a set of commands execute sequentially in a single step, use the `command` syntax followed by a `|` symbol:

```yml
steps:
  - command: |
      "tests.sh"
      "echo 'running tests'"
```
{: codeblock-file="pipeline.yml"}

You can also define multiple commands by using the `commands` syntax and starting each new command on a new line:

```yml
steps:
  - commands:
    - "tests.sh"
    - "echo 'running tests'"
```
{: codeblock-file="pipeline.yml"}

When running multiple commands, either defined in a single line (`npm install && tests.sh`) or defined in a list, any failure will prevent subsequent commands from running, and will mark the command step as failed.

The results of running the commands defined in separate command steps are not guaranteed to be available to the subsequent command steps as those steps could be running on a different machine in the [cluster queue](/docs/agent/v3/targeting/queues/managing#setting-up-queues).

> 📘 Commands and `PATH`
> The shell command(s) provided for execution must be resolvable through the directories defined within the `PATH` environment variable. When referencing scripts for execution, preference using a relative path (for example, `./scripts/build.sh`, or `scripts/bin/build-prod`).

## Command step attributes

Required attributes:

<table data-attributes data-attributes-required>
  <tr>
    <td><code>command</code></td>
    <td>
      The shell command/s to run during this step. This can be a single line of commands, or a list of commands that must all pass.<br/>
      <em>Example:</em> <code>"build.sh"</code><br/>
      <em>Example:</em><br/>
      <code>- "npm install"</code><br/>
      <code>- "./tests.sh"</code><br/>
      <em>Alias:</em> <code>commands</code>
    </td>
  </tr>
</table>

```yml
steps:
  - commands:
    - "npm install && npm test"
    - "extras/moretests.sh"
    - "./build.sh"
```
{: codeblock-file="pipeline.yml"}

> 📘 Pipelines without command steps
> Although the <code>command</code> attribute is required for a command step, some <a href="/docs/pipelines/integrations/plugins/using#adding-a-plugin-to-your-pipeline">plugins</a> work without a command step, so it isn't strictly necessary for your pipeline to have an explicit command step.

Optional attributes:

<table data-attributes>
  <tr id="agents">
    <td><code>agents</code></td>
    <td>
      A map of <a href="/docs/agent/v3/cli-start#setting-tags">agent tag</a> keys to values to <a href="/docs/agent/v3/cli-start#agent-targeting">target specific agents</a> for this step.<br/>
      <em>Example:</em> <code>npm: "true"</code>
    </td>
  </tr>
  <tr>
    <td><code>allow_dependency_failure</code></td>
    <td>
      Whether to continue to run this step if any of the steps named in the <code>depends_on</code> attribute fail.<br/>
      <em>Default:</em> <code>false</code>
    </td>
  </tr>
  <tr>
    <td><code>artifact_paths</code></td>
    <td>
      The <a href="/docs/pipelines/configure/glob-pattern-syntax">glob path</a> or paths of <a href="/docs/agent/v3/cli-artifact">artifacts</a> to upload from this step. This can be a single line of paths separated by semicolons, or a list.<br/>
      <em>Example:</em> <code>"logs/**/*;coverage/**/*"</code><br/>
      <em>Example:</em><br/>
      <code>- "logs/**/*"</code><br/>
      <code>- "coverage/**/*"</code>
    </td>
  </tr>
  <tr>
    <td><code>branches</code></td>
    <td>
      The <a href="/docs/pipelines/configure/workflows/branch-configuration#branch-pattern-examples">branch pattern</a> defining which branches will include this step in their builds.<br/>
      <em>Example:</em> <code>"main stable/*"</code>
    </td>
  </tr>
  <tr>
    <td><code>cancel_on_build_failing</code></td>
    <td>
      Setting this attribute to <code>true</code> cancels the job as soon as the build is marked as <a href="/docs/pipelines/configure/defining-steps#build-states">failing</a>.<br/>
      <em>Default:</em> <code>"false"</code>
    </td>
  </tr>
  <tr>
    <td><code>concurrency</code></td>
    <td>
      The <a href="/docs/pipelines/configure/workflows/controlling-concurrency#concurrency-limits">maximum number of jobs</a> created from this step that are allowed to run at the same time. If you use this attribute, you must also define a label for it with the <code>concurrency_group</code> attribute.<br/>
      <em>Example:</em> <code>3</code>
    </td>
  </tr>
  <tr>
    <td><code>concurrency_group</code></td>
    <td>
      A unique name for the concurrency group that you are creating. If you use this attribute, you must also define the <code>concurrency</code> attribute.<br/>
      <em>Example:</em> <code>"my-app/deploy"</code>
    </td>
  </tr>
  <tr>
    <td><code>concurrency_method</code></td>
    <td>
      This attribute provides control of the scheduling method for jobs in a <a href="/docs/pipelines/configure/workflows/controlling-concurrency">concurrency group</a>. With the <code>"ordered"</code> value set, the jobs run sequentially in the order they were queued, while the <code>"eager"</code> value allows jobs to run as soon as resources become available. If you use this attribute, you must also define the <code>concurrency</code> and <code>concurrency_group</code> attributes.<br/>
      <em>Default:</em> <code>"ordered"</code><br/>
      <em>Example:</em> <code>"eager"</code>
    </td>
  </tr>
  <tr>
    <td><code>depends_on</code></td>
    <td>
      A list of step keys that this step depends on. This step will only run after the named steps have completed. See <a href="/docs/pipelines/configure/dependencies">managing step dependencies</a> for more information.<br/>
      <em>Example:</em> <code>"test-suite"</code>
    </td>
  </tr>
  <tr>
    <td><code>env</code></td>
    <td>
      A map of <a href="/docs/pipelines/configure/environment-variables">environment variables</a> for this step.<br/>
      <em>Example:</em> <code>RAILS_ENV: "test"</code>
    </td>
  </tr>
  <tr>
    <td><code>secrets</code></td>
    <td>
      Either an array of <a href="/docs/pipelines/security/secrets/buildkite-secrets">Buildkite secrets</a> or a map of environment variables names to Buildkite secrets for this step.<br/>
      <em>Example:</em> <code>- API_ACCESS_TOKEN</code>
    </td>
  </tr>
  <tr>
    <td><code>if</code></td>
    <td>
      A boolean expression that omits the step when false. See <a href="/docs/pipelines/configure/conditionals">Using conditionals</a> for supported expressions.<br/>
      <em>Example:</em> <code>build.message != "skip me"</code>
    </td>
  </tr>
  <tr>
    <td><code>key</code></td>
    <td>
      A unique string to identify the command step. The value is available in the <code>BUILDKITE_STEP_KEY</code> <a href="/docs/pipelines/configure/environment-variables">environment variable</a>.<br/>
      Keys can not have the same pattern as a UUID (<code>xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx</code>).<br/>
      <em>Example:</em> <code>"linter"</code><br/>
      <em>Alias:</em> <code>identifier</code>
    </td>
  </tr>
  <tr id="label">
    <td><code>label</code></td>
    <td>
      The label that will be displayed in the pipeline visualization in Buildkite. Supports emoji.<br/>
      <em>Example:</em> <code>"\:hammer\: Tests" will be rendered as ":hammer: Tests"</code><br/>
    </td>
  </tr>
  <tr>
    <td><code>matrix</code></td>
    <td>
      Either an array of values to be used in the matrix expansion, or a single <code>setup</code> key, and an optional <code>adjustments</code> key.<br/>
      <code>steps:<br/>
- label: "{{matrix}} build"<br/>
&nbsp;&nbsp;command: "echo '.buildkite/steps/build-binary.sh {{matrix}}'"<br/>
&nbsp;&nbsp;&nbsp;&nbsp;matrix:<br/>
&nbsp;&nbsp;&nbsp;&nbsp;- "macOS"<br/>
&nbsp;&nbsp;&nbsp;&nbsp;- "Linux"<code>
    </td>
  </tr>
  <tr>
    <td><code>parallelism</code></td>
    <td>
      The number of <a href="/docs/pipelines/tutorials/parallel-builds#parallel-jobs">parallel jobs</a> that will be created based on this step.<br/>
      <em>Example:</em> <code>3</code>
    </td>
  </tr>
  <tr id="plugins">
    <td><code>plugins</code></td>
    <td>
      An array of <a href="/docs/pipelines/integrations/plugins">plugins</a> for this step.<br/>
      <em>Example:</em><br/>
      <code>- docker-compose#v1.0.0:<br/>
&nbsp;&nbsp;&nbsp;&nbsp;run: app</code>
    </td>
  </tr>
  <tr>
    <td><code>priority</code></td>
    <td>
      Adjust the <a href="/docs/pipelines/configure/workflows/managing-priorities">priority</a> for a specific job, as a positive or negative integer.<br/>
      <em>Example:</em><br/>
      <code>- command: "will-run-first.sh"<br/>
      &nbsp;&nbsp;priority: 1</code>
    </td>
  </tr>
  <tr>
    <td><code>retry</code></td>
    <td>
      The conditions for retrying this step.<br/>
      Available types: <code>automatic</code>, <code>manual</code>
    </td>
  </tr>
  <tr>
    <td><code>skip</code></td>
    <td>
      Whether to skip this step or not. Passing a string (with a 70-character limit) provides a reason for skipping this command. Passing an empty string is equivalent to <code>false</code>.
      Note: Skipped steps will be hidden in the pipeline view by default, but can be made visible by toggling the 'Skipped jobs' icon.<br/>
      <em>Example:</em> <code>true</code><br/>
      <em>Example:</em> <code>false</code><br/>
      <em>Example:</em> <code>"My reason"</code>
    </td>
  </tr>
  <tr>
    <td><code>soft_fail</code></td>
    <td>
      Allow specified non-zero exit statuses not to fail the build.
      Can be either <code>true</code> to make all exit statuses soft-fail or an <code>array</code> of allowed soft failure exit statuses with the <code>exit_status</code> attribute. Use <code>exit_status: "*"</code> to allow all non-zero exit statuses not to fail the build.<br/>
      <em>Example:</em> <code>true</code><br/>
      <em>Example:</em><br/>
      <code>- exit_status: 1</code><br/>
      <em>Example:</em><br/>
      <code>- exit_status: "*"</code><br/>
    </td>
  </tr>
  <tr id="timeout_in_minutes">
    <td><code>timeout_in_minutes</code></td>
    <td>
      <p>The maximum number of minutes a job created from this step is allowed to run. If the job exceeds this time limit, or if it finishes with a non-zero exit status, the job is automatically canceled and the build fails. Jobs that time out with an exit status of <code>0</code> are marked as <code>passed</code>.</p>
      <p>You can also set <a href="/docs/pipelines/configure/build-timeouts">default and maximum timeouts</a> in the Buildkite UI.</p>
      <p><em>Example:</em> <code>60</code></p>
    </td>
  </tr>
</table>

## Agent-applied attributes

<%= render_markdown partial: 'pipelines/configure/step_types/agent_applied_attributes' %>

## Container image attributes

The `image` attribute can be used with either the [Agent Stack for Kubernetes](/docs/agent/v3/self-hosted/agent-stack-k8s) controller to run your [Buildkite Agents](/docs/agent/v3), or [Buildkite hosted agents](/docs/pipelines/hosted-agents).

- If you are running your Buildkite Agents using the Agent Stack for Kubernetes, you can use the `image` attribute to specify a [container image](/docs/agent/v3/self-hosted/agent-stack-k8s/podspec#podspec-command-and-interpretation-of-arguments-custom-images) for a command step to run its job in.

- If you are using Buildkite hosted agents, support for the `image` attribute is experimental and subject to change.

<table>
  <tr>
    <td><code>image</code></td>
    <td>
      A fully qualified image reference string. The <a href="/docs/agent/v3/self-hosted/agent-stack-k8s">Agent Stack for Kubernetes</a> controller will configure the <a href="/docs/agent/v3/self-hosted/agent-stack-k8s/podspec#podspec-command-and-interpretation-of-arguments-custom-images">custom image</a> for the <code>command</code> container of this job. The value is available in the <code>BUILDKITE_IMAGE</code> <a href="/docs/pipelines/configure/environment-variables">environment variable</a>.<br/>
      <em>Example:</em> <code>"alpine:latest"</code>
    </td>
  </tr>
</table>

> 🚧
> Support for this `image` attribute is currently experimental.

Example pipeline, showing how build and step level `image` attributes interact:

```yml
image: "ubuntu:22.04" # The default image for the pipeline's build

steps:
  - name: "\:node\: Frontend tests"
    command: |
      cd frontend
      npm ci
      npm test
    image: "node:18" # This step's job uses the node:18 image

  - name: "\:golang\: Backend tests"
    command: |
      cd backend
      go mod download
      go test ./...
    image: "golang:1.21" # This step's job uses the golang:1.21 image

  - name: "\:package\: Package application"
    command: |
      apt-get update && apt-get install -y zip
      zip -r app.zip frontend/ backend/
    # No image specified in this step.
    # Therefore, this step's job uses the pipeline's default ubuntu:22.04 image
```

## Retry attributes

At least one of the following attributes is required:

<table>
  <tr>
    <td><code><a href="/docs/pipelines/configure/step-types/command-step#retry-attributes-automatic-retry-attributes">automatic</a></code></td>
    <td>
      Whether to allow a job to retry automatically. This field accepts a boolean value, individual retry conditions, or a list of multiple different retry conditions.<br/> If set to <code>true</code>, the retry conditions are set to the default value.<br/>
      <em>Default value:</em><br/>
      <code>exit_status: "*"</code><br/>
      <code>signal: "*"</code><br/>
      <code>signal_reason: "*"</code><br/>
      <code>limit: 2</code><br/>
      <em>Example:</em> <code>true</code>
    </td>
  </tr>
  <tr>
    <td><code><a href="/docs/pipelines/configure/step-types/command-step#retry-attributes-manual-retry-attributes">manual</a></code></td>
    <td>
      Whether to allow a job to be retried manually. This field accepts a boolean value, or a single retry condition.<br/>
      <em>Default value:</em> <code>true</code><br/>
      <em>Example:</em> <code>false</code>
    </td>
  </tr>
</table>

```yml
steps:
  - label: "Tests"
    command: "tests.sh"
    retry:
      automatic: true

  - wait: ~

  - label: "Deploy"
    command: "deploy.sh"
    retry:
      manual: false
```
{: codeblock-file="pipeline.yml"}

If you retry a job, the information about the failed job(s) remains, and a new job is created. The history of retried jobs is preserved and immutable. The number of possible retries is available as an [environment variable `limit`](/docs/pipelines/configure/step-types/command-step#retry-attributes-automatic-retry-attributes) on the job. When a limit is not specified on automatic retry, the default limit is three.

<%= image "retry-time-date.png", width: 2456/2, height: 1076/2, alt: "You can view how and when a job was retried" %>

You can also see when a job has been retried and whether it was retried automatically or by a user. Such jobs will hidden - you can expand and view all the hidden retried jobs.

<%= image "hidden-jobs.png", width: 1400, height: 330, alt: "Retry history is preserved and can be viewed" %>

In the Buildkite UI, there is a [Job Retries Report section](https://buildkite.com/organizations/~/reports/job-retries) where you can view a graphic report on jobs retried manually or automatically within the last 30 days. This can help you understand flakiness and instability across all of your pipelines.

<%= image "job-retries-report.png", width: 2792/2, height: 1400/2, alt: "Information on manual and automatic job retries over the last 24 hours to 30 days " %>

Conditions on retries can be specified. For example, it's possible to set steps to be retried automatically if they exit with particular exit codes, or prevent retries on important steps like deployments. The following example shows different retry configurations:

```yml
  - label: "Tests"
    command: "tests.sh"
    retry:
      automatic:
        - exit_status: 5
          limit: 2
        - exit_status: "*"
          limit: 4
  - wait: ~
  - label: "Deploy"
    command: "deploy.sh"
    branches: "main"
    retry:
      manual:
        allowed: false
        reason: "Deploys shouldn't be retried"
```
{: codeblock-file="pipeline.yml"}

### Automatic retry attributes

Optional attributes:

<table>
  <tr>
    <td><code>exit_status</code></td>
    <td>
      The exit status value that causes this job to retry, and can include any value between 0-255. Other valid exit status values include <code>*</code> for any value between 1-255 (excluding <code>0</code>), as well as <code>-1</code> (the value returned when an agent is lost and Buildkite no longer receives contact from agent).<br/>
      <p><em>Examples:</em></p>
      <ul>
        <li><code>"*"</code></li>
        <li><code>2</code></li>
        <li><code>42</code></li>
        <li><code>143</code></li>
        <li><code>-1</code></li>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>signal</code></td>
    <td>
      The signal that causes this job to retry. This signal only appears if the agent sends a signal to the job and an interior process does not handle the signal. <code>SIGKILL</code> propagates reliably because it cannot be handled, and is a useful way to differentiate graceful cancelation and timeouts.
      <p><em>Examples:</em></p>
      <ul>
        <li><code>"*"</code></li>
        <li><code>kill</code></li>
        <li><code>SIGINT</code></li>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>signal_reason</code></td>
    <td>
      The reason a process was signaled.<br/>
      <p><em>Examples:</em></p>
      <ul>
        <li><code>"*"</code></li>
        <li><code>none</code></li>
        <li><code>cancel</code></li>
        <li><code>agent_stop</code></li>
        <li><code>agent_refused</code></li>
        <li><code>process_run_error</code></li>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>limit</code></td>
    <td>
      The number of times this job can be retried. The maximum value this can be set to is 10.<br/>
      <em>Example:</em> <code>3</code>
    </td>
  </tr>
</table>

> 📘 -1 exit status
> A job will fail with an exit status of -1 if communication with the agent has been lost (for example, the agent has been forcefully terminated, or the agent machine was shut down without allowing the agent to disconnect). See the section on [Exit Codes](/docs/agent/v3#exit-codes) for information on other exit codes.

```yml
steps:
  - label: "Tests"
    command: "tests.sh"
    retry:
      automatic:
        - exit_status: -1  # Agent was lost
          limit: 2
        - exit_status: 255 # Forced agent shutdown
          limit: 2
```
{: codeblock-file="pipeline.yml"}

### Manual retry attributes

Optional attributes:

<table>
  <tr>
    <td><code>allowed</code></td>
    <td>
      A boolean value that defines whether or not this job can be retried manually.<br/>
      <em>Default value:</em> <code>true</code><br/>
      <em>Example:</em> <code>false</code>
    </td>
  </tr>
  <tr>
    <td><code>permit_on_passed</code></td>
    <td>
      A boolean value that defines whether or not this job can be retried after it has passed.<br/>
      <em>Example:</em> <code>false</code>
    </td>
  </tr>
  <tr>
    <td><code>reason</code></td>
    <td>
      A string that will be displayed in a tooltip on the Retry button in Buildkite. This will only be displayed if the <code>allowed</code> attribute is set to false.<br/>
      <em>Example:</em> <code>"No retries allowed on deploy steps"</code>
    </td>
  </tr>
</table>

```yml
steps:
  - label: "Tests"
    command: "tests.sh"
    retry:
      manual:
        permit_on_passed: true

  - wait: ~

  - label: "Deploy"
    command: "deploy.sh"
    retry:
      manual:
        allowed: false
        reason: "Sorry, you can't retry a deployment"
```
{: codeblock-file="pipeline.yml"}

## Soft fail attributes

Optional attributes:

<table>
  <tr>
    <td><code>exit_status</code></td>
    <td>
      Allow specified non-zero exit statuses not to fail the build. Use <code>"*"</code> to allow all non-zero exit statuses or specify individual exit status codes.
      <br/>
      <em>Example:</em> <code>"*"</code><br/>
      <em>Example:</em> <code>1</code>
    </td>
  </tr>
</table>

```yml
steps:
  - label: "Specific exit status"
    command: "tests.sh"
    soft_fail:
      - exit_status: 1

  - label: "All non-zero exit statuses"
    command: "tests.sh"
    soft_fail:
      - exit_status: "*"
```
{: codeblock-file="pipeline.yml"}


## Matrix attributes

<table>
  <tr>
    <td><code>setup</code></td>
    <td>
      A list of dimensions, each containing an array of elements. The job matrix is built by combining all values of each dimension, with the other elements of each dimension.
    </td>
  </tr>
  <tr>
    <td><code>adjustments</code></td>
    <td>
      A array of <code>with</code> keys, each mapping an element to each dimension listed in the <code>array.setup</code>, as well as the attribute to modify for that combination.<br/>
      Currently, only <code>soft_fail</code> and <code>skip</code> can be modified.
    </td>
  </tr>
</table>

```yaml
steps:
- label: "💥 Matrix build with adjustments"
  command: "echo {{matrix.os}} {{matrix.arch}} {{matrix.test}}"
  matrix:
    setup:
      arch:
        - "amd64"
        - "arm64"
      os:
        - "windows"
        - "linux"
      test:
        - "A"
        - "B"
    adjustments:
      - with:
          os: "windows"
          arch: "arm64"
          test: "B"
        soft_fail: true
      - with:
          os: "linux"
          arch: "arm64"
          test: "B"
        skip: true
```
{: codeblock-file="pipeline.yml"}

## Fast-fail running jobs

To automatically cancel any remaining jobs as soon as any job in the build fails (except jobs marked as `soft_fail`), add the `cancel_on_build_failing: true` attribute to your command steps.

When a job fails, the build enters a _failing_ state. Any jobs still running that have `cancel_on_build_failing: true` are automatically canceled. Once all running jobs have been cancelled, the build is marked as _failed_ due to the initial job failure.

## Example

```yml
steps:
  - label: "\:hammer\: Tests"
    commands:
      - "npm install"
      - "npm run tests"
    branches: "main"
    env:
      NODE_ENV: "test"
    agents:
      npm: "true"
      queue: "tests"
    artifact_paths:
      - "logs/**/*"
      - "coverage/**/*"
    parallelism: 5
    timeout_in_minutes: 3
    retry:
      automatic:
        - exit_status: -1
          limit: 2
        - exit_status: 143
          limit: 2
        - exit_status: 255
          limit: 2

  - label: "Visual diff"
    commands:
      - "npm install"
      - "npm run visual-diff"
    cancel_on_build_failing: true
    retry:
      automatic:
        limit: 3

  - label: "Skipped job"
    command: "broken.sh"
    cancel_on_build_failing: true
    skip: "Currently broken and needs to be fixed"

  - wait: ~

  - label: "\:shipit\: Deploy"
    command: "deploy.sh"
    branches: "main"
    concurrency: 1
    concurrency_group: "my-app/deploy"
    concurrency_method: "eager"
    retry:
      manual:
        allowed: false
        reason: "Sorry, you can't retry a deployment"

  - wait: ~

  - label: "Smoke test"
    command: "smoke-test.sh"
    soft_fail:
      - exit_status: 1
```
{: codeblock-file="pipeline.yml"}
