- `{build.number}` can be obtained:

    * From the number after `builds/` in your Buildkite URL, after accessing **Pipelines** in the global navigation > your specific pipeline > your specific pipeline build.

    * By running the [List builds for a pipeline](/docs/apis/rest-api/builds#list-builds-for-a-pipeline) REST API query to obtain this value from `number` in the response. For example:

        ```bash
        curl -H "Authorization: Bearer $TOKEN" \
          -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds"
        ```
