---
toc: false
---

# S3 secrets bucket

The Elastic CI Stack for AWS creates an S3 bucket for you (or uses the one you provide as the `SecretsBucket` parameter). This is where the agent fetches your private SSH keys for source control and environment variables that provide other secrets to your builds.

The following S3 objects are downloaded and processed:

* `/env` or `/environment` - a file that contains environment variables in the format `KEY=VALUE`
* `/private_ssh_key` - a private SSH key that is added to ssh-agent for your builds
* `/git-credentials` - a [git-credentials](https://git-scm.com/docs/git-credential-store#_storage_format) file for git over HTTPS
* `/secret-files/*` - individual secret files that are loaded as environment variables ([Individual secret files](#individual-secret-files))
* `/{pipeline-slug}/env` or `/{pipeline-slug}/environment` - a file that contains environment variables specific to a pipeline, in the format `KEY=VALUE`
* `/{pipeline-slug}/private_ssh_key` - a private SSH key that is added to ssh-agent for your builds, specific to the pipeline
* `/{pipeline-slug}/git-credentials` - a [git-credentials](https://git-scm.com/docs/git-credential-store#_storage_format) file for git over HTTPS, specific to a pipeline
* `/{pipeline-slug}/secret-files/*` - individual secret files that are loaded as environment variables, specific to a pipeline ([Individual secret files](#individual-secret-files))
* When provided, the environment variable `BUILDKITE_PLUGIN_S3_SECRETS_BUCKET_PREFIX` overrides `{pipeline-slug}`

These files are encrypted using [AWS KMS](https://aws.amazon.com/kms/).

> 🚧 Sourcing of environment variable files
> The agent sources files such as `/env` or `/{pipeline-slug}/environment`. It is possible to include a shell script that will be executed by the agent in these files. However, including shell scripts in these files should be used with caution, as it can lead to unexpected behavior.

## Using your own S3 bucket

By default, the Elastic CI Stack for AWS creates a new S3 bucket for secrets. To use an existing S3 bucket instead, specify the following parameters when creating or updating your CloudFormation stack:

* `SecretsBucket` - the name of your existing S3 bucket
* `SecretsBucketRegion` - the AWS region where your bucket is located (for example, `us-east-1`)

When using your own bucket, the Elastic CI Stack for AWS uses it as-is without modifying encryption settings. Your bucket must allow the stack's IAM role to read objects. The Elastic CI Stack for AWS automatically configures the necessary permissions for agents to access the bucket.

The `SecretsBucketEncryption` parameter only applies when the Elastic CI Stack for AWS creates a new bucket. When set to `true`, it enforces encryption at rest and in transit on the created bucket.

## Uploading secrets

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

> 📘 KMS key limitation
> Currently (as of June 2021), you must use the default KMS key for S3. Follow [issue #235](https://github.com/buildkite/elastic-ci-stack-for-aws/issues/235) for progress on using specific KMS keys.

To store your secrets unencrypted, set the `BUILDKITE_USE_KMS` environment variable to `false` in your agent configuration or environment hook.

## Individual secret files

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

## Configuration options

### Suppressing SSH key warnings

The Elastic CI Stack for AWS provides several configuration options to customize agent behavior.


By default, if your repository uses SSH for transport (the repository URL starts with `git@`) and no SSH key is found in the secrets bucket, the agent displays a warning message. You can suppress this warning using one of the following methods.

#### Using a CloudFormation parameter

Set the `SecretsPluginSkipSSHKeyNotFoundWarning` parameter to `true` when creating or updating your CloudFormation stack. This configures the warning suppression for all agents in the stack.

#### Using an environment variable

Set the `BUILDKITE_PLUGIN_S3_SECRETS_SKIP_SSH_KEY_NOT_FOUND_WARNING` environment variable to `true` in your pipeline configuration or agent environment hook:

```bash
BUILDKITE_PLUGIN_S3_SECRETS_SKIP_SSH_KEY_NOT_FOUND_WARNING=true
```

Use these options when managing SSH keys through alternative methods such as agent hooks or container images.
