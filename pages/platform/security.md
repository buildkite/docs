# Security

Securing a Buildkite organization is a shared responsibility. Buildkite secures the control plane that schedules your builds and stores your build data. You secure the agents that run your builds, the credentials those builds use, and the access your users and tokens have to your Buildkite organization. Learn more about how Buildkite protects your data, and how data flows between Buildkite and your infrastructure, in the [Pipelines security overview](/docs/pipelines/security).

This page brings together the security documentation for the Buildkite platform, [Buildkite Pipelines](/docs/pipelines), and [Buildkite Package Registries](/docs/package-registries).

## Where to start

- [Security hardening checklist](/docs/platform/security/hardening-checklist): The security controls available across Buildkite, grouped by area and ordered into baseline, recommended, and advanced tiers.
- [Incident response](/docs/platform/security/incident-response): How to prepare for, contain, and investigate a security incident in your Buildkite organization.
- [Token security](/docs/platform/security/tokens): The types of tokens that Buildkite issues, how to identify them by their prefix, and what happens when a token is leaked.

## Identity and access

Control who can access your Buildkite organization and what they can do:

- [Single sign-on (SSO)](/docs/platform/sso) and its supported providers.
- [Enforcing two-factor authentication (2FA)](/docs/platform/team-management/enforce-2fa) for all users.
- [User and team permissions](/docs/platform/team-management/permissions) across the Buildkite platform.
- [Pipeline permissions](/docs/pipelines/security/permissions) and [registry permissions](/docs/package-registries/security/permissions).
- [Inactive user list](/docs/platform/team-management/inactive-user-list) for finding and removing users who no longer need access.
- [Managing API access tokens](/docs/apis/managing-api-tokens), including token scopes, auditing, and IP address restrictions.
- [OAuth Token Exchange](/docs/apis/oauth-token-exchange) for issuing short-lived API tokens to services.

## Agents

Harden the infrastructure that runs your builds:

- [Clusters](/docs/pipelines/security/clusters) for isolating pipelines and agents, and [cluster rules](/docs/pipelines/security/clusters/rules) for granting access between them.
- [Agent tokens](/docs/agent/self-hosted/tokens) and [job acquisition tokens](/docs/agent/self-hosted/job-acquisition-tokens).
- [Buildkite agent security](/docs/agent/self-hosted/security) settings for self-hosted agents.
- [Network requirements](/docs/agent/self-hosted/security/network-requirements) for self-hosted agents.
- [Network security](/docs/agent/buildkite-hosted/network-security) for Buildkite hosted agents.
- [Code access](/docs/agent/self-hosted/code-access) for self-hosted agents, and [code access](/docs/agent/buildkite-hosted/code-access) for Buildkite hosted agents.
- Security guidance for the [Elastic CI Stack for AWS](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security), [securing agents on AWS](/docs/agent/self-hosted/aws/architecture/securing-your-setup), and [securing the Agent Stack for Kubernetes](/docs/agent/self-hosted/agent-stack-k8s/securing-the-stack).

## Pipelines and supply chain

Protect the integrity of what your pipelines run:

- [Signed pipelines](/docs/agent/self-hosted/security/signed-pipelines) for verifying that steps haven't been modified after upload.
- [Commit verification](/docs/pipelines/configure/git-checkout#commit-verification) and the [agent checkout-override mode](/docs/pipelines/configure/git-checkout#agent-checkout-override-mode).
- [Running builds on pull requests](/docs/pipelines/source-control/github#running-builds-on-pull-requests), including builds from third-party forks.
- [Pinning plugin versions](/docs/pipelines/integrations/plugins/using#pinning-plugin-versions).
- [Pipeline templates](/docs/pipelines/governance/templates) for standardizing steps across pipelines.
- [SLSA provenance](/docs/package-registries/security/slsa-provenance) for packages published to Buildkite Package Registries.
- [Incoming webhooks](/docs/pipelines/security/incoming-webhooks) security.

## Secrets

Provide credentials to your builds without exposing them:

- [Secrets overview](/docs/pipelines/security/secrets) and [managing secrets](/docs/pipelines/security/secrets/managing).
- [Risk considerations](/docs/pipelines/security/secrets/risk-considerations) for where not to store secrets.
- [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets) and their [access policies](/docs/pipelines/security/secrets/buildkite-secrets/access-policies).
- [Redacted environment variables](/docs/pipelines/configure/managing-log-output#redacted-environment-variables) in job logs.
- [OIDC in Buildkite Pipelines](/docs/pipelines/security/oidc), including [OIDC with AWS](/docs/pipelines/security/oidc/aws) and [OIDC with Azure](/docs/pipelines/security/oidc/azure).
- [OIDC in Buildkite Package Registries](/docs/package-registries/security/oidc).

## Monitoring

Detect and investigate activity in your Buildkite organization:

- [Audit log](/docs/platform/audit-log) and its [logged events](/docs/platform/audit-log#logged-events).
- [Amazon EventBridge](/docs/pipelines/integrations/observability/amazon-eventbridge) for streaming audit events to your SIEM system.
- [Job log archiving](/docs/pipelines/governance/job-log-archiving) to your own storage.
