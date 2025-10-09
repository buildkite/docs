# Toolsets

The [Buildkite MCP server](/docs/apis/mcp-server) organizes its [MCP tools](/docs/apis/mcp-server#available-mcp-tools) into logical groups of _toolsets_, each of which can be selectively enabled on the MCP server, based on your requirements.

## Available toolsets

Each toolset groups related [MCP tools](/docs/apis/mcp-server#available-mcp-tools), which interact with specific areas of the Buildkite platform. You can enable these individual toolsets by [configuring them for your Buildkite MCP server](#configuration). Doing so effectively restricts your AI tool's or agent's access to the Buildkite API, based on each set of MCP tools made available through the MCP server's configured toolsets.

<table>
  <thead>
    <tr>
      <th style="width:15%">Toolset (name)</th>
      <th style="width:35%">Description</th>
      <th style="width:50%">Tools</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "toolset": "user",
        "description": "[User, authentication, and Buildkite organization](/docs/apis/mcp-server#available-mcp-tools-user-authentication-and-buildkite-organization)",
        "tools": "current_user, user_token_organization, access_token"
      },
      {
        "toolset": "clusters",
        "description": "[Buildkite clusters](/docs/apis/mcp-server#available-mcp-tools-buildkite-clusters) management",
        "tools": "get_cluster, list_clusters, get_cluster_queue, list_cluster_queues"
      },
      {
        "toolset": "pipelines",
        "description": "[Pipelines](/docs/apis/mcp-server#available-mcp-tools-pipelines) management",
        "tools": "get_pipeline, list_pipelines, create_pipeline, update_pipeline"
      },
      {
        "toolset": "builds",
        "description": "[Builds](/docs/apis/mcp-server#available-mcp-tools-builds) operations",
        "tools": "list_builds, get_build, create_build, wait_for_build, get_jobs, unblock_job"
      },
      {
        "toolset": "logs",
        "description": "[Logs](/docs/apis/mcp-server#available-mcp-tools-logs) processing",
        "tools": "search_logs, tail_logs, read_logs, get_logs_info"
      },
      {
        "toolset": "artifacts",
        "description": "[Artifacts](/docs/apis/mcp-server#available-mcp-tools-artifacts) management",
        "tools": "list_artifacts, get_artifact"
      },
      {
        "toolset": "annotations",
        "description": "[Annotations](/docs/apis/mcp-server#available-mcp-tools-annotations) management",
        "tools": "list_annotations"
      },
      {
        "toolset": "tests",
        "description": "[Test Engine](/docs/apis/mcp-server#available-mcp-tools-test-engine)",
        "tools": "list_test_runs, get_test_run, get_failed_executions, get_test"
      }
    ].select { |field| field[:toolset] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:toolset] %></code>
         </td>
        <td>
          <p><%= render_markdown(text: field[:description]) %></p>
        </td>
        <td>
          <p><%= field[:tools].split(', ').map { |tool| "<code>#{tool}</code>" }.join(', ') %></p>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

## Configuration

You can configure [toolset availability](#available-toolsets) for either the [remote](#configuration-remote-mcp-server) or [local](#configuration-local-mcp-server) Buildkite MCP servers.

### Remote MCP server

Toolset availability for the [remote MCP server](/docs/apis/mcp-server#types-of-mcp-servers-remote-mcp-server) can be configured by adding the required [toolset names](#available-toolsets) as part of an extension to the remote MCP server's URL (for a single toolset only), or alternatively, and for multiple toolsets, as part of the header of requests sent to the Buildkite platform from the remote MCP server.

You can also configure [read-only access](/docs/apis/mcp-server#read-only-remote-mcp-server) to the remote MCP server as part of configuring toolsets.

#### Using a URL extension

When [configuring your AI tool with the remote MCP server](/docs/apis/mcp-server/remote/configuring-ai-tools), you can enable a single toolset by appending `/x/{toolset.name}` to the end of the remote MCP server URL (`https://mcp.buildkite.com/mcp`), where `{toolset.name}` is the name of the [toolset](#available-toolsets) you want to enable. To enforce read-only access, append `/readonly` to the end of `/x/{toolset.name}`.

For example, to enable the `builds` toolset for the remote MCP server, configure your AI tool with the following URL:

```url
https://mcp.buildkite.com/mcp/x/builds
```

To enforce read-only access to this remote MCP server toolset, configure your AI tool with this instead:

```url
https://mcp.buildkite.com/mcp/x/builds/readonly
```

#### Using headers

When [configuring your AI tool with the remote MCP server](/docs/apis/mcp-server/remote/configuring-ai-tools), you can enable one or more toolsets by specifying their [toolset names](#available-toolsets) within the `X-Buildkite-Toolsets` header of requests sent to the Buildkite platform from the remote MCP server. To enforce read-only access, add the `X-Buildkite-Readonly` header with a value of `true`.

### Local MCP server

Toolset availability for the [local MCP server](/docs/apis/mcp-server#types-of-mcp-servers-local-mcp-server) can be configured using environment variables or command-line flags when the local MCP server is started.

#### Using pre-built or source-built binaries

When using a [pre-built](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-using-a-pre-built-binary) or [source-built](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-building-from-source) binary to run the MCP server, add the `--enabled-toolsets` flag with a comma-delimited list of toolsets to enable:

```bash
buildkite-mcp-server stdio --enabled-toolsets="user,pipelines,builds"
```

#### Using Docker

When using [Docker](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-using-docker) to run the MCP server, set the `BUILDKITE_TOOLSETS` environment variable with a comma-delimited list of toolsets to enable:

```bash
docker run --rm -e BUILDKITE_API_TOKEN=bkua_xxxxx -e BUILDKITE_TOOLSETS="user,pipelines,builds" buildkite/mcp-server stdio
```

### Special values

- **`all`** - Enables all available toolsets (default)
- **Read-only mode** - Add `--read-only` flag or `BUILDKITE_READ_ONLY=true` to filter out write operations
