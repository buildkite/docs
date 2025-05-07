# Kubernetes PodSpec

Using the `kubernetes` plugin allows specifying a [`PodSpec`](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodSpec) Kubernetes API resource that will be used in a Kubernetes [`Job`](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/job-v1/#Job).

## Kubernetes PodSpec Generation

The `agent-stack-k8s` controller allows defining some or all of the Kubernetes `PodSpec` from the following locations:

- Controller configuration: `pod-spec-patch`.
- Buildkite job, using the `kubernetes` plugin: `podSpec`, `podSpecPatch`.

With multiple `PodSpec` inputs provided, here is how the `agent-stack-k8s` controller generates a Kubernetes `PodSpec`:

- Create a simple `PodSpec` containing a single container with the `Image` defined in the controller's configuration and the value of the Buildkite job's command (`BUILDKITE_COMMAND`).
- If the `kubernetes` plugin is present in the Buildkite job's plugins and contains a `podSpec`, use this as the starting `PodSpec` instead.
- Apply the `/workspace` Volume.
- Apply any `extra-volume-mounts` defined by the `kubernetes` plugin.
- Modify any `containers` defined by the `kubernetes` plugin, overriding the `command` and `args`.
- Add the `agent` container to the `PodSpec`.
- Add the `checkout` container to the `PodSpec` (if `skip.checkout` is set to `false`).
- Add `init` containers for the `imagecheck-#` containers, based on the number of unique images defined in the `PodSpec`.
- Apply `pod-spec-patch` from the controller's configuration, using a [strategic merge patch](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/update-api-object-kubectl-patch/) in the controller.
- Apply `podSpecPatch` from the `kubernetes` plugin, using a [strategic merge patch](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/update-api-object-kubectl-patch/) in the controller.
- Ensure the a `checkout` container in not present after applying patching via `pod-spec-patch`, `podSpecPatch` (if `skip.checkout` is set to `true`).
- Remove any duplicate `VolumeMounts` present in `PodSpec` after patching.
- Create a Kubernetes Job with the final `PodSpec`.

## PodSpec command and interpretation of arguments

In a `podSpec`, `command` _must_ be a list of strings, since it is [defined by Kubernetes](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#entrypoint). However, the Buildkite Agent Stack for Kubernetes controller runs the Buildkite agent instead of the container's default entrypoint.

To run a command, it must _re-interpret_ `command` into input for the Buildkite agent. By default, it treats `command` as a sequence of multiple commands, similar to steps and commands in a pipeline.yaml which is different to the interpretation of `command` (as an entrypoint vector run without a shell as a single command) in Kubernetes.

This "interposer" behaviour can be changed using `commandParams/interposer`:

- `buildkite` is the default, in which agent-stack-k8s treats `command` as a sequence of multiple commands and `args` as extra arguments added to the end of the last command, which is then typically interpreted by the shell.
- `vector` emulates the Kubernetes' interpretation in which `command` and `args` specify components of a single command intended to be run directly.
- `legacy` is the 0.14.0 and earlier behaviour in which `command` and `args` were joined directly into a single command with spaces.

A Buildkite example:

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

If you have a multi-line `command`, specifying the `args` could lead to confusion, so we recommend just using `command`.

`vector` example:

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

Almost any container image may be used, but it _must_ have a POSIX shell available to be executed at `/bin/sh`.
You can specify a different image to use for a step in a step level `podSpecPatch`. Previously this could be done with a step level `podSpec`.

```yaml
# pipelines.yaml
agents:
  queue: kubernetes
steps:
- name: Hello World!
  commands:
  - echo -n Hello!
  - echo " World!"
  plugins:
  - kubernetes:
      podSpecPatch:
        containers:
        - name: container-0
          image: alpine:latest

- name: Hello World from alpine!
  commands:
  - echo -n Hello
  - echo " from alpine!"
  plugins:
  - kubernetes:
      podSpecPatch:
        containers:
        - name: container-0      # <---- Please specify this as exactly `container-0` for now.
          image: alpine:latest   #       We are experimenting with ways to make this more ergonomic
```
