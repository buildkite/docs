# Installation

Before proceeding, ensure that you have met the [prerequisites](/docs/agent/v3/agent-stack-k8s/overview#before-you-start) for the Buildkite Agent Stack for Kubernetes.

The recommended way to start setting up the Buildkite Agent Stack for Kubernetes is to deploy a [Helm](https://helm.sh) chart by running the following command with your appropriate configuration values:

```bash
helm upgrade --install agent-stack-k8s oci://ghcr.io/buildkite/helm/agent-stack-k8s \
    --namespace buildkite \
    --create-namespace \
    --set agentToken=<buildkite-cluster-agent-token> \
    --set config.org=<buildkite-organization-slug> \
    --set config.cluster-uuid=<buildkite-cluster-uuid> \
    --set-json='config.tags=["queue=kubernetes"]'
```

Alternatively, you can place these configuration values into a YAML configuration file by creating the YAML file in this format:

```yaml
# values.yml
agentToken: "buildkite-cluster-agent-token"
config:
  org: "buildkite-organization-slug"
  cluster-uuid: "buildkite-cluster-uuid"
  tags:
    - queue=kubernetes
```

<%= render_markdown partial: 'agent/v3/agent_stack_k8s/deploy_helm_chart_using_a_yaml_configuration_file' %>

Both of these deployment methods:

- Create a Kubernetes deployment and install the `agent-stack-k8s` controller as a Pod running in the `buildkite` namespace.
  * The `buildkite` namespace is created if it does not already exist in the Kubernetes cluster.
- Use the provided `agentToken` to query the Buildkite Agent API looking for jobs:
  * In your Buildkite organization (`config.org`)
  * Assigned to the `kubernetes` queue in your cluster (`config.cluster-uuid`)

## How to find a Buildkite cluster's UUID

To find the Buildkite cluster UUID from the Buildkite interface:

1. Select **Agents** in the global navigation to access your Buildkite organization's [**Clusters** page](https://buildkite.com/organizations/-/clusters).
1. Select the cluster containing your configured queue.
1. Select **Settings**.
1. On the **Cluster Settings** page, scroll down to the **GraphQL API Integration** section and your Buildkite cluster's UUID is shown as the `id` parameter value.

## Storing Buildkite tokens in a Kubernetes Secret

If you prefer to self-manage a Kubernetes Secret containing the agent token instead of allowing the Helm chart to create a secret automatically, the Buildkite Agent Stack for Kubernetes controller can reference a custom secret.

Here's how a custom secret can be created:

```bash
kubectl create secret generic <secret-name> -n buildkite \
  --from-literal=BUILDKITE_AGENT_TOKEN='<buildkite-cluster-agent-token>'
```

This Kubernetes Secret name can be provided to the controller with the `agentStackSecret` option, replacing the `agentToken` option. You can then reference your Kubernetes Secret by name during Helm chart deployments.

To reference your Kubernetes Secret when setting up the Buildkite Agent Stack for Kubernetes, run the Helm chart deployment command with your appropriate configuration values:

```bash
helm upgrade --install agent-stack-k8s oci://ghcr.io/buildkite/helm/agent-stack-k8s \
    --namespace buildkite \
    --create-namespace \
    --set agentStackSecret=<kubernetes-secret-name> \
    --set config.org=<buildkite-organization-slug> \
    --set config.cluster-uuid=<buildkite-cluster-uuid> \
    --set-json='config.tags=["queue=kubernetes"]'
```

Alternatively, to reference your Kubernetes Secret with your configuration values in a YAML file by creating the YAML file in this format:

```yaml
# values.yml
agentStackSecret: "kubernetes-secret-name"
config:
  org: "buildkite-organization-slug"
  cluster-uuid: "buildkite-cluster-uuid"
  tags:
    - queue=kubernetes
```

<%= render_markdown partial: 'agent/v3/agent_stack_k8s/deploy_helm_chart_using_a_yaml_configuration_file' %>

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

The latest and earlier versions (with digests) of the Buildkite Agent Stack for Kubernetes `agent-stack-k8s` can be found under [Releases](https://github.com/buildkite/agent-stack-k8s/releases) in the Buildkite Agent Stack for Kubernetes [GitHub repository](https://github.com/buildkite/agent-stack-k8s/).

## Controller configuration

Learn more about detailed configuration options in [Controller configuration](/docs/agent/v3/agent-stack-k8s/controller-configuration).

## Running builds

After the Buildkite Agent Stack `agent-stack-k8s` Kubernetes controller has been configured and deployed, you are ready to [run a Buildkite build](/docs/agent/v3/agent-stack-k8s/running-builds).
