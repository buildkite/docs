# GraphQL API overview

The Buildkite GraphQL API provides an alternative to the [REST API](/docs/apis/rest-api). It allows for more efficient retrieval of data by enabling you to fetch multiple, nested resources in a single request.

For the list of existing disparities between the GraphQL API and the REST API, see [API differences](/docs/apis/api-differences).

## Getting started

The quickest way to get started with the GraphQL API is to try the [GraphQL console](https://buildkite.com/user/graphql/console) on Buildkite.

<div><a href="https://buildkite.com/user/graphql/console"><%= image "console.png", width: 2470, height: 1530, alt: "Screenshot of the GraphQL Console on Buildkite" %></a></div>

Learn more about using GraphQL queries and mutations with the GraphQL console or command line in the [Using GraphQL from the console or the command line](/docs/apis/graphql/graphql-tutorial) tutorial.

> 📘 Note for contributors to public and open-source projects
> You need to be a member of the Buildkite organization to be able to generate and use an API token for it.

## Endpoint

The GraphQL API endpoint is `https://graphql.buildkite.com/v1`. All requests must be HTTP `POST` requests with `application/json` encoded bodies.

## Authentication

GraphQL requests must be authenticated using an <a href="<%= url_helpers.user_access_tokens_url %>" rel="nofollow">API access token</a> with the **Enable GraphQL API Access** permission selected. Pass the token in your GraphQL request using the `Authorization` HTTP header with a value `Bearer <token>`.

For example:

```bash
curl -H "Authorization: Bearer $TOKEN" https://graphql.buildkite.com/v1
```

Since the [scopes](/docs/apis/managing-api-tokens#token-scopes) of these API access tokens cannot be restricted, [Buildkite organization administrators](/docs/platform/team-management/permissions#manage-teams-and-permissions-organization-level-permissions) can implement [portals](/docs/apis/graphql/portals), which instead provide restricted GraphQL API access to the Buildkite platform.

## Performing requests with curl

A GraphQL request is a standard HTTPS POST request, with a JSON-encoded body containing a `"query"` key, and optionally a `"variables"` key.

For example, the following `curl` command returns the `name` property of the current `viewer`:

```bash
curl https://graphql.buildkite.com/v1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{ viewer { user { name } } }",
    "variables": "{ }"
  }'
```

```json
{
  "data": {
    "viewer": {
      "user": {
        "name": "Jane Doe"
      }
    }
  }
}
```

For documentation on the full list of fields and types, refer to the [**Documentation** tab of the GraphQL console](https://buildkite.com/user/graphql/documentation).

## GraphQL IDs

All node types have an `id` property, which is a global identifier for the node. You can find the GraphQL ID for any node by querying for the `id` property, for example:

```graphql
query {
  organization(slug: "my-org") {
    id
  }
}
```

```json
{
  "data": {
    "organization": {
      "id": "T3JnYW5pemF0aW9uLS0tYTk4OTYxYjctYWRjMS00MWFhLTg3MjYtY2ZiMmM0NmU0MmUw"
    }
  }
}
```

A GraphQL ID can be used with the global `node` query to quickly return properties of a node, without having to query through nested layers of data. To return specific properties of the object, you'll need to specify the object's type using an [Inline Fragment](https://graphql.org/learn/queries/#inline-fragments).

For example, the following query uses an organization's `id` to find the total number of pipelines in the organization:

```graphql
query {
  node(id: "T3JnYW5pemF0aW9uLS0tYTk4OTYxYjctYWRjMS00MWFhLTg3MjYtY2ZiMmM0NmU0MmUw") {
    ... on Organization {
      pipelines {
        count
      }
    }
  }
}
```

```json
{
  "data": {
    "node": {
      "pipelines": {
        "count": 42
      }
    }
  }
}
```

## Relay compatibility

The Buildkite GraphQL API adheres to the [Relay specification](https://relay.dev/docs/guides/graphql-server-specification/), which defines standards for querying [paginated collections](https://relay.dev/docs/guides/graphql-server-specification/#connections) ("Connections" and "Edges") and for [identifying objects](https://relay.dev/docs/guides/graphql-server-specification/#object-identification) directly from the root of a query (avoiding long nested queries).

## GraphQL schema

If you need the GraphQL schema, you can get it from the API using [GraphQL introspection](https://graphql.org/learn/introspection/), by running the following query against the API:

```graphql
query IntrospectionQuery {
    __schema {
      queryType { name description kind}
      mutationType { name description kind }
      subscriptionType { name description kind }
      types {
        name
        kind
        description
        ...FullType
      }
      directives {
        name
        description
        locations
        args {
          ...InputValue
        }
      }
    }
  }

  fragment FullType on __Type {
    fields(includeDeprecated: true) {
      name
      description
      args {
        ...InputValue
      }
      type {
        ...TypeRef
      }
      isDeprecated
      deprecationReason
    }
    inputFields {
      ...InputValue
    }
    interfaces {
      ...TypeRef
    }
    enumValues(includeDeprecated: true) {
      name
      description
      isDeprecated
      deprecationReason
    }
    possibleTypes {
      ...TypeRef
    }
  }

  fragment InputValue on __InputValue {
    name
    description
    type { ...TypeRef }
    defaultValue
  }

  fragment TypeRef on __Type {
    kind
    name
    description
    ofType {
      kind
      name
      description
      ofType {
        kind
        name
        description
        ofType {
          kind
          name
          description
          ofType {
            kind
            name
            description
            ofType {
              kind
              name
              description
              ofType {
                kind
                name
                description
                ofType {
                  kind
                  name
                  description
                }
              }
            }
          }
        }
      }
    }
  }
```

## Learning more about GraphQL

Further resources for learning more about GraphQL:

- The [GraphQL API cookbook](/docs/apis/graphql/graphql-cookbook) page full of common queries and mutations.
- The [Portals](/docs/apis/graphql/portals) page, where you can learn more about how to provide restricted access to Buildkite's GraphQL API.
- The [**Learn** section](https://graphql.org/learn/) of [the official GraphQL website](https://graphql.org).
- The [Getting started with GraphQL queries and mutations](https://buildkite.com/blog/getting-started-with-graphql-queries-and-mutations) blog post.
