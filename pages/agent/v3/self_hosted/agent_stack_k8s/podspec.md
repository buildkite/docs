# Kubernetes PodSpec

Using the `kubernetes` plugin allows you to specify a [`PodSpec`](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodSpec) Kubernetes API resource that will be used in a Kubernetes [`Job`](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/job-v1/#Job).

## Kubernetes PodSpec generation

The Agent Stack for Kubernetes controller allows you to define some or all of the Kubernetes `PodSpec` from the following locations:

- Controller configuration: `pod-spec-patch`.
- Buildkite job, using the `kubernetes` plugin: `podSpec`, `podSpecPatch`.

With multiple `PodSpec` inputs provided, here is how the Agent Stack for Kubernetes controller generates a Kubernetes `PodSpec`:

1. Create a simple `PodSpec` containing a single container with the `Image` defined in the controller's configuration and the value of the Buildkite job's command (`BUILDKITE_COMMAND`).

    If the `kubernetes` plugin is present in the Buildkite job's plugins and contains a `podSpec`, use this as the starting `PodSpec` instead.

1. Apply the `/workspace` Volume.

1. Apply any `extra-volume-mounts` defined by the `kubernetes` plugin.

1. Modify any `containers` defined by the `kubernetes` plugin, overriding the `command` and `args`.

1. Add the `agent` container to the `PodSpec`.

1. Add the `checkout` container to the `PodSpec` (if `skip.checkout` is set to `false`).

1. Add `init` containers for the `imagecheck-#` containers, based on the number of unique images defined in the `PodSpec`.

1. Apply `pod-spec-patch` from the controller's configuration, using a [strategic merge patch](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/update-api-object-kubectl-patch/) in the controller.

1. Apply `podSpecPatch` from the `kubernetes` plugin, using a [strategic merge patch](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/update-api-object-kubectl-patch/) in the controller.

1. Ensure the a `checkout` container in not present after applying patching via `pod-spec-patch`, `podSpecPatch` (if `skip.checkout` is set to `true`).

1. Remove any duplicate `VolumeMounts` present in `PodSpec` after patching.

1. Create a Kubernetes Job with the final `PodSpec`.

## PodSpec command and interpretation of arguments

In a `podSpec`, `command` _must_ be a list of strings, since it is [defined by Kubernetes](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#entrypoint). However, the Buildkite Agent Stack for Kubernetes controller runs the Buildkite Agent instead of the container's default entrypoint.

To run a command, the controller must _re-interpret_ `command` into input for the Buildkite Agent. By default, the controller treats `command` as a sequence of multiple commands, similar to steps and commands in a `pipeline.yaml` file which is different to the interpretation of `command` (as an entrypoint vector run without a shell as a single command) in Kubernetes.

This _interposer_ behavior can be changed using `commandParams/interposer`, which can have one of the following values:

- `buildkite` is the default, in which the Agent Stack for Kubernetes controller treats `command` as a sequence of multiple commands, and `args` as extra arguments added to the end of the last command, which are then typically interpreted by the shell.
- `vector` emulates the Kubernetes' interpretation in which `command` and `args` specify components of a single command intended to be run directly.
- `legacy` is the behavior of the Agent Stack for Kubernetes controller version 0.14.0 and earlier, where `command` and `args` are joined directly into a single command with spaces.

An example using `buildkite` interposer behavior:

```yaml
steps:
- label: Hello World!
  agents:
    queue: kubernetes
  plugins:
  - kubernetes:
      commandParams:
        interposer: buildkite  # This is the default, and can be omitted
      podSpec:
        containers:
        - image: alpine:latest
          command:
          - set -euo pipefail
          - |-       # <-- YAML block scalars work too
            echo Hello World! > hello.txt
            cat hello.txt | buildkite-agent annotate
```

If you have a multi-line `command`, specifying the `args` could lead to confusion. Therefore, it is recommended to just use `command`.

An example using `vector` interposer behavior:

```yaml
steps:
- label: Hello World!
  agents:
    queue: kubernetes
  plugins:
  - kubernetes:
      commandParams:
        interposer: vector
      podSpec:
        containers:
        - image: alpine:latest
          command: ['sh']
          args:
          - '-c'
          - |-
            set -eu

            echo Hello World! > hello.txt
            cat hello.txt | buildkite-agent annotate
```

### Custom images

In version 0.30.0 and later of the Agent Stack for Kubernetes controller, you can use the [`image` attribute](/docs/pipelines/configure/step-types/command-step#container-image-attributes) in a command step to specify a container image for the step's job.
Almost any container image may be used, but the image _must_ have a POSIX shell available to be executed at `/bin/sh`.

```yaml
# pipeline.yaml
steps:
- name: Hello World!
  image: "alpine:latest" # <- New in v0.30.0
  commands:
  - echo -n Hello!
```

For versions of the controller prior to 0.30.0, you can specify a different image using `podSpecPatch`. See [Custom images](/docs/agent/v3/self-hosted/agent-stack-k8s/custom-images) for detailed information on container types, image requirements, and configuration options.

### Environment variables precedence

During its bootstrap phase, the Buildkite Agent receives some of its environment variables from the Buildkite platform. These environment variables are normally set using the `env` keyword in pipeline.yaml file.

During the generation of the Kubernetes `podSpec`, the `podSpec` receives some of its environment variables from the Agent Stack for Kubernetes controller itself, some controller-specific environment variables defined in the values.yaml file, as well as environment variables that can be set in various `podSpec` configuration steps of the pipeline.yaml file.

Be aware that currently, environment variables defined as part of a `podSpec` take higher precedence over environment variables set using the `env` keyword in the pipeline.yaml file.

If you have a need for a more flexible environment variable setup, use [Agent hooks](/docs/agent/v3/self-hosted/hooks) to implement a precedence rule suite to your organization.
