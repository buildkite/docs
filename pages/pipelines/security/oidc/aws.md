---
keywords: oidc, authentication, IAM, roles, AWS
---

# OIDC with AWS

The [Buildkite Agent's `oidc` command](/docs/agent/v3/cli-oidc) allows you to request an [Open ID Connect (OIDC)](https://openid.net/developers/how-connect-works/) token containing _claims_ about the current pipeline and its job. These tokens can be consumed by AWS and exchanged for an Identity and Access Management (IAM) role with AWS-scoped permissions.

This process uses the following Buildkite plugins to implement OIDC with AWS and your Buildkite pipelines:

- [AWS assume-role-with-web-identity](https://github.com/buildkite-plugins/aws-assume-role-with-web-identity-buildkite-plugin)
- [AWS SSM Buildkite Plugin](https://github.com/buildkite-plugins/aws-ssm-buildkite-plugin)

Learn more about:

- How OIDC tokens are constructed and how to extract and use claims in the [OpenID Connect Core documentation](https://openid.net/specs/openid-connect-core-1_0.html#IDToken).

- Amazon's implementation of OIDC with their federated system in [Create an OpenID Connect (OIDC) identity provider in IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) of the AWS IAM User Guide.

## Step 1: Set up an OIDC provider in your AWS account

First, you'll need to set up an IAM OIDC provider in your AWS account.

Learn more about how to do this in the [Create an OpenID Connect (OIDC) identity provider in IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) page of the AWS IAM User Guide.

On this page, as part of the [Creating and managing an OIDC provider (console)](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html#manage-oidc-provider-console) process, specify the following values for the:

- **Provider URL**: `https://agent.buildkite.com`

- **Audience**: `sts.amazonaws.com`

## Step 2: Create a new (or update an existing) IAM role to use with your pipelines

Creating new or updating existing IAM roles is conducted through your AWS account.

Learn more about how to do this in the [Creating a role using custom trust policies (console)](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-custom.html) page of the AWS IAM User Guide.

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
                "Action": [
                    "sts:TagSession",
                    "sts:AssumeRoleWithWebIdentity"
                ],
                "Condition": {
                    "StringEquals": {
                        "agent.buildkite.com:aud": "sts.amazonaws.com",
                        "aws:RequestTag/organization_slug": "ORGANIZATION_SLUG",
                        "aws:RequestTag/organization_id": "ORGANIZATION_ID",
                        "aws:RequestTag/pipeline_slug": "PIPELINE_SLUG",
                        "aws:RequestTag/build_branch": "BRANCH_NAME"
                    }
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

    Learn more about creating custom trust policies in [Creating IAM policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_create-console.html#access_policies_create-start) of the AWS IAM User Guide.

1. Modify the `Principal` section of the pasted code snippet accordingly:
    1. Ensure that this is set to `Federated`, and points to the `oidc-provider` Amazon Resource Name (ARN) from the **Provider URL** you [configured above](#step-1-set-up-an-oidc-provider-in-your-aws-account) (that is, `agent.buildkite.com`).
    1. Change `AWS_ACCOUNT_ID` to your actual AWS account ID.

1. Modify the `Condition` section of the code snippet accordingly:
    1. Ensure the `StringEquals` subsection's _audience_ field name has a value that matches the **Audience** you [configured above](#step-1-set-up-an-oidc-provider-in-your-aws-account) (that is, `sts.amazonaws.com`). The _audience_ field name is your provider URL appended by `:aud`—`agent.buildkite.com:aud`.
    1. Ensure the `StringEquals` subsection's RequestTag fields have values match the Buildkite pipeline that will use this role: When formulating such values, the following constituent field's value:
        - `ORGANIZATION_SLUG` can be obtained:

            * From the end of your Buildkite URL, after accessing **Pipelines** in the global navigation of your organization in Buildkite.

            * By running the [List organizations](/docs/apis/rest-api/organizations#list-organizations) REST API query to obtain this value from `slug` in the response. For example:

                ```bash
                curl - X GET "https://api.buildkite.com/v2/organizations" \
                  -H "Authorization: Bearer $TOKEN"
                ```

            * From the `BUILDKITE_ORGANIZATION_SLUG` value displayed on the `Environment` tab of any job that ran in the organization
        - `ORGANIZATION_ID` is a UUID and can be obtained:

            * By running the same [List organizations](/docs/apis/rest-api/organizations#list-organizations) REST API query used to obtain `ORGANIZATION_SLUG`

            * From the `BUILDKITE_ORGANIZATION_ID` value displayed on the `Environment` tab of any job that ran in the organization
        - `PIPELINE_SLUG` (optional) can be obtained:

            * From the end of your Buildkite URL, after accessing **Pipelines** in the global navigation of your organization in Buildkite, then accessing the specific pipeline to be specified in the custom trust policy.

            * By running the [List pipelines](/docs/apis/rest-api/pipelines#list-pipelines) REST API query to obtain this value from `slug` in the response from the specific pipeline. For example:

                ```bash
                curl - X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines" \
                  -H "Authorization: Bearer $TOKEN"
                ```
        - `BRANCH_NAME` (optional) is usually replaced with `main` to restrict the IAM role's access to the `main` branch only. If this RequestTag condition is omitted, the role can be assumed by a build on any branch

1. If you have dedicated/static public IP addresses and wish to implement defense in depth against an attacker stealing an OIDC token to access your cloud environment, retain the `Condition` section's `IpAddress` subsection, and modify its values (`AGENT_PUBLIC_IP_ONE` and `AGENT_PUBLIC_IP_TWO`) with a list of your agent's IP addresses or [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) range or block.

    Only OIDC token exchange requests (for IAM roles) from Buildkite Agents with these IP addresses will be permitted.

1. Verify that your custom trust policy is complete. The following example trust policy (noting that `AWS_ACCOUNT_ID` has not been specified) will only allow the exchange of an agent's OIDC tokens with IAM roles when:
    * the Buildkite organization is `example-org`, with an ID of `ab3883b1-9596-4312-a09c-4527ae997ba7`
    * the Buildkite pipeline is `example-pipeline`
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
                "Action": [
                    "sts:TagSession",
                    "sts:AssumeRoleWithWebIdentity"
                ],
                "Condition": {
                    "StringEquals": {
                        "agent.buildkite.com:aud": "sts.amazonaws.com",
                        "aws:RequestTag/organization_slug": "example-org",
                        "aws:RequestTag/organization_id": "b3883b1-9596-4312-a09c-4527ae997ba7",
                        "aws:RequestTag/pipeline_slug": "example-pipeline",
                        "aws:RequestTag/build_branch": "main"
                    }
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

1. Specify an appropriate **Role name**, for example, `example-pipeline-oidc-for-ssm`, and complete the remaining steps.

## Step 3: Configure your IAM role with AWS actions

Add an inline or managed IAM policy (separate to the custom trust policy [configured above](#step-2-create-a-new-or-update-an-existing-iam-role-to-use-with-your-pipelines)) to allow the IAM role to perform any actions your pipeline needs. Learn more about how to do this in [Managed policies and inline policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html) of the AWS IAM User Guide.

Common examples are permissions to read secrets from SSM and push images to ECR, although this would depend on the purpose of your pipeline.

In the following example, we'll allow access to read an SSM Parameter Store key named `/pipelines/example-pipeline/oidc-for-ssm/example-deploy-key` by attaching the following inline policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameters"
            ],
            "Resource": "arn\:aws\:ssm\:us-east-1\:012345678910:parameter/pipelines/example-pipeline/oidc-for-ssm/example-deploy-key"
        }
    ]
}
```

## Step 4: Configure your pipeline to assume the role

Finally, use the two Buildkite plugins to use the IAM role and to pull in the SSM parameter (added above):

- [AWS assume-role-with-web-identity](https://github.com/buildkite-plugins/aws-assume-role-with-web-identity-buildkite-plugin)
- [AWS SSM Buildkite Plugin](https://github.com/buildkite-plugins/aws-ssm-buildkite-plugin)

Incorporate the following into your pipeline (modifying as required):

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
      - aws-assume-role-with-web-identity#v1.2.0:
          role-arn: arn\:aws\:iam::012345678910:role/example-pipeline-oidc-for-ssm
          session-tags:
            - organization_slug
            - organization_id
            - pipeline_slug
            - build_branch
      - aws-ssm#v1.0.0:
          parameters:
            EXAMPLE_DEPLOY_KEY: /pipelines/example-pipeline/oidc-for-ssm/example-deploy-key
```

## CloudTrail

A Buildkite job that successfully assumes an AWS IAM Role using this pattern will leave a record in AWS CloudTrail. That record will include details like the IP address of the agent that ran the job, plus the values for any of the `session-tags` that were listed in the `pipeline.yml`.

Here is a fragment of a CloudTrail event with the relevant tags:

```json
{
    "eventVersion": "1.08",
    "userIdentity": {
        "type": "WebIdentityUser",
        "principalId": "arn\:aws\:iam::AWS_ACCOUNT_ID:oidc-provider/agent.buildkite.com\:sts.amazonaws.com\:organization\:example-org\:pipeline\:example-pipeline\:ref\:refs/heads/main\:commit\:1da177e4c3f41524e886b7f1b8a0c1fc7321cac2\:step\:",
        "userName": "organization\:example-org\:pipeline\:example-pipeline\:ref\:refs/heads/main\:commit\:1da177e4c3f41524e886b7f1b8a0c1fc7321cac2\:step\:",
        "identityProvider": "arn\:aws\:iam::AWS_ACCOUNT_ID:oidc-provider/agent.buildkite.com"
    },
    "eventTime": "2025-02-18T13:34:48Z",
    "eventSource": "sts.amazonaws.com",
    "eventName": "AssumeRoleWithWebIdentity",
    "awsRegion": "us-east-1",
    "sourceIPAddress": "192.0.2.0",
    "userAgent": "aws-cli/2.13.0 Python/3.11.4 Linux/6.7.12 exe/x86_64.ubuntu.22 prompt/off command/sts.assume-role-with-web-identity",
    "requestParameters": {
        "principalTags": {
            "pipeline_slug": "example-pipeline",
            "organization_id": "ab3883b1-9596-4312-a09c-4527ae997ba7",
            "organization_slug": "example-org",
            "build_branch": "main"
        },
        "roleArn": "arn\:aws\:iam::AWS_ACCOUNT_ID:role/example-pipeline-oidc-for-ssm",
        "roleSessionName": "buildkite-job-01951944-87df-428f-ad92-90709ee78a59"
    },
    ...
}
```
