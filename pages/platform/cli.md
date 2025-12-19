# The Buildkite CLI

The Buildkite CLI is a command-line interface (CLI) tool for interacting directly with Buildkite itself. This tool provides command line/terminal access to work with a subset of Buildkite's features, as you normally would through Buildkite's web interface.

Using the Buildkite CLI, you can view builds, create and cancel builds, unblock jobs, stop agents, along with several other actions.

## Installation

The Buildkite CLI can be installed on all major platforms. Learn more about how to install the tool on your platform in [Buildkite CLI installation](/docs/platform/cli/installation).

## Usage

<div class="highlight">
<pre class="highlight shell">
<code>$ bk
Usage: bk <command> [flags]

Work with Buildkite from the command line.

Flags:
  -h, --help        Show context-sensitive help.
  -y, --yes         Skip all confirmation prompts
      --no-input    Disable all interactive prompts
  -q, --quiet       Suppress progress output

Commands:
  agent pause <agent-id> [flags]
    Pause a Buildkite agent.

  agent list [flags]
    List agents.

  agent resume <agent-id>
    Resume a Buildkite agent.

  agent stop [<agents> ...] [flags]
    Stop Buildkite agents.

  agent view <agent> [flags]
    View details of an agent.

  api [<args> ...] [flags]
    Interact with the Buildkite API

  artifacts download <artifact-id>
    Download an artifact by its UUID.

  artifacts list [<build-number>] [flags]
    List artifacts for a build or a job in a build.

  build create (new) [flags]
    Create a new build.

  build cancel <build-number> [flags]
    Cancel a build.

  build view [<build-number>] [flags]
    View build information.

  build list [flags]
    List builds.

  build download [<build-number>] [flags]
    Download resources for a build.

  build rebuild [<build-number>] [flags]
    Rebuild a build.

  build watch [<build-number>] [flags]
    Watch a build's progress in real-time.

  cluster list [flags]
    List clusters.

  cluster view <cluster-id> [flags]
    View cluster information.

  configure [<args> ...] [flags]
    Configure Buildkite API token

  init [<args> ...] [flags]
    Initialize a pipeline.yaml file

  job cancel <job-id> [flags]
    Cancel a job.

  job list [flags]
    List jobs.

  job retry <job-id>
    Retry a job.

  job unblock <job-id> [flags]
    Unblock a job.

  pipeline create <name> [flags]
    Create a new pipeline.

  pipeline list [flags]
    List pipelines.

  pipeline migrate --file=STRING [flags]
    Migrate a CI/CD pipeline configuration to Buildkite format.

  pipeline validate [flags]
    Validate a pipeline YAML file.

  pipeline view [<pipeline>] [flags]
    View a pipeline.

  package [<args> ...] [flags]
    Manage packages

  use [<args> ...] [flags]
    Select an organization

  user [<args> ...] [flags]
    Invite users to the organization

  version [<args> ...] [flags]
    Print the version of the CLI being used

  whoami [flags]
    Print the current user and organization

Run "bk <command> --help" for more information on a command.
</code>
</pre>
</div>

## Configuration

The Buildkite CLI requires an API access token to interact with Buildkite and your Buildkite organizations. Learn more about how to configure these API access tokens in [Buildkite CLI configuration](/docs/platform/cli/configuration).
