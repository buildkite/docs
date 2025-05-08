# Troubleshooting

If you're experiencing any issues with Buildkite Agent Stack for Kubernetes controller, we recommend enabling the debug mode and log collection to get a better visibility into potential issues.

## Enable debug mode

Increasing the verbosity of Buildkite Agent Stack for Kubernetes controller's logs can be accomplished by enabling Debug mode. Once enabled, the logs will emit individual, detailed actions performed by the controller while obtaining jobs from Buildkite's API, processing configurations to generate a Kubernetes PodSpec and creating a new Kubernetes Job. Debug mode can help to identify processing delays or incorrect job processing issues.

Debug mode can be enabled during the Helm deployment of the Buildkite Agent Stack for Kubernetes controller via the command line:

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
- Kubernetes Namespace where the Buildkite Agent Stack for Kubernetes controller is deployed
- Buildkite job ID to collect Job and Pod logs

### Gathering of data and logs

The `log-collector` script will gather the following information:
- Kubernetes Job, Pod resource details for Buildkite Agent Stack for Kubernetes controller
- Kubernetes Pod logs for Buildkite Agent Stack for Kubernetes controller
- Kubernetes Job, Pod resource details for Buildkite job ID (if provided)
- Kubernetes Pod logs that executed Buildkite job ID (if provided)

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
