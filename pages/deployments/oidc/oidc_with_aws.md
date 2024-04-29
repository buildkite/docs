---
keywords: oidc, authentication, IAM, roles, AWS
---

# OIDC with AWS

The [Buildkite Agent's oidc command](/docs/agent/v3/cli-oidc) allows you to request an OpenID Connect (OIDC) token representing the current job. These tokens can be exchanged on federated systems like AWS for an Identity and Access Management (IAM) role with AWS-scoped permissions.

This process uses the following Buildkite plugins to implement OIDC with AWS and Buildkite pipelines:

- [AWS assume-role-with-web-identity](https://github.com/buildkite-plugins/aws-assume-role-with-web-identity-buildkite-plugin)
- [AWS SSM Buildkite Plugin](https://github.com/buildkite-plugins/aws-ssm-buildkite-plugin)

Learn more about:

- How OIDC tokens are constructed and how to extract and use claims in the [OpenID Connect Core documentation](https://openid.net/specs/openid-connect-core-1_0.html#IDToken).

- Amazon's implementation of OIDC with their federated system in the [AWS OpenID Connect identity provider in IAM documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html).

## Step 1: Set up an OIDC provider in your AWS account

First, you'll need to set up an IAM OIDC provider in your AWS account.

Learn more about how to do this in the [Create an OpenID Connect (OIDC) identity provider in IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) page of the AWS documentation.

On this page, as part of the [Creating and managing an OIDC provider (console)](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html#manage-oidc-provider-console) process, specify the following values for the:

- **Provider URL**: `https://agent.buildkite.com`

- **Audience**: `sts.amazonaws.com`

## Step 2: Create a new (or update an existing) IAM role to use with your pipelines

Creating new or updating existing IAM roles is conducted through your AWS account.

Learn more about how to do this in the [Creating a role using custom trust policies (console)](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-custom.html) page of the AWS documentation.

As part of this process:

1. Choose the **Custom trust policy** role type.

1. Copy the following example trust policy in the following JSON code block and paste it into an code editor:

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

1. Modify the following sections of the pasted code snippet accordingly:
    * `AWS_ACCOUNT_ID` (in `Principal`) is your AWS account ID.
    * next item

1. In the **Custom trust policy** section,

1. Specify an appropriate **Role name**, for example, `compute-ssm-oidc-example`.

Set the Principal to be federated via the IAM OIDC provider we just created, and add some conditions against using this IAM role for additional security using the format of the OIDC token subject provided by Buildkite.

This allows us to limit use of this IAM role to named Organizations, Pipelines, and optionally branches, commits and steps. Format is
 `organization:ORGANIZATION_SLUG:pipeline:PIPELINE_SLUG:ref:REF:commit:BUILD_COMMIT:step:STEP_KEY`

You can use a wildcard `*` to replace any subjects you don’t want to set limits on.

You can also add multiple token subjects as a list if you want to use the same IAM role for multiple pipelines, or if you want a variety of branches, commits and steps enabled.

If you have a public IP address associated with your Buildkite Agent's, you can also set a condition on the source IP address and further restrict access to your IAM role.

Update the following sections:

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

Add an inline or managed IAM policy to the role to allow the IAM role to perform any actions your pipeline needs. Common examples are permissions to read secrets from SSM and push images to ECR, but this entirely depends on the purpose of your Pipeline.

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
      - aws-assume-role-with-web-identity#v1.0.0:
          role-arn: arn\:aws\:iam::012345678910:role/compute-ssm-oidc-example
      - aws-ssm#v1.0.0:
          parameters:
            EXAMPLE_DEPLOY_KEY: /pipelines-compute/oidc/example-deploy-key
```
