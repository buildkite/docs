# Secrets management

Protecting sensitive information like API keys, tokens, and credentials is critical for maintaining secure CI/CD pipelines. This page covers best practices for managing secrets in Buildkite Pipelines, including native tools, access controls, and regular maintenance routines.

> 📘
> For in-depth information on security best practices for Buildkite Pipelines, see [Enforcing security controls](/docs/pipelines/best-practices/enforcing-security-controls).

## Managing secrets securely

Proper secrets management is a keystone to overall security of your CI/CD infrastructure. The following are some recommendations on keeping your secrets safe in your Buildkite pipelines:

- Use Buildkite's native secret management tools whenever possible:
    * Built-in [Buildkite secrets and redaction](/docs/pipelines/security/secrets/buildkite-secrets) feature
    * A wide selection of [secrets plugins](/docs/pipelines/integrations/plugins/directory) available for different secret store
These tools are designed to work seamlessly with Buildkite and give you the security features you need without bolting on external solutions.
- Rotate your secrets regularly. Even if you don't think a secret has been compromised, regular rotation limits the window of opportunity if something does go wrong.
- Keep secrets scoped as tightly as possible. Only expose a secret to the specific pipeline steps that actually need it. You can configure this granular access using [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets#use-a-buildkite-secret-in-a-job) or through plugins like the [vault secrets plugin](https://buildkite.com/resources/plugins/buildkite-plugins/vault-secrets-buildkite-plugin/). Also, there's no reason to allow test steps to have access to production deployment credentials.
- Track how your secrets are being used. [Audit logs](/docs/platform/audit-log) showing which steps consume which secrets help you maintain visibility into your security posture and make compliance reporting much easier when that time comes around.
