# Portals
Buildkite Portals are an alternative to the Buildkite REST and GraphQL APIs. You can think of them as stored user-defined GraphQL operations made accessible via an authenticated URL endpoint.

Portals are an ideal fit for machine-to-machine operations since they're scoped down to perform only the operations described within a GraphQL document and aren't tied to user-owned access tokens.


## Getting started
The best way to learn about Portals is by creating a portal.

Let’s get started by heading over to your [organization](https://buildkite.com/organizations/~/portals) and creating an example portal for triggering a build on the main branch of a pipeline.

At a minimum, a portal requires a name that will be used to generate a unique endpoint, and a GraphQL document.

1. Let’s start by naming our portal “Trigger main build”.

2. Now we can define the operation that our portal will be allowed to perform. For now we’ll use the following GraphQL mutation:



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

    _Hint: You can get the GraphQL pipeline ID from your pipeline settings._

3. Now that we've filled in all the required fields, we can go ahead and create the portal which will subsequently generate a new HTTP endpoint and corresponding access token which we’ll use later for  authentication.

3. Save the access token! You won’t see it again, so put this somewhere secure.
4. Now it’s time to call our new endpoint. You can access it using the following, replacing the organisation slug with your own.


    e.g.

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
https://portal.buildkite.com/organizations/<organization>/portals/<portal>
```


All requests must be `HTTP POST` requests with `application/json` encoded bodies.

## Authentication

Similar to the Buildkite REST and GraphQL APIs, Portals are authenticated using bearer authentication by using the associated access token generated for a given portal.

e.g.

```sh
curl -H "Authorization: Bearer $TOKEN" https://portal.buildkite.com/organizations/my-org/portals/my-portal
```

A corresponding access token is generated on creation of a portal.

If you need to rotate a given access token, you can do this by duplicating and removing the existing portal, which will in turn generate a fresh token.

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

Whilst Portals are in customer preview, creation of portals are restricted to organization administrators.
