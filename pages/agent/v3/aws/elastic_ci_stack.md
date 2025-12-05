---
toc_include_h3: false
---

# Elastic CI Stack for AWS overview

The Buildkite Elastic CI Stack for AWS gives you a private, autoscaling
[Buildkite agent](/docs/agent/v3) cluster. You can use the Buildkite Elastic CI Stack for AWS to parallelize large test suites across hundreds of nodes, run tests, app deployments, or AWS ops tasks. Each Buildkite Elastic CI Stack for AWS deployment contains an Auto Scaling group and a launch template.

## Architecture

For an overview of the architecture of the Elastic CI Stack for AWS, take a look at our [Architecture documentation](/docs/agent/v3/aws/elastic-ci-stack/architecture).

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

### Required and recommended skills

The Elastic CI Stack for AWS does not require familiarity with the underlying AWS services to deploy it. However, to run builds, some familiarity with the following services is required:

- [AWS CloudFormation](https://aws.amazon.com/cloudformation/) if using the Cloudformation deployment method
- [Terraform](https://developer.hashicorp.com/terraform) if using the Terraform deployment method
- [Amazon EC2](https://aws.amazon.com/ec2/) (to select an EC2 `InstanceTypes` stack parameter appropriate for your workload)
- [Amazon S3](https://aws.amazon.com/s3/) (to copy your git clone secret for cloning and building private repositories)

Elastic CI Stack for AWS provides defaults and pre-configurations suited for most use cases without the need for additional customization. Still, you'll benefit from familiarity with VPCs, availability zones, subnets, and security groups for custom instance networking.

For post-deployment diagnostic purposes, deeper familiarity with EC2 is recommended to be able to access the instances launched to execute Buildkite jobs over SSH or [AWS Systems Manager Sessions](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html).

### Billable services

Elastic CI Stack for AWS creates its own VPC (virtual private cloud) by default. Best practice is to set up a separate development AWS account and use role switching and consolidated billing. You can check out this external tutorial for more information on how to ["Delegate Access Across AWS Accounts"](http://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html).

The Elastic CI Stack for AWS deploys several billable Amazon services that do not require upfront payment and operate on a pay-as-you-go principle, with the bill proportional to usage.

<table>
  <thead>
    <tr>
      <th style="width:30%">Service name</th>
      <th style="width:60%">Purpose</th>
      <th style="width:10%">Required</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "service_name": "EC2",
        "purpose": "Deployment of instances",
        "required": "☑️"
      },
      {
        "service_name": "EBS",
        "purpose": "Root disk storage of EC2 instances",
        "required": "☑️"
      },
      {
        "service_name": "Lambda",
        "purpose": "Scaling of Auto Scaling group and modifying Auto Scaling group's properties",
        "required": "☑️"
      },
      {
        "service_name": "Systems Manager Parameter Store",
        "purpose": "Storing the Buildkite agent token",
        "required": "☑️"
      },
      {
        "service_name": "CloudWatch Logs",
        "purpose": "Logs for instances and Lambda scaler",
        "required": "☑️"
      },
      {
        "service_name": "CloudWatch Metrics",
        "purpose": "Metrics recorded by Lambda scaler",
        "required": "☑️"
      },
      {
        "service_name": "S3",
        "purpose": "Charging based on storage and transfers in/and out of the secrets bucket (on by default)",
        "required": "❌"
      }
    ].select { |field| field[:service_name] }.each do |field| %>
      <tr>
        <td>
          <p><%= field[:service_name] %></p>
        </td>
        <td>
          <p><%= field[:purpose] %></p>
        </td>
        <td>
          <p><%= field[:required] %></p>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

Buildkite services are billed according to your [plan](https://buildkite.com/pricing).

### Supported builds

This stack is designed to run your builds in a share-nothing pattern similar to the [12 factor application principals](http://12factor.net):

- Each project should encapsulate its dependencies through Docker and Docker Compose.
- Build pipeline steps should assume no state on the machine (and instead rely on [build meta-data](/docs/guides/build-meta-data), [build artifacts](/docs/guides/artifacts) or S3).
- Secrets are configured using environment variables exposed using the S3 secrets bucket.

By following these conventions you get a scalable, repeatable, and source-controlled CI environment that any team within your organization can use.

## Running your first build

We've created a sample [bash-parallel-example sample pipeline](https://github.com/buildkite/bash-parallel-example) for you to test with your new autoscaling stack. Click the **Add to Buildkite** button below (or on the [GitHub README](https://github.com/buildkite/bash-parallel-example)):

<a class="inline-block" href="https://buildkite.com/new?template=https://github.com/buildkite/bash-parallel-example" target="_blank" rel="nofollow"><img src="https://buildkite.com/button.svg" alt="Add Bash Example to Buildkite" class="no-decoration" width="160" height="30"></a>

Click **Create Pipeline**. Depending on your organization's settings, the next step will vary slightly:

- If your organization uses the web-based steps editor (default), your pipeline is now ready for its first build. You can skip to the next step.
- If your organization has been upgraded to the [YAML steps editor](/docs/pipelines/tutorials/pipeline-upgrade), you should see a **Choose a Starting Point** wizard. Select **Pipeline Upload** from the list:
  <%= image "buildkite-pipeline-upload.png", size: "#{782/2}x#{400/2}", alt: 'Upload Pipeline from Version Control' %>

Click **New Build** in the top right and choose a build message (perhaps a little party `\:partyparrot\:`?):

<%= image "buildkite-new-build.png", size: "#{1140/2}x#{898/2}", alt: 'Triggering Buildkite Build' %>

Once your build is created, head back to [AWS EC2 Auto Scaling Groups](https://console.aws.amazon.com/ec2/v2/home?#AutoScalingGroups) to watch the Elastic CI Stack for AWS creating new EC2 instances:

<%= image "ec2-asg.png", size: "#{400/2}x#{200/2}", alt: 'AWS EC2 Auto Scaling Group Menu' %>

<!-- vale off -->

Select the **buildkite-AgentAutoScaleGroup-xxxxxxxxxxxx** group and then the **Instances** tab. You'll see instances starting up to run your new build and after a few minutes they'll transition from **Pending** to **InService**:

<!-- vale on -->

<%= image "buildkite-demo-instances.png", width: 3266/2, height: 1748/2, alt: "AWS Auto Scaling Group Launching" %>

Once the instances are ready they will appear on your Buildkite Agents page:

<%= image "buildkite-connected-agents.png", size: "#{1584/2}x#{1508/2}", alt: 'Buildkite Connected Agents' %>

And then your build will start running on your new agents:

<%= image "build.png", size: "#{2356/2}x#{1488/2}", alt: "Your First Build" %>

Congratulations on running your first Elastic CI Stack for AWS build on Buildkite! :tada:

## Get started with the Elastic CI Stack for AWS

Get started with Buildkite Elastic CI Stack for AWS for:

* Linux and Windows
    - [Setup with CloudFormation](/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/setup)
    - [Setup with Terraform](/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/terraform)
* Mac
    - [Setup with CloudFormation](/docs/agent/v3/aws/elastic-ci-stack/ec2-mac/setup)
