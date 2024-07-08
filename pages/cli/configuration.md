# Buildkite CLI configuration

The Buildkite CLI uses both the [REST](/docs/apis/rest-api) and [GraphQL](/docs/apis/graphql-api) APIs to interact with Buildkite, and therefore, requires the configuration of an API access token.

## Create an API access token for the Buildkite CLI

To create a new API access token:

1. Select your user profile icon > [**Personal Settings**](https://buildkite.com/user/settings) in the global navigation.

1. Select **API Access Tokens** to access your [**API Access Tokens**](https://buildkite.com/user/api-access-tokens) page.

1. Select **New API Access Token** to open the **New API Access Token** page.

1. Specify a **Description** and the **Organization Access** (that is, the specific Buildkite organization) for this token.

1. Once you have selected the required **REST API Scopes** and **Enable GraphQL API access** for the token, retain a copy of your API access token's value in a secure location.

> 📘
> You can use [this link](https://buildkite.com/user/api-access-tokens/new?description=Buildkite%20CLI) to begin creating this token with the **Description** `Buildkite CLI` already defined.
> You can also use [this link](https://buildkite.com/user/api-access-tokens/new?description=Buildkite%20CLI&scopes%5B%5D=read_agents&scopes%5B%5D=write_agents&scopes%5B%5D=read_clusters&scopes%5B%5D=write_clusters&scopes%5B%5D=read_teams&scopes%5B%5D=write_teams&scopes%5B%5D=read_artifacts&scopes%5B%5D=write_artifacts&scopes%5B%5D=read_builds&scopes%5B%5D=write_builds&scopes%5B%5D=read_build_logs&scopes%5B%5D=read_organizations&scopes%5B%5D=read_pipelines&scopes%5B%5D=write_pipelines&scopes%5B%5D=read_user&scopes%5B%5D=read_suites&scopes%5B%5D=write_suites&scopes%5B%5D=read_registries&scopes%5B%5D=write_registries&scopes%5B%5D=delete_registries&scopes%5B%5D=read_packages&scopes%5B%5D=write_packages&scopes%5B%5D=delete_packages&scopes%5B%5D=graphql) to begin creating this token with this **Description**, along with all the required **REST API Scopes** and **Enable GraphQL API access** options already selected.

## Configure the Buildkite CLI with your API access token

Once you have [created your API access token](#create-an-api-access-token-for-the-buildkite-cli), you'll need to configure the Buildkite CLI with this token.

To do this:

1. Run the following command:

    ```bash
    bk configure
    ```

1. When prompted for `Organization slug`, specify the slug for your Buildkite organization.

1. When prompted for `API Token`, specify the value for your configured API access token.

## Configure the Buildkite CLI with multiple organizations

Some users may have access to Buildkite organizations—one for their company, and others for open-source work, personal work, etc.

The Buildkite CLI tool allows you to work with such multiple Buildkite organizations.

To configure the Buildkite CLI tool with another Buildkite organization:

1. Ensure you have [created individual API access tokens](#create-an-api-access-token-for-the-buildkite-cli) for each Buildkite organization to configure in the Buildkite CLI tool.

1. Run the following command:

    ```bash
    bk configure add
    ```

1. When prompted for `Organization slug`, specify the slug for the new Buildkite organization to add to the Buildkite CLI.

1. When prompted for `API Token`, specify the value for your configured API access token for this organization.

## Select a configured organization

If your Buildkite CLI tool has been [configured with multiple Buildkite organizations](#configure-the-buildkite-cli-with-multiple-organizations), you can switch from your current/active organization to another. To do this:

1. Run the following command:

    ```bash
    bk use
    ```

1. Use the cursor select another configured Buildkite organization and make it the current/active one. All subsequent `bk` commands will operate with the new active organization.
