# Internal container registries

_Internal container registries_ is a feature of [Buildkite hosted agents](/docs/pipelines/hosted-agents), which allows you to house Docker images built by your pipelines.

> 📘 Default Enterprise plan feature
> Internal container registries is a _default feature_ available to all new and existing Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan.

## Internal container registries overview

Once a [Buildkite cluster has been set up](/docs/pipelines/clusters/manage-clusters#setting-up-clusters), and its first [hosted queue](/docs/pipelines/clusters/manage-queues#create-a-buildkite-hosted-queue) has been started, an internal container registry is created for this cluster, which you can use to manage Open Container Initiative (OCI) images built by your pipelines on Buildkite hosted agents.
