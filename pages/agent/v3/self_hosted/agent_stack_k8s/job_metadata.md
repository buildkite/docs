---
toc: false
---

# Default job metadata

The Buildkite Agent Stack for Kubernetes controller can automatically add labels and annotations to the Kubernetes Jobs it creates.

Default annotations and labels can be set in the controller's YAML configuration values file, through `default-metadata`. Such a configuration applies its defined annotations and labels to all Jobs created by the controller:

```yaml
# values.yaml
...
default-metadata:
  annotations:
    imageregistry: "https://hub.docker.com/"
    mycoolannotation: llamas
  labels:
    argocd.argoproj.io/tracking-id: example-id-here
    mycoollabel: alpacas
...
```

Alternatively, you can set the default labels for individual steps in a pipeline using the `metadata` configuration of the `kubernetes` plugin:

```yaml
# pipeline.yaml
...
  plugins:
    - kubernetes:
        metadata:
          annotations:
            imageregistry: "https://hub.docker.com/"
            myannotation: "ci-pipeline"
          labels:
            argocd.argoproj.io/tracking-id: "example-id-here"
            mylabel: "backend"
...
```
