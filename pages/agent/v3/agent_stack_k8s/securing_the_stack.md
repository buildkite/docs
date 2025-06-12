# Securing the Agent Stack for Kubernetes

> 📘 Minimum version requirement
> To implement the configuration options described on this page, version 0.13.0 or later of the Agent Stack for Kubernetes controller is required.

To secure Buildkite Pipelines jobs on the Agent Stack for Kubernetes controller, the `prohibit-kubernetes-plugin` configuration option can be used to prevent users from overriding a controller-defined `pod-spec-patch`. With the `prohibit-kubernetes-plugin` configuration enabled, any Pipelines job including the `kubernetes` plugin will fail.

## Using inline configuration

Add the `--prohibit-kubernetes-plugin` argument to your Helm deployment:

```bash
helm upgrade --install agent-stack-k8s oci://ghcr.io/buildkite/helm/agent-stack-k8s \
    --namespace buildkite \
    --create-namespace \
    --set agentToken=<buildkite-cluster-agent-token> \
    --set-json='config.tags=["queue=kubernetes"]' \
    --prohibit-kubernetes-plugin
```

## Using a YAML configuration file

You can also enable the `prohibit-kubernetes-plugin` option in your configuration values YAML file:

```yaml
# values.yaml
...
config:
  prohibit-kubernetes-plugin: true
  pod-spec-patch:
    # Override the default podSpec here.
  ...
```
