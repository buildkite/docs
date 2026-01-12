# Running builds

After you've [installed](/docs/agent/v3/self-hosted/agent-stack-k8s/installation), [configured](/docs/agent/v3/self-hosted/agent-stack-k8s/controller-configuration), and [set up](/docs/agent/v3/self-hosted/agent-stack-k8s/agent-configuration) the Buildkite Agent Stack for Kubernetes controller, and it is monitoring the Agent API for jobs assigned to the `kubernetes` queue, you can start creating builds in your pipelines.

## Defining steps

A pipeline step can target the `kubernetes` queue with [agent tags](/docs/agent/v3/targeting/queues). For example:

```yaml
steps:
- label: "\:kubernetes\: Hello World!"
  command: echo Hello World!
  agents:
    queue: kubernetes
```

This YAML step configuration creates a Buildkite job containing an agent tag of `queue=kubernetes`.
The `agent-stack-k8s` controller retrieves this job using the Agent API and converts it into a Kubernetes job.

The Kubernetes job contains a single Pod with containers that will check out the pipeline's Git repository and use the `buildkite/agent:latest` (default image) container to run the `echo Hello World!` command.

### Kubernetes plugin

For defining of more complicated pipeline steps, additional configurations can be used with the `kubernetes` plugin.

Unlike other [Buildkite plugins](/docs/pipelines/integrations/plugins), there is no corresponding plugin repository for the `kubernetes` plugin. Instead, this `kubernetes` plugin syntax is reserved for and interpreted by the `agent-stack-k8s` controller. For example, defining `checkout.skip: true` will skip cloning the pipeline's repo for the job:

```yaml
steps:
- label: "\:kubernetes\: Hello World!"
  command: echo Hello World!
  agents:
    queue: kubernetes
  plugins:
  - kubernetes:
      checkout:
        skip: true
```

## Cloning private repositories

As is the case with standalone [Buildkite Agent installations](/docs/agent/v3/self-hosted/install), to access and clone private repositories, you need to make [Git credentials](/docs/agent/v3/self-hosted/agent-stack-k8s/git-credentials) available for the agent to use. These credentials can be in the form of a SSH key for cloning over `ssh://` or with a `.git-credentials` file for cloning over `https://`.

## Kubernetes node selection

The Buildkite Agent Stack for Kubernetes controller can schedule your Buildkite jobs to run on particular Kubernetes Nodes with matching [_labels_](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) using Kubernetes PodSpec [`nodeSelector`](#kubernetes-node-selection-nodeselector) and [`nodeName`](#kubernetes-node-selection-nodename) fields.

### nodeSelector

The [`nodeSelector`](https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes/#create-a-pod-that-gets-scheduled-to-your-chosen-node) field of the PodSpec can be used to schedule your Buildkite jobs on a chosen Kubernetes Node with matching labels. The `nodeSelector` field can be defined in the controller's configuration using `pod-spec-patch`. This will apply to all Buildkite jobs processed by the controller:

```yaml
# values.yml
...
config:
  pod-spec-patch:
    nodeSelector:
      nodecputype: "amd64"  # <--- run on nodes labelled as 'nodecputype=amd64'
...
```

The `nodeSelector` field can also be defined under `podSpecPatch` using the `kubernetes` plugin. It will apply only to this job and will override any __matching__ labels defined under `nodeSelector` in the controller's configuration:

```yaml
# pipeline.yaml
steps:
- label: "\:kubernetes\: Hello World!"
  command: echo Hello World!
  agents:
    queue: kubernetes
  plugins:
  - kubernetes:
      podSpecPatch:
        nodeSelector:
          nodecputype: "arm64"  # <--- override nodeSelector `nodecputype` label from 'amd64' -> 'arm64'
...
```

### nodeName

The [`nodeName`](https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes/#create-a-pod-that-gets-scheduled-to-specific-node) field of the PodSpec can be used to schedule your Buildkite jobs on a specific Kubernetes Node.

The `nodeName` field can be defined in the controller's configuration using `pod-spec-patch`. This will apply to all Buildkite jobs processed by the controller:

```yaml
# values.yml
...
config:
  pod-spec-patch:
    nodeName: "k8s-worker-01"
...
```

The `nodeName` field can also be defined in under `podSpecPatch` using the `kubernetes` plugin. It will apply only to this job and will override `nodeName` in the controller's configuration:

```yaml
# pipeline.yaml
steps:
- label: "\:kubernetes\: Hello World!"
  command: echo Hello World!
  agents:
    queue: kubernetes
  plugins:
  - kubernetes:
      podSpecPatch:
        nodeName: "k8s-worker-03"  # <--- override nodeName 'k8s-worker-01' -> 'k8s-worker-03'
...
```
