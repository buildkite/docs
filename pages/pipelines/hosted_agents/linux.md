# Linux hosted agents

Linux instances for Buildkite hosted agents are offered with two architectures:

- ARM
- AMD64 (x64_86)

To accommodate different workloads, instances are capable of running up to 8 hours. If you require longer running agents please contact support.

## Size

Buildkite offers a selection of instance sizes, allowing you to tailor your hosted agents' resources to the demands of your jobs. Below is a breakdown of the available sizes.

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

## Image configuration

To configure your Linux instance you can use the [Docker Compose](https://github.com/buildkite-plugins/docker-compose-buildkite-plugin) plugin.

## Cache volumes

> 🚧 Under development
> This feature is currently not available.

Cache volumes will provide:

- An optimal solution for storing dependencies that are shared across various jobs, or for housing Docker images. This feature is designed to enhance efficiency by reusing these resources, thereby reducing the time spent on each job.
- Cluster-wide accessibility. This means that all pipelines within a single cluster can access the same cache volume. For instance, if multiple pipelines within a cluster depend on node modules, these pipelines will all reference and benefit from the same cache volume, ensuring consistency and speed.
- Flexibility with size, starting from as little as 5GB with auto-scaling up to 249 GB
- Docker caching, which will employ specialized machines that are tailored to build your images significantly faster than standard machines
- Git mirror caching
