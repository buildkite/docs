# Installation

Before proceeding, make sure that you have met the [requirements](/docs/agent/v3/agent-stack-k8s/overview#requirements) for the Buildkite Agent Stack for Kubernetes.

The recommended way of starting with the Buildkite Agent Stack for Kubernetes is by deploying a [Helm](https://helm.sh) chart with the following inline configuration:

```bash
helm upgrade --install agent-stack-k8s oci://ghcr.io/buildkite/helm/agent-stack-k8s \
    --namespace buildkite \
    --create-namespace \
    --set agentToken=<Buildkite Cluster Agent Token> \
    --set config.org=<Buildkite Org Slug> \
    --set config.cluster-uuid=<Buildkite Cluster UUID> \
    --set-json='config.tags=["queue=kubernetes"]'
```

You will need to create a YAML configuration file with the following values:

```yaml
# values.yml
agentToken: "your-Buildkite-cluster-agent-token"
config:
  org: "Buildkite-organization-slug"
  cluster-uuid: "Buildkite-cluster-UUID"
  tags:
    - queue=kubernetes
```

Next, you need to deploy the Helm chart, referencing the configuration values in the YAML file you've created:

```bash
helm upgrade --install agent-stack-k8s oci://ghcr.io/buildkite/helm/agent-stack-k8s \
    --namespace buildkite \
    --create-namespace \
    --values values.yml
```

Both of these deployment methods will:

- Create a Kubernetes deployment and install the `agent-stack-k8s` controller as a Pod running in the `buildkite` namespace.
  * The `buildkite` namespace is created if it does not already exist in the Kubernetes cluster
- The controller will use the provided `agentToken` to query the Buildkite Agent API looking for jobs:
  * In your Organization (`config.org`)
  * Assigned to the `kubernetes` Queue in your Cluster (`config.cluster-uuid`)

## How to find a Buildkite Cluster's UUID

To find the Buildkite cluster UUID:
- Go to the [Clusters page](https://buildkite.com/organizations/-/clusters)
- Click on the Cluster containing your Cluster Queue
- Click on "Settings"
- The UUID of the Cluster UUID will shown under "GraphQL API Integration"

## Storing Buildkite tokens in Kubernetes Secret

If you prefer to self-manage a Kubernetes Secret containing the agent token instead of allowing the Helm chart to create a secret automatically, Buildkite Agent Stack controller for Kubernetes can referece a custom secret.

Here's how a custom secret can be created:

```bash
kubectl create secret generic <secret-name> -n buildkite \
  --from-literal=BUILDKITE_AGENT_TOKEN='<Buildkite Cluster Agent Token>'
```

This Kubernetes Secret name can be provided to the controller with the `agentStackSecret` option, replacing the `agentToken` option. You can then reference your Kubernetes Secret by name during Helm chart deployments.

To reference your Kubernetes Secret with inline configuration:

```bash
helm upgrade --install agent-stack-k8s oci://ghcr.io/buildkite/helm/agent-stack-k8s \
    --namespace buildkite \
    --create-namespace \
    --set agentStackSecret=<Kubernetes Secret name> \
    --set config.org=<Buildkite Org Slug> \
    --set config.cluster-uuid=<Buildkite Cluster UUID> \
    --set-json='config.tags=["queue=kubernetes"]'
```

To reference your Kubernetes Secret with your configuration values YAML file:

```yaml
# values.yml
agentStackSecret: "Kubernetes-Secret-name"
config:
  org: "Buildkite-organization-slug"
  cluster-uuid: "Buildkite-cluster-UUID"
  tags:
    - queue=kubernetes
```

## Other installation methods

You can also use the following chart as a dependency:

```yaml
dependencies:
- name: agent-stack-k8s
  version: "0.28.0"
  repository: "oci://ghcr.io/buildkite/helm"
```

Alternatively, you can also use this chart as a Helm [template](https://helm.sh/docs/chart_best_practices/templates/):

```
helm template oci://ghcr.io/buildkite/helm/agent-stack-k8s --values values.yaml
```

Latest and previous versions (with digests) of the Buildkite Agent Stack for Kubernetes `agent-stack-k8s` can be found under [Releases](https://github.com/buildkite/agent-stack-k8s/releases) in the Buildkite Agent Stack for Kubernetes [GitHub repository](https://github.com/buildkite/agent-stack-k8s/).

## Controller configuration

Detailed configuration options can be found in the the documentation for [controller Configuration](/docs/agent/v3/agent-stack-k8s/controller-configuration).

## Running builds

After the Buildkite Agent Stack `agent-stack-k8s` Kubernetes controller has been configured and deployed, you are ready to [run a Buildkite build](/docs/agent/v3/agent-stack-k8s/running-builds).
