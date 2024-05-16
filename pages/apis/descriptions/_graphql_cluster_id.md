- `clusterId` (required) can be obtained:

    * From the **Cluster Settings** page of your target cluster. To do this:
        1. Select **Agents** (in the global navigation) > the specific cluster > **Settings**.
        1. Once on the **Cluster Settings** page, copy the `cluster` parameter value from the **GraphQL API Integration** section, which is the `cluster.id` value.

    * By running the [List clusters](/docs/apis/graphql/cookbooks/clusters#list-clusters) GraphQL API query and obtain this value from the `id` in the response associated with the name of your target cluster (specified by the `name` value in the response). For example:

        ```graphql
        query getClusters {
          organization(slug: "organization-slug") {
            clusters(first: 10) {
              edges {
                node {
                  id
                  name
                  uuid
                  color
                  description
                }
              }
            }
          }
        }
        ```
