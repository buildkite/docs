---
keywords: oidc, authentication, IAM, roles
---

# OIDC with Buildkite

<%= render_markdown partial: 'platform/buildkite_agent_oidc_token_overview' %>

The [Buildkite Agent's `oidc` command](/docs/agent/v3/cli-oidc) allows you to request an OIDC token representing the pipeline's current job. These tokens can then be exchanged on federated systems like AWS for authenticated role-based access with specific permissions to interact with your cloud environments.

This section of the Buildkite Docs covers Buildkite's OIDC implementation with other federated systems, such as [AWS](/docs/pipelines/security/oidc/aws).
