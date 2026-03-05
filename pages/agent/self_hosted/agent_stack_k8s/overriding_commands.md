# Overriding commands

You can alter the `command` or `args` for `command` containers using PodSpecPatch. These will be re-wrapped in the necessary `buildkite-agent` invocation.

However, PodSpecPatch will not modify the `command` or `args` values for containers with the following names or patterns (provided by the Agent Stack for Kubernetes controller):

- `copy-agent`
- `imagecheck-*`
- `agent`
- `checkout`

Instead, if an attempt is made to modify the `command` or `args` values for these containers, an error is returned.

If modifying the commands of these containers is something you want to do, consider other potential solutions:

- To override checkout behaviour, consider writing a `checkout` hook, or disabling the checkout container entirely with `checkout: skip: true`.
- To run additional containers without `buildkite-agent` in them, consider using a [sidecar](/docs/agent/self-hosted/agent-stack-k8s/sidecars).

> 📘
> Buildkite is continually looking into adding ways to make the Buildkite Agent Stack for Kubernetes more flexible while ensuring core functionality is maintained.

## Important considerations and precautions

Avoid using PodSpecPatch to override `command` or `args` of the containers added by the Agent Stack for Kubernetes controller. Such modifications, if not done with extreme care and detailed knowledge about how the controller constructs PodSpecs, are very likely to break the agent's functionality within the pod.

If the replacement command for the checkout container does not invoke `buildkite-agent bootstrap`:

- The container will not connect to the `agent` container, and the agent will not finish the job normally because there was not an expected number of other containers connecting to it.
- The logs from the container will not be visible in Buildkite Pipelines.
- The hooks will not be executed automatically.
- The plugins will not be checked out or executed automatically and various other functions provided by `buildkite-agent` may not work.

If the command for the `agent` container is overridden, and the replacement command does not invoke `buildkite-agent start`, then the job will not be acquired at all on Buildkite Pipelines.

If you still wish to disable this precaution, and override the raw `command` or `args` of these controller-provided containers using PodSpecPatch, you may do so with the `allow-pod-spec-patch-unsafe-command-modification` config option.
