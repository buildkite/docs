# Toolsets

The Buildkite MCP server organizes its tools into logical **toolsets** that can be enabled or disabled based on your needs. Learn more about the MCP server in the [Buildkite MCP server overview](/docs/apis/mcp-server).

## Available toolsets

Each toolset groups related MCP tools that interact with specific areas of the Buildkite platform. You can enable or disable individual toolsets to control which API functionality is available to your AI assistant. Learn more about MCP tools in the [Buildkite MCP server overview](/docs/apis/mcp-server).

<table>
  <thead>
    <tr>
      <th style="width:20%">Toolset</th>
      <th style="width:40%">Description</th>
      <th style="width:40%">Tools</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "toolset": "clusters",
        "description": "Cluster Management",
        "tools": "get_cluster, list_clusters, get_cluster_queue, list_cluster_queues"
      },
      {
        "toolset": "pipelines",
        "description": "Pipeline Management",
        "tools": "get_pipeline, list_pipelines, create_pipeline, update_pipeline"
      },
      {
        "toolset": "builds",
        "description": "Build Operations",
        "tools": "list_builds, get_build, create_build, wait_for_build, get_jobs, unblock_job"
      },
      {
        "toolset": "artifacts",
        "description": "Artifact Management",
        "tools": "list_artifacts, get_artifact"
      },
      {
        "toolset": "logs",
        "description": "Log Analysis",
        "tools": "search_logs, tail_logs, read_logs, get_logs_info"
      },
      {
        "toolset": "tests",
        "description": "Test Engine",
        "tools": "list_test_runs, get_test_run, get_failed_executions, get_test"
      },
      {
        "toolset": "annotations",
        "description": "Annotation Management",
        "tools": "list_annotations"
      },
      {
        "toolset": "user",
        "description": "User & Organization",
        "tools": "current_user, user_token_organization, access_token"
      }
    ].select { |field| field[:toolset] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:toolset] %></code>
         </td>
        <td>
          <p><%= field[:description] %></p>
        </td>
        <td>
          <p><%= field[:tools].split(', ').map { |tool| "<code>#{tool}</code>" }.join(', ') %></p>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

## Configuration

Configure toolsets using environment variables or command-line flags.

### Using pre-built or source-built binaries

When using a [pre-built](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-using-a-pre-built-binary) or [source-built](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-building-from-source) binary to run the MCP server, add the `--enabled-toolsets` flag with a comma-delimited list of toolsets to enable:

```bash
buildkite-mcp-server stdio --enabled-toolsets="user,pipelines,builds"
```

### Using Docker

When using [Docker](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-using-docker) to run the MCP server, set the `BUILDKITE_TOOLSETS` environment variable with a comma-delimited list of toolsets to enable:

```bash
docker run --rm -e BUILDKITE_API_TOKEN=bkua_xxxxx -e BUILDKITE_TOOLSETS="user,pipelines,builds" buildkite/mcp-server stdio
```

## Special values

- **`all`** - Enables all available toolsets (default)
- **Read-only mode** - Add `--read-only` flag or `BUILDKITE_READ_ONLY=true` to filter out write operations
