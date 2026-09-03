# Windows hosted agents

Windows hosted agents are:

- [Buildkite agents](/docs/agent) hosted by Buildkite that run on Windows Server 2022 in ephemeral virtual machines.

- Configured as part of a _Buildkite hosted queue_, where the machine type is Windows, with a particular [size](#sizes) to efficiently manage jobs with varying requirements.

> 📘 Private preview feature
> Windows hosted agents are currently in private preview and must be enabled for your Buildkite organization. To request access, contact the Buildkite Support team at [support@buildkite.com](mailto:support@buildkite.com).

Learn more about:

- Best practices for configuring queues in [How should I structure my queues](/docs/pipelines/security/clusters#clusters-and-queues-best-practices-how-should-i-structure-my-queues) of the [Clusters overview](/docs/pipelines/security/clusters), as well as [Manage queues](/docs/agent/queues/managing).

- How to configure Windows hosted agents in [Create a Buildkite hosted queue](/docs/agent/queues/managing#create-a-buildkite-hosted-queue).

- The [concurrency](#concurrency), [security](#security), and [current limitations](#current-limitations) of Windows hosted agents.

## Sizes

Windows hosted agents support the AMD64 architecture in four instance shapes:

<%= render_markdown partial: 'shared/buildkite_hosted_agents/instance_shape_table_windows' %>

## Base image

Windows hosted agents use a fixed, Buildkite-managed Windows Server 2022 base image. Windows hosted queues don't support the base image configuration available for [Linux](/docs/agent/buildkite-hosted/linux#agent-images) and [macOS](/docs/agent/buildkite-hosted/macos#macos-instance-software-support) hosted queues. A Windows hosted queue's settings page doesn't display a **Base Image** tab.

Each job runs in a new virtual machine. After the job finishes, Buildkite destroys the virtual machine and its data.

## Concurrency

Windows hosted agents can operate concurrently when running your Buildkite pipeline jobs.

<%= render_markdown partial: 'agent/buildkite_hosted/hosted_agents_concurrency_explanation' %>

The number of Windows hosted agents that can process jobs concurrently depends on the Windows vCPU concurrency allocated to your organization and the [instance shape](#sizes) configured for the queue.

When a job would exceed the allocated concurrency, it remains queued until sufficient capacity is available.

## Security

Each Windows job runs in an isolated virtual machine that Buildkite destroys, together with its data, after the job completes.

## Current limitations

Windows hosted agents don't currently support:

- Custom base images.
- [Cache volumes](/docs/agent/buildkite-hosted/cache-volumes).
- [Terminal access](/docs/agent/buildkite-hosted/terminal-access) using SSH.
- [Desktop access](/docs/agent/buildkite-hosted/desktop-access) using VNC or Remote Desktop.
- ARM64 architecture.
- Windows Server 2025.
- Selecting a Windows shell in the queue settings.
- Selecting or managing the Buildkite agent version.
- Windows jobs through the [GitHub Actions compatibility feature](/docs/pipelines/migration/run-github-actions-workflows).
