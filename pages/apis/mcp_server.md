# Buildkite MCP server overview

The [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) is an open protocol standard on how to connect artificial intelligence (AI) tools, agents and models to a variety of other systems and data sources.

Buildkite provides its own [open-source MCP server](https://github.com/buildkite/buildkite-mcp-server) to expose Buildkite product data (for example, data from pipelines, builds, and jobs for Pipelines, including test data for Test Engine) for AI tools, editors, agents, and other products to interact with.

Buildkite's MCP server is built on and interacts with the [Buildkite REST API](/docs/apis/rest-api). Learn more about what the MCP server is capable of in [Available MCP tools](#available-mcp-tools).

To start using Buildkite's MCP server, first determine which [type of Buildkite MCP server](#types-of-mcp-servers) to work with. This next section provides an overview of the differences between these MCP server types and how they need to be configured.

Once you have established which Buildkite MCP server to use (remote or local) and if local, have [installed the MCP server](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally) and [configured its API access token](/docs/apis/mcp-server/local/installing#configure-an-api-access-token), you can then proceed to configure your AI tools to work with the [remote](/docs/apis/mcp-server/remote/configuring-ai-tools) (recommended) or [local](/docs/apis/mcp-server/local/configuring-ai-tools) MCP server.

## Types of MCP servers

Buildkite provides both a [remote](#types-of-mcp-servers-remote-mcp-server) and [local](#types-of-mcp-servers-local-mcp-server) MCP server.

### Remote MCP server

The _remote_ MCP server is one that Buildkite hosts, and is available for all users to access at the following URL:

```url
https://mcp.buildkite.com/mcp
```

This type of MCP server is typically used by AI tools that you interact with directly from a prompt, and it's the recommended MCP server type to use.

#### What it's suitable for

The remote MCP server is suitable for personal usage with an AI tool, as it has the following advantages.

- You don't need to configure an API access token, which poses a potential security risk if leaked.

    Instead, you only require your Buildkite user account, and the Buildkite platform issues a short-lived OAuth access token, representing your user account for authentication, along with both _read_ and _write_ access permission scopes which are pre-set by the Buildkite platform to provide the authorization. This OAuth token auth process takes place after [configuring your AI tool with the remote MCP server](/docs/apis/mcp-server/remote/configuring-ai-tools) and connecting to it.

    **Notes:**
    * OAuth access tokens are valid for 12 hours, and the refresh tokens are valid for seven days.
    * These OAuth access tokens provide both read and write access to the remote MCP server. If you'd prefer to restrict your access to read-only, a [read-only version of the MCP server](#read-only-remote-mcp-server) is also available.

- There is no need to install or upgrade any software. Since the remote MCP server undergoes frequent updates, you get access to new features and fixes automatically.

#### What it's not suitable for

The remote MCP server is not suitable for use in automated workflows, where running a specific version of the MCP server is important for generating consistent results.

<h4 id="read-only-remote-mcp-server">Read-only remote MCP server</h4>

Buildkite also provides a version of the remote MCP server with read-only access to the Buildkite platform. This version is available for all users to access at the following URL:

```
https://mcp.buildkite.com/mcp/readonly
```

This remote MCP server version issues a short-lived OAuth access token for your Buildkite user account, along with _read-only_ access permission scopes pre-set by the Buildkite platform. Hence, when using this remote MCP server, only [MCP tools](#available-mcp-tools) that work with read-only access are available.

### Local MCP server

The _local_ MCP server is one that you install yourself directly on your own machine or in a containerized environment.

This type of MCP server is typically used by AI tools as _AI agents_, which an automated system or workflow, such as a Buildkite pipeline, can interact with. Such AI agent interactions are usually shell-based.

#### What it's suitable for

The local MCP server enables automated workflows (for example, using [Buildkite Pipelines](/docs/pipelines)), where running a specific version of the MCP server is important for generating consistent results.

Also, if you want to contribute to the [Buildkite MCP server project](https://github.com/buildkite/buildkite-mcp-server), the local MCP server allows you to run and test your changes locally.

#### What it's not suitable for

The local MCP server is not suitable for personal usage with an AI tool, as it has the following disadvantages.

- Since your Buildkite API access token is used for authentication and authorization to the MCP server, you'll need to manage the security (for example, leak prevention) of this token and its storage in plain text.

- You'll also need to manage upgrades to the MCP server yourself, especially if you choose to install the binary version of the local MCP server, which means you may miss out on new and updated features offered automatically through the [remote MCP server](#types-of-mcp-servers-remote-mcp-server).

If you intend to use the local Buildkite MCP server, learn more about how to set up and install it in [Installing the Buildkite MCP server](/docs/apis/mcp-server/local/installing).

## Available MCP tools

The Buildkite MCP server exposes the following categories of _MCP tools_.

The names of these tools (for example, `list_pipelines`) typically do not need to be used in direct prompts to AI tools or agents. However, each MCP tool name is designed to be understandable, so that it can be used directly in a prompt when you want your AI tool or agent to explicitly use that MCP tool to query the Buildkite platform.

Learn more about MCP tools in the [Core Server Features](https://modelcontextprotocol.io/docs/learn/server-concepts#core-server-features) and [Tools](https://modelcontextprotocol.io/docs/learn/server-concepts#tools) sections of the [Understanding MCP servers](https://modelcontextprotocol.io/docs/learn/server-concepts) page in the [Model Context Protocol](https://modelcontextprotocol.io/docs/getting-started/intro) docs.

> 📘
> While Buildkite's MCP server makes calls to the Buildkite REST API, note that in some cases, only a subset of the resulting fields are returned in the response to your AI tool or agent. This is done to reduce noise for your AI tool / agent, as well as reduce costs associated with text tokenization of the response.

### User and authentication

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
            <p>See <%= link_to field[:link_text], field[:link] %> of the REST API docs for more information.</p>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

### Organizations and clusters

These MCP tools are used to retrieve details about the [clusters](/docs/pipelines/clusters/manage-clusters) and their [queues](/docs/pipelines/clusters/manage-queues) configured in your Buildkite organization. Learn more about clusters in [Clusters overview](/docs/pipelines/clusters).

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
        "link": "/docs/apis/rest-api/clusters/queues#list-queues"
      },
      {
        "tool": "get_cluster_queue",
        "description": "Get detailed information about a specific queue including its key, description, dispatch status, and hosted agent configuration.",
        "link_text": "Get a queue",
        "link": "/docs/apis/rest-api/clusters/queues#get-a-queue"
      }
    ].select { |field| field[:tool] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:tool] %></code>
         </td>
        <td>
          <p><%= field[:description] %></p>
          <% if field[:link] %>
            <p>See <%= link_to field[:link_text], field[:link] %> of the REST API docs for more information.</p>
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
            <p>See <%= link_to field[:link_text], field[:link] %> of the REST API docs for more information.</p>
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
        "tool": "create_build",
        "description": "Trigger a new build on a Buildkite pipeline for a specific commit and branch, with optional environment variables, metadata, and author information.",
        "link_text": "Create a build",
        "link": "/docs/apis/rest-api/builds#create-a-build"
      },
      {
        "tool": "wait_for_build",
        "description": "Wait for a specific build to be completed. This tool calls the <em>Get a build</em> endpoint to retrieve the status of the build from its logs. If the build is still running, <code>wait_for_build</code> calls the Get a build endpoint with increasingly less frequency, to reduce text tokenization usage and traffic, until the returned build status is completed.",
        "link_text": "Get a build",
        "link": "/docs/apis/rest-api/builds#get-a-build"
      }
    ].select { |field| field[:tool] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:tool] %></code>
         </td>
        <td>
          <p><%= field[:description] %></p>
          <% if field[:link] %>
            <p>See <%= link_to field[:link_text], field[:link] %> of the REST API docs for more information.</p>
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
            <p>See <%= link_to field[:link_text], field[:link] %> of the REST API docs for more information.</p>
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
          <p><%= field[:description] %></p>
          <% if field[:link] %>
            <p>See <%= link_to field[:link_text], field[:link] %> of the REST API docs for more information.</p>
          <% end %>
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
            <p>See <%= link_to field[:link_text], field[:link] %> of the REST API docs for more information.</p>
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
            <p>See <%= link_to field[:link_text], field[:link] %> of the REST API docs for more information.</p>
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
          <p><%= field[:description] %></p>
          <% if field[:link] %>
            <p>See <%= link_to field[:link_text], field[:link] %> of the REST API docs for more information.</p>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

## Smart caching and storage

To improve performance in accessing log data from the Buildkite platform, the Buildkite MCP server downloads and stores the [logs of jobs](/docs/apis/rest-api/jobs#get-a-jobs-log-output) in [Parquet file format](https://parquet.apache.org/docs/file-format/) to either of the following areas.

- For the [local MCP server](#types-of-mcp-servers-local-mcp-server), on the file system of the machine running the MCP server.

- For the [remote MCP server](#types-of-mcp-servers-remote-mcp-server), in a dedicated area of the Buildkite platform.

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
        "default_location": "The <code>.bklog</code> sub-directory of the home directory."
      },
      {
        "environment": "A containerized environment (for example, using Docker or Kubernetes)",
        "default_location": "The <code>/tmp/bklog</code> sub-directory of the file system's root directory level."
      }
    ].select { |field| field[:environment] }.each do |field| %>
      <tr>
        <td>
          <p><%= field[:environment] %></p>
         </td>
        <td>
          <p><%= field[:default_location] %></p>
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

