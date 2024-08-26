- `{pipeline.uuid}` can be obtained:

    * From the **Pipeline Settings** page of a given pipeline. To do this:
        1. Select **Pipelines** (in the global navigation) > the specific pipeline > **Settings**.
        1. Once on the **Pipeline Settings** page, copy the `UUID` value from the **GraphQL API Integration** section, which is the `{pipeline.uuid}` value.

    * By running a [Get pipeline](/docs/apis/rest-api/pipelines#get-a-pipeline) REST API query and obtaining this value from the `id` in the response. For example:

    ```bash
    curl -H "Authorization: Bearer $TOKEN" \
      - X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}"
    ```

    * By running a [Get pipeline](/docs/apis/graphql/schemas/query/pipeline) GraphQL API query and obtaining this value from the `uuid` in the response. For example:

    ```graphql
    query getPipeline {
      organization(slug: "organization-slug") {
        pipeline(slug: "pipeline-slug") {
          uuid
        }
      }
    }
    ```
