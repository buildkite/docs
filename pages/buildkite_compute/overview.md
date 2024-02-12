# What is compute

Buildkite compute provides an infrastructure-as-a-service layer, allowing you to run agents on a fully managed platform. With Compute Services, the infrastructure management tasks traditionally handled by your team, such as provisioning, scaling, and maintaining the servers that run your agents, can now be managed by Buildkite.

Buildkite compute is currently in private trials, you need to contact support to express interest and have the service switched on for your organisation **are there limitations here for example if I contacted support are they likely to turn it on for me, or is it currently restricted to enterprise clients**

## Creating a compute queue

You can set up distinct compute queues, each configured with specific types and sizes, to efficiently manage jobs with varying requirements.

1. Navigate to the cluster where you want your compute queue to reside. For detailed guidance, refer to our [clusters documentation](/docs/clusters/overview)
1. Proceed to the 'Queues' section.
1. Click on 'New Queue'.
1. Give your queue a key.
1. Choose 'Hosted' as the compute.
1. Select your machnie type.
1. Select your machine architecture.
1. Select you machine capacity.
1. Select you image settings (comming soon) **Need to add something here about what they get out of the box and tell them to contact support if they need a different setup**

### Configuring a compute queue

Once your queue is created you can navigate to settings in the queue and change the machine machine capacity used for the queue, and also mark the queue as the default queue for the cluster

### API integration

The API integration details for the queue can be found in the API Integration section of the queue configuration


## Compute Types

During our private trial phase, we are offering both Mac and Linux agents. We plan to extend our services to include Windows agents by late 2024, as part of our ongoing commitment to providing a comprehensive range of options.
Usage of all instance types is billed on a per-minute basis. To accommodate different workloads, instances are capable of running up to 8 hours. If you reqire longer running agents please contact support.
We offer a selection of instance sizes, allowing you to tailor your compute resources to the demands of your jobs. Below is a detailed breakdown of the available options.

In terms of security, every Buildkite hosted agent within a cluster benefits from hypervisor-level isolation, ensuring robust separation between each instance.

### Linux
Linux machines are offered with two architectures 

* ARM
* AMD64 (x64_86)

#### Size
<table>
    <thead>
        <tr><th>Size</th><th>vCPU</th><th>RAM</th><th>Price</th></tr>
    </thead>
    <tbody>
        <tr><td>Small</td><td>2</td><td>4 GB</td><td></td></tr>
        <tr><td>Medium</td><td>4</td><td>8 GB</td><td></td></tr>
        <tr><td>Large</td><td>8</td><td>32 GB</td><td></td></tr>
    </tbody>
</table>

#### Image options

### Mac
Mac machines are only offered with mac silicon architecture. Please contact support if you have specific needs for intel machines.

#### Size
<table>
    <thead>
        <tr><th>Size</th><th>vCPU</th><th>RAM</th><th>Price</th></tr>
    </thead>
    <tbody>
        <tr><td>Small</td><td>4</td><td>7 GB</td><td></td></tr>
        <tr><td>Medium</td><td>6</td><td>14 GB</td><td></td></tr>
        <tr><td>Large</td><td>12</td><td>28 GB</td><td></td></tr>
    </tbody>
</table>

#### Image options

## Caching

**looks from the planning that this will not be ready till 1/2 way through march, so we should put this in comming soon**

At present, cache volumes are exclusively available for Linux environments.

Our cache volumes serve as an optimal solution for storing dependencies that are shared across various jobs, or for housing docker images. This feature is designed to enhance efficiency by reusing these resources, thereby reducing the time spent on each job.

> 📘 
> cache volumes are not intended for storing job artifacts intended for subsequent use by other jobs. Such artifacts should be directed to a dedicated artifact storage system. The nature of our agents and cache volumes is ephemeral, underscoring the temporary lifespan of the data they contain.

Cache volumes provide cluster-wide accessibility. This means that all pipelines within a single cluster can access the same cache volume. For instance, if multiple pipelines within a cluster depend on node modules, they will all reference and benefit from the same cache volume, ensuring consistency and speed.

Our metrics indicate a high cache hit ratio, boosting the likelihood of your jobs accessing the latest available cache volume, which can significantly expedite your build process.

**get a value for the XX in the line below**
Cache volumes are flexible in size, starting from as little as XX GB and can be scaled up to 249 GB. When you create a cache volume, we manage the scaling seamlessly and automatically to meet your demands.

Currently, our cache volumes do not perform automatic cleanup of unused items. However, introducing a cleanup mechanism is on our roadmap for future implementation.

**do we want to list this pricing model**
The pricing model for cache volumes is twofold: there is an hourly storage rate based on the number of gigabytes stored, in addition to a fixed fee applied each time a cache volume is utilized within a job.

For docker caching, we employ specialized machines that are tailored to build your images significantly faster than standard machines. The use of these specialized machines incurs an additional charge each time you build docker images.

Additionally, we optimize the efficiency of your builds by caching your git mirror. **does this really live in the caching section or should it live in the git section?**

## Pipelines and Git

**Need to add something about pipelines and GIT private repo access (hopefully this week, so we should include it)**
**github code access**
**moving a pipeline into a queue**
**ssh into a machine**
**usage metrics**

## Secrets

### Buildkite secrets

We offer two solutions for secrets, Buildkite secrets, and using your own service provider, more details about using these solutions can be found [here](/docs/buildkite-compute/secrets)
**doesn't look like this will be ready for this 2 weeks, so we probs just need a coming soon, and don't need to pushlish the how to docs yet**

## Compliance

Our compute is SOC2 compliant.


## Disaster recovery

Our agents are located in North America and Europe.

We can support your legal requirements in terms of specific regions. Please contact support if you have any requirements around the regions your agents need to be hosted in.

