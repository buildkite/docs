---
keywords: docs, pipelines, tutorials, github merge queues
---

# Using GitHub merge queues

Merge queues are a feature of GitHub to improve development velocity on busy branches. They automate the merging for pull requests while protecting the branch from failure due to incompatibilities introduced by different pull requests.

Buildkite supports creating builds for pull requests in a GitHub merge queue, and can automatically cancel redundant builds when the composition of the merge queue changes. These builds are uniquely identified in the Buildkite UI, and the behavior of the pipeline can be manipulated based on conditionals and environment variables that identify it as a merge queue build.

## Before you start

Familiarize yourself with [managing a merge queue in GitHub](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue).

## Enable merge queue builds for a pipeline

To enable merge queue builds for a pipeline:

1. From your Buildkite dashboard, select your pipeline.
1. Select **Pipeline Settings** > **GitHub**.
1. In the **GitHub Settings** section, select the **Build merge queues** checkbox.

<%= image "build-merge-queues-setting.png", alt: "Enabling merge queue builds in a pipeline's GitHub settings" %>
> 🚧 Ensure GitHub webhook has _Merge groups_ events enabled
> Buildkite relies on receiving `merge_group` webhook events from GitHub to create builds for merge groups in the merge queue. Ensure your pipeline's [webhook](/docs/pipelines/source-control/github#set-up-a-new-pipeline-for-a-github-repository) has the _Merge groups_ event enabled before enabling merge queue builds.

That's it! Your pipeline now supports merge queues in GitHub. 🎉

## Understanding merge queue behavior

When a GitHub Pull Request (PR) is added to the merge queue, a "merge group" is created. A merge group contains the changes for that PR, along with changes belonging to any PR ahead of it in the merge queue.

Each merge group is based on the HEAD commit of the merge group ahead of it in the queue, and the merge group at the front of the queue is based on the HEAD commit of the target branch.

<%= image "relationship-between-merge-groups.png", class: "invertible", alt: "The relationship between merge groups in a GitHub merge queue" %>

The HEAD commit of a merge group is a speculative commit constructed based on the _Merge method_ setting of the merge queue in GitHub. This commit is the exact commit that will end up on the target branch _if_ the merge group is successfully merged into the target branch.

### Builds created for merge groups

Every time GitHub creates a merge group, two webhook events are sent that Buildkite might respond to:

1. A `push` webhook event for the temporary `gh-readonly-queue/*` branch that was created.
1. A `merge_group` webhook event for the merge group.

If **Build branches** is enabled for the pipeline, then Buildkite will by default respond to the `push` event by creating a build for the temporary branch. These builds will be no different to a build created for any other branch.

However, if **Build merge queues** is enabled, the `push` event will be ignored and instead Buildkite will respond to the `merge_group` event by creating a "merge queue build" that captures additional properties about that merge group:

<%= image "mapping-of-merge-group-to-a-build.png", class: "invertible", alt: "The mapping between a merge group and a build" %>
These properties are exposed as [conditionals](/docs/pipelines/configure/conditionals#variable-and-syntax-reference) and [environment variables](/docs/pipelines/configure/environment-variables#buildkite-environment-variables) in the build:

Property          | Conditional                      | Environment variable
----------------- | -------------------------------- | --------------------------------
base_sha          | `build.merge_queue.base_commit`  | `BUILDKITE_MERGE_QUEUE_BASE_COMMIT`
base_ref          | `build.merge_queue.base_branch`  | `BUILDKITE_MERGE_QUEUE_BASE_BRANCH`
head_sha          | `build.commit`                   | `BUILDKITE_COMMIT`
head_ref          | `build.branch`                   | `BUILDKITE_BRANCH`
{: class="responsive-table"}

> 📘 Skipping builds
> [Skipping a build](/docs/pipelines/configure/skipping) is not supported for merge queue builds, as GitHub expects every merge group commit to receive a commit status update.<br />
> However, you can still use [conditionals](/docs/pipelines/configure/conditionals#conditionals-in-steps) to prevent steps from running inside of a merge queue build.

### Listing merge queue builds

Merge queue builds are listed separately at the top of the pipeline page:

<%= image "merge-queue-builds-list.png", alt: "Merge queue builds listed at the top of a pipeline" %>
This listing reflects all builds created for the merge queue, it is not representative of the current state of the merge queue in GitHub. For example, if a pull request is removed from the merge queue, the corresponding build will remain visible in Buildkite.

### Failing builds in a merge queue

Builds for merge groups can post [commit status updates](/docs/pipelines/source-control/github#customizing-commit-statuses) like any other build:

<%= image "failing-build-in-merge-queue.png", class: "invertible", alt: "A failing build in the merge queue" %>

If that commit status is a required check for the merge queue, then a "failing" (or "failed") update will cause GitHub to remove the corresponding pull request from the merge queue.

> 🚧 Behavior may differ based on GitHub merge queue settings
> If you've disabled the _Require all queue entries to pass required checks_ setting on the merge queue in GitHub, then a failing build will not always cause the pull request to be removed from the merge queue immediately.<br />
> Instead GitHub will first wait to see if the build for any merge group behind it in the queue succeeds. This option is intended to prevent flaky test failures from causing pull requests to be removed from the merge queue unnecessarily.

When this happens the merge groups for any merge groups behind it in the queue will be "invalidated" and replaced with new merge groups that exclude the removed pull request.

<%= image "dequeueing-and-invalidation-of-merge-groups.png", class: "invertible", alt: "Dequeueing and invalidation of merge groups after a build failure" %>

This will result in a new build being created for the newly created merge group:

<%= image "after-merge-queue-changes.png", class: "invertible", alt: "A new build created after changes to the merge queue" %>

### Automatic cancellation of redundant builds

When a merge group is invalidated, GitHub sends a `merge_group` webhook event that Buildkite can respond to by cancelling any running build for that merge group. Select **Cancel builds for destroyed merge groups** in the pipeline's GitHub settings to enable this behavior.

<%= image "merge-queue-cancel-builds-setting.png", alt: "Setting to enable automatic cancellation of builds for destroyed merge groups" %>

### Interaction with if_changed agent behavior

The agent [supports an `if_changed` attribute](/docs/agent/cli/reference/pipeline#apply-if-changed) that allows steps to be conditionally included in a build based on the files changed in the commit range for that build.

By default for merge queue builds this commit range will be the range of commits between the HEAD of the target branch and the HEAD of the merge group the build is for. That means it will also consider file changes from merge groups ahead of the build's merge group in the queue.

If your merge queue has the _Require all queue entries to pass required checks_ setting enabled, it is safe for `if_changed` to consider only the file changes belonging to the PR the merge group is for. Select **Use base commit when making `if_changed` comparisons** in the pipeline's GitHub settings to enable this behavior.

<%= image "merge-queue-if-changed-setting.png", alt: "Setting to enable `if_changed` to consider only the file changes belonging to the PR the merge group is for" %>

### After merge groups are merged

When a series of merge groups are successfully merged, GitHub fast-forwards the target branch of the queue to the HEAD of the last merge group being merged.

GitHub sends a `push` webhook event for the updated target branch and a build will be created if **Build branches** is enabled in the pipeline's GitHub settings.

The creation of this build can be avoided by [skipping existing commits](/docs/pipelines/configure/skipping#skip-builds-with-existing-commits) or applying [branch filtering](https://buildkite.com/docs/pipelines/configure/workflows/branch-configuration#pipeline-level-branch-filtering).
