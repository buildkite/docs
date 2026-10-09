# Canceling builds

Buildkite Pipelines provides several ways to cancel builds and jobs, either automatically or manually.

## Cancel running intermediate builds

Sometimes you may push several commits in quick succession, leading to Buildkite Pipelines building each commit in turn. You can configure your pipeline to cancel these running builds and only build the latest commit.

When a new build is created on a branch, Buildkite Pipelines checks for earlier builds on the same branch that are running, and cancels them. A build is running when it is in one of these states:

- _started_
- _failing_
- _blocked_, when the build is paused at a [block step](/docs/pipelines/configure/step-types/block-step) whose `blocked_state` attribute is `running`. The build is canceled even if none of its jobs are running.

This check applies to all new builds, however they are created (for example, from a push, the API, the Buildkite dashboard, or a schedule). The check does not affect builds that are queued but have not started yet. The check also does not affect builds paused at a block step whose `blocked_state` attribute is `passed` (the default) or `failed`. For information on how to skip queued builds, see [Skip intermediate builds](/docs/pipelines/configure/skipping#skip-queued-intermediate-builds).

To cancel running builds on the same branch:

1. Navigate to your pipeline's **Settings**.
1. Select **Builds**.
1. Select **Cancel Intermediate Builds**.
1. (Optional) Limit which branches build canceling applies to by adding branch patterns in the text box below **Cancel Intermediate Builds**. Separate each pattern with a space. For example, `branch-one` means Buildkite Pipelines only cancels intermediate builds on `branch-one`, and `!main` cancels intermediate builds on all branches except `main`. You can also use wildcards, for example, `main stable-* !unstable`. For more examples, see [Branch configuration](/docs/pipelines/configure/workflows/branch-configuration).

You can also configure these options using the [REST API](/docs/apis/rest-api/pipelines#create-a-yaml-pipeline).

> 🚧 **Cancel Intermediate Builds** checks one time for each new build
> Creating a new build triggers the check. The check runs a short time after the new build is created, and cancels the earlier builds that are running at that time. The check does not run again when the new build starts running. If an earlier build starts or restarts after the check has run (for example, because the earlier build was queued, or because a job was retried), then the earlier build is not canceled. The next new build on the branch cancels the earlier build if it is still running.
> To also stop queued builds before they start, turn on [**Skip Intermediate Builds**](/docs/pipelines/configure/skipping#skip-queued-intermediate-builds).

## Manually cancel a job

If your pipeline has multiple command steps, you can manually cancel a step, which will cause the build to fail.

If you do _not_ want the build to fail when you cancel a specific step, you can set [`soft_fail`](/docs/pipelines/configure/soft-fail).

To manually cancel a job:

1. From your Buildkite dashboard, select your pipeline.
2. Select the running build.
3. Select the job (step) you want to cancel.
4. Select **Cancel**.

## Cancel a build using the agent CLI

You can cancel a build using the [`buildkite-agent build cancel` command](/docs/agent/cli/reference/build#canceling-a-build). This is a job-level command, meaning it runs within the context of a job and authenticates using the `$BUILDKITE_AGENT_ACCESS_TOKEN` environment variable that Buildkite Pipeline automatically provides to every running job—on both [self-hosted](/docs/agent/self-hosted) and [Buildkite hosted](/docs/agent/buildkite-hosted) agents.

```shell
buildkite-agent build cancel
```

This cancels the build associated with the current job's context. You can also target a specific build using the [`--build` flag](/docs/agent/cli/reference/build#build) with the build UUID, or by setting the `$BUILDKITE_BUILD_ID` environment variable.

This command is typically called from within a pipeline step script. If you are using Buildkite hosted agents, you can also run the command interactively from a [terminal session](/docs/agent/buildkite-hosted/terminal-access) open on a running job. This is a separate browser-based feature for investigating the job environment.

## Cancel reasons

When a build is canceled, Buildkite Pipelines records why. The reason is returned in the `cancel_reason` field of the [REST API build data model](/docs/apis/rest-api/builds#build-data-model) and in the `cancelReason` field of the [GraphQL API build object](/docs/apis/graphql/schemas/object/build). Use this value to tell builds that people canceled apart from builds that Buildkite Pipelines canceled automatically.

<table class="responsive-table">
  <thead>
    <tr>
      <th style="width:40%">Cancel reason</th>
      <th style="width:60%">Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>user_canceled_via_ui</code></td>
      <td>A user canceled the build from the Buildkite dashboard.</td>
    </tr>
    <tr>
      <td><code>user_canceled_via_api</code></td>
      <td>A user canceled the build using the <a href="/docs/apis/rest-api/builds#cancel-a-build">REST API</a> or the GraphQL API.</td>
    </tr>
    <tr>
      <td><code>build_skipping</code></td>
      <td>A newer build was created on the same branch, and the pipeline has <a href="#cancel-running-intermediate-builds"><strong>Cancel Intermediate Builds</strong></a> turned on. Despite its name, this value is not set by <strong>Skip Intermediate Builds</strong>.</td>
    </tr>
    <tr>
      <td><code>branch_deleted</code></td>
      <td>The branch was deleted from GitHub, and the pipeline has the <strong>Cancel deleted branch builds</strong> <a href="/docs/pipelines/source-control/github#running-builds-on-pull-requests">GitHub setting</a> turned on.</td>
    </tr>
    <tr>
      <td><code>merge_group_destroyed</code></td>
      <td>GitHub invalidated the build's merge group, and the pipeline has <strong>Cancel builds for destroyed merge groups</strong> turned on. Learn more in <a href="/docs/pipelines/tutorials/github-merge-queue#understanding-merge-queue-behavior-automatic-cancellation-of-redundant-builds">Automatic cancellation of redundant builds</a>.</td>
    </tr>
    <tr>
      <td><code>maximum_lifetime_reached</code></td>
      <td>The build reached its maximum lifetime before it finished. A build paused at a <a href="/docs/pipelines/configure/step-types/block-step">block step</a> is only canceled when the step's <code>blocked_state</code> attribute is <code>running</code>. Otherwise, the build finishes as <em>passed</em> or <em>failed</em>.</td>
    </tr>
    <tr>
      <td><code>organization_locked</code></td>
      <td>Buildkite canceled the build because the Buildkite organization was locked, for example, during a data migration.</td>
    </tr>
    <tr>
      <td><code>by_staff</code></td>
      <td>Buildkite staff canceled the build.</td>
    </tr>
    <tr>
      <td><code>Agent canceled via job &lt;job-id&gt;</code></td>
      <td>A job ran the <a href="#cancel-a-build-using-the-agent-cli"><code>buildkite-agent build cancel</code> command</a>. The value includes the ID of that job.</td>
    </tr>
    <tr>
      <td><code>null</code></td>
      <td>No reason was recorded for the cancellation.</td>
    </tr>
  </tbody>
</table>
