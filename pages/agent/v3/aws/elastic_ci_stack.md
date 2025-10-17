---
toc_include_h3: false
---

# Elastic CI Stack for AWS overview

The Buildkite Elastic CI Stack for AWS gives you a private, autoscaling
[Buildkite agent](/docs/agent/v3) cluster. You can use the Buildkite Elastic CI Stack for AWS to parallelize large test suites across hundreds of nodes, run tests, app deployments, or AWS ops tasks. Each Buildkite Elastic CI Stack for AWS deployment contains an Auto Scaling group and a launch template.

## Architecture

This diagram illustrates a standard deployment of Elastic CI Stack for AWS.

<%= image "buildkite-elastic-ci-stack-on-aws-architecture.png", alt: "Elastic CI Stack for AWS Architecture Diagram" %>

## Features

The Buildkite Elastic CI Stack for AWS supports:

* All AWS regions (except China and US GovCloud)
* Linux and Windows operating systems
* Configurable instance size
* Configurable number of Buildkite agents per instance
* Configurable spot instance bid price
* Configurable auto-scaling based on build activity
* Docker and Docker Compose
* Per-pipeline S3 secret storage (with SSE encryption support)
* Docker registry push/pull
* CloudWatch Logs for system and Buildkite agent events
* CloudWatch metrics from the Buildkite API
* Support for stable, beta or edge Buildkite Agent releases
* Multiple stacks in the same AWS Account
* Rolling updates to stack instances to reduce interruption

Most features are supported across both Linux and Windows. The following table provides details of which features are supported by these operating systems:

Feature | Linux | Windows
--- | --- | ---
Docker | ✅ | ✅
Docker Compose | ✅ | ✅
AWS CLI | ✅ | ✅
S3 Secrets Bucket | ✅ | ✅
ECR Login | ✅ | ✅
Docker Login | ✅ | ✅
CloudWatch Logs Agent | ✅ | ✅
Per-Instance Bootstrap Script | ✅ | ✅
🧑‍🔬 git-mirrors experiment | ✅ | ✅
SSM Access | ✅ | ✅
Instance Storage (NVMe) | ✅ |
SSH Access | ✅ |
Periodic `authorized_keys` Refresh | ✅ |
Periodic Instance Health Check | ✅ |
Git LFS | ✅ |
Additional sudo Permissions | ✅ |
RDP Access | | ✅
Pipeline Signing | ✅ | ✅

## Get started with the Elastic CI Stack for AWS

Get started with Buildkite Elastic CI Stack for AWS for:

* [Linux and Windows](/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/setup)
* [Mac](/docs/agent/v3/aws/elastic-ci-stack/ec2-mac/setup)
