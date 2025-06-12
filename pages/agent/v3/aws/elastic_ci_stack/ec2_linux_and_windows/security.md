# Security in the Elastic CI Stack for AWS

The [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws/) repository hasn't been reviewed by security researchers so exercise caution with what credentials you make available to your builds.

The S3 buckets that Buildkite Agent creates for secrets don't allow public access. The stack's default VPC configuration does provide EC2 instances with a public IPv4 address. If you wish to customize this, the best practice is to create your own VPC and provide values for the [Network Configuration](/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/template-parameters#network-configuration) template section:

* `VpcId`
* `Subnets`
* `AvailabilityZones`
* `SecurityGroupIds`

Anyone with commit access to your codebase (including third-party pull-requests if you've enabled them in Buildkite) also has access to your secrets bucket files.

Keep in mind the EC2 HTTP metadata server is available from within builds, which means builds act with the same IAM permissions as the instance.

## Network configuration

An Elastic CI Stack for AWS deployment contains an Auto Scaling group and a launch template. Together they boot instances in the default templated public subnet, or if you have configured them, into a set of VPC subnets.

After booting, the Elastic CI Stack for AWS instances require network access to [buildkite.com](https://buildkite.com/buildkite). This access can be provided by booting them in a VPC subnet with a routing table that has Internet connectivity, either directly using an Internet Gateway or indirectly using a NAT Instance or NAT Gateway.

By default, the template creates a public subnet VPC for your EC2 instances. The
VPC in which your stack's instances are booted can be customized using the `VpcId`,
and `Subnets` template parameters. If you choose to use a VPC with split
public/private subnets, the `AssociatePublicIpAddress` parameter can be used to
turn off public IP association for your instances. See the [VPC](/docs/agent/v3/aws/architecture/vpc)
documentation for guidance on choosing a VPC layout suitable for your use case.

### Limiting CloudFormation permissions

By default, CloudFormation will operate using the permissions granted to the
identity, AWS IAM User or Role, used to create or update a stack.

See [CloudFormation service role](/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/cloudformation-service-role)
for a listing of the IAM actions required to create, update, and delete a stack
with the Elastic CI Stack for AWS template.

### Default IAM policies

You're not required to create any special IAM roles or policies, though the deployment template creates several of these on your behalf. Some optional functionality does depend on IAM permission should you choose to enable them. For more information, see:

* [`buildkite-agent artifact` IAM Permissions](/docs/agent/v3/cli-artifact#using-your-private-aws-s3-bucket-iam-permissions), a policy to allow the Buildkite agent to read/write artifacts to a custom S3 artifact storage location
* [`BootstrapScriptUrl` IAM Policy](/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/managing-elastic-ci-stack#customizing-instances-with-a-bootstrap-script), a policy to allow the EC2 instances to read an S3-stored `BootstrapScriptUrl` object
* [Using AWS Secrets Manager](/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/secrets-manager) to store your Buildkite Agent token depends on a resource policy to grant read access to the Elastic CI Stack for AWS roles (the scaling Lambda and EC2 Instance Profile)

### Key creation

You don't need to create keys for the default deployment of Elastic CI Stack for AWS, but you can additionally create:

* KMS key to encrypt the AWS SSM Parameter that stores your Buildkite agent token
* KMS key for S3 SSE protection of secrets and artifacts
* SSH key or other git credentials to be able to clone private repositories and store them in the S3 secrets bucket and optionally encrypt them using S3 SSE)

Remember that such keys are not intended to be public, and you must not grant public access to them.

See also [Storing your Buildkite Agent token in AWS Secrets Manager](/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/secrets-manager).

## Build secrets

Learn more about build secrets in the [S3 secrets bucket](/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/secrets-bucket) page.
## Sensitive data

The following types of sensitive data are present in Elastic CI Stack for AWS:

* **Buildkite agent token credential** (`BuildkiteAgentToken`) retrieved from your Buildkite account. When provided to the deployment template, it is stored in plaintext in AWS SSM Parameter Store (there is no support for creating an encrypted SSM Parameter from CloudFormation). If you need to store it in encrypted form, you can create your own SSM Parameter and provide the `BuildkiteAgentTokenParameterStorePath` value along with `BuildkiteAgentTokenParameterStoreKMSKey` for decrypting it.

* **Secrets and artifacts** stored in S3. You can use server-side encryption (SSE) to control access to these objects.

* **Instance Storage working data** stored by EC2 instances (git checkouts or any other private resources you decide to retrieve) either on their EBS root disk or on the Instance Storage NVMe drives. The Elastic CI Stack for AWS deployment template does not support configuring EBS encryption.

CloudWatch Logs and EC2 instance log data are forwarded to CloudWatch Logs, but these logs don't contain sensitive information.
