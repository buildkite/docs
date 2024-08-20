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

    Learn more about creating custom trust policies in [Creating IAM policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_create-console.html#access_policies_create-start) of the AWS IAM User Guide.

1. Modify the `Principal` section of the pasted code snippet accordingly:
    1. Ensure that this is set to `Federated`, and points to the `oidc-provider` Amazon Resource Name (ARN) from the **Provider URL** you [configured above](#step-1-set-up-an-oidc-provider-in-your-aws-account) (that is, `agent.buildkite.com`).
    1. Change `AWS_ACCOUNT_ID` to your actual AWS account ID.

1. Modify the `Condition` section of the code snippet accordingly:
    1. Ensure the `StringEquals` subsection's _audience_ field name has a value that matches the **Audience** you [configured above](#step-1-set-up-an-oidc-provider-in-your-aws-account) (that is, `sts.amazonaws.com`). The _audience_ field name is your provider URL appended by `:aud`—`agent.buildkite.com:aud`.
    1. Ensure the `StringLike` subsection's _subject_ field name has at least one value that matches the format: `organization:ORGANIZATION_SLUG:pipeline:PIPELINE_SLUG:ref:REF:commit:BUILD_COMMIT:step:STEP_KEY`, where the constituent fields of this line determine the conditions under which the IAM role is granted in exchange for the OIDC token. The _subject_ field name is your provider URL appended by `:sub`—`agent.buildkite.com:sub`. This value format is equivalent to the subject (`sub`) claim when [requesting for an OIDC token for the current job](/docs/agent/v3/cli-oidc#claims), and the IAM role is granted when the values specified in these constituent fields have been met. The _subject_ field values in your custom trust policy can be different to those specified by your OIDC token's subject claim value, making your trust policy either more restrictive or permissive. When formulating such a value, the following constituent field's value:
        - `ORGANIZATION_SLUG` can be obtained:

            * From the end of your Buildkite URL, after accessing **Pipelines** in the global navigation of your organization in Buildkite.

            * By running the [List organizations](/docs/apis/rest-api/organizations#list-organizations) REST API query to obtain this value from `slug` in the response. For example:

                ```bash
                curl - X GET "https://api.buildkite.com/v2/organizations" \
                  -H "Authorization: Bearer $TOKEN"
                ```
        - `PIPELINE_SLUG` (optional) can be obtained:

            * From the end of your Buildkite URL, after accessing **Pipelines** in the global navigation of your organization in Buildkite, then accessing the specific pipeline to be specified in the custom trust policy.

            * By running the [List pipelines](/docs/apis/rest-api/pipelines#list-pipelines) REST API query to obtain this value from `slug` in the response from the specific pipeline. For example:

                ```bash
                curl - X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines" \
                  -H "Authorization: Bearer $TOKEN"
                ```
        - `REF` (optional) is usually replaced with `refs/heads/main` to restrict the IAM role's access to the `main` branch only, `refs/tags/*` to restrict the IAM role's access to tagged releases, or a wildcard `*` if the IAM role can be accessed and used by all branches.
        - `BUILD_COMMIT` (optional) can be omitted and if so, is usually replaced with a single wildcard `*` at the end of the line.
        - `STEP_KEY` (optional) can be omitted and if so, is usually replaced with a single wildcard `*` at the end of the line.

    **Note:** When formulating your _subject_ field's value, you can replace any of the constituent field values above with a wildcard `*` to not set limits on those constituent fields.

    For example, to allow the IAM role to be used for any pipeline in the Buildkite organization `example-org`, when building on any branch or tag, specify a single _subject_ field value of `organization:example-org:*`.

    You can also allow this IAM role to be used with other pipelines, branches, commits and steps by specifying multiple comma-separated values for the `agent.buildkite.com:sub` _subject_ field.

1. If you have dedicated/static public IP addresses and wish to implement defense in depth against an attacker stealing an OIDC token to access your cloud environment, retain the `Condition` section's `IpAddress` subsection, and modify its values (`AGENT_PUBLIC_IP_ONE` and `AGENT_PUBLIC_IP_TWO`) with a list of your agent's IP addresses or [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) range or block.

    Only OIDC token exchange requests (for IAM roles) from Buildkite Agents with these IP addresses will be permitted.

1. Verify that your custom trust policy is complete. The following example trust policy (noting that `AWS_ACCOUNT_ID` has not been specified) will only allow the exchange of an agent's OIDC tokens with IAM roles when:
    * the Buildkite organization is `example-org`
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
      - aws-assume-role-with-web-identity#v1.0.0:
          role-arn: arn\:aws\:iam::012345678910:role/example-pipeline-oidc-for-ssm
      - aws-ssm#v1.0.0:
          parameters:
            EXAMPLE_DEPLOY_KEY: /pipelines/example-pipeline/oidc-for-ssm/example-deploy-key
```
