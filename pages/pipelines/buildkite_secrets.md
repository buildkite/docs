# Buildkite secrets

_Buildkite secrets_ is a feature that allows you to configure secrets which are managed by Buildkite to use in your Buildkite Agents

These secrets can be accessed using the [`buildkite-agent secret get` command](/docs/agent/v3/cli-secret).

Secrets have the following characteristics:

- Configured and scoped within a [cluster](/docs/clusters/overview).
- Available to all agents within the cluster.
- Are not visible once created.
