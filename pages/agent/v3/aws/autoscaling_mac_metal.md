# Auto Scaling mac1.metal instances

We have built a [CloudFormation template](https://github.com/buildkite/elastic-mac-for-aws)
that configures an Auto Scaling group, Launch Template, and Host Resource Group
suitable for maintaining a pool of mac1.metal instance based Buildkite Agents.
This can be used to build Xcode Project based software projects using Buildkite.

Using an Auto Scaling Group for your instances enables automatic instance
replacement when hardware failures occur, freeing you from the responsibility to
reprovision instances.

As you must prepare and supply your own AMI for this template, macOS support has
not been incorporated into the Elastic CI Stack for AWS.

## Choose a VPC Layout

Can use the default VPC and a security group to permit inbound SSH access.

Consider whether giving your mac1.metal instances a public IP address is
appropriate.

May wish to use a VPC with separate Public / Private subnets with a NAT Gateway,
and a Bastion instance or VPN for SSH and VNC access to the mac1.metal
instances.

## Build an AMI

Set up a password for the ec2-user so you can connect using VNC.

Using screen sharing, set up auto-login for the ec2-user. Disable auto screen
lock.

Install Xcode and Xcode Command Line Utilities. Launch them once so you are
presented with the EULA prompt.

You do not need to install the buildkite-agent, this will be done automatically
by the Launch Template `UserData` script.

Create an AMI from the instance using the AWS Console.

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
