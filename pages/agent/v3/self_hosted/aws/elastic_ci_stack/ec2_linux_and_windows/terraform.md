# Terraform deployment for the Elastic CI Stack for AWS

The Elastic CI Stack for AWS can be deployed using Terraform instead of AWS CloudFormation.

> 📘 Prefer AWS CloudFormation?
> This guide uses Terraform. For AWS CloudFormation instructions, see the [AWS CloudFormation setup guide](/docs/agent/v3/self-hosted/aws/elastic_ci_stack/ec2_linux_and_windows/setup).

## Before you start

Deploying the Elastic CI Stack for AWS with Terraform requires [Terraform](https://www.terraform.io/downloads) version 1.0 or later and a Buildkite [Agent token](/docs/agent/v3/self-hosted/tokens).

For the information on getting started with Terraform, see HashiCorp's [Get Started with Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started) tutorial and the [AWS Provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) for configuring AWS credentials.

The module creates its own VPC by default. To deploy into an existing VPC, set the `vpc_id` and `subnets` variables.

## Deploying the stack

Create a `main.tf` file with the following configuration:

```terraform
terraform {
  required_version = ">= 1.0"
}

module "buildkite_stack" {
  source  = "buildkite/elastic-ci-stack-for-aws/buildkite"
  version = "~> 0.1.0"

  stack_name            = "buildkite"
  buildkite_agent_token = "your-agent-token-here"

  min_size = 0
  max_size = 10
}
```

Next, run the following commands to deploy the stack:

```bash
terraform init
terraform plan
terraform apply
```

## Configuration

The only required variable is `buildkite_agent_token`. For information on creating and managing agent tokens, see [Agent tokens](/docs/agent/v3/self-hosted/tokens).

For the complete list of variables and their descriptions, see the [module documentation](https://registry.terraform.io/modules/buildkite/elastic-ci-stack/aws) on the Terraform Registry or the [configuration parameters](/docs/agent/v3/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/configuration-parameters) reference.

## Example configurations

The Terraform module repository includes several example configurations. You can check out the following examples in the [examples directory](https://github.com/buildkite/terraform-buildkite-elastic-ci-stack-for-aws/tree/main/examples):

- [Basic](https://github.com/buildkite/terraform-buildkite-elastic-ci-stack-for-aws/tree/main/examples/basic)
- [Spot instances](https://github.com/buildkite/terraform-buildkite-elastic-ci-stack-for-aws/tree/main/examples/spot-instances)
- [Scheduled scaling](https://github.com/buildkite/terraform-buildkite-elastic-ci-stack-for-aws/tree/main/examples/scheduled-scaling)
- [Existing VPC](https://github.com/buildkite/terraform-buildkite-elastic-ci-stack-for-aws/tree/main/examples/existing-vpc)

## Updating the stack

To update to a newer version of the module, update the `version` constraint in your `main.tf`:

```terraform
module "buildkite_stack" {
  source  = "buildkite/elastic-ci-stack/aws"
  version = "0.1.0"

  # ... your configuration
}
```

Then run the following commands:

```bash
terraform init -upgrade
terraform plan
terraform apply
```

The Auto Scaling group will replace instances gradually during the update. Existing builds will complete before instances are terminated using the [Buildkite Agent Scaler](https://github.com/buildkite/buildkite-agent-scaler).

## Related documentation

For more information on configuring and managing the Elastic CI Stack for AWS, see:

- [Using AWS Secrets Manager](/docs/agent/v3/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security#using-aws-secrets-manager-in-the-elastic-ci-stack-for-aws) to configure secrets
- [Managing the Elastic CI Stack for AWS](/docs/agent/v3/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/managing-elastic-ci-stack) for operational tasks
- [Troubleshooting](/docs/agent/v3/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/troubleshooting) for resolving common issues
- [Terraform module reference](https://registry.terraform.io/modules/buildkite/elastic-ci-stack-for-aws/buildkite/latest) on the Terraform Registry
- [GitHub repository](https://github.com/buildkite/terraform-buildkite-elastic-ci-stack-for-aws) for the module source code
