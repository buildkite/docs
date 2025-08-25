# Registries

A collection of common tasks with package registries using the GraphQL API.

You can test out the Buildkite GraphQL API using the Buildkite [GraphQL console](https://buildkite.com/user/graphql/console). This includes built-in documentation under its **Documentation** tab.

## List organization registries

List the first 50 registries in the organization.

```graphql
query getOrganizationRegistries {
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
