# Secrets overview

Buildkite supports a number of mechanisms by which you can manage secrets that your pipelines must use to interact with 3rd party systems during the build process or for deployment.

Some of these mechanisms emphasize greater security over convenience to set up. Others emphasize set up convenience over security.

This section of the Buildkite Docs provides guidelines on how to manage and configure secrets to suit your particular requirements.

- [Manging pipeline secrets](/docs/pipelines/security/secrets/managing) in a [hybrid Buildkite architecture](/docs/tutorials/getting-started#understand-the-architecture) with self-hosted agents.

- [Risk considerations](/docs/pipelines/security/secrets/risk-considerations) and practices to avoid exposing your secrets, which could compromise the security of your 3rd party systems.
