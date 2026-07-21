# Creating custom AMIs

Custom AMIs help teams ensure that their agents have all required tools and configurations before instance launch. This prevents instances from reverting to the base image state when agents restart, which would lose any manual changes made during runtime.

Custom [AMIs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) can be used with the [Elastic CI Stack for AWS](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows) by specifying the `ImageId` parameter. You can use any AMI available to your AWS account. For best results, start with the Packer templates provided in the [packer directory](https://github.com/buildkite/elastic-ci-stack-for-aws/tree/main/packer) of the [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws) repository.

## Requirements

To use the [Packer](https://developer.hashicorp.com/packer) templates provided, you need the following installed on your system:

- Docker
- Make
- AWS CLI
- Git — the built-in `secrets`, `ecr`, and `docker-login` plugins are pulled in as git submodules
- GNU sed (`gsed`) — required on macOS only (`brew install gnu-sed`); the [`Makefile`](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/main/Makefile) errors out if it is not installed

Before your first build, initialize the submodules so the built-in plugins are populated:

```bash
git submodule update --init --recursive
```

Without this step, the built-in plugin directories are empty. The Packer build itself succeeds (it copies empty directories), but the resulting AMI fails at runtime when agent hooks try to source missing plugin files.

The following AWS IAM permissions are required to build custom AMIs using the provided Packer templates:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CopyImage",
        "ec2:CreateImage",
        "ec2:CreateKeyPair",
        "ec2:CreateSecurityGroup",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteKeyPair",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteSnapshot",
        "ec2:DeleteVolume",
        "ec2:DeregisterImage",
        "ec2:DescribeImageAttribute",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeRegions",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSnapshots",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume",
        "ec2:GetPasswordData",
        "ec2:ModifyImageAttribute",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifySnapshotAttribute",
        "ec2:RegisterImage",
        "ec2:RunInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances"
      ],
      "Resource": "*"
    }
  ]
}
```

You'll also benefit from familiarity with:

- [Packer](https://developer.hashicorp.com/packer/docs/intro)
- [HashiCorp configuration language (HCL)](https://github.com/hashicorp/hcl?tab=readme-ov-file#hcl)
- Bash or PowerShell (depending on the operating system)

If you already know what you need to customize and just want the build command, skip to [Creating an image](#creating-an-image). Otherwise, the next two sections explain what each layer of the stack AMI provides and which Elastic CI Stack features depend on which components.

## How the AMI is layered

The Packer templates build the AMI in two stages. Both the Linux (Amazon Linux 2023) and Windows Server 2022 AMIs follow the same two-stage structure, but with platform-specific scripts and service management. Understanding what each stage provides makes it easier to customize an AMI without breaking the features the stack expects.

### Base AMI

The base AMI templates are in `packer/linux/base` and `packer/windows/base`.

The base layer is applied directly on top of the upstream Amazon Linux 2023 or Windows Server 2022 image. It installs the operating-system baseline that every Buildkite agent instance needs, regardless of how it is used:

- Docker Engine with buildx, docker compose v2, and the ECR credential helper
- Amazon CloudWatch agent
- AWS Systems Manager (SSM) agent and the Session Manager plugin
- Core CLI tooling: AWS CLI v2, `git`, `git-lfs`, `jq`
- Linux only: `mdadm`, `nvme-cli`, GnuPG (full), Development Tools, systemd timers for Docker garbage collection and periodic refresh of `authorized_keys` from S3
- Windows only: Windows Containers feature enabled

The base AMI is cached by the [`Makefile`](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/main/Makefile) and only rebuilt when `packer/{linux,windows}/base` changes. Its AMI ID is captured in the `packer-base-*.output` file next to the Makefile.

### Stack AMI

The stack AMI templates are in `packer/linux/stack` and `packer/windows/stack`.

The stack layer is applied on top of the base AMI. This is what turns a Docker-capable host into a Buildkite Elastic CI Stack agent. It installs:

- The Buildkite agent binary (stable and beta channels — `edge` and `oldstable` are downloaded on first boot if selected)
- **Linux:** the `buildkite-agent` user, group, and directory layout (`/etc/buildkite-agent`, `/var/lib/buildkite-agent/{builds,git-mirrors,plugins}`), plus the `buildkite-agent.service` systemd unit
- **Windows:** the agent directory layout under `C:\buildkite-agent\` (`builds`, `hooks`, `plugins`, `git-mirrors`), with the agent managed as an NSSM service
- Boot-time bootstrap scripts — see [What the stack layer adds on top of the Buildkite agent](#what-the-stack-layer-adds-on-top-of-the-buildkite-agent) below
- Agent hooks (`environment`, `pre-command`, `pre-exit`) that wire in disk-space checks, Docker configuration, and the built-in plugins
- Lifecycle and autoscaling tooling: [lifecycled](https://github.com/buildkite/lifecycled), `stop-agent-gracefully`, and `terminate-instance` (bash scripts on Linux, PowerShell scripts on Windows)
- The built-in `secrets`, `ecr`, and `docker-login` plugins — under `/usr/local/buildkite-aws-stack/plugins/` on Linux and `C:\Program Files\Git\usr\local\buildkite-aws-stack\plugins\` on Windows
- The `s3secrets-helper` binary
- **Linux only:** `fix-buildkite-agent-builds-permissions`, `goss`/`dgoss`, rsyslog rules for `buildkite-agent` and `docker` service logs, a cloud-init systemd override (`10-power-off-on-failure.conf`) that powers off the instance if bootstrap fails
- **Windows only:** a PowerShell error trap in `bk-install-elastic-stack.ps1` that marks the instance as unhealthy when bootstrap fails, so the Auto Scaling group can replace it
- CloudWatch agent configuration for streaming agent and system logs (using rsyslog on Linux, Windows Events on Windows)

> 📘 Reusing a pre-built base AMI
> If you're only customizing the Buildkite-specific parts of the AMI, you can skip rebuilding the base every time by passing an existing base AMI to the stack build with `BASE_AMI_ID`. The Makefile also reads `packer-base-*.output` automatically if it exists.

## What the stack layer adds on top of the Buildkite agent

An AMI that only contains the `buildkite-agent` binary does not boot into a working Elastic CI Stack instance. The CloudFormation `UserData` calls bootstrap scripts installed by the stack layer.

On Linux, three scripts are called:

- `/usr/local/bin/bk-mount-instance-storage.sh`
- `/usr/local/bin/bk-configure-docker.sh`
- `/usr/local/bin/bk-install-elastic-stack.sh`

On Windows, two scripts are called (there is no instance storage mounting equivalent):

- `C:\buildkite-agent\bin\bk-configure-docker.ps1`
- `C:\buildkite-agent\bin\bk-install-elastic-stack.ps1`

If those scripts aren't present, bootstrap fails and the instance is shut down. On Linux, the `10-power-off-on-failure.conf` systemd override triggers `poweroff.target`. On Windows, the PowerShell error trap in the bootstrap script marks the instance as unhealthy so the Auto Scaling group replaces it.

Beyond the bootstrap scripts, each CloudFormation stack parameter that customizes agent behavior is applied by one of these scripts or by the agent hooks — not by the agent binary itself.

The two areas most often overlooked when planning a custom AMI are the **lifecycle and autoscaling integration** (which you almost always want to keep) and the **S3 secrets plugin** (which is enabled by default but can be disabled if you use a different secret store).

### Lifecycle and autoscaling integration

The Elastic CI Stack does not rely on the Auto Scaling group alone to terminate agents. Instead it uses [lifecycled](https://github.com/buildkite/lifecycled) plus a small collection of scripts to give running jobs a chance to finish, upload artifacts, and disconnect cleanly before the instance is terminated. If your custom AMI keeps these components in place, you get graceful scale-in "for free."

The following table describes the Linux components. On Windows, `lifecycled` is managed using NSSM instead of systemd, and the bash scripts are replaced by PowerShell equivalents (`stop-agent-gracefully.ps1` and `terminate-instance.ps1`) under `C:\buildkite-agent\bin\`.

<table>
  <thead>
    <tr>
      <th style="width:35%">Component (Linux)</th>
      <th style="width:65%">Role</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "component": "<code>/usr/bin/lifecycled</code> + <code>lifecycled.service</code>",
        "role": "Subscribes to the Auto Scaling group's <code>EC2_INSTANCE_TERMINATING</code> lifecycle hook and invokes the handler script when the instance is asked to shut down."
      },
      {
        "component": "<code>/usr/local/bin/stop-agent-gracefully</code>",
        "role": "Lifecycled's handler: signals the Buildkite agent to finish its current job, waits for it to disconnect, then completes the lifecycle action."
      },
      {
        "component": "<code>/usr/local/bin/terminate-instance</code>",
        "role": "Invoked when a job triggers <code>BuildkiteTerminateInstanceAfterJob</code> or <code>BuildkiteTerminateInstanceOnDiskFull</code>. First attempts <code>terminate-instance-in-auto-scaling-group --should-decrement-desired-capacity</code> to scale in. If that fails (for example, the group is already at minimum size), it tries termination without decrement. As a last resort, it marks the instance as <code>Unhealthy</code> so the ASG replaces it."
      },
      {
        "component": "<code>buildkite-agent.service</code> + <code>10-power-off-on-failure.conf</code> (installed under both <code>cloud-init.service.d/</code> and <code>cloud-final.service.d/</code>)",
        "role": "systemd override that powers off the instance if cloud-init bootstrap fails, letting the ASG replace failed instances instead of leaving them running in a broken state."
      },
      {
        "component": "Agent config written by <code>bk-install-elastic-stack.sh</code>",
        "role": "Applies <code>disconnect-after-idle-timeout</code>, <code>disconnect-after-job</code>, and <code>disconnect-after-uptime</code>, which are the settings that make agents opt into scale-in."
      }
    ].each do |field| %>
      <tr>
        <td><p><%= field[:component] %></p></td>
        <td><p><%= field[:role] %></p></td>
      </tr>
    <% end %>
  </tbody>
</table>

If you replace any of these, you're taking on responsibility for detecting termination, draining the agent, and reporting instance health back to the Auto Scaling group. Keeping the stack layer as-is and adding your customizations _on top of it_ (extra provisioners, extra scripts, additional packages) is almost always the right choice.

### S3 secrets plugin

The Elastic CI Stack ships with a built-in [S3 secrets plugin](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security#s3-secrets-bucket) that fetches SSH keys, environment files, and per-pipeline secret files from an S3 bucket at the start of each job. The plugin is enabled by default through the `EnableSecretsPlugin` CloudFormation parameter (which defaults to `true`). When `SecretsBucket` is left empty, the stack creates a managed S3 bucket automatically.

The plugin depends on three things being present on the AMI:

- The `s3secrets-helper` binary — at `/usr/local/bin/s3secrets-helper` on Linux or downloaded by `install-s3secrets-helper.ps1` on Windows
- The `secrets` plugin hooks — under `/usr/local/buildkite-aws-stack/plugins/secrets` on Linux or `C:\Program Files\Git\usr\local\buildkite-aws-stack\plugins\secrets` on Windows
- The `environment` and `pre-exit` agent hooks that source those plugin hooks

If you build a custom AMI without them, setting `EnableSecretsPlugin=true` (the default) becomes a no-op — jobs start, but nothing is pulled from the secrets bucket, and any pipeline that expects a private SSH key or an `env` file fails during checkout. You have two options:

1. **Keep the built-in plugin.** Leave the stack layer's secrets components in place and, if needed, add your own extra hooks that run alongside them. This is what most customizations do.
1. **Replace it.** If you have a different secret store (AWS Secrets Manager, HashiCorp Vault, or an internal service), remove the built-in plugin from the AMI, set `EnableSecretsPlugin=false` in your stack parameters, and install your replacement's hooks under `/etc/buildkite-agent/hooks/` (Linux) or `C:\buildkite-agent\hooks\` (Windows) in your Packer template.

The `ecr` and `docker-login` built-in plugins follow the same pattern: enabled by CloudFormation parameters (`EnableECRPlugin`, `EnableDockerLoginPlugin`), and dependent on the plugin directories the stack layer copies into place.

### Feature-to-component mapping

The tables below show which CloudFormation parameters or Elastic CI Stack features stop working if a given component is removed from your custom AMI. Everything listed here comes from the **stack layer** — the base layer only provides Docker, CloudWatch, SSM, and general OS tooling.

> 📘 Platform differences
> The component paths shown are for Linux. On Windows, shell scripts (`.sh`) have PowerShell equivalents (`.ps1`), paths are rooted at `C:\buildkite-agent\` instead of `/usr/local/bin/` and `/etc/buildkite-agent/`, and systemd services are replaced by NSSM services. Components marked "Linux only" have no Windows equivalent.

#### Bootstrap and boot-time configuration

<table>
  <thead>
    <tr>
      <th style="width:35%">Component</th>
      <th style="width:65%">Elastic CI Stack features and CloudFormation parameters that depend on it</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "component": "<code>bk-install-elastic-stack.sh</code> / <code>.ps1</code>",
        "features": "Bootstrap itself. Reads the agent token from SSM, writes <code>buildkite-agent.cfg</code>, and applies almost every <code>Buildkite*</code> parameter (<code>BuildkiteQueue</code>, <code>AgentsPerInstance</code>, <code>BuildkiteAgentTags</code>, <code>BuildkiteAgentRelease</code>, <code>BuildkiteAgentSigningKeySSMParameter</code>, <code>BuildkiteAgentVerificationKeySSMParameter</code>, <code>BuildkiteAgentEnableGitMirrors</code>, <code>BootstrapScriptUrl</code>, <code>AgentEnvFileUrl</code>, <code>AuthorizedUsersUrl</code>, <code>ExperimentalEnableResourceLimits</code> and all <code>ResourceLimits*</code>, <code>EnableEC2LogRetentionPolicy</code>, <code>EC2LogRetentionDays</code>). Without it, the instance shuts itself down at boot."
      },
      {
        "component": "<code>bk-configure-docker.sh</code> / <code>.ps1</code>",
        "features": "<code>EnableDockerUserNamespaceRemap</code>, <code>EnableDockerExperimental</code>, <code>DockerNetworkingProtocol</code>, <code>DockerIPv4AddressPool1</code>, <code>DockerIPv4AddressPool2</code>, <code>DockerIPv6AddressPool</code>, <code>DockerFixedCidrV4</code>, <code>DockerFixedCidrV6</code>."
      },
      {
        "component": "<code>bk-mount-instance-storage.sh</code> (Linux only)",
        "features": "<code>EnableInstanceStorage</code>, <code>MountTmpfsAtTmp</code>. Handles NVMe discovery, software RAID across multiple drives, and bind-mounting builds and git-mirrors onto ephemeral storage. Not available on Windows."
      },
      {
        "component": "<code>bk-check-disk-space.sh</code> + <code>environment</code> / <code>pre-exit</code> hooks (Linux only)",
        "features": "<code>BuildkitePurgeBuildsOnDiskFull</code>, <code>BuildkiteTerminateInstanceOnDiskFull</code>, <code>EnablePreExitDiskCleanup</code>, <code>DockerPruneUntil</code>, <code>DockerBuilderPruneEnabled</code>. Not available on Windows."
      }
    ].each do |field| %>
      <tr>
        <td><p><%= field[:component] %></p></td>
        <td><p><%= field[:features] %></p></td>
      </tr>
    <% end %>
  </tbody>
</table>

#### Lifecycle, autoscaling, and instance health

<table>
  <thead>
    <tr>
      <th style="width:35%">Component</th>
      <th style="width:65%">Elastic CI Stack features and CloudFormation parameters that depend on it</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "component": "<code>lifecycled</code>, <code>stop-agent-gracefully</code>, <code>terminate-instance</code>",
        "features": "Graceful ASG scale-in. <code>BuildkiteTerminateInstanceAfterJob</code>. Instance-health signalling that lets the ASG replace failed hosts. Present on both Linux and Windows (PowerShell equivalents on Windows)."
      },
      {
        "component": "<code>fix-buildkite-agent-builds-permissions</code> (Linux only)",
        "features": "Docker-based builds that write files to the workspace as root. Without it, subsequent jobs on the same agent fail during git operations because the <code>buildkite-agent</code> user cannot remove root-owned files. Not applicable on Windows."
      },
      {
        "component": "<strong>Linux:</strong> <code>buildkite-agent.service</code> + <code>10-power-off-on-failure.conf</code><br><strong>Windows:</strong> NSSM service + PowerShell error trap",
        "features": "The agent auto-starting on boot. Automatic shutdown or health-status marking when bootstrap fails, so the ASG replaces broken instances instead of leaving them running."
      }
    ].each do |field| %>
      <tr>
        <td><p><%= field[:component] %></p></td>
        <td><p><%= field[:features] %></p></td>
      </tr>
    <% end %>
  </tbody>
</table>

#### Built-in plugins and observability

<table>
  <thead>
    <tr>
      <th style="width:35%">Component</th>
      <th style="width:65%">Elastic CI Stack features and CloudFormation parameters that depend on it</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "component": "<code>s3secrets-helper</code> + <code>secrets</code> built-in plugin",
        "features": "<code>EnableSecretsPlugin</code> (defaults to <code>true</code>), <code>SecretsBucket</code>, <code>SecretsBucketRegion</code>, <code>SecretsPluginSkipSSHKeyNotFoundWarning</code>. See <a href=\"/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security#s3-secrets-bucket\">S3 secrets bucket</a>."
      },
      {
        "component": "<code>ecr</code> built-in plugin",
        "features": "<code>EnableECRPlugin</code>, <code>ECRAccessPolicy</code>, <code>EnableECRCredentialHelper</code>, <code>AWS_ECR_LOGIN_REGISTRY_IDS</code>. See <a href=\"/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/managing-elastic-ci-stack#docker-registry-support\">Docker registry support</a>."
      },
      {
        "component": "<code>docker-login</code> built-in plugin",
        "features": "<code>EnableDockerLoginPlugin</code>, <code>DOCKER_LOGIN_USER</code>, <code>DOCKER_LOGIN_PASSWORD</code>, <code>DOCKER_LOGIN_SERVER</code>. See <a href=\"/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/managing-elastic-ci-stack#docker-registry-support\">Docker registry support</a>."
      },
      {
        "component": "<strong>Linux:</strong> CloudWatch agent config + rsyslog rules<br><strong>Windows:</strong> CloudWatch agent config + Windows Events collection",
        "features": "The <code>/buildkite/elastic-stack/{instance-id}</code> and <code>/buildkite/system/{instance-id}</code> log groups. <code>EnableEC2LogRetentionPolicy</code> and <code>EC2LogRetentionDays</code>. Without them, the CloudWatch agent is installed but does not stream any Buildkite or Docker service logs."
      }
    ].each do |field| %>
      <tr>
        <td><p><%= field[:component] %></p></td>
        <td><p><%= field[:features] %></p></td>
      </tr>
    <% end %>
  </tbody>
</table>

## Creating an image

To create a custom AMI, use the provided Packer templates to build new images with your modifications. First, make your changes to the Packer templates, then run the [`Makefile`](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/main/Makefile) in the root directory to begin the build process.

This [`Makefile`](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/main/Makefile) provides several build targets, each running Packer in a Docker container:

<table>
  <thead>
    <tr>
      <th style="width:40%">Command</th>
      <th style="width:60%">Description</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "command": "make packer",
        "description": "Build all AMI variants"
      },
      {
        "command": "make packer-linux-amd64.output",
        "description": "Build Amazon Linux 2023 (64-bit x86) AMI only"
      },
      {
        "command": "make packer-linux-arm64.output",
        "description": "Build Amazon Linux 2023 (64-bit ARM, Graviton) AMI only"
      },
      {
        "command": "make packer-windows-amd64.output",
        "description": "Build Windows Server 2022 (64-bit x86) AMI only"
      },
      {
        "command": "make packer-base-linux-amd64.output",
        "description": "Build the Amazon Linux 2023 base AMI only (64-bit x86)"
      },
      {
        "command": "make packer-base-linux-arm64.output",
        "description": "Build the Amazon Linux 2023 base AMI only (64-bit ARM, Graviton)"
      },
      {
        "command": "make packer-base-windows-amd64.output",
        "description": "Build the Windows Server 2022 base AMI only (64-bit x86)"
      }
    ].select { |field| field[:command] }.each do |field| %>
      <tr>
        <td>
          <p><code><%= field[:command] %></code></p>
        </td>
        <td>
          <p><%= field[:description] %></p>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

The full stack targets (`make packer-linux-amd64.output`, `make packer-linux-arm64.output`, `make packer-windows-amd64.output`) automatically build the corresponding base AMI first, unless a base AMI ID is passed in using `BASE_AMI_ID` or a previous `packer-base-*.output` file is present.

By default, all builds target the `us-east-1` region and use your default AWS profile. The `make` command can be prefixed with environment variables to change the behavior of the build.

<table>
  <thead>
    <tr>
      <th style="width:30%">Variable</th>
      <th style="width:20%">Default</th>
      <th style="width:50%">Description</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "variable": "AWS_REGION",
        "default": "us-east-1",
        "description": "Target AWS region for AMI creation"
      },
      {
        "variable": "AWS_PROFILE",
        "default": "(system default)",
        "description": "Specific AWS profile to use"
      },
      {
        "variable": "PACKER_LOG",
        "default": "(unset)",
        "description": "Enable Packer debug logging (<code>PACKER_LOG=1</code>)"
      },
      {
        "variable": "BUILDKITE_BUILD_NUMBER",
        "default": "none",
        "description": "Build identifier passed to Packer as an AMI tag"
      },
      {
        "variable": "IS_RELEASED",
        "default": "false",
        "description": "Whether this is a release build"
      },
      {
        "variable": "ARM64_INSTANCE_TYPE",
        "default": "m7g.xlarge",
        "description": "Instance type for ARM64 builds"
      },
      {
        "variable": "AMD64_INSTANCE_TYPE",
        "default": "m7a.xlarge",
        "description": "Instance type for AMD64 builds"
      },
      {
        "variable": "WIN64_INSTANCE_TYPE",
        "default": "m7i.xlarge",
        "description": "Instance type for Windows builds"
      },
      {
        "variable": "AMI_PUBLIC",
        "default": "false",
        "description": "Set to <code>true</code> to make the built AMIs available to all AWS accounts. Defaults to private — recommended, since baked-in secrets would otherwise be exposed."
      },
      {
        "variable": "AMI_USERS",
        "default": "(empty)",
        "description": "Comma-separated list of AWS account IDs allowed to launch the private AMI (ignored when <code>AMI_PUBLIC=true</code>)."
      },
      {
        "variable": "BASE_AMI_ID",
        "default": "(auto)",
        "description": "Skip the base-AMI rebuild and layer the stack on top of this AMI ID. When unset, the Makefile reads the ID from <code>packer-base-{arch}.output</code> if it exists."
      }
    ].select { |field| field[:variable] }.each do |field| %>
      <tr>
        <td>
          <p><code><%= field[:variable] %></code></p>
        </td>
        <td>
          <% if field[:default].starts_with?('(') %>
            <p><%= field[:default] %></p>
          <% else %>
            <p><code><%= field[:default] %></code></p>
          <% end %>
        </td>
        <td>
          <p><%= field[:description] %></p>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

> 📘 Changing the agent version
> The agent version is pinned inside `install-buildkite-agent.sh` (Linux) and `install-buildkite-agent.ps1` (Windows). To change it, edit the `AGENT_VERSION` value in those scripts directly, or use `make bump-agent-version` to update both scripts and the README automatically.

For example, you could build an AMD64 Linux image in the `eu-west-1` region using a smaller instance type and a specific AWS profile by running:

```bash
AMD64_INSTANCE_TYPE="t3.medium" \
AWS_REGION="eu-west-1" \
AWS_PROFILE="assets-profile" \
make packer-linux-amd64.output
```

Once your image build is completed, the AMI is stored in your AWS account and the AMI ID is displayed in your terminal output. You can also find the AMI ID in the corresponding output file (such as `packer-linux-amd64.output`).

### Common customization flows

Rebuild only the stack layer on top of an existing base AMI:

```bash
BASE_AMI_ID=ami-0123456789abcdef0 \
  make packer-linux-amd64.output
```

Build private AMIs and share them with specific AWS accounts:

```bash
AMI_PUBLIC=false \
AMI_USERS="123456789012,987654321098" \
  make packer
```

Build only the Linux AMIs (skip the Windows build):

```bash
make packer-base-linux-amd64.output packer-linux-amd64.output \
     packer-base-linux-arm64.output packer-linux-arm64.output
```
