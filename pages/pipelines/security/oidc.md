---
keywords: oidc, authentication, IAM, roles
---

# OIDC in Buildkite Pipelines

<%= render_markdown partial: 'platform/oidc_introduction' %>

You can configure third-party products and services, such as [AWS](https://aws.amazon.com/), [GCP](https://cloud.google.com/), [Azure](https://azure.microsoft.com/) and many others, as well as Buildkite products, such as [Packages](/docs/packages/security/oidc), with OIDC policies that only permit Buildkite Agent interactions from specific Buildkite organizations, pipelines, jobs, and agents, associated with a pipeline's job.

A Buildkite OIDC token is a signed [JSON Web Token (JWT)](https://jwt.io/) provided by a Buildkite Agent, containing metadata claims about a pipeline and its job, including the pipeline and organization slugs, as well as job-specific data, such as the branch, the commit SHA, the job ID, and the agent ID. Such a token is associated with a Buildkite Agent interaction to perform one or more actions within the third-party service. If the token's claims do not match or comply with the service's OIDC policy, the OIDC token and subsequent pipeline jobs' interactions are rejected.

The [Buildkite Agent's `oidc` command](/docs/agent/v3/cli-oidc) allows you to request an OIDC token from Buildkite containing claims about the pipeline's current job. These tokens are then consumed by federated systems like AWS, and exchanged for authenticated role-based access with specific permissions to interact with your cloud environments.

This section of the Buildkite Docs covers Buildkite's OIDC implementation with other federated systems, such as [AWS](/docs/pipelines/security/oidc/aws).
