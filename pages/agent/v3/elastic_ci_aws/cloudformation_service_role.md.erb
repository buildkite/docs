# CloudFormation Service Role

If you want to explicitly specify the actions CloudFormation can perform on
your behalf when deploying the Elastic CI Stack for AWS, you can create your
stack using an IAM User or Role that has been granted limited permissions, or
use an [AWS CloudFormation service role](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-iam-servicerole.html).

The Elastic CI Stack for AWS repository contains an experimental
[service role template](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/master/templates/service-role.yml).
This template creates an IAM Role and set of IAM Policies with the IAM Actions
necessary to create, update, and delete a CloudFormation Stack created with the
Elastic CI Stack template.

The IAM role created by this template is used to create and delete CloudFormation stacks in our
test suite, but it is likely that the permissions needed for some stack parameter permutations are
missing.

This template can be deployed as is, or used as the basis for your own
CloudFormation service role.

## Deploying the service role template

With a copy of the Elastic CI Stack for AWS repository, the service role
template can be deployed using the [AWS CLI](https://aws.amazon.com/cli/):

```bash
aws cloudformation deploy \
	--template-file templates/service-role.yml \
	--stack-name buildkite-elastic-ci-stack-service-role \
	--capabilities CAPABILITY_IAM
```

Once the stack has been created, the role ARN (Amazon Resource Name) can be retrieved using:

```bash
aws cloudformation describe-stacks \
	--stack-name buildkite-elastic-ci-stack-service-role \
	--query "Stacks[0].Outputs[?OutputKey=='RoleArn'].OutputValue" \
	--output text
```

This role ARN can be passed to an `aws cloudformation create-stack` invocation
as a value for the `--role-arn` flag.
