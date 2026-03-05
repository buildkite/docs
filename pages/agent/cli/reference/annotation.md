# buildkite-agent annotation

The Buildkite agent's `annotation` command allows manipulating existing build annotations.

Learn more about how to use this command in [Annotations](/docs/pipelines/configure/annotations).

Annotations are added using [the `buildkite-agent annotate` command](/docs/agent/cli/reference/annotate).

## Removing an annotation

The `buildkite-agent annotation remove` command removes an existing annotation associated with the current build.

Options for the `annotation remove` command can be found in the `buildkite-agent` cli help:

<%= render 'agent/cli/help/annotation_remove' %>
