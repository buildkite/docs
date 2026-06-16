# Troubleshooting

If you're experiencing any issues with Buildkite Agent Stack for Kubernetes controller, it is recommended that you enable the debug mode and log collection to obtain better visibility and insight into such issues or any other related problems.

## Enable debug mode

Increasing the verbosity of Buildkite Agent Stack for Kubernetes controller's logs can be accomplished by enabling debug mode. Once enabled, the logs will emit individual, detailed actions performed by the controller while obtaining jobs from Buildkite's API, processing configurations to generate a Kubernetes PodSpec and creating a new Kubernetes Job. Debug mode can help to identify processing delays or incorrect job processing issues.

Debug mode can be enabled during the [installation](/docs/agent/self-hosted/agent-stack-k8s/installation) (Helm chart deployment) of the Buildkite Agent Stack for Kubernetes controller using the command line:

```bash
helm upgrade --install agent-stack-k8s oci://ghcr.io/buildkite/helm/agent-stack-k8s \
    --namespace buildkite \
    --create-namespace \
    --set config.debug=true \
    --values values.yml
```

Or within the controller's configuration values YAML file:

```yaml
# values.yaml
...
config:
  debug: true
...
```

To verify that debug logging is active, tail the controller's logs and look for entries with a `DEBUG` level:

```bash
kubectl logs -n buildkite deployment/agent-stack-k8s -f
```

> 📘 Namespace
> The previous command assumes the controller is deployed to the `buildkite` namespace. Replace `buildkite` with the namespace you used during [installation](/docs/agent/self-hosted/agent-stack-k8s/installation) if it differs.

## Kubernetes log collection

To enable log collection for the Buildkite Agent Stack for Kubernetes controller, use the [`utils/log-collector`](https://github.com/buildkite/agent-stack-k8s/blob/main/utils/log-collector) script in the controller repository.

### Prerequisites

- kubectl binary
- kubectl setup and authenticated to correct k8s cluster

### Inputs to the script

When executing the `log-collector` script, you will be prompted for:

- Kubernetes Namespace where the Buildkite Agent Stack for Kubernetes controller is deployed.

- Buildkite job ID to collect Job and Pod logs.

### Gathering of data and logs

The `log-collector` script will gather the following information:

- Kubernetes Job, Pod resource details for the Buildkite Agent Stack for Kubernetes controller.

- Kubernetes Pod logs for the Buildkite Agent Stack for Kubernetes controller.

- Kubernetes Job, Pod resource details for the Buildkite job ID (if provided).

- Kubernetes Pod logs that executed the Buildkite job ID (if provided).

The logs will be archived in a tarball named `logs.tar.gz` in the current directory. If requested, these logs may be provided by email to the Buildkite Support (`support@buildkite.com`).

## Common issues and fixes

Below are some common issues that users may experience when using the Buildkite Agent Stack for Kubernetes controller to process Buildkite jobs.

When Buildkite jobs are queued but not running, work through these checks in order:

1. Confirm the controller pod itself is running
1. Confirm the controller is creating Kubernetes Jobs for your Buildkite jobs
1. Investigate routing and concurrency configuration

### Controller pod is not running

If Buildkite jobs are not being acquired at all, first confirm that the controller pod itself is healthy in the Kubernetes cluster:

```bash
kubectl get deployment agent-stack-k8s -n buildkite
kubectl get pods -n buildkite
```

A healthy deployment shows `1/1` ready replicas and a pod in the `Running` state. If the pod is in any other state, inspect the pod events:

```bash
kubectl describe pod -l app=agent-stack-k8s -n buildkite
```

The following table lists the most common non-`Running` pod statuses and their typical causes.

Status                       | Meaning                                              | Typical cause
---------------------------- | ---------------------------------------------------- | -------------
`Pending`                    | Pod has not been scheduled to a node yet.            | Insufficient CPU or memory, scheduling constraints (taints, tolerations, affinity), or image pull delays.
`ContainerCreating`          | Pod is scheduled but containers are still starting.  | Volume mount, image pull, or network setup is still in progress or failing.
`CrashLoopBackOff`           | Container repeatedly crashes and is restarted.       | Application error, invalid configuration, or missing secret.
`ImagePullBackOff`           | Kubernetes cannot pull the container image.          | Incorrect image name or registry authentication failure.
`ErrImagePull`               | Initial image pull failed.                           | Invalid image tag or registry unavailable.
`CreateContainerConfigError` | Container configuration is invalid.                  | Missing ConfigMap, Secret, or environment variable.
`CreateContainerError`       | Container failed to start.                           | Invalid command, mount failure, or permissions issue.
`RunContainerError`          | Runtime failed to launch the container.              | Container runtime issue on the node.
`OOMKilled`                  | Container exceeded its memory limit.                 | Memory limit set too low for the workload.
`Terminating`                | Pod is being deleted.                                | Scale-down, rollout, or a stuck finalizer.
{: class="responsive-table"}

If the cluster runs on Google Kubernetes Engine, you can also review historical pod events in Google Cloud Logging using the following query:

```
resource.type="k8s_pod"
resource.labels.cluster_name="CLUSTER_NAME"
resource.labels.location="ZONE_NAME"
resource.labels.pod_name="POD_NAME"
```

#### Pod stuck in `Pending`

A `Pending` pod usually indicates either insufficient cluster capacity or a scheduling constraint such as a node taint. The pod events from `kubectl describe pod` will identify which.

For an insufficient capacity issue, the event reads similar to the following:

```
0/5 nodes are available: Insufficient cpu.
0/5 nodes are available: Insufficient memory.
```

To confirm node-level resource usage, check the allocated resources reported by each node:

```bash
kubectl describe nodes | grep -A6 -E "^Name:|^Allocated resources:"
```

Example output:

```
Name:               gke-example-cluster-default-pool-00000000-xxxx
Roles:              <none>
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/instance-type=e2-medium
                    beta.kubernetes.io/os=linux
                    cloud.google.com/gke-boot-disk=pd-balanced
                    cloud.google.com/gke-container-runtime=containerd
--
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource                       Requests              Limits
  --------                       --------              ------
  cpu                            762m (81%)            5 (531%)
  memory                         964261120 (32%)       7323138560 (249%)
  ephemeral-storage              0 (0%)                0 (0%)
```

To resolve insufficient capacity, either reduce the workload on existing nodes or add nodes to the cluster, manually or through autoscaling.

For a taints or tolerations issue, the event reads similar to the following:

```
node(s) had taint {key=value:NoSchedule}
```

List the taints on each node with the following command:

```bash
kubectl get nodes -o custom-columns=NODE:.metadata.name,TAINTS:.spec.taints
```

The Buildkite Agent Stack for Kubernetes controller does not define any tolerations by default, so nodes carrying taints will not accept the controller pod. Either remove the offending taints, or add nodes without taints for the controller to run on.

> 📘 Outside Buildkite control
> Cluster-level scheduling constraints such as capacity, taints, tolerations, and affinity rules are managed in your Kubernetes cluster, not by Buildkite. Resolving them requires changes to your cluster configuration.

#### Pod stuck in `ContainerCreating`

When the controller pod is stuck in `ContainerCreating`, inspect the pod events:

```bash
kubectl describe pod -l app=agent-stack-k8s -n buildkite
```

Common causes are missing volumes, secrets, or ConfigMaps, which appear as events such as the following:

```
FailedMount  MountVolume.SetUp failed  Unable to attach or mount volumes
MountVolume.SetUp failed  secret not found
MountVolume.SetUp failed  configmap not found
```

Confirm that the volume, secret, and ConfigMap objects referenced by the pod exist in the same Kubernetes namespace.

For other pod statuses listed in the table, the pod events reported by `kubectl describe pod` identify the underlying cause.

### Controller is healthy but not creating Kubernetes Jobs for Buildkite jobs

If the controller pod is `Running` but Buildkite jobs are still not being processed, the next step is to confirm whether the controller has created a Kubernetes Job and Pod for a specific Buildkite job. Each resource created by the controller is labeled with `buildkite.com/job-id`.

For a Buildkite job with the ID `01234567-****-****-****-456789abcdef`, check for the corresponding Kubernetes resources:

```bash
kubectl get jobs -A -l buildkite.com/job-id=01234567-****-****-****-456789abcdef -n buildkite
kubectl get pods -A -l buildkite.com/job-id=01234567-****-****-****-456789abcdef -n buildkite
```

Interpret the result of these commands:

- **If a Kubernetes Job or Pod exists for the Buildkite job ID**, the controller is acquiring and converting jobs successfully, and the issue is with the Job or Pod itself. Inspect that Pod's status and events using the same approach described in [Controller pod is not running](/docs/agent/self-hosted/agent-stack-k8s/troubleshooting#common-issues-and-fixes-controller-pod-is-not-running).

- **If no Kubernetes Job or Pod exists for the Buildkite job ID**, the controller is not converting the job. Enable [debug mode](/docs/agent/self-hosted/agent-stack-k8s/troubleshooting#enable-debug-mode) and review the controller logs to determine why. The two most common causes are a queue or cluster mismatch (see [Jobs are being created, but not processed by controller](/docs/agent/self-hosted/agent-stack-k8s/troubleshooting#common-issues-and-fixes-jobs-are-being-created-but-not-processed-by-controller)) and the controller having reached its concurrency limit (see [Controller stops accepting new jobs from a queue](/docs/agent/self-hosted/agent-stack-k8s/troubleshooting#common-issues-and-fixes-controller-stops-accepting-new-jobs-from-a-queue)).

### Jobs are being created, but not processed by controller

The primary requirement to have the Buildkite Agent Stack for Kubernetes controller acquire and process a Buildkite job is a matching `queue` tag. If the controller is configured to process scheduled jobs with tag `"queue=kubernetes"` you will need to ensure that your pipeline YAML is [targeting the same queue](https://buildkite.com/docs/agent/queues#targeting-a-queue-from-a-pipeline) at either the pipeline-level or at each step-level.

If a job is created without a queue target, the [default queue](https://buildkite.com/docs/agent/queues#assigning-a-self-hosted-agent-to-a-queue-the-default-self-hosted-queue) will be applied. The Buildkite Agent Stack for Kubernetes controller expects all jobs to have a `queue` tag explicitly defined, even for "default" cluster queues. Any job missing a `queue` tag will be skipped by the controller during processing and the controller emit the following log:

```
job missing 'queue' tag, skipping...
```

To view the agent tags applied to your job(s), the following GraphQL query can be executed (be sure to substitute your Organization's slug and Cluster ID):

```graphql
query getClusterScheduledJobs {
  organization(slug: "<organization-slug>") {
    jobs(
      state: [SCHEDULED]
      type: [COMMAND]
      order: RECENTLY_CREATED
      first: 100
      clustered: true
      cluster: "<cluster-id>"
    ) {
      count
      edges {
        node {
          ... on JobTypeCommand {
            url
            uuid
            agentQueryRules
          }
        }
      }
    }
  }
}
```

This will return the `100` newest created jobs for the `<cluster-id>` Cluster in the `<organization-slug>` Organization that are in a `scheduled` state and waiting for the controller to convert them each to a Kubernetes Job. Each Buildkite job's agent tags will be defined under `agentQueryRules`.

### Controller stops accepting new jobs from a queue

Sometimes the count of jobs in `waiting` state in the Buildkite Pipelines UI may increase, however, no new pods are created. This happens when the controller reaches its `max-in-flight` limit (the maximum number of jobs it runs concurrently, which defaults to `25`) and pauses processing further jobs until in-flight jobs complete. Reviewing the logs may reveal a `max-in-flight reached` error, for example:

```
DEBUG	limiter	scheduler/limiter.go:77	max-in-flight reached	{"in-flight": 25}
```

#### Confirm the cause

First, enable [debug mode](#enable-debug-mode) and look for the `max-in-flight reached` message. You can tail the controller logs with:

```bash
kubectl logs -n buildkite deployment/agent-stack-k8s -f
```

If your cluster runs on Google Kubernetes Engine, you can also search historical logs in Google Cloud Logging:

```
resource.type="k8s_container"
resource.labels.project_id="GCP_PROJECT_ID"
resource.labels.location="ZONE"
resource.labels.cluster_name="CLUSTER_NAME"
resource.labels.namespace_name="NAMESPACE_NAME"
labels.k8s-pod/app="agent-stack-k8s"
```

Then confirm that no new Kubernetes Jobs are created while the Buildkite Pipelines UI displays the jobs as `waiting`.

#### Increase the max-in-flight limit

If the controller consistently reaches its limit and your cluster has spare capacity, increase the `max-in-flight` value in the controller's configuration values YAML file:

```yaml
# values.yaml
...
config:
  max-in-flight: 50
...
```

A value of `0` removes the limit entirely. For more detail, see the `--max-in-flight` flag in the [Flags](/docs/agent/self-hosted/agent-stack-k8s/controller-configuration#flags) section of the [Controller configuration](/docs/agent/self-hosted/agent-stack-k8s/controller-configuration) page.

> 📘 Ensure the cluster has capacity first
> Increasing `max-in-flight` causes the controller to create more Kubernetes Jobs concurrently. If the underlying cluster does not have enough capacity, the additional Jobs and Pods are still created, but they remain in the `Pending` state until capacity becomes available. Before raising the limit, confirm your cluster can schedule the extra Pods, or pair the change with cluster autoscaling. See [Controller pod is not running](/docs/agent/self-hosted/agent-stack-k8s/troubleshooting#common-issues-and-fixes-controller-pod-is-not-running) for diagnosing `Pending` pods.

#### Workaround

Execute the `kubectl -n buildkite rollout restart deployment agent-stack-k8s` command to restart the controller pod and clear the `max-in-flight reached` condition as this will allow scheduling to resume.

#### Fix

If you are using any version of the controller older than [v0.27.0](https://github.com/buildkite/agent-stack-k8s/releases/tag/v0.27.0), [upgrade](https://github.com/buildkite/agent-stack-k8s/releases) to the latest version.

### Multiple controllers share the same stack ID

When multiple Buildkite Agent Stack for Kubernetes controllers target the same Buildkite queue without each being given a unique stack ID, they all default to the stack ID `agent-stack-k8s`. Sharing a stack ID across controllers can cause collisions and unpredictable scheduling behavior. Each controller should be assigned a unique ID.

#### Fix

Set a unique `id` value for each controller in its configuration values YAML file. For example:

```yaml
# Stack A: values.yaml
config:
  id: "agent-stack-k8s-us-east-1"
  pod-pending-timeout: "3m"
```

```yaml
# Stack B: values.yaml
config:
  id: "agent-stack-k8s-us-west-2"
  pod-pending-timeout: "3m"
```

If you set the ID through the Helm command line, also override `fullnameOverride` so the Kubernetes resources for each release have unique names:

```bash
# Stack A
helm upgrade --install agent-stack-k8s oci://ghcr.io/buildkite/helm/agent-stack-k8s \
    --namespace buildkite \
    --create-namespace \
    --set fullnameOverride=agent-stack-k8s-us-east-1 \
    --set config.id=agent-stack-k8s-us-east-1 \
    --values values.yml
```

```bash
# Stack B
helm upgrade --install agent-stack-k8s oci://ghcr.io/buildkite/helm/agent-stack-k8s \
    --namespace buildkite \
    --create-namespace \
    --set fullnameOverride=agent-stack-k8s-us-west-2 \
    --set config.id=agent-stack-k8s-us-west-2 \
    --values values.yml
```

### Jobs get cancelled by controller

Buildkite jobs sometimes fail with the following error:

```
The pod has been in Pending state for 15m1s without starting.
```

This indicates that the Job's pod controller created did not start within the default 15-minute window. Common causes include:

- Scheduling issues in k8s cluster where pod affinity rules are not matching with nodes in the cluster
- No available node that can fit the pod as they are all fully utilized

#### Fix

Review the k8s cluster/node config to ensure nodes are available to schedule the pods. In scenarios where it is fine to wait longer than 15 minutes for pod to start to optimize for infrastructure usage, increase the pod pending timeout by setting `pod-pending-timeout` in the controller's configuration values YAML file to a value greater than the default of `15m`:

```yaml
#values.yaml
...
config:
  pod-pending-timeout: "20m"
...
```

### Jobs time out waiting for containers to start

Buildkite jobs sometimes fail with the following error:

```
Error running job: timed out waiting 5m0s for all containers to connect
```

This indicates that one or more containers in the Job's Pod did not start within the default 5-minute window. Common causes include:

- A container image is very large and takes longer than 5 minutes to pull.
- The cluster is under heavy load and image pulls or scheduling are delayed.
- A container failed to start because of a missing secret, ConfigMap, or invalid image reference. In these cases, inspect the Pod events as described in [Controller pod is not running](/docs/agent/self-hosted/agent-stack-k8s/troubleshooting#common-issues-and-fixes-controller-pod-is-not-running).

#### Fix

If long image pulls or scheduling delays are expected, increase the container start timeout by setting `container-start-timeout` in the controller's configuration values YAML file to a value greater than the default of `5m`:

```yaml
# values.yaml
...
config:
  container-start-timeout: "15m"
...
```

For other configurable timeouts, see the [Flags](/docs/agent/self-hosted/agent-stack-k8s/controller-configuration#flags) section of the [Controller configuration](/docs/agent/self-hosted/agent-stack-k8s/controller-configuration) page. To increase the maximum runtime of Kubernetes Jobs after they start, see [Long-running jobs](/docs/agent/self-hosted/agent-stack-k8s/long-running-jobs).

### Wrong exit code affects auto job retries

Error code from the Kubernetes pods may not be passed through the agent, preventing the use of [exit-based retries](/docs/pipelines/configure/retry). This is what the error could look like:

```
The following init containers failed:

 CONTAINER   EXIT CODE  SIGNAL  REASON                  MESSAGE                                                        
 My-agent        137       0    ContainerStatusUnknown  The container could not be located when the pod was terminated
```

Such scenario might take place if in the Buildkite Pipelines UI, the exit code was `137`, however the exit code emitted from the container was `1`. As a result, the kickoff of retries will not happen if they were configured to happen for the exit code `1`.

#### Workaround

Add a retry rule for all stack-level failures. An example of such configuration would look like this:

```
retry:
  - signal_reason: "stack_error"
    limit: 3
  ```

#### Fix

Upgrading to version [v0.29.0](https://github.com/buildkite/agent-stack-k8s/releases/tag/v0.29.0) is the recommended action in this case as a "stack_error" exit reason was added to the agent, to provide better visibility to stack-level errors.
