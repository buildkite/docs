# Installation

Before proceeding, ensure that you have met the [prerequisites](/docs/agent/v3/self-hosted/agent-stack-k8s#before-you-start) for the Buildkite Agent Stack for Kubernetes controller.

> 🚧
> Starting with version 0.29.0 of the controller, [unclustered agent tokens](/docs/agent/v3/self-hosted/unclustered-tokens) are no longer supported. The Buildkite Agent Stack for Kubernetes requires a [Buildkite cluster](/docs/pipelines/security/clusters/manage) and an [agent token](/docs/agent/v3/self-hosted/tokens#create-a-token) for this cluster in order to process Buildkite jobs.

The recommended way to install the Buildkite Agent Stack for Kubernetes controller is to deploy a [Helm](https://helm.sh) chart by running the following command with your appropriate configuration values:

```bash
helm upgrade --install agent-stack-k8s oci://ghcr.io/buildkite/helm/agent-stack-k8s \
    --namespace buildkite \
    --create-namespace \
    --set agentToken=<buildkite-cluster-agent-token>
```

> 📘
> Versions 0.28.1 and earlier of the Agent Stack for Kubernetes controller also requires you to specify a queue, using the argument: `--set-json='config.tags=["queue=arm64"]'`. If you do not specify a queue, then the queue name is assumed to be `kubernetes`.

Alternatively, you can place these configuration values into a YAML configuration file by creating the YAML file in this format:

```yaml
# values.yml
agentToken: "<buildkite-cluster-agent-token>"
# Optionally:
# config:
#   tags:
#     - queue=some-queue
```

> 📘
> If using version 0.27.0 and earlier of the Agent Stack for Kubernetes controller, see [Early versions of the controller](#early-versions-of-the-controller) (below) for details on additional configuration requirements.

<%= render_markdown partial: 'agent/v3/self_hosted/agent_stack_k8s/deploy_helm_chart_using_a_yaml_configuration_file' %>

Both of these deployment methods:

- Create a Kubernetes deployment in the `buildkite` namespace with a single Pod containing the `controller` container.
  * The `buildkite` namespace is created if it does not already exist in the Kubernetes cluster.
- Use the provided `agentToken` to query the Buildkite Agent API looking for jobs:
  * In your Buildkite organization (associated with the `agentToken`)
  * Assigned to the [default queue](/docs/agent/v3/queues#the-default-queue) in your Buildkite cluster (associated with the `agentToken`)

## Early versions of the controller

Versions 0.27.0 and earlier of the Agent Stack for Kubernetes controller also requires you to specify a [Buildkite API access token with the GraphQL scope enabled](/docs/apis/graphql-api#authentication), the organization slug, and the cluster UUID, as additional top-level configuration. For example, in the `values.yml` file:

```yaml
graphqlToken: "<buildkite-api-access-token-with-graphql-scope>"
config:
  org: "<buildkite-organization-slug>"
  cluster-uuid: "<buildkite-cluster-uuid>"
```

To find the Buildkite cluster UUID from the Buildkite interface:

1. Select **Agents** in the global navigation to access your Buildkite organization's [**Clusters** page](https://buildkite.com/organizations/-/clusters).
1. Select the cluster containing your configured queue.
1. Select **Settings**.
1. On the **Cluster Settings** page, scroll down to the **GraphQL API Integration** section and your Buildkite cluster's UUID is shown as the `id` parameter value.

## Storing Buildkite tokens in a Kubernetes Secret

If you prefer to self-manage a Kubernetes Secret containing the agent token instead of allowing the Helm chart to create a secret automatically, the Buildkite Agent Stack for Kubernetes controller can reference a custom secret.

Here is how a custom secret can be created:

```bash
kubectl create namespace buildkite
kubectl create secret generic <kubernetes-secret-name> -n buildkite \
  --from-literal=BUILDKITE_AGENT_TOKEN='<buildkite-cluster-agent-token>'
```

This Kubernetes Secret name can be provided to the controller with the `agentStackSecret` option, replacing the `agentToken` option. You can then reference your Kubernetes Secret by name during Helm chart deployments.

To reference your Kubernetes Secret when setting up the Buildkite Agent Stack for Kubernetes controller, run the Helm chart deployment command with your appropriate configuration values:

```bash
helm upgrade --install agent-stack-k8s oci://ghcr.io/buildkite/helm/agent-stack-k8s \
    --namespace buildkite \
    --create-namespace \
    --set agentStackSecret=<kubernetes-secret-name> \
    --set-json='config.tags=["queue=kubernetes"]'
```

Alternatively, to reference your Kubernetes Secret with your configuration values in a YAML file by creating the YAML file in this format:

```yaml
# values.yml
agentStackSecret: "<kubernetes-secret-name>"
config:
  tags:
    - queue=kubernetes
```

<%= render_markdown partial: 'agent/v3/self_hosted/agent_stack_k8s/deploy_helm_chart_using_a_yaml_configuration_file' %>

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

The latest and earlier versions (with digests) of the Buildkite Agent Stack for Kubernetes controller can be found under [Releases](https://github.com/buildkite/agent-stack-k8s/releases) in the Buildkite Agent Stack for Kubernetes controller [GitHub repository](https://github.com/buildkite/agent-stack-k8s/).

## Controller configuration

Learn more about detailed configuration options in [Controller configuration](/docs/agent/v3/self-hosted/agent-stack-k8s/controller-configuration).

## Running builds

After the Buildkite Agent Stack for Kubernetes controller has been configured and deployed, you are ready to [run a Buildkite build](/docs/agent/v3/self-hosted/agent-stack-k8s/running-builds).
