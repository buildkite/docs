# Linux and Windows setup for the Elastic CI Stack for AWS with AWS CloudFormation

This guide leads you through getting started with the [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws) for Linux and Windows using [AWS CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html).

> 📘 Prefer Terraform?
> This guide uses AWS CloudFormation. For the Terraform setup instructions, see the [Terraform setup guide](/docs/agent/v3/aws/elastic_ci_stack/ec2_linux_and_windows/terraform).

With the help of the Elastic CI Stack for AWS, you are able to launch a private, autoscaling [Buildkite Agent cluster](/docs/pipelines/clusters) in your own AWS account.

<!-- vale off -->

> 📘 Get hands-on
> Read on for detailed instructions, or jump straight in:
> <a href="https://console.aws.amazon.com/cloudformation/home#/stacks/new?stackName=buildkite&templateURL=https://s3.amazonaws.com/buildkite-aws-stack/latest/aws-stack.yml"><%= image "launch-stack.svg", alt: "Launch stack button" %></a>

<!-- vale on -->

## Before you start

Most Elastic CI Stack for AWS features are supported on both Linux and Windows. The following [Amazon Machine Images (AMIs)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) are available by default in all supported regions. The operating system and architecture will be selected based on the values provided for the `InstanceOperatingSystem` and `InstanceTypes` parameters:

- Amazon Linux 2023 (64-bit x86)
- Amazon Linux 2023 (64-bit ARM, Graviton)
- Windows Server 2019 (64-bit x86)

If you want to use the [AWS CLI](https://aws.amazon.com/cli/) instead, download [`config.json.example`](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/-/config.json.example), rename it to `config.json`, add your Buildkite Agent token (and any [other config values](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/main/templates/aws-stack.yml)), and then run the below command:

```bash
aws cloudformation create-stack \
  --output text \
  --stack-name buildkite \
  --template-url "https://s3.amazonaws.com/buildkite-aws-stack/latest/aws-stack.yml" \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
  --parameters "$(cat config.json)"
```

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

Review the parameters, see [Elastic CI Stack for AWS parameters](/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/configuration-parameters) for more details.

Once you're ready, check these three checkboxes:

- I acknowledge that AWS CloudFormation might create IAM resources.
- I acknowledge that AWS CloudFormation might create IAM resources with custom names.
- I acknowledge that AWS CloudFormation might require the following capability: `CAPABILITY_AUTO_EXPAND`

Then click **Create stack**:

<%= image "aws-create-stack.png", size: "#{2728/2}x#{1006/2}", alt: "AWS Create Stack Button" %>

After creating the stack, Buildkite takes you to the [CloudFormation console](https://console.aws.amazon.com/cloudformation/home). Click the **Refresh** icon in the top right hand corner of the screen until you see the stack status is `CREATE_COMPLETE`.

<%= image "elastic-ci-stack.png", width: 2756/2, height: 1406/2, alt: "AWS Elastic CI Stack for AWS Create Complete" %>

You now have a working Elastic CI Stack for AWS ready to run builds! :tada:

## CloudFormation service role

If you want to explicitly specify the actions CloudFormation can perform on
your behalf when deploying the Elastic CI Stack for AWS, you can create your
stack using an IAM User or Role that has been granted limited permissions, or
use an [AWS CloudFormation service role](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-iam-servicerole.html).

The Elastic CI Stack for AWS repository contains an experimental
[service role template](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/-/templates/service-role.yml).
This template creates an IAM Role and set of IAM Policies with the IAM Actions
necessary to create, update, and delete a CloudFormation Stack created with the
Elastic CI Stack for AWS template.

The IAM role created by this template is used to create and delete CloudFormation stacks in our
test suite, but it is likely that the permissions needed for some stack parameter permutations are
missing.

This template can be deployed as is, or used as the basis for your own
CloudFormation service role.


### Deploying the service role template

With a copy of the Elastic CI Stack for AWS repository, the service role
template can be deployed using the [AWS CLI](https://aws.amazon.com/cli/):

```bash
aws cloudformation deploy \
	--template-file templates/service-role.yml \
	--stack-name buildkite-elastic-ci-stack-service-role \
	--capabilities CAPABILITY_IAM
```

Once the stack has been created, the role ARN (Amazon Resource Name) can be retrieved using:

```bash
aws cloudformation describe-stacks \
	--stack-name buildkite-elastic-ci-stack-service-role \
	--query "Stacks[0].Outputs[?OutputKey=='RoleArn'].OutputValue" \
	--output text
```

This role ARN can be passed to an `aws cloudformation create-stack` invocation
as a value for the `--role-arn` flag.

## Related content

To gain a better understanding of how Elastic CI Stack for AWS works and how to use it most effectively and securely, check out the following resources:

- [Running Buildkite Agent on AWS](/docs/agent/v3/aws)
- [GitHub repo for Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws)
- [Configuration parameters for Elastic CI Stack for AWS](/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/configuration-parameters)
- [Using AWS Secrets Manager](/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/security#using-aws-secrets-manager-in-the-elastic-ci-stack-for-aws)
