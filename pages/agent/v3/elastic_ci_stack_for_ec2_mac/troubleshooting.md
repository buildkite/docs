# Troubleshooting

The following are solutions to problems some users face when using the [Elastic CI Stack for AWS Mac](https://github.com/buildkite/elastic-mac-for-aws).

## My Auto Scaling group doesn't launch any instances

* If your Auto Scaling group does not launch any instances, open the EC2 Console
dashboard and *Auto Scaling Groups* from the side bar. Find your Auto Scaling
group and open the *Activity* tab. The *Activity history* table will list the
scaling actions that have occurred and any errors that resulted.

* There may be a shortage of `mac1.metal` instances in the region, or Availability
Zones of your VPC subnets. This error is likely to be a temporary one, wait for your
Auto Scaling group to attempt to scale out again and see if the error persists.

* Your launch template's AMI may not have been associated with a Customer
Managed License in AWS License Manager. Ensure you [associate your AMI](/docs/agent/v3/elastic-ci-stack-for-ec2-mac/autoscaling-mac-metal#step-3-associate-your-ami-with-a-customer-managed-license-in-aws-license-manager)
and any new AMIs with a Customer managed license. Ensure the License
configuration has a *License type* of `Cores`.

## My instances don't start the `buildkite-agent`

Ensure your AMI has been [configured to auto-login as the `ec2-user`](/docs/agent/v3/elastic-ci-stack-for-ec2-mac/autoscaling-mac-metal#step-2-build-an-ami)
in the GUI.

## How do I enable use of Xcode and the iOS simulator?

To allow your pipelines to use Xcode and the iOS simulator the Buildkite Agent launchd job configuration requires an `Aqua` session type.

## What user does the agent run as?

The Buildkite agent runs as `ec2-user`.

