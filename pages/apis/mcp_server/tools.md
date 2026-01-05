# MCP tools overview

_MCP tools_ form the fundamental components of an _MCP server_, and provide the mechanisms through which AI tools and agents can access a system's APIs, through its MCP server.

Learn more about MCP tools in the [Core Server Features](https://modelcontextprotocol.io/docs/learn/server-concepts#core-server-features) and [Tools](https://modelcontextprotocol.io/docs/learn/server-concepts#tools) sections of the [Understanding MCP servers](https://modelcontextprotocol.io/docs/learn/server-concepts) page in the [Model Context Protocol](https://modelcontextprotocol.io/docs/getting-started/intro) docs.

## Available MCP tools

The Buildkite MCP server exposes the following categories of MCP tools.

The names of these tools (for example, `list_pipelines`) typically do not need to be used in direct prompts to AI tools or agents. However, each MCP tool name is designed to be understandable, so that it can be used directly in a prompt when you want your AI tool or agent to explicitly use that MCP tool to query the Buildkite platform.

As part of configuring your AI tool or agent with the [remote or local Buildkite MCP server](/docs/apis/mcp-server#types-of-mcp-servers), you can restrict its access to specific categories of tools using [toolsets](/docs/apis/mcp-server/tools/toolsets).

Additionally, Buildkite recommends [configuring your project's `AGENTS.md` file with a hint](#the-agents-dot-md-file) to help guide your AI tool or agent to use the Buildkite MCP server and its tools with your project.

> 📘
> While Buildkite's MCP server makes calls to the Buildkite REST API, note that in some cases, only a subset of the resulting fields are returned in the response to your AI tool or agent. This is done to reduce noise for your AI tool / agent, as well as reduce costs associated with text tokenization of the response (also known as token usage).

### User, authentication and Buildkite organization

These MCP tools are associated with [authentication](/docs/apis#authentication) and relate to querying details about the access token's user and Buildkite organization they belong to.

<table>
  <thead>
    <tr>
      <th style="width:20%">Tool</th>
      <th style="width:80%">Description</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "tool": "access_token",
        "description": "Uses the [Get the current token](/docs/apis/rest-api/access-token#get-the-current-token) REST API endpoint to retrieve information about the current API access token, including its scopes and UUID."
      },
      {
        "tool": "current_user",
        "description": "Uses the [Get the current user](/docs/apis/rest-api/user#get-the-current-user) REST API endpoint to retrieve details about the user account that owns the API token, including name, email, avatar, and account creation date.",
        "scope": "read_user"
      },
      {
        "tool": "user_token_organization",
        "description": "Uses the [Get an organization](/docs/apis/rest-api/organizations#get-an-organization) REST API endpoint to retrieve details about the Buildkite organization associated with the user token used for this request.",
        "scope": "read_organizations"
      }
    ].select { |field| field[:tool] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:tool] %></code>
         </td>
        <td>
          <p><%= render_markdown(text: field[:description]) %></p>
          <% if field[:scope] %>
            <p>Required <a href="/docs/apis/managing-api-tokens#token-scopes">token scope</a>: <code><%= field[:scope] %></code>.</p>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

### Buildkite clusters

These MCP tools are used to retrieve details about the [clusters](/docs/pipelines/clusters/manage-clusters) and their [queues](/docs/agent/v3/targeting/queues/managing) configured in your Buildkite organization. Learn more about clusters in [Clusters overview](/docs/pipelines/clusters).

<table>
  <thead>
    <tr>
      <th style="width:20%">Tool</th>
      <th style="width:80%">Description</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "tool": "list_clusters",
        "description": "Uses the [List clusters](/docs/apis/rest-api/clusters#clusters-list-clusters) REST API endpoint to list all clusters in an organization with their names, descriptions, default queues, and creation details.",
        "scope": "read_clusters"
      },
      {
        "tool": "get_cluster",
        "description": "Uses the [Get a cluster](/docs/apis/rest-api/clusters#clusters-get-a-cluster) REST API endpoint to retrieve detailed information about a specific cluster including its name, description, default queue, and configuration.",
        "scope": "read_clusters"
      },
      {
        "tool": "list_cluster_queues",
        "description": "Uses the [List queues](/docs/apis/rest-api/clusters/queues#list-queues) REST API endpoint to list all queues in a cluster with their keys, descriptions, dispatch status, and agent configuration.",
        "scope": "read_clusters"
      },
      {
        "tool": "get_cluster_queue",
        "description": "Uses the [Get a queue](/docs/apis/rest-api/clusters/queues#get-a-queue) REST API endpoint to retrieve detailed information about a specific queue including its key, description, dispatch status, and hosted agent configuration.",
        "scope": "read_clusters"
      }
    ].select { |field| field[:tool] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:tool] %></code>
         </td>
        <td>
          <p><%= render_markdown(text: field[:description]) %></p>
          <% if field[:scope] %>
            <p>Required <a href="/docs/apis/managing-api-tokens#token-scopes">token scope</a>: <code><%= field[:scope] %></code>.</p>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

### Pipelines

These MCP tools are used to retrieve details about existing [pipelines](/docs/apis/rest-api/pipelines) in [your Buildkite organization](/docs/apis/rest-api/organizations), as well as create new pipelines, and update existing ones.

<table>
  <thead>
    <tr>
      <th style="width:20%">Tool</th>
      <th style="width:80%">Description</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "tool": "list_pipelines",
        "description": "Uses the [List pipelines](/docs/apis/rest-api/pipelines#list-pipelines) REST API endpoint to list all pipelines in an organization with their basic details, build counts, and current status.",
        "scope": "read_pipelines"
      },
      {
        "tool": "get_pipeline",
        "description": "Uses the [Get a pipeline](/docs/apis/rest-api/pipelines#get-a-pipeline) REST API endpoint to retrieve detailed information about a specific pipeline including its configuration, steps, environment variables, and build statistics.",
        "scope": "read_pipelines"
      },
      {
        "tool": "create_pipeline",
        "description": "Uses the [Create a YAML pipeline](/docs/apis/rest-api/pipelines#create-a-yaml-pipeline) REST API endpoint to set up a new CI/CD pipeline in Buildkite with YAML configuration, repository connection, and cluster assignment.",
        "scope": "write_pipelines"
      },
      {
        "tool": "update_pipeline",
        "description": "Uses the [Update a pipeline](/docs/apis/rest-api/pipelines#update-a-pipeline) REST API endpoint to modify an existing Buildkite pipeline's configuration, repository, settings, or metadata.",
        "scope": "write_pipelines"
      }
    ].select { |field| field[:tool] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:tool] %></code>
         </td>
        <td>
          <p><%= render_markdown(text: field[:description]) %></p>
          <% if field[:scope] %>
            <p>Required <a href="/docs/apis/managing-api-tokens#token-scopes">token scope</a>: <code><%= field[:scope] %></code>.</p>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

### Builds

These MCP tools are used to retrieve details about existing [builds](/docs/apis/rest-api/builds) of a [pipeline](#available-mcp-tools-pipelines), as well as create new builds, and wait for a specific build to finish.

<table>
  <thead>
    <tr>
      <th style="width:20%">Tool</th>
      <th style="width:80%">Description</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "tool": "list_builds",
        "description": "Uses the [List all builds](/docs/apis/rest-api/builds#list-all-builds) REST API endpoint to list all builds for a pipeline with their status, commit information, and metadata.",
        "scope": "read_builds"
      },
      {
        "tool": "get_build",
        "description": "Uses the [Get a build](/docs/apis/rest-api/builds#get-a-build) REST API endpoint to retrieve detailed information about a specific build including its jobs, timing, and execution details.",
        "scope": "read_builds"
      },
      {
        "tool": "create_build",
        "description": "Uses the [Create a build](/docs/apis/rest-api/builds#create-a-build) REST API endpoint to trigger a new build on a Buildkite pipeline for a specific commit and branch, with optional environment variables, metadata, and author information.",
        "scope": "write_builds"
      },
      {
        "tool": "wait_for_build",
        "description": "Waits for a specific build to be completed. This tool uses the [Get a build](/docs/apis/rest-api/builds#get-a-build) REST API endpoint to retrieve the status of the build from its logs. If the build is still running, the `wait_for_build` tool automatically calls this same endpoint again, and does so repeatedly with increasingly less frequency, to reduce text tokenization usage and traffic, until the returned build status is completed.",
        "scope": "read_builds"
      }
    ].select { |field| field[:tool] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:tool] %></code>
         </td>
        <td>
          <p><%= render_markdown(text: field[:description]) %></p>
          <% if field[:scope] %>
            <p>Required <a href="/docs/apis/managing-api-tokens#token-scopes">token scope</a>: <code><%= field[:scope] %></code>.</p>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

### Jobs

These MCP tools are used to retrieve the logs of [jobs](/docs/apis/rest-api/jobs) from a pipeline [build](#available-mcp-tools-builds), as well as unblock jobs in a pipeline build. A job's logs can then be processed by the [logs](#available-mcp-tools-logs) tools of the MCP server, for the benefit of your AI tool or agent.

<table>
  <thead>
    <tr>
      <th style="width:20%">Tool</th>
      <th style="width:80%">Description</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "tool": "get_job_logs",
        "description": "Uses the [Get a job's log output](/docs/apis/rest-api/jobs#get-a-jobs-log-output) REST API endpoint to get the log output and metadata for a specific job, including content, size, and header timestamps. Automatically saves to file for large logs to avoid token limits.",
        "scope": "read_build_logs"
      },
      {
        "tool": "unblock_job",
        "description": "Uses the [Unblock a job](/docs/apis/rest-api/jobs#unblock-a-job) REST API endpoint to unblock a blocked job in a Buildkite build to allow it to continue execution.",
        "scope": "write_builds"
      }
    ].select { |field| field[:tool] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:tool] %></code>
         </td>
        <td>
          <p><%= render_markdown(text: field[:description]) %></p>
          <% if field[:scope] %>
            <p>Required <a href="/docs/apis/managing-api-tokens#token-scopes">token scope</a>: <code><%= field[:scope] %></code>.</p>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

### Logs

These MCP tools are used to process the logs of [jobs](#available-mcp-tools-jobs), for the benefit of your AI tool or agent. These MCP tools leverage the [Buildkite Logs Search & Query Library](https://github.com/buildkite/buildkite-logs?tab=readme-ov-file#buildkite-logs-search--query-library) (used by the Buildkite MCP server), which converts the complex Buildkite logs returned by the Buildkite platform into [Parquet file](https://parquet.apache.org/docs/file-format/) versions of these log files, making the logs more consumable for AI tools, agents and large language models (LLMs).

For improved performance, these Parquet log files are also cached and stored. Learn more about this in [Smart caching and storage](#smart-caching-and-storage).

<table>
  <thead>
    <tr>
      <th style="width:20%">Tool</th>
      <th style="width:80%">Description</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "tool": "search_logs",
        "description": "Search log entries using regex patterns with optional context lines."
      },
      {
        "tool": "tail_logs",
        "description": "Show the last N entries from the log file (that is, N lines for recent errors and status checks)."
      },
      {
        "tool": "get_logs_info",
        "description": "Get metadata and statistics about the Parquet log file."
      },
      {
        "tool": "read_logs",
        "description": "Read log entries from the file, optionally starting from a specific row number."
      }
    ].select { |field| field[:tool] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:tool] %></code>
         </td>
        <td>
          <p><%= render_markdown(text: field[:description]) %></p>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

### Artifacts

These MCP tools are used to retrieve details about artifacts from a pipeline [build](#available-mcp-tools-builds), as well as obtain the artifacts themselves.

<table>
  <thead>
    <tr>
      <th style="width:20%">Tool</th>
      <th style="width:80%">Description</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "tool": "list_artifacts",
        "description": "Uses the [List artifacts for a build](/docs/apis/rest-api/artifacts#list-artifacts-for-a-build) REST API endpoint to list a build's artifacts across all of its jobs, including file details, paths, sizes, MIME types, and download URLs.",
        "scope": "read_artifacts"
      },
      {
        "tool": "get_artifact",
        "description": "Uses the [Get an artifact](/docs/apis/rest-api/artifacts#get-an-artifact) REST API endpoint to get detailed information about a specific artifact including its metadata, file size, SHA-1 hash, and download URL.",
        "scope": "read_artifacts"
      }
    ].select { |field| field[:tool] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:tool] %></code>
         </td>
        <td>
          <p><%= render_markdown(text: field[:description]) %></p>
          <% if field[:scope] %>
            <p>Required <a href="/docs/apis/managing-api-tokens#token-scopes">token scope</a>: <code><%= field[:scope] %></code>.</p>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

### Annotations

These MCP tools are used to retrieve details about the annotations resulting from a pipeline [build](#available-mcp-tools-builds).

<table>
  <thead>
    <tr>
      <th style="width:20%">Tool</th>
      <th style="width:80%">Description</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "tool": "list_annotations",
        "description": "Uses the [List annotations for a build](/docs/apis/rest-api/annotations#list-annotations-for-a-build) REST API endpoint to list all annotations for a build, including their context, style (success/info/warning/error), rendered HTML content, and creation timestamps.",
        "scope": "read_builds"
      }
    ].select { |field| field[:tool] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:tool] %></code>
         </td>
        <td>
          <p><%= render_markdown(text: field[:description]) %></p>
          <% if field[:scope] %>
            <p>Required <a href="/docs/apis/managing-api-tokens#token-scopes">token scope</a>: <code><%= field[:scope] %></code>.</p>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

### Test Engine

These MCP tools are used to retrieve details about Test Engine [tests](/docs/test-engine/glossary#test) and their [runs](/docs/test-engine/glossary#run) from a [test suite](/docs/test-engine/test-suites), along with other Test Engine-related data.

<table>
  <thead>
    <tr>
      <th style="width:20%">Tool</th>
      <th style="width:80%">Description</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "tool": "get_test",
        "description": "Uses the [Get a test](/docs/apis/rest-api/test-engine/tests#get-a-test) REST API endpoint to retrieve a specific test in Buildkite Test Engine. This provides additional metadata for failed test executions.",
        "scope": "read_suites"
      },
      {
        "tool": "list_test_runs",
        "description": "Uses the [List all runs](/docs/apis/rest-api/test-engine/runs#list-all-runs) REST API endpoint to list all test runs for a test suite in Buildkite Test Engine.",
        "scope": "read_suites"
      },
      {
        "tool": "get_test_run",
        "description": "Uses the [Get a run](/docs/apis/rest-api/test-engine/runs#get-a-run) REST API endpoint to retrieve a specific test run in Buildkite Test Engine.",
        "scope": "read_suites"
      },
      {
        "tool": "get_failed_executions",
        "description": "Uses the [Get failed execution data](/docs/apis/rest-api/test-engine/runs#get-failed-execution-data) REST API endpoint to retrieve failed test executions for a specific test run in Buildkite Test Engine. Optionally retrieves the expanded failure details such as full error messages and stack traces.",
        "scope": "read_suites"
      },
      {
        "tool": "get_build_test_engine_runs",
        "description": "Get Test Engine runs data for a specific build in Buildkite Pipelines. This can be used to look up test runs."
      }
    ].select { |field| field[:tool] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:tool] %></code>
         </td>
        <td>
          <p><%= render_markdown(text: field[:description]) %></p>
          <% if field[:scope] %>
            <p>Required <a href="/docs/apis/managing-api-tokens#token-scopes">token scope</a>: <code><%= field[:scope] %></code>.</p>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

## Smart caching and storage

To improve performance in accessing log data from the Buildkite platform, the Buildkite MCP server downloads and stores the [logs of jobs](/docs/apis/rest-api/jobs#get-a-jobs-log-output) in [Parquet file format](https://parquet.apache.org/docs/file-format/) to either of the following areas.

- For the [local MCP server](/docs/apis/mcp-server#types-of-mcp-servers-local-mcp-server), on the file system of the machine running the MCP server.

- For the [remote MCP server](/docs/apis/mcp-server#types-of-mcp-servers-remote-mcp-server), in a dedicated area of the Buildkite platform.

These Parquet log files are stored and managed by the MCP server and all interactions with these files are managed by the [MCP server's log tools](#available-mcp-tools-logs).

If the job is in a terminal state (for example, the job was completed successfully, had failed, or was canceled), then the job's Parquet format logs are downloaded and stored indefinitely.

If the job is in a non-terminal state (for example, the job is still running or is blocked), then the job's Parquet logs are retained for 30 seconds.

### Storage locations

If you are running the [local MCP server](/docs/apis/mcp-server/local/installing), the following table indicates the default locations for these Parquet log files.

<table>
  <thead>
    <tr>
      <th style="width:55%">Environment</th>
      <th style="width:45%">Default Parquet log file location</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "environment": "A physical machine (for example, a desktop or laptop computer)",
        "default_location": "The `.bklog` sub-directory of the home directory."
      },
      {
        "environment": "A containerized environment (for example, using Docker or Kubernetes)",
        "default_location": "The `/tmp/bklog` sub-directory of the file system's root directory level."
      }
    ].select { |field| field[:environment] }.each do |field| %>
      <tr>
        <td>
          <p><%= field[:environment] %></p>
         </td>
        <td>
          <p><%= render_markdown(text: field[:default_location]) %></p>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

You can override these default Parquet log file locations through the `$BKLOG_CACHE_URL` environment variable, which can be used with either a local file system path or an `s3://` path, where the latter may be better suited for pipeline usage, for example:

```bash
# Local development with persistent cache
export BKLOG_CACHE_URL="file:///Users/me/bklog-cache"

# Shared cache across build agents
export BKLOG_CACHE_URL="s3://ci-logs-cache/buildkite/"
```

## The AGENTS.md file

The [`AGENTS.md` file](https://agents.md/) is used to help guide your AI tool or agent to work on a project. Depending on which AI tool or agent you use, this file might use a different name, such as `CLAUDE.md` for Claude Code.

Buildkite recommends configuring your project's `AGENTS.md` file by adding a hint like the following to help your AI tool or agent to use the Buildkite MCP server and its tools with your project:

```markdown
- **CI/CD**: `my-buildkite-organization` Buildkite organization, `my-pipeline` pipeline slug for build and test (`.buildkite/pipeline.yml`), `my-pipeline-release` pipeline slug for releases (`.buildkite/pipeline.release.yml`)
```

You should replace your Buildkite organization, pipeline slugs, and pipeline file names with those applicable to your project.

Add this hint to an appropriate section within your `AGENTS.md` file. For example, for a typical development project, you might add this hint to a series of existing ones in a section about about architecture.
