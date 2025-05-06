# Default container resources (requests and limits)

## Using `pod-spec-patch` in the Controller's Configuration

In the controller's values YAML, you can specify the default resources (requests/limits) to apply to Pods/containers:

```yaml
# values.yaml
agentStackSecret: <name of predefend secrets for k8s>
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
    - name: checkout       # this container clones the repo
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

All Jobs created by the `agent-stack-k8s` controller will have these resources applied. To override these resources for a single job, use the `kubernetes` plugin with `podSpecPatch` to define container resources:

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
        - name: container-0    # <---- Please specify this as exactly `container-0`.
          resources:           #       We are working on making this more ergonomic
            requests:
              cpu: 1000m
              memory: 50Mi
            limits:
              memory: 1Gi

- name: Hello from a container with default resources
  command: echo Hello World!
```

## Configuring imagecheck-* containers

Defining [CPU](https://kubernetes.io/docs/tasks/configure-pod-container/assign-cpu-resource/#cpu-units) and [memory](https://kubernetes.io/docs/tasks/configure-pod-container/assign-memory-resource/#memory-units) resource limits can be set with the `image-check-container-cpu-limit` and `image-check-container-memory-limit` configuration values:

```
# values.yaml
config:
  image-check-container-cpu-limit: 100m
  image-check-container-memory-limit: 128Mi
```
