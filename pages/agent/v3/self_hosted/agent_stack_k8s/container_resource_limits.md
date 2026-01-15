# Container resources (requests and limits)

Default resources for requests and limits can be allocated to Pods and their containers using the PodSpec patch in the Buildkite [Agent Stack for Kubernetes controller's values YAML configuration file](#using-the-podspec-patch-in-the-controller-values-yaml-configuration-file), which applies across the board, or within a [pipeline's YAML file](#overriding-the-podspec-patch-for-a-single-job), which can override those defined in the values YAML configuration file.

Alternatively, Resource Classes can be configured, allowing workload to decide resources by specifying `resource_class` Agent tags.

## Using resource class

Resource Classes allow you to define reusable resource configurations that can be applied to CI workloads based on agent tags.

> 📘 Minimum version requirement
> To implement the agent configuration options described on this section, version 0.31.0 or later of the Agent Stack for Kubernetes controller is required.

### Configuration

Resource classes are defined in the controller configuration under the `resource-classes` key:

```yaml
# values.yaml
config:
  resource-classes:
    class-name:
      resource:      # Optional: Kubernetes resource requirements
        requests:
          cpu: "100m"
          memory: "128Mi"
        limits:
          cpu: "200m"
          memory: "256Mi"
      nodeSelector:  # Optional: Kubernetes node selector
        instance-type: "small"
        zone: "us-west-2a"
```

+ **resource** (optional): [Kubernetes ResourceRequirements object](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) that will be applied to the command container
  * **requests**: Resource requests (CPU, memory, etc.)
  * **limits**: Resource limits (CPU, memory, etc.)
+ **nodeSelector** (optional): Key-value pairs for [Kubernetes node selection](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector)

### Usage

To use a resource class in your CI pipeline, specify the `resource_class` agent tag:

```yaml
# pipeline.yaml
steps:
  - label: "Build"
    command: "make build"
    agents:
      resource_class: "medium" # <-- New!
```

### Example configurations

```yaml
# values.yaml
config:
  resource-classes:
    xs:
      resource:
        requests:
          cpu: "100m"
          memory: "128Mi"
        limits:
          cpu: "200m"
          memory: "256Mi"
    gpu:
      resource:
        requests:
          nvidia.com/gpu: "1"
          cpu: "1000m"
          memory: "2Gi"
        limits:
          nvidia.com/gpu: "1"
          cpu: "2000m"
          memory: "4Gi"
      nodeSelector:
        accelerator: "nvidia-tesla-k80"
    spot:
      nodeSelector:
        node-type: "spot"
        instance-type: "large"
```

### Default resource class

> 📘 Minimum version requirement
> To configure a default resource class, version 0.37.0 or later of the Agent Stack for Kubernetes controller is required.

You can specify a default resource class that applies to jobs without an explicit `resource_class` agent tag. This ensures all jobs receive resource requests and limits, even when pipeline steps don't specify a resource class.

Configure the default using the `default-resource-class-name` key, which must reference a named resource class from `resource-classes`:

```yaml
# values.yaml
config:
  resource-classes:
    small:
      resource:
        requests:
          cpu: "500m"
          memory: "512Mi"
    large:
      resource:
        requests:
          cpu: "2"
          memory: "4Gi"

  default-resource-class-name: "small"
```

With this configuration:

+ Jobs without a `resource_class` agent tag receive the `small` resource class
+ Jobs that explicitly specify `resource_class: large` (or any other defined class) use that class instead

The controller validates that `default-resource-class-name` references an existing resource class at startup. If the specified class doesn't exist in `resource-classes`, the controller fails to start with an error.


## Using the PodSpec patch in the controller values YAML configuration file

In the Buildkite Agent Stack for Kubernetes controller's values YAML configuration file, you can specify the default resources (requests and limits) to apply to the Pods and containers:

```yaml
# values.yaml
agentStackSecret: <name-of-predefined-secrets-for-kubernetes>
config:
  pod-spec-patch:
    initContainers:
    - name: copy-agent
    resources:
      requests:
        cpu: 100m
        memory: 50Mi
      limits:
        memory: 100Mi
    containers:
    - name: agent          # this container acquires the job
      resources:
        requests:
          cpu: 100m
          memory: 50Mi
        limits:
          memory: 1Gi
    - name: checkout       # this container clones the repository
      resources:
        requests:
          cpu: 100m
          memory: 50Mi
        limits:
          memory: 1Gi
    - name: container-0    # the job runs in a container with this name by default
      resources:
        requests:
          cpu: 100m
          memory: 50Mi
        limits:
          memory: 1Gi
```

## Overriding the PodSpec patch for a single job

Following on from the Agent Stack for Kubernetes controller's YAML configuration values file above, all the Kubernetes Jobs created by the controller will have the resources (defined in this file) applied to them. To override these resources for a single job, use the `kubernetes` plugin with `podSpecPatch` to define container resources. For example:

```yaml
# pipelines.yaml
agents:
  queue: kubernetes
steps:
- name: Hello from a container with more resources
  command: echo Hello World!
  plugins:
  - kubernetes:
      podSpecPatch:
        containers:
        - name: container-0    # <-- Specify this exactly as `container-0`.
          resources:           #     Currently under experimentation to make this more ergonomic.
            requests:
              cpu: 1000m
              memory: 50Mi
            limits:
              memory: 1Gi

- name: Hello from a container with default resources
  command: echo "Hello World!"
```

## Configuring imagecheck-* containers

To define [CPU](https://kubernetes.io/docs/tasks/configure-pod-container/assign-cpu-resource/#cpu-units) and [memory](https://kubernetes.io/docs/tasks/configure-pod-container/assign-memory-resource/#memory-units) resource limits for your containers, use the `image-check-container-cpu-limit` and `image-check-container-memory-limit` configuration values:

```
# values.yaml
config:
  image-check-container-cpu-limit: 100m
  image-check-container-memory-limit: 128Mi
```
