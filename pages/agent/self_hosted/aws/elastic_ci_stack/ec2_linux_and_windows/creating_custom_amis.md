# Creating custom AMIs

Custom AMIs help teams ensure that their agents have all required tools and configurations before instance launch. These images preserve the required configuration when the stack launches new or replacement instances, which do not retain changes made to previous instances during runtime.

Custom [AMIs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) can be used with the [Elastic CI Stack for AWS](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows) by specifying the `ImageId` parameter. You can use any AMI available to your AWS account. For best results, start with the Packer templates provided in the [packer directory](https://github.com/buildkite/elastic-ci-stack-for-aws/tree/main/packer) of the [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws) repository.

## Creating an image

To create a custom AMI using the provided Packer templates:

1. Clone the [Elastic CI Stack for AWS repository](https://github.com/buildkite/elastic-ci-stack-for-aws).
1. Initialize the repository's Git submodules. Before your first build, initialize the submodules so the built-in plugins are populated:

    ```bash
    git submodule update --init --recursive
    ```

    Without this step, Git leaves the built-in plugin directories empty, and Packer copies those empty directories into the AMI. The image build succeeds, but the resulting AMI lacks the plugin hooks. At runtime, enabling an affected plugin causes the agent's `environment` hook to exit when it tries to source the missing plugin hook.

1. Make your changes to the templates in the `packer` directory.
1. From the repository's root directory, run the [`Makefile`](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/main/Makefile) target for the image you want to build. For example, run the following command to build an Amazon Linux 2023 AMD64 image:

    ```bash
    make packer-linux-amd64.output
    ```

When the build completes, the AMI is stored in your AWS account. The AMI ID appears in your terminal output and in the corresponding output file, such as `packer-linux-amd64.output`.

The following sections describe the build requirements, the AMI components you can customize, and the available build targets and options.

## Requirements

To use the [Packer](https://developer.hashicorp.com/packer) templates provided, you need the following installed on your system:

- Docker
- Make
- AWS CLI
- **Git:** The built-in `secrets`, `ecr`, and `docker-login` [plugins](/docs/pipelines/integrations/plugins) are pulled in as Git submodules
- `GNU sed (gsed)`: Required on macOS only (`brew install gnu-sed`); the `Makefile` exits with an error if it is not installed

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

## How the AMIs are layered

The Linux and Windows Packer templates both build the AMI in two stages, but their components, scripts, and supported Docker behavior differ. The following sections describe each platform separately.

### Linux base AMI

The Linux base AMI template is in `packer/linux/base`.

The base layer is applied directly on top of the upstream Amazon Linux 2023 image. It installs the operating-system baseline that every Linux Buildkite agent instance needs, regardless of how it is used:

- Docker Engine, Docker Buildx, Docker Compose v2, and the ECR credential helper
- Amazon CloudWatch agent
- AWS Systems Manager (SSM) agent and the Session Manager plugin
- Core CLI tooling: AWS CLI v2, `git`, `git-lfs`, `jq`
- `mdadm`, `nvme-cli`, GnuPG (full), and Development Tools
- Systemd timers for Docker garbage collection and periodic refresh of `authorized_keys` from S3

The base AMI is cached by the [`Makefile`](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/main/Makefile) and only rebuilt when `packer/linux/base` changes. Its AMI ID is captured in the corresponding `packer-base-linux-*.output` file next to the Makefile.

### Linux stack AMI

The Linux stack AMI template is in `packer/linux/stack`.

The stack layer is applied on top of the base AMI. This is what turns a Docker-capable host into a Buildkite Elastic CI Stack agent. It installs:

- The Buildkite agent binary for the stable and beta channels (`edge` and `oldstable` are downloaded on first boot if selected)
- The `buildkite-agent` user, group, and directory layout (`/etc/buildkite-agent`, `/var/lib/buildkite-agent/{builds,git-mirrors,plugins}`), plus the `buildkite-agent.service` systemd unit
- Boot-time bootstrap scripts described in [What the Linux stack layer adds on top of the Buildkite agent](#what-the-linux-stack-layer-adds-on-top-of-the-buildkite-agent)
- Agent hooks (`environment`, `pre-command`, `pre-exit`) that wire in disk-space checks, Docker configuration, and the built-in plugins
- Lifecycle and autoscaling tooling: [lifecycled](https://github.com/buildkite/lifecycled), `stop-agent-gracefully`, and `terminate-instance`
- The built-in `secrets`, `ecr`, and `docker-login` plugins under `/usr/local/buildkite-aws-stack/plugins/`
- The `s3secrets-helper` binary
- `fix-buildkite-agent-builds-permissions` and `goss`/`dgoss`
- Rsyslog rules for `buildkite-agent` and `docker` service logs
- A cloud-init systemd override (`10-power-off-on-failure.conf`) that powers off the instance if bootstrap fails
- CloudWatch agent configuration for streaming agent and system logs using rsyslog

> 📘 Reusing a pre-built base AMI
> If you're only customizing the Buildkite-specific parts of the Linux AMI, you can skip rebuilding the base by passing an existing Elastic CI Stack Linux base AMI to the stack build with `BASE_AMI_ID`. The Makefile also reuses an up-to-date `packer-base-linux-*.output` file automatically.

### Windows base AMI

The Windows base AMI template is in `packer/windows/base`. It is applied to the upstream Windows Server 2022 English Full Base image and installs:

- Docker CE, Docker Compose, and the ECR credential helper
- The Windows Containers feature
- Amazon CloudWatch agent
- AWS CLI v2, Git for Windows, `jq`, Chocolatey, and NSSM
- The AWS Systems Manager Session Manager plugin installer, downloaded to `C:\buildkite-agent\bin\SessionManagerPluginSetup.exe`
- `lifecycled.exe` as the NSSM-managed `lifecycled` service

The Windows base AMI does not include Linux packages, Docker Buildx, systemd timers, or the S3 `authorized_keys` refresh tooling described in the Linux base AMI section.

### Windows stack AMI

The Windows stack AMI template is in `packer/windows/stack`. It installs:

- Stable and beta Buildkite agent executables under `C:\buildkite-agent\bin\`
- The `builds`, `hooks`, `git-mirrors`, and `plugins` directories under `C:\buildkite-agent\`
- PowerShell bootstrap scripts under `C:\buildkite-agent\bin\`
- The NSSM-managed `buildkite-agent` service
- `stop-agent-gracefully.ps1` and `terminate-instance.ps1` for lifecycle handling
- The built-in `secrets`, `ecr`, and `docker-login` plugins under `C:\Program Files\Git\usr\local\buildkite-aws-stack\plugins\`
- `s3secrets-helper.exe` under `C:\buildkite-agent\bin\`
- CloudWatch agent configuration for Windows log files and Windows Events

The Windows stack does not install the Linux instance-storage, disk-cleanup, permissions-repair, goss, rsyslog, systemd, or cloud-init components. See [What the Windows stack layer adds on top of the Buildkite agent](#what-the-windows-stack-layer-adds-on-top-of-the-buildkite-agent) for the Windows bootstrap and feature differences.

## What the Linux stack layer adds on top of the Buildkite agent

An AMI that only contains the `buildkite-agent` binary does not boot into a working Elastic CI Stack instance. The CloudFormation `UserData` calls bootstrap scripts installed by the Linux stack layer. A bare image also lacks the cloud-init override that provides the Linux stack's failure safeguard.

Three scripts are called:

- `/usr/local/bin/bk-mount-instance-storage.sh`
- `/usr/local/bin/bk-configure-docker.sh`
- `/usr/local/bin/bk-install-elastic-stack.sh`

If those scripts aren't present, bootstrap fails without automatically invoking the stack's failure safeguard. A customized image that retains `10-power-off-on-failure.conf` triggers `poweroff.target` when bootstrap fails.

Beyond the bootstrap scripts, each CloudFormation stack parameter that customizes agent behavior is applied by one of these scripts or by the agent hooks, not by the agent binary itself.

Preserve the lifecycle and autoscaling integration unless you plan to replace it. The S3 secrets plugin is enabled by default, but you can disable it if you use a different secret store.

### Lifecycle and autoscaling integration

The Elastic CI Stack does not rely on the Auto Scaling group alone to terminate agents. Instead, it uses [lifecycled](https://github.com/buildkite/lifecycled) and a small collection of scripts to give running jobs a chance to finish, upload artifacts, and disconnect cleanly before the instance is terminated. Keeping these components in your custom AMI provides graceful scale-in.

The following table describes the Linux components.

<table>
  <thead>
    <tr>
      <th style="width:35%">Component</th>
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
        "role": "Invoked when a job triggers <code>BuildkiteTerminateInstanceAfterJob</code> or <code>BuildkiteTerminateInstanceOnDiskFull</code>. First attempts <code>terminate-instance-in-auto-scaling-group --should-decrement-desired-capacity</code> to scale in. If that fails (for example, the group is already at minimum size), it tries termination without decrement. As a last resort, it marks the instance as <code>Unhealthy</code> so the Auto Scaling group replaces it."
      },
      {
        "component": "<code>buildkite-agent.service</code> + <code>10-power-off-on-failure.conf</code> (installed under both <code>cloud-init.service.d/</code> and <code>cloud-final.service.d/</code>)",
        "role": "systemd override that powers off the instance if cloud-init bootstrap fails, letting the Auto Scaling group replace failed instances instead of leaving them running in a broken state."
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

If you replace any of these components, you're responsible for detecting termination, draining the agent, and reporting instance health to the Auto Scaling group. To preserve this behavior, keep the stack layer and add extra provisioners, scripts, or packages on top of it.

### S3 secrets plugin

The Elastic CI Stack ships with a built-in [S3 secrets plugin](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security#s3-secrets-bucket) that fetches SSH keys, environment files, and per-pipeline secret files from an S3 bucket at the start of each job. The plugin is enabled by default through the `EnableSecretsPlugin` CloudFormation parameter (which defaults to `true`). When `SecretsBucket` is left empty, the stack creates a managed S3 bucket automatically.

The plugin depends on three things being present on the AMI:

- `s3secrets-helper`: The binary at `/usr/local/bin/s3secrets-helper`
- `secrets`: The plugin hooks under `/usr/local/buildkite-aws-stack/plugins/secrets`
- **Agent hooks:** The `environment` and `pre-exit` hooks that source the plugin hooks

If the agent hooks remain but the plugin files are absent, the `environment` hook exits when it fails to source the missing plugin hook. Removing both the agent hooks and plugin files makes `EnableSecretsPlugin=true`, which is the default, have no effect.

- **Keep the built-in plugin:** Leave the stack layer's secrets components in place and, if needed, add your own hooks that run alongside them.
- **Replace it:** If you have a different secret store (AWS Secrets Manager, HashiCorp Vault, or an internal service), remove the built-in plugin from the AMI, set `EnableSecretsPlugin=false` in your stack parameters, and install your replacement's hooks under `/etc/buildkite-agent/hooks/` in your Packer template.

The `ecr` and `docker-login` built-in plugins follow the same pattern: enabled by CloudFormation parameters (`EnableECRPlugin`, `EnableDockerLoginPlugin`), and dependent on the plugin directories the stack layer copies into place.

### Feature-to-component mapping

The tables below show which CloudFormation parameters or Elastic CI Stack features depend on each Linux stack component. These mappings do not apply to Windows AMIs. Everything listed here comes from the _Linux stack layer_. The Linux base layer provides Docker, CloudWatch, SSM, and general operating system tooling.

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
        "component": "<code>bk-install-elastic-stack.sh</code>",
        "features": "Bootstrap itself. Reads the agent token from SSM, writes <code>buildkite-agent.cfg</code>, and applies almost every <code>Buildkite*</code> parameter (<code>BuildkiteQueue</code>, <code>AgentsPerInstance</code>, <code>BuildkiteAgentTags</code>, <code>BuildkiteAgentRelease</code>, <code>BuildkiteAgentSigningKeySSMParameter</code>, <code>BuildkiteAgentVerificationKeySSMParameter</code>, <code>BuildkiteAgentEnableGitMirrors</code>, <code>BootstrapScriptUrl</code>, <code>AgentEnvFileUrl</code>, <code>AuthorizedUsersUrl</code>, <code>ExperimentalEnableResourceLimits</code>, and all <code>ResourceLimits*</code>, <code>EnableEC2LogRetentionPolicy</code>, <code>EC2LogRetentionDays</code>). Without it, bootstrap cannot configure or start the agent. Shutdown behavior also requires the cloud-init override."
      },
      {
        "component": "<code>bk-configure-docker.sh</code>",
        "features": "<code>EnableDockerUserNamespaceRemap</code>, <code>EnableDockerExperimental</code>, <code>DockerNetworkingProtocol</code>, <code>DockerIPv4AddressPool1</code>, <code>DockerIPv4AddressPool2</code>, <code>DockerIPv6AddressPool</code>, <code>DockerFixedCidrV4</code>, <code>DockerFixedCidrV6</code>."
      },
      {
        "component": "<code>bk-mount-instance-storage.sh</code>",
        "features": "<code>EnableInstanceStorage</code>, <code>MountTmpfsAtTmp</code>. Handles NVMe discovery, software RAID across multiple drives, and bind-mounting builds and git-mirrors onto ephemeral storage."
      },
      {
        "component": "<code>bk-check-disk-space.sh</code> + <code>environment</code> / <code>pre-exit</code> hooks",
        "features": "<code>BuildkitePurgeBuildsOnDiskFull</code>, <code>BuildkiteTerminateInstanceOnDiskFull</code>, <code>EnablePreExitDiskCleanup</code>, <code>DockerPruneUntil</code>, <code>DockerBuilderPruneEnabled</code>."
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
        "features": "Graceful Auto Scaling group scale-in. <code>BuildkiteTerminateInstanceAfterJob</code>. Instance-health signaling that lets the Auto Scaling group replace failed hosts."
      },
      {
        "component": "<code>fix-buildkite-agent-builds-permissions</code>",
        "features": "Docker-based builds that write files to the workspace as root. Without it, subsequent jobs on the same agent fail during Git operations because the <code>buildkite-agent</code> user cannot remove root-owned files."
      },
      {
        "component": "<code>buildkite-agent.service</code> + <code>10-power-off-on-failure.conf</code>",
        "features": "The agent auto-starting on boot. Automatic shutdown when bootstrap fails, so the Auto Scaling group replaces broken instances instead of leaving them running."
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
        "features": "<code>EnableECRPlugin</code>, <code>AWS_ECR_LOGIN_REGISTRY_IDS</code>, and agent-hook handling of <code>ECRAccessPolicy</code> and <code>EnableECRCredentialHelper</code>. See <a href=\"/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/managing-elastic-ci-stack#docker-registry-support\">Docker registry support</a>."
      },
      {
        "component": "<code>docker-login</code> built-in plugin",
        "features": "<code>EnableDockerLoginPlugin</code>, <code>DOCKER_LOGIN_USER</code>, <code>DOCKER_LOGIN_PASSWORD</code>, <code>DOCKER_LOGIN_SERVER</code>. See <a href=\"/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/managing-elastic-ci-stack#docker-registry-support\">Docker registry support</a>."
      },
      {
        "component": "CloudWatch agent config + rsyslog rules",
        "features": "The <code>/buildkite/elastic-stack</code> and <code>/buildkite/system</code> log groups, alongside the other Linux <code>/buildkite/...</code> groups. These groups use <code>{instance_id}</code> as the log stream name. <code>EnableEC2LogRetentionPolicy</code> and <code>EC2LogRetentionDays</code>. Without this configuration, the CloudWatch agent is installed but does not stream Buildkite or Docker service logs."
      }
    ].each do |field| %>
      <tr>
        <td><p><%= field[:component] %></p></td>
        <td><p><%= field[:features] %></p></td>
      </tr>
    <% end %>
  </tbody>
</table>

## What the Windows stack layer adds on top of the Buildkite agent

The Windows stack uses PowerShell scripts, NSSM services, Windows paths, and Windows-specific CloudWatch collection. It does not use the Linux component mappings in the previous section.

CloudFormation `UserData` calls two scripts:

- `C:\buildkite-agent\bin\bk-configure-docker.ps1`
- `C:\buildkite-agent\bin\bk-install-elastic-stack.ps1`

The Docker configuration script runs first. The stack installation script then selects the agent release, writes `buildkite-agent.cfg`, configures hooks and services, and signals the CloudFormation result.

Terminating PowerShell errors that reach the error trap in `bk-install-elastic-stack.ps1` mark the instance as unhealthy and, when deployed by CloudFormation, send a failed signal. Explicit `Exit` paths bypass the trap, so not every nonzero exit provides this safeguard. A bare image without the script also lacks the safeguard, and the earlier `bk-configure-docker.ps1` invocation runs outside the trap.

### Services and lifecycle

Windows uses NSSM instead of systemd:

- `lifecycled`: Runs `C:\lifecycled\bin\lifecycled.exe` and calls `C:\buildkite-agent\bin\stop-agent-gracefully.ps1` during an Auto Scaling lifecycle event
- `buildkite-agent`: Runs `C:\buildkite-agent\bin\buildkite-agent.exe start` and calls `terminate-instance.ps1` after the service exits

The stack writes the agent disconnect settings used for scale-in. The termination script first asks the Auto Scaling group to terminate the instance and decrement the desired capacity. If that fails when `BuildkiteTerminateInstanceAfterJob=true`, it marks the instance as unhealthy. Otherwise, it restarts the agent service.

### Built-in plugins and observability

The Windows `environment`, `pre-command`, and `pre-exit` hooks source the enabled built-in plugins using the Git Bash view of `/usr/local/buildkite-aws-stack/plugins/`. The physical plugin files are under `C:\Program Files\Git\usr\local\buildkite-aws-stack\plugins\`.

The Windows CloudWatch configuration collects these file logs using `{instance_id}` as the stream name:

- `/buildkite/cfn-init`
- `/buildkite/EC2Launch/UserdataExecution`
- `/buildkite/elastic-stack`
- `/buildkite/buildkite-agent`
- `/buildkite/lifecycled`

It also sends Windows System events to `/buildkite/system`. Windows does not use the Linux rsyslog configuration or the Linux-only `/buildkite/docker-daemon`, `/buildkite/cloud-init`, `/buildkite/cloud-init/output`, and `/buildkite/auth` log groups.

### Windows feature differences

On Windows, `bk-configure-docker.ps1` implements `EnableDockerExperimental` by updating `C:\ProgramData\docker\config\daemon.json` and restarting Docker. It does not implement the other Docker behavior mapped to `bk-configure-docker.sh` on Linux.

The following features and components in the Linux mapping have no Windows implementation:

- `EnableDockerUserNamespaceRemap`, `DockerNetworkingProtocol`, `DockerIPv4AddressPool1`, `DockerIPv4AddressPool2`, `DockerIPv6AddressPool`, `DockerFixedCidrV4`, and `DockerFixedCidrV6`
- `EnableInstanceStorage` and `MountTmpfsAtTmp`
- `BuildkitePurgeBuildsOnDiskFull`, `BuildkiteTerminateInstanceOnDiskFull`, and `EnablePreExitDiskCleanup`
- `DockerPruneUntil` and `DockerBuilderPruneEnabled`
- `bk-mount-instance-storage.sh`, `bk-check-disk-space.sh`, `fix-buildkite-agent-builds-permissions`, `goss`, `dgoss`, rsyslog, systemd, and the cloud-init failure override

## Build targets and options

The `Makefile` provides several build targets, each running Packer in a Docker container:

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

The full stack targets (`make packer-linux-amd64.output`, `make packer-linux-arm64.output`, `make packer-windows-amd64.output`) automatically build the corresponding base AMI first, unless a base AMI ID is passed in using `BASE_AMI_ID` or an up-to-date `packer-base-*.output` file is present.

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
        "description": "Set to <code>true</code> to make the built AMIs available to all AWS accounts. Keep AMIs private to avoid exposing baked-in secrets"
      },
      {
        "variable": "AMI_USERS",
        "default": "(empty)",
        "description": "Comma-separated list of AWS account IDs allowed to launch the private AMI (ignored when <code>AMI_PUBLIC=true</code>)."
      },
      {
        "variable": "BASE_AMI_ID",
        "default": "(auto)",
        "description": "Skip the base-AMI rebuild and layer the stack on top of a compatible Elastic CI Stack base AMI. When unset, the Makefile reads the ID from the corresponding <code>packer-base-{platform}-{arch}.output</code> file if it exists."
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
> The agent version is pinned in `packer/linux/stack/scripts/install-buildkite-agent.sh` and `packer/windows/stack/scripts/install-buildkite-agent.ps1`. To change it, edit the `AGENT_VERSION` value in each script. The Packer targets read these pinned values, so setting `AGENT_VERSION` when running an image target does not override the installed version.

For example, you could build an AMD64 Linux image in the `eu-west-1` region using a smaller instance type and a specific AWS profile by running:

```bash
AMD64_INSTANCE_TYPE="t3.medium" \
AWS_REGION="eu-west-1" \
AWS_PROFILE="assets-profile" \
make packer-linux-amd64.output
```

### Common customization flows

Rebuild only the stack layer on top of an existing Elastic CI Stack base AMI:

```bash
BASE_AMI_ID=ami-0123456789abcdef0 \
  make packer-linux-amd64.output
```

The Linux stack template expects the source AMI to use the `ec2-user` SSH user and to include the packages and services installed by the [Linux base layer](#linux-base-ami). Standard Ubuntu AMIs use the `ubuntu` SSH user and do not provide all of those dependencies. To use an Ubuntu base AMI, change `ssh_username` in `packer/linux/stack/buildkite-ami.pkr.hcl` from `ec2-user` to `ubuntu`, then add provisioning for the required base-layer dependencies before applying the stack layer.

Build private AMIs and share them with specific AWS accounts:

```bash
AMI_PUBLIC=false \
AMI_USERS="111122223333,444455556666" \
  make packer
```

Build only the Linux AMIs (skip the Windows build):

```bash
make packer-base-linux-amd64.output packer-linux-amd64.output \
     packer-base-linux-arm64.output packer-linux-arm64.output
```
