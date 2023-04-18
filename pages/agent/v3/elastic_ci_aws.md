# Linux and Windows setup for the Elastic CI Stack for AWS

The Buildkite Elastic CI Stack for AWS gives you a private, autoscaling [Buildkite agent](/docs/agent/v3) cluster. Use it to parallelize large test suites across hundreds of nodes, run tests and deployments for Linux or Windows based services and apps, or run AWS ops tasks.

See the [Elastic CI Stack for AWS tutorial](/docs/tutorials/elastic_ci_stack_aws) for a step-by-step guide, or jump straight in:

<!-- vale off -->
<!-- alex ignore master -->

<a href="https://console.aws.amazon.com/cloudformation/home#/stacks/new?stackName=buildkite&templateURL=https://s3.amazonaws.com/buildkite-aws-stack/latest/aws-stack.yml"><%= image "launch-stack.svg", alt: "Launch stack button" %></a>

<!-- vale on -->


## Before you start

> Elastic CI Stack for AWS creates its own VPC (virtual private cloud) by default. Best practice is to set up a separate development AWS account and use role switching and consolidated billing. You can check out this external tutorial for more information on how to ["Delegate Access Across AWS Accounts"](http://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html).

See [Template parameters in the Elastic CI Stack for AWS](/docs/agent/v3/elastic_ci_aws/parameters) for details on the template parameters.

If you want to use the [AWS CLI](https://aws.amazon.com/cli/) instead, download [`config.json.example`](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/master/config.json.example), rename it to `config.json`, add your Buildkite Agent token (and any other config values), and then run the below command:

```bash
aws cloudformation create-stack \
  --output text \
  --stack-name buildkite \
  --template-url "https://s3.amazonaws.com/buildkite-aws-stack/latest/aws-stack.yml" \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --parameters "$(cat config.json)"
```

## What's on each machine?


<!-- vale off -->

* [Amazon Linux 2](https://aws.amazon.com/amazon-linux-2/)
* [Buildkite Agent v3.44.0](https://buildkite.com/docs/agent)
* [Git v2.39.1](https://git-scm.com/) and [Git LFS v3.3.0](https://git-lfs.com/)
* [Docker](https://www.docker.com) - v20.10.23 (Linux) and v20.10.9 (Windows)
* [Docker Compose](https://docs.docker.com/compose/) - v1.29.2 and v2.16.0 (Linux) and v1.29.2 (Windows)
* [AWS CLI](https://aws.amazon.com/cli/) - useful for performing any ops-related tasks
* [jq](https://stedolan.github.io/jq/) - useful for manipulating JSON responses from CLI tools such as AWS CLI or the Buildkite API

<!-- vale on -->

On both Linux and Windows, the Buildkite agent runs as user `buildkite-agent`.



> TODO: INCORPORATE TUTORIAL CONTENT HERE. Move images, remove tutorial page, redirect tutorial page to here.






## Further references

To gain a better understanding of how Elastic CI Stack for AWS works and how to use it most effectively and securely, check out the following resources:

* [Elastic CI Stack for AWS tutorial](/docs/tutorials/elastic-ci-stack-aws)
* [Running Buildkite Agent on AWS](/docs/agent/v3/aws)
* [GitHub repo for Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws)
* [Template parameters for Elastic CI Stack for AWS](/docs/agent/v3/elastic-ci-aws/parameters)
* [Using AWS Secrets Manager](/docs/agent/v3/aws/secrets-manager)
* [VPC Design](/docs/agent/v3/aws/vpc)
* [CloudFormation service role](/docs/agent/v3/elastic-ci-aws/cloudformation-service-role)
