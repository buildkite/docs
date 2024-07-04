# Packages

A collection of common tasks with packages using the GraphQL API.

You can test out the Buildkite GraphQL API using the [Buildkite explorer](https://graphql.buildkite.com/explorer). This includes built-in documentation under the **Docs** panel.

## List organization registries

List the first 50 package registries in the organization.

```graphql
query getOrganizationRegisteries {
  organization(slug: "organization-slug"){
    registries(first: 50){
      edges{
        node{
          name
          id
          uuid
          createdAt
          updateaAt
        }
      }
    }
  }
}
```
