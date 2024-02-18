# What is compute

Buildkite compute provides an infrastructure-as-a-service layer, allowing you to run agents on a fully managed platform. With Compute Services, the infrastructure management tasks traditionally handled by your team, such as provisioning, scaling, and maintaining the servers that run your agents, can now be managed by Buildkite.

Buildkite compute is currently in private trials, you need to contact support to express interest and have the service switched on for your organization.

## Creating a compute queue

You can set up distinct compute queues, each configured with specific types and sizes to efficiently manage jobs with varying requirements.

To create a compute queue navigate to the cluster where you want your compute queue to reside, select _New Queue_ and select _Hosted_ as the compute option. follow the prompts to configure your compute services. 

### Configuring a compute queue

Once your queue is created you can navigate to settings in the queue and change the machine capacity, and set the queue as the default queue for the cluster

## Compute types

During our private trial phase, we are offering both Mac and Linux agents. We plan to extend our services to include Windows agents by late 2024 as part of our ongoing commitment to providing a comprehensive range of options.

For detailed information about the agents please see [Mac Compute Instances](https://buildkite.com/organizations/~/settings)

Usage of all instance types is billed on a per-minute basis. To accommodate different workloads, instances are capable of running up to 8 hours. If you require longer running agents please contact support.

We offer a selection of instance sizes, allowing you to tailor your compute resources to the demands of your jobs. Below is a breakdown of the available instance sizes.

Every Buildkite hosted agent within a cluster benefits from hypervisor-level isolation, ensuring robust separation between each instance.

### Linux

#### Size
<table>
    <thead>
        <tr><th>Size</th><th>vCPU</th><th>RAM</th></tr>
    </thead>
    <tbody>
        <tr><td>Small</td><td>2</td><td>4 GB</td></tr>
        <tr><td>Medium</td><td>4</td><td>8 GB</td></tr>
        <tr><td>Large</td><td>8</td><td>32 GB</td></tr>
    </tbody>
</table>

### Mac

#### Size
<table>
    <thead>
        <tr><th>Size</th><th>vCPU</th><th>RAM</th><th>Price</th></tr>
    </thead>
    <tbody>
        <tr><td>Small</td><td>4</td><td>7 GB</td></tr>
        <tr><td>Medium</td><td>6</td><td>14 GB</td></tr>
        <tr><td>Large</td><td>12</td><td>28 GB</td></tr>
    </tbody>
</table>

## Using private GitHub repositories in your compute pipelines

To use a private GitHub repository with Buildkite compute services you will need to authorize Buildkite to access your repository.

1. Navigate to your Buildkite org settings page [here](https://buildkite.com/organizations/~/settings).
1. On the left hand menu select _Repository Providers_.
1. Select the _GitHub (with code access)_ option.
1. Follow the prompts to authorize the services on your GitHub account, you can restrict access to specific repositories during setup.

## Moving your pipeline to a compute services

- Ensure your pipeline is in the same cluster as the compute queue you setup previously see [Manage clusters](/docs/clusters/manage-clusters).
- Set your pipeline to use the GitHub (with code access) service your authorized in the step above.
    * Navigate to your pipeline settings.
    * Select GitHub from the left menu.  
    * Remove the existing repository, or select the _Choose another repository or URL_ link
    * Select the GitHub account including ...(with code access).
    * Select the repository.
    * Select _Save Repository_.
- Ensure each step in the pipeline targets the required compute queue.

You are now ready to run a build on your Buildkite compute queue.

## Compliance

Our compute is SOC2 compliant.

## Disaster recovery

Our agents are located in North America and Europe.

We can support your legal requirements in terms of specific regions. Please contact support if you have any requirements around the regions your agents need to be hosted in.

## Coming soon

### API support for hosted queues
We are working on adding functionality in the API to allow configuration of hosted queues.

### macOS image configuration in the UI
We are building the ability to choose the software versions you require to be installed on the MacOS instances used in your queues.



### Buildkite secrets

Only in the rarest cases does CI not need to access outside services, and in these cases, the usability of the CI is severely limited. To use CI effectively - and to move toward CD, continuous deployment - your CI system needs to be able to safely and securely interact with outside services like observability platforms, cloud providers, and other services.

To do this, you need to be able to securely store secrets like API credentials, SSH keys, and other sensitive information, and be able to use them safely and effectively in your builds. Buildkite Secrets provides such a way to do this - we'll securely store your secrets, and provide a way for you to access them in your builds.

Buildkite Secrets are an encrypted key-value store, where secrets are available to your builds via the Buildkite Agent. Secrets are encrypted both at rest and in transit using SSL, and are decrypted server-side when accessed by the agent. The agent makes it easy to use these secrets in your build scripts, and provides a way to inject secrets into your build steps as environment variables.

Secrets are scoped per-cluster, and all belong to a single cluster - that is, agents outside of the cluster the secret belongs to will not be able to access that secret.

Until Buildkite secrets are available and if you would like to continue using your third party secrets provider like AWS SSM, GC Secrets or Hashicorp Vault we provide plugins that allow you to access these services. If a plugin for the service you use is not listed below please reach out to support.

<table>
    <thead>
        <tr><th>Service</th><th>Plugin</th></tr>
    </thead>
    <tbody>
        <tr><td>AWS SSM</td><td>[plugin](https://github.com/buildkite-plugins/aws-assume-role-with-web-identity-buildkite-plugin)</td></tr>
        <tr><td>GC Secrets</td><td>[plugin](https://github.com/buildkite-plugins/gcp-workload-identity-federation-buildkite-plugin)</td></tr>
        <tr><td>Hashicorp Vault</td><td>[plugin](https://github.com/buildkite-plugins/vault-secrets-buildkite-plugin)</td></tr>
    </tbody>
</table>

### Ability to SSH into a machine

We are working on allowing direct SSH access into the compute instances.

### Usage metrics

Enhanced usage metrics across your compute queues.


