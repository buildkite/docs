# Portals

> 📘
> The _portals_ feature is currently in _customer preview_.

Buildkite _portals_ is an alternative feature to Buildkite's REST and GraphQL APIs. Portals behave like stored, user-defined GraphQL operations made accessible via an authenticated URL endpoint.

Portals work well with machine-to-machine operations, since they're scoped to perform only the operations described within a GraphQL document and are not tied to user-owned access tokens.

## Getting started

To get started with portals, create a portal, by accessing the [portals feature of your organization](https://buildkite.com/organizations/~/portals) to create an example portal that triggers a build on the main branch of a pipeline.

At a minimum, a portal requires a name that will be used to generate a unique endpoint, and a GraphQL document.

1. Start by naming your portal **Trigger main build**.

1. Define the operation that your portal is allowed to perform. For now, use the following GraphQL mutation:

    ```graphql
    mutation triggerBuild {
    buildCreate(input:{
      branch: "main",
      commit:"HEAD,"
      pipelineID:"UGlwZWxpbmUtLS0wMTkzMDkxZC1lOTIUzzRhMWEtYWQ0NS1jMWJhNTA2N2RiMzQ=",
    }) {
        build {
          url
        }
      }
    }
    ```

    **Tip:** You can get the GraphQL pipeline ID from your pipeline settings.

1. After completing the required fields for this mutation, proceed to create the portal, which subsequently generates a new HTTP endpoint and corresponding access token (known as an _admin-level portal token_) which you'll need to use later for authentication.

1. Save this access token to somewhere secure, as you won't be able to access its value again through the Buildkite interface.

    **Note:** This _portal token_ is referred to as an _admin-level_ one, since it grants Buildkite organization administrator-access privileges to this Buildkite organization.

1. Make a request to your new endpoint. You can access it using the following `curl` command, replacing the organization slug with your own.

    For example:

    ```sh
    curl -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d "{}" \
      -X POST "https://portal.buildkite.com/organizations/my-organization/portals/trigger-main-build"
    ```

Voila! You've just created and executed a portal.

>📘 What more examples?
> To explore our entire GraphQL API, check out our [GraphQL Explorer](https://buildkite.com/user/graphql/console) or our [GraphQL Cookbook](https://buildkite.com/docs/apis/graphql/graphql-cookbook).

## Endpoint

Each portal has a unique endpoint served from `http://portal.buildkite.com` with the following URL structure:

```
https://portal.buildkite.com/organizations/{organization.slug}/portals/{portal}
```

All requests must be `HTTP POST` requests with `application/json` encoded bodies.

## Authentication

Similar to the Buildkite REST and GraphQL APIs, portals are authenticated with the associated portal token generated for a given portal.

For example:

```sh
curl -H "Authorization: Bearer $TOKEN" https://portal.buildkite.com/organizations/my-org/portals/my-portal
```

>📘
> If you need to generate a new admin-level portal token (to replace an older or suspected compromised one), you can do this by duplicating and removing the existing portal, which will in turn generate a new admin-level portal token.

## Passing arguments

GraphQL operations may include arguments which can be provided as part of the JSON request body.

For example, given a portal that uses the following GraphQL query:

```graphql
query GetTotalBuildRunTime($build_slug: ID) {
  build(slug: "organization-slug/pipeline-slug/build-number") {
    pipeline {
      name
    }
    url
    startedAt
    finishedAt
  }
}
```

Calling this specific portal would then require `build_slug` to be included as part of the HTTP request.

e.g.

```sh
curl -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{ "build_slug": "organization-slug/pipeline-slug/build-number" }" \
  -X POST "https://portal.buildkite.com/organizations/my-organization/portals/get-total-run-time"
```

## Customer preview

While portals are in customer preview, the creation of portals is restricted to organization administrators.
