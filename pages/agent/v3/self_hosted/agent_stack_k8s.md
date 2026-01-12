# Agent Stack for Kubernetes overview

The Buildkite Agent Stack for Kubernetes (`agent-stack-k8s`) is a Kubernetes [controller](https://kubernetes.io/docs/concepts/architecture/controller/) that uses Buildkite's [Agent API](/docs/apis/agent-api) to watch for scheduled jobs assigned to the controller's queue.

## Architecture

When a matching job is returned from the Agent REST API, the controller creates a Kubernetes job containing a single Pod with containers that will acquire and run the Buildkite job. The job contains a [PodSpec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodSpec) that defines all the containers required to acquire and run a Buildkite job:

- Adding an init container to:
  * Copy the agent binary onto the workspace volume (`copy-agent`).
  * Check that other container images pull successfully before starting (`imagecheck`).
- Adding a container to run the Buildkite agent (`agent`).
- Adding a container to clone the source repository (`checkout`).
- Modifying the (`container-N`) user-specified containers to:
  * Overwrite the entrypoint to the agent binary.
  * Run with the working directory set to the workspace.

> 📘
> The Agent Stack for Kubernetes controller works with the Agent API in version 0.28.0 and later of the controller. Earlier versions of the controller work with the GraphQL API.

## Before you start

- A Kubernetes cluster.
- A [Buildkite cluster](/docs/pipelines/security/clusters/manage) and an [agent token](/docs/agent/v3/self-hosted/tokens#create-a-token) for this cluster.

<!-- vale off -->

- (Optional) Create a unique [self-hosted queue](/docs/agent/v3/targeting/queues/managing#create-a-self-hosted-queue) for this Buildkite cluster.
  * If [queue tags are not explicitly specified when the agent is started](/docs/agent/v3/targeting/queues#setting-an-agents-queue), then the controller will pull jobs from the [default queue](/docs/agent/v3/targeting/queues#the-default-queue). You can define the queue name to be whatever suits your requirements to query the API for scheduled jobs assigned to that queue. However, the examples used throughout this documentation assume the queue name of **kubernetes**.
- Helm version v3.8.0 or newer (as support for OCI-based registries is required).

<!-- vale on -->

- If working with a version of the Agent Stack for Kubernetes controller prior to 0.28.0, a [Buildkite API access token with the GraphQL scope enabled](/docs/apis/graphql-api#authentication).

> 📘 A note on using GraphQL API tokens
> Since the Agent Stack for Kubernetes controller version 0.28.0 and later works with the [Agent REST API](/docs/apis/agent-api), the Buildkite GraphQL API is no longer used. Additionally, the organization slug and cluster UUID can be inferred using the Agent Token. Therefore, if you are upgrading from an older version of the controller to its current version, your Buildkite API access token with the GraphQL scope enabled, org, and cluster UUID can all be safely removed from your configuration or Kubernetes Secret. Only an [agent token](/docs/agent/v3/self-hosted/tokens#create-a-token) for your Buildkite cluster is required.

## Get started with the Agent Stack for Kubernetes

Learn more about how to set up the Buildkite Agent Stack for Kubernetes from the [Installation](/docs/agent/v3/self-hosted/agent-stack-k8s/installation) page.

## Development and contributing

Since the Buildkite Agent Stack for K8s is open source, you can make your own contributions to this project. Learn more about how to do this from in [Agent Stack K8s Development](https://github.com/buildkite/agent-stack-k8s/blob/main/DEVELOPMENT.md).
