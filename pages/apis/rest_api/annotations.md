# Annotations API


## Annotation data model

An annotation is a snippet of Markdown uploaded by your agent during the execution of a build's job. Annotations are created using the [`buildkite-agent annotate` command](/docs/agent/v3/cli-annotate) from within a job.

<table>
<tbody>
  <tr><th><code>id</code></th><td>ID of the annotation</td></tr>
  <tr><th><code>context</code></th><td>The "context" specified when annotating the build. Only one annotation per build may have any given context value.</td></tr>
  <tr><th><code>style</code></th><td>The style of the annotation. Can be `success`, `info`, `warning` or `error`.</td></tr>
  <tr><th><code>body_html</code></th><td>Rendered HTML of the annotation's body</td></tr>
  <tr><th><code>created_at</code></th><td>When the annotation was first created</td></tr>
  <tr><th><code>updated_at</code></th><td>When the annotation was last added to or replaced</td></tr>
</tbody>
</table>

## List annotations for a build

Returns a [paginated list](<%= paginated_resource_docs_url %>) of a build's annotations.

>📘
> Note that you need the <a href="/docs/apis/rest-api/builds#build-number-vs-build-id">build number</a> to retrieve annotations, not the build ID.

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{build.number}/annotations"
```

```json
[
  {
    "id": "de0d4ab5-6360-467a-a34b-e5ef5db5320d",
    "context": "default",
    "style": "info",
    "body_html": "<h1>My Markdown Heading</h1>\n<img src=\"artifact://indy.png\" alt=\"Belongs in a museum\" height=250 />",
    "created_at": "2019-04-09T18:07:15.775Z",
    "updated_at": "2019-08-06T20:58:49.396Z"
  },
  {
    "id": "5b3ceff6-78cb-4fe9-88ae-51be5f145977",
    "context": "coverage",
    "style": "info",
    "body_html": "Read the <a href=\"artifact://coverage/index.html\">uploaded coverage report</a>",
    "created_at": "2019-04-09T18:07:16.320Z",
    "updated_at": "2019-04-09T18:07:16.320Z"
  }
]
```

Required scope: `read_builds`

Success response: `200 OK`

## Create an annotation on a build

Creates an annotation on a build.

>📘
> Note that you need the <a href="/docs/apis/rest-api/builds#build-number-vs-build-id">build number</a> to create annotations, not the build ID.

```bash
curl -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{build.number}/annotations" \
  -H "Content-Type: application/json" \
  -d '{
    "body": "Hello world!",
    "style": "info",
    "context": "greeting"
  }'
```

```json
{
  "id": "018b8d10-6b5b-4df2-b0ff-dfa2af566050",
  "context": "greeting",
  "style": "info",
  "body_html": "<p>Hello world!</p>\n",
  "created_at": "2023-11-01T22:45:45.435Z",
  "updated_at": "2023-11-01T22:45:45.435Z"
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>body</code></th>
    <td>
      The annotation's body, as <a href="/docs/agent/v3/cli-annotate#supported-markdown-syntax">HTML or Markdown</a>.
      <p class="Docs__api-param-eg"><em>Example:</em> <code>"My annotation here"</code></p>
    </td>
  </tr>
</tbody>
</table>

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>style</code></th>
    <td>
      The style of the annotation. Can be <code>success</code>, <code>info</code>, <code>warning</code> or <code>error</code>.
      <p class="Docs__api-param-eg"><em>Example:</em> <code>"info"</code></p>
    </td>
  </tr>
  <tr>
    <th><code>context</code></th>
    <td>
      A string value by which to identify the annotation on the build. This is useful when appending to an existing annotation. Only one annotation per build may have any given context value.
      <p class="Docs__api-param-eg"><em>Example:</em> <code>"coverage"</code></p>
    </td>
  </tr>
  <tr>
    <th><code>append</code></th>
    <td>
      Whether to append the given <code>body</code> onto the annotation with the same context.
      <p class="Docs__api-param-eg"><em>Example:</em> <code>true</code></p>
    </td>
  </tr>
</tbody>
</table>

Required scope: `write_builds`

Success response: `201 Created`
