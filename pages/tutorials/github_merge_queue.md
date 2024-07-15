---
keywords: docs, pipelines, tutorials, github merge queues
---

# Using GitHub merge queues

> 🚧 GitHub beta feature
> The merge queue feature for pull requests is in public beta and subject to change.

Merge queues are a feature of GitHub to improve development velocity on busy branches. They can increase the rate at which pull requests are merged into a branch while ensuring all the required branch protection checks pass. Merge queues preserve the order of pull requests to merge, remove redundant builds, and reduce flaky merges.

## Before you start

Familiarize yourself with [managing a merge queue in GitHub](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue).

## Enable a merge queue for a pipeline

The merge queue creates temporary branches with a special prefix to validate pull request changes. You need to update the pipeline configuration to match branches with the special prefix if you are already using [branch filters](/docs/pipelines/branch-configuration#pipeline-level-branch-filtering). To avoid these temporary branches triggering multiple builds on the same pipeline for the same commit, it is recommended you enable the option to skip builds on existing commits.

To enable a merge queue for a pipeline:

1. From your Buildkite dashboard, select your pipeline.
1. Select **Pipeline Settings** > **GitHub**.
1. In the **GitHub Settings** section, select the **Skip builds with existing commits** checkbox.
1. If you are already using branch filters in the **Branch Limiting** section, add another filter for the following pattern:

   ```text
   gh-readonly-queue/{base_branch}/*
   ```

   Otherwise, leave the branch filter text box blank, and builds will be triggered for GitHub merge queue branches automatically.

That's it! Your pipeline supports merge queues in GitHub. 🎉
