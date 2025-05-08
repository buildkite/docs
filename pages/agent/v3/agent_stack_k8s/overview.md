# Agent Stack for Kubernetes overview

The Buildkite Agent Stack for Kubernetes `agent-stack-k8s` is a Kubernetes [controller](https://kubernetes.io/docs/concepts/architecture/controller/) that uses Buildkite's [Agent API](/docs/apis/agent-api) to watch for scheduled jobs assigned to the controller's queue.

## Architecture

When a matching job is returned from the GraphQL API, the controller creates a Kubernetes job containing a single Pod with containers that will acquire and run the Buildkite job. The job contains a [PodSpec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodSpec) that defines all the containers required to acquire and run a Buildkite job:

- Adding an init container to:
  * Copy the agent binary onto the workspace volume (`copy-agent`).
  * Check that other container images pull successfully before starting (`imagecheck`).
- Adding a container to run the Buildkite agent (`agent`).
- Adding a container to clone the source repository (`checkout`).
- Modifying the (`container-N`) user-specified containers to:
  * Overwrite the entrypoint to the agent binary.
  * Run with the working directory set to the workspace.

<!-- vale off -->

The entry point rewriting and ordering logic is heavily inspired by the approach used in [Tekton](https://github.com/tektoncd/pipeline/blob/933e4f667c19eaf0a18a19557f434dbabe20d063/docs/developers/README.md#entrypoint-rewriting-and-step-ordering).

<!-- vale on -->

## Requirements

> 📘 A note on GraphQL API token redundancy
> Starting with v0.28.0 of the controller, the Buildkite GraphQL API is no longer used. If you are upgrading from an older version, your GraphQL-enabled token can be safely removed from your configuration or Kubernetes secret. Only the agent token is required.

- A Kubernetes cluster
- A Buildkite API access token with the [GraphQL scope enabled](/docs/apis/graphql-api#authentication)
- A cluster's [agent token](/docs/agent/v3/tokens#create-a-token)
- A cluster's [Queue](/docs/pipelines/clusters/manage-queues#create-a-self-hosted-queue)
  * The UUID of the Cluster is also required. See [Obtain Cluster UUID](https://github.com/buildkite/agent-stack-k8s/blob/main/docs/installation.md#how-to-find-a-buildkite-clusters-uuid)
- Helm version v3.8.0 or newer (as support for OCI-based registries is required).

## Get started with the Agent Stack for Kubernetes

Follow the [installation instructions](/docs/agent/v3/agent-stack-k8s/installation) to set up the Buildkite Agent Stack for Kubernetes.

## Development and contributing

If you would like to contribute to the development of the , follow the [development instructions](https://github.com/buildkite/agent-stack-k8s/blob/main/DEVELOPMENT.md) in the [official GitHub repository](https://github.com/buildkite/agent-stack-k8s) for the Buildkite Agent Stack for Kubernetes.