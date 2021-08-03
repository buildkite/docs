# Auto Scaling mac1.metal instances

We have built a [CloudFormation template](https://github.com/buildkite/elastic-mac-for-aws)
that configures an Auto Scaling group, Launch Template, and Host Resource Group
suitable for maintaining a pool of EC2 mac1.metal instance based Buildkite
Agents. These agents can be used to run Buildkite Pipelines that build Xcode
based software projects for macOS, iOS, iPadOS, tvOS, and watchOS.

As you must prepare and supply your own AMI for this template, macOS support has
**not** been incorporated into the Elastic CI Stack for AWS.

Using an Auto Scaling Group for your instances ensures booting your macOS
Buildkite Agents is repeatable, and provides automatic instance replacement when
hardware failures occur.

## Prerequisites

Familiarity with AWS VPCs, and EC2 AMIs is required. You should also have
familiarity with the macOS GUI.

You must choose an AWS Region with `mac1.metal` instances available. See
[Amazon EC2 Mac Instances](https://aws.amazon.com/ec2/instance-types/mac/) and
[Amazon EC2 Dedicated Hosts Pricing](https://aws.amazon.com/ec2/dedicated-hosts/pricing/)
for details on which regions have `mac1.metal` hosts available.

See also the [Amazon EC2 Mac instances User Guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-mac-instances.html)
for more details on AWS EC2 Mac instances.

## Choose a VPC Layout

Before deploying this template you must choose a VPC subnet design, and which
VPC security groups your instances should belong to.

Depending on your threat model, you may find running instances in your default
VPC’s public subnets with a public IP address suitable. Otherwise, you may wish
to explore options like separate Public/Private subnets and a NAT Gateway, and
using a Bastion or VPN to access the instances over SSH and VNC.

In supported regions, `mac1.metal` dedicated hosts may not be availabile in
every Availability Zone. Consider using a subnet in every Availability Zone to
maximise the pool of instances available to boot from.

You also need to configure or define the VPC Security Groups your instance
network interfaces should belong to. At a minimum, inbound SSH access is
required to set up your initial template AMI.

## Build an AMI

Before deploying this template, you must create a template AMI that can be
horizontally scaled across multiple instances.

1. Reserve a [AWS mac1.metal](https://aws.amazon.com/ec2/instance-types/mac/)
Dedicated Host.
1. Boot a macOS instance using your desired AMI on the Dedicated Host.
1. Configure instance VPC subnets, security groups, and key pairs so that you
can access the instance.
1. Using an SSH or SSM session:
	1. Set a password for the ec2-user using `sudo passwd ec2-user`
	1. Enable screen sharing using `sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -restart -agent -privs -all`
1. Using a VNC session:
	1. Sign in as the ec2-user
	1. Enable Automatic login for the ec2-user in System Preferences > Users & Accounts > Login Options
	1. Disable Require password in System Preferences > Security & Privacy > General
1. Install your required version of Xcode
	1. Ensure you launch Xcode at least once so you are presented with the EULA prompt.
1. Using the AWS Console, create an AMI from your instance.

You do not need to install the `buildkite-agent`, it is automatically by the
Launch Template `UserData` script.

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

Using the VPC and AMI prepared earlier, provide values for the following
required parameters:

* ImageId
* RootVolumeSize
* Subnets, from your VPC set up
* SecurityGroupIds, from your VPC set up
* IamInstanceProfile, if using additional AWS services from your builds provide an instance profile with appropriate IAM role
* BuildkiteAgentToken
* BuildkiteAgentQueue

There are also optional parameters to configure the Auto Scaling Group:

* MinSize, defaults to 0
* MaxSize, defaults to 3

The default AWS Limit for mac1.metal is 3 dedicated hosts per account region. If
you require more than 3 instances, request an increased limit using the AWS
Console.

To deploy using the AWS CLI, save your parameters in a `.parameters.json` file
and run the following commands:

```
$ cat .parameters.json
> [
	{
		"ParameterKey": "ImageId",
		"ParameterValue": "ami-0c3a7d0c15048b6b5"
	},
	{
		"ParameterKey": "RootVolumeSize",
		"ParameterValue": "250"
	},
	{
		"ParameterKey": "Subnets",
		"ParameterValue": "subnet-f3e72abb,subnet-f23fe294"
	},
	{
		"ParameterKey": "SecurityGroupIds",
		"ParameterValue": "sg-a09db9d7"
	},
	{
		"ParameterKey": "BuildkiteAgentQueue",
		"ParameterValue": "mac"
	},
	{
		"ParameterKey": "BuildkiteAgentToken",
		"ParameterValue": "[redacted]"
	}
]

$ make
> sed "s/%v/v0.0.1-9-g1790b0d/" <template.yml >build/template.yml

$ aws cloudformation deploy --stack-name buildkite-mac --region YOUR_REGION --template-file build/template.yml --parameters-override file:///$PWD/.parameters.json
```

See the [AWS CloudFormation Deploy CLI documentation](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/cloudformation/deploy/index.html)
for more details.



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
