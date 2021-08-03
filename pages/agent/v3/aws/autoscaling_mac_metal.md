# Auto Scaling mac1.metal instances

We have built a [CloudFormation template](https://github.com/buildkite/elastic-mac-for-aws)
that configures an Auto Scaling group, Launch Template, and Host Resource Group
suitable for maintaining a pool of mac1.metal instance based Buildkite Agents.
This can be used to build Xcode Project based software projects using Buildkite.

As you must prepare and supply your own AMI for this template, macOS support has
not been incorporated into the Elastic CI Stack for AWS.

Using an Auto Scaling Group for your instances enables automatic instance
replacement when hardware failures occur, freeing you from the responsibility to
manually reprovision instances.

## Prerequisites

Familiarity with AWS VPCs, and EC2 AMIs is required. You should also have
familiarity with the macOS GUI.

## Choose a VPC Layout

Before deploying this template you must choose a VPC subnet layout for your
instances and which VPC security groups you want them to belong to.

Depending on your threat model, you may find running these instances in you AWS
account’s default VPC public subnets with public IP addresses suitable.
Otherwise, you may wish to explore options like separate Public/Private subnets
and a NAT Gateway, and using a Bastion or VPN to access the instances over SSH
and VNC.

## Build an AMI

Set up a password for the ec2-user so you can connect using VNC.

Using screen sharing, set up auto-login for the ec2-user. Disable auto screen
lock.

Install Xcode and Xcode Command Line Utilities. Launch them once so you are
presented with the EULA prompt.

You do not need to install the buildkite-agent, this will be done automatically
by the Launch Template `UserData` script.

Create an AMI from the instance using the AWS Console.

## Associate your AMI with a Customer managed license in AWS License Manager

To launch an instances using a Host Resource Group, the instance AMI must be
associated with a Customer managed license in AWS License Manager.

Using the AWS Console, open the AWS License Manager dashboard and naviate to
Customer managed licenses. Create a new Customer managed license, enter a
descriptive name and select a License Type of `Cores`.

Once your Customer managed license has been saved, open the detail view for your
license. Open the Associated AMIs tab and choose Associate AMI. From the list of
Available AMIs, select your macOS AMIs and then click Associate.

## Deploy the CloudFormation template

Using the VPC and AMI prepared earlier, deploy this template and fill in values
for the parameters:

* ImageId
* RootVolumeSize
* Subnets, from your VPC set up
* SecurityGroupIds, from your VPC set up
* IamInstanceProfile, if using additional AWS services from your builds provide an instance profile with appropriate IAM role
* BuildkiteAgentToken
* BuildkiteAgentQueue

Using the AWS CLI:

```
aws cloudformation deploy --stack-name buildkite-mac --region YOUR_REGION --parameters-override file:///.parameters.json
```

There are optional parameters to configure the Auto Scaling Group `MinSize` and
`MaxSize` which default to 0 and 3 respectively.

The default AWS limit for mac1.metal is 3 dedicated hosts per account region. If
you require more than 3 instances, request an increased limit using the AWS
Console.

Once you have deployed the template, use the template Resources tab to find the
Auto Scaling Group. Edit the Auto Scaling Group and set the Desired Capacity to
the number of instances you require.

The Auto Scaling Group will automatically provision Dedicated Hosts using the
Host Resource Group, and boot instances on them. The Launch Template’s
`UserData` script will install, configure, and start the Buildkite Agent.

Caveat the use of dynamic scaling policies on the Auto Scaling Group, instances
are slow to boot and slow to terminate. Consider using Scheduled Scaling Rules.

## F.A.Q.

### My ASG doesn’t launch any instances

If your ASG does not launch any instances, check the ASG Activity to see what
error is occuring.

It may be that there are no mac1.metal instances available in the region or
subnets you have chosen.

It may be that your Launch Template’s AMI is not associated with a Customer
Managed License in AWS License Manager.

Ensure you [associate your AMI](#associate-your-AMI-with-a-Customer-managed-license-in-AWS-License-Manager)
and any new AMIs with a Customer managed license. Ensure the License
Configuration has a License Type of `Core`.

### My instances don’t start the buildkite-agent

Ensure your AMI has been [configured to auto-login as the ec2-user](#Build-an-AMI)
in the GUI. The buildkite-agent launchd job configuration requires an `Aqua`
session type to allow your pipelines to use Xcode and the iOS Simulator.
