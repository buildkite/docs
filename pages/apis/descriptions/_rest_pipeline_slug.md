- `{pipeline.slug}` can be obtained:

    * From the end of your Buildkite URL, after accessing **Pipelines** in the global navigation > your specific pipeline.

    * By running the [List pipelines](/docs/apis/rest-api/pipelines#list-pipelines) REST API query to obtain this value from `slug` in the response. For example:

        ```bash
        curl -H "Authorization: Bearer $TOKEN" \
          -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines"
        ```
