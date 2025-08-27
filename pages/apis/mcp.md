# Buildkite Model Context Protocol server

A [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) is an open protocol standard on how to connect AI models to a variety of tools and data sources.

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
- All [read-only](#configure-required-api-access-token-scopes-all-read-only-functionality) scopes.

You can also [create a new Buildkite API access token with these pre-selected scopes](https://buildkite.com/user/api-access-tokens/new?scopes%5B%5D=read_clusters&scopes%5B%5D=read_pipelines&scopes%5B%5D=read_builds&scopes%5B%5D=read_build_logs&scopes%5B%5D=read_user&scopes%5B%5D=read_organizations&scopes%5B%5D=read_artifacts&scopes%5B%5D=read_suites&scopes%5B%5D=write_builds&scopes%5B%5D=write_pipelines), to create this API access token more rapidly through the Buildkite interface.

## Install the Buildkite MCP server

### Docker (recommended)

### Pre-built binary

### Build from source

