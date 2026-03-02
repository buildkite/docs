# Annotations

Buildkite Pipelines' annotations feature lets you add custom content to a build page (known as _build annotations_), which you can [create](#create-a-build-annotation) from your pipeline steps or using the REST or GraphQL APIs.

Build annotations appear on the build page's main **Annotations** tab. See [Build page](/docs/pipelines/build-page) for more information about navigating this interface.

<!--
You can also add annotations to individual jobs (known as _job-scoped annotations_), which you can [create](#create-a-job-scoped-annotation) directly from your relevant pipeline steps.
-->

Adding annotations can be useful for a variety of purposes, such as summarizing a build's job results to make them easier to read, for example, presenting key failure components in a failed step's job execution:

<%= image "overview.png", alt: "Screenshot of annotations from a step that checks for broken links" %>

## Create a build annotation

Build annotations can be created from [within a build's job](#create-a-build-annotation-from-within-a-builds-job), as well as externally using Buildkite's [REST API](#create-a-build-annotation-externally-using-the-rest-api) and [GraphQL API](#create-a-build-annotation-externally-using-the-graphql-api).

There is no limit to the amount of annotations you can create, but the maximum body size of each annotation is 1MiB. The size is measured in bytes, accounting for the underlying data encoding, where the specific encoding used can affect the size calculation. For example, if UTF-8 encoding is implemented, some characters may be encoded using up to 4 bytes each.

### From within a build's job

To create an annotation from within a build's job, use the [`buildkite-agent annotate` command](/docs/agent/cli/reference/annotate#creating-an-annotation) within the step definition for this job.

For example, a step like this:

```yaml
steps:
  - label: "\:writing_hand\: Example"
    command: |
      cat << 'EOF' | buildkite-agent annotate --style "info" --context "agent-cli-example"
      ### Example annotation

      This was created from within a build's job.
      EOF
```

Generates this annotation on the build page's main **Annotations** tab:

<%= image "annotations-build-job-example.png", width: 1820/2, height: 1344/2, alt: "Screenshot of a build job example" %>

Creating annotations like this is the most common approach, as these steps run as part of your pipeline's builds.

See [Formatting annotations](#formatting-annotations) for more information on how to use this Buildkite agent command to create annotations.

### Externally using the REST API

To [create a build annotation](/docs/apis/rest-api/annotations#create-an-annotation-on-a-build) using the [REST API](/docs/apis/rest-api), run the following example `curl` command:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{build.number}/annotations" \
  -H "Content-Type: application/json" \
  -d '{
    "body": "### Example annotation\n\nThis was created using the REST API.",
    "style": "info",
    "context": "rest-api-example"
  }'
```

where:

<%= render_markdown partial: 'apis/descriptions/rest_access_token' %>

<%= render_markdown partial: 'apis/descriptions/rest_org_slug' %>

<%= render_markdown partial: 'apis/descriptions/rest_pipeline_slug' %>

<%= render_markdown partial: 'apis/descriptions/rest_build_number' %>

- For more information on how to use the `body`, `style`, and `context` fields, see [Formatting annotations](#formatting-annotations) for details on how to use these fields in relation to how they're used by the `buildkite-agent annotate` command.

### Externally using the GraphQL API

To [create a build annotation](/docs/apis/graphql/schemas/mutation/buildannotate) using the [GraphQL API](/docs/apis/graphql-api), run the following example mutation:

```graphql
mutation {
  buildAnnotate(input: {
    buildID: "build-id",
    body: "### Example annotation\n\nThis was created using the GraphQL API.",
    style: INFO,
    context: "graphql-api-example"
  }) {
    annotation {
      uuid
      style
      context
      body {
        html
      }
    }
  }
}

```

where:

- `buildID` (required) can be obtained by running the [Get builds](/docs/apis/graphql/cookbooks/builds#get-builds-for-a-pipeline) GraphQL API query and obtain this value from the `id` in the response associated with the number of your build (specified by the `number` value in the response). For example:

    ```graphql
    query GetBuilds {
      pipeline(slug: "organization-slug/pipeline-slug") {
        builds(first: 10) {
          edges {
            node {
              id
              number
              url
            }
          }
        }
      }
    }
    ```

    **Tip:** You can associate the build number with the annotation on the Buildkite interface by accessing **Pipelines** in the global navigation > your specific pipeline > your specific pipeline build, and then checking the build number after `builds/` in your Buildkite URL.

- `style` can be `DEFAULT`, `ERROR`, `INFO`, `SUCCESS` or `WARNING`.

- For more information on how to use the `body`, `style`, and `context` fields, see [Formatting annotations](#formatting-annotations) for details on how to use these fields in relation to how they're used by the `buildkite-agent annotate` command.

<!--

## Create a job-scoped annotation

By default, annotations are scoped to the entire build. However, you can create job-scoped annotations that appear inline with specific jobs in the build interface, making it easier to see contextual information directly next to the job that produced it.

To create a job-scoped annotation, use the `--scope` flag:

```bash
buildkite-agent annotate --scope job "Job-specific information"
```

Job-scoped annotations are particularly useful for:

- Test failures specific to individual jobs in a test matrix
- Job-specific deployment information or Terraform plans
- Results from parallel jobs that need to be viewed separately
- Build matrices where each job produces different output

In contrast to build(-scoped) annotations, which appear in the build page's main **Annotations** tab (see [Create a build annotation > From within a build's job](#create-a-build-annotation-from-within-a-builds-job) for an example), job-scoped annotations appear within the **Annotations** tab of the job's details page, which you can access by selecting that job from the build page interface.

> 📘 Version requirements
> Job-scoped annotations require Buildkite agent v3.112 or newer.

-->

## Formatting annotations

Build annotations support a number of different [styles](#formatting-annotations-annotation-styles), [Markdown syntaxes](#formatting-annotations-supported-markdown-syntax), as well as [CSS classes](#formatting-annotations-supported-css-classes).

You can also [embed and link to artifacts](#formatting-annotations-embedding-and-linking-artifacts-in-annotations) from within your build annotations too.

### Annotation styles

You can change the visual style of annotations using the `--style` option.

This is an example pipeline showcasing the different styles of annotations:

```yaml
steps:
  - label: "\:console\: Annotation Test"
    command: |
      buildkite-agent annotate 'Example `default` style' --context 'ctx-default'
      buildkite-agent annotate 'Example `info` style' --style 'info' --context 'ctx-info'
      buildkite-agent annotate 'Example `warning` style' --style 'warning' --context 'ctx-warn'
      buildkite-agent annotate 'Example `error` style' --style 'error' --context 'ctx-error'
      buildkite-agent annotate 'Example `success` style' --style 'success' --context 'ctx-success'
```

<%= image "annotations-styles.png", alt: "Screenshot of available annotation styles" %>

### Supported Markdown syntax

Buildkite Pipelines uses CommonMark with GitHub Flavored Markdown extensions to provide consistent, unambiguous Markdown syntax.

See GitHub's [Basic writing and formatting syntax](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax) guide (to start with) and [GitHub Flavoured Markdown Spec](https://github.github.com/gfm/) for more details on how to implement this Markdown syntax.

Annotations do not support GitHub-style syntax highlighting, task lists, user mentions, or automatic links for references to issues, pull requests or commits.

CommonMark supports HTML inside Markdown blocks, but will revert to Markdown parsing on newlines. For more information about how HTML is parsed and which tags CommonMark supports please refer to the [CommonMark spec](https://spec.commonmark.org).

> 🚧 HTML limitations
> Annotations are sanitized for security. Only a subset of HTML tags are allowed, including `<span>`, `<div>`, `<p>`, `<a>`, `<img>`, `<pre>`, `<code>`, `<table>`, `<h1>` through `<h6>`, and list elements. Arbitrary tags such as `<script>`, `<style>`, and `<iframe>` are stripped.
>
> Attributes are also restricted. The `class` attribute is allowed but only for a specific allowlist of CSS class names (see [Supported CSS classes](#formatting-annotations-supported-css-classes) below). Link `href` values are limited to `http`, `https`, `mailto`, `itms-services`, and relative URL schemes.
>
> Inline styles (for example, `style="margin-top: 0;"`) are stripped. Some CSS classes may not work on certain HTML elements due to CSS specificity. Use the supported Basscss classes listed below instead.

### Supported CSS classes

A number of CSS classes are accepted in annotations. These include a subset of layout and formatting controls based on [Basscss](#basscss), and [colored console output](#colored-console-output).

<h4 id="basscss">Basscss</h4>

[Basscss](http://basscss.com) is a toolkit of composable CSS classes which can be combined to accomplish many styling tasks.
Annotations in Buildkite Pipelines accept the following parts of version 8.0 of Basscss within annotations:

- [Align](http://basscss.com/#basscss-align)
- [Border](http://basscss.com/#basscss-border)
- [Button](https://basscss.com/v7/docs/btn/)
- [Background Colors](https://basscss.com/v7/docs/background-colors/)
- [Colors](https://basscss.com/v7/docs/colors/)
- [Flexbox](http://basscss.com/#basscss-flexbox)
  * All except `sm-flex`, `md-flex` and `lg-flex`
- [Margin](http://basscss.com/#basscss-margin)
- [Layout](http://basscss.com/#basscss-layout)
  * All except Floats (Please use Flexbox instead)
- [Padding](http://basscss.com/#basscss-padding)
- [Typography](http://basscss.com/#basscss-typography)
  * `bold`, `regular`, `italic`, `caps`
  * `left-align`, `center`, `right-align`, `justify`
  * `underline`, `truncate`
  * `list-reset`
- [Type Scale](http://basscss.com/#basscss-type-scale)

An exhaustive list of classes that annotations support can be found below:

```
bold regular italic caps underline
left-align center right-align justify
align-baseline align-top align-middle align-bottom
list-reset truncate fit

inline block inline-block table table-cell
overflow-hidden overflow-scroll overflow-auto

ml-auto mr-auto mx-auto
flex flex-column flex-wrap flex-auto flex-none
items-start items-end items-center items-baseline items-stretch
self-start self-end self-center self-baseline self-stretch
justify-start justify-end justify-center justify-between justify-around
content-start content-end content-center content-between content-around content-stretch
order-0 order-1 order-2 order-3 order-last

border border-top border-right border-bottom border-left border-none rounded

h1 h2 h3 h4 h5 h6

m0 mt0 mr0 mb0 ml0 mx0 my0 m1
mt1 mr1 mb1 ml1 mx1 my1
m2 mt2 mr2 mb2 ml2 mx2 my2
m3 mt3 mr3 mb3 ml3 mx3 my3
m4 mt4 mr4 mb4 ml4 mx4 my4
mxn1 mxn2 mxn3 mxn4

p0 pt0 pr0 pb0 pl0 px0 py0
p1 pt1 pr1 pb1 pl1 py1 px1
p2 pt2 pr2 pb2 pl2 py2 px2
p3 pt3 pr3 pb3 pl3 py3 px3
p4 pt4 pr4 pb4 pl4 py4 px4

col-1 col-2 col-3 col-4 col-5 col-6
col-7 col-8 col-9 col-10 col-11 col-12

sm-col-1 sm-col-2 sm-col-3 sm-col-4 sm-col-5 sm-col-6
sm-col-7 sm-col-8 sm-col-9 sm-col-10 sm-col-11 sm-col-12

md-col-1 md-col-2 md-col-3 md-col-4 md-col-5 md-col-6
md-col-7 md-col-8 md-col-9 md-col-10 md-col-11 md-col-12

lg-col-1 lg-col-2 lg-col-3 lg-col-4 lg-col-5 lg-col-6
lg-col-7 lg-col-8 lg-col-9 lg-col-10 lg-col-11 lg-col-12

black gray silver white aqua blue navy teal green olive lime
yellow orange red fuchsia purple maroon muted

btn btn-sm btn-lg btn-primary

bg-black bg-gray bg-silver bg-white bg-aqua bg-blue
bg-navy bg-teal bg-green bg-olive bg-lime bg-yellow
bg-orange bg-red bg-fuchsia bg-purple bg-maroon bg-muted
```

<h4 id="colored-console-output">Colored console output</h4>

Console output in annotations can be displayed with ANSI colors when wrapped in a Markdown block marked as `term` or `terminal` syntax. There is a limit of 10 blocks per annotation.

<!-- Following code block needs to be indented to show the code block as well as the code -->

    ```term
    \x1b[31mFailure/Error:\x1b[0m \x1b[32mexpect\x1b[0m(new_item.created_at).to eql(now)

    \x1b[31m  expected: 2018-06-20 19:42:26.290538462 +0000\x1b[0m
    \x1b[31m       got: 2018-06-20 19:42:26.290538000 +0000\x1b[0m

    \x1b[31m  (compared using eql?)\x1b[0m
    ```

<%= image "annotations-terminal-output.png", alt: "Screenshot of colored terminal output in an annotation" %>

> 📘
> Make sure you escape the backticks (<code>`</code>) that demarcate the code block if you're echoing to the terminal, so it doesn't get interpreted as a shell interpreted command.

The following pipeline prints an escaped Markdown block, adds line breaks using `\n` and formats `test` using the red ANSI code `\033[0;31m` before resetting the remainder of the output with `\033[0m`. Passing `-e` to the echo commands ensures that the backslash escapes codes are interpreted (the default is not to interpret them).

```yaml
steps:
  - label: "Annotation Test"
    command:
      - echo -e "\`\`\`term\nThis is a \033[0;31mtest\033[0m\n\`\`\`" | buildkite-agent annotate
```
{: codeblock-file="pipeline.yml"}

The results are piped though to the `buildkite-agent annotate` command:

<%= image "annotations-terminal-output-color.png", alt: "Screenshot of colored terminal output in an annotation" %>

Or for more complex annotations, pipe an entire file to the `buildkite-agent annotate` command:

```bash
printf '%b\n' "$(cat markdown-for-annotation.md)" | buildkite-agent annotate
```

If you're using our [terminal to HTML](http://buildkite.github.io/terminal-to-html/) tool, wrap the output in `<pre class="term"><code></code></pre>` tags, so it displays the terminal color styles but won't process it again:

```html
<pre class="term">
  <code>
    terminal-to-html output
  </code>
</pre>
```

### Embedding and linking artifacts in annotations

Uploaded artifacts can be embedded in annotations by referencing them using the `artifact://` prefix in your image source.

```yaml
steps:
  - label: "\:console\: Annotation Test"
    command: |
      buildkite-agent artifact upload "indy.png"
      cat << EOF | buildkite-agent annotate --style "info"
        <img src="artifact://indy.png" alt="Belongs in a museum" height=250 >
      EOF
```
{: codeblock-file="pipeline.yml"}

<%= image "artifact-embed.png", alt: "Screenshot of using an artifact in an annotation" %>

You can also link to uploaded artifacts as a shortcut to important files:

```yaml
steps:
  - label: "Upload Coverage Report"
    command: |
      buildkite-agent artifact upload "coverage/*"
      cat << EOF | buildkite-agent annotate --style "info"
        Read the <a href="artifact://coverage/index.html">uploaded coverage report</a>
      EOF
```
{: codeblock-file="pipeline.yml"}

## List annotations for a build

All build <!-- and job-scoped --> annotations for a build can be retrieved using the [REST API](#list-annotations-for-a-build-using-the-rest-api) or [GraphQL API](#list-annotations-for-a-build-using-the-graphql-api).

### Using the REST API

To [list build <!-- and job-scoped --> annotations for a build](/docs/apis/rest-api/annotations#list-annotations-for-a-build) using the Buildkite [REST API](/docs/apis/rest-api/annotations).

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{build.number}/annotations"
```

<%= render_markdown partial: 'apis/descriptions/rest_access_token' %>

<%= render_markdown partial: 'apis/descriptions/rest_org_slug' %>

<%= render_markdown partial: 'apis/descriptions/rest_pipeline_slug' %>

<%= render_markdown partial: 'apis/descriptions/rest_build_number' %>

### Using the GraphQL API

To [list build <!-- and job-scoped --> annotations for a build](/docs/apis/graphql/schemas/object/annotation) using the [GraphQL API](/docs/apis/graphql-api), run the following example query:

```graphql
query GetBuildAnnotations {
  node(id: "build-id") {
    ... on Build {
      number
      annotations(first: 10) {
        edges {
          node {
            uuid
            context
            style
            body {
              text
              html
            }
            createdAt
          }
        }
      }
    }
  }
}
```

where `build-id` (required) can be obtained by running the [Get builds](/docs/apis/graphql/cookbooks/builds#get-builds-for-a-pipeline) GraphQL API query and obtaining this value from the `id` in the response associated with the number of your build (specified by the `number` value in the response). For example:

```graphql
query GetBuilds {
  pipeline(slug: "organization-slug/pipeline-slug") {
    builds(first: 10) {
      edges {
        node {
          id
          number
        }
      }
    }
  }
}
```

## Remove an annotation

Build <!-- and job-scoped --> annotations can be removed from [within a build's job](#remove-an-annotation-from-within-a-builds-job), as well as externally using the [REST API](#remove-an-annotation-externally-using-the-rest-api). Removing an annotation using the GraphQL API is not supported.

### From within a build's job

To remove a build <!-- or job-scoped --> annotation from within a build's job, use the [`buildkite-agent annotation remove` command](/docs/agent/cli/reference/annotation#removing-an-annotation) within the step definition for this job.

For example:

```yaml
steps:
  - label: "\:exploding-death-star\: Remove annotation"
    command: buildkite-agent annotation remove --context "agent-cli-example"
```

Removing annotations like this is the most common approach, as these steps run as part of your pipeline's builds.

### Externally using the REST API

To [remove a build <!-- or job-scoped --> annotation](/docs/apis/rest-api/annotations#delete-an-annotation-on-a-build) using the [REST API](/docs/apis/rest-api), run the following example `curl` command:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{build.number}/annotations/{annotation.uuid}"
```

where:

<%= render_markdown partial: 'apis/descriptions/rest_access_token' %>

<%= render_markdown partial: 'apis/descriptions/rest_org_slug' %>

<%= render_markdown partial: 'apis/descriptions/rest_pipeline_slug' %>

<%= render_markdown partial: 'apis/descriptions/rest_build_number' %>

- `{annotation.uuid}` can be obtained by [listing annotations for a build](#list-annotations-for-a-build-using-the-rest-api) and extracting the `id` value from the response. This value is not available from the Buildkite interface.

## Using annotations to report test results

Annotations are a great way of rendering test failures that occur in different steps in a pipeline.

The [junit-annotate plugin](https://github.com/buildkite-plugins/junit-annotate-buildkite-plugin) converts all the junit.xml artifacts in a build into a single annotation:

```yaml
steps:
  - command: test.sh
    parallelism: 50
    artifact_paths: tmp/junit-*.xml
  - wait: ~
    continue_on_failure: true
  - plugins:
      - junit-annotate#v2.7.0:
          artifacts: tmp/junit-*.xml
```
{: codeblock-file="pipeline.yml"}

If you use Bazel as your build tool, see [Creating dynamic pipelines and build annotations using Bazel](/docs/pipelines/tutorials/dynamic-pipelines-and-annotations-using-bazel) for a tutorial on generating annotations from Bazel build events.
