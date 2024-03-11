- `cluster_id` can be obtained:

    * From the _Cluster Settings_ page of your target cluster. To do this:
        1. Select _Agents_ (in the global navigation) > the specific cluster > _Settings_.
        1. Once on the _Cluster Settings_ page, copy the `id` parameter value from the _GraphQL API Integration_ section, which is the `cluster_id` value.

    * By running the [List clusters](/docs/apis/rest-api/clusters#clusters-list-clusters) REST API query and obtain this value from the `id` in the response associated with the name of your target cluster (specified by the `name` value in the response). For example:

        ```bash
        curl -H "Authorization: Bearer $TOKEN"
          - X GET "https://api.buildkite.com/v2/organizations/{org.slug}/clusters"
        ```
