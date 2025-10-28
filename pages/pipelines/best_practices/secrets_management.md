# Secrets management

Proper secrets management is key to overall security of your CI/CD infrastructure. The following are some recommendations on keeping your secrets safe in your Buildkite pipelines:

- Use Buildkite's native secret management tools whenever possible. Start with the built-in [Buildkite secrets and redaction](/docs/pipelines/security/secrets/buildkite-secrets) feature, or explore the [secrets plugins](/docs/pipelines/integrations/plugins/directory) available for different secret stores.
- Rotate your secrets regularly. Even if you don't think a secret has been compromised, regular [automated rotation](/docs/apis/managing-api-tokens#api-token-security-rotation) limits the window of opportunity if something does go wrong.
- Keep secrets scoped as tightly as possible. Only expose a secret to the specific pipeline steps that actually need it. For example, don't allow test steps to have access to production deployment credentials. You can configure granular access using [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets#use-a-buildkite-secret-in-a-job) or through plugins like the [vault secrets plugin](https://buildkite.com/resources/plugins/buildkite-plugins/vault-secrets-buildkite-plugin/).
- Track how your secrets are being used. [Audit logs](/docs/platform/audit-log) showing which steps consume which secrets help you maintain visibility into your security posture and make compliance reporting much easier when that time comes around.

> 📘
> For in-depth information on security best practices for Buildkite Pipelines, see [Enforcing security controls](/docs/pipelines/best-practices/enforcing-security-controls).
