# Security

Use this section to secure your Buildkite organization, review its security controls, or respond to a suspected compromise. It brings together guidance for the Buildkite platform, [Buildkite Pipelines](/docs/pipelines), and [Buildkite Package Registries](/docs/package-registries), with links to configuration instructions in each product's documentation.

## Shared responsibility

Buildkite and your organization share responsibility for security:

- **Buildkite:** Secures the control plane that schedules builds and stores build data. For [Buildkite hosted agents](/docs/agent/buildkite-hosted), Buildkite also manages the underlying infrastructure and agent updates.
- **Your organization:** Controls user and token access, the code your builds run, and the credentials and systems those builds can access, regardless of where your agents run.
- **Your organization with self-hosted agents:** Also provisions, secures, and maintains the [agent infrastructure](/docs/agent/self-hosted/security), including agent updates and network boundaries.

The controls your organization is responsible for are listed in [Security best practices](/docs/platform/security/best-practices). Apply at least the baseline controls in each area before connecting production systems.

Learn how Buildkite protects your data, and how data flows between Buildkite and your infrastructure, in the [Pipelines security overview](/docs/pipelines/security).

## Where to start

Cover all of the following areas before you connect production systems. If you're reviewing or auditing an existing Buildkite organization, use them to find the controls to check:

- **Secure your organization setup:** Configure [authentication and access control](/docs/platform/security/best-practices#authentication-and-access-control), including SSO or 2FA, teams, permissions, and API access tokens.
- **Secure your agents, pipelines, secrets, and network:** Apply the controls for [Buildkite agent security](/docs/platform/security/best-practices#buildkite-agent-security), [pipeline and supply chain integrity](/docs/platform/security/best-practices#pipeline-and-supply-chain-integrity), [secrets management](/docs/platform/security/best-practices#secrets-management), and [network and data exposure](/docs/platform/security/best-practices#network-and-data-exposure).
- **Prepare your organization for incidents:** Set up [monitoring and detection](/docs/platform/security/best-practices#monitoring-and-detection), and write a runbook based on [Incident response](/docs/platform/security/incident-response) so that you can contain compromised access, rotate exposed secrets, investigate activity, and recover.

## Identity and access

Control who can access your Buildkite organization and what they can do:

- [Single sign-on (SSO)](/docs/platform/sso) and its supported providers.
- [Enforcing two-factor authentication (2FA)](/docs/platform/team-management/enforce-2fa) for all users.
- [User and team permissions](/docs/platform/team-management/permissions) across the Buildkite platform.
- [Pipeline permissions](/docs/pipelines/security/permissions) and [registry permissions](/docs/package-registries/security/permissions).
- [Inactive user list](/docs/platform/team-management/inactive-user-list) for periodically reviewing and removing users who no longer need access.
- SCIM provisioning for [Okta](/docs/platform/sso/okta#using-scim-to-provision-and-manage-users) or [Microsoft Entra ID](/docs/platform/sso/azure-ad#using-scim-to-provision-and-manage-users) for automated deprovisioning, which removes a user's access to Buildkite as soon as they're removed from your identity provider.
- [Token security](/docs/platform/security/tokens) for token lifecycle guidance, identifying token types, and detecting leaked tokens.
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
