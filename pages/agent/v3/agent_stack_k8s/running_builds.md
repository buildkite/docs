# Running builds

After you configure, deploy, and set up the Buildkite Agent Stack for Kubernetees controller, and it is monitoring the Agent API for jobs assigned to the `kubernetes` queue, you can create builds in your pipelines.

## Defining steps

A pipeline step can target the `kubernetes` queue with [agent tags](/docs/agent/v3/queues):

```yaml
steps:
- label: ":kubernetes: Hello World!"
  command: echo Hello World!
  agents:
    queue: kubernetes
```

An example above will create a Buildkite job containing an agent tag of `queue=kubernetes`.
The `agent-stack-k8s` controller will retrieve this job via the Agent API and convert it into a Kubernetes job.
The Kubernetes job will contain a single Pod with containers that will checkout the pipeline's Git repository and use the (default image) `buildkite/agent:latest` container to run the `echo Hello World!` command.

### The `kubernetes` plugin

For defining of more complicated pipeline steps, additional configurations can be used with the `kubernetes` plugin. 

Unlike other [Buildkite plugins](/docs/pipelines/integrations/plugins), there is no corresponding plugin repository for the `kubernetes` plugin. Rather, this is reserved syntax that is interpreted by the `agent-stack-k8s` controller.
For example, defining `checkout.skip: true` will skip cloning the pipeline's repo for the job:

```yaml
steps:
- label: ":kubernetes: Hello World!"
  command: echo Hello World!
  agents:
    queue: kubernetes
  plugins:
  - kubernetes:
      checkout:
        skip: true
```

## Cloning private repositories

Just like with a standalone installation of the Buildkite agent, in order to access and clone private repositories you will need to make Git credentials available for the Agent to use. These credentials can be in the form of a SSH key for cloning over `ssh://` or with a `.git-credentials` file for cloning over `https://`.

## Defining `nodeSelector`

The `agent-stack-k8s` controller can schedule your Buildkite jobs to run on particular Kubernetes Nodes, using Kubernetes PodSpec fields for `nodeSelector` and `nodeName`.

The `agent-stack-k8s` controller can schedule your Buildkite jobs to run on particular Kubernetes Nodes with matching Labels. The [`nodeSelector`](https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes/#create-a-pod-that-gets-scheduled-to-your-chosen-node) field of the PodSpec can be used to schedule your Buildkite jobs on a chosen Kubernetes Node with matching Labels.

The `nodeSelector` field can be defined in the controller's configuration via `pod-spec-patch`. This will apply to all Buildkite jobs processed by the controller:

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
- label: ":kubernetes: Hello World!"
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

## Defining `nodeName`

The [`nodeName`](https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes/#create-a-pod-that-gets-scheduled-to-specific-node) field of the PodSpec can also be used to schedule your Buildkite jobs on a specific Kubernetes Node.

The `nodeName` field can be defined in the controller's configuration via `pod-spec-patch`. This will apply to all Buildkite jobs processed by the controller:

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
- label: ":kubernetes: Hello World!"
  command: echo Hello World!
  agents:
    queue: kubernetes
  plugins:
  - kubernetes:
      podSpecPatch:
        nodeName: "k8s-worker-03"  # <--- override nodeName 'k8s-worker-01' -> 'k8s-worker-03'
...
```
