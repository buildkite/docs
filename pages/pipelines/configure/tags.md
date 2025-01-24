# Pipeline tags

Pipeline tags allow you to tag and search for your pipelines using the search bar. Tags are beneficial when you have many pipelines and would like to group and filter through them quickly.

<%= image "pipeline-tag-search.png", alt: "The search bar is selected and shows a dropdown with suggested tags." %>

## Using tags

You can assign each pipeline up to ten unique tags. A tag can comprise emoji and text, up to 128 characters. It is recommended using an emoji to make the tag stand out, and to keep the text short and clear.

You can tag a pipeline by navigating to the pipeline's **Settings** or using the API. In REST, use the `tags` property on the [Pipeline REST API](/docs/apis/rest-api/pipelines). In GraphQL, use the `tag` field on the [`pipelineUpdate` mutation](/docs/apis/graphql/schemas/mutation/pipelineupdate).

To use the same tag across multiple pipelines, you must create the same tag on each pipeline.
