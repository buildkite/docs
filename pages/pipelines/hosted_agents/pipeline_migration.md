# Hosted agents pipeline migration

To migrate an existing pipeline to use a hosted agents queue, you must first ensure:

- Your pipeline is in the same cluster as all the hosted agent queues you wish to target.
- Each step in the pipeline targets the required hosted agent queue.
- Source control settings have been updated to allow code access.

An additional process is required for private private repositories, see below for the relevant instructions.

## Private repository

To set your pipeline to use the _GitHub (with code access)_ service:

1. Ensure you have followed the instructions in [Private repositories](/docs/pipelines/hosted-agents/code-access#private-repositories) (on the [Hosted agents code access](/docs/pipelines/hosted-agents/code-access) page) for your pipeline's GitHub repository.
1. Navigate to your pipeline settings.
1. Select GitHub from the left menu.
1. Remove the existing repository, or select the _Choose another repository or URL_ link
1. Select the GitHub account including ...(with code access).
1. Select the repository.
1. Select _Save Repository_.

## All repositories

When accessing any repository (public or private) from a Buildkite hosted agent, you must also ensure the repository is checked out using `HTTPS`.

1. Navigate to your pipeline settings.
1. Select _GitHub_ from the left menu.
1. Change the _Checkout using_ to `HTTPS`.
