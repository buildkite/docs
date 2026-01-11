When [configuring the Buildkite CLI with an API access token](/docs/platform/cli/configuration), ensure it has the **Read Packages** and **Write Packages** REST API scopes, which allows this token to publish files to any source registry your user account has access to within your Buildkite organization.

You can also override this configured token by passing in a different token value using the `BUILDKITE_API_TOKEN` environment variable when running the `bk` command:

```bash
BUILDKITE_API_TOKEN=$another_token_value bk package push organization-slug/registry-slug ./path/to/my/file.ext
```

If you have [installed the Buildkite CLI](/docs/platform/cli/installation) to your [self-hosted agents](/docs/agent/v3/self-hosted/installing), you can also do the following:

- Use the `bk` command from within your Buildkite pipelines.

- Using the `BUILDKITE_API_TOKEN` environment variable, pass in a Buildkite OIDC token value generated from your agents that meets your source registry's [OIDC policy](/docs/package-registries/security/oidc#define-an-oidc-policy-for-a-registry). Learn more about these tokens in [OIDC in Buildkite Package Registries](/docs/package-registries/security/oidc).
