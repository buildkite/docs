---
keywords: oidc, authentication, IAM, roles
---

# OIDC in Buildkite Pipelines

<%= render_markdown partial: 'platform/oidc_introduction' %>

You can configure third-party products and services, such as [AWS](https://aws.amazon.com/), [GCP](https://cloud.google.com/), [Azure](https://azure.microsoft.com/) and many others, as well as Buildkite products, such as [Package Registries](/docs/package-registries/security/oidc), with OIDC policies that only permit Buildkite Agent interactions from specific Buildkite organizations, pipelines, agents, and other metadata associated with the pipeline's job.

A Buildkite OIDC token can be issued by a Buildkite Agent, asserting claims about the slugs of the pipeline it is building and organization that contains this pipeline, the ID of the job that created the token, as well as other claims, such as the name of the branch used in the build, the SHA of the commit that triggered the build, and the agent ID. Such a token is associated with a Buildkite Agent interaction to perform one or more actions within the third-party service. If the token's claims do not comply with the service's OIDC policy, the token is rejected and subsequent pipeline jobs' interactions are rejected.

The [Buildkite Agent's `oidc` command](/docs/agent/v3/cli-oidc) allows you to request an OIDC token from Buildkite containing claims about the pipeline's current job. These tokens can then be consumed by federated systems like AWS, and exchanged for authenticated role-based access with specific permissions to interact with your cloud environments.

This section of the Buildkite Docs covers Buildkite's OIDC implementation with other federated systems, such as [AWS](/docs/pipelines/security/oidc/aws).
