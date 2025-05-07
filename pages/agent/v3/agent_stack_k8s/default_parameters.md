# Default parameters for the Buildkite Agent Stack for Kubernetes

This document outlines the default checkout, command, and sidecar parameters for configuring and using the Buildkite Agent Stack for Kubernetes.

## Default checkout parameters

You can add `envFrom` to all `checkout` containers separately, either per-step in the pipeline or for all jobs in `values.yaml`:

```yaml
# pipeline.yml
...
  kubernetes:
    checkout:
      envFrom:
      - prefix: GITHUB_
        secretRef:
          name: github-secrets
...
```

`values.yaml` example:

```yaml
# values.yml
config:
  default-checkout-params:
    envFrom:
    - prefix: GITHUB_
      secretRef:
        name: github-secrets
...
```

## Default command parameters

You can add `envFrom` to all user-defined command containers separately, either per-step in the pipeline or for all jobs in `values.yaml`:

```yaml
# pipeline.yml
...
  kubernetes:
    commandParams:
      interposer: vector
      envFrom:
      - prefix: DEPLOY_
        secretRef:
          name: deploy-secrets
...
```

`values.yaml` example:

```yaml
# values.yml
config:
  default-command-params:
    interposer: vector
    envFrom:
    - prefix: DEPLOY_
      secretRef:
        name: deploy-secrets
...
```

## Default sidecar parameters

You can add `envFrom` all `sidecar` containers separately, either per-step in the pipeline or for all jobs in `values.yaml`:

```yaml
# pipeline.yml
...
  kubernetes:
    sidecarParams:
      envFrom:
      - prefix: LOGGING_
        configMapRef:
          name: logging-config
...
```

`values.yaml` example:

```yaml
# values.yml
config:
  default-sidecar-params:
    envFrom:
    - prefix: LOGGING_
      configMapRef:
        name: logging-config
...
```
