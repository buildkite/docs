# Hosted agents secrets

_Secrets_ is a Buildkite feature that allows you to configure secrets to use in your Buildkite Agents, and is accessible using the [`buildkite-agent secret` command](/docs/agent/v3/cli-secret).

Secrets have the following characteristics:

- Configured and scoped within a [cluster](/docs/clusters/overview).
- Available to all agents within the cluster.
- Are not visible once created.

