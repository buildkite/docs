# Canceling builds

Buildkite Pipelines provides several ways to cancel builds and jobs, either automatically or manually.

## Cancel running intermediate builds

Sometimes you may push several commits in quick succession, leading to Buildkite Pipelines building each commit in turn. You can configure your pipeline to cancel these running builds and only build the latest commit.

When a new build is created on a branch, Buildkite Pipelines cancels the earlier builds on the same branch that are running at that time. A build is running when it is in one of these states:

- _started_
- _failing_
- _blocked_, while other jobs in the build are still running

This check applies to all new builds, however they are created (for example, from a push, the API, the Buildkite dashboard, or a schedule). The check does not affect builds that are queued but have not started yet, or builds that have stopped at a block step with no running jobs. For information on how to skip queued builds, see [Skip intermediate builds](/docs/pipelines/configure/skipping#skip-queued-intermediate-builds).

To cancel running builds on the same branch:

1. Navigate to your pipeline's **Settings**.
1. Select **Builds**.
1. Select **Cancel Intermediate Builds**.
1. (Optional) Limit which branches build canceling applies to by adding branch patterns in the text box below **Cancel Intermediate Builds**. Separate each pattern with a space. For example, `branch-one` means Buildkite Pipelines only cancels intermediate builds on `branch-one`, and `!main` cancels intermediate builds on all branches except `main`. You can also use wildcards, for example, `main stable-* !unstable`. For more examples, see [Branch configuration](/docs/pipelines/configure/workflows/branch-configuration).

You can also configure these options using the [REST API](/docs/apis/rest-api/pipelines#create-a-yaml-pipeline).

> 🚧 **Cancel Intermediate Builds** checks one time, when a new build is created
> Buildkite Pipelines checks for running builds only at the time the new build is created, not when the new build starts running. If an earlier build starts or restarts after the new build is created (for example, because the earlier build was queued, or because a job was retried), then the earlier build is not canceled. The next new build on the branch cancels the earlier build if it is still running.
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
