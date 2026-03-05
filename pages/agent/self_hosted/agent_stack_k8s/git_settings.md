---
toc: false
---

# Git settings

In the Buildkite Agent Stack for Kubernetes controller version v0.13.0 and later, flags for `git clone` and `git fetch` can be overridden on a per-step basis (similar to `BUILDKITE_GIT_CLONE_FLAGS` and `BUILDKITE_GIT_FETCH_FLAGS` env vars) with the `checkout` block:

```yaml
# pipeline.yml
steps:
- label: Hello World!
  agents:
    queue: kubernetes
  plugins:
  - kubernetes:
      checkout:
        cloneFlags: -v --depth 1
        fetchFlags: -v --prune --tags
```

In the Buildkite Agent Stack for Kubernetes controller version v0.16.0 and later, more Git flags and options are supported by the agent: `cleanFlags`, `noSubmodules`, `submoduleCloneConfig`, `gitMirrors` (`cloneFlags`, `lockTimeout`, and `skipUpdate`) and are configurable with the `checkout` block. For example:

```yaml
# pipeline.yml
steps:
- label: Hello World!
  agents:
    queue: kubernetes
  plugins:
  - kubernetes:
      checkout:
        cleanFlags: -ffxdq
        noSubmodules: false
        submoduleCloneConfig: ["key=value", "something=else"]
        gitMirrors:
          path: /buildkite/git-mirrors # optional with volume
          volume:
            name: my-special-git-mirrors
            persistentVolumeClaim:
              claimName: block-pvc
          lockTimeout: 600
          skipUpdate: true
          cloneFlags: -v
```

To avoid setting `checkout` on every step, you can use `default-checkout-params` within `values.yaml` when deploying the stack. These will apply the settings to every job. For example:

```yaml
# values.yaml
...
config:
  default-checkout-params:
    # The available options are the same as `checkout` within `plugin.kubernetes`.
    cloneFlags: -v --depth 1
    noSubmodules: true
    gitMirrors:
      volume:
        name: host-git-mirrors
        hostPath:
          path: /var/lib/buildkite/git-mirrors
          type: Directory
```

## Git mirrors and migrating from Elastic CI Stack for AWS to Kubernetes

If you are migrating to the Buildkite Agent Stack for Kubernetes from the Elastic CI Stack for AWS, you may be accustomed to enabling [Git mirrors](/docs/agent/self-hosted/configure/git-mirrors) by setting the `BuildkiteAgentEnableGitMirrors` CloudFormation parameter to `true`. In this setup, the agent automatically manages a shared directory for Git mirrors on each EC2 instance, typically `/var/lib/buildkite-agent/git-mirrors`, with little additional configuration required.

When moving to the Buildkite Agent Stack for Kubernetes, support for Git mirrors is equally powerful but requires explicit configuration to suit the dynamic and distributed nature of Kubernetes. Instead of a single EC2 instance, each build runs in its own pod, and persistent storage must be configured to ensure that Git mirrors are shared and retained between jobs.

### Configuring Git mirrors in Kubernetes

The Buildkite Agent Stack for Kubernetes supports flexible Git mirror configuration to optimize repository cloning and fetching for your builds.

To enable Git mirrors in Kubernetes, specify the mirror storage location and volume type. For persistent, cluster-wide storage, use PersistentVolumeClaim (PVC):

```yaml
# values.yaml
config:
  default-checkout-params:
    cloneFlags: -v --depth 1
    noSubmodules: true
    gitMirrors:
      volume:
        name: my-special-git-mirrors
        persistentVolumeClaim:
          claimName: your-pvc
```

This approach is recommended for production environments as it provides resilience and allows mirrors to persist and be shared across pods and nodes, depending on your storage class.

> 🚧
> Make sure the referenced PVC already exists in your Kubernetes cluster.

For simpler or development setups, use a `hostPath` volume to mount a directory from the Kubernetes node:

```yaml
# values.yaml
config:
  default-checkout-params:
    gitMirrors:
      volume:
        name: host-git-mirrors
        hostPath:
          path: /var/lib/buildkite/git-mirrors
          type: Directory
```

### Key differences

In Elastic CI Stack, mirrors are local to each EC2 instance and automatically managed, whereas in the Buildkite Agent Stack for Kubernetes, you must explicitly configure persistent storage for mirrors, and the type of storage you choose (hostPath or PVC) affects performance, availability, and scalability. Additionally, each build runs in a new pod, so a persistent storage is essential for effective mirroring in Kubernetes.

### Best practices and troubleshooting

For large repositories or monorepos, Git mirrors can significantly reduce checkout times and network usage. Ensure your storage backend is fast and reliable, and consider using SSD-backed persistent volumes for best performance. If you encounter issues such as lock contention or mirror corruption, review your `lockTimeout` settings and consult the troubleshooting advice in the [Git mirrors documentation](/docs/agent/self-hosted/configure/git-mirrors#common-issues-with-git-mirrors).

By configuring Git mirrors appropriately in the Buildkite Agent Stack for Kubernetes, you can maintain the same performance and reliability benefits you experienced in the Elastic CI Stack, while taking full advantage of Kubernetes’ scalability and flexibility.
