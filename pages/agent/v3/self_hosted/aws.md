---
toc_include_h3: false
---

# Buildkite Agents in AWS

The Buildkite Agent can be run on AWS using Buildkite's Elastic CI Stack for AWS, using a Kubernetes cluster or by installing the agent on your self-managed EC2 instances. On this page, common installation and setup recommendations for different scenarios of using the Buildkite Agent on AWS are covered.

## Using the Elastic CI Stack for AWS

The [Elastic CI Stack for AWS](/docs/agent/v3/self-hosted/aws/elastic-ci-stack) is an autoscaling Buildkite Agent cluster that includes Docker, S3, and CloudWatch integration.

You can use the Elastic CI Stack for AWS to test Linux or Windows projects, parallelize large test suites, run Docker containers or `docker-compose` integration tests, or perform any AWS ops related tasks.

### Setup with CloudFormation

You can launch the Elastic CI Stack for AWS directly in your AWS account using a CloudFormation template. For setup instructions, see [Setup with CloudFormation](/docs/agent/v3/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/setup).

### Setup with Terraform

In addition to using CloudFormation, the Elastic CI Stack for AWS can also be deployed and managed using the Terraform module. For setup instructions, see [Setup with Terraform](/docs/agent/v3/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/terraform).

## Using the Buildkite Agent Stack for Kubernetes on AWS

The Buildkite Agent's jobs can be run within a Kubernetes cluster on AWS.

Before you start, you will require your own Kubernetes cluster running on AWS. Learn more about this from [Kubernetes on AWS](https://aws.amazon.com/kubernetes/).

Once your Kubernetes cluster is running in AWS, you can then set up the [Buildkite Agent Stack for Kubernetes](/docs/agent/v3/self-hosted/agent-stack-k8s) to run in this cluster. Learn more about how to set up the Agent Stack for Kubernetes on the [Installation](/docs/agent/v3/self-hosted/agent-stack-k8s/installation) page of this documentation.

## Installing the agent on your own AWS instances

To run the Buildkite Agent on your own AWS EC2 instances, use the installer that matches your EC2 instance operating system:

* For Amazon Linux 2 or later, use the [Red Hat/CentOS installer](/docs/agent/v3/self-hosted/install/redhat)
* For macOS, use [installing the agent on your own AWS EC2 Mac instances](/docs/agent/v3/self-hosted/aws/self-serve-install/ec2-mac)

## Using the Elastic CI Stack for AWS for EC2 Mac CloudFormation template

[Elastic CI Stack for AWS for EC2 Mac](https://github.com/buildkite/elastic-ci-stack-for-ec2-mac) is an experimental CloudFormation template for an autoscaling macOS Buildkite agent cluster.

You can use an Elastic CI Stack for AWS for EC2 Mac deployment to build and test macOS, iOS, iPadOS, tvOS, and watchOS projects.

Read the [Auto Scaling EC2 Mac instances](/docs/agent/v3/self-hosted/aws/elastic-ci-stack/ec2-mac/setup) documentation for instructions on preparing and deploying this template.
