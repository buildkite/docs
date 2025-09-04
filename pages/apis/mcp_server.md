# Buildkite MCP server

The [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) is an open protocol standard on how to connect AI tools and models to a variety of other systems and data sources.

Buildkite provides its own [open-source MCP server](https://github.com/buildkite/buildkite-mcp-server) to expose Buildkite product data (for example, data from pipelines, builds, and jobs for Pipelines, as well as from test data for Test Engine) for AI tools, editors and other products to interact with.

Learn more about what Buildkite's MCP server is capable of in [Available tools](#available-tools).

To start using Buildkite's MCP server, first determine which [type of Buildkite MCP server](#types-of-mcp-servers) to work with. This next section provides an overview of the differences between these MCP server types and how they are configured. From there, you can proceed to install the MCP server (if necessary) and proceed to configure your AI tool with the MCP server.

## Types of MCP servers

Buildkite provides both a _remote_ and _local_ MCP server:

- The remote MCP server is one that Buildkite hosts, and is available for all customers to access at the following URL:

    ```url
    https://mcp.buildkite.com/mcp
    ```

- The local MCP server is one that you install yourself on your own machine. Learn more about how to set up and install a local Buildkite MCP server in [Installing the Buildkite MCP server locally](/docs/apis/mcp-server/installing).

The MCP server is built on and interacts with Buildkite's REST API. Therefore, as part of installing a local Buildkite MCP server, you'll also need to [configure an API access token with the required scopes](/docs/apis/mcp-server/installing#configure-an-api-access-token) that your local MCP server will use.

If you are using Buildkite's remote MCP server, you do not need to configure an API access token. Instead, you only require a Buildkite user account, and an OAuth token representing this account is used for authentication, along with access permission scopes which are pre-set by the Buildkite platform, for authorization. This OAuth token auth process takes place when configuring your AI tool with the remote MCP server.

Once you have established which Buildkite MCP server to use (remote or local) and if local, have [installed the MCP server](/docs/apis/mcp-server/installing#install-and-run-the-server-locally) and [configured its API access token](/docs/apis/mcp-server/installing#configure-an-api-access-token), you can then proceed to [configure your AI tools](/docs/apis/mcp-server/configuring-ai-tools) to work with this MCP server.

## Available tools

The Buildkite MCP server exposes the following [MCP tools](https://modelcontextprotocol.io/docs/learn/server-concepts#tools-ai-actions).

### User and authentication

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
        "description": "Get information about the current API access token including its scopes and UUID.",
        "link_text": "Get the current token",
        "link": "/docs/apis/rest-api/access-token#get-the-current-token"
      },
      {
        "tool": "current_user",
        "description": "Get details about the user account that owns the API token, including name, email, avatar, and account creation date.",
        "link_text": "Get the current user",
        "link": "/docs/apis/rest-api/user#get-the-current-user"
      },
      {
        "tool": "user_token_organization",
        "description": "Get the organization associated with the user token used for this request.",
        "link_text": "Get an organization",
        "link": "/docs/apis/rest-api/organizations#get-an-organization"
      }
    ].select { |field| field[:tool] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:tool] %></code>
         </td>
        <td>
          <p><%= field[:description] %></p>
          <% if field[:link] %>
            <p>Learn more about this from <%= link_to field[:link_text], field[:link] %> of the REST API docs.</p>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

### Organizations and clusters

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
        "description": "List all clusters in an organization with their names, descriptions, default queues, and creation details.",
        "link_text": "List clusters",
        "link": "/docs/apis/rest-api/clusters#clusters-list-clusters"
      },
      {
        "tool": "get_cluster",
        "description": "Get detailed information about a specific cluster including its name, description, default queue, and configuration.",
        "link_text": "Get a cluster",
        "link": "/docs/apis/rest-api/clusters#clusters-get-a-cluster"
      },
      {
        "tool": "list_cluster_queues",
        "description": "List all queues in a cluster with their keys, descriptions, dispatch status, and agent configuration.",
        "link_text": "List queues",
        "link": "/docs/apis/rest-api/clusters#queues-list-queues"
      },
      {
        "tool": "get_cluster_queue",
        "description": "Get detailed information about a specific queue including its key, description, dispatch status, and hosted agent configuration.",
        "link_text": "Get a queue",
        "link": "/docs/apis/rest-api/clusters#queues-get-a-queue"
      }
    ].select { |field| field[:tool] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:tool] %></code>
         </td>
        <td>
          <p><%= field[:description] %></p>
          <% if field[:link] %>
            <p>Learn more about this from <%= link_to field[:link_text], field[:link] %> of the REST API docs.</p>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

### Pipelines

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
        "description": "List all pipelines in an organization with their basic details, build counts, and current status.",
        "link_text": "List pipelines",
        "link": "/docs/apis/rest-api/pipelines#list-pipelines"
      },
      {
        "tool": "get_pipeline",
        "description": "Get detailed information about a specific pipeline including its configuration, steps, environment variables, and build statistics.",
        "link_text": "Get a pipeline",
        "link": "/docs/apis/rest-api/pipelines#get-a-pipeline"
      },
      {
        "tool": "create_pipeline",
        "description": "Set up a new CI/CD pipeline in Buildkite with YAML configuration, repository connection, and cluster assignment.",
        "link_text": "Create a YAML pipeline",
        "link": "/docs/apis/rest-api/pipelines#create-a-yaml-pipeline"
      },
      {
        "tool": "update_pipeline",
        "description": "Modify an existing Buildkite pipeline's configuration, repository, settings, or metadata.",
        "link_text": "Update a pipeline",
        "link": "/docs/apis/rest-api/pipelines#update-a-pipeline"
      }
    ].select { |field| field[:tool] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:tool] %></code>
         </td>
        <td>
          <p><%= field[:description] %></p>
          <% if field[:link] %>
            <p>Learn more about this from <%= link_to field[:link_text], field[:link] %> of the REST API docs.</p>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

### Builds

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
        "description": "List all builds for a pipeline with their status, commit information, and metadata.",
        "link_text": "List all builds",
        "link": "/docs/apis/rest-api/builds#list-all-builds"
      },
      {
        "tool": "get_build",
        "description": "Get detailed information about a specific build including its jobs, timing, and execution details.",
        "link_text": "Get a build",
        "link": "/docs/apis/rest-api/builds#get-a-build"
      },
      {
        "tool": "get_build_test_engine_runs",
        "description": "Get Test Engine runs data for a specific build in Buildkite Pipelines. This can be used to look up test runs."
      },
      {
        "tool": "create_build",
        "description": "Trigger a new build on a Buildkite pipeline for a specific commit and branch, with optional environment variables, metadata, and author information.",
        "link_text": "Create a build",
        "link": "/docs/apis/rest-api/builds#create-a-build"
      },
      {
        "tool": "wait_for_build",
        "description": "Wait for a specific build to complete."
      }
    ].select { |field| field[:tool] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:tool] %></code>
         </td>
        <td>
          <p><%= field[:description] %></p>
          <% if field[:link] %>
            <p>Learn more about this from <%= link_to field[:link_text], field[:link] %> of the REST API docs.</p>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

### Jobs

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
        "tool": "get_jobs",
        "description": "Get all jobs for a specific build including their state, timing, commands, and execution details."
      },
      {
        "tool": "get_job_logs",
        "description": "Get the log output and metadata for a specific job, including content, size, and header timestamps. Automatically saves to file for large logs to avoid token limits.",
        "link_text": "Get a job's log output",
        "link": "/docs/apis/rest-api/jobs#get-a-jobs-log-output"
      },
      {
        "tool": "unblock_job",
        "description": "Unblock a blocked job in a Buildkite build to allow it to continue execution.",
        "link_text": "Unblock a job",
        "link": "/docs/apis/rest-api/jobs#unblock-a-job"
      }
    ].select { |field| field[:tool] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:tool] %></code>
         </td>
        <td>
          <p><%= field[:description] %></p>
          <% if field[:link] %>
            <p>Learn more about this from <%= link_to field[:link_text], field[:link] %> of the REST API docs.</p>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

### Logs

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
        "description": "Show the last N entries from the log file."
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
          <p><%= field[:description] %></p>
          <% if field[:link] %>
            <p>Learn more about this from <%= link_to field[:link_text], field[:link] %> of the REST API docs.</p>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

<h4 id="smart-caching-and-storage">Smart caching and storage</h4>

### Artifacts

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
        "description": "List a build's artifacts across all of its jobs, including file details, paths, sizes, MIME types, and download URLs.",
        "link_text": "List artifacts for a build",
        "link": "/docs/apis/rest-api/artifacts#list-artifacts-for-a-build"
      },
      {
        "tool": "get_artifact",
        "description": "Get detailed information about a specific artifact including its metadata, file size, SHA-1 hash, and download URL.",
        "link_text": "Get an artifact",
        "link": "/docs/apis/rest-api/artifacts#get-an-artifact"
      }
    ].select { |field| field[:tool] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:tool] %></code>
         </td>
        <td>
          <p><%= field[:description] %></p>
          <% if field[:link] %>
            <p>Learn more about this from <%= link_to field[:link_text], field[:link] %> of the REST API docs.</p>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

### Annotations

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
        "description": "List all annotations for a build, including their context, style (success/info/warning/error), rendered HTML content, and creation timestamps.",
        "link_text": "List annotations for a build",
        "link": "/docs/apis/rest-api/annotations#list-annotations-for-a-build"
      }
    ].select { |field| field[:tool] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:tool] %></code>
         </td>
        <td>
          <p><%= field[:description] %></p>
          <% if field[:link] %>
            <p>Learn more about this from <%= link_to field[:link_text], field[:link] %> of the REST API docs.</p>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

### Test Engine

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
        "description": "Get a specific test in Buildkite Test Engine. This provides additional metadata for failed test executions.",
        "link_text": "Get a test",
        "link": "/docs/apis/rest-api/test-engine/tests#get-a-test"
      },
      {
        "tool": "list_test_runs",
        "description": "List all test runs for a test suite in Buildkite Test Engine.",
        "link_text": "List all runs",
        "link": "/docs/apis/rest-api/test-engine/runs#list-all-runs"
      },
      {
        "tool": "get_test_run",
        "description": "Get a specific test run in Buildkite Test Engine.",
        "link_text": "Get a run",
        "link": "/docs/apis/rest-api/test-engine/runs#get-a-run"
      },
      {
        "tool": "get_failed_executions",
        "description": "Get failed test executions for a specific test run in Buildkite Test Engine. Optionally get the expanded failure details such as full error messages and stack traces.",
        "link_text": "Get failed execution data",
        "link": "/docs/apis/rest-api/test-engine/runs#get-failed-execution-data"
      }
    ].select { |field| field[:tool] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:tool] %></code>
         </td>
        <td>
          <p><%= field[:description] %></p>
          <% if field[:link] %>
            <p>Learn more about this from <%= link_to field[:link_text], field[:link] %> of the REST API docs.</p>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>
