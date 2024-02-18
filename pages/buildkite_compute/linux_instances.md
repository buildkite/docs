## Linux compute instances

Linux instances are offered with two architectures.

- ARM
- AMD64 (x64_86)

To configure your Linux instance you can use the [Docker Compose](https://github.com/buildkite-plugins/docker-compose-buildkite-plugin) plugin.

## Coming soon

### Docker config editing in the UI for Linux compute
We are building functionality to allow you to edit the docker config for your linux images within the Buildkite UI

### Cache volumes for Linux instances

Cache volumes will provide:
- an optimal solution for storing dependencies that are shared across various jobs, or for housing docker images. This feature is designed to enhance efficiency by reusing these resources, thereby reducing the time spent on each job.
- cluster-wide accessibility. This means that all pipelines within a single cluster can access the same cache volume. For instance, if multiple pipelines within a cluster depend on node modules, they will all reference and benefit from the same cache volume, ensuring consistency and speed.
- flexibility with size, starting from as little as 5GB with auto scaling up to 249 GB.
- Docker caching, which will employ specialized machines that are tailored to build your images significantly faster than standard machines.
- Git Mirror caching### Docker config editing in the UI for Linux compute
We are building functionality to allow you to edit the docker config for your linux images within the Buildkite UI

### Cache volumes for Linux instances

Cache volumes will provide:
- an optimal solution for storing dependencies that are shared across various jobs, or for housing docker images. This feature is designed to enhance efficiency by reusing these resources, thereby reducing the time spent on each job.
- cluster-wide accessibility. This means that all pipelines within a single cluster can access the same cache volume. For instance, if multiple pipelines within a cluster depend on node modules, they will all reference and benefit from the same cache volume, ensuring consistency and speed.
- flexibility with size, starting from as little as 5GB with auto scaling up to 249 GB.
- Docker caching, which will employ specialized machines that are tailored to build your images significantly faster than standard machines.
- Git Mirror caching