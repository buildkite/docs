# Troubleshooting

The following are solutions to problems some users face when using the [Elastic CI Stack for AWS Mac](https://github.com/buildkite/elastic-mac-for-aws).

## My Auto Scaling group doesn't launch any instances

* If your Auto Scaling group does not launch any instances, open the EC2 Console
dashboard and **Auto Scaling Groups** from the side bar. Find your Auto Scaling
group and open the **Activity** tab. The **Activity history** table will list the
scaling actions that have occurred and any errors that resulted.

* There may be a shortage of `mac1.metal` instances in the region, or Availability
Zones of your VPC subnets. This error is likely to be a temporary one, wait for your
Auto Scaling group to attempt to scale out again and see if the error persists.

* Your launch template's AMI may not have been associated with a Customer
Managed License in AWS License Manager. Ensure you [associate your AMI](/docs/agent/v3/self-hosted/aws/elastic-ci-stack/ec2-mac/setup#step-3-associate-your-ami-with-a-self-managed-license-in-aws-license-manager)
and any new AMIs with a Customer managed license. Ensure the License
configuration has a **License type** of `Cores`.

## My instances don't start the buildkite-agent

Ensure your AMI has been [configured to auto-login as the `ec2-user`](/docs/agent/v3/self-hosted/aws/elastic-ci-stack/ec2-mac/setup#step-2-build-an-ami)
in the GUI.

## How do I enable use of Xcode and the iOS simulator?

To allow your pipelines to use Xcode and the iOS simulator the Buildkite Agent launchd job configuration requires an `Aqua` session type.

## What user does the agent run as?

The Buildkite agent runs as `ec2-user`.

## UserData script fails with Homebrew commands

Common errors include:
```
zsh:1: command not found: brew
Error: $HOME must be set to run brew.
```

These occur because the UserData script runs as `root`, but Homebrew is installed under the `ec2-user` account. Ensure your UserData script uses `su -` to run Homebrew commands as the correct user:

```bash
#!/bin/bash
user=ec2-user
su - "${user}" -c 'brew install buildkite/buildkite/buildkite-agent'
config="$(su - ${user} -c 'brew --prefix')"/etc/buildkite-agent/buildkite-agent.cfg
sed -i '' "s/xxx/${BuildkiteAgentToken}/g" "${config}"
echo "tags=\"queue=${BuildkiteAgentQueue},buildkite-mac-stack=%v\"" >> "${config}"
echo "tags-from-ec2=true" >> "${config}"
su - "${user}" -c 'brew services start buildkite/buildkite/buildkite-agent'
```

## Homebrew service fails to start with launch control error 125

You may see errors like:
```
Error: Failure while executing; `/bin/launchctl enable gui/501/homebrew.mxcl.buildkite-agent` exited with 125.
Warning: running through sudo, using user/* instead of gui/* domain!
```

This is related to GUI service startup and the agent should still start successfully. If problems persist, ensure your AMI was configured with auto-login enabled.

## Path issues when building custom AMIs with Packer

When using Packer to build custom macOS AMIs, you may encounter issues where commands like `brew` cannot be found, which are usually the result of these executables not being configured in your `PATH` environment variable.

Add the Homebrew executable paths to your Packer provisioner scripts:

```bash
PATH=/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:/usr/sbin:/sbin
```

Note that the exact path depends on your architecture:
* Apple Silicon (ARM): `/opt/homebrew/bin`
* Intel (x86): `/usr/local/bin`
