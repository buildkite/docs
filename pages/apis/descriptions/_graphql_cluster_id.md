- `cluster-id` can be obtained:

    * From the _Cluster Settings_ page of your specific cluster that the agent will connect to. To do this:
        1. Select _Agents_ (in the global navigation) > the specific cluster > _Settings_.
        1. Once on the _Cluster Settings_ page, copy the `cluster` parameter value from the _GraphQL API Integration_ section, which is the `cluster.id` value.

    * By running the [List clusters](/docs/apis/graphql/cookbooks/clusters#list-clusters) GraphQL API query and obtain this value from the `id` in the response associated with the name of your cluster (specified by the `name` value in the response). For example:

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
