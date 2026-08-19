# Hosted agents desktop access

Buildkite hosted agents provide browser-based _desktop access_ to running jobs on [macOS hosted agents](/docs/agent/buildkite-hosted/macos). This feature opens a live remote desktop for a job, alongside the existing [terminal access](/docs/agent/buildkite-hosted/terminal-access) feature, without requiring any local port forwarding or additional software.

Desktop access is useful for:

- Visually inspecting a macOS build or test run as it happens.
- Debugging UI tests and simulator or device interactions that are hard to diagnose from logs alone.
- Interacting directly with applications and tools that require a graphical environment.

> 📘 Limited availability
> Desktop access for hosted agents is being rolled out to Buildkite organizations. If the **Open Desktop** button described below isn't available for your organization, contact Buildkite Support at [support@buildkite.com](mailto:support@buildkite.com).

## Use desktop access in the Buildkite interface

Desktop access is available for currently running jobs on macOS hosted agents. [Remote access must be active across your Buildkite organization](/docs/agent/buildkite-hosted/terminal-access#deactivate-and-reactivate-remote-access-on-hosted-agents). You also need permission to manage hosted agents in your Buildkite organization.

To open a job's desktop:

1. While a pipeline is building, expand the relevant step and wait for its job to start running on a macOS hosted agent.
1. Select the job's **Open Desktop** button, next to its **Open Terminal** button.

A new browser tab opens and connects to the job's remote desktop. The desktop scales to fit the browser window, and resizes automatically as the window changes size. Mouse and keyboard input in the browser tab are sent directly to the remote desktop.

Each desktop session uses a short-lived access token that is created on demand. The response containing the access token and VNC credentials is not cached.

The **Open Desktop** button only appears for jobs running on macOS hosted agents, not for jobs on Linux hosted agents or self-hosted agents.

## Use desktop access from the Buildkite CLI

Buildkite CLI version 3.55.0 and later provides the `bk job vnc` command. Use the command to connect a local VNC client to a running macOS hosted job:

```bash
bk job vnc 0190046e-e199-453b-a302-a21a4d649d31
```

The command requests a short-lived access token and opens a local port on your computer. It then opens the VNC client registered with your operating system and proxies the connection until the client disconnects. You don't need to configure port forwarding.

Before running the command:

- [Configure the Buildkite CLI](/docs/platform/cli/configuration) with your Buildkite organization and an API access token that has the `write_builds` scope.
- Confirm that [remote access is active](/docs/agent/buildkite-hosted/terminal-access#deactivate-and-reactivate-remote-access-on-hosted-agents) for your Buildkite organization.
- Find the UUID of a running command job on a macOS hosted agent.
- Confirm that you have permission to manage hosted agents for the job.

The `bk job vnc` command does not support Linux hosted jobs or self-hosted jobs.
