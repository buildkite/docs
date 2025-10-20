# Toolsets

The [Buildkite MCP server](/docs/apis/mcp-server) organizes its [MCP tools](/docs/apis/mcp-server/tools#available-mcp-tools) into logical groups of _toolsets_, each of which can be selectively enabled on the MCP server, based on your requirements.

## Available toolsets

Each toolset groups related [MCP tools](/docs/apis/mcp-server/tools#available-mcp-tools), which interact with specific areas of the Buildkite platform. You can enable these individual toolsets by configuring them for the [remote](#configuring-the-remote-mcp-server) or [local](#configuring-the-local-mcp-server) Buildkite MCP server. Doing so effectively restricts your AI tool's or agent's access to the Buildkite API, based on each set of MCP tools made available through the MCP server's configured toolsets.

Also, see [Recommended toolset configurations](#recommended-toolset-configurations) for details on how to configure different combinations of toolsets for different use cases.

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
        "description": "[User, authentication, and Buildkite organization](/docs/apis/mcp-server/tools#available-mcp-tools-user-authentication-and-buildkite-organization)",
        "tools": "current_user, user_token_organization, access_token"
      },
      {
        "toolset": "clusters",
        "description": "[Buildkite clusters](/docs/apis/mcp-server/tools#available-mcp-tools-buildkite-clusters) management",
        "tools": "get_cluster, list_clusters, get_cluster_queue, list_cluster_queues"
      },
      {
        "toolset": "pipelines",
        "description": "[Pipelines](/docs/apis/mcp-server/tools#available-mcp-tools-pipelines) management",
        "tools": "get_pipeline, list_pipelines, create_pipeline, update_pipeline"
      },
      {
        "toolset": "builds",
        "description": "[Builds](/docs/apis/mcp-server/tools#available-mcp-tools-builds) operations",
        "tools": "list_builds, get_build, create_build, wait_for_build, get_jobs, unblock_job"
      },
      {
        "toolset": "logs",
        "description": "[Logs](/docs/apis/mcp-server/tools#available-mcp-tools-logs) processing",
        "tools": "search_logs, tail_logs, read_logs, get_logs_info"
      },
      {
        "toolset": "artifacts",
        "description": "[Artifacts](/docs/apis/mcp-server/tools#available-mcp-tools-artifacts) management",
        "tools": "list_artifacts, get_artifact"
      },
      {
        "toolset": "annotations",
        "description": "[Annotations](/docs/apis/mcp-server/tools#available-mcp-tools-annotations) management",
        "tools": "list_annotations"
      },
      {
        "toolset": "tests",
        "description": "[Test Engine](/docs/apis/mcp-server/tools#available-mcp-tools-test-engine)",
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

## Configuring the remote MCP server

You can configure toolset availability for the [remote MCP server](/docs/apis/mcp-server#types-of-mcp-servers-remote-mcp-server) by adding the required [toolset names](#available-toolsets) as part of an [extension to the remote MCP server's URL](#configuring-the-remote-mcp-server-using-a-url-extension) (for a single toolset only), or alternatively, and for multiple toolsets, as part of the [header of requests](#configuring-the-remote-mcp-server-using-headers) sent to the Buildkite platform from the remote MCP server.

You can also configure [read-only access](/docs/apis/mcp-server#read-only-remote-mcp-server) to the remote MCP server as part of this process, and when configuring multiple toolsets, be [selective over which ones have read-only access](#configuring-the-remote-mcp-server-selective-read-only-access-to-toolsets).

### Using a URL extension

When [configuring your AI tool with the remote MCP server](/docs/apis/mcp-server/remote/configuring-ai-tools), you can enable a single toolset by appending `/x/{toolset.name}` to the end of the remote MCP server URL (`https://mcp.buildkite.com/mcp`), where `{toolset.name}` is the name of the [toolset](#available-toolsets) you want to enable. To enforce read-only access, append `/readonly` to the end of `/x/{toolset.name}`.

#### Examples

To enable the `builds` toolset for the remote MCP server, configure your AI tool with the following URL:

```url
https://mcp.buildkite.com/mcp/x/builds
```

To enforce read-only access to this remote MCP server toolset, configure your AI tool with this URL instead:

```url
https://mcp.buildkite.com/mcp/x/builds/readonly
```

> 📘
> The remote MCP server URL `https://mcp.buildkite.com/mcp` without any further extension provides unrestricted access to the Buildkite API, restricted only by all applicable [token scopes](/docs/apis/managing-api-tokens#token-scopes) available to your Buildkite user account's access token, and what you can access on the Buildkite platform.

### Using headers

When [configuring your AI tool with the remote MCP server](/docs/apis/mcp-server/remote/configuring-ai-tools), you can enable one or more toolsets by specifying their [toolset names](#available-toolsets) as a single-line comma-separated list value for the `X-Buildkite-Toolsets` header of requests sent to the Buildkite platform from the remote MCP server. To enforce read-only access, also add the `X-Buildkite-Readonly` header with a value of `true`.

#### Examples

To enable the `builds` toolset for the remote MCP server, configure your AI tool with the standard remote MCP server URL:

```url
https://mcp.buildkite.com/mcp
```

along with the following request header:

```url
X-Buildkite-Toolsets: builds
```

To enable the `user`, `pipelines`, and `builds` toolsets for the remote MCP server, configure your AI tool with the standard remote MCP server URL, and the following request header:

```url
X-Buildkite-Toolsets: user,pipelines,builds
```

To enforce read-only access across all of these toolsets, use the following request headers:

```url
X-Buildkite-Toolsets: user,pipelines,builds
X-Buildkite-Readonly: true
```

You can also be [selective with read-only access to toolsets](#configuring-the-remote-mcp-server-selective-read-only-access-to-toolsets).

> 📘
> Learn more about how to configure different AI tools with these header configurations in [Configuring AI tools with the remote MCP server](/docs/apis/mcp-server/remote/configuring-ai-tools).
> Omitting the `X-Buildkite-Toolsets` and `X-Buildkite-Readonly` headers from these configurations provides unrestricted access to the Buildkite API, restricted only by all applicable [token scopes](/docs/apis/managing-api-tokens#token-scopes) available to your Buildkite user account's access token, and what you can access on the Buildkite platform.

### Selective read-only access to toolsets

If you want to enable multiple [toolsets](#available-toolsets), but be selective over which ones of these have read-only access, you'll need to create two remote MCP server configurations ([using headers](#configuring-the-remote-mcp-server-using-headers)) for your AI tool—one for toolsets with both read and write access, and the other for toolsets with read-only access.

#### Examples

To enable the `user` and `pipelines` toolsets with read-only access, and the `builds` toolset with both read and write access, create two remote MCP server configurations with the standard URL:

```url
https://mcp.buildkite.com/mcp
```

For the `user` and `pipelines` toolsets with read-only access to the remote MCP server, implement the request header:

```url
X-Buildkite-Toolsets: user,pipelines
X-Buildkite-Readonly: true
```

And for the `builds` toolset with read and write access to the remote MCP server, implement the request header:

```url
X-Buildkite-Toolsets: builds
```

You could also [use the URL extension](#configuring-the-remote-mcp-server-using-a-url-extension) approach to do this by implementing three separate remote MCP server configurations, each of whose URLs are respectively:

```url
https://mcp.buildkite.com/mcp/x/user/readonly
https://mcp.buildkite.com/mcp/x/pipelines/readonly
https://mcp.buildkite.com/mcp/x/builds
```

> 📘
> Ensure you provide an appropriate name for each MCP server configuration to make it easier to identify which toolsets and level of access each server has to the Buildkite API.
> For example, instead of `buildkite` as an MCP server configuration name, use more descriptive names, for example: `buildkite-read-only-user-pipelines-toolsets` and `buildkite-builds-toolset`.

## Configuring the local MCP server

You can configure toolset availability for the [local MCP server](/docs/apis/mcp-server#types-of-mcp-servers-local-mcp-server) by adding the required [toolset names](#available-toolsets) as part of an environment variable or command-line flag when either the [Docker](#configuring-the-local-mcp-server-using-docker) or [binary](#configuring-the-local-mcp-server-using-the-binary) version of the local MCP server is started.

You can also configure read-only access to the local MCP server as part of this process, and when configuring multiple toolsets, be [selective over which ones have read-only access](#configuring-the-local-mcp-server-selective-read-only-access-to-toolsets).

### Using Docker

When [configuring your AI tool with the local MCP server](/docs/apis/mcp-server/local/configuring-ai-tools) running in [Docker](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-using-docker), you can enable one or more toolsets by adding the `BUILDKITE_TOOLSETS` environment variable to the `docker run` command, and specifying the [toolset names](#available-toolsets) as a comma-separated list value for this variable. To enforce read-only access, also add the `BUILDKITE_READ_ONLY` environment variable with a value of `true` to this command.

#### Examples

To enable the `builds` toolset for the local MCP server, configure the `docker run` command with:

```bash
docker run --rm -e BUILDKITE_API_TOKEN=bkua_xxxxx -e BUILDKITE_TOOLSETS="builds" buildkite/mcp-server stdio
```

To enable the `user`, `pipelines`, and `builds` toolsets for the local MCP server, and enforce read-only access across all of these toolsets, configure the `docker run` command with:

```bash
docker run --rm -e BUILDKITE_API_TOKEN=bkua_xxxxx -e BUILDKITE_TOOLSETS="user,pipelines,builds" -e BUILDKITE_READ_ONLY="true" buildkite/mcp-server stdio
```

You can also be [selective with read-only access to toolsets](#configuring-the-local-mcp-server-selective-read-only-access-to-toolsets).

Most [AI tool or agent configurations for the local MCP server](/docs/apis/mcp-server/local/configuring-ai-tools) require configuring the `docker run` command's environment variables with both an `args` array and `env` object in its JSON configuration file. Hence, the example above would be configured in these JSON files as:

```json
{
  ...
    "buildkite-read-only-toolsets": {
      "command": "docker",
      "args": [
        "run", "--pull=always", "-q", "-i", "--rm",
        "-e", "BUILDKITE_API_TOKEN",
        "-e", "BUILDKITE_TOOLSETS",
        "-e", "BUILDKITE_READ_ONLY",
        "buildkite/mcp-server",
        "stdio"
      ],
      "env": {
        "BUILDKITE_API_TOKEN": "bkua_xxxxx",
        "BUILDKITE_TOOLSETS": "user,pipelines,builds",
        "BUILDKITE_READ_ONLY": "true"
      }
    }
  ...
}
```

> 📘
> Specifying `BUILDKITE_TOOLSETS` with a value of `all` enables all available toolsets, which is the default value for this environment variable when omitted.
> Omitting the `BUILDKITE_TOOLSETS` and `BUILDKITE_READ_ONLY` environment variables from these `docker run` commands provides unrestricted access to the Buildkite API, restricted only by all applicable [token scopes](/docs/apis/managing-api-tokens#token-scopes) available to the Buildkite user account's API access token, and what it can access on the Buildkite platform.

### Using the binary

When [configuring your AI tool with the local MCP server](/docs/apis/mcp-server/local/configuring-ai-tools) running as a [pre-built](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-using-a-pre-built-binary) or [source-built](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-building-from-source) binary, you can enable one or more toolsets by adding the `--enabled-toolsets` flag to the `buildkite-mcp-server` command, and specifying the [toolset names](#available-toolsets) as a comma-separated list value for this flag. To enforce read-only access, also add the `--read-only` flag.

#### Examples

To enable the `builds` toolset for the local MCP server, configure the `buildkite-mcp-server` command with:

```bash
buildkite-mcp-server stdio --api-token=bkua_xxxxx --enabled-toolsets="builds"
```

To enable the `user`, `pipelines`, and `builds` toolsets for the local MCP server, and enforce read-only access across all of these toolsets, configure the `buildkite-mcp-server` command with:

```bash
buildkite-mcp-server stdio --api-token=bkua_xxxxx --enabled-toolsets="user,pipelines,builds" --read-only
```

You can also be [selective with read-only access to toolsets](#configuring-the-local-mcp-server-selective-read-only-access-to-toolsets).

Most [AI tool or agent configurations for the local MCP server](/docs/apis/mcp-server/local/configuring-ai-tools) require configuring the `buildkite-mcp-server` command flags with an `env` object in its JSON configuration file. Hence, the example above would be configured in these JSON files as:

```json
{
  ...
    "buildkite-read-only-toolsets": {
      "command": "buildkite-mcp-server",
      "args": ["stdio"],
      "env": {
        "BUILDKITE_API_TOKEN": "bkua_xxxxx",
        "BUILDKITE_TOOLSETS": "user,pipelines,builds",
        "BUILDKITE_READ_ONLY": "true"
      }
    }
  ...
}
```

> 📘
> Specifying `BUILDKITE_TOOLSETS` environment variable or the `--enabled-toolsets` flag with a value of `all` enables all available toolsets, which is the default value for this environment variable or flag when omitted.
> Omitting the `BUILDKITE_TOOLSETS` and `BUILDKITE_READ_ONLY` environment variables (or `--enabled-toolsets` and `--read-only` flags) from these `buildkite-mcp-server` commands provides unrestricted access to the Buildkite API, restricted only by all applicable [token scopes](/docs/apis/managing-api-tokens#token-scopes) available to the Buildkite user account's API access token, and what it can access on the Buildkite platform.

### Selective read-only access to toolsets

If you want to enable multiple [toolsets](#available-toolsets), but be selective over which ones of these have read-only access, you'll need to create two local MCP servers for your AI tool or agent, each with different configurations—one for toolsets with both read and write access, and the other for toolsets with read-only access.

#### Examples

To enable the `user` and `pipelines` toolsets with read-only access, and the `builds` toolset with both read and write access, create two local MCP servers (in this case, running in Docker) each with these different configurations.

For the `user` and `pipelines` toolsets with read-only access, configure the local MCP server's `docker run` command with:

```bash
docker run --rm -e BUILDKITE_API_TOKEN=bkua_xxxxx -e BUILDKITE_TOOLSETS="user,pipelines" -e BUILDKITE_READ_ONLY="true" buildkite/mcp-server stdio
```

And for the `builds` toolset with read and write access, configure the local MCP server's `docker run` command with:

```bash
docker run --rm -e BUILDKITE_API_TOKEN=bkua_xxxxx -e BUILDKITE_TOOLSETS="builds" buildkite/mcp-server stdio
```

> 📘
> When [configuring your AI tool or agent with these local MCP servers](/docs/apis/mcp-server/local/configuring-ai-tools), ensure you provide an appropriate name for each MCP server configuration to make it easier to identify which toolsets and level of access each server has to the Buildkite API.
> For example, instead of:
> `"buildkite": { ... }`
> Use more descriptive names, for example:
> `"buildkite-read-only-user-pipelines-toolsets": { ... }`
> and
> `"buildkite-builds-toolset": { ... }`

## Recommended toolset configurations

Once you've learned how to configure the [remote](#configuring-the-remote-mcp-server) or [local](#configuring-the-local-mcp-server) MCP server for toolsets, you can configure different combinations of [toolsets](#available-toolsets) for different use cases.

### Recommended minimum baseline

As a recommended minimum baseline, always include the `user` toolset as its tools provide essential user and organization information that many AI workflows depend on.

### CI/CD management

For CD/CD management, set the following MCP server toolsets:

- `user`
- `pipelines`
- `builds`

### Debugging and analysis

For debugging and analysis of pipeline builds, set the following MCP server toolsets:

- `user`
- `builds`
- `logs`
- `tests`
- `annotations`

### Full access

For full access to the Buildkite MCP server's toolsets:

- If you are using the [remote MCP server](#configuring-the-remote-mcp-server), don't configure any toolsets, and instead, only configure the remote MCP server URL: `https://mcp.buildkite.com/mcp`.
- If you are using the [local MCP server](#configuring-the-local-mcp-server), also don't configure any toolsets, or, if you want to be explicit about this in your configuration, set the `BUILDKITE_TOOLSETS` environment variable or the `--enabled-toolsets` flag with a value of `all`.
