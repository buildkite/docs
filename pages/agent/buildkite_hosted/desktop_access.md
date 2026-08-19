# Hosted agents desktop access

Buildkite hosted agents provide browser-based _desktop access_ to running jobs on [macOS hosted agents](/docs/agent/buildkite-hosted/macos). This feature opens a live remote desktop for a job, alongside the existing [terminal access](/docs/agent/buildkite-hosted/terminal-access) feature, without requiring any local port forwarding or additional software.

Desktop access is useful for:

- Visually inspecting a macOS build or test run as it happens.
- Debugging UI tests and simulator or device interactions that are hard to diagnose from logs alone.
- Interacting directly with applications and tools that require a graphical environment.

> 📘 Limited availability
> Desktop access for hosted agents is being rolled out to Buildkite organizations. If the **Open Desktop** button described below isn't available for your organization, contact Buildkite Support at [support@buildkite.com](mailto:support@buildkite.com).

## Use desktop access on hosted agents

Desktop access is available for currently running jobs on macOS hosted agents. [Terminal access must be active across your Buildkite organization](/docs/agent/buildkite-hosted/terminal-access#deactivate-and-reactivate-terminal-access-on-hosted-agents). You also need permission to manage hosted agents in your Buildkite organization.

To open a job's desktop:

1. While a pipeline is building, expand the relevant step and wait for its job to start running on a macOS hosted agent.
1. Select the job's **Open Desktop** button, next to its **Open Terminal** button.

A new browser tab opens and connects to the job's remote desktop. The desktop scales to fit the browser window, and resizes automatically as the window changes size. Mouse and keyboard input in the browser tab are sent directly to the remote desktop.

Each desktop session uses a short-lived access token that is created on demand. The response containing the access token and VNC credentials is not cached.

The **Open Desktop** button only appears for jobs running on macOS hosted agents, not for jobs on Linux hosted agents or self-hosted agents.
