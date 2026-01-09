# Security in the Elastic CI Stack for AWS

The [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws/) repository hasn't been reviewed by security researchers so exercise caution with what credentials you make available to your builds.

The S3 buckets that Buildkite Agent creates for secrets don't allow public access. The stack's default VPC configuration does provide EC2 instances with a public IPv4 address. If you wish to customize this, the best practice is to create your own VPC and provide values for the [Network Configuration](/docs/agent/v3/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/configuration-parameters#network-configuration) parameters:

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
turn off public IP association for your instances. See the [VPC](/docs/agent/v3/self-hosted/aws/architecture/vpc)
documentation for guidance on choosing a VPC layout suitable for your use case.

### Limiting CloudFormation permissions

By default, CloudFormation will operate using the permissions granted to the
identity, AWS IAM User or Role, used to create or update a stack.

See [CloudFormation service role](/docs/agent/v3/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/setup#cloudformation-service-role)
for a listing of the IAM actions required to create, update, and delete a stack
with the Elastic CI Stack for AWS template.

### Default IAM policies

You're not required to create any special IAM roles or policies, though the deployment template creates several of these on your behalf. Some optional functionality does depend on IAM permission should you choose to enable them. For more information, see:

* [`buildkite-agent artifact` IAM Permissions](/docs/agent/v3/cli-artifact#using-your-private-aws-s3-bucket-iam-permissions), a policy to allow the Buildkite agent to read/write artifacts to a custom S3 artifact storage location
* [`BootstrapScriptUrl` IAM Policy](/docs/agent/v3/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/managing-elastic-ci-stack#customizing-instances-with-a-bootstrap-script), a policy to allow the EC2 instances to read an S3-stored `BootstrapScriptUrl` object
* Using AWS Secrets Manager to store your Buildkite Agent token depends on a resource policy to grant read access to the Elastic CI Stack for AWS roles (the scaling Lambda and EC2 Instance Profile)

### Key creation

You don't need to create keys for the default deployment of Elastic CI Stack for AWS, but you can additionally create:

* KMS key to encrypt the AWS SSM Parameter that stores your Buildkite agent token
* KMS key for S3 SSE protection of secrets and artifacts
* SSH key or other git credentials to be able to clone private repositories and store them in the S3 secrets bucket and optionally encrypt them using S3 SSE)

Remember that such keys are not intended to be public, and you must not grant public access to them.

## Sensitive data

The following types of sensitive data are present in Elastic CI Stack for AWS:

* **Buildkite agent token credential** (`BuildkiteAgentToken`) retrieved from your Buildkite account. When provided to the deployment template, it is stored in plaintext in AWS SSM Parameter Store (there is no support for creating an encrypted SSM Parameter from CloudFormation). If you need to store it in encrypted form, you can create your own SSM Parameter and provide the `BuildkiteAgentTokenParameterStorePath` value along with `BuildkiteAgentTokenParameterStoreKMSKey` for decrypting it.

* **Secrets and artifacts** stored in S3. You can use server-side encryption (SSE) to control access to these objects.

* **Instance Storage working data** stored by EC2 instances (git checkouts or any other private resources you decide to retrieve) either on their EBS root disk or on the Instance Storage NVMe drives. The Elastic CI Stack for AWS deployment template does not support configuring EBS encryption.

CloudWatch Logs and EC2 instance log data are forwarded to CloudWatch Logs, but these logs don't contain sensitive information.

## Using AWS Secrets Manager in the Elastic CI Stack for AWS

The Elastic CI Stack for AWS supports reading a Buildkite Agent token from
the AWS Systems Manager Parameter Store. The token can be stored in a plaintext
parameter, or encrypted with a KMS Key for access control purposes. You can also store your Buildkite Agent token using AWS Secrets Manager if
you need the advanced functionality it offers over the Parameter
Store.

For example, AWS Secrets Manager can automatically rotate and
revoke secrets using Lambda functions, and replicate secrets across multiple
regions in your account.

### Storing agent tokens

To store your Buildkite Agent token as an AWS Secrets
Manager secret, configure the Elastic CI Stack for AWS's
`BuildkiteAgentTokenParameterStorePath` parameter to reference your secret with
the special parameter path `/aws/reference/secretsmanager/your_Secrets_Manager_secret_ID`.
Parameter Store will transparently fetch the token from AWS Secrets
Manager when this parameter is read.

See the AWS documentation on [Referencing AWS Secrets Manager secrets from Parameter Store parameters](https://docs.aws.amazon.com/systems-manager/latest/userguide/integration-ps-secretsmanager.html)
for more details.

To ensure your Elastic CI Stack for AWS has access to the secret:

* Provide the Key ID (not the alias) used to encrypt the Secrets Manager secret to the `BuildkiteAgentTokenParameterStoreKMSKey` parameter. An IAM policy with `kms:Decrypt` permission for this key is included in the CloudFormation template.
* Use the CloudFormation stacks' *Resources* tab to find the `AutoscalingLambdaExecutionRole` and `IAMRole` roles, use their Amazon Resource Name (ARN) in the policy below.
* Secret Manager will capture a role's Unique ID when saving the resource policy; if you re-create the IAM role you must save the resource policy again to grant access.
* Use the Secret Manager secret's resource policy to grant `secretsmanager:GetSecretValue` permission to both the instance IAM role and the scaling Lambda IAM Role.

```json
{
  "Version" : "2012-10-17",
  "Statement" : [ {
    "Effect" : "Allow",
    "Principal" : {
      "AWS" : [
        "arn\:aws\:iam::[redacted]:role/buildkite-stack-AutoscalingLambdaExecutionRole",
        "arn\:aws\:iam::[redacted]:role/buildkite-stack-Role"
      ]
    },
    "Action" : "secretsmanager:GetSecretValue",
    "Resource" : "*"
  } ]
}
```

### Multi-region replication

It is also possible to replicate your Buildkite Agent token to multiple regions
using AWS Secret Manager's [multi-region replication](https://docs.aws.amazon.com/secretsmanager/latest/userguide/create-manage-multi-region-secrets.html). You
can then deploy an Elastic CI Stack for AWS to each region and use the Parameter Store
reference path to read the secret from the regionally replicated secret.

Some additional points to keep in mind when using multi-region replication:

* Ensure each region's IAM role has `ssm:GetParameter` permission for the region
it will be retrieving the secret from.
  + By default, the template will grant permission to only the region it is
    deployed to, limiting the role's utility to the stack's region. This isn't a
    problem but a caveat to be aware of. Don't expect to use the same role in
    multiple regions.
* Ensure each region's IAM role has `kms:Decrypt` permission for the key used to
encrypt the secret in that region.
  + You can do this with the AWS Secrets Manager key in Secrets
    Manager, and looking up the underlying CMK ID of that key alias in each
    region the stack template is deployed to. Provide that value for the
    `BuildkiteAgentTokenParameterStoreKMSKey` parameter for the stack in that
    region.
* Apply a resource policy to the primary Secrets Manager secret that grants
`secretsmanager:GetSecretValue` for each region's IAM role and wait for that to
be replicated.

Now, changes to the agent token secret (either made by hand or using Automatic
Secret Rotation) will be replicated from the primary region to each replica
region.

The Elastic CI Stack for AWS will only retrieve the Buildkite Agent token once when the
instance boots. You should [refresh your Auto Scaling Group instances](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-instance-refresh.html)
after rotating and replicating the secret, and before revoking the old token.

## S3 secrets bucket

The Elastic CI Stack for AWS creates an S3 bucket for you (or uses the one you provide as the `SecretsBucket` parameter). This is where the agent fetches your private SSH keys for source control and environment variables that provide other secrets to your builds.

### S3 secret paths

The following S3 objects are downloaded and processed:

* `/env` or `/environment` - a file that contains environment variables in the format `KEY=VALUE`
* `/private_ssh_key` - a private SSH key that is added to ssh-agent for your builds
* `/git-credentials` - a [git-credentials](https://git-scm.com/docs/git-credential-store#_storage_format) file for git over HTTPS
* `/secret-files/*` - individual secret files that are loaded as environment variables ([Individual secret files](#s3-secrets-bucket-individual-secret-files))
* `/{pipeline-slug}/env` or `/{pipeline-slug}/environment` - a file that contains environment variables specific to a pipeline, in the format `KEY=VALUE`
* `/{pipeline-slug}/private_ssh_key` - a private SSH key that is added to ssh-agent for your builds, specific to the pipeline
* `/{pipeline-slug}/git-credentials` - a [git-credentials](https://git-scm.com/docs/git-credential-store#_storage_format) file for git over HTTPS, specific to a pipeline
* `/{pipeline-slug}/secret-files/*` - individual secret files that are loaded as environment variables, specific to a pipeline ([Individual secret files](#s3-secrets-bucket-individual-secret-files))
* When provided, the environment variable `BUILDKITE_PLUGIN_S3_SECRETS_BUCKET_PREFIX` overrides `{pipeline-slug}`

These files are encrypted using [AWS KMS](https://aws.amazon.com/kms/).

> 🚧 Sourcing of environment variable files
> The agent sources files such as `/env` or `/{pipeline-slug}/environment`. It is possible to include a shell script that will be executed by the agent in these files. However, including shell scripts in these files should be used with caution, as it can lead to unexpected behavior.

### Using your own S3 bucket

By default, the Elastic CI Stack for AWS creates a new S3 bucket for secrets. To use an existing S3 bucket instead, specify the following parameters when creating or updating your CloudFormation stack:

* `SecretsBucket` - the name of your existing S3 bucket
* `SecretsBucketRegion` - the AWS region where your bucket is located (for example, `us-east-1`)

When using your own bucket, the Elastic CI Stack for AWS uses it as-is without modifying encryption settings. Your bucket must allow the stack's IAM role to read objects. The Elastic CI Stack for AWS automatically configures the necessary permissions for agents to access the bucket.

The `SecretsBucketEncryption` parameter only applies when the Elastic CI Stack for AWS creates a new bucket. When set to `true`, it enforces encryption at rest and in transit on the created bucket.

### Uploading secrets

To generate a private SSH key and upload it with KMS encryption to an S3 bucket:

```bash
# generate a deploy key for your project
ssh-keygen -t rsa -b 4096 -f id_rsa_buildkite
pbcopy < id_rsa_buildkite.pub # add this to your GitHub repository's deploy keys

aws s3 cp --acl private --sse aws:kms id_rsa_buildkite "s3://${SecretsBucket}/private_ssh_key"
```

To set secrets that your builds can access, create a file that sets environment variables and upload it:

```bash
echo "export MY_ENV_VAR=something secret" > myenv
aws s3 cp --acl private --sse aws:kms myenv "s3://${SecretsBucket}/env"
rm myenv
```

> 📘
> Currently only the default KMS key for S3 is supported.

### Individual secret files

You can store individual secrets as separate S3 objects under the `/secret-files/` prefix. This approach helps you manage multiple secrets independently from the environment variable files (`/env` or `/environment`).

Individual secret files must have a filename that ends with one of the following suffixes:

* `_SECRET`
* `_SECRET_KEY`
* `_PASSWORD`
* `_TOKEN`
* `_ACCESS_KEY`

The filename (without the path) becomes the environment variable name, and the file contents become the environment variable value.

To upload a secret that will be available as `DATABASE_PASSWORD`:

```bash
echo "my-database-password" > DATABASE_PASSWORD
aws s3 cp --acl private --sse aws:kms DATABASE_PASSWORD "s3://${SecretsBucket}/secret-files/DATABASE_PASSWORD"
rm DATABASE_PASSWORD
```

To use pipeline-specific secret files, include the pipeline slug in the path. Replace `{pipeline-slug}` with your actual pipeline slug:

```bash
aws s3 cp --acl private --sse aws:kms API_TOKEN "s3://${SecretsBucket}/{pipeline-slug}/secret-files/API_TOKEN"
```

### Configuration options for suppressing SSH key warnings

By default, if your repository uses SSH for transport (the repository URL starts with `git@`) and no SSH key is found in the secrets bucket, the agent will display a warning message. You can suppress this warning using one of the following methods. Use these methods when managing SSH keys through alternative methods such as agent hooks or container images.

#### Using a CloudFormation parameter

Set the `SecretsPluginSkipSSHKeyNotFoundWarning` parameter to `true` when creating or updating your CloudFormation stack. This configures the warning suppression for all agents in the stack.

#### Using an environment variable

Set the `BUILDKITE_PLUGIN_S3_SECRETS_SKIP_SSH_KEY_NOT_FOUND_WARNING` environment variable to `true` in your pipeline configuration or agent environment hook:

```bash
BUILDKITE_PLUGIN_S3_SECRETS_SKIP_SSH_KEY_NOT_FOUND_WARNING=true
```
