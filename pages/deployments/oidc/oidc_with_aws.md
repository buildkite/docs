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

1. Copy the following example trust policy in the following JSON code block and paste it into a code editor:

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

1. Modify the `Principal` section of the pasted code snippet accordingly:
    1. Ensure that this is set to `Federated`, and points to the `oidc-provider` Amazon Resource Name (ARN) from the **Provider URL** you [configured above](#step-1-set-up-an-oidc-provider-in-your-aws-account) (that is, `agent.buildkite.com`).
    1. Change `AWS_ACCOUNT_ID` to your actual AWS account ID.

1. Modify the `Condition` section of the code snippet accordingly:
    1. Ensure the `StringEquals` subsection's _audience_ field name (your provider URL appended by `:aud`—`agent.buildkite.com:aud`) has a value that matches the **Audience** you [configured above](#step-1-set-up-an-oidc-provider-in-your-aws-account) (that is, `sts.amazonaws.com`).
    1. Ensure the `StringLike` subsection's _subject_ field name (your provider URL appended by `:sub`—`agent.buildkite.com:sub`) has at least one value that matches the format: `organization:ORGANIZATION_SLUG:pipeline:PIPELINE_SLUG:ref:REF:commit:BUILD_COMMIT:step:STEP_KEY`, where the constituent fields of this line determine the conditions (that is, when the values specified in these constituent fields have been met) under which the IAM role is granted in exchange for the OIDC token. The following constituent field's value:
        - `ORGANIZATION_SLUG` can be obtained:

            * From the end of your Buildkite URL, after accessing **Pipelines** in the global navigation of your organization in Buildkite.

            * By running the [List organizations](/docs/apis/rest-api/organizations#list-organizations) REST API query to obtain this value from `slug` in the response. For example:

                ```bash
                curl - X GET "https://api.buildkite.com/v2/organizations" \
                  -H "Authorization: Bearer $TOKEN"
                ```
        - `PIPELINE_SLUG` can be obtained:

            * From the end of your Buildkite URL, after accessing **Pipelines** in the global navigation of your organization in Buildkite, then accessing the specific pipeline to be specified in the custom trust policy.

            * By running the [List pipelines](/docs/apis/rest-api/pipelines#list-pipelines) REST API query to obtain this value from `slug` in the response from the specific pipeline. For example:

                ```bash
                curl - X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines" \
                  -H "Authorization: Bearer $TOKEN"
                ```
        - `REF` is usually replaced with `refs/heads/main` to enforce the IAM role's access and use to only the `main` branch, `refs/tags/*` to ensure only tagged releases are able to be deployed, or a wildcard `*` if the IAM role can be accessed and used by all branches.
        - `BUILD_COMMIT` (optional) can be omitted and if so, is usually replaced with a single wildcard `*` at the end of the line.
        - `STEP_KEY` (optional) can be omitted and if so, is usually replaced with a single wildcard `*` at the end of the line.

    **Note:** When formulating your _subject_ field's value, you can replace any of the constituent field values above with a wildcard `*` to not set limits on those constituent fields.

    You can also allow this IAM role to be used with other pipelines, branches, commits and steps by specifying multiple comma-separated values for the `agent.buildkite.com:sub` _subject_ field.

    For example, to allow the IAM role to be used for any pipeline in the Buildkite organization `example-org`, when building on any branch or tag, specify a single _subject_ field value of `organization:example-org:pipeline:*:ref:refs:*`.

1. Modify the `Condition` section's `IpAddress` values (`AGENT_PUBLIC_IP_ONE` and `AGENT_PUBLIC_IP_TWO`) with a list of your agent's IP addresses.

    Only OIDC token exchange requests (for IAM roles) from Buildkite Agents with these IP addresses will be permitted.

1. Verify that your custom trust policy is complete. The following example trust policy (noting that `AWS_ACCOUNT_ID` has not been specified) will only allow the exchange of an agent's OIDC tokens with IAM roles when:
    * the Buildkite organization is `example-org`
    * building on both the `main` branch and tagged releases
    * on Buildkite Agents whose IP addresses are either `192.0.2.0` or `198.51.100.0`

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
                            "organization\:example-org\:pipeline\:example-pipeline\:ref:refs/heads/main:*",
                            "organization\:example-org\:pipeline\:example-pipeline\:ref:refs/tags/*:*"
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

1. In the **Custom trust policy** section, copy your modified custom trust policy, paste it into your IAM role, and complete the next few steps up to specifying the **Role name**.

1. Specify an appropriate **Role name**, for example, `compute-ssm-oidc-example`, and complete the remaining steps.

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
