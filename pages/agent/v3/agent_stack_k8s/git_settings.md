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
