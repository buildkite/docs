# `buildkite-agent secret`

> Note: The `secrets` command, as well as its associated server-side features, are currently in feature preview. If you're interested in trialing Buildkite Secrets, [contact support](mailto:support@buildkite.com).

The `buildkite-agent secret` command allows you to query and retrieve secrets from Buildkite's secret storage. This command is useful for fetching secrets that are required by your build scripts, without having to configure third-party secret management systems.

## Getting a secret

<%= render "agent/v3/help/secret_get" %>
