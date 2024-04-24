---
keywords: oidc, authentication, IAM, roles, AWS
---

# OIDC with AWS

The [Buildkite Agent's oidc command](/docs/agent/v3/cli-oidc) allows you to request an OIDC token representing the current job. These tokens can be exchanged with federated systems like AWS in exchange for an IAM role with AWS scoped permissions.

See the [OpenID Connect Core documentation](https://openid.net/specs/openid-connect-core-1_0.html#IDToken) for more information about how OIDC tokens are constructed and how to extract and use claims.

See the [AWS OpenID Connect identity provider in IAM documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) for more information on their implementation of the federated system.

We will be using two Buildkite Plugins to utilise OIDC with AWS and our Pipelines.

- Buildkite Plugin [aws-assume-role-with-web-identity-buildkite-plugin](https://github.com/buildkite-plugins/aws-assume-role-with-web-identity-buildkite-plugin)
- Buildkite Plugin [aws-ssm-buildkite-plugin](https://github.com/buildkite-plugins/aws-ssm-buildkite-plugin)

## Step 1: Setup OIDC provider in AWS account

First we'll set up an AWS IAM OpenID Connect (OIDC) provider using the following configuration.

  URL: `https://agent.buildkite.com`

  Audience: `sts.amazonaws.com`

## Step 2: Create a new (or update an existing) IAM role to use with your pipeline(s)

In this example the IAM role is named: `compute-ssm-oidc-example`. When creating the role you must `Select Custom Trust Policy`.

Set the Principal to be federated via the IAM OIDC provider we just created, and add some conditions against using this IAM role for additional security using the format of the OIDC token subject provided by Buildkite.

This allows us to limit use of this IAM role to named Organizations, Pipelines, and optionally branches, commits and steps. Format is
 `organization:ORGANIZATION_SLUG:pipeline:PIPELINE_SLUG:ref:REF:commit:BUILD_COMMIT:step:STEP_KEY`

You can use a wildcard `*` to replace any subjects you don’t want to set limits on.

You can also add multiple token subjects as a list if you want to use the same IAM role for multiple pipelines, or if you want a variety of branches, commits and steps enabled.

If you have a public IP address associated with your Buildkite Agent's, you can also set a condition on the source IP address and further restrict access to your IAM role.

Example Trust Policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn\:aws\:iam:\:AWS_ACCOUNT_ID\:oidc-provider/agent.buildkite.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "agent.buildkite.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "agent.buildkite.com:sub": "organization\:ORGANIZATION_SLUG\:pipeline:PIPELINE_SLUG\:ref\:REF\:commit\:BUILD_COMMIT\:step\:STEP_KEY"
                },
                "IpAddress": {
                    "aws:SourceIp": [
                        "AGENT_PUBLIC_IP_ONE",
                        "AGENT_PUBLIC_IP_TWO"
                    ]
                }

            }
        }
    ]
}
```

Update the following sections:

- In the Principal, replace `AWS_ACCOUNT_ID`  with your account ID.
- In the Condition on the subject, replace:

    * `ORGANIZATION_SLUG` with your Buildkite Organization
    * `PIPELINE_SLUG` with your Pipeline
    * `REF` - this is commonly replaced with `refs/heads/main` to enforce only the main branch using the IAM role  or `refs/tags/*` for only tagged releases able to deploy, or a wildcard if we want all branches to use it.
    * `BUILD_COMMIT` - this is commonly replaced with a wildcard `*`
    * `STEP_KEY` - this is commonly replaced with a wildcard `*`

- In the condition on the IP Address, replace `AGENT_PUBLIC_IP_ONE` and `AGENT_PUBLIC_IP_TWO` with a list of your Agent IP addresses.

Expanded example Trust Policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn\:aws\:iam:\:AWS_ACCOUNT_ID\:oidc-provider/agent.buildkite.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "agent.buildkite.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "agent.buildkite.com:sub": [
                        "organization\:example-org\:pipeline\:example-pipeline\:ref\:refs/heads/main\:*",
                        "organization\:example-org\:pipeline\:example-pipeline\:ref\:refs/tags/*:*"
                    ]
                },
                "IpAddress": {
                    "aws:SourceIp": [
                        "192.0.2.0",
                        "198.51.100.0"
                    ]
                }

            }
        }
    ]
}
```

## Step 3: Configure your IAM role with AWS actions

Add inline or managed IAM policies to the role to allow whatever IAM permissions your pipeline needs. Common examples are permissions to read secrets from SSM and push images to ECR, but there are no limitations here.

In this example we’ll allow access to read an SSM Parameter Store key named `/pipelines-compute/oidc/example-deploy-key` by attaching the following inline policy.

```json
{
  "Version": "2012-10-17",
  "Statement": [
     {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters"
            ],
            "Resource": "arn\:aws\:ssm\:us-east-1\:012345678910\:parameter/pipelines-compute/oidc/example-deploy-key"
        }
  ]
}
```

## Step 4: Configure your pipeline to assume the role

We’ll use two Buildkite Plugins to use the IAM role and to pull in the SSM parameter

- [aws-assume-role-with-web-identity-buildkite-plugin](https://github.com/buildkite-plugins/aws-assume-role-with-web-identity-buildkite-plugin)
- [aws-ssm-buildkite-plugin](https://github.com/buildkite-plugins/aws-ssm-buildkite-plugin)

This can be added to your Pipeline as follows

```yaml
agents:
  queue: mac-small

steps:
 -  label: "\:aws\: Deploy to Production"
    key: deploy-to-production
    command: echo "Example Deploy Key equals \$EXAMPLE_DEPLOY_KEY"
    env:
      AWS_DEFAULT_REGION: us-east-1
      AWS_REGION: us-east-1
    plugins:
      - aws-assume-role-with-web-identity:
          role-arn: arn\:aws\:iam::012345678910:role/compute-ssm-oidc-example
      - aws-ssm#v1.0.0:
          parameters:
            EXAMPLE_DEPLOY_KEY: /pipelines-compute/oidc/example-deploy-key
```
