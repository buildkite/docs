# Incident response

This page describes how to prepare for, contain, and investigate a security incident affecting your Buildkite organization, such as a compromised user account, a leaked token, or an exposed secret.

If you discover a security incident, contact support@buildkite.com immediately. If you've detected an exposed secret, also contact security@buildkite.com. Early notification allows Buildkite to assist with remediation steps.

## Prepare before an incident

Several response actions depend on preparation or require help from Buildkite support. Complete the following steps before you need them:

- **Write a runbook:** Document the containment steps on this page for your Buildkite organization, including the API calls your team would run and who has permission to run them.
- **Record escalation contacts:** Keep the Buildkite support and security contacts in your runbook. Customers on the [Enterprise](https://buildkite.com/pricing) plan have an emergency email available for operational and security incidents, as part of the Buildkite SLA. Contact your Customer Success Manager for more information.
- **Keep a non-SSO login path:** If you use [single sign-on (SSO)](/docs/platform/sso), keep at least one user whose SSO requirement is optional, so that someone can log back in if you need to [disable and re-enable SSO](/docs/platform/team-management/permissions#removing-users-during-a-security-incident-disabling-and-re-enabling-sso).
- **Turn on audit log streaming:** Review the [audit log](/docs/platform/audit-log) (Enterprise plan only) and stream its events to your security information and event management (SIEM) system using [Amazon EventBridge](/docs/pipelines/integrations/observability/amazon-eventbridge), so that you can detect and investigate suspicious activity.
- **Capture build trigger information:** Buildkite stores information on incoming webhooks for approximately one week for troubleshooting only, and this information [cannot be used for audit](/docs/pipelines/security/incoming-webhooks). If you need a durable record of what triggered each build, [capture the webhook](/docs/pipelines/security/incoming-webhooks#how-do-i-access-the-webhook-that-triggered-a-build) yourself.

## Contain the incident

The following actions limit what an attacker can do with compromised access. Choose the actions that match the scope of the incident.

### Remove a compromised user

Remove a compromised user from your Buildkite organization immediately. Removing the user cuts off their access to the resources of your Buildkite organization, which is as effective as ending all their sessions in your organization. Learn how to remove a user in the Buildkite interface or using the GraphQL API in [Removing users during a security incident](/docs/platform/team-management/permissions#removing-users-during-a-security-incident).

If you use SSO, also disable or remove the user in your identity provider. Otherwise, the user can log in with SSO again and rejoin your Buildkite organization. Learn more in [Removing users from an organization with enabled SSO](/docs/platform/team-management/permissions#removing-users-during-a-security-incident-removing-users-from-an-organization-with-enabled-sso). If an attacker controls your identity provider, the scope of the incident is beyond what Buildkite tools alone can remediate.

To log a user out of all their sessions across the Buildkite platform, send the affected user IDs to support@buildkite.com. Organizations don't own user accounts, so this action is not self-service.

### Revoke compromised tokens

Revoke any token that may have been exposed:

- **Agent tokens:** [Revoke the agent token](/docs/agent/self-hosted/tokens#revoke-a-token) using the Buildkite interface, the REST API, or the GraphQL API. Revoking an agent token prevents new agents from registering with it, but doesn't disconnect agents that are already connected, so also stop or replace those agents.
- **API access tokens:** [Remove your organization from the token](/docs/apis/managing-api-tokens#auditing-tokens-removing-an-organization-from-a-token) on the API access audit page. The token's owner cannot add your organization back.
- **Other tokens:** Identify the token type from its prefix using [Token security](/docs/platform/security/tokens), and contact Buildkite support for any token you cannot revoke yourself.

### Rotate exposed secrets

Rotate every secret that the compromised user, token, or agent could access, starting with production deployment credentials. Update the rotated values in [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets) or your external secrets store. If a secret value appears in a job log without being redacted, rotate the secret and contact security@buildkite.com.

### Stop unwanted builds

To stop native GitHub webhook-triggered builds in a pipeline, use the **Disable Incoming GitHub Webhook Processing** option described in [Disabling incoming GitHub webhook processing](/docs/pipelines/source-control/github#disabling-incoming-github-webhook-processing). This does not disable GitHub Actions pipeline triggers. [Disable those separately](/docs/apis/rest-api/pipeline-triggers#update-a-pipeline-trigger) by setting `enabled` to `false`.

A pipeline's webhook URL contains its secret. If a webhook URL has been compromised, contact Buildkite support to reissue it. Learn more in [Incoming webhooks](/docs/pipelines/security/incoming-webhooks#can-i-re-issue-a-webhook-secret-using-the-buildkite-ui).

### Force all users to re-authenticate

If multiple accounts may be compromised, a Buildkite organization administrator can disable and re-enable SSO to force all users to re-authorize. This also rescinds the SSO authorization of the administrator who disables SSO. API access tokens are not subject to SSO requirements, so this action does not replace removing compromised users. Learn more in [Disabling and re-enabling SSO](/docs/platform/team-management/permissions#removing-users-during-a-security-incident-disabling-and-re-enabling-sso).

## Investigate the incident

Use the [audit log](/docs/platform/audit-log) to identify what a compromised user or token did, filtering by actor, event type, or pipeline (Enterprise plan only). Review the [logged events](/docs/platform/audit-log#logged-events) for token creation, changes to SSO providers, secret access, and changes to team membership and pipeline visibility.

The Buildkite incident response team can audit access logs to identify which users and IP addresses accessed builds containing leaked information. Customers on the [Enterprise](https://buildkite.com/pricing) plan can request older logs to be rehydrated for in-depth forensic analysis.

## Recover and harden

After you've contained the incident, review your Buildkite organization against the [Security hardening checklist](/docs/platform/security/hardening-checklist) to reduce the impact of a future incident. For example, set expiry dates on agent tokens and API access tokens, and replace static cloud credentials with [OIDC](/docs/pipelines/security/oidc).
