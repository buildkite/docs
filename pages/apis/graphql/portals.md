# Portals

Buildkite's GraphQL API is accessed using an [authenticated API access token](/docs/apis/graphql-api#authentication) whose [token scopes](/docs/apis/managing-api-tokens#token-scopes) cannot be restricted.

Therefore, the Buildkite _portals_ feature provides restricted GraphQL API access to the Buildkite platform, by allowing [Buildkite organization administrators](/docs/platform/team-management/permissions#manage-teams-and-permissions-organization-level-permissions) to define and create GraphQL operations, which are stored by Buildkite, and are made accessible through an authenticated URL endpoint.

Portals work well with machine-to-machine operations, since they're scoped to perform only the operations described within a [GraphQL document](https://spec.graphql.org/October2021/#sec-Language) and are not tied to user-owned access tokens.

## Getting started

To get started with portals, as a Buildkite organization administrator, access the **Portals** feature to begin creating a portal (for example, to create an example portal that triggers a build on the main branch of a pipeline):

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. Select **Integrations > Portals** to access your organization's [**Portals**](https://buildkite.com/organizations/~/portals) page.

1. Select the **Create a portal** button. Note that if existing portals are present, select the **New Portal** button instead.

    At a minimum, a portal requires a **Name** and **GraphQL query**, which are used to generate a unique endpoint, and a GraphQL document.

1. Specify your portal's **Name** (for example, **Trigger main build**).

1. Specify the definition for the operation that your portal is allowed to perform in **GraphQL query**. For example, use the following GraphQL mutation:

    ```graphql
    mutation triggerBuild {
    buildCreate(input:{
      branch: "main",
      commit: "HEAD,"
      pipelineID: "pipeline-id",
    }) {
        build {
          url
        }
      }
    }
    ```

    **Tip:** You can get the GraphQL pipeline ID (for example, a value looking similar to something like `UGlwZWxpbmUtLS0wMTkzMDkxZC1lOTIUzzRhMWEtYWQ0NS1jMWJhNTA2N2RiMzQ=`) from your pipeline settings.

1. After completing these required fields and any others for this portal, select **Save Portal** to create the portal.

    A new HTTP endpoint is generated, along with a corresponding _portal token_ (a type of access token known as an _admin-level portal token_), which you'll need to use later for authentication.

1. Save this portal token to somewhere secure, as you won't be able to access its value again through the Buildkite interface.

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

Each portal has a unique endpoint served from `https://portal.buildkite.com` with the following URL structure:

```
https://portal.buildkite.com/organizations/{organization.slug}/portals/{portal}
```

All requests must be `HTTP POST` requests with `application/json` encoded bodies.

## Defining multiple operations

Multiple GraphQL operations can be defined within a single portal [GraphQL document](https://spec.graphql.org/October2021/#sec-Language). This enables grouping related queries and mutations such as those used in CLI tools or custom workflows under a single portal token for more streamlined usage.

The following example defines two operations in the same document—one to fetch recent builds, and another to trigger a new build:

```graphql
  query GetBuilds($pipelineSlug: ID!) {
    pipeline(slug: $pipelineSlug) {
      builds(last: 10, branch: "main") {
        edges {
          node {
            url
          }
        }
      }
    }
  }

  mutation triggerBuild($pipelineID: ID!) {
    buildCreate(input:{
      branch: "main",
      commit: "HEAD",
      pipelineID: $pipelineID,
    }) {
      build {
        url
      }
    }
  }
```

>📘
> While multiple operations can exist in a portal document, only one can be executed per request. To run a specific operation, include its `operation_name` as a query parameter along with the relevant variables.

An example request for running the `GetBuilds` operation:

```sh
curl -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "pipelineSlug": "organization-slug/pipeline-slug" }' \
  -X POST "https://portal.buildkite.com/organizations/my-organization/portals/portal-slug?operation_name=GetBuilds"
```


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
  -d '{ "build_slug": "organization-slug/pipeline-slug/build-number" }' \
  -X POST "https://portal.buildkite.com/organizations/my-organization/portals/get-total-build-run-time"
```
