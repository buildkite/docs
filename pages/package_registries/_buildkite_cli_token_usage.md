When [configuring the Buildkite CLI with the appropriate registry write token](/docs/platform/cli/configuration), ensure it has the **Read Packages** and **Write Packages** REST API scopes, which allows this token to publish files to any source registry your user account has access to within your Buildkite organization.

You can also override this configured token by passing in a different token value as the `BUILDKITE_API_TOKEN` environment variable into the `bk` command.

```bash
BUILDKITE_API_TOKEN=$another_token_value bk packages push organization-slug/registry-slug --package-version 1.0.0 --package-path ./path/to/my/file.ext
```

If you have [installed the Buildkite CLI to your self-hosted agents](/docs/platform/cli/installation), you can also do the following:

- Use the `bk` command from within your Buildkite pipelines.

- Using this `BUILDKITE_API_TOKEN` environment variable, pass a Buildkite OIDC token from your agents that meets your source registry's [OIDC policy](/docs/package-registries/security/oidc#define-an-oidc-policy-for-a-registry). Learn more about these tokens in [OIDC in Buildkite Package Registries](/docs/package-registries/security/oidc).
