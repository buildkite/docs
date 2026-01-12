# Installing the Agent on your own AWS EC2 Mac instances

Setting up a macOS AMI that starts a Buildkite Agent on launch is a multi
step process. You can start with one of the macOS AMIs from AWS, or with an AMI
you've already installed Xcode or other software on.

To use Xcode and the iOS Simulator, you must configure auto-login of a GUI
session, and launch the Buildkite Agent in an `aqua` session as a Launchd Agent:

1. Reserve an [EC2 Mac](https://aws.amazon.com/ec2/instance-types/mac/)
Dedicated Host.
1. Boot a macOS instance using your desired AMI on the Dedicated Host.
1. Configure instance VPC subnets, security groups, and key pairs so that you
can access the instance.
1. Using an SSH or AWS SSM session:
	- Set a password for the `ec2-user` using `sudo passwd ec2-user`
	- Enable screen sharing using `sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -restart -agent -privs -all`
	- Grow the AFPS container to use all the available space in your EBS root disk if needed, see the [AWS user guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/mac-instance-increase-volume.html).
1. Using a VNC session (run SSH port forwarding `ssh -L 5900:localhost:5900 ec2-user@<ip-address>` if direct access is not available):
	1. Sign in as the `ec2-user`.
	1. Enable **Automatic login** for the `ec2-user` in **System Preferences** > **Users & Accounts** > **Login Options**.
	1. Disable **Require password** in **System Preferences** > **Security & Privacy** > **General**.
	1. Set system sleep in **System Preferences** > **Energy Saver** > **Turn display off after** to **Never**.
	1. Disable the screen saver in **System Preferences** > **Desktop & Screen Saver** > **Show screen saver after**.
1. Follow the [macOS installation guide](/docs/agent/v3/self-hosted/install/macos#installation)
instructions to install the Buildkite agent using Homebrew and configure
starting on login.
1. Verify that the Buildkite agent has connected to buildkite.com with your
desired agent tags.
1. Create an AMI from your instance.

Your saved AMI can now be used to boot as many macOS instances as you require.

To make this process repeatable, save your instance configuration in a
[launch template](https://docs.aws.amazon.com/autoscaling/ec2/userguide/LaunchTemplates.html).
To automate instance replacement, use an [Auto Scaling group](https://docs.aws.amazon.com/autoscaling/ec2/userguide/AutoScalingGroup.html)
to boot instances and a [host resource group](https://docs.aws.amazon.com/license-manager/latest/userguide/host-resource-groups.html)
to reserve Dedicated Hosts.

While the use of an Auto Scaling group and host resource group to automatically
maintain capacity in the face of hardware failures is recommended, load based
dynamic auto-scaling of macOS instances is not recommended. The instances are
currently slow to boot and slow to terminate. Use of load based auto-scaling is
likely to result in an over-provision of agents which carries a high minimum
charge per Dedicated Host.

There is an excellent blog post on [running iOS agents in the cloud](https://www.starkandwayne.com/blog/buildkite-2/) that goes into more detail on preparing macOS AMIs using [Packer](https://www.packer.io/).

## Known issues

* You might need to give the agent [full disk access](https://github.com/buildkite/agent/issues/1400).



