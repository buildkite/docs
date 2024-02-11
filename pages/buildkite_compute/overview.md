# What is compute

This new feature provides an infrastructure-as-a-service layer, allowing you to run Buildkite agents on a fully managed platform. With Compute Services, the infrastructure management tasks traditionally handled by your team, such as provisioning, scaling, and maintaining the servers that run your agents, can now be managed by Buildkite.

Buildkite compute services is currently in private trials, you need to contact support to express interest and have the service switched on for your organisation **are there limitations here for example if I contacted support are they likely to turn it on for me, or is it currently restricted to enterprise clients**

## Creating a compute queue

You can create different compute queues to handle different jobs that require a different configuration of types and sizes. 


## Compute Types

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

Cache volumes are currently only offered for Linux.

Our cache volumes are great for storing your dependencies to be used across your jobs or docker images.

You should not use cache volumes for artifacts of jobs that are to be used by other jobs. These are better suited for an artifact storage. Our agents and cache volumes are defined to be ephemeral.

A cache volume can be accessed from all the pipelines within a cluster. So if you have multiple pipelines using node modules as a dependency within a cluster they will all be referring to the same cache volume.

We have seen very high cache hit ratios for you to hit your latest cache volume.

Cache volumes can be created for as little as XX GB and can grow up to 249 GB. Once you create a cache volume we scale it up automatically. 

Our cache volumes currently do not clean up unused items stored in them. Cleaning it up is soon to be on our roadmap.

Cache volumes are prices according to two values. You pay an hour storage rate per each GB you store in our cache volumes and you also pay a set fee every time you use that cache volume in your job.

For docker cache we use special machines for you to have your build images multiple times faster than your usual machine. You will be charged an extra amount for every time you build docker images.

We also cache your git mirror by d

## Secrets

### Buildkite secrets

We offer two solutions for secrets, Buildkite secrets, and using your own service provider, more details about using these solutions can be found [here](/docs/buildkite-compute/secrets)


## Compliance

Our compute is SOC2 compliant.


## Disaster recovery

Our agents are located in North America and Europe.

We can support your legal requirements in terms of specific regions. Please contact support if you have any requirements around the regions your agents need to be hosted in.

