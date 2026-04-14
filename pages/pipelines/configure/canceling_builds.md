# Canceling builds

Buildkite Pipelines provides several ways to cancel builds and jobs, either automatically or manually.

## Cancel running intermediate builds

Sometimes you may push several commits in quick succession, leading to Buildkite Pipelines building each commit in turn. You can configure your pipeline to always cancel any running builds, and only build the latest commit.

To cancel running builds on the same branch:

1. Navigate to your pipeline's **Settings**.
1. Select **Builds**.
1. Select **Cancel Intermediate Builds**.
1. (Optional) Limit which branches build canceling applies to by adding branch names in the text box below **Cancel Intermediate Builds**. For example, "branch-one" means Buildkite only cancels intermediate builds on branch-one. You can also use not-equals: "!main" cancels intermediate builds on all branches except main.

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
