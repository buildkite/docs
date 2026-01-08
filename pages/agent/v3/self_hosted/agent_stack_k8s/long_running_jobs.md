# Long-running jobs

> 📘 Minimum version requirement
> To implement the configuration options described on this page, version 0.24.0 or later of the Agent Stack for Kubernetes controller is required.

The Agent Stack for Kubernetes controller supports the `activeDeadlineSeconds` field of the Kubernetes [JobSpec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/job-v1/#JobSpec), which can be achieved by setting the Job's active deadline (that is, the number of seconds specified in its `activeDeadlineSeconds` field). Learn more about this in Kubernetes' documentation on [Job termination and cleanup](https://kubernetes.io/docs/concepts/workloads/controllers/job/#job-termination-and-cleanup).

## Controller configuration for increasing maximum job duration (for all jobs)

By default, Kubernetes Jobs created by the Agent Stack for Kubernetes controller will run for a maximum duration of `21600` seconds (6 hours). After this duration has been exceeded, all of the running Pods are terminated and the Job status will be `type: Failed`. In the Buildkite interface, this will be reflected as `Exited with status -1 (agent lost)`. If long-running jobs are common in your Buildkite Organization, this value should be increased in your controller configuration values YAML file:

```yaml
# values.yaml
...
config:
  job-active-deadline-seconds: 86400 # 24h
...
```

## Kubernetes plugin configuration for increasing maximum job duration (on a per-job basis)

It is also possible to override this configuration using the `kubernetes` plugin directly in your pipeline steps, which will only apply to the Kubernetes Job running this `command` step:

```yaml
steps:
- label: Long-running job
  command: echo "Hello world" && sleep 43200
  plugins:
  - kubernetes:
      jobActiveDeadlineSeconds: 43500
```

Additional information on configuring `jobActiveDeadlineSeconds` can be found in the `--job-active-deadline-seconds` flag description of the [Flags](/docs/agent/v3/self-hosted/agent-stack-k8s/controller-configuration#flags) section, on the [Controller configuration](/docs/agent/v3/self-hosted/agent-stack-k8s/controller-configuration) page.
