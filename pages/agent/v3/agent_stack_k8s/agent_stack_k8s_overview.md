# Agent Stack for Kubernetes overview

The Buildkite Agent Stack for Kubernetes `agent-stack-k8s` is a Kubernetes [controller](https://kubernetes.io/docs/concepts/architecture/controller/) that uses the Buildkite [GraphQL API](https://buildkite.com/docs/apis/graphql-api) to watch for scheduled jobs assigned to the controller's queue.

## Architecture

When a matching job is returned from the GraphQL API, the controller creates a Kubernetes job containing a single Pod with containers that will acquire and run the Buildkite job. The [PodSpec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodSpec) contained in the job defines a [PodSpec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodSpec) containing all the containers required to acquire and run a Buildkite job:

- adding an init container to:
  - copy the agent binary onto the workspace volume (`copy-agent`)
  - check that other container images pull successfully before starting (`imagecheck`)
- adding a container to run the Buildkite agent (`agent`)
- adding a container to clone the source repository (`checkout`)
- modifying the (`container-N`) user-specified containers to:
  - overwrite the entrypoint to the agent binary
  - run with the working directory set to the workspace

The entry point rewriting and ordering logic is heavily inspired by the approach used in [Tekton](https://github.com/tektoncd/pipeline/blob/933e4f667c19eaf0a18a19557f434dbabe20d063/docs/developers/README.md#entrypoint-rewriting-and-step-ordering).

## Requirements

- A Kubernetes cluster
- A Buildkite API Access Token with the [GraphQL scope enabled](https://buildkite.com/docs/apis/graphql-api#authentication)
- A Cluster [Agent Token](https://buildkite.com/docs/agent/v3/tokens#create-a-token)
- A Cluster [Queue](https://buildkite.com/docs/pipelines/clusters/manage-queues#create-a-self-hosted-queue)
  - The UUID of the Cluster is also required. See [Obtain Cluster UUID](docs/installation.md#how-to-find-a-buildkite-clusters-uuid)
- Helm version v3.8.0 or newer (as support for OCI-based registries is required).

## Get started with the Agent Stack for Kubernetes

Get started with Buildkite Agent Stack for Kubernetes by following the [installation instructions](https://github.com/buildkite/agent-stack-k8s/blob/main/docs/installation.md) in the `agent-stack-k8s` repository.

## Documentation

Currently, the Buildkite Agent Stack for Kubernetes is extensively documented in the [Documentation](https://github.com/buildkite/agent-stack-k8s/blob/main/docs/README.md) section of its corresponding repository.
