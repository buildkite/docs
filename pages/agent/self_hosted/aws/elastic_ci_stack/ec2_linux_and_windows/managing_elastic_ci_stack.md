# Managing the Elastic CI Stack for AWS

This page describes common tasks for managing the Elastic CI Stack for AWS.

## Docker registry support

If you want to push or pull from registries such as [Docker Hub](https://hub.docker.com/) or [Quay](https://quay.io/) you can use the `environment` hook in your secrets bucket to export the following environment variables:

* `DOCKER_LOGIN_USER="the-user-name"`
* `DOCKER_LOGIN_PASSWORD="the-password"`
* `DOCKER_LOGIN_SERVER=""` - optional. By default it logs in to Docker Hub

Setting these performs a `docker login` before each pipeline step runs, allowing you to `docker push` to them from within your build scripts.

If you use [Amazon ECR](https://aws.amazon.com/ecr/) you can set the `ECRAccessPolicy` parameter for the stack to either `readonly`, `poweruser`, or `full` depending on the [access level](http://docs.aws.amazon.com/AmazonECR/latest/userguide/ecr_managed_policies.html) you want your builds to have.

You can disable this in individual pipelines by setting `AWS_ECR_LOGIN=false`.

If you want to log in to an ECR server on another AWS account, you can set `AWS_ECR_LOGIN_REGISTRY_IDS="id1,id2,id3"`.

The AWS ECR options are powered by an embedded version of the [ECR plugin](https://github.com/buildkite-plugins/ecr-buildkite-plugin), so if you require options that aren't listed here, you can disable the embedded version as above and call the plugin directly. See [its README](https://github.com/buildkite-plugins/ecr-buildkite-plugin) for more examples (requires Agent v3.x).

## Optimizing for slow Docker builds

For large legacy applications the Docker build process might take a long time on new instances. For these cases it's recommended to create an optimized "builder" stack which doesn't scale down, keeps a warm docker cache and is responsible for building and pushing the application to Docker Hub before running the parallel build jobs across your normal CI stack.

An example of how to set this up:

1. Create a Docker Hub repository for pushing images to
1. Update the pipeline's [`environment` hook](/docs/agent/hooks#job-lifecycle-hooks) in your secrets bucket to perform a `docker login`
1. Create a builder stack with its own queue (for example, `elastic-builders`)

Here is an example build pipeline based on a production Rails application:

```yaml
steps:
  - name: "\:docker\: :package:"
    plugins:
      docker-compose:
        build: app
        image-repository: my-docker-org/my-repo
    agents:
      queue: elastic-builders
  - wait
  - name: ":hammer:"
    command: ".buildkite/steps/tests"
    plugins:
      docker-compose:
        run: app
    agents:
      queue: elastic
    parallelism: 75
```

## Multiple instances

If you need different instances sizes and scaling characteristics for different pipelines, you can create multiple stacks. Each can run on a different [Agent queue](/docs/agent/queues), with its own configuration, or even in a different AWS account.

Examples:

* A `docker-builders` stack that provides always-on workers with hot Docker caches (see [Optimizing for slow Docker builds](#optimizing-for-slow-docker-builds))
* A `pipeline-uploaders` stack with tiny, always-on instances for lightning fast `buildkite-agent pipeline upload` jobs.
* A `deploy` stack with added credentials and permissions specifically for deployment.

## Autoscaling

If you configure `MinSize` < `MaxSize` in your AWS autoscaling configuration, the stack automatically scales up and down based on the number of scheduled jobs.

This means you can scale down to zero when idle, which means you can use larger instances for the same cost.

Metrics are collected with a Lambda function, polling every 10 seconds based on the queue the stack is configured with. The autoscaler monitors only one queue, and the monitoring drives the scaling of the stack. You should only use one Elastic CI Stack for AWS per queue to avoid scaling up redundant agents. If you target the same queue with multiple stacks, each stack will independently scale up additional agents as if it were the only stack running, leading to over-provisioning.

## Terminating the instance after the job is complete

You can set `BuildkiteTerminateInstanceAfterJob` to `true` to force the instance to terminate after it completes a job. Setting this value to `true` tells the stack to enable `disconnect-after-job` in the `buildkite-agent.cfg` file.

It is best to find an alternative to this setting if at all possible. The turn around time for replacing these instances is currently slow (5-10 minutes depending on other stack configuration settings). If you need single use jobs, we suggest looking at our container plugins like `docker`, `docker-compose`, and `ecs`, all which can be found [here](https://buildkite.com/plugins).

## Elastic CI Stack for AWS releases

It is recommended to run the latest stable release of the CloudFormation
template, available from `https://s3.amazonaws.com/buildkite-aws-stack/aws-stack.yml`,
or a specific release available from the [releases page](https://github.com/buildkite/elastic-ci-stack-for-aws/releases).

The latest stable release can be deployed to any of our supported AWS Regions.

The most recent build of the CloudFormation stack is published to:

```text
https://s3.amazonaws.com/buildkite-aws-stack/main/aws-stack.yml
```

With a version for each commit also published at:

```text
https://s3.amazonaws.com/buildkite-aws-stack/main/${COMMIT}.aws-stack.yml
```

>📘 Versions prior to v6.0.0
> Per-commit builds for versions prior to v6.0.0, in particular for commits that are ancestors of [419f271](https://github.com/buildkite/elastic-ci-stack-for-aws/commit/419f271b54802c4c8301730bc35b34ed379074c4), were published to:
>
> ```text
> https://s3.amazonaws.com/buildkite-aws-stack/master/${COMMIT}.aws-stack.yml
> ```

<!-- vale off -->

A main branch release can also be deployed to any of our supported AWS
Regions.

<!-- vale on -->

GitHub branches are also automatically published to a per-branch URL
`https://s3.amazonaws.com/buildkite-aws-stack/${BRANCH}/aws-stack.yml`.

Branch releases can only be deployed to `us-east-1`.

## Updating your stack

Template URLs follow this pattern for a specific version:

```
https://s3.amazonaws.com/buildkite-aws-stack/VERSION/aws-stack.yml
```

Before upgrading, export your current stack parameters so you have a record of every value:

```bash
aws cloudformation describe-stacks \
  --stack-name YOUR_STACK_NAME \
  --query 'Stacks[0].Parameters' \
  --output json > stack-parameters-backup.json
```

Sensitive parameters such as `BuildkiteAgentToken` appear as `****` in this output. The values are preserved in the stack.

Also check the [CHANGELOG](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/main/CHANGELOG.md) for all versions between your current version and the target, paying attention to any parameter renames and removals.

### Upgrade using the AWS Console

1. Open the [CloudFormation console](https://console.aws.amazon.com/cloudformation) and select your stack.
2. Click **Update stack** and choose **Create a change set** from the dropdown. Avoid **Make a direct update** — it applies changes immediately without a preview.
3. Select **Replace existing template**, choose **Amazon S3 URL**, and paste the template URL for your target version. Click **Next**.
4. The parameters screen shows current values pre-filled as **Use existing value**. If you are upgrading from v5, review for renamed parameters before proceeding. Click **Next**.
5. On **Configure change set options**, scroll to **Capabilities and transforms** and check all three acknowledgement boxes. These are unchecked by default and the change set will fail if they are left unchecked. Click **Next**.
6. Click **Create change set**. Once ready, the **Resource changes** tab shows which resources will be modified.
7. Click **Execute change set** to apply the upgrade.

### Upgrade using the AWS CLI

To upgrade from the CLI, use `update-stack` with the target template URL and `UsePreviousValue=true` for each parameter:

```bash
PARAMS=$(aws cloudformation describe-stacks \
  --stack-name YOUR_STACK_NAME \
  --query 'Stacks[0].Parameters[*].ParameterKey' \
  --output text | tr '\t' '\n' | \
  awk '{print "ParameterKey="$1",UsePreviousValue=true"}' | \
  tr '\n' ' ')

aws cloudformation update-stack \
  --stack-name YOUR_STACK_NAME \
  --template-url "https://s3.amazonaws.com/buildkite-aws-stack/TARGET_VERSION/aws-stack.yml" \
  --parameters $PARAMS \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND
```

To wait for the update to complete:

```bash
aws cloudformation wait stack-update-complete --stack-name YOUR_STACK_NAME
```

To preview changes before applying them, create a change set without executing it:

```bash
aws cloudformation create-change-set \
  --stack-name YOUR_STACK_NAME \
  --change-set-name preview-upgrade \
  --template-url "https://s3.amazonaws.com/buildkite-aws-stack/TARGET_VERSION/aws-stack.yml" \
  --parameters $PARAMS \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND
```

Once the change set reaches `CREATE_COMPLETE`, view the planned changes in the CloudFormation console under the stack's **Change sets** tab before deciding whether to execute it.

You can also use `aws cloudformation deploy`, but the Elastic CI Stack template (~127 KB) exceeds CloudFormation's 51,200-byte local file size limit, so you must download the template locally and provide an S3 bucket:

```bash
curl -s "https://s3.amazonaws.com/buildkite-aws-stack/TARGET_VERSION/aws-stack.yml" \
  -o aws-stack.yml

aws cloudformation deploy \
  --stack-name YOUR_STACK_NAME \
  --template-file aws-stack.yml \
  --s3-bucket YOUR_S3_BUCKET \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND
```

Common errors with `deploy`:

| Error | Cause | Fix |
|---|---|---|
| `Templates with a size greater than 51,200 bytes must be deployed via an S3 Bucket` | `--s3-bucket` not provided | Add `--s3-bucket YOUR_BUCKET` |
| `the following arguments are required: --template-file` | `--template-url` used instead of `--template-file` | Download the template locally and use `--template-file` |
| `Unknown options: --change-set-name` | `--change-set-name` is not a valid `deploy` flag | Use `aws cloudformation create-change-set` for named change sets |

### Upgrade strategy

When a stack update requires changes to the Auto Scaling group, CloudFormation replaces the entire ASG rather than updating instances in place. It creates a new ASG, waits for it to pass health checks, and then terminates the old one. There is no rolling instance update option.

### Upgrading from v5 to v6

v6.0.0 renamed or removed several parameters. Passing an old v5 parameter name to a v6 template causes an immediate `ValidationError` and the update is rejected without making any changes.

| v5 parameter | v6 parameter | Notes |
|---|---|---|
| `InstanceType` | `InstanceTypes` | Now accepts a comma-separated list |
| `ManagedPolicyARN` | `ManagedPolicyARNs` | Now accepts a comma-separated list |
| `SecurityGroupId` | `SecurityGroupIds` | Now accepts a comma-separated list |
| `EnableAgentGitMirrorsExperiment` | `BuildkiteAgentEnableGitMirrors` | |
| `SpotPrice` | Removed | Spot pricing is now handled automatically |

Update your stack configuration and any upgrade scripts to use the new names before targeting a v6 template.

**`BuildkiteAgentScalerVersion`**

In v5, `BuildkiteAgentScalerVersion` may hold an early version such as `1.3.2`. If this value is carried forward into a v6 update, the change set appears to succeed but fails during execution with:

```
Parameters: [EventSchedulePeriod, MinPollInterval] do not exist in the template
```

This error comes from the nested scaler sub-stack and only surfaces when the change set executes. The stack automatically rolls back to `UPDATE_ROLLBACK_COMPLETE`.

To avoid this, omit `BuildkiteAgentScalerVersion` from the `update-stack` parameter list. When the parameter is not passed, CloudFormation uses the template default.

`BuildkiteAgentScalerVersion` was removed in v6.52.0. Remove it from your configuration before targeting v6.52.0 or later — passing it causes an immediate `ValidationError`.

### Pause Auto Scaling

The CloudFormation template supports zero downtime deployment when updating.
If you are concerned about causing a service interruption during the template
update, use the AWS Console to temporarily pause auto scaling.

Open the CloudFormation console and select your stack instance. Using the
Resources tab, find the `AutoscalingFunction`. Use the Lambda console to find
the function's Triggers and Disable the trigger rule. Next, find the stack's
`AgentAutoScaleGroup` and set the `DesiredCount` to `0`. Once the remaining
instances have terminated, deploy the updated stack and undo the manual
changes to resume instance auto scaling.

### Rolling back to a previous version

To roll back, use `update-stack` with the earlier version's template URL. Build the `$PARAMS` variable the same way as for an upgrade (see [Upgrade using the AWS CLI](#upgrade-using-the-aws-cli)), then run:

```bash
aws cloudformation update-stack \
  --stack-name YOUR_STACK_NAME \
  --template-url "https://s3.amazonaws.com/buildkite-aws-stack/PREVIOUS_VERSION/aws-stack.yml" \
  --parameters $PARAMS \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND
```

CloudFormation uses the same update process as an upgrade.

### Troubleshooting stack updates

**Stack is in `UPDATE_ROLLBACK_COMPLETE`**

This status means a previous update failed and the stack rolled back successfully. The stack is fully functional — fix the root cause and submit a new update.

**`Parameters: [X] do not exist in the template`**

You are passing a parameter name that does not exist in the target template. Check whether it is a renamed v5 parameter (see the [Upgrading from v5 to v6](#upgrading-from-v5-to-v6) table above) or `BuildkiteAgentScalerVersion` being passed to a v6.52.0+ template. The update is rejected before any changes are made.

**`Templates with a size greater than 51,200 bytes must be deployed via an S3 Bucket`**

You are using `aws cloudformation deploy` without `--s3-bucket`. Add `--s3-bucket YOUR_BUCKET` to the command.

## Using custom IAM roles

You can use an existing IAM role instead of letting the stack create one. This is useful for sharing a role across multiple stacks, or managing IAM roles outside of the stack.

To use a custom role, pass a pre-existing role's ARN to the Terraform variable `instance_role_arn`, or the CloudFormation Parameter `InstanceRoleARN`.

For the Agent Scaler Lambda, the ASG Process Suspender Lambda, or the Stop Buildkite agents Lambda, you can also provide custom roles using the Terraform variables `scaler_lambda_role_arn`, `asg_process_suspender_role_arn`, and `stop_buildkite_agents_role_arn`. Custom Lambda roles are currently only supported when using Terraform.

### IAM policy requirements

As a baseline, a custom IAM role needs the same permissions the stack would normally create. At minimum, Buildkite agents need an access to:

* SSM for agent tokens and instance management
* Auto Scaling for instance lifecycle management
* AWS CloudWatch for logs and metrics
* AWS CloudFormation for stack resource information (AWS CloudFormation-specific)
* EC2 for instance metadata

The following additional policies may also apply if using additional features:

* Amazon S3 access for AWS S3 secrets and custom artifact buckets
* KMS for encrypted parameters or pipeline signing
* ECR for accessing container images

### IAM policy examples

To get started, we've included the policies that are created using the AWS CloudFormation and Terraform stacks.

Some of the resources are generated dynamically when running either of the infrastructure-as-code solutions, so you will need to update them accordingly.

#### Core agent policy

The below policy set is the minimum requirement for the Elastic CI Stack for AWS:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingInstances",
                "cloudwatch:PutMetricData",
                "cloudformation:DescribeStackResource",
                "ec2:DescribeTags"
            ],
            "Resource": "*"
        },
        {
            "Sid": "TerminateInstance",
            "Effect": "Allow",
            "Action": [
                "autoscaling:SetInstanceHealth",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": "arn\:aws\:autoscaling:*:*:autoScalingGroup:*:autoScalingGroupName/YOUR_STACK_NAME-AgentAutoScaleGroup-*"
        },
        {
            "Sid": "Logging",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutRetentionPolicy"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Ssm",
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeInstanceProperties",
                "ssm:ListAssociations",
                "ssm:PutInventory",
                "ssm:UpdateInstanceInformation",
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel",
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ssm:GetParameter",
            "Resource": "arn\:aws\:ssm:*:*:parameter/YOUR_AGENT_TOKEN_PARAMETER_PATH"
        }
    ]
}
```

#### S3 secrets bucket

When the [S3 secrets bucket](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security#s3-secrets-bucket) is enabled, the following statement is required:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "SecretsBucket",
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "arn\:aws\:s3:::YOUR_SECRETS_BUCKET",
                "arn\:aws\:s3:::YOUR_SECRETS_BUCKET/*"
            ]
        }
    ]
}
```

#### S3 artifacts bucket

When using the custom Artifacts Storage in S3, the following statement is required:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ArtifactsBucket",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:GetObjectVersion",
                "s3:GetObjectVersionAcl",
                "s3:ListBucket",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:PutObjectVersionAcl"
            ],
            "Resource": [
                "arn\:aws\:s3:::YOUR_ARTIFACTS_BUCKET",
                "arn\:aws\:s3:::YOUR_ARTIFACTS_BUCKET/*"
            ]
        }
    ]
}
```

#### KMS

When using KMS keys for signed pipelines or encrypted parameters, the following statement is required:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt"
            ],
            "Resource": "arn\:aws\:kms:*:*:key/YOUR_KMS_KEY_ID"
        }
    ]
}
```

### Lambda roles

When using custom IAM roles for the Agent Scaler Lambda, the ASG Process Suspender Lambda, or the Stop Buildkite agents Lambda, the following additional permissions are required beyond the core agent policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ScalerLambdaAutoScaling",
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeScalingActivities",
                "autoscaling:SetDesiredCapacity"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ScalerLambdaSSMToken",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter"
            ],
            "Resource": "arn\:aws\:ssm:*:*:parameter/YOUR_AGENT_TOKEN_PARAMETER_PATH"
        },
        {
            "Sid": "AsgProcessSuspender",
            "Effect": "Allow",
            "Action": [
                "autoscaling:SuspendProcesses"
            ],
            "Resource": "*"
        },
        {
            "Sid": "StopBuildkiteAgentsDescribeAsg",
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups"
            ],
            "Resource": "*"
        },
        {
            "Sid": "StopBuildkiteAgentsModifyAsg",
            "Effect": "Allow",
            "Action": [
                "autoscaling:UpdateAutoScalingGroup"
            ],
            "Resource": "arn\:aws\:autoscaling:*:*:autoScalingGroup:*:autoScalingGroupName/YOUR_STACK_NAME-*"
        },
        {
            "Sid": "StopBuildkiteAgentsSSMDocument",
            "Effect": "Allow",
            "Action": [
                "ssm:SendCommand"
            ],
            "Resource": "arn\:aws\:ssm:*::document/AWS-RunShellScript"
        },
        {
            "Sid": "StopBuildkiteAgentsSSMInstances",
            "Effect": "Allow",
            "Action": [
                "ssm:SendCommand"
            ],
            "Resource": "arn\:aws\:ec2:*:*:instance/*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/aws:autoscaling:groupName": "YOUR_ASG_NAME"
                }
            }
        },
        {
            "Sid": "LambdaLogging",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn\:aws\:logs:*:*:log-group:/aws/lambda/YOUR_STACK_NAME-*"
        }
    ]
}
```

When using Elastic CI mode for the Scaler Lambda, the following additional permissions are also required:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ElasticCIModeEC2",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ElasticCIModeSSM",
            "Effect": "Allow",
            "Action": [
                "ssm:SendCommand",
                "ssm:GetCommandInvocation"
            ],
            "Resource": [
                "arn\:aws\:ssm:*::document/AWS-RunShellScript",
                "arn\:aws\:ec2:*:*:instance/*"
            ]
        },
        {
            "Sid": "ElasticCIModeTerminate",
            "Effect": "Allow",
            "Action": [
                "ec2:TerminateInstances"
            ],
            "Resource": "arn\:aws\:ec2:*:*:instance/*",
            "Condition": {
                "StringEquals": {
                    "ec2:ResourceTag/aws:autoscaling:groupName": "YOUR_ASG_NAME"
                }
            }
        }
    ]
}
```

#### Trust policy

The following is the trust policy that is created for all the Elastic CI Stack for AWS instance roles:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "autoscaling.amazonaws.com",
                    "ec2.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}

```

When using custom IAM roles for the Agent Scaler Lambda, the ASG Process Suspender Lambda, or the Stop Buildkite agents Lambda, the trust policy must include `lambda.amazonaws.com` in your Trust Policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "autoscaling.amazonaws.com",
                    "ec2.amazonaws.com",
                    "lambda.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

#### ECR managed policies

For ECR access, the most straightforward approach is to utilize one of the pre-existing roles provided by AWS:

* `arn\:aws\:iam:\:aws\:policy/AmazonEC2ContainerRegistryReadOnly`
* `arn\:aws\:iam:\:aws\:policy/AmazonEC2ContainerRegistryPowerUser`
* `arn\:aws\:iam:\:aws\:policy/AmazonEC2ContainerRegistryFullAccess`

### CloudFormation configuration

When creating a stack with AWS CloudFormation, a role can be passed as an ARN, for example:

```yaml
Parameters:
  InstanceRoleARN: "arn\:aws\:iam::123456789012:role/MyBuildkiteRole"
```

In AWS CloudFormation, IAM roles are limited to a maximum of 10 paths, for example:

```yaml
Parameters:
  InstanceRoleARN: "arn\:aws\:iam::123456789012:role/a/b/c/d/e/f/g/h/i/j/MyBuildkiteRole"
```

### Terraform configuration

When using Terraform, there is no limit on the number of paths that can be used within an ARN. You can pass the value of your IAM Role's ARN to `var.instance_role_arn` and get started.

For Lambda functions, you can provide custom role Amazon Resource Names (ARNs) in `terraform.tfvars`:

```hcl
instance_role_arn                  = "arn\:aws\:iam::123456789012:role/MyBuildkiteRole"
scaler_lambda_role_arn             = "arn\:aws\:iam::123456789012:role/MyBuildkiteRole"
asg_process_suspender_role_arn     = "arn\:aws\:iam::123456789012:role/MyBuildkiteRole"
stop_buildkite_agents_role_arn     = "arn\:aws\:iam::123456789012:role/MyBuildkiteRole"
```

You can use the same role for all resources, or provide different roles for each Lambda function and the EC2 instances.

## CloudWatch metrics

Metrics are calculated every minute from the Buildkite API using a Lambda function.

<%= image "cloudwatch-metrics.png", alt: 'CloudWatch metrics' %>

You can view the stack's metrics under **Custom Namespaces** > **Buildkite** within CloudWatch.

## Reading instance and agent logs

Each instance streams file system logs such as `/var/log/messages` and `/var/log/docker` into namespaced AWS log groups. A full list of files and log groups can be found in the relevant [Linux](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/main/packer/linux/stack/conf/cloudwatch-agent/amazon-cloudwatch-agent.json) CloudWatch agent `config.json` file.

Within each stream the logs are grouped by instance ID.

To debug an agent:

1. Find the instance ID from the agent in Buildkite
2. Go to your **CloudWatch Logs Dashboard**
3. Choose the desired log group
4. Search for the instance ID in the list of log streams

## Customizing instances with a bootstrap script

You can customize your stack's instances by using the `BootstrapScriptUrl` stack parameter to run a script on instance boot. The script executes before the Buildkite agent starts and runs with elevated privileges, making it useful for installing software, configuring settings, or performing other customizations.

The stack parameter accepts a URI that specifies the location and retrieval method for your bootstrap script. Supported URI schemes include:

* S3 object URI (for example, `s3://my-bucket-name/my-bootstrap.sh`) retrieves the script from an S3 bucket using the AWS S3 API. The instance's IAM role must have `s3:GetObject` permission for the specified object.
* HTTPS URL (for example, `https://www.example.com/config/bootstrap.sh`) downloads the script using `curl`command on Linux or `Invoke-WebRequest` on Windows. The URL must be publicly accessible.
* Local file path (for example, `file:///usr/local/bin/my-bootstrap.sh`) references a script already present on the instance's filesystem. This is particularly useful when customizing the AMI to include bootstrap scripts.

For private S3 objects, you need to create an IAM policy to allow the instances to read the file. The policy should include:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": ["arn\:aws\:s3:::my-bucket-name/my-bootstrap.sh"]

    }
  ]
}
```

After creating the policy, you must specify the policy's ARN in the `ManagedPolicyARNs` stack parameter.

## Configuring agent environment variables

You can configure environment variables for the Buildkite agent process by using the `AgentEnvFileUrl` stack parameter. These environment variables apply to the agent process itself and are useful for configuring proxy settings, debugging options, or other agent-specific configuration. These variables are _not_ the same as build environment variables, which should be configured in your pipeline.

The parameter accepts a URI that specifies the location and retrieval method for an environment file. Supported URI schemes include:

* S3 object URI (for example, `s3://my-bucket-name/agent.env`) retrieves the environment file from an S3 bucket using the AWS S3 API. The instance's IAM role must have `s3:GetObject` permission for the specified object.
* SSM parameter path (for example, `ssm:/buildkite/agent/config`) retrieves environment variables from AWS Systems Manager Parameter Store. The instance's IAM role must have `ssm:GetParameter` permission. All parameters under the specified path are retrieved recursively with decryption enabled for `SecureString` parameters. The last segment of each parameter path becomes the environment variable name in uppercase (for example, `/buildkite/agent/config/http_proxy` becomes `HTTP_PROXY`).
* HTTPS URL (for example, `https://www.example.com/config/agent.env`) downloads the environment file using `curl` command on Linux or `Invoke-WebRequest` on Windows. The URL must be publicly accessible.
* Local file path (for example, `file:///etc/buildkite/agent.env`) references an environment file already present on the instance's filesystem. This is useful when customizing the AMI to include environment configuration.

The environment file must contain variables in the format `KEY="value"`, with one variable per line.

For private S3 objects, you must create an IAM policy to allow the instances to read the file. For SSM parameters, the IAM policy should include `ssm:GetParameter` permission for the specified parameter path. After creating the policy, you must specify the policy's ARN in the `ManagedPolicyARNs` stack parameter.

## Health monitoring

You can assess and monitor health and proper function of the Elastic CI Stack for AWS using a combination of the following tools:

* **Auto Scaling group Activity logs** found on the EC2 Auto Scaling dashboard. They display the actions taken by the Auto Scaling group (failures, scale in/out, etc.).

* **CloudWatch Metrics** the Buildkite namespace contains `ScheduledJobsCount`, `RunningJobsCount`, and `WaitingJobsCount` measurements for the Buildkite Queue your Elastic CI Stack for AWS was configured to poll. These numbers are fed to the Auto Scaling group by the scaling Lambda.

* **CloudWatch Logs** log streams for the Buildkite agent and EC2 Instance system console.
