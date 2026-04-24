- `{job.id}` can be obtained by running the [Get a build](/docs/apis/rest-api/builds#get-a-build) REST API query to obtain this value from the `id` of the relevant job in the `jobs` array of the response. For example:

    ```bash
    curl -H "Authorization: Bearer $TOKEN" \
      -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{build.number}"
    ```
