# Canceling builds

Buildkite Pipelines provides several ways to cancel builds and jobs, either automatically or manually.

## Cancel running intermediate builds

Sometimes you may push several commits in quick succession, leading to Buildkite Pipelines building each commit in turn. You can configure your pipeline to always cancel any running builds, and only build the latest commit.

To cancel running builds on the same branch:

1. Navigate to your pipeline's **Settings**.
1. Select **Builds**.
1. Select **Cancel Intermediate Builds**.
1. (Optional) Limit which branches build canceling applies to by adding branch names in the text box below **Cancel Intermediate Builds**. For example, "branch-one" means Buildkite Pipelines only cancels intermediate builds on branch-one. You can also use not-equals: "!main" cancels intermediate builds on all branches except main.

You can also configure these options using the [REST API](/docs/apis/rest-api/pipelines#create-a-yaml-pipeline).

> 🚧 Using **Cancel Intermediate Builds** and re-running earlier builds
> If an earlier build has started running again (for example, due to a job being retried) while the newest build is already running, then this earlier build will not be canceled.
> If, however, an earlier build has started running again _before_ a new build starts running, then the earlier build will be canceled.

## Manually cancel a job

If your pipeline has multiple command steps, you can manually cancel a step, which causes the build to fail.

If you do _not_ want the build to fail when you cancel a specific step, you can set [`soft_fail`](/docs/pipelines/configure/step-types/command-step#soft-fail-attributes).

To manually cancel a job:

1. From your Buildkite dashboard, select your pipeline.
2. Select the running build.
3. Select the job (step) you want to cancel.
4. Select **Cancel**.

## Cancel a build using the agent CLI

You can cancel a build using the [`buildkite-agent build cancel` command](/docs/agent/cli/reference/build#canceling-a-build). This is a job-level command, meaning it runs within the context of a job and authenticates using the `$BUILDKITE_AGENT_ACCESS_TOKEN` that Buildkite automatically provides to every running job — on both [self-hosted](/docs/agent/self-hosted) and [Buildkite hosted](/docs/agent/buildkite-hosted) agents.

```shell
buildkite-agent build cancel
```

This cancels the build associated with the current job's context. You can also target a specific build using the [`--build` flag](/docs/agent/cli/reference/build#build) with the build UUID, or by setting the `$BUILDKITE_BUILD_ID` environment variable.

This command is typically called from within a pipeline step script. If you are using Buildkite hosted agents, you can also run it interactively from a [terminal session](/docs/agent/buildkite-hosted/terminal-access) open on a running job, though that is a separate browser-based feature for investigating the job environment.
