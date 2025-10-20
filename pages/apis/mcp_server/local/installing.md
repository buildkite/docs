# Installing the Buildkite MCP server

The Buildkite MCP server is available both [locally and remotely](/docs/apis/mcp-server#types-of-mcp-servers). This page is about installing and configuring the _local_ MCP server, beginning with [Before you start](#before-you-start).

Once you have installed your local Buildkite MCP server using the relevant instructions on this page, you can proceed to [configure your AI tools or agents](/docs/apis/mcp-server/local/configuring-ai-tools) to work with this MCP server.

> 📘
> Buildkite's _remote_ MCP server requires no installation and is available publicly, with authentication and authorization fully managed by OAuth. If you're working directly with an AI tool as opposed to using an AI agent in a workflow (see [Types of MCP servers](/docs/apis/mcp-server#types-of-mcp-servers) for more information), and you'd prefer to use the remote MCP server instead, proceed directly to its [Configuring AI tools](/docs/apis/mcp-server/remote/configuring-ai-tools) page.

## Before you start

To use Buildkite's MCP server locally, you'll need the following:

- A Buildkite user account, which you can sign into your Buildkite organization with.

- A [Buildkite API access token](https://buildkite.com/user/api-access-tokens) for this Buildkite user account. Learn more about the required scopes to configure for this token in [Configure an API access token](#configure-an-api-access-token).

Specific requirements for each type of local installation method for the Buildkite MCP server are covered in their relevant [installation sections](#install-and-run-the-server-locally).

## Configure an API access token

This section explains which [scopes](/docs/apis/managing-api-tokens#token-scopes) your local Buildkite MCP server's API access token requires permission for within your Buildkite organization, for your particular use case. These scopes typically fit into the following categories:

- [Minimum access](#configure-an-api-access-token-minimum-access)
- [All read-only access](#configure-an-api-access-token-all-read-only-access)
- [All read and write access](#configure-an-api-access-token-all-read-and-write-access)

### Minimum access

For minimum access, select the following [scopes](/docs/apis/managing-api-tokens#token-scopes) for your local MCP server's API access token. These scopes provide your token with the minimum required access permissions on the Buildkite MCP server, and prevent access to more sensitive information within your Buildkite organization.

<table>
  <thead>
    <tr>
      <th style="width:20%">Scope</th>
      <th style="width:20%"></th>
      <th style="width:60%">Access permissions</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "scope": "Read Builds",
        "scope_internal": "read_builds",
        "access_permissions": "List and retrieve details of a pipeline's builds, jobs and annotations."
      },
      {
        "scope": "Read Pipelines",
        "scope_internal": "read_pipelines",
        "access_permissions": "List and retrieve details of pipelines themselves."
      },
      {
        "scope": "Read User",
        "scope_internal": "read_user",
        "access_permissions": "Retrieve basic details about a Buildkite user account."
      }
    ].select { |field| field[:scope] }.each do |field| %>
      <tr>
        <td>
          <strong><%= field[:scope] %></strong>
         </td>
        <td>
          <code><%= field[:scope_internal] %></code>
        </td>
        <td>
          <p><%= field[:access_permissions] %></p>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

You can also [create a new Buildkite API access token rapidly with these pre-selected scopes](https://buildkite.com/user/api-access-tokens/new?scopes%5B%5D=read_builds&scopes%5B%5D=read_pipelines&scopes%5B%5D=read_user).

### All read-only access

For all read-only access, select both the [minimum access permissions](#configure-an-api-access-token-minimum-access), as well as the following additional [scopes](/docs/apis/managing-api-tokens#token-scopes) for your local MCP server's API access token. These scopes provide your token with all read-only access permissions available through the Buildkite MCP server. These additional scopes include permission to access more information about your Buildkite organization, including clusters, more pipeline build details (that is, log information), as well as access to Test Engine test suite data.

<table>
  <thead>
    <tr>
      <th style="width:25%">Scope</th>
      <th style="width:25%"></th>
      <th style="width:50%">Access permissions</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "scope": "Read Clusters",
        "scope_internal": "read_clusters",
        "access_permissions": "List and retrieve details of clusters and their queues."
      },
      {
        "scope": "Read Artifacts",
        "scope_internal": "read_artifacts",
        "access_permissions": "Retrieve build artifacts and their metadata."
      },
      {
        "scope": "Read Build Logs",
        "scope_internal": "read_build_logs",
        "access_permissions": "Retrieve the log output of builds and their jobs."
      },
      {
        "scope": "Read Organizations",
        "scope_internal": "read_organizations",
        "access_permissions": "List and retrieve details of the Buildkite organization."
      },
      {
        "scope": "Read Suites",
        "scope_internal": "read_suites",
        "access_permissions": "List and retrieve details of Test Engine test suites—including runs, tests, executions, etc."
      }
    ].select { |field| field[:scope] }.each do |field| %>
      <tr>
        <td>
          <strong><%= field[:scope] %></strong>
         </td>
        <td>
          <code><%= field[:scope_internal] %></code>
        </td>
        <td>
          <p><%= field[:access_permissions] %></p>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

You can also [create a new Buildkite API access token rapidly with these pre-selected scopes](https://buildkite.com/user/api-access-tokens/new?scopes%5B%5D=read_clusters&scopes%5B%5D=read_pipelines&scopes%5B%5D=read_builds&scopes%5B%5D=read_build_logs&scopes%5B%5D=read_user&scopes%5B%5D=read_organizations&scopes%5B%5D=read_artifacts&scopes%5B%5D=read_suites).

### All read and write access

For all read and write access, select both the [minimum access permissions](#configure-an-api-access-token-minimum-access) and [all read-only access permissions](#configure-an-api-access-token-all-read-only-access), as well as the following additional [scopes](/docs/apis/managing-api-tokens#token-scopes) for your local MCP server's API access token. These scopes provide your token with all available read _and_ write access permissions available through the Buildkite MCP server. These additional scopes include permission to edit pipelines and their builds within your Buildkite organization.

<table>
  <thead>
    <tr>
      <th style="width:20%">Scope</th>
      <th style="width:20%"></th>
      <th style="width:60%">Access permissions</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "scope": "Write Builds",
        "scope_internal": "write_builds",
        "access_permissions": "Create new pipeline builds, unblock jobs, and trigger builds."
      },
      {
        "scope": "Write Pipelines",
        "scope_internal": "write_pipelines",
        "access_permissions": "Create new pipelines, update update existing ones, and delete pipelines too."
      }
    ].select { |field| field[:scope] }.each do |field| %>
      <tr>
        <td>
          <strong><%= field[:scope] %></strong>
         </td>
        <td>
          <code><%= field[:scope_internal] %></code>
        </td>
        <td>
          <p><%= field[:access_permissions] %></p>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

You can also [create a new Buildkite API access token rapidly with these pre-selected scopes](https://buildkite.com/user/api-access-tokens/new?scopes%5B%5D=read_clusters&scopes%5B%5D=read_pipelines&scopes%5B%5D=read_builds&scopes%5B%5D=read_build_logs&scopes%5B%5D=read_user&scopes%5B%5D=read_organizations&scopes%5B%5D=read_artifacts&scopes%5B%5D=read_suites&scopes%5B%5D=write_builds&scopes%5B%5D=write_pipelines).

## Install and run the server locally

To install and run the Buildkite MCP server locally, you can do so using [Docker](#install-and-run-the-server-locally-using-docker) (recommended), natively as a [pre-built binary](#install-and-run-the-server-locally-using-a-pre-built-binary), or [build it from source](#install-and-run-the-server-locally-building-from-source).

### Using Docker

To run the Buildkite MCP server locally in Docker:

1. Ensure you have installed and are running [Docker](https://www.docker.com/) version 20.x or later.

    **Note:**
    * You can also confirm the minimum required Docker version from the [buildkite-mcp-server's README](https://github.com/buildkite/buildkite-mcp-server/tree/main?tab=readme-ov-file#%EF%B8%8F-prerequisites).
    * These remaining steps are for running the MCP server in Docker from the command line, or if you have installed the [Docker Engine](https://docs.docker.com/engine/install/) only. If you've installed Docker through Docker Desktop, you can follow the more convenient [Docker Desktop instructions](#using-docker-desktop) instead.

1. Open a terminal or command prompt, and run this command to obtain the Buildkite MCP server Docker image.

    ```bash
    docker pull buildkite/mcp-server
    ```

1. Run the following command to spin up the Buildkite MCP server image in Docker.

    ```bash
    docker run --pull=always -q -it --rm -e BUILDKITE_API_TOKEN=<api-token-value> buildkite/mcp-server stdio
    ```

    where `<api-token-value>` is the value of your Buildkite API access token, set with [your required scopes](#configure-an-api-access-token). This token usually begins with the value `bkua_`.

<h4 id="using-docker-desktop">Using Docker Desktop</h4>

If you are using [Docker Desktop](https://www.docker.com/products/docker-desktop/), you can add the Buildkite MCP server to the **MCP Toolkit** area of Docker Desktop.

<!-- vale off -->

To do so, visit the [Buildkite MCP server](https://hub.docker.com/mcp/server/buildkite/overview) page on [Docker's mcp hub site](https://hub.docker.com/mcp) for MCP servers. This page provides details on which Docker Desktop versions are supported, and a button from which you can add the MCP server directly to your Docker Desktop installation.

<!-- vale on -->

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

1. Ensure you have installed [Go](https://go.dev/dl/) version 1.24 or later.

    **Note:** You can also confirm the minimum required Go version from the [buildkite-mcp-server's README](https://github.com/buildkite/buildkite-mcp-server/tree/main?tab=readme-ov-file#%EF%B8%8F-prerequisites).

1. Run the following commands to build the MCP server locally from source.

    ```bash
    go install github.com/buildkite/buildkite-mcp-server/cmd/buildkite-mcp-server@latest
    ```

> 📘
> If you're interested in contributing to the development of the Buildkite MCP server, see the [Contributing section of the README](https://github.com/buildkite/buildkite-mcp-server/tree/main?tab=readme-ov-file#-contributing) and [Development](https://github.com/buildkite/buildkite-mcp-server/blob/main/DEVELOPMENT.md) guide for more information.

## Using 1Password

For enhanced security, you can store your [Buildkite API access token](#configure-an-api-access-token) in [1Password](https://1password.com/) and reference this token using the [1Password command-line interface (CLI)](https://developer.1password.com/docs/cli) instead of exposing it as a plain environment variable.

### Before you start

Ensure you have met the following requirements before continuing with any 1Password configuration.

- You have [installed the 1Password CLI](https://developer.1password.com/docs/cli/get-started/), and have authenticated into it.
- Your [API access token](#configure-an-api-access-token) has been stored as an item in 1Password.

### Accessing your API access token from 1Password

Instead of using `BUILDKITE_API_TOKEN` environment variable or `--api-token` flag, use `BUILDKITE_API_TOKEN_FROM_1PASSWORD` environment variable or `--api-token-from-1password` flag, respectively with a 1Password item reference.

#### Example environment variable usage

```bash
export BUILDKITE_API_TOKEN_FROM_1PASSWORD="op://Private/Buildkite API Token/credential" buildkite-mcp-server stdio
```

#### Example CLI flag usage

```bash
buildkite-mcp-server stdio --api-token-from-1password="op://Private/Buildkite API Token/credential"
```

> 📘
> The local MCP server will call `op read -n <reference>` to fetch the API access token. Ensure your 1Password CLI has been successfully authenticated before starting the server.

## Self-hosting the MCP server

You can [install the Buildkite MCP server](#install-and-run-the-server-locally) as your own self-hosted server, which effectively behaves similarly to Buildkite's remote MCP server, but as one that operates in your own environment.

To do this, use the following the following command, which runs the MCP server with streamable HTTP transport, and makes the server available through `http://localhost:3000/mcp`:

```bash
buildkite-mcp-server http --api-token=${BUILDKITE_API_TOKEN}
```

where `${BUILDKITE_API_TOKEN}` is the value of your [configured Buildkite API access token](#configure-an-api-access-token), set with your required scopes.

To run the MCP server with legacy server-sent events (SSE), use this command with the `--use-sse` option. For example:

```bash
buildkite-mcp-server http --use-sse --api-token=${BUILDKITE_API_TOKEN}
```

To change the listening address or port on which the MCP server runs, use the `HTTP_LISTEN_ADDR` environment variable. For example, to set this port to `4321`:

```bash
HTTP_LISTEN_ADDR="localhost:4321" buildkite-mcp-server http --api-token=...
```

To run the MCP server using Docker with streamable HTTP transport and expose the server through port `3000`:

```bash
docker run --pull=always -q --rm -e BUILDKITE_API_TOKEN -e HTTP_LISTEN_ADDR=":3000" -p 127.0.0.1:3000:3000 buildkite/mcp-server http
```

With your self-hosted MCP server up and running, you can now [configure your AI tools](/docs/apis/mcp-server/remote/configuring-ai-tools) as you would for Buildkite's remote MCP server, but substituting its URL (`https://mcp.buildkite.com/mcp`) for the URL of your self-hosted MCP server (for example, `http://127.0.0.1:3000/mcp`). Note that the OAuth authentication flow won't be triggered in this case, as your server will be configured to use your own API access token.

> 📘
> If you'd like to customize your self-hosted MCP server further, note that the [Buildkite MCP server](https://github.com/buildkite/buildkite-mcp-server) implements the [mcp-go](https://github.com/mark3labs/mcp-go) library. Consult this library's README and associated documentation for more customization details.
