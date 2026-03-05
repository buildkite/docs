# buildkite-agent annotate

The Buildkite agent's `annotate` command allows you to add additional information to Buildkite build pages using CommonMark Markdown.

Learn more about how to use this command in [Annotations](/docs/pipelines/configure/annotations).

## Creating an annotation

The `buildkite-agent annotate` command creates an annotation associated with the current build.

Options for the `annotate` command can be found in the `buildkite-agent` cli help:

<%= render 'agent/cli/help/annotate' %>

## Removing an annotation

Annotations can be removed using [the `buildkite-agent annotation remove` command](/docs/agent/cli/reference/annotation).
