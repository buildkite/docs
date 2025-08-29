# Installing the Buildkite MCP server locally

The Buildkite MCP server is available to install locally, and is also available remotely at `https://mcp.buildkite.com/mcp`, which is Buildkite's official _remote MCP server_.

While there are no installation requirements for the remote MCP server, this page covers the details and requirements for installing Buildkite's MCP server locally, beginning with [Before you start](#before-you-start).

Once you have installed your local Buildkite MCP server using the relevant instructions on this page, you can proceed to [configure your AI tools](/docs/apis/mcp-server/configuring-ai-tools) to work with this MCP server.

> 📘
> If you are connecting to Buildkite's remote MCP server, proceed directly to [configure your AI tools](/docs/apis/mcp-server/configuring-ai-tools) to work with this server.

## Before you start

To use Buildkite's MCP server locally, you'll need the following:

- A [Buildkite API access token](https://buildkite.com/user/api-access-tokens). Learn more about the required scopes to configure for this token in [Configure API access token with required scopes](#configure-api-access-token-with-required-scopes).

- Internet access to `ghcr.io`.

Specific requirements for each type of local installation method for the Buildkite MCP server are covered in their relevant [installation sections](#install-the-buildkite-mcp-server-locally).

## Configure API access token with required scopes

This section explains which [scopes](/docs/apis/managing-api-tokens#token-scopes) your local Buildkite MCP server's API access token requires permission for within your Buildkite organization, for your particular use case. These scopes fit into the following categories:

- [Minimum access](#configure-api-access-token-with-required-scopes-minimum-access)
- [All read-only access](#configure-api-access-token-with-required-scopes-all-read-only-access)
- [All read and write access](#configure-api-access-token-with-required-scopes-all-read-and-write-access)

### Minimum access

For minimum access, select the following [scopes](/docs/apis/managing-api-tokens#token-scopes) for your local MCP server's API access token. These scopes provide your token with the minimum required access permissions on the Buildkite MCP server, and prevents access to more sensitive information within your Buildkite organization.

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

To create this API access token rapidly through the Buildkite interface, you can do so by [creating a new Buildkite API access token with these pre-selected scopes](https://buildkite.com/user/api-access-tokens/new?scopes%5B%5D=read_builds&scopes%5B%5D=read_pipelines&scopes%5B%5D=read_user).

### All read-only access

For all read-only access, select both the [minimum access permissions](#configure-api-access-token-with-required-scopes-minimum-access), as well as the following additional [scopes](/docs/apis/managing-api-tokens#token-scopes) for your local MCP server's API access token. These scopes provide your token with all read-only access permissions available through the Buildkite MCP server. These additional scopes include permission to access more information about your Buildkite organization, including clusters, more pipeline build details (that is, log information), as well as access to Test Engine test suite data.

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

To create this API access token rapidly through the Buildkite interface, you can do so by [creating a new Buildkite API access token with these pre-selected scopes](https://buildkite.com/user/api-access-tokens/new?scopes%5B%5D=read_clusters&scopes%5B%5D=read_pipelines&scopes%5B%5D=read_builds&scopes%5B%5D=read_build_logs&scopes%5B%5D=read_user&scopes%5B%5D=read_organizations&scopes%5B%5D=read_artifacts&scopes%5B%5D=read_suites).

### All read and write access

For all read and write access, select both the [minimum access permissions](#configure-api-access-token-with-required-scopes-minimum-access) and [all read-only access permissions](#configure-api-access-token-with-required-scopes-all-read-only-access), as well as the following additional [scopes](/docs/apis/managing-api-tokens#token-scopes) for your local MCP server's API access token. These scopes provide your token with all available read _and_ write access permissions available through the Buildkite MCP server. These additional scopes include permission to edit pipelines and their builds within your Buildkite organization.

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

To create this API access token rapidly through the Buildkite interface, you can do so by [create a new Buildkite API access token with these pre-selected scopes](https://buildkite.com/user/api-access-tokens/new?scopes%5B%5D=read_clusters&scopes%5B%5D=read_pipelines&scopes%5B%5D=read_builds&scopes%5B%5D=read_build_logs&scopes%5B%5D=read_user&scopes%5B%5D=read_organizations&scopes%5B%5D=read_artifacts&scopes%5B%5D=read_suites&scopes%5B%5D=write_builds&scopes%5B%5D=write_pipelines).

## Install the Buildkite MCP server locally

To install and run the Buildkite MCP server locally, you can do so using [Docker](#install-the-buildkite-mcp-server-locally-using-docker) (recommended) or [Docker Desktop](#using-docker-desktop), or natively as a [pre-built binary](#install-the-buildkite-mcp-server-locally-using-a-pre-built-binary), or [build it from source](#install-the-buildkite-mcp-server-locally-building-from-source).

### Using Docker

To run the Buildkite MCP server locally in Docker:

1. Ensure you have installed and are running [Docker](https://www.docker.com/) version 20.x or later.

1. Open a terminal or command prompt, and run this command to obtain the Buildkite MCP server Docker image.

    ```bash
    docker pull buildkite/mcp-server
    ```

1. Run the following command to spin up the Buildkite MCP server image in Docker.

    ```bash
    docker run --pull=always -q -it --rm -e BUILDKITE_API_TOKEN=<api-token-value> buildkite/mcp-server stdio
    ```

    where `<api-token-value>` is the value of your Buildkite API access token, set with [your required scopes](#configure-api-access-token-with-required-scopes). This token usually begins with the value `bkua_`.

<h4 id="using-docker-desktop">Using Docker Desktop</h4>

If you have installed and are using [Docker Desktop](https://www.docker.com/products/docker-desktop/), you can add the Buildkite MCP server to the **MCP Toolkit** area of Docker Desktop by either:

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

1. Ensure you have installed [Go](https://www.docker.com/) version 1.24 or later.

1. Run the following commands to build the MCP server locally from source.

    ```bash
    go install github.com/buildkite/buildkite-mcp-server@latest
    # or
    goreleaser build --snapshot --clean
    # or
    make build    # uses goreleaser (snapshot)
    ```
