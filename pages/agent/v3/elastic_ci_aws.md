---
toc_include_h3: false
---

# Linux and Windows setup for the Elastic CI Stack for AWS

The [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws) gives you a private, autoscaling Buildkite agent cluster in your own AWS account. Use it to parallelize large test suites across hundreds of nodes, run tests and deployments for services and apps, or run AWS ops tasks.

This guide leads you through getting started with the stack for Linux and Windows.

<!-- vale off -->

> 📘 Get hands-on
> Read on for detailed instructions, or jump straight in:
> <a href="https://console.aws.amazon.com/cloudformation/home#/stacks/new?stackName=buildkite&templateURL=https://s3.amazonaws.com/buildkite-aws-stack/latest/aws-stack.yml"><%= image "launch-stack.svg", alt: "Launch stack button" %></a>

<!-- vale on -->

## Before you start

Most Elastic CI Stack for AWS features are supported on both Linux and Windows.
The following AMIs are available in all the supported regions:

- Amazon Linux 2023 (64-bit x86)
- Amazon Linux 2023 (64-bit ARM, Graviton)
- Windows Server 2019 (64-bit x86)

If you want to use the [AWS CLI](https://aws.amazon.com/cli/) instead, download [`config.json.example`](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/-/config.json.example), rename it to `config.json`, add your Buildkite Agent token (and any other config values), and then run the below command:

```bash
aws cloudformation create-stack \
  --output text \
  --stack-name buildkite \
  --template-url "https://s3.amazonaws.com/buildkite-aws-stack/latest/aws-stack.yml" \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
  --parameters "$(cat config.json)"
```

### Required and recommended skills

The Elastic CI Stack for AWS does not require familiarity with the underlying AWS services to deploy it. However, to run builds, some familiarity with the following AWS services is required:

- [AWS CloudFormation](https://aws.amazon.com/cloudformation/)
- [Amazon EC2](https://aws.amazon.com/ec2/) (to select an EC2 `InstanceTypes` stack parameter appropriate for your workload)
- [Amazon S3](https://aws.amazon.com/s3/) (to copy your git clone secret for cloning and building private repositories)

Elastic CI Stack for AWS provides defaults and pre-configurations suited for most use cases without the need for additional customization. Still, you'll benefit from familiarity with VPCs, availability zones, subnets, and security groups for custom instance networking.

For post-deployment diagnostic purposes, deeper familiarity with EC2 is recommended to be able to access the instances launched to execute Buildkite jobs over SSH or [AWS Systems Manager Sessions](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html).

### Billable services

> Elastic CI Stack for AWS creates its own VPC (virtual private cloud) by default. Best practice is to set up a separate development AWS account and use role switching and consolidated billing. You can check out this external tutorial for more information on how to ["Delegate Access Across AWS Accounts"](http://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html).

The Elastic CI Stack for AWS template deploys several billable Amazon services that do not require upfront payment and operate on a pay-as-you-go principle, with the bill proportional to usage.

| Service name                    | Purpose                                                                                  | Required |
| ------------------------------- | ---------------------------------------------------------------------------------------- | -------- |
| EC2                             | Deployment of instances                                                                  | ☑️       |
| EBS                             | Root disk storage of EC2 instances                                                       | ☑️       |
| Lambda                          | Scaling of Auto Scaling group and modifying Auto Scaling group's properties              | ☑️       |
| Systems Manager Parameter Store | Storing the Buildkite agent token                                                        | ☑️       |
| CloudWatch Logs                 | Logs for instances and Lambda scaler                                                     | ☑️       |
| CloudWatch Metrics              | Metrics recorded by Lambda scaler                                                        | ☑️       |
| S3                              | Charging based on storage and transfers in/and out of the secrets bucket (on by default) | ❌       |

Buildkite services are billed according to your [plan](https://buildkite.com/pricing).

### What's on each machine?

<!-- vale off -->

- [Amazon Linux 2023](https://aws.amazon.com/amazon-linux-2/)
- [Buildkite Agent v3.71.0](https://buildkite.com/docs/agent)
- [Git](https://git-scm.com/) and [Git LFS](https://git-lfs.com/)
- [Docker](https://www.docker.com)
- [Docker Compose](https://docs.docker.com/compose/)
- [AWS CLI](https://aws.amazon.com/cli/) - useful for performing any ops-related tasks
- [jq](https://stedolan.github.io/jq/) - useful for manipulating JSON responses from CLI tools such as AWS CLI or the Buildkite API

For more details on what versions are installed on a given Elastic CI Stack, see the corresponding [release announcement](https://github.com/buildkite/elastic-ci-stack-for-aws/releases).

<!-- vale on -->

On both Linux and Windows, the Buildkite agent runs as user `buildkite-agent`.

### Supported builds

This stack is designed to run your builds in a share-nothing pattern similar to the [12 factor application principals](http://12factor.net):

- Each project should encapsulate its dependencies through Docker and Docker Compose.
- Build pipeline steps should assume no state on the machine (and instead rely on [build meta-data](/docs/guides/build-meta-data), [build artifacts](/docs/guides/artifacts) or S3).
- Secrets are configured using environment variables exposed using the S3 secrets bucket.

By following these conventions you get a scalable, repeatable, and source-controlled CI environment that any team within your organization can use.

## Launching the stack

Go to the [Agents page](https://buildkite.com/organizations/-/agents) on Buildkite and select the **AWS** tab:

<%= image "agents-tab.png", size: "#{1532/2}x#{296/2}", alt: "Buildkite AWS Agents" %>

Click **Launch Stack** :red_button:

<%= image "agents-tab-launch.png", size: "#{554/2}x#{316/2}", alt: 'Launch Buildkite Elastic CI Stack for AWS' %>

<%= image "aws-select-template.png", size: "#{1037/2}x#{673/2}", alt: "AWS Select Template Screen" %>

After clicking **Next**, configure the stack using your Buildkite agent token:

<%= image "aws-parameters.png", size: "#{2200/2}x#{1934/2}", alt: "AWS Parameters" %>

If you don't know your agent token, there is a **Reveal Agent Token** button available on the right-hand side of the [Agents page](https://buildkite.com/organizations/-/agents):

<%= image "buildkite-agent-token.png", size: "#{752/2}x#{424/2}", alt: "Reveal Agent Token" %>

By default the stack uses a job queue of `default`, but you can specify any other queue name you like.

A common example of setting a queue for a dedicated Windows agent can be achieved with the following in your `pipeline.yml` after you've set up your Windows stack:

```yaml
steps:
  - command: echo "hello from windows"
    agents:
      queue: "windows"
```

For more information, see [Buildkite Agent job queues](/docs/agent/v3/queues), specifically [Targeting a queue](/docs/agent/v3/queues#targeting-a-queue).

Review the parameters, see [Elastic CI Stack for AWS parameters](/docs/agent/v3/elastic_ci_aws/parameters) for more details.

Once you're ready, check these three checkboxes:

- I acknowledge that AWS CloudFormation might create IAM resources.
- I acknowledge that AWS CloudFormation might create IAM resources with custom names.
- I acknowledge that AWS CloudFormation might require the following capability: `CAPABILITY_AUTO_EXPAND`

Then click **Create stack**:

<%= image "aws-create-stack.png", size: "#{2728/2}x#{1006/2}", alt: "AWS Create Stack Button" %>

After creating the stack, Buildkite takes you to the [CloudFormation console](https://console.aws.amazon.com/cloudformation/home). Click the **Refresh** icon in the top right hand corner of the screen until you see the stack status is `CREATE_COMPLETE`.

<%= image "elastic-ci-stack.png", width: 2756/2, height: 1406/2, alt: "AWS Elastic CI Stack for AWS Create Complete" %>

You now have a working Elastic CI Stack for AWS ready to run builds! :tada:

## Running your first build

We've created a sample [bash-parallel-example sample pipeline](https://github.com/buildkite/bash-parallel-example) for you to test with your new autoscaling stack. Click the **Add to Buildkite** button below (or on the [GitHub README](https://github.com/buildkite/bash-parallel-example)):

<a class="inline-block" href="https://buildkite.com/new?template=https://github.com/buildkite/bash-parallel-example" target="_blank" rel="nofollow"><img src="https://buildkite.com/button.svg" alt="Add Bash Example to Buildkite" class="no-decoration" width="160" height="30"></a>

Click **Create Pipeline**. Depending on your organization's settings, the next step will vary slightly:

- If your organization uses the web-based steps editor (default), your pipeline is now ready for its first build. You can skip to the next step.
- If your organization has been upgraded to the [YAML steps editor](https://buildkite.com/docs/tutorials/pipeline-upgrade), you should see a **Choose a Starting Point** wizard. Select **Pipeline Upload** from the list:
  <%= image "buildkite-pipeline-upload.png", size: "#{782/2}x#{400/2}", alt: 'Upload Pipeline from Version Control' %>

Click **New Build** in the top right and choose a build message (perhaps a little party `\:partyparrot\:`?):

<%= image "buildkite-new-build.png", size: "#{1140/2}x#{898/2}", alt: 'Triggering Buildkite Build' %>

Once your build is created, head back to [AWS EC2 Auto Scaling Groups](https://console.aws.amazon.com/ec2autoscaling/home) to watch the Elastic CI Stack for AWS creating new EC2 instances:

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

## Related content

To gain a better understanding of how Elastic CI Stack for AWS works and how to use it most effectively and securely, check out the following resources:

- [Running Buildkite Agent on AWS](/docs/agent/v3/aws)
- [GitHub repo for Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws)
- [Template parameters for Elastic CI Stack for AWS](/docs/agent/v3/elastic-ci-aws/parameters)
- [Using AWS Secrets Manager](/docs/agent/v3/aws/secrets-manager)
- [VPC design](/docs/agent/v3/aws/vpc)
- [CloudFormation service role](/docs/agent/v3/elastic-ci-aws/cloudformation-service-role)
