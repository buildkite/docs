# Using GraphQL from the console or the command line

[GraphQL](http://graphql.org) is a standard for defining, querying and documenting APIs in a human-friendly way, with built-in documentation, a friendly query language and a bunch of tools to help you get started.

This guide shows you how to query the GraphQL API using the GraphQL console (see the [GraphQL overview](/docs/apis/graphql-api) page > [Getting started](/docs/apis/graphql-api#getting-started) section for more information) and from the command line. You'll first need a [Buildkite](https://buildkite.com/) user account, and for the command line, an [API access token](https://buildkite.com/user/api-access-tokens/new) for this user account with the **Enable GraphQL API Access** permission selected.

## Running your first GraphQL request in the console

The following is a GraphQL query that requests the name of the current user (the account attached to the API Access Token, in other words, you!)

```graphql
query {
  viewer {
    user {
      name
    }
  }
}
```

Running that in the GraphQL console returns:

```json
{
  "data": {
    "viewer": {
      "user": {
        "name": "Sam Wright"
      }
    }
  }
}
```

Notice how the structure of the data returned is similar to the structure of the query.

## Running your first GraphQL request on the command line

To run the same query using [cURL](https://curl.haxx.se), replace `xxxxxxx` with your API Access Token:

```sh
$ curl 'https://graphql.buildkite.com/v1' \
       -H 'Authorization: Bearer xxxxxxx' \
       -H "Content-Type: application/json" \
       -d '{
         "query": "query { viewer { user { name } } }"
       }'
```

which returns exactly the same as the query we ran in the explorer:

```json
{
  "data": {
    "viewer": {
      "user": {
        "name": "Sam Wright"
      }
    }
  }
}
```

## Getting collections of objects

Getting the name of the current user is one thing, but what about a more complex query?
The `builds` [field](https://buildkite.com/user/graphql/documentation/type/User) of the `user` returns a `BuildConnection`.
A connection is a collection of objects, and requires some metadata called [`edges` and `nodes`](https://graphql.org/learn/pagination/#pagination-and-edges).

In the this query we're asking for for the current user's most recently created build (get one build, starting from the first `first): 1`).

```graphql
query {
  viewer {
    user {
      name
      builds(first: 1) {
        edges {
          node {
            number
            branch
            message
          }
        }
      }
    }
  }
}
```

which returns:

```json
{
  "data": {
    "viewer": {
      "user": {
        "name": "Sam Wright",
        "builds": {
          "edges": [
            {
              "node": {
                "number": 136,
                "branch": "main",
                "message": "Merge pull request #796 from buildkite/docs\n\nImprove API docs"
              }
            }
          ]
        }
      }
    }
  }
}
```
