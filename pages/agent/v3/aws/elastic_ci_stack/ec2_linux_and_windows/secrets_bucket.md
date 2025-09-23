---
toc: false
---

# S3 secrets bucket

The stack creates an S3 bucket for you (or uses the one you provide as the `SecretsBucket` parameter). This is where the agent fetches your SSH private keys for source control, and environment variables to provide other secrets to your builds.

The following S3 objects are downloaded and processed:

* `/env` or `/environment` - a file that contains environment variables, in the format of `KEY=VALUE`
* `/private_ssh_key` - a private key that is added to ssh-agent for your builds
* `/git-credentials` - a [git-credentials](https://git-scm.com/docs/git-credential-store#_storage_format) file for git over https
* `/{pipeline-slug}/env` or `/{pipeline-slug}/environment` - a file that contains environment variables, specific to a pipeline, in the format of `KEY=VALUE`
* `/{pipeline-slug}/private_ssh_key` - a private key that is added to ssh-agent for your builds, specific to the pipeline
* `/{pipeline-slug}/git-credentials` - a [git-credentials](https://git-scm.com/docs/git-credential-store#_storage_format) file for git over https, specific to a pipeline
* When provided, the environment variable `BUILDKITE_PLUGIN_S3_SECRETS_BUCKET_PREFIX` will overwrite `{pipeline-slug}`

These files are encrypted using [Amazon's KMS Service](https://aws.amazon.com/kms/).

> 🚧 Sourcing of environment variable files
> Files such as `/env` or `/{pipeline-slug}/environment` are sourced. It is possible to include a shell script that will be executed by the agent in these files. However, including shell scripts in these files should be used with caution, as it can lead to unexpected behavior.

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
