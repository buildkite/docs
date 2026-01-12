# Using agent hooks and plugins

> 📘 Minimum version requirement
> To implement the configuration options described on this page, version 0.16.0 or later of the Agent Stack for Kubernetes controller is required. However, agent hooks are supported in [earlier versions of the controller](#agent-hooks-in-earlier-versions).

## Agent hooks

The `agent-config` block within the controller's configuration file (`values.yaml`) accepts a value for [`hooks-path`](/docs/agent/v3/self-hosted/configure#hooks-path) as part of the `hooksVolume` configuration. If configured, a corresponding volume named `buildkite-hooks` will be automatically mounted on `checkout` and command containers, with the Buildkite Agent configured to use them.

You can specify any volume source for agent hooks, but a common choice is to use a [ConfigMap](https://kubernetes.io/docs/concepts/configuration/configmap/), since hooks generally aren't large and ConfigMaps are made available across the cluster.

To create a ConfigMap containing agent hooks:

```shell
kubectl create configmap buildkite-agent-hooks --from-file=/tmp/hooks -n buildkite
```

All the hooks needed are under the `/tmp/hooks` directory and a ConfigMap created with the name `buildkite-agent-hooks` in the `buildkite` namespace of the Kubernetes cluster.

Example of using hooks from a ConfigMap:

```yaml
config:
  agent-config:
    hooks-path: /buildkite/hooks
    hooksVolume:
      name: buildkite-hooks
      configMap:
        defaultMode: 493
        name: buildkite-agent-hooks
```
{: codeblock-file="values.yaml"}

### Permissions and availability

The `defaultMode` value of `493` sets the Unix permissions to `755`, which enables the hooks to be executable.

### Hooks mount point

The `hooks-path` Buildkite agent config option can be used to change the mount point of the corresponding `buildkite-hooks` volume. This will also set `BUILDKITE_HOOKS_PATH` to the defined path on `checkout` and command containers. The default mount point is `/buildkite/hooks`.

## Agent hooks in earlier versions

If you are running the Buildkite Agent Stack Kubernetes controller 0.15.0 or earlier, your agent hooks must be present on the instances where the Buildkite Agent runs.

These hooks need to be accessible to the Kubernetes pod where the `checkout` and command containers will be running. The recommended approach is to create a ConfigMap with the agent hooks and mount the ConfigMap as a volume to the containers.

To create a ConfigMap containing agent hooks:

```shell
kubectl create configmap buildkite-agent-hooks --from-file=/tmp/hooks -n buildkite
```

All the hooks needed are under the `/tmp/hooks` directory and a ConfigMap created with the name `buildkite-agent-hooks` in the `buildkite` namespace of the Kubernetes cluster.

In order for the agent to use these hooks, a volume containing the ConfigMap is defined and then mounted to all containers using `extraVolumeMounts` at `/buildkite/hooks`, using the `kubernetes` plugin:

```yaml
steps:
- label: "\:pipeline\: Pipeline Upload"
  agents:
    queue: kubernetes
  plugins:
  - kubernetes:
      extraVolumeMounts:
        - mountPath: /buildkite/hooks
          name: agent-hooks
      podSpec:
        containers:
        - command:
          - echo hello-world
          image: alpine:latest
          env:
          - name: BUILDKITE_HOOKS_PATH
            value: /buildkite/hooks
        volumes:
          - configMap:
              defaultMode: 493
              name: buildkite-agent-hooks
            name: agent-hooks
```
{: codeblock-file="pipeline.yml"}

> 📘 Permissions and availability
> The `defaultMode` value of `493` sets the Unix permissions to `755`, which enables the hooks to be executable.

## Agent hook execution differences

With jobs created by the Buildkite Agent Stack for Kubernetes controller, there are key differences with hook execution. The primary difference is with the `checkout` container and user-defined `command` containers.

- The `environment` hook is executed multiple times, once within the `checkout` container, and once within each of the user-defined `command` containers.
- Checkout-related hooks (`pre-checkout`, `checkout`, `post-checkout`) are only executed within the `checkout` container.
- Command-related hooks (`pre-command`, `command`, `post-command`) are only executed within the `command` container(s).

> 📘 Exporting environment variables
> Since hooks are executed from within separate containers for checkout and command phases of the job's lifecycle, any environment variables exported during the execution of hooks with the `checkout` container will _not_ be available to the command container(s). This is operationally different from how hooks are [sourced](/docs/agent/v3/hooks#hook-scopes) outside of the Buildkite Agent Stack for Kubernetes.

If the env `BUILDKITE_HOOKS_PATH` is set at pipeline level instead of at the container level, as shown in the earlier pipeline configuration examples, then the hooks will run for both `checkout` container and `command` container(s).

Here is the pipeline config where env `BUILDKITE_HOOKS_PATH` is exposed to all containers in the pipeline:

```yaml
steps:
- label: "\:pipeline\: Pipeline Upload"
  env:
    BUILDKITE_HOOKS_PATH: /buildkite/hooks
  agents:
    queue: kubernetes
  plugins:
  - kubernetes:
      extraVolumeMounts:
        - mountPath: /buildkite/hooks
          name: agent-hooks
      podSpec:
        containers:
        - command:
          - echo
          - hello-world
          image: alpine:latest
        volumes:
          - configMap:
              defaultMode: 493
              name: buildkite-agent-hooks
            name: agent-hooks
```
{: codeblock-file="pipeline.yml"}

This happens because agent hooks will be present in both containers and `environment` hook will also run in both containers. Here is what the resulting build output will look like:

```
Running global environment hook     # <-- checkout container
Running global pre-checkout hook    # <-- checkout container
Preparing working directory         # <-- checkout container
Running global post-checkout hook   # <-- checkout container
Running global environment hook     # <-- user-defined container
Running commands                    # <-- user-defined container
Running global pre-exit hook        # <-- user-defined container
```

In the scenarios where you would want to `skip checkout` when running on Buildkite Agent Stack for Kubernetes controller, the outlined configuration will cause checkout-related hooks (`pre-checkout`, `checkout` and `post-checkout`) to _not_ execute because the `checkout` container will not be present when `skip: true` is configured for `checkout`.

Here is a pipeline example where `checkout` is skipped:

```yaml
steps:
- label: "\:pipeline\: Pipeline Upload"
  env:
    BUILDKITE_HOOKS_PATH: /buildkite/hooks
  agents:
    queue: kubernetes
  plugins:
  - kubernetes:
      checkout:
        skip: true
      extraVolumeMounts:
        - mountPath: /buildkite/hooks
          name: agent-hooks
      podSpec:
        containers:
        - command:
          - echo
          - hello-world
          image: alpine:latest
        volumes:
          - configMap:
              defaultMode: 493
              name: buildkite-agent-hooks
            name: agent-hooks
```
{: codeblock-file="pipeline.yml"}

Looking at the resulting build logs below, you'll see that it only has `environment` and `pre-exit` hooks that ran for the user-defined `command` container and no checkout-related hooks. The is due to the `checkout.skip: true` value being applied, resulting in the `checkout` container not being created and checkout-related hooks no executing.

```
Running global environment hook     # <-- user-defined container
Running commands                    # <-- user-defined container
Running global pre-exit hook        # <-- user-defined container
```

## Plugins

The `agent-config` block within the controller's configuration file (`values.yaml`) accepts a value for [`plugins-path`](/docs/agent/v3/self-hosted/configure#plugins-path) using the `pluginsVolume` configuration. If configured, a corresponding volume named `buildkite-plugins` will be automatically mounted on `checkout` and command containers, with the Buildkite Agent configured to use them.

Example of using plugins from a [HostPath](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath)):

```yaml
config:
agent-config:
  pluginsVolume:
    name: buildkite-plugins
    plugins-path: /buildkite/plugins
  hostPath:
    type: Directory
    path: /etc/buildkite-agent/plugins
```
{: codeblock-file="values.yaml"}

> 📘 Plugins mount point
> The `plugins-path` Buildkite agent config option can be used to change the mount point of the corresponding volume. This will also set `BUILDKITE_PLUGINS_PATH` to the defined path on `checkout` and command containers. The default mount point is `/buildkite/plugins`.
