# Buildkite hosted agents

Buildkite hosted agents provides a fully-managed platform on which you can run your agents, so that you don't have to manage agents in your own self-hosted environment.

With hosted agents, Buildkite handles infrastructure management tasks, such as provisioning, scaling, and maintaining the servers that run your agents.

> 📘 Buildkite hosted agents is currently in its private trials phase
> Please [contact support](https://buildkite.com/support) to express interest in this feature.

## Hosted agent types

During the private trial phase, Buildkite is offering both Mac and Linux hosted agents. Buildkite plans to add support for Windows hosted agents by late 2024, as part of extending these services.

For detailed information about available agent sizes and configuration, please see [Mac hosted agents](/docs/pipelines/hosted-agents/mac), and [Linux hosted agents](/docs/pipelines/hosted-agents/linux).

Usage of all instance types is billed on a per-minute basis.

Every Buildkite hosted agent within a cluster benefits from hypervisor-level isolation, ensuring robust separation between each instance.

## Creating a hosted agent queue

You can set up distinct hosted agent queues, each configured with specific types and sizes to efficiently manage jobs with varying requirements.

For example you may have two queues set up:

* `mac_small_7gb`
* `mac_large_32gb`

Learn more about best practices for configuring queues in [How should I structure my queues](/docs/clusters/overview#clusters-and-queues-best-practices-how-should-i-structure-my-queues).

To create a hosted agent queue:

1. Navigate to the cluster where you want your hosted agent queue to reside.
1. Select **New Queue** and select the **Hosted** option.
1. Follow the prompts to configure your hosted agent services.

## Using GitHub repositories in your hosted agent pipelines

Buildkite hosted agent services support both public and private repositories. Learn more about setting up code access in [Hosted agent code access](/docs/pipelines/hosted-agents/code-access).

## Migrating your pipelines to hosted agent services

Learn more about migrating existing pipelines to Buildkite hosted agent services in [Hosted agent pipeline migration](/docs/pipelines/hosted-agents/pipeline-migration).

## Secret management

> 🚧 Under development
> This feature is currently not available.

Buildkite is developing a secret management feature to securely manage secrets (such as API credentials or SSH keys) for hosted agents. Secrets are required by these hosted agents to access 3rd-party services outside the Buildkite environment.

Secret management provides an encrypted key-value store, where secrets are available to your builds via the Buildkite agent. Secrets are encrypted both at rest and in transit using SSL, and are decrypted server-side when accessed by the agent. The agent makes it easy to use these secrets in your build scripts, and provides a way to inject secrets into your build steps as environment variables.

Secrets will initially be scoped per-cluster. Therefore, if an agent is not associated with a cluster that has a configured secret, the agent will not be able to access this secret. Buildkite has additional work on the roadmap to allow secrets to be scoped per-pipeline.

Until secret management is available, if you would like to continue [using your third party secrets provider like AWS SSM, GC Secrets or Hashicorp Vault](/docs/pipelines/secrets), Buildkite provides plugins that allow you to access these services. If a plugin for the service you use is not listed below please contact support.

<table>
    <thead>
        <tr><th>Service</th><th>Plugin</th></tr>
    </thead>
    <tbody>
        <tr><td>AWS SSM</td><td><a href="https://github.com/buildkite-plugins/aws-assume-role-with-web-identity-buildkite-plugin">aws-assume-role-with-web-identity-buildkite-plugin</a></td></tr>
        <tr><td>GC Secrets</td><td><a href="https://github.com/buildkite-plugins/gcp-workload-identity-federation-buildkite-plugin">gcp-workload-identity-federation-buildkite-plugin</a></td></tr>
        <tr><td>Hashicorp Vault</td><td><a href="https://github.com/buildkite-plugins/vault-secrets-buildkite-plugin">vault-secrets-buildkite-plugin</a></td></tr>
    </tbody>
</table>

## Ability to SSH into a machine

> 🚧 Under development
> This feature is currently not available.

Buildkite is working on allowing direct SSH access into its hosted agents feature.
