# Registries

A collection of common tasks with package registries using the GraphQL API.

<%= render_markdown partial: 'apis/graphql/cookbooks/graphql_console_link' %>

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
