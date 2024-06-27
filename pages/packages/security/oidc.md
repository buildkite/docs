# OIDC in Buildkite Packages

<%= render_markdown partial: 'platform/buildkite_agent_oidc_token_overview' %>

Third-party products and services, such as [GitHub Actions](https://github.com/features/actions), as well as Buildkite Packages itself, can be configured with OIDC-compatible policies that only permit agent interactions from specific Buildkite organizations, pipelines, jobs, and agents associated with pipelines' jobs.

A Buildkite OIDC token, representing an agent interaction containing this metadata from a pipeline's job, can be used by such third-party services and Buildkite Packages to allow these services to authenticate this Buildkite interaction. If one of these interactions does not match or comply with the service's policy, the interaction is rejected.

The [Buildkite Agent's `oidc` command](/docs/agent/v3/cli-oidc) allows you to request an OIDC token representing the pipeline's current job. These tokens are can then used by a Buildkite Packages registry to determine if the organization, pipeline and any other metadata associated with the pipeline and its job are permitted to publish/upload packages to this registry.
