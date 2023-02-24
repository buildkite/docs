# `buildkite-agent annotation`

The Buildkite Agent's `annotation` command allows manipulating existing build annotations.

Annotations are added using [the `buildkite-agent annotate` command](cli-annotate).

>📘 Newly-added feature
> This feature was introduced in <a href="https://github.com/buildkite/agent/releases/tag/v3.28.1">v3.28.1</a> of the agent.


## Removing an annotation

The `buildkite-agent annotation remove` command removes an existing annotation associated with the current build.

Options for the `annotation remove` command can be found in the `buildkite-agent` cli help:


<%= render 'agent/v3/help/annotation_remove' %>

