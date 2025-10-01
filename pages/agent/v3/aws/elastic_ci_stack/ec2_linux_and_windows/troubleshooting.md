# Troubleshooting the Elastic CI Stack for AWS

<!-- alex ignore easy -->

Infrastructure as code isn't always easy to troubleshoot, but here are some ways to debug exactly what's going on inside the [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws), and some solutions for specific situations.

## Using CloudWatch Logs

Elastic CI Stack for AWS sends logs to various CloudWatch log streams:

* Buildkite Agent logs get sent to the `buildkite/buildkite-agent/{instance_id}` log stream. If there are problems within the agent itself, the agent logs should help diagnose.
* Output from an Elastic CI Stack for AWS instance's startup script ([Linux](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/-/packer/linux/stack/conf/bin/bk-install-elastic-stack.sh) or [Windows](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/-/packer/windows/conf/bin/bk-install-elastic-stack.ps1)) get sent to the `/buildkite/elastic-stack/{instance_id}` log stream. If an instance is failing to launch cleanly, it's often a problem with the startup script, making this log stream especially useful for debugging problems with the Elastic CI Stack for AWS.

Additionally, on Linux instances only:

* Docker Daemon logs get sent to the `/buildkite/docker-daemon/{instance_id}` log stream. If docker is having a bad day on your machine, look here.
* Output from the cloud init process, up until the startup script is initialised, is sent to `/buildkite/cloud-init/output/{instance_id}`. Logs from this stream can be useful for inspecting what environment variables were sent to the startup script.

On Windows instances only:

* Logs from the UserData execution process (similar to the `/buildkite/cloud-init/output` group above) are sent to the `/buildkite/EC2Launch/UserdataExecution/{instance_id}` log stream.

There are a couple of other log groups that the Elastic CI Stack for AWS sends logs to, but their use cases are pretty specific. For a full accounting of what logs are sent to CloudWatch, see the config for [Linux](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/-/packer/linux/conf/cloudwatch-agent/config.json) and [Windows](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/-/packer/windows/conf/cloudwatch-agent/amazon-cloudwatch-agent.json).

## Collecting logs using script

An alternative method to collect the logs is to use the [`log-collector`](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/main/utils/log-collector) script in the [`utils`](https://github.com/buildkite/elastic-ci-stack-for-aws/tree/main/utils) folder of the [Elastic CI Stack for AWS repository](https://github.com/buildkite/elastic-ci-stack-for-aws).

The script collects CloudWatch Logs for the Instance, Lambda function, and AutoScaling activity, then packages them in a zip archive that you can email to Support for help at [support@buildkite.com](mailto:support@buildkite.com).

## Debugging bootstrap script failures

When you've configured a custom `BootstrapScriptUrl` parameter but instances aren't working correctly, use the following suggestions to help identify and resolve any issues.

### Verify the basics

* Test whether `BootstrapScriptUrl` is accessible: `curl -f "$BOOTSTRAP_URL" -o bootstrap_script.sh`.
* Syntax-check the script: `bash -n bootstrap_script.sh`.
* Check the Auto Scaling group activity for launch failures:

```bash
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name your-buildkite-asg \
  --max-items 10
```

### Examine CloudWatch Logs

* `/buildkite/elastic-stack/{instance_id}` - check for the "Running bootstrap script from" message.
* `/buildkite/cloud-init/output/{instance_id}` - check the environment setup.
* `/buildkite/buildkite-agent/{instance_id}` - verify the agent start.

### Collect detailed information

For active instances:

```bash
aws ssm send-command \
  --instance-ids i-1234567890abcdef0 \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["cat /var/log/elastic-stack-bootstrap-status", "tail -50 /var/log/elastic-stack.log"]'
```

For terminated instances:

```bash
aws ec2 get-console-output --instance-id i-1234567890abcdef0
```

Use the [`log-collector`](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/main/utils/log-collector) script:

```bash
./utils/log-collector.sh -s your-stack-name -r your-region
```

## Accessing Elastic CI Stack for AWS instances directly

Sometimes, looking at the logs isn't enough to figure out what's going on in your instances. In these cases, it can be useful to access the shell on the instance directly:

* If your Elastic CI Stack for AWS has been configured to allow SSH access (using the `AuthorizedUsersUrl` parameter), run `ssh <some instance id>` in your terminal.
* If SSH access isn't available, you can still use AWS SSM to remotely access the instance by finding the instance ID, and then running `aws ssm start-session --target <instance id>`.

## Auto Scaling group fails to boot instances

Resource shortage can cause this issue. See the Auto Scaling group's Activity log for diagnostics.

To fix this issue, change or add more instance types to the `InstanceTypes` template parameter. If 100% of your existing instances are Spot Instances, switch some of them to On-Demand Instances by setting `OnDemandPercentage` parameter to a value above zero.

## Instances are abruptly terminated

This can happen when using Spot Instances. AWS EC2 sends a notification to a spot instance 2 minutes prior to termination. The agent intercepts that notification and attempts to gracefully shut down. If the instance does not shut down gracefully in that time, it is terminated.

To identify if your agent instance was terminated, you can inspect the `/buildkite/lifecycled` CloudWatch log group for the instance. The example below shows the log line indicating that the instance was sent the spot termination notice.

```
| 2023-07-31 19:19:23.432 | level=info msg="Received termination notice" instanceId=i-abcd notice=spot | i-abcd | 444793955923:/buildkite/lifecycled |
```

If all your existing instances are Spot Instances, switch some of them to On-Demand Instances by setting the `OnDemandPercentage` parameter to a value above zero.

For better resilience, you can use step retries to automatically retry a job that has failed due to spot instance reclamation. See [Automatic retry attributes](/docs/pipelines/configure/step-types/command-step#retry-attributes-automatic-retry-attributes) for more information.

## Stacks over-provision agents

If you have multiple stacks, check that they listen to unique queues—determined by the `BuildkiteQueue` parameter. Each Elastic CI Stack for AWS you launch through CloudFormation should have a unique value for this parameter. Otherwise, each scales out independently to service all the jobs on the queue, but the jobs will be distributed amongst them. This will mean that your stacks are over-provisioned.

This could also happen if you have agents that are not part of an Elastic CI Stack for AWS [started with a tag](/docs/agent/v3/cli-start#tags) of the form `queue=<name of queue>`. Any agents started like this will compete with a stack for jobs, but the stack will scale out as if this competition did not exist.

## Instances fail to boot Buildkite Agent

See the Auto Scaling group's Activity logs and CloudWatch Logs for the booting instances to determine the issue. Observe where in the `UserData` script the boot is failing. Identify what resource is failing when the instances are attempting to use it, and fix that issue.

## Instances fail jobs

Successfully booted instances can fail jobs for numerous reasons. A frequent source of issues is their disk filling up before the hourly cron job fixes it or terminates them.

An instance with a full disk can be causing jobs to fail. If such instance is not being replaced automatically — for example, because of a stack with the `MinSize` parameter greater than zero, you can manually terminate the instance using the EC2 Dashboard.

## Permission errors when running Docker images with volume mounts

The Docker daemon is configured by default to run containers in a [username namespace](https://docs.docker.com/engine/security/userns-remap/). This will map the `root:root` user and group inside the container to the `buildkite-agent:docker` on the host. You can disable this using the stack parameter `EnableDockerUserNamespaceRemap`.
