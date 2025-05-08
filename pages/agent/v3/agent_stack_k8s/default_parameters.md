# Default parameters

This page describes the default [checkout](#default-checkout-parameters), [command](#default-command-parameters), and [sidecar](#default-sidecar-parameters) parameters for the Buildkite Agent Stack for Kubernetes.

## Default checkout parameters

You can add `envFrom` to all `checkout` containers separately, either:

- Per-step in the pipeline, for example:

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

- Or alternatively, for all jobs using a `values.yml` file, for example:

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

You can add `envFrom` to all user-defined command containers separately, either:

- Per-step in the pipeline, for example:

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

- Or alternatively, for all jobs using a `values.yml` file, for example:

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

You can add `envFrom` to all `sidecar` containers separately, either:

- Per-step in the pipeline, for example:

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

- Or alternatively, for all jobs using a `values.yml` file, for example:

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
