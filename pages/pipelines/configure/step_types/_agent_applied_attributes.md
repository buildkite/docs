These attributes are only applied by the Buildkite Agent when uploading a pipeline (`buildkite-agent pipeline upload`), since they require direct access to your code or repository to process correctly.

<table>
  <tr>
    <td><code>if_changed</code></td>
    <td>
      A <a href="/docs/pipelines/configure/glob-pattern-syntax">glob pattern</a> that omits the step from a build if it does not match any files changed in the build. <br/>
      <em>Example:</em> <code>"{**.go,go.mod,go.sum,fixtures/**}"</code><br/>
      Starting with Agent v3.109.0, `if_changed` also supports lists of glob patterns and <code>include</code> and <code>exclude</code> attributes.<br/>
      <em>Minimum Buildkite Agent version:</em> v3.99 (with <code>--apply-if-changed</code> flag), v3.103.0 (enabled by default), v3.109.0 (expanded syntax)
    </td>
  </tr>
</table>

> 🚧
> Agent-applied attributes are not accepted in pipelines set using the Buildkite interface.

Example pipeline, demonstrating various forms of `if_changed`:

```yaml
steps:
  # if_changed can specify a single glob pattern.
  # Note that YAML requires some strings to be quoted.
  - label: "Only run if a .go file anywhere in the repo is changed"
    if_changed: "**.go"

  # Braces {,} lets you combine patterns and subpatterns.
  # Note that this syntax is whitespace-sensitive: a space within a
  # pattern is treated as part of the file path for matching.
  - label: "Only run if go.mod or go.sum are changed"
    if_changed: go.{mod,sum}
    # Wrong: go.{mod, sum}

  # Combining the two previous examples:
  - label: "Run if any Go-related file is changed"
    if_changed: "{**.go,go.{mod,sum}}"

  # A less Go-centric example:
  - label: "Run for any changes within app/ or spec/"
    if_changed: "{app/**,spec/**}"

  # From Agent v3.109, lists of patterns are supported. If any changed file
  # matches any of the patterns, the step is run. This can be a more ergonomic
  # alternative to using braces.
  - label: "Run if any Go-related file is changed"
    if_changed:
      - "**.go"
      - go.{mod,sum}

  - label: "Run for any changes in app/ or spec/"
    if_changed:
      - app/**
      - spec/**

  # From Agent v3.109, include and exclude are supported attributes.
  # Like if_changed, they may be single patterns or lists of patterns.
  # In this form, `include` is required. `exclude` eliminates changed files
  # from causing a step to run.
  - label: "Run for changes in spec/, but not in spec/integration/"
    if_changed:
      include: spec/**
      exclude: spec/integration/**

  - label: "Run for api and internal, but not api/docs or internal .py files"
    if_changed:
      include:
        - api/**
        - internal/**
      exclude:
        - api/docs/**
        - internal/**.py
```
