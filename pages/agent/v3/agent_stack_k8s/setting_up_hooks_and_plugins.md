# How to set up agent hooks and plugins

> 📘 Minimum version requirement
> To implement the configuration options described on this page, version 0.16.0 or later of the Agent Stack for Kubernetes controller is required. However, agent hooks are supported in [earlier versions of the controller](#setting-up-agent-hooks-in-earlier-versions).

The `agent-config` block within `values.yaml` accepts a `hookVolume` and `pluginVolume`. If used, the corresponding volumes named `buildkite-hooks` and `buildkite-plugins` will be automatically mounted on checkout and command containers, with the Buildkite Agent configured to use them.

You can specify any volume source for the agent hooks and plugins, but a common choice is to use a `configMap`, since hooks generally aren't large and config maps are made available across the cluster.

To create the config map containing hooks:

```shell
kubectl create configmap buildkite-agent-hooks --from-file=/tmp/hooks -n buildkite
```

- Example of using hooks from a config map:

    ```yaml
    # values.yaml
    config:
    agent-config:
        hooksVolume:
        name: buildkite-hooks
        configMap:
            defaultMode: 493
            name: buildkite-agent-hooks
    ```

- Example of using plugins from a host path ([_caveat lector_](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath)):

    ```yaml
    # values.yaml
    config:
    agent-config:
        pluginsVolume:
        name: buildkite-plugins
        hostPath:
            type: Directory
            path: /etc/buildkite-agent/plugins
    ```

> 📘
> The `hooks-path` and `plugins-path` Buildkite agent config options can be used to change the mount point of the corresponding volume. The default mount points are `/buildkite/hooks` and `/buildkite/plugins`.

## Setting up agent hooks in earlier versions

If you are running the Buildkite Agent Stack Kubernetes controller 0.15.0 or earlier, your agent hooks must be present on the instances where the Buildkite Agent runs.

These hooks need to be accessible to the Kubernetes pod where the `checkout` and `command` containers will be running. The recommended approach is to create a configmap with the agent hooks and mount the configmap as volume to the containers.

Here is the command to create `configmap` which will have agent hooks in it:

```shell
kubectl create configmap buildkite-agent-hooks --from-file=/tmp/hooks -n buildkite
```

All the hooks will need to be under the `/tmp/hooks` directory and `configmap` created with the name `buildkite-agent-hooks` in the `buildkite` namespace of the Kubernetes cluster.

Here is how to make these hooks in configmap available to the containers with the help of the pipeline config for setting up agent hooks:

```yaml
# pipeline.yml
steps:
- label: ':pipeline: Pipeline Upload'
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

There are 3 main aspects necessary for making sure that hooks are available to the containers in the Agent Stack for Kubernetes.

- Define the env variable `BUILDKITE_HOOKS_PATH` with the path `agent` and `checkout` containers will look for hooks:

    ```yaml
        env:
        - name: BUILDKITE_HOOKS_PATH
            value: /buildkite/hooks
    ```

- Define the `VolumeMounts` using `extraVolumeMounts` which will be the path where the hooks will be mounted to within the containers:

    ```yaml
        extraVolumeMounts:
        - mountPath: /buildkite/hooks
        name: agent-hooks
    ```

- Define `volumes` where the configmap will be mounted:

    ```yaml
        volumes:
        - configMap:
            defaultMode: 493
            name: buildkite-agent-hooks
            name: agent-hooks
    ```

<!-- vale off -->

> 📘 Permissions and availability
> In the examples above, the `defaultMode` value of `493` sets the Unix permissions to `755`, which enables the hooks to be executable. Another way to make this hooks directory available to containers is to use [hostPath](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath) mount, but this is not a recommended approach for production environments.

<!-- vale on -->

When the pipeline from the example is run, agent hooks will be available to the container and will run them.

With jobs created by the Buildkite Agent Stack for Kubernetes controller, there are key differences with hook execution. The primary difference is with the `checkout` container and user-defined `command` containers.

- The `checkout` container runs checkout-related hooks, such as `pre-checkout`, `checkout` and `post-checkout`.
- Similarly, the command-related hooks, such as `pre-command`, `command` and `post-command` are executed by the `command` container(s).
- The `environment` hook is executed multiple times, once within the `checkout` container, and once within each of the user-defined `command` containers.

If the env `BUILDKITE_HOOKS_PATH` is set at pipeline level instead of at the container level, as shown in the earlier pipeline configuration examples, then the hooks will run for both `checkout` container and `command` container(s).

Here is the pipeline config where env `BUILDKITE_HOOKS_PATH` is exposed to all containers in the pipeline:

```yaml
# pipeline.yml
steps:
- label: ':pipeline: Pipeline Upload'
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

In the scenarios where you would want to `skip checkout` when running on Buildkite Agent Stack for Kubernetes controller, the outlined configuration will cause checkout-related hooks such as pre-checkout, checkout, and post-checkout _not_ to run because `checkout` container will not be present when `skip checkout` is set.

Here is the pipeline config where checkout is skipped:

```yaml
# pipeline.yml
steps:
- label: ':pipeline: Pipeline Upload'
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

Looking at the resulting build logs below, you'll see that it only has `environment` and `pre-exit` hooks that ran for the user-defined `command` container and no checkout-related hooks. The is due to the `checkout.skip: true` value being applied, resulting in the `checkout` container not being created and checkout-related hooks no executing.

```
Running global environment hook     # <-- user-defined container
Running commands                    # <-- user-defined container
Running global pre-exit hook        # <-- user-defined container
```
