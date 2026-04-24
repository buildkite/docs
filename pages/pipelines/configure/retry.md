# Retry

The `retry` attribute of a [command step](/docs/pipelines/configure/step-types/command-step) controls whether and how a job can be retried. You can configure automatic retries for transient failures, manual retries for user-initiated reruns, or both.

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

## Retry behavior

If you retry a job, the information about the failed job(s) remains, and a new job is created. The history of retried jobs is preserved and immutable. For automatic retries, the number of possible retries can be set with a [`limit` attribute](/docs/pipelines/configure/retry#retry-attributes-automatic-retry-attributes) on the job's step. When a limit is not specified, the default limit is two.

<%= image "retry-time-date.png", width: 2456/2, height: 1076/2, alt: "You can view how and when a job was retried" %>

You can also see when a job has been retried and whether it was retried automatically or by a user. Such jobs are hidden by default—you can expand and view all the hidden retried jobs.

<%= image "hidden-jobs.png", width: 1400, height: 330, alt: "Retry history is preserved and can be viewed" %>

In the Buildkite web interface, there is a [Job Retries Report section](https://buildkite.com/organizations/~/reports/job-retries) where you can view a graphic report on jobs retried manually or automatically within the last 30 days. This can help you understand flakiness and instability across all of your pipelines.

<%= image "job-retries-report.png", width: 2792/2, height: 1400/2, alt: "Information on manual and automatic job retries over the last 24 hours to 30 days" %>

## Retry attributes

The `retry` attribute requires one of the following attributes:

<table>
  <tr>
    <td><code><a href="#retry-attributes-automatic-retry-attributes">automatic</a></code></td>
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
    <td><code><a href="#retry-attributes-manual-retry-attributes">manual</a></code></td>
    <td>
      Whether to allow a job to be retried manually. This field accepts a boolean value, or a single retry condition.<br/>
      <em>Default value:</em> <code>true</code><br/>
      <em>Example:</em> <code>false</code>
    </td>
  </tr>
</table>

Conditions on retries can be specified. For example, it's possible to set steps to be retried automatically if they exit with particular exit codes, or prevent retries on important steps like deployments. The following example shows different retry configurations:

```yml
steps:
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

The `retry.automatic` attribute has the following optional attributes:

<table>
  <tr>
    <td><code>exit_status</code></td>
    <td>
      The exit status number or numbers that cause this job to be retried. This attribute accepts a single integer, an array of integers, or <code>"*"</code> (wildcard). Valid exit status values are between 0 and 255, plus <code>-1</code> (the value returned when an agent is lost and Buildkite no longer receives contact from the agent). A <code>"*"</code> matches any value between 1 and 255 (excluding <code>0</code>).<br/>
      <em>Default value:</em> <code>"*"</code>
      <p><em>Examples:</em></p>
      <ul>
        <li><code>"*"</code></li>
        <li><code>2</code></li>
        <li><code>-1</code></li>
        <li><code>[1, 5, 42, 255]</code></li>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>signal</code></td>
    <td>
      The signal that causes this job to be retried. This attribute accepts a string, an array of strings, or <code>"*"</code> (wildcard). This signal only appears if the agent sends a signal to the job and an interior process does not handle the signal. <code>SIGKILL</code> propagates reliably because it cannot be handled, and is a useful way to differentiate graceful cancelation and timeouts. Signal matching is case-insensitive and the <code>SIG</code> prefix is optional (for example, <code>SIGKILL</code> and <code>kill</code> are equivalent). Use <code>"none"</code> to match jobs that received no signal.<br/>
      <em>Default value:</em> <code>"*"</code>
      <p><em>Examples:</em></p>
      <ul>
        <li><code>"*"</code></li>
        <li><code>"none"</code></li>
        <li><code>kill</code></li>
        <li><code>SIGINT</code></li>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>signal_reason</code></td>
    <td>
      The reason associated with a job failure. This attribute accepts a string, an array of strings, or <code>"*"</code> (wildcard). Use <code>"none"</code> to match jobs with no signal reason.<br/>
      Some signal reasons represent cases where a running job was signaled to stop, for example, <code>cancel</code> or <code>agent_stop</code>. Other signal reasons indicate that the job never ran in the first place, for example, <code>signature_rejected</code>, <code>agent_incompatible</code>, or <code>stack_error</code>.<br/>
      <em>Default value:</em> <code>"*"</code>
      <p><em>Available values:</em></p>
      <ul>
        <li><code>"*"</code> — matches any signal reason</li>
        <li><code>none</code> — matches jobs with no signal reason</li>
        <li><code>cancel</code> — the job was canceled or timed out</li>
        <li><code>agent_stop</code> — the agent was stopped while running the job</li>
        <li><code>agent_refused</code> — the agent refused the job</li>
        <li><code>agent_incompatible</code> — the agent was incompatible with the job</li>
        <li><code>process_run_error</code> — the process failed to start</li>
        <li><code>signature_rejected</code> — the job signature was rejected</li>
        <li><code>stack_error</code> — an error occurred provisioning infrastructure for the job</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td><code>limit</code></td>
    <td>
      The number of times this job can be retried. The maximum value this can be set to is 10. Each retry rule tracks its own count independently.<br/>
      <em>Default value:</em> <code>2</code><br/>
      <em>Example:</em> <code>3</code><br/>
      You can also set this value to <code>0</code> to prevent a job from being retried. This is useful if, for example, the job returns a <code>signal_reason</code> of <code>stack_error</code>. Learn more about this in the <a href="/docs/apis/agent-api/stacks#finish-a-job-retry-attributes">Retry attributes</a> section of the <a href="/docs/apis/agent-api/stacks">Stacks API</a>.
    </td>
  </tr>
</table>

When a single retry rule specifies multiple conditions (`exit_status`, `signal`, and `signal_reason`), all conditions must match for that rule to trigger a retry. If you define multiple retry rules, they are evaluated in the order they appear, and the first matching rule is applied. Exit statuses not matched by any rule are not retried, so you don't need to explicitly set `limit: 0` for unmatched statuses.

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

> 📘 -1 exit status
> A job will fail with an exit status of -1 if communication with the agent has been lost (for example, the agent has been forcefully terminated, or the agent machine was shut down without allowing the agent to disconnect). See [Exit codes](/docs/agent/lifecycle#exit-codes) for information on other such codes.

The following example shows a step with combined retry conditions. The first rule retries up to three times when the agent refuses the job (both the exit status and signal reason must match). The second rule retries up to two times for any other failure.

```yml
steps:
  - label: "Tests"
    command: "tests.sh"
    retry:
      automatic:
        - exit_status: -1
          signal_reason: agent_refused
          limit: 3
        - exit_status: "*"
          limit: 2
```
{: codeblock-file="pipeline.yml"}

### Manual retry attributes

The `retry.manual` attribute has the following optional attributes:

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
      A string displayed in a tooltip on the **Retry** button in Buildkite. This only appears if the <code>allowed</code> attribute is set to false.<br/>
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
