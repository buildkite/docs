# Creating custom AMIs

Custom AMIs help teams ensure that their agents have all required tools and configurations before instance launch. This prevents instances from reverting to the base image state when agents restart, which would lose any manual changes made during run time.

Custom [AMIs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) can be used with the Elastic CI Stack for AWS by specifying the `ImageId` parameter. You can use any AMI available to your AWS account. For best results, start with Buildkite's base [Packer](https://developer.hashicorp.com/packer) templates. The Packer templates used to create the default stack images are available in the [packer directory](https://github.com/buildkite/elastic-ci-stack-for-aws/tree/main/packer) of the [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws) repository.

## Requirements

To use the Packer templates provided, you will need the following installed on your system:

- Docker
- Make
- AWS CLI

The following AWS IAM permissions are required to build custom AMIs using the provided packer templates:

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
        "description": "Build Windows Server 2019 (64-bit x86) AMI only"
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
        "description": "Build identifier passed to Packer"
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


For example, you could build an AMD64 Linux image in the `eu-west-1` region using a smaller instance type and a specific AWS profile by running:

```bash
AMD64_INSTANCE_TYPE="t3.medium" \
AWS_REGION="eu-west-1" \
AWS_PROFILE="assets-profile" \
make packer-linux-amd64.output
```

Once your image build is completed, the AMI will be stored in your AWS account and the AMI ID is displayed in your terminal output. You can also find the AMI ID in the corresponding output file (such as `packer-linux-amd64.output`).

