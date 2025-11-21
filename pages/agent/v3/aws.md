---
toc_include_h3: false
---

# Buildkite Agents in AWS

The Buildkite Agent can be run on AWS using Buildkite's Elastic CI Stack for AWS CloudFormation template, or by installing the agent on your self-managed instances. On this page, common installation and setup recommendations for different scenarios of using the Buildkite Agent on AWS are covered.

## Using the Elastic CI Stack for AWS CloudFormation template

The [Elastic CI Stack for AWS](/docs/agent/v3/aws/elastic-ci-stack) is a
CloudFormation template for an autoscaling Buildkite Agent cluster. The agent instances include Docker, S3, and CloudWatch integration.

You can use an Elastic CI Stack for AWS deployment to test Linux or Windows projects,
parallelize large test suites, run Docker containers or docker-compose
integration tests, or perform any AWS ops related tasks.

You can launch an instance of the Elastic CI Stack for AWS from the [Getting started section of its GitHub repository's README](https://github.com/buildkite/elastic-ci-stack-for-aws?tab=readme-ov-file#getting-started).

## Using the Buildkite Agent Stack for Kubernetes on AWS

The Buildkite Agent's jobs can be run within a Kubernetes cluster on AWS.

Before you start, you will require your own Kubernetes cluster running on AWS. Learn more about this from [Kubernetes on AWS](https://aws.amazon.com/kubernetes/).

Once your Kubernetes cluster is running in AWS, you can then set up the [Buildkite Agent Stack for Kubernetes](/docs/agent/v3/agent-stack-k8s) to run in this cluster. Learn more about how to set up the Agent Stack for Kubernetes on the [Installation](/docs/agent/v3/agent-stack-k8s/installation) page of this documentation.

## Installing the agent on your own AWS instances

To run the Buildkite Agent on your own AWS instances, use the installer that matches your
instance operating system:

* For Amazon Linux 2 or later, use the [Red Hat/CentOS installer](/docs/agent/v3/redhat)
* For macOS, use [installing the agent on your own AWS EC2 Mac instances](/docs/agent/v3/aws/self-serve-installation/ec2-mac)

## Using the Elastic CI Stack for AWS for EC2 Mac CloudFormation template

[Elastic CI Stack for AWS for EC2 Mac](https://github.com/buildkite/elastic-ci-stack-for-ec2-mac) is an
experimental CloudFormation template for an autoscaling macOS Buildkite agent
cluster.

You can use an Elastic CI Stack for AWS for EC2 Mac deployment to build and test macOS,
iOS, iPadOS, tvOS, and watchOS projects.

Read the [Auto Scaling EC2 Mac instances](/docs/agent/v3/aws/elastic-ci-stack/ec2-mac/setup) documentation for instructions on preparing and deploying this template.
