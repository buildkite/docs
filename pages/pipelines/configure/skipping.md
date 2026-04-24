# Skipping builds

Build skipping allows you to avoid unnecessary rebuilds, conserving resources and freeing up agents.

## Skip queued intermediate builds

Sometimes you may push several commits in quick succession, leading to Buildkite building each commit in turn. You can configure your pipeline to always skip these intermediate builds, and only build the latest commit.

To skip pending builds on the same branch:

1. Navigate to your pipeline's **Settings**.
1. Select **Builds**.
1. Select **Skip Intermediate Builds**.
1. (Optional) Limit which branches build skipping applies to by adding branch names in the text box below **Skip Intermediate Builds**. For example, "branch-one" means Buildkite only skips intermediate builds on branch-one. You can also use not-equals: "!main" skips intermediate builds on all branches except main.

You can also configure these options using the [REST API](/docs/apis/rest-api/pipelines#create-a-yaml-pipeline).

## Ignore a commit

Some code changes, such as editing a Readme, may not require a Buildkite build. If you want Buildkite to ignore a commit, add `[ci skip]`,`[skip ci]`, `[ci-skip]`, or `[skip-ci]` anywhere in the commit message.

If pull request events are enabled for a given pipeline, when a pull request is created, a build will also be triggered unless `[ci skip]`,`[skip ci]`, `[ci-skip]`, or `[skip-ci]` is added to the pull request title.

> 📘
> When squashing commits in a merge, any commit message that contains `[skip ci]` will be included in the squashed commit message. This means that the merge will not trigger a build.
> In order to avoid this and have the merge trigger a build, you should remove the commit containing `[skip ci]` from the squashed commit message.

For example, the following commit message will cause Buildkite to ignore the commit and not create a corresponding build:

```
Fix readme typos [skip ci]
```

Multi-line commit messages are also supported. For example, the following commit message will also cause Buildkite to ignore the commit:

```
Fix readme typos

* Fixed the build badge
* Fixed broken GitHub link

[skip ci]
```

For more advanced build filtering and commit skipping, see the [Using conditionals](/docs/pipelines/configure/conditionals) guide.

> 🚧 Skipping commits with Bitbucket Server
> Not all webhooks from Bitbucket Server contain the commit message. When a commit message is not included in a webhook, the build will run.

## Ignore pull requests

You can skip pull requests by adding `[ci skip]`, `[skip ci]`, `[ci-skip]`, or `[skip-ci]` anywhere in the title of a pull request. Refer to [Running builds on pull requests](/docs/pipelines/source-control/github#running-builds-on-pull-requests) for more information.

## Ignore branches

You can choose to always ignore certain branches. Refer to [Branch configuration](/docs/pipelines/configure/workflows/branch-configuration) for more information.

## Skip builds using conditionals

You can use conditionals to skip builds at both the pipeline and step level. Refer to [Conditionals](/docs/pipelines/configure/conditionals) for more information.

## Skip builds with existing commits

Sometimes you don't want to trigger a new build for a commit that's already passed validation, regardless of the branch. For example, when [using merge queues in GitHub](/docs/pipelines/tutorials/github-merge-queue).

To skip a build with existing commits:

1. From your Buildkite dashboard, select your pipeline.
1. Select **Settings** > **GitHub**.
1. In the **GitHub Settings** section, select the **Skip builds with existing commits** checkbox.
