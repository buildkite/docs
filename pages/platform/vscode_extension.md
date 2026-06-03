# Visual Studio Code extension

The [Buildkite VS Code extension](https://marketplace.visualstudio.com/items?itemName=Buildkite.buildkite) lets you manage your pipelines, builds, jobs, and agents directly from Visual Studio Code without switching to the Buildkite web interface. The extension is [open source and available on GitHub](https://github.com/buildkite/vscode-buildkite).

## Requirements

Visual Studio Code 1.60 or later.

## Installation

Install the extension from the [Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=Buildkite.buildkite). The [YAML Language Support by Red Hat](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) extension is installed automatically as a dependency, which enables pipeline YAML validation.

## Authentication

The extension uses OAuth to authenticate with Buildkite. When you first open a Buildkite panel or run **Buildkite: Sign In** from the Command Palette, you are prompted to sign in with your browser. This opens buildkite.com where you authorize the extension, and you are then returned to VS Code automatically.

To sign out, run **Buildkite: Sign Out** from the Command Palette.

> [!NOTE]
> If you prefer to use a [Buildkite API access token](/docs/apis/managing-api-tokens) instead, select **Use API Token** when prompted, or run **Buildkite: Set API Token** from the Command Palette. An API token and an OAuth session can coexist; the OAuth session takes priority. To remove a stored API token, run **Buildkite: Clear API Token**.

## Pipelines panel

The Buildkite activity bar icon opens a sidebar with three panels. The **Pipelines** panel shows a tree view of your pipelines and their recent builds.

Each pipeline shows up to 10 of its most recent builds. Builds in an active state (running, scheduled, or being created) refresh automatically every 60 seconds. Each build shows its individual jobs, including their status.

The following actions are available from the **Pipelines** panel:

- **View on Buildkite** — opens the build in your browser
- **Rebuild** — triggers a new build with the same configuration
- **Create a build** — creates a build on the current git branch
- **Cancel build** — cancels a running or scheduled build
- **Unblock next job** — unblocks a build waiting at a block step; if the block step defines input fields, you are prompted to fill them in before the build continues
- **View build error** — shows the log for the failed job; if multiple jobs failed, a quick picker lets you choose which to view
- **View annotations** — displays build annotations in a panel
- **View job log** — opens the job log in VS Code with ANSI color support (see [Job logs](#job-logs))
- **Retry job** — retries a failed or timed-out job
- **Download artifact** — downloads a build artifact to your local machine

### Managing pipelines

Right-click any pipeline in the tree to access pipeline management actions:

- **Edit pipeline settings** — update the pipeline name, description, default branch, or repository URL
- **Create pipeline** — add a new pipeline by entering its name, repository URL, and optionally a description and default branch
- **Archive pipeline** — hides the pipeline from the active list
- **Unarchive pipeline** — restores an archived pipeline
- **Delete pipeline** — permanently deletes the pipeline (requires confirmation)

## Agents panel

The **Agents** panel lists your organization's connected agents and their current status (connected, running, paused, or idle). The following actions are available per agent:

- **Pause** — prevents the agent from accepting new jobs
- **Resume** — allows a paused agent to accept jobs again
- **Stop** — gracefully stops the agent after its current job completes
- **Force stop** — immediately terminates the agent

To narrow the list, select the filter icon in the panel toolbar and enter a query. You can filter by agent name, hostname, or queue tag (for example, `queue=deploy`). Select the close icon to clear an active filter.

## Support panel

The **Support** panel provides a search field for querying the Buildkite documentation, along with links to contact support and raise issues against the extension on GitHub.

You can also run **Buildkite: Search Docs** from the Command Palette to search documentation directly and open results in your browser.

## Job logs

To view a job's log output inside VS Code, right-click the job in the **Pipelines** panel and select **View Job Log in Output**. The log renders with ANSI color codes and shows the pipeline name, build number, and job name as context.

To open the log in your browser instead, select **Open Job Log in Browser**.

## Status bar

The extension adds a status indicator to the VS Code status bar that shows the build status for the pipeline associated with your current workspace. It identifies the matching pipeline by reading your git remote URL and comparing it against your Buildkite pipelines.

The status bar updates every 60 seconds. Clicking it opens a quick picker to switch between matched pipelines. Use the keyboard shortcut `Cmd+Alt+P` (macOS) or `Ctrl+Alt+P` (Windows and Linux) to open the same quick picker.

By default, the status bar is hidden when no matching pipeline is found. To show it regardless, set `buildkite.statusBar.showWhenNoMatch` to `true` in your VS Code settings.

## Build notifications

The extension sends a notification when a build completes. Notifications are enabled by default for both passing and failing builds.

## Pipeline YAML validation

The extension automatically validates `.buildkite/pipeline.yml` (and related pipeline files) against the official Buildkite pipeline schema from [SchemaStore](https://www.schemastore.org/). This provides real-time validation, context-aware autocomplete, and hover documentation as you edit pipeline files. No configuration is required.

