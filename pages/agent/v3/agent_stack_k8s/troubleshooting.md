# Troubleshooting

If you're experiencing any issues with the `agent-stack-k8s` controller, we recommend enabling the debug mode and enable log collection to get a better visibility into potential issues.

## Enable debug mode

Debug mode can be enabled during the Helm deployment of the `agent-stack-k8s` controller via the command line:

```bash
helm upgrade --install agent-stack-k8s oci://ghcr.io/buildkite/helm/agent-stack-k8s \
    --namespace buildkite \
    --create-namespace \
    --debug \
    --values values.yml
```

Or within the controller's configuration values YAML file:

```yaml
# values.yaml
...
config:
  debug: true
...
```

## Kubernetes log collection

To enable log collection for the `agent-stack-k8s` controller, use the [`utils/log-collector`](https://github.com/buildkite/agent-stack-k8s/blob/main/utils/log-collector) script in the controller repository.

### Prerequisites

- kubectl binary
- kubectl setup and authenticated to correct k8s cluster

### Inputs to the script

When executing the `log-collector` script, you will be prompted for:
- Kubernetes Namespace where the `agent-stack-k8s` controller is deployed
- Buildkite job ID to collect Job and Pod logs

### Gathering of data and logs

The `log-collector` script will gather the following information:
- Kubernetes Job, Pod resource details for `agent-stack-k8s` controller
- Kubernetes Pod logs for `agent-stack-k8s` controller
- Kubernetes Job, Pod resource details for Buildkite job ID (if provided)
- Kubernetes Pod logs that executed Buildkite job ID (if provided)

The logs will be archived in a tarball named `logs.tar.gz` in the current directory. If requested, these logs may be provided via email to the Buildkite Support (`support@buildkite.com`).
