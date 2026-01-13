---
toc: false
---

# Secrets overview

Buildkite supports a number of mechanisms by which you can manage secrets that your pipelines must use to interact with 3rd party systems during the build process or for deployment.

Some of these mechanisms emphasize greater security over convenience to set up. Others emphasize set up convenience over security.

This section of the Buildkite Docs provides guidelines on how to manage and configure secrets to suit your particular requirements.

- [Managing pipeline secrets](/docs/pipelines/security/secrets/managing), provides guidance and best practices for managing your secrets in either a [hybrid Buildkite architecture](/docs/pipelines/getting-started#understand-the-architecture) with self-hosted agents, or with [Buildkite hosted agents](/docs/agent/v3/buildkite-hosted).

- [Risk considerations](/docs/pipelines/security/secrets/risk-considerations) and practices to avoid exposing your secrets, which could compromise the security of your 3rd party systems.

- [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets), an encrypted key-value store secrets management service offered by Buildkite for use with either Buildkite hosted or self-hosted agents.

- [Buildkite secrets policies](/docs/pipelines/security/secrets/buildkite-secrets/access-policies), to provide agent access control for your secrets, ensuring that only authorized agents can access them during builds.
