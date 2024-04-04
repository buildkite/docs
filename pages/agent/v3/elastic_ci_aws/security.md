# Security in the Elastic CI Stack for AWS

The [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws/) repository hasn't been reviewed by security researchers so exercise caution with what credentials you make available to your builds.

The S3 buckets that Buildkite Agent creates for secrets don't allow public access. The stack's default VPC configuration does provide EC2 instances with a public IPv4 address. If you wish to customize this, the best practice is to create your own VPC and provide values for the [Network Configuration](/docs/agent/v3/elastic-ci-aws/parameters#network-configuration) template section:

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
turn off public IP association for your instances. See the [VPC](/docs/agent/v3/aws/vpc)
documentation for guidance on choosing a VPC layout suitable for your use case.

### Limiting CloudFormation permissions

By default, CloudFormation will operate using the permissions granted to the
identity, AWS IAM User or Role, used to create or update a stack.

See [CloudFormation service role](/docs/agent/v3/elastic-ci-aws/cloudformation-service-role)
for a listing of the IAM actions required to create, update, and delete a stack
with the Elastic CI Stack for AWS template.

### Default IAM policies

You're not required to create any special IAM roles or policies, though the deployment template creates several of these on your behalf. Some optional functionality does depend on IAM permission should you choose to enable them. For more information, see:

* [`buildkite-agent artifact` IAM Permissions](/docs/agent/v3/cli-artifact#using-your-private-aws-s3-bucket-iam-permissions), a policy to allow the Buildkite agent to read/write artifacts to a custom S3 artifact storage location
* [`BootstrapScriptUrl` IAM Policy](/docs/agent/v3/elastic-ci-aws/managing-elastic-ci-stack#customizing-instances-with-a-bootstrap-script), a policy to allow the EC2 instances to read an S3-stored `BootstrapScriptUrl` object
* [Using AWS Secrets Manager](/docs/agent/v3/aws/secrets-manager) to store your Buildkite Agent token depends on a resource policy to grant read access to the Elastic CI Stack for AWS roles (the scaling Lambda and EC2 Instance Profile)

### Key creation

You don't need to create keys for the default deployment of Elastic CI Stack for AWS, but you can additionally create:

* KMS key to encrypt the AWS SSM Parameter that stores your Buildkite agent token
* KMS key for S3 SSE protection of secrets and artifacts
* SSH key or other git credentials to be able to clone private repositories and store them in the S3 secrets bucket and optionally encrypt them using S3 SSE)

Remember that such keys are not intended to be public, and you must not grant public access to them.

See also [Storing your Buildkite Agent token in AWS Secrets Manager](/docs/agent/v3/aws/secrets-manager).

## Build secrets

The stack creates an S3 bucket for you (or uses the one you provide as the `SecretsBucket` parameter). This is where the agent fetches your SSH private keys for source control, and environment hooks to provide other secrets to your builds.

The following S3 objects are downloaded and processed:

* `/env` - An [agent environment hook](/docs/agent/hooks)
* `/private_ssh_key` - A private key that is added to ssh-agent for your builds
* `/git-credentials` - A [git-credentials](https://git-scm.com/docs/git-credential-store#_storage_format) file for git over https
* `/{pipeline-slug}/env` - An [agent environment hook](/docs/agent/hooks), specific to a pipeline
* `/{pipeline-slug}/private_ssh_key` - A private key that is added to ssh-agent for your builds, specific to the pipeline
* `/{pipeline-slug}/git-credentials` - A [git-credentials](https://git-scm.com/docs/git-credential-store#_storage_format) file for git over https, specific to a pipeline
* When provided, the environment variable `BUILDKITE_PLUGIN_S3_SECRETS_BUCKET_PREFIX` will overwrite `{pipeline-slug}`

These files are encrypted using [Amazon's KMS Service](https://aws.amazon.com/kms/).

Here's an example that shows how to generate a private SSH key, and upload it with KMS encryption to an S3 bucket:

```bash
# generate a deploy key for your project
ssh-keygen -t rsa -b 4096 -f id_rsa_buildkite
pbcopy < id_rsa_buildkite.pub # paste this into your github deploy key

aws s3 cp --acl private --sse aws:kms id_rsa_buildkite "s3://${SecretsBucket}/private_ssh_key"
```

If you want to set secrets that your build can access, create a file that sets environment variables and upload it:

```bash
echo "export MY_ENV_VAR=something secret" > myenv
aws s3 cp --acl private --sse aws:kms myenv "s3://${SecretsBucket}/env"
rm myenv
```

<!-- date -->

>📘
> Currently (as of June 2021), you must use the default KMS key for S3. Follow <a href="https://github.com/buildkite/elastic-ci-stack-for-aws/issues/235" target="_blank">issue #235</a> for progress on using specific KMS keys.

If you want to store your secrets unencrypted, you can disable encryption entirely by setting `BUILDKITE_USE_KMS=false` in your Elastic CI Stack for AWS configuration.

## Sensitive data

The following types of sensitive data are present in Elastic CI Stack for AWS:

* **Buildkite agent token credential** (`BuildkiteAgentToken`) retrieved from your Buildkite account. When provided to the deployment template, it is stored in plaintext in AWS SSM Parameter Store (there is no support for creating an encrypted SSM Parameter from CloudFormation). If you need to store it in encrypted form, you can create your own SSM Parameter and provide the `BuildkiteAgentTokenParameterStorePath` value along with `BuildkiteAgentTokenParameterStoreKMSKey` for decrypting it.

* **Secrets and artifacts** stored in S3. You can use server-side encryption (SSE) to control access to these objects.

* **Instance Storage working data** stored by EC2 instances (git checkouts or any other private resources you decide to retrieve) either on their EBS root disk or on the Instance Storage NVMe drives. The Elastic CI Stack for AWS deployment template does not support configuring EBS encryption.

CloudWatch Logs and EC2 instance log data are forwarded to CloudWatch Logs, but these logs don't contain sensitive information.
