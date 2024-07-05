# The Buildkite CLI

The Buildkite command-line interface (CLI) is a CLI tool for interacting directly with Buildkite itself. This tool provides command line/terminal access to work with some aspects of Buildkite's features, as you normally would through Buildkite's web interface.

Using the Buildkite CLI, you can view builds, create and cancel builds, unblock jobs, stop agents, along with several other actions.

## Installation

The Buildkite CLI can be installed on all major platforms. Learn more about how to install the tool on your platform in [Buildkite CLI installation](/docs/cli/installation).

## Usage

<div class="highlight">
<pre class="highlight shell">
<code>$ bk
Work with Buildkite from the command line.

Usage:
  bk [command]

Examples:
$ bk build view


Available Commands:
  agent       Manage agents
  build       Manage pipeline builds
  cluster     Manage organization clusters
  completion  Generate the autocompletion script for the specified shell
  configure   Configure Buildkite API token
  help        Help about any command
  init        Initialize a pipeline.yaml file
  job         Manage jobs within a build
  pipeline    Manage pipelines
  use         Select an organization

Flags:
  -h, --help   help for bk

Use "bk [command] --help" for more information about a command.
</code>
</pre>
</div>

## Configuration

The Buildkite CLI requires an API access token to interact with Buildkite and your Buildkite organizations. Learn more about how to configure these API access tokens in [Buildkite CLI configuration](/docs/cli/configuration).
