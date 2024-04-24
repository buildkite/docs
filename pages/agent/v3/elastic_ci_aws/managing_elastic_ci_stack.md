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
1. Update the pipeline's [`environment` hook](/docs/agent/v3/hooks#job-lifecycle-hooks) in your secrets bucket to perform a `docker login`
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

To update your stack to the latest version, use CloudFormation's stack update
tools with one of the URLs from the
[Elastic CI Stack for AWS releases](#elastic-ci-stack-for-aws-releases) section.

To preview changes to your stack before executing them, use a
[CloudFormation Change Set](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-changesets.html).

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

## CloudWatch metrics

Metrics are calculated every minute from the Buildkite API using a Lambda function.

<%= image "cloudwatch-metrics.png", alt: 'CloudWatch metrics' %>

You can view the stack's metrics under **Custom Namespaces** > **Buildkite** within CloudWatch.

## Reading instance and agent logs

Each instance streams file system logs such as `/var/log/messages` and `/var/log/docker` into namespaced AWS log groups. A full list of files and log groups can be found in the relevant [Linux](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/-/packer/linux/conf/cloudwatch-agent/config.json) CloudWatch agent `config.json` file.

Within each stream the logs are grouped by instance ID.

To debug an agent:

1. Find the instance ID from the agent in Buildkite
2. Go to your **CloudWatch Logs Dashboard**
3. Choose the desired log group
4. Search for the instance ID in the list of log streams

## Customizing instances with a bootstrap script

You can customize your stack's instances by using the `BootstrapScriptUrl` stack parameter to run a Bash script on instance boot. To set up a bootstrap script,  set the `BootstrapScriptUrl` parameter to one of the following:

* An S3 bucket containing the script, for example `s3://my_bucket_name/my_bootstrap.sh`
* A URL such as `https://www.example.com/config/bootstrap.sh`
* A local file name `file:///usr/local/bin/my_bootstrap.sh` (this is particularly useful if you're customizing the AMI and are able to include a bootstrap script that way).

If the file is private, you also need to create an IAM policy to allow the instances to read the file, for example:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": ["arn\:aws\:s3:::my_bucket_name/my_bootstrap.sh"]

    }
  ]
}
```

After creating the policy, you must specify the policy's ARN in the `ManagedPolicyARNs` stack parameter.

## Health monitoring

You can assess and monitor health and proper function of the Elastic CI Stack for AWS using a combination of the following tools:

* **Auto Scaling group Activity logs** found on the EC2 Auto Scaling dashboard. They display the actions taken by the Auto Scaling group (failures, scale in/out, etc.).

* **CloudWatch Metrics** the Buildkite namespace contains `ScheduledJobsCount`, `RunningJobsCount`, and `WaitingJobsCount` measurements for the Buildkite Queue your Elastic CI Stack for AWS was configured to poll. These numbers are fed to the Auto Scaling group by the scaling Lambda.

* **CloudWatch Logs** log streams for the Buildkite agent and EC2 Instance system console.
