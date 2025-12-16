- `{org.slug}` can be obtained:

    * From the end of your Buildkite URL, after accessing **Pipelines** in the global navigation of your organization in Buildkite.

    * By running the [List organizations](/docs/apis/rest-api/organizations#list-organizations) REST API query to obtain this value from `slug` in the response. For example:

        ```bash
        curl -H "Authorization: Bearer $TOKEN" \\
          -X GET "https://api.buildkite.com/v2/organizations"
        ```
