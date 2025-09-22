# Troubleshooting

If you're experiencing any issues with Buildkite Agent Stack for Kubernetes controller, it is recommended that you enable the debug mode and log collection to obtain better visibility and insight into such issues or any other related problems.

## Enable debug mode

Increasing the verbosity of Buildkite Agent Stack for Kubernetes controller's logs can be accomplished by enabling debug mode. Once enabled, the logs will emit individual, detailed actions performed by the controller while obtaining jobs from Buildkite's API, processing configurations to generate a Kubernetes PodSpec and creating a new Kubernetes Job. Debug mode can help to identify processing delays or incorrect job processing issues.

Debug mode can be enabled during the [installation](/docs/agent/v3/agent-stack-k8s/installation) (Helm chart deployment) of the Buildkite Agent Stack for Kubernetes controller via the command line:

```bash
helm upgrade --install agent-stack-k8s oci://ghcr.io/buildkite/helm/agent-stack-k8s \
    --namespace buildkite \
    --create-namespace \
    --debug \
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

The logs will be archived in a tarball named `logs.tar.gz` in the current directory. If requested, these logs may be provided via email to the Buildkite Support (`support@buildkite.com`).

## Common issues and fixes

Below are some common issues that users may experience when using the Buildkite Agent Stack for Kubernetes controller to process Buildkite jobs.

### Jobs are being created, but not processed by controller

The primary requirement to have the Buildkite Agent Stack for Kubernetes controller acquire and process a Buildkite job is a matching `queue` tag. If the controller is configured to process scheduled jobs with tag `"queue=kubernetes"` you will need to ensure that your pipeline YAML is [targeting the same queue](https://buildkite.com/docs/agent/v3/queues#targeting-a-queue) at either the pipeline-level or at each step-level.

If a job is created without a queue target, the [default queue](https://buildkite.com/docs/agent/v3/queues#the-default-queue) will be applied. The Buildkite Agent Stack for Kubernetes controller expects all jobs to have a `queue` tag explicitly defined, even for "default" cluster queues. Any job missing a `queue` tag will be skipped by the controller during processing and the controller emit the following log:

```
job missing 'queue' tag, skipping...
```

To view the agent tags applied to your job(s), the following GraphQL query can be executed (be sure to substitute your Organization's slug and Cluster ID):

```
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

### Controller stops accepting new jobs from a cluster Queue

There may be some cases where some waiting jobs increase in the Buildkite UI, however, no new pods are created.
Reviewing the Logs may show `max-in-flight reached` with counters not decreasing.
Error may look like 
``` 
DEBUG	limiter	scheduler/limiter.go:77	max-in-flight reached	{"in-flight": 25}
````

#### Some initial steps to help 

1. Enable debug log and look for errors related to `max-in-flight` reached
2. Confirm no new Kubernetes jobs are created while the UI shows jobs waiting 

#### Temporary fix 
Execute `kubectl -n buildkite rollout restart deployment agent-stack-k8s` to restart the controller pod and clear the the “max-in-flight reached” condition that allows scheduling to resume


#### Fixes:
[Upgrade](https://github.com/buildkite/agent-stack-k8s/releases) to the latest controller release if using any version less than [v0.2.7](https://github.com/buildkite/agent-stack-k8s/releases/tag/v0.27.0)



#### Wrong exit code 

Error code from the kubernetes pods may not be passed through the agent preventing the use of exit based retries the error could look like below 

A scenrario would be if a user saw in the Buildkite UI that an exit code was `137` however the exit code emitted from the container was `1`. This would prevent the kickoff of retries that were configured for the exit code `1`. 

A workaround that could help here is to simply add a retry rule for all stack level failures 
An example of the configuration would look like this 

```
retry:
  - signal_reason: stack_error
    limit: 3
  ```
However, the version [v.0.29.0](https://github.com/buildkite/agent-stack-k8s/releases/tag/v0.29.0) has better handling for this situation as we added a "stack_error" exit reason to the agent, to provide better visibility to stack-level errors. 


