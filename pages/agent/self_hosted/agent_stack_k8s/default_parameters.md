# Default parameters

This page describes how to add environment variables to the default parameters of the [checkout](#default-checkout-parameters), [command](#default-command-parameters), and [sidecar](#default-sidecar-parameters) containers in your Buildkite Agent Stack for Kubernetes controller setup using the `envFrom` feature.

## Default checkout parameters

You can add `envFrom` to all `checkout` containers in two ways:

- Per-step in your pipeline configuration, for example:

    ```yaml
    # pipeline.yml
    ...
    kubernetes:
      checkout:
        envFrom:
        - prefix: GITHUB_  # This prefix is added to all variable names
          secretRef:
            name: github-secrets # References a Secret named "github-secrets"
    ...
    ```

- Or globally for all jobs using a `values.yml` file, for example:

    ```yaml
    # values.yml
    config:
      default-checkout-params:
        envFrom:
        - prefix: GITHUB_   # This prefix is added to all variable names
          secretRef:
            name: github-secrets # References a Secret named "github-secrets"
    ...
    ```

## Default command parameters

You can add `envFrom` to all user-defined command containers in two ways:

- Per-step in your pipeline configuration, for example:

    ```yaml
    # pipeline.yml
    ...
    kubernetes:
      commandParams:
        envFrom:
        - prefix: DEPLOY_  # This prefix is added to all variable names
          secretRef:
            name: deploy-secrets # References a Secret named "deploy-secrets"
    ...
    ```

- Or alternatively, for all jobs using a `values.yml` file, for example:

    ```yaml
    # values.yml
    config:
      default-command-params:
        envFrom:
        - prefix: DEPLOY_  # This prefix is added to all variable names
          secretRef:
            name: deploy-secrets  # References a Secret named "deploy-secrets"
    ...
    ```

## Default sidecar parameters

You can add `envFrom` to all `sidecar` containers in two ways:

- Per-step in your pipeline configuration, for example:

    ```yaml
    # pipeline.yml
    ...
    kubernetes:
      sidecarParams:
        envFrom:
        - prefix: LOGGING_  # This prefix is added to all variable names
          configMapRef:
            name: logging-config  # References a ConfigMap named "logging-config"
    ...
    ```

- Or alternatively, for all jobs using a `values.yml` file, for example:

    ```yaml
    # values.yml
    config:
      default-sidecar-params:
        envFrom:
        - prefix: LOGGING_  # This prefix is added to all variable names
          configMapRef:
            name: logging-config  # References a ConfigMap named "logging-config"
    ...
    ```
