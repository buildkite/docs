# What are hosted agents

Buildkite compute provides a fully managed platform for you to run your agents.

With Compute Services, the infrastructure management tasks traditionally handled by your team, such as provisioning, scaling, and maintaining the servers that run your agents, can now be managed by Buildkite.

Buildkite compute is currently in private trials, you need to contact support to express interest and have the service switched on for your organization.

## Compute types

During our private trial phase, we are offering both Mac and Linux agents. We plan to extend our services to include Windows agents by late 2024 as part of our ongoing commitment to providing a comprehensive range of options.

For detailed information about available agent sizes and configuration please see [Mac Compute Instances](/docs/buildkite-compute/macos-instances), and [Linux Compute Instances](/docs/buildkite-compute/linux-instances)

Usage of all instance types is billed on a per-minute basis.

Every Buildkite hosted agent within a cluster benefits from hypervisor-level isolation, ensuring robust separation between each instance.

## Creating a compute queue

You can set up distinct compute queues, each configured with specific types and sizes to efficiently manage jobs with varying requirements.

For example you may have two queues setup

* `mac_small_7gb`
* `mac_large_32gb`

Learn more about best practice queue configuration [here](/docs/clusters/overview#clusters-and-queues-best-practice-how-should-i-structure-my-queues)

To create a compute queue, navigate to the cluster where you want your compute queue to reside, select _New Queue_ and select _Hosted_ as the compute option. follow the prompts to configure your compute services.

## Using GitHub repositories in your compute pipelines

Buildkite compute services support both public and private repositories, see [Compute Source Control](/docs/buildkite-compute/source-control) to learn more about setting up code access.

## Migrating your pipelines to compute services

You can migrate existing pipelines to compute services, to learn more see [Compute Pipeline Migration](/docs/buildkite-compute/pipeline-migration)

## Coming soon

### API support for hosted queues
We are working on adding functionality in the API to allow configuration of hosted queues.

### macOS image configuration in the UI
We are building the ability to choose the software versions you require to be installed on the MacOS instances used in your queues.

### Buildkite secrets

Only in the rarest cases does CI not need to access outside services, and in these cases, the usability of the CI is severely limited. To use CI effectively - and to move toward CD, continuous deployment - your CI system needs to be able to safely and securely interact with outside services like observability platforms, cloud providers, and other services.

To do this, you need to be able to securely store secrets like API credentials, SSH keys, and other sensitive information, and be able to use them safely and effectively in your builds. Buildkite Secrets provides a way to do this - we'll securely store your secrets, and provide a way for you to access them in your builds.

Buildkite Secrets are an encrypted key-value store, where secrets are available to your builds via the Buildkite Agent. Secrets are encrypted both at rest and in transit using SSL, and are decrypted server-side when accessed by the agent. The agent makes it easy to use these secrets in your build scripts, and provides a way to inject secrets into your build steps as environment variables.

Secrets will initially be scoped per-cluster - that is, agents outside of the cluster the secret belongs to will not be able to access that secret. We have additional work on the roadmap to allow secrets to be scoped per-pipeline.

Until Buildkite secrets are available and if you would like to continue using your third party secrets provider like AWS SSM, GC Secrets or Hashicorp Vault we provide plugins that allow you to access these services. If a plugin for the service you use is not listed below please contact support.

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



### Ability to SSH into a machine

We are working on allowing direct SSH access into the compute instances.

### Usage metrics

Enhanced usage metrics across your compute queues.



