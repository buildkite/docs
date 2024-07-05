# Buildkite CLI configuration

To configure the CLI you can use `bk configure`. This will walk you through setting your organization and API token.

> 📘
> The CLI uses both [GraphQL](/docs/apis/graphql-api) and [REST](/docs/apis/rest-api) APIs. You'll need to create a token from you [personal settings](https://buildkite.com/user/api-access-tokens/new?description=Buildkite%20CLI) page.

## Multiple organizations

The CLI supports working with multiple organizations for those who might have a separate organization for open-source work, or a personal Buildkite account, etc.

To configure another organization you can run `bk configure add` which will prompt you for the new organization and API token.

## Selecting an organization

If you have multiple organizations configured, you can switch between the active organization with `bk use`.
