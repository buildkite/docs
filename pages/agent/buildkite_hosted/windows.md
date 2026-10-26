# Windows hosted agents

Windows hosted agents are:

- [Buildkite agents](/docs/agent) hosted by Buildkite that run on Windows Server 2022 in ephemeral virtual machines.

- Configured as part of a _Buildkite hosted queue_, where the machine type is Windows, with a particular [size](#sizes) to efficiently manage jobs with varying requirements.

> 📘 Public preview feature
> Windows hosted agents are currently in public preview and available on [Trial, Pro, and Enterprise](https://buildkite.com/pricing) plans. To provide feedback, contact the Buildkite Support team at [support@buildkite.com](mailto:support@buildkite.com).

Learn more about:

- Best practices for configuring queues in [How should I structure my queues](/docs/pipelines/security/clusters#clusters-and-queues-best-practices-how-should-i-structure-my-queues) of the [Clusters overview](/docs/pipelines/security/clusters), as well as [Manage queues](/docs/agent/queues/managing).

- How to configure Windows hosted agents in [Create a Buildkite hosted queue](/docs/agent/queues/managing#create-a-buildkite-hosted-queue).

- The [concurrency](#concurrency), [security](#security), and [current limitations](#current-limitations) of Windows hosted agents.

- Running GitHub Actions workflows on Windows hosted agents using [GitHub Actions Compatibility](/docs/pipelines/migration/run-github-actions-workflows#requirements-run-windows-jobs).

## Sizes

Windows hosted agents support the AMD64 architecture in four instance shapes:

<%= render_markdown partial: 'shared/buildkite_hosted_agents/instance_shape_table_windows' %>

Larger instance shapes are available on Enterprise plans. Contact [Buildkite Support](mailto:support@buildkite.com) to request access.

## Base image

Windows hosted agents use a fixed, Buildkite-managed Windows Server 2022 base image. Windows hosted queues don't support the base image configuration available for [Linux](/docs/agent/buildkite-hosted/linux#agent-images) and [macOS](/docs/agent/buildkite-hosted/macos#macos-instance-software-support) hosted queues. A Windows hosted queue's settings page doesn't display a **Base Image** tab.

Each job runs in a new virtual machine. After the job finishes, Buildkite destroys the virtual machine and its data.

## Concurrency

Windows hosted agents can operate concurrently when running your Buildkite pipeline jobs.

<%= render_markdown partial: 'agent/buildkite_hosted/hosted_agents_concurrency_explanation' %>

The number of Windows hosted agents (of a [Buildkite hosted queue](/docs/agent/queues/managing#create-a-buildkite-hosted-queue)) that can process your pipeline jobs concurrently is calculated by your Buildkite plan's _maximum combined vCPU_ value divided by your [instance shape's](#sizes) _vCPU_ value. See the [Buildkite pricing](https://buildkite.com/pricing/) page for details on the **Windows Concurrency** that applies to your plan.

For example, if your Buildkite plan provides you with a maximum combined vCPU value of up to 64, and you've configured a Buildkite hosted queue with the `WINDOWS_AMD64_4X16` (Medium) [instance shape](#sizes), whose vCPU value is 4, then the number of concurrent hosted agents that can run jobs on this queue is 16 (that is, 64 / 4 = 16).

When concurrency limits are exceeded, additional jobs will be queued until sufficient capacity becomes available.

## Security

Each Windows job runs in an isolated virtual machine that Buildkite destroys, together with its data, after the job completes.

## Current limitations

Windows hosted agents don't currently support:

- Custom base images
- [Cache volumes](/docs/agent/buildkite-hosted/cache-volumes)
- [Terminal access](/docs/agent/buildkite-hosted/terminal-access) using SSH
- [Desktop access](/docs/agent/buildkite-hosted/desktop-access) using VNC or Remote Desktop
- ARM64 architecture
- Nested virtualization
- Windows Server 2025
- Selecting a Windows shell in the queue settings
- Selecting or managing the Buildkite agent version

Without nested virtualization, Windows hosted agents can't run WSL2, Docker Desktop, or Windows containers with Hyper-V isolation. Docker Engine is installed on the base image and runs Windows containers with [process isolation](https://learn.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/hyperv-container).
