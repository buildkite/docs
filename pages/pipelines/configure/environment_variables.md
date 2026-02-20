# Environment variables

When the agent invokes your build scripts it passes in a set of standard Buildkite environment variables, along with any that you've defined in your build configuration. You can use these environment variables in your [build steps](/docs/pipelines/configure/defining-steps) and
[job lifecycle hooks](/docs/agent/hooks#job-lifecycle-hooks).

Environment variable size limits are dependent on the operating systems the agents are run on. When a program or process is started, it can typically accept inputs as either one or more environment variables in the form of `key=value` pairs, or a list (array) of command line arguments (referred to as a vector of arguments or `argv`). Depending on the operating system, these limits could be shared size limit across all such environment variables and `argv`, whereas others impose size limits per item (such as an environment variable's size limit).

For best practices and recommendations about using secrets in your environment variables, see the [Managing secrets](/docs/pipelines/security/secrets/managing) guide.

## Buildkite environment variables

The following environment variables may be visible in your commands, plugins, and hooks.

> 🚧 Unverified commits
> Note that GitHub accepts <a href="https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification">unsigned commits</a>, including information about the commit author and passes them along to webhooks, so you should not rely on these for authentication unless you are confident that all of your commits are trusted.

<table class="Docs__attribute__table">
  <colgroup>
    <col>
    <col>
  </colgroup>
  <tbody>
  <% ENVIRONMENT_VARIABLES['variables'].each do |env| -%>
    <%
      # anchors can't have *
      anchor = env['name'].gsub(/\*/, "")
    %>
    <tr id="<%= anchor %>">
      <th>
        <code><%= env['name'] %></code> <a class="Docs__attribute__link" href="#<%= anchor %>">#</a>
        <% if env['default_value'] %>
          <p class="Docs__attribute__env-var">
            <strong>Default</strong>:
            <code><%= env['default_value'] -%></code>
          </p>
        <% end %>
        <% if env['values'] %>
        <ul class="comma-separated Docs__attribute__env-var">
          <li><strong>Possible values:</strong></li>
            <% env['values'].each do |v| -%>
            <li><code><%= v -%></code></li>
          <% end %>
          </ul>
        <% end %>
        <% if !env['modifiable'] %>
          <small>This value cannot be modified</small>
        <% end %>
      </th>
      <td>
        <%= render_markdown(text: env['desc']) -%>

        <% if env['example'] %>
          <p>
            <strong class="h5">Example:</strong>
            <code><%= env['example'] -%></code>
          </p>
        <% end -%>
      </td>
    </tr>
  <% end -%>
  </tbody>
</table>

## Deprecated environment variables

The following environment variables have been deprecated.

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>BUILDKITE_PROJECT_PROVIDER</code></th>
    <td>This has been renamed to <code>BUILDKITE_PIPELINE_PROVIDER</code>.</td>
  </tr>
  <tr>
    <th><code>BUILDKITE_PROJECT_SLUG</code></th>
    <td>This has been renamed to <code>BUILDKITE_PIPELINE_SLUG</code>.</td>
  </tr>
  <tr>
    <th><code>BUILDKITE_SCRIPT_PATH</code></th>
    <td>This has been renamed to <code>BUILDKITE_COMMAND</code></td>
  </tr>
  <tr>
    <th><code>BUILDKITE_STEP_IDENTIFIER</code></th>
    <td>This has been renamed to <code>BUILDKITE_STEP_KEY</code></td>
  </tr>
  <tr>
    <th><code>BUILDBOX_AGENT_ID</code></th>
    <td>This has been renamed to <code>BUILDKITE_AGENT_ID</code></td>
  </tr>
  <tr>
    <th><code>BUILDBOX_AGENT_NAME</code></th>
    <td>This has been renamed to <code>BUILDKITE_AGENT_NAME</code></td>
  </tr>
  <tr>
    <th><code>BUILDBOX_AGENT_META_DATA_*</code></th>
    <td>This has been renamed to <code>BUILDKITE_AGENT_META_DATA_*</code></td>
  </tr>
  <tr>
    <th><code>BUILDBOX_AGENT_ACCESS_TOKEN</code></th>
    <td>This has been renamed to <code>BUILDKITE_AGENT_ACCESS_TOKEN</code></td>
  </tr>
  <tr>
    <th><code>BUILDBOX_AGENT_API_URL</code></th>
    <td>This has been removed with no replacement</td>
  </tr>
</tbody>
</table>

## Defining your own

You can define environment variables in your jobs in a few ways, depending on the nature of the value being set:

* Pipeline settings — for values that are *not secret*.
* [Build pipeline configuration](/docs/pipelines/configure/step-types/command-step) — for values that are *not secret*.
* An `environment` or `pre-command` [agent hook](/docs/agent/hooks) — for values that are secret or agent-specific.

> 🚧 Secrets in environment variables
> Do not print or export secrets in your pipelines. See the [Secrets](/docs/pipelines/security/secrets/managing) documentation for further information and best practices.

## Variable interpolation

Any environment variables set by Buildkite will be interpolated by the Agent.

If you're using the YAML Steps editor to define your pipeline, only the following subset of the environment variables are available:

* `BUILDKITE_BRANCH`
* `BUILDKITE_TAG`
* `BUILDKITE_MESSAGE`
* `BUILDKITE_COMMIT`
* `BUILDKITE_PIPELINE_SLUG`
* `BUILDKITE_PIPELINE_NAME`
* `BUILDKITE_PIPELINE_ID`
* `BUILDKITE_ORGANIZATION_SLUG`
* `BUILDKITE_TRIGGERED_FROM_BUILD_PIPELINE_SLUG`
* `BUILDKITE_REPO`
* `BUILDKITE_PULL_REQUEST`
* `BUILDKITE_PULL_REQUEST_BASE_BRANCH`
* `BUILDKITE_PULL_REQUEST_REPO`
* `BUILDKITE_MERGE_QUEUE_BASE_BRANCH`
* `BUILDKITE_MERGE_QUEUE_BASE_COMMIT`

Some variables, for example `BUILDKITE_BUILD_NUMBER`, cannot be supported in the YAML Step editor as the interpolation happens before the build is created. In those cases, interpolate them at the [runtime](/docs/pipelines/configure/environment-variables#runtime-variable-interpolation).

Alternatively, You can also access the rest of the Buildkite [environment variables](/docs/pipelines/configure/environment-variables#buildkite-environment-variables) by using a `pipeline.yml` file. Either define your entire pipeline in the YAML file, or you do a [pipeline upload](/docs/agent/cli/reference/pipeline) part way through your build that adds only the steps that use environment variables. See the [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) docs for more information about adding steps with pipeline uploads.

## Runtime variable interpolation

When using environment variables that will be evaluated at run-time, make sure you escape the `$` character using `$$` or `\$`. For example:

```yml
- command: "deploy.sh $$SERVER"
  env:
    SERVER: "server-a"
```

Further details about environment variable interpolation can be found in the [pipeline upload](/docs/agent/cli/reference/pipeline#environment-variable-substitution) CLI guide.

## Environment variable precedence

You can set environment variables in lots of different places, and which ones take precedence can get a little confusing.
There are many different levels at which environment variables are merged together. The following walkthrough and examples demonstrate the order in which variables are combined, as if you had set variables in every available place.

### Job environment

When a job runs on an agent, the first combination of environment variables happens in the job environment itself. This is the environment you can see in a job's Environment tab in the Buildkite dashboard, and the one returned by the REST and GraphQL APIs.

> 📘
> If you are not using YAML Steps, the precedence of environment variables is different from the list below.
> Please [migrate your pipelines](/docs/pipelines/tutorials/pipeline-upgrade) to use YAML steps.

The job environment is made by merging the following sets of values, where values in each successive set take precedence:

<table>
<tbody>
  <tr>
    <th><em>Pipeline</em></th>
    <td>Optional variables set by you on a pipeline on the Pipeline Settings page</td>
  </tr>
  <tr>
    <th><em>Build</em></th>
    <td>Optional variables set by you on the build when creating a new build in the UI or using the REST API</td>
  </tr>
    <tr>
    <th><em>Step</em></th>
    <td>Optional variables set by you on a step in the YAML steps editor or a pipeline.yml file</td>
  </tr>
  <tr>
    <th><em>Standard</em></th>
    <td>The set of variables provided by Buildkite to every job</td>
  </tr>
</tbody>
</table>

For example, if you had configured the following environment variables:

<table>
  <tbody>
    <tr>
      <th><em>Pipeline</em></th>
      <td><code>MY_ENV1="a"</code></td>
    </tr>
    <tr>
      <th><em>Build</em></th>
      <td><code>MY_ENV1="b"</code></td>
    </tr>
        <tr>
      <th><em>Step</em></th>
      <td><code>MY_ENV1="c"</code></td>
    </tr>
  </tbody>
</table>

In the final job environment, the value of `MY_ENV1` would be `"c"`.

#### Setting variables in a pipeline.yml

There are two places in a pipeline.yml file that you can set environment variables:

  1. In the `env` attribute of command and trigger steps.
  1. In the `env` attribute at the top of the yaml file, before you define your pipeline's steps.

Defining an environment variable at the top of your yaml file will set that variable on each of the command steps in the pipeline that have not already started running, and is equivalent to setting the `env` attribute on every step. This includes further pipeline uploads through `buildkite-agent pipeline upload`.

> 🚧 Concurrent pipeline uploads and environment variables
> Concurrent pipeline uploads with build-level environment variables can cause unpredictable behavior by modifying the environment for steps that haven't started yet.
> This affects steps running after pipeline uploads, signed pipeline steps (where environment variables affect signature verification), and jobs that depend on specific environment variable values.
> Issues typically occur when multiple pipeline uploads that include build-level environment variables happen at the same time or set the same environment variable to different values.

#### Setting variables in a Trigger step

Environment variables are not automatically passed through to builds created with [trigger steps](/docs/pipelines/configure/step-types/trigger-step). To set build-level environment variables on triggered builds, set the trigger step's `env` attribute.

### Agent environment

Separate to the job's base environment, your `buildkite-agent` process has an environment of its own. This is made up of:

* operating system environment variables
* any variables you set on your agent when you started it
* any environment variables that were inherited from how you started the process (for example, systemd sets some env vars for you)

For a list of variables and configuration flags, you can set on your agent, see the Buildkite agent's [start command documentation](/docs/agent/cli/reference/start).

> 📘
> When using the [Agent Stack for Kubernetes](/docs/agent/self-hosted/agent-stack-k8s) controller, environment variables declared as part of a PodSpec will also take precedence when the Kubernetes job is created. Learn more about this in [Kubernetes PodSpec generation](/docs/agent/self-hosted/agent-stack-k8s/podspec#kubernetes-podspec-generation).

### Job runtime environment

Once the job is accepted by an agent, more environment merging happens. Starting with the environment that we put together in the [Job Environment section](#environment-variable-precedence-job-environment), we merge in some of the variables from the agent environment.

> 📘
> Not all variables from the agent are available in the job runtime. For example, we remove the agent's registration token and replace it with a build session token that has limited permissions. This new session token is used when you run the `artifact`, `meta-data` and `pipeline` commands inside the job.

After the agent variables have been merged, the bootstrap script is run.

The bootstrap runs any hooks that have been defined by your
[agent](/docs/agent/hooks#hook-locations-agent-hooks), your [repository](/docs/agent/hooks#hook-locations-repository-hooks) or [plugins](/docs/agent/hooks#hook-locations-plugin-hooks).
Variables that are set in these hooks will be merged into the runtime
environment, and will override any previous values that are set.

> 🚧 Take care with environment variables in hooks
> Variables that are defined in hooks can override anything that exists in the environment.

This is the environment your command runs in 🎉

Finally, if your job's commands make any changes to the environment, those changes will only survive as long as the script is running.
