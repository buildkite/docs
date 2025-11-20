# Buildkite Agents on Google Cloud Platform

The Buildkite Agent can be run on Google Cloud Platform (GCP) using Buildkite's Elastic CI Stack for GCP Terraform module, or by installing the agent on your self-managed instances. This page covers common installation and setup recommendations for different scenarios of using the Buildkite Agent on GCP.

## Using the Elastic CI Stack for GCP Terraform module

The [Elastic CI Stack for GCP](/docs/agent/v3/gcp/elastic-ci-stack/elastic-ci-stack) is a Terraform module for an autoscaling Buildkite Agent cluster. The agent instances include Docker, Cloud Storage, and Cloud Logging integration.

You can use an Elastic CI Stack for GCP deployment to test Linux projects, parallelize large test suites, run Docker containers or docker-compose integration tests, or perform any tasks related to GCP ops.

You can deploy an instance of the Elastic CI Stack for GCP by following the [Terraform setup guide](/docs/agent/v3/gcp/elastic-ci-stack/terraform).

## Using the Buildkite Agent Stack for Kubernetes on GCP

The Buildkite Agent's jobs can be run within a Kubernetes cluster on GCP.

To start, you will need your own Kubernetes cluster running on GCP. Learn more in [Google Kubernetes Engine (GKE) documentation](https://cloud.google.com/kubernetes-engine).

Once your Kubernetes cluster is running on GCP, you can then set up the [Buildkite Agent Stack for Kubernetes](/docs/agent/v3/agent-stack-k8s) to run in this cluster. Learn more about how to set up the Agent Stack for Kubernetes in the [Agent Stack for Kubernetes installation documentation](/docs/agent/v3/agent-stack-k8s/installation).

## Installing the agent on your own GCP instances

To run the Buildkite Agent on your own [Google Compute Engine](https://cloud.google.com/compute) instance, use whichever installer matches your instance operating system.

For example, to install on an Ubuntu-based instance:

1. Launch an instance using the latest Ubuntu LTS image [through the console](https://console.cloud.google.com/compute/instancesAdd)
1. Connect using SSH (via the console SSH button or `gcloud compute ssh`)
1. Follow the [setup instructions for Ubuntu](/docs/agent/v3/ubuntu)

For other Linux distributions, see:

- [Debian](/docs/agent/v3/debian)
- [Red Hat/CentOS](/docs/agent/v3/redhat)

### Configuring agents for production use

When running agents on individual Compute Engine instances, consider:

- **Service account permissions**: Create a dedicated service account with minimal required permissions.
- **Metadata server**: Use the [metadata server](https://cloud.google.com/compute/docs/metadata/overview) for configuration.
- **Startup scripts**: Configure the agent using [startup scripts](https://cloud.google.com/compute/docs/instances/startup-scripts).
- **Systemd integration**: Use systemd to manage the agent service (installed by default with package installers).
- **Logging**: Configure log shipping to [Cloud Logging](https://cloud.google.com/logging).

## Uploading artifacts to Google Cloud Storage

You can upload the [artifacts](/docs/pipelines/artifacts) created by your builds to your own [Google Cloud Storage](https://cloud.google.com/storage) bucket. Configure the agent to target your bucket by exporting the following environment variables using an [environment agent hook](/docs/agent/v3/hooks) (note that this cannot be set using the web interface of Buildkite Pipelines, API, or during pipeline upload):

```shell
export BUILDKITE_ARTIFACT_UPLOAD_DESTINATION="gs://my-bucket/$BUILDKITE_PIPELINE_ID/$BUILDKITE_BUILD_ID/$BUILDKITE_JOB_ID"
```

### Granting access to Cloud Storage

Make sure the agent has permission to create new objects. If the agent is running on Google Compute Engine or Google Kubernetes Engine, you can grant Storage Write permission to the instance or cluster, or restrict access more specifically using [a service account](https://cloud.google.com/compute/docs/access/service-accounts).

You can also set the application credentials using the environment variable `BUILDKITE_GS_APPLICATION_CREDENTIALS`. From Buildkite Agent versions 3.15.2 and above, you can also use raw JSON with the `BUILDKITE_GS_APPLICATION_CREDENTIALS_JSON` variable. See the [Managing Pipeline Secrets](/docs/pipelines/security/secrets/managing) documentation to learn about setting up environment variables securely.

### Configuring access control

If you are using any of the non-public [predefined Access Control Lists (ACLs)](https://cloud.google.com/storage/docs/access-control/lists#predefined-acl) to control permissions on your bucket, you won't have automatic access to your artifacts through the links in the web interface of Buildkite Pipelines. Artifacts will inherit the permissions of the bucket into which they're uploaded. You can set a specific ACL on an artifact:

```shell
export BUILDKITE_GS_ACL="publicRead"
```

### Authenticated access to artifacts

If you need to be authenticated to view the objects in your bucket, you can use Google Cloud Storage's [cookie-based authentication](https://cloud.google.com/storage/docs/request-endpoints#cookieauth):

```shell
export BUILDKITE_GCS_ACCESS_HOST="storage.cloud.google.com"
```

To use your own authenticating proxy for access control, set your proxy's domain as the access host:

```shell
export BUILDKITE_GCS_ACCESS_HOST="myproxyhost.com"
```

### Customizing artifact paths

If your proxy does not follow default GCS artifact path conventions, for example, the the bucket name is not included in the URL, you can override the artifact path.

To override the default path, export the environment variable `BUILDKITE_GCS_PATH_PREFIX`:

```shell
export BUILDKITE_GCS_PATH_PREFIX="custom-folder-structure/"
```

The above variable export will cause the artifact path to use your custom prefix instead of the `GCS_BUCKET_NAME`:

```shell
# default path
${BUILDKITE_GCS_ACCESS_HOST}/${GCS_BUCKET_NAME}/${ARTIFACT_PATH}

# using the BUILDKITE_GCS_PATH_PREFIX environment variable
${BUILDKITE_GCS_ACCESS_HOST}/custom-folder-structure/${ARTIFACT_PATH}
```

## Further reading

To continue exploring the possibilities of using the Buildkite Agent on Google Cloud Platform, you will benefit from visiting the following documentation pages:

- [Elastic CI Stack for GCP overview](/docs/agent/v3/gcp/elastic-ci-stack/elastic-ci-stack)
- [Terraform setup guide](/docs/agent/v3/gcp/elastic-ci-stack/terraform)
- [Configuration parameters](/docs/agent/v3/gcp/elastic-ci-stack/configuration-parameters)
- [Buildkite Agent Stack for Kubernetes](/docs/agent/v3/agent-stack-k8s)
- [Agent configuration](/docs/agent/v3/configuration)
- [Agent hooks](/docs/agent/v3/hooks)
