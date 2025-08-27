# Buildkite APIs

## Authentication

The Buildkite REST and GraphQL APIs expect an access token to be provided using the `Authorization` HTTP header:

```bash
curl -H "Authorization: Bearer $TOKEN" https://api.buildkite.com/v2/user
```

Generate an [access token](https://buildkite.com/user/api-access-tokens).

All webhooks contain an [`X-Buildkite-Token` header](/docs/apis/webhooks/pipelines#http-headers) which allows you to verify the authenticity of the request.

## API security

Buildkite is a member of the [GitHub secret scanning program](https://docs.github.com/en/code-security/secret-scanning/secret-scanning-partnership-program/secret-scanning-partner-program).
This service [alerts](https://docs.github.com/en/code-security/secret-scanning/secret-scanning-partnership-program/secret-scanning-partner-program#the-secret-scanning-process) us when a Buildkite personal API access token has been leaked on GitHub in a public repository.

Once Buildkite receives a notification of a publicly leaked token from GitHub, Buildkite will:

- Revoke the token immediately.
- Email the user who generated the token to let them know it has been revoked.
- Email the organizations associated with the token to let them know it has been revoked.

You can also:

- Enable GitHub secret scanning for [private repositories](https://docs.github.com/en/code-security/secret-scanning/enabling-secret-scanning-features/enabling-secret-scanning-for-your-repository).

- Generate a new [access token for your Buildkite user account](https://buildkite.com/user/api-access-tokens).

## REST API

The Buildkite REST API aims to give you complete programmatic access and control of Buildkite to extend, integrate and automate anything to suit your particular needs.

1. Generate an [API access token](https://buildkite.com/user/api-access-tokens) with as much [scope](/docs/apis/managing-api-tokens#token-scopes) as you need.
2. Make requests to https://api.buildkite.com using the token you generated in the `Authorization` header:

    ```bash
    curl -H "Authorization: Bearer $TOKEN" https://api.buildkite.com/v2/user
    ```

More information about the [REST API](/docs/apis/rest-api).

## GraphQL

The Buildkite GraphQL API provides an alternative to the REST API. The GraphQL API allows for more efficient retrieval of data by enabling you to fetch multiple, nested resources in a single request.

You can access the GraphQL API through the _GraphQL console_ (see the [GraphQL overview](/docs/apis/graphql-api) page > [Getting started](/docs/apis/graphql-api#getting-started) section for more information), as well as at the command line (see the [Console and CLI tutorial](/docs/apis/graphql/graphql-tutorial) page for more information). For command line access, you'll need a Buildkite [API access token](https://buildkite.com/user/api-access-tokens) with the **Enable GraphQL API Access** permission selected.

Learn more information about the Buildkite's GraphQL API through its [overview](/docs/apis/graphql-api) and [Console and CLI tutorial](/docs/apis/graphql/graphql-tutorial) pages.

## Webhooks

Webhooks allow you to monitor and respond to events within your Buildkite organization, providing a real time view of activity and allowing you to extend and integrate Buildkite into your systems.

For Pipelines, webhooks can be [added and configured](/docs/apis/webhooks/pipelines#add-a-webhook) on your Buildkite organization's [**Notification Services** settings](https://buildkite.com/organizations/-/services) page.

For Test Engine and Package Registries, webhooks can be configured through their specific [test suites](/docs/apis/webhooks/test-engine#add-a-webhook) and [registries](/docs/apis/webhooks/package-registries#add-a-webhook), respectively.

Learn more about Buildkite's webhooks from the [Webhooks overview](/docs/apis/webhooks) page.
