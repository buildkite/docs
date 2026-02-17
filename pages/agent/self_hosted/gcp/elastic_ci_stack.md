# Elastic CI Stack for GCP overview

The Buildkite Elastic CI Stack for GCP gives you a private, autoscaling [Buildkite Agent](/docs/agent) cluster running on Google Cloud Platform. You can use it to run your builds on your own infrastructure, with complete control over security, networking, and costs.

## Architecture

The stack is organized into four Terraform modules:

- **[Networking](https://github.com/buildkite/terraform-buildkite-elastic-ci-stack-for-gcp/tree/main/modules/networking)** - VPC, subnets, Cloud NAT, and firewall rules
- **[IAM](https://github.com/buildkite/terraform-buildkite-elastic-ci-stack-for-gcp/tree/main/modules/iam)** - service accounts and permissions for agents and metrics
- **[Compute](https://github.com/buildkite/terraform-buildkite-elastic-ci-stack-for-gcp/tree/main/modules/compute)** - instance groups, autoscaling, and agent configuration
- **[Buildkite Agent Metrics](https://github.com/buildkite/terraform-buildkite-elastic-ci-stack-for-gcp/tree/main/modules/buildkite-agent-metrics)** - Cloud Function for publishing queue metrics

## Features

The Buildkite Elastic CI Stack for GCP supports:

- All GCP regions
- Linux operating system (Debian 12)
- Configurable machine types (including ARM instances)
- Configurable autoscaling based on build queue activity
- Docker and Docker Compose v2
- Multi-architecture build support (ARM/x86 cross-platform)
- Cloud Logging for system and Buildkite Agent events
- Cloud Monitoring metrics from the Buildkite API
- Support for stable, beta, or edge Buildkite Agent releases
- Multiple stacks in the same GCP project
- Rolling updates to stack instances to reduce interruption
- Secret Manager integration for secure token storage
- Preemptible VM support for cost optimization
- Automated Docker garbage collection and disk space management

## Get started with the Elastic CI Stack for GCP

You can get started with the Buildkite Elastic CI Stack for GCP using Terraform. Follow the [Terraform setup guide](/docs/agent/self-hosted/gcp/elastic-ci-stack/terraform).

## Architecture comparison

The Elastic CI Stack for GCP is inspired by the [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws) and provides similar functionality using GCP services:

| Feature | AWS Implementation | GCP Implementation |
|---------|--------------------|--------------------|
| Compute | EC2 Auto Scaling Groups | Managed Instance Groups |
| Networking | VPC, NAT Gateway | VPC, Cloud NAT |
| Secrets | Secrets Manager / Parameter Store | Secret Manager |
| Logging | CloudWatch Logs | Cloud Logging |
| Metrics | CloudWatch Metrics | Cloud Monitoring |
| Autoscaling Metrics | Lambda function | Cloud Function |
| Image Building | Packer | Packer |
| Infrastructure | CloudFormation or Terraform | Terraform |

## What's on each machine?

This is the list of contents on each machine running the Buildkite Elastic CI Stack for GCP:

- [Debian 12 (Bookworm)](https://www.debian.org/releases/bookworm/)
- [The Buildkite Agent](/docs/agent)
- [Git](https://git-scm.com/)
- [Docker](https://www.docker.com)
- [Docker Compose v2](https://docs.docker.com/compose/)
- [Docker Buildx](https://docs.docker.com/buildx/working-with-buildx/)
- [gcloud CLI](https://cloud.google.com/sdk/gcloud) - useful for performing any ops-related tasks
- [jq](https://stedolan.github.io/jq/) - useful for manipulating JSON responses from CLI tools

For more details on what versions are installed, see the [Packer templates](https://github.com/buildkite/terraform-buildkite-elastic-ci-stack-for-gcp/tree/main/packer).

The Buildkite Agent runs as user `buildkite-agent`.

## Supported builds

This stack is designed to run your builds in a shared-nothing pattern similar to the [12 factor application principles](http://12factor.net):

- Each project should encapsulate its dependencies through Docker and Docker Compose.
- Build pipeline steps should assume no state on the machine (and instead rely on the [build meta-data](/docs/pipelines/build-meta-data), [build artifacts](/docs/pipelines/artifacts), or Cloud Storage).
- Secrets are configured using environment variables exposed using Secret Manager.

By following these conventions, you get a scalable, repeatable, and source-controlled CI environment that any team within your organization can use.

## Suggested reading

To gain a better understanding of how Elastic CI Stack for GCP works and how to use it most effectively and securely, check out the following resources:

- [GitHub repo for Elastic CI Stack for GCP](https://github.com/buildkite/terraform-buildkite-elastic-ci-stack-for-gcp)
- [Terraform setup guide](/docs/agent/self-hosted/gcp/elastic-ci-stack/terraform)
- [Configuration parameters for Elastic CI Stack for GCP](/docs/agent/self-hosted/gcp/elastic-ci-stack/configuration-parameters)
- [Architecture overview](/docs/agent/self-hosted/gcp/architecture/vpc)
