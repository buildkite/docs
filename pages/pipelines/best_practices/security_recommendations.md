# Security best practices

For in-depth information on enforcing Buildkite security controls, see [Enforcing security controls](/docs/pipelines/security/enforcing-security-controls).

## Manage secrets properly

* Native secret management: Use [Buildkite secrets and redaction](/docs/pipelines/security/secrets/buildkite-secrets) and [secrets plugins](https://buildkite.com/docs/pipelines/integrations/plugins/directory).
* Rotate secrets: Regularly update credentials to minimize risk.
* Limit scope: Expose secrets only to the steps that require them. See more in [Buildkite Secrets](/docs/pipelines/security/secrets/buildkite-secrets#use-a-buildkite-secret-in-a-job) and [vault secrets plugin](https://buildkite.com/resources/plugins/buildkite-plugins/vault-secrets-buildkite-plugin/).
* Audit usage: Track which steps consume which secrets.

## Enforce access controls

* Team-based access: Grant permissions per team and specific team needs (read-only or write permissions). See [Teams permissions](/docs/platform/team-management/permissions).
* Branch protections: Limit edits to sensitive pipelines.
* Permission reviews: Audit permissions on a regular basis.
* Use SSO/SAML: Centralize authentication and improve compliance.

## Governance and compliance

* Policy-as-code: Define and enforce organizational rules (e.g., required steps, approved plugins).
* Audit readiness: Retain logs, artifacts, and approvals for compliance reporting.
* Sandbox pipelines: Provide safe environments to test changes without impacting production.
