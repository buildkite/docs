# Long-running jobs

> 📘 Version requirement
> To be able to implement the configuration options described below, `v0.24.0` or newer of the controller is required.

The `agent-stack-k8s` controller supports the `activeDeadlineSeconds` field of the JobSpec. According to the Kubernetes [documentation](https://kubernetes.io/docs/concepts/workloads/controllers/job/#job-termination-and-cleanup):

> Another way to terminate a Job is by setting an active deadline. Do this by setting the `.spec.activeDeadlineSeconds` field of the Job to a number of seconds. The `activeDeadlineSeconds` applies to the duration of the job, no matter how many Pods are created. Once a Job reaches `activeDeadlineSeconds`, all of its running Pods are terminated and the Job status will become `type: Failed` with `reason: DeadlineExceeded`.

## Controller configuration for increasing maximum job duration (for all jobs)

By default, Kubernetes Jobs created by the `agent-stack-k8s` controller will run for a maximum duration of `21600` seconds (6 hours). After this duration has been exceeded, all of the running Pods are terminated and the Job status will be `type: Failed`. In the Buildkite UI, this will be reflected as `Exited with status -1 (agent lost)`. If long-running jobs are common in your Buildkite Organization, this value should be increased in your controller configuration values YAML file:

```yaml
# values.yaml
...
config:
  job-active-deadline-seconds: 86400 # 24h
...
```

## Kubernetes plugin configuration for increasing maximum job duration (on a per-job basis)

It is also possible to override this configuration via the `kubernetes` plugin directly in your pipeline steps, which will only apply to the Kubernetes Job running this `command` step:

```yaml
steps:
- label: Long-running job
  command: echo "Hello world" && sleep 43200
  plugins:
  - kubernetes:
      jobActiveDeadlineSeconds: 43500
```

Additional information on configuring `jobActiveDeadlineSeconds` can be found in the [controller configuration documentation](/docs/agent/v3/agent-stack-k8s/controller-configuration) in the section that covers the `--job-active-deadline-seconds` flag.
