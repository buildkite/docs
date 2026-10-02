---
toc: false
---

# Source control

Buildkite Pipelines integrates with source control providers to create builds from repository events. Connecting a provider configures the integration for events and build statuses. Depending on the provider and agent type, you might also need to configure credentials so the agent can clone private repositories.

## Connect a source control provider

- [GitHub](/docs/pipelines/source-control/github)
- [GitHub Enterprise](/docs/pipelines/source-control/github-enterprise)
- [GitLab](/docs/pipelines/source-control/gitlab)
- [Bitbucket](/docs/pipelines/source-control/bitbucket)
- [Bitbucket Server](/docs/pipelines/source-control/bitbucket-server)
- [Origin](/docs/pipelines/source-control/origin)
- [Phabricator](/docs/pipelines/source-control/phabricator)
- [Other Git servers](/docs/pipelines/source-control/git)

## Configure access to private repositories

Choose a repository authentication method based on where your agents run and which provider connection you use:

- **Buildkite hosted agents with GitHub or Origin:** Repository access is included when you connect the full-access GitHub App or an Origin repository. See [Buildkite hosted agent code access](/docs/agent/buildkite-hosted/code-access).
- **SSH key stored in Buildkite Secrets:** This is the recommended option for self-hosted agents, the Limited Access GitHub App, and providers without native repository access. Follow the instructions for [self-hosted agents](/docs/agent/self-hosted/code-access#using-buildkite-secrets-recommended) or [Buildkite hosted agents](/docs/agent/buildkite-hosted/code-access#private-repositories-with-other-providers).
- **SSH key stored on an agent machine:** Self-hosted agents can use keys in the agent user's `~/.ssh` directory. See [Managing SSH keys on agent machines](/docs/agent/self-hosted/code-access#managing-ssh-keys-on-agent-machines).
- **GitHub App installation access token:** As an alternative to SSH keys, self-hosted agents can generate a short-lived token in a `pre-checkout` hook. See [Using GitHub App installation access tokens](/docs/pipelines/source-control/github#using-github-app-installation-access-tokens).
