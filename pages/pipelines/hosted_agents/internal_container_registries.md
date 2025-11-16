# Internal container registries

_Internal container registries_ is a feature of [Buildkite hosted agents](/docs/pipelines/hosted-agents), which allows you to house Docker images built by your pipelines.

> 📘 Default Enterprise plan feature
> Internal container registries is a _default feature_ available to all new and existing Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan.

## Internal container registries overview

Once a [Buildkite cluster has been set up](/docs/pipelines/clusters/manage-clusters#setting-up-clusters), and its first [hosted queue](/docs/pipelines/clusters/manage-queues#create-a-buildkite-hosted-queue) has been started, an internal container registry is created for this cluster, which you can use to manage Open Container Initiative (OCI) images built by your pipelines on Buildkite hosted agents.

To use the internal container registry, you'll need to reference the pre-defined environment variable `$BUILDKITE_HOSTED_REGISTRY_URL` for the registry in Docker commands you use in your pipelines. The value of this environment variable defines the location for your cluster's internal container registry.

The main advantage of using your internal container registry over [cache volumes](/docs/pipelines/hosted-agents/cache-volumes) is that unlike cache volumes, the internal cache volume's storage is _deterministic_, which means that any commands you use in your pipelines to interact with this registry will interact directly with the relevant data stored in this registry. This is in contrast to the [non-deterministic nature of cache volumes](/docs/pipelines/hosted-agents/cache-volumes#lifecycle-non-deterministic-nature), where commands to retrieve data from your cache volume may instead retrieve it from a different source.

## Using your internal container registry

This section provides examples on how to upload and retrieve container images from your internal container registry.

### Building and uploading a container image

