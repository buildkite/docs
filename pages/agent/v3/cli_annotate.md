# buildkite-agent annotate

The Buildkite Agent's `annotate` command allows you to add additional information to Buildkite build pages using CommonMark Markdown.

<%= image "overview.png", alt: "Screenshot of annotations with test reports" %>

## Creating an annotation

The `buildkite-agent annotate` command creates an annotation associated with the current build.

There is no limit to the amount of annotations you can create, but the maximum body size of each annotation is 1MiB. The size is measured in bytes, accounting for the underlying data encoding, where the specific encoding used can affect the size calculation. For example, if UTF-8 encoding is implemented, some characters may be encoded using up to 4 bytes each. All annotations can be retrieved using the [GraphQL API](/docs/apis/graphql-api).

Options for the `annotate` command can be found in the `buildkite-agent` cli help:

<%= render 'agent/v3/help/annotate' %>

## Removing an annotation

Annotations can be removed using [the `buildkite-agent annotation remove` command](/docs/agent/v3/cli-annotation).

## Annotation styles

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

## Annotation ordering

Annotations are ordered by priority (highest to lowest) and then by most recently created. Priority can be set with the `--priority` option when creating the annotation with `buildkite-agent annotate`. Priority ranges from `1` to `10`, with `10` being the highest priority and `1` being the lowest. If priority is not set, the default priority is `3`. If two annotations have the same priority, the one created most recently will be displayed first.

This is an example pipeline that showcases how to use priority to order annotations:

```yaml
steps:
  - label:  "\:console\: Annotation Test"
    command: |
      buildkite-agent annotate 'Example 1 (Priority 1)' --context 'first' --priority 1
      buildkite-agent annotate 'Example 2 (Priority 10)' --style 'info' --context 'second' --priority 10
      buildkite-agent annotate 'Example 3 (Priority 4)' --style 'warning' --context 'third' --priority 4
      buildkite-agent annotate 'Example 4 (Priority 4)' --style 'error' --context 'fourth' --priority 4
      buildkite-agent annotate 'Example 5 (Priority 3, Default)' --style 'success' --context 'fifth'
```

Which would produce the following ordering:

<%= image "annotations-priority.png", alt: "Screenshot of annotations with different priorities" %>

## Supported Markdown syntax

Buildkite Pipelines uses CommonMark with GitHub Flavored Markdown extensions to provide consistent, unambiguous Markdown syntax.

See GitHub's [Basic writing and formatting syntax](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax) guide (to start with) and [GitHub Flavoured Markdown Spec](https://github.github.com/gfm/) for more details on how to implement this Markdown syntax.

Annotations do not support GitHub-style syntax highlighting, task lists, user mentions, or automatic links for references to issues, pull requests or commits.

CommonMark supports HTML inside Markdown blocks, but will revert to Markdown parsing on newlines. For more information about how HTML is parsed and which tags CommonMark supports please refer to the [CommonMark spec](https://spec.commonmark.org).

## Supported CSS classes

A number of CSS classes are accepted in annotations. These include a subset of layout and formatting controls based on [Basscss](http://basscss.com), and colored console output.

### Basscss

[Basscss](http://basscss.com) is a toolkit of composable CSS classes which can be combined to accomplish many styling tasks.
We accept the following parts of version 8.0 of Basscss within annotations:

* [Align](http://basscss.com/#basscss-align)
* [Border](http://basscss.com/#basscss-border)
* [Button](https://basscss.com/v7/docs/btn/)
* [Background Colors](https://basscss.com/v7/docs/background-colors/)
* [Colors](https://basscss.com/v7/docs/colors/)
* [Flexbox](http://basscss.com/#basscss-flexbox)
  - All except `sm-flex`, `md-flex` and `lg-flex`
* [Margin](http://basscss.com/#basscss-margin)
* [Layout](http://basscss.com/#basscss-layout)
  - All except Floats (Please use Flexbox instead)
* [Padding](http://basscss.com/#basscss-padding)
* [Typography](http://basscss.com/#basscss-typography)
  - `bold`, `regular`, `italic`, `caps`
  - `left-align`, `center`, `right-align`, `justify`
  - `underline`, `truncate`
  - `list-reset`
* [Type Scale](http://basscss.com/#basscss-type-scale)

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

### Colored console output

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

## Embedding & linking artifacts in annotations

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

## Using annotations to report test results

Annotations are a great way of rendering test failures that occur in different steps in a pipeline.

We've created a plugin to convert all the junit.xml artifacts in a build into a single annotation: https://github.com/buildkite-plugins/junit-annotate-buildkite-plugin

```yaml
steps:
  - command: test.sh
    parallelism: 50
    artifact_paths: tmp/junit-*.xml
  - wait: ~
    continue_on_failure: true
  - plugins:
      - junit-annotate#v1.2.0:
          artifacts: tmp/junit-*.xml
```
{: codeblock-file="pipeline.yml"}
