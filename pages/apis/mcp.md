# Buildkite MCP server

The [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) is an open protocol standard on how to connect AI models to a variety of tools and data sources.

Buildkite provides its own MCP server to expose Buildkite product data (for example, from pipelines, builds, and jobs for Pipelines, as well as from tests for Test Engine) for AI tools, editors and other products.

## Before you start

To use Buildkite's MCP server, you'll need the following:

- To run the MCP server locally:

    * [Docker](https://www.docker.com/) version 20.x or later.
    * If running natively on your own computer:

        - On macOS, [Homebrew](https://brew.sh/).
        - If building from source, [Go](https://go.dev/dl/) version 1.24 or later.

- A [Buildkite API access token](https://buildkite.com/user/api-access-tokens). Learn more about the required scopes to configure for this token in [Configure required API access token scopes](#configure-required-api-access-token-scopes).

- Internet access to `ghcr.io`.

## Configure required API access token scopes

The following sections explain which [scopes](/docs/apis/managing-api-tokens#token-scopes) for your Buildkite MCP server's API access token are required, to access the relevant Buildkite platform functionality for your particular use case. These sets of scopes fit into the following categories:

- [Minimum recommended functionality](#configure-required-api-access-token-scopes-minimum-recommended-functionality)
- [All read-only functionality](#configure-required-api-access-token-scopes-all-read-only-functionality)
- [All read and write functionality](#configure-required-api-access-token-scopes-all-read-and-write-functionality)

### Minimum recommended functionality

Select the following [scopes](/docs/apis/managing-api-tokens#token-scopes) for your MCP server's API access token, to provide it with the minimum recommended functionality within the Buildkite platform:

- **Read Suites** (`read_suites`)
- **Read Pipelines** (`read_pipelines`)
- **Read User** (`read_user`)

You can also [create a new Buildkite API access token with these pre-selected scopes](https://buildkite.com/user/api-access-tokens/new?scopes%5B%5D=read_builds&scopes%5B%5D=read_pipelines&scopes%5B%5D=read_user), to create this API access token more rapidly through the Buildkite interface.

### All read-only functionality

Select the following [scopes](/docs/apis/managing-api-tokens#token-scopes) for your MCP server's API access token, to provide it with all required read-only functionality within the Buildkite platform:

- **Read Clusters** (`read_clusters`)
- **Read Artifacts** (`read_artifacts`)
- **Read Builds** (`read_builds`)
- **Read Build Logs** (`read_build_logs`)
- **Read Organizations** (`read_organizations`)
- **Read Pipelines** (`read_pipelines`)
- **Read User** (`read_user`)
- **Read Suites** (`read_suites`)
- All [minimum recommended](#configure-required-api-access-token-scopes-minimum-recommended-functionality) scopes.

You can also [create a new Buildkite API access token with these pre-selected scopes](https://buildkite.com/user/api-access-tokens/new?scopes%5B%5D=read_clusters&scopes%5B%5D=read_pipelines&scopes%5B%5D=read_builds&scopes%5B%5D=read_build_logs&scopes%5B%5D=read_user&scopes%5B%5D=read_organizations&scopes%5B%5D=read_artifacts&scopes%5B%5D=read_suites), to create this API access token more rapidly through the Buildkite interface.

### All read and write functionality

Select the following [scopes](/docs/apis/managing-api-tokens#token-scopes) for your MCP server's API access token, to provide it with all required read-only functionality within the Buildkite platform:

- **Write Builds** (`write_builds`)
- **Write Pipelines** (`write_pipelines`)
- All [minimum recommended](#configure-required-api-access-token-scopes-minimum-recommended-functionality) and [read-only](#configure-required-api-access-token-scopes-all-read-only-functionality) scopes.

You can also [create a new Buildkite API access token with these pre-selected scopes](https://buildkite.com/user/api-access-tokens/new?scopes%5B%5D=read_clusters&scopes%5B%5D=read_pipelines&scopes%5B%5D=read_builds&scopes%5B%5D=read_build_logs&scopes%5B%5D=read_user&scopes%5B%5D=read_organizations&scopes%5B%5D=read_artifacts&scopes%5B%5D=read_suites&scopes%5B%5D=write_builds&scopes%5B%5D=write_pipelines), to create this API access token more rapidly through the Buildkite interface.

## Install the Buildkite MCP server locally

To install and run the Buildkite MCP server locally, you can do so using [Docker](#install-the-buildkite-mcp-server-locally-using-docker) (recommended), or natively as a [pre-built binary](#install-the-buildkite-mcp-server-locally-using-a-pre-built-binary), or [build it from source](#install-the-buildkite-mcp-server-locally-building-from-source).

### Using Docker

To run the Buildkite MCP server locally in Docker:

1. Open a terminal or command prompt, and run this command to obtain the Buildkite MCP server Docker image.

    ```bash
    docker pull buildkite/mcp-server
    ```

1. Run the following command to spin up the Buildkite MCP server image in Docker.

    ```bash
    docker run --pull=always -q -it --rm -e BUILDKITE_API_TOKEN=<api-token-value> buildkite/mcp-server stdio
    ```

    where `<api-token-value>` is the value of your Buildkite API access token, set with [your required scopes](#configure-required-api-access-token-scopes). This token usually begins with the value `bkua_`.

<h4 id="using-docker-desktop">Using Docker Desktop</h4>

If you use [Docker Desktop](https://www.docker.com/products/docker-desktop/), you can add the Buildkite MCP server to the **MCP Toolkit** area of Docker Desktop by either:

- Selecting **Add to Docker Desktop**:<p></p>
    <a class="inline-block" href="https://hub.docker.com/open-desktop?url=https://open.docker.com/dashboard/mcp/servers/id/buildkite/config?enable=true" target="_blank" rel="nofollow"><img src="https://img.shields.io/badge/Add%20to%20Docker%20Desktop-17191e?style=flat&logo=docker" class="no-decoration" width="175" height="25"></a>

- Running this command:

    ```bash
    docker mcp server enable buildkite
    ```

### Using a pre-built binary

To run the Buildkite MCP server locally using a pre-built binary, follow these steps, bearing in mind that macOS users can also use the convenient [Homebrew method](#homebrew-method) as an alternative to this procedure:

1. Visit the [buildkite-mcp-server Releases](https://github.com/buildkite/buildkite-mcp-server/releases) page in GitHub.
1. Download the appropriate pre-built binary file for your particular operating system and its architecture. For macOS, choose the appropriate **Darwin** binary for your machine's architecture.
1. Extract the binary and execute it to install the Buildkite MCP server locally to your computer.

> 📘
> The installer is fully static, and no pre-requisite libraries are required.

<h4 id="homebrew-method">Homebrew method</h4>

Instead of installing the relevant **Darwin** binary from the [buildkite-mcp-server Releases](https://github.com/buildkite/buildkite-mcp-server/releases) page, you can run this [Homebrew](https://brew.sh/) command to install the Buildkite MCP server locally on macOS:

```bash
brew install buildkite/buildkite/buildkite-mcp-server
```

### Building from source

To build the Buildkite MCP server locally from source, run these commands:

```bash
go install github.com/buildkite/buildkite-mcp-server@latest
# or
goreleaser build --snapshot --clean
# or
make build    # uses goreleaser (snapshot)
```

## Configure the Buildkite MCP server for your AI tool

This section contains code snippets, which you can copy and modify, and then use to configure your AI tools to work with the Buildkite MCP server.

### Amp

You can configure [Amp](https://ampcode.com/) with the Buildkite MCP server, which runs either [using Docker](#amp-mcp-server-using-docker) or [as a local binary](#amp-mcp-server-as-a-local-binary). To do this, add the relevant configuration to your [Amp `settings.json` file](https://ampcode.com/manual#configuration).

<h4 id="amp-mcp-server-using-docker">MCP server using Docker</h4>

Add the following JSON configuration to your [Amp `settings.json` file](https://ampcode.com/manual#configuration).

```json
{
  "amp.mcpServers": {
    "buildkite": {
      "command": "docker",
      "args": [
        "run", "--pull=always", "-q",
        "-i", "--rm", "-e", "BUILDKITE_API_TOKEN",
        "buildkite/mcp-server", "stdio"
      ],
      "env": { "BUILDKITE_API_TOKEN": "bkua_xxxxx" }
    }
  }
}
```

where `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](#configure-required-api-access-token-scopes).

<h4 id="amp-mcp-server-as-a-local-binary">MCP server as a local binary</h4>

Add the following JSON configuration to your [Amp `settings.json` file](https://ampcode.com/manual#configuration).

```json
{
  "amp.mcpServers": {
    "buildkite": {
      "command": "buildkite-mcp-server",
      "args": ["stdio"],
      "env": { 
        "BUILDKITE_API_TOKEN": "bkua_xxxxx", 
        "JOB_LOG_TOKEN_THRESHOLD": "job-log-token-threashold-value" 
      }
    }
  }
}
```

where:

- `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](#configure-required-api-access-token-scopes).

- `job-log-token-threashold-value` is ?

### Claude Code

You can configure [Claude Code](https://www.anthropic.com/claude-code) (as a command line tool) with the Buildkite MCP server, which runs either [using Docker](#claude-code-mcp-server-using-docker) or [as a local binary](#claude-code-mcp-server-as-a-local-binary). To do this, run the relevant Claude Code command, after [installing Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview).

<h4 id="claude-code-mcp-server-using-docker">MCP server using Docker</h4>

Run the following Claude Code command, after [installing Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview).

```bash
claude mcp add buildkite -- docker run --pull=always -q --rm -i -e BUILDKITE_API_TOKEN=bkua_xxxxx buildkite/mcp-server stdio
```

where `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](#configure-required-api-access-token-scopes).

<h4 id="claude-code-mcp-server-as-a-local-binary">MCP server as a local binary</h4>

Run the following Claude Code command, after [installing Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview).

```bash
claude mcp add buildkite --env BUILDKITE_API_TOKEN=bkua_xxxxx -- buildkite-mcp-server stdio
```

where `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](#configure-required-api-access-token-scopes).

### Claude Desktop

You can configure [Claude Desktop](https://claude.ai/download) with the Buildkite MCP server, which runs either [using Docker](#claude-dekstop-mcp-server-using-docker) or [as a local binary](#claude-dekstop-mcp-server-as-a-local-binary). To do this, add the relevant configuration to your [Claude Desktop's `claude_desktop_config.json` file](https://modelcontextprotocol.io/quickstart/server#testing-your-server-with-claude-for-desktop).

<h4 id="claude-dekstop-mcp-server-using-docker">MCP server using Docker</h4>

Add the following configuration to your [Claude Desktop's `claude_desktop_config.json` file](https://modelcontextprotocol.io/quickstart/server#testing-your-server-with-claude-for-desktop), which you can access from Claude Desktop's **Settings** > **Developer** > **Edit Config** button on the **Local MCP servers** page.

```json
{
  "mcpServers": {
    "buildkite": {
      "command": "docker",
      "args": [
        "run", "--pull=always", "-q",
        "-i", "--rm", "-e", "BUILDKITE_API_TOKEN",
        "buildkite/mcp-server", "stdio"
      ],
      "env": { "BUILDKITE_API_TOKEN": "bkua_xxxxx" }
    }
  }
}
```

where `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](#configure-required-api-access-token-scopes).

<h4 id="claude-dekstop-mcp-server-as-a-local-binary">MCP server as a local binary</h4>

Add the following configuration to your [Claude Desktop's `claude_desktop_config.json` file](https://modelcontextprotocol.io/quickstart/server#testing-your-server-with-claude-for-desktop), which you can access from Claude Desktop's **Settings** > **Developer** > **Edit Config** button on the **Local MCP servers** page.

```json
{
  "mcpServers": {
    "buildkite": {
      "command": "buildkite-mcp-server",
      "args": ["stdio"],
      "env": { "BUILDKITE_API_TOKEN": "bkua_xxxxx", "JOB_LOG_TOKEN_THRESHOLD": "job-log-token-threashold-value" }
    }
  }
}
```

where:

- `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](#configure-required-api-access-token-scopes).

- `job-log-token-threashold-value` is ?

### Cursor

You can configure [Cursor](https://cursor.com/) with the Buildkite MCP server, which runs either [using Docker](#cursor-mcp-server-using-docker) or [as a local binary](#cursor-mcp-server-as-a-local-binary). To do this, add the relevant configuration to your [Cursor's `mcp.json` file](https://docs.cursor.com/en/context/mcp#using-mcp-json).

<h4 id="cursor-mcp-server-using-docker">MCP server using Docker</h4>

Add the following JSON configuration to your [Cursor `mcp.json` file](https://docs.cursor.com/en/context/mcp#using-mcp-json).

```json
{
  "buildkite": {
    "command": "docker",
    "args": [
      "run", "--pull=always", "-q",
      "-i", "--rm",
      "-e", "BUILDKITE_API_TOKEN",
      "buildkite/mcp-server",
      "stdio"
    ]
  }
}
```

<h4 id="cursor-mcp-server-as-a-local-binary">MCP server as a local binary</h4>

Add the following JSON configuration to your [Cursor `mcp.json` file](https://docs.cursor.com/en/context/mcp#using-mcp-json).

```json
{
  "buildkite": {
    "command": "buildkite-mcp-server",
    "args": ["stdio"],
    "env": {
      "BUILDKITE_API_TOKEN": "bkua_xxxxxxxx",
      "JOB_LOG_TOKEN_THRESHOLD": "job-log-token-threashold-value"
    }
  }
}
```

where:

- `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](#configure-required-api-access-token-scopes).

- `job-log-token-threashold-value` (_optional_) is ?

