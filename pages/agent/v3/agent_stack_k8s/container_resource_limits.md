# Default container resources (requests and limits)

In the Buildkite Agent Stack for Kubernetes controller's values YAML configuration file, you can specify the default resources (requests and limits) to apply to the Pods and containers:

```yaml
# values.yaml
agentStackSecret: <name of predefend secrets for Kubernetes>
config:
  org: <your-org-slug>
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
