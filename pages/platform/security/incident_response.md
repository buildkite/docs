# Incident response

This page describes how to prepare for, contain, investigate, and recover from a security incident affecting your Buildkite organization, such as a compromised user account, a leaked token, or an exposed secret.

If you discover a security incident, contact support@buildkite.com immediately. If you've detected an exposed secret, also contact security@buildkite.com. Early notification allows Buildkite to assist with remediation steps.

The following diagram shows the order in which to respond to a suspected compromise, and which containment action matches what was compromised:

<%= image "incident-response-flow.png", width: 1304/2, height: 956/2, alt: "Flowchart of the incident response steps: notify Buildkite, contain the incident by removing a compromised user, revoking a compromised token, rotating an exposed secret, stopping unwanted builds, or forcing all users to re-authenticate, then investigate, remove remaining access, and recover and harden", class: "no-decoration" %>

## Prepare before an incident

Several response actions depend on preparation or require help from Buildkite support. Complete the following steps before you need them:

- **Write a runbook:** Document the containment steps on this page for your Buildkite organization, including the API calls your team would run and who has permission to run them.
- **Record escalation contacts:** Keep the Buildkite support and security contacts in your runbook. Customers on the [Enterprise](https://buildkite.com/pricing) plan have an emergency email available for operational and security incidents, as part of the Buildkite SLA. Contact your Customer Success Manager for more information.
- **Set up a break-glass account:** If you use [single sign-on (SSO)](/docs/platform/sso), someone needs to be able to log in without SSO if you [disable and re-enable SSO](/docs/platform/team-management/permissions#removing-users-during-a-security-incident-disabling-and-re-enabling-sso). Create a dedicated Buildkite organization administrator account for this purpose, and make its SSO requirement optional. Don't make the SSO requirement optional for an administrator account that someone uses every day. Protect the break-glass account with the following controls:

    * **Strong authentication:** Use a long, unique password, and enable [two-factor authentication (2FA)](/docs/platform/tutorials/2fa) on the account.
    * **Secure credential storage:** Store the password, 2FA device or secret, and recovery codes in a restricted vault, and require approval from more than one person to retrieve them.
    * **Restricted use:** Use the account only to recover access during an incident. Don't use it for everyday administration, and don't create API access tokens for it.
    * **Monitoring:** Alert on any [audit log](/docs/platform/audit-log) event whose actor is the break-glass account (Enterprise plan only). Use an email address for the account that delivers to a monitored security mailbox, so that password reset requests and other account notifications are seen.
    * **Periodic validation:** Test the account on a schedule, for example, every quarter. Confirm that you can log in, that the account is still an administrator, and that the vault approval process works, and then rotate the password.

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

## Remove remaining access

Containment removes the access you know about. Before you recover, check that the attacker didn't create another way back in during the incident window, from the earliest suspicious activity found in your investigation until containment.

Review the following changes made during the incident window, and remove or revoke anything you can't account for. The audit log event types listed are a starting point for your search. If your plan doesn't include the audit log, review the same resources directly in the Buildkite interface.

- **Users and teams:** New members, accepted invitations, and changes to team membership or team access to pipelines, such as `ORGANIZATION_MEMBER_CREATED`, `ORGANIZATION_INVITATION_ACCEPTED`, `TEAM_MEMBER_CREATED`, and `TEAM_PIPELINE_CREATED`.
- **Tokens and authorizations:** New API access tokens, agent tokens, and OAuth authorizations, and tokens newly granted access to your Buildkite organization, such as `API_ACCESS_TOKEN_CREATED`, `USER_API_ACCESS_TOKEN_ORGANIZATION_ACCESS_ADDED`, `CLUSTER_TOKEN_CREATED`, `AGENT_TOKEN_CREATED`, and `AUTHORIZATION_CREATED`.
- **Authentication settings:** Changes to SSO providers and organization settings, such as `SSO_PROVIDER_CREATED`, `SSO_PROVIDER_UPDATED`, and `ORGANIZATION_UPDATED`.
- **Pipelines, schedules, and integrations:** Changes that could run code or send data elsewhere, such as `PIPELINE_UPDATED`, `PIPELINE_SCHEDULE_CREATED`, `PIPELINE_VISIBILITY_CHANGED`, `NOTIFICATION_SERVICE_CREATED`, and `SCM_PIPELINE_SETTINGS_UPDATED`.
- **Secrets and clusters:** New or changed Buildkite secrets and cluster permissions, such as `SECRET_CREATED`, `SECRET_UPDATED`, and `CLUSTER_PERMISSION_CREATED`.

Changes outside Buildkite can also give an attacker a way back in. Check the following systems as well:

- **Source control:** In your source control system, review new deploy keys, webhooks, app installations, collaborators, and commits that change pipeline definitions, scripts, or [repository hooks](/docs/agent/hooks#hook-locations-repository-hooks).
- **Agent hosts:** On self-hosted agents, review changes to [agent hooks](/docs/agent/hooks), the [agent configuration file](/docs/agent/self-hosted/configure), SSH keys, scheduled tasks, and running processes. Replacing persistent agents with instances built from a known-good image is often faster and more reliable than inspecting them.

Proceed to recovery when every access path created or changed during the incident window has been removed or accounted for, and monitoring shows no new signs of compromise, such as unexpected agent connections, token use, or builds.

## Recover and harden

After you've contained the incident, review your Buildkite organization against the [Security checklist](/docs/platform/security) to reduce the impact of a future incident. For example, set expiry dates on agent tokens and API access tokens, and replace static cloud credentials with [OIDC](/docs/pipelines/security/oidc).
