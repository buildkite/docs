---
keywords: oidc, authentication, IAM, roles, AWS
---

# OIDC with AWS

The [Buildkite agent's `oidc` command](/docs/agent/cli/reference/oidc) allows you to request an [Open ID Connect (OIDC)](https://openid.net/developers/how-connect-works/) token containing _claims_ about the current pipeline and its job. These tokens can be consumed by AWS and exchanged for an Identity and Access Management (IAM) role with AWS-scoped permissions.

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

The trust policy in this step restricts access using Buildkite OIDC claims directly as AWS condition keys, such as `agent.buildkite.com:organization_id` and `agent.buildkite.com:pipeline_id`. It also includes the matching `organization_slug` and `pipeline_slug` conditions. These aren't required when you use the IDs, but they make the policy easier to read. Learn more about the available condition keys and how to choose between them in [Restricting access with Buildkite OIDC claims](#restricting-access-with-buildkite-oidc-claims).

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
                    "StringLike": {
                        "agent.buildkite.com:sub": "organization\:ORGANIZATION_SLUG\:pipeline:PIPELINE_SLUG\:ref\:REF\:commit\:BUILD_COMMIT\:step\:STEP_KEY"
                    },
                    "StringEquals": {
                        "agent.buildkite.com:aud": "sts.amazonaws.com",
                        "agent.buildkite.com:organization_slug": "ORGANIZATION_SLUG",
                        "agent.buildkite.com:organization_id": "ORGANIZATION_ID",
                        "agent.buildkite.com:pipeline_slug": "PIPELINE_SLUG",
                        "agent.buildkite.com:pipeline_id": "PIPELINE_ID"
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
    1. Ensure the `StringLike` subsection's `agent.buildkite.com:sub` condition matches the token's subject. [AWS requires a condition on `agent.buildkite.com:sub`](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_oidc_secure-by-default.html) in every trust policy for a Buildkite OIDC provider. The default subject has the format `organization:ORGANIZATION_SLUG:pipeline:PIPELINE_SLUG:ref:REF:commit:BUILD_COMMIT:step:STEP_KEY`. You can wildcard sections of this string, for example, `organization:example-org:*` matches any pipeline job in the `example-org` organization. Use the direct `organization_id` and `pipeline_id` conditions below to restrict access to immutable identities. If you use a [custom subject claim](/docs/agent/cli/reference/oidc#custom-subject-claims), match that value instead of the default subject format.
    1. Ensure the `StringEquals` subsection's _audience_ field has a value that matches the **Audience** you [configured above](#step-1-set-up-an-oidc-provider-in-your-aws-account) (that is, `sts.amazonaws.com`). The _audience_ field name is your provider URL appended by `:aud`—`agent.buildkite.com:aud`.
    1. Set the `StringEquals` subsection's `agent.buildkite.com:organization_id` and `agent.buildkite.com:pipeline_id` values to the immutable UUIDs of the organization and pipeline that will use this role, and set the `agent.buildkite.com:organization_slug` and `agent.buildkite.com:pipeline_slug` values to their slugs. Obtain the placeholder values as follows:
        - `ORGANIZATION_SLUG` can be obtained:

            * From the end of your Buildkite URL, after accessing **Pipelines** in the global navigation of your organization in Buildkite.

            * By running the [List organizations](/docs/apis/rest-api/organizations#list-organizations) REST API query to obtain this value from `slug` in the response. For example:

                ```bash
                curl -X GET "https://api.buildkite.com/v2/organizations" \
                  -H "Authorization: Bearer $TOKEN"
                ```

            * From the `BUILDKITE_ORGANIZATION_SLUG` value displayed on the `Environment` tab of any job that ran in the organization.
        - `ORGANIZATION_ID` is a UUID and can be obtained:

            * By running the same [List organizations](/docs/apis/rest-api/organizations#list-organizations) REST API query used to obtain `ORGANIZATION_SLUG`.

            * From the `BUILDKITE_ORGANIZATION_ID` value displayed on the `Environment` tab of any job that ran in the organization.
        - `PIPELINE_SLUG` can be obtained:

            * From the end of your Buildkite URL, after accessing **Pipelines** in the global navigation of your organization in Buildkite, then accessing the specific pipeline to be specified in the custom trust policy.

            * By running the [List pipelines](/docs/apis/rest-api/pipelines#list-pipelines) REST API query to obtain this value from `slug` in the response from the specific pipeline. For example:

                ```bash
                curl -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines" \
                  -H "Authorization: Bearer $TOKEN"
                ```
        - `PIPELINE_ID` is a UUID and can be obtained from `id` in the same **List pipelines** REST API response, or from the `BUILDKITE_PIPELINE_ID` value on the **Environment** tab of a job that ran in the pipeline.
1. If your agents' requests reach AWS STS from dedicated/static public IP addresses and you wish to implement defense in depth against an attacker stealing an OIDC token to access your cloud environment, retain the `Condition` section's `IpAddress` subsection, and modify its values (`AGENT_PUBLIC_IP_ONE` and `AGENT_PUBLIC_IP_TWO`) with the IP addresses or [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) ranges that AWS sees these requests coming from. Depending on your network, these could be your agents' own public IP addresses, or those of a NAT gateway or proxy that your agents use to reach the internet.

    Only OIDC token exchange requests (for IAM roles) from these IP addresses will be permitted.

    If your agents reach AWS STS through a VPC endpoint, the `aws:SourceIp` condition key isn't available, and this condition denies all role assumption. Use the [`aws:VpcSourceIp`](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_condition-keys.html#condition-keys-vpcsourceip) condition key instead.

1. Verify that your custom trust policy is complete. The following example trust policy (noting that `AWS_ACCOUNT_ID` has not been specified) will only allow the exchange of an agent's OIDC tokens with IAM roles when:
    * The Buildkite organization is `example-org`, with an ID matching `ORGANIZATION_ID`.
    * The Buildkite pipeline is `example-pipeline`, with an ID matching `PIPELINE_ID`.
    * The request comes from either `192.0.2.0` or `198.51.100.0`.

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
                    "StringLike": {
                        "agent.buildkite.com:sub": "organization\:example-org\:*"
                    },
                    "StringEquals": {
                        "agent.buildkite.com:aud": "sts.amazonaws.com",
                        "agent.buildkite.com:organization_slug": "example-org",
                        "agent.buildkite.com:organization_id": "ORGANIZATION_ID",
                        "agent.buildkite.com:pipeline_slug": "example-pipeline",
                        "agent.buildkite.com:pipeline_id": "PIPELINE_ID"
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

    **Note:** Replace `ORGANIZATION_ID` and `PIPELINE_ID` with your actual UUIDs.

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
  - label: "\:aws\: Deploy to Production"
    key: deploy-to-production
    command: echo "Example Deploy Key equals \$EXAMPLE_DEPLOY_KEY"
    env:
      AWS_DEFAULT_REGION: us-east-1
      AWS_REGION: us-east-1
    plugins:
      - aws-assume-role-with-web-identity#v1.8.0:
          role-arn: arn\:aws\:iam::012345678910:role/example-pipeline-oidc-for-ssm
      - aws-ssm#v1.0.0:
          parameters:
            EXAMPLE_DEPLOY_KEY: /pipelines/example-pipeline/oidc-for-ssm/example-deploy-key
```

> 📘
> The backslash (`\`) before `$EXAMPLE_DEPLOY_KEY` in the example above prevents this environment variable from being interpolated during the pipeline's upload to Buildkite Pipelines. You could alternatively use a `$` symbol for this purpose (resulting in `$$EXAMPLE_DEPLOY_KEY`).

## Restricting access with Buildkite OIDC claims

AWS supports the following Buildkite OIDC claims directly as condition keys in role trust policies. Each key uses the `agent.buildkite.com:` prefix and supports [string operators](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html).

AWS STS condition key | OIDC token claim | Available in session
--------------------- | ---------------- | --------------------
`agent.buildkite.com:organization_slug` | `organization_slug` | No
`agent.buildkite.com:organization_id` | `organization_id` | No
`agent.buildkite.com:pipeline_slug` | `pipeline_slug` | No
`agent.buildkite.com:pipeline_id` | `pipeline_id` | No
`agent.buildkite.com:cluster_name` | `cluster_name` | No
`agent.buildkite.com:cluster_id` | `cluster_id` | No
`agent.buildkite.com:build_branch` | `build_branch` | No
{: class="responsive-table"}

These keys are available when AWS authenticates the initial `AssumeRoleWithWebIdentity` request, but not in the resulting role session for authorizing access to AWS resources. You do not need [session tags](#using-aws-session-tags) to use these keys in a trust policy. See the **Buildkite** tab in [Available keys for AWS OIDC federation](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_iam-condition-keys.html#condition-keys-wif) and the [Buildkite OIDC claims reference](/docs/agent/cli/reference/oidc#claims) for details.

To restrict access using one of these claims, add its condition key to the `Condition` section of your trust policy, as the [Step 2](#step-2-create-a-new-or-update-an-existing-iam-role-to-use-with-your-pipelines) examples do for the organization and pipeline. These conditions add to the [required `agent.buildkite.com:sub` condition](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_oidc_secure-by-default.html), and don't replace it.

> 🚧 Use immutable identifiers instead of slugs.
> Deleted organization and pipeline slugs can be reused by different organizations or pipelines. A policy that relies only on slugs could grant access to an unintended identity. Use immutable `organization_id` and `pipeline_id` values to restrict access. For cluster restrictions, use `cluster_id` instead of `cluster_name`.

You can include `organization_slug` and `pipeline_slug` conditions alongside the immutable UUID conditions, as the Step 2 examples do. UUIDs alone are difficult to identify when reading an IAM policy, and the matching slugs make it clear which organization and pipeline the policy applies to. Since all conditions must match, update the slug conditions if you rename the organization or pipeline.

The `cluster_id` and `cluster_name` claims are [optional claims](/docs/agent/cli/reference/oidc#claims-optional-claims), which are only included in the OIDC token when requested with the `--claim` option of the `buildkite-agent oidc request-token` command.

## Including the build branch in your custom trust policy

When [creating a custom trust policy for your IAM role](#step-2-create-a-new-or-update-an-existing-iam-role-to-use-with-your-pipelines), you can include the build branch within this policy. However, be aware that doing so comes with potential risks, since this doesn't necessarily guarantee that the entire build will be run from the branch defined in the policy. For instance, the policy might allow a build to commence off the `main` branch. However, the next step of the pipeline might check out a different branch and run the remainder of the pipeline's build from that branch.

Nevertheless, being aware of these risks, if you do wish to include the build branch in your custom trust policy, add the `agent.buildkite.com:build_branch` entry to your `Condition` section's `StringEquals` subsection when [defining your trust policy in the code editor](#step-2-create-a-new-or-update-an-existing-iam-role-to-use-with-your-pipelines):

```json
...
"Condition": {
    "StringEquals": {
        ...
        "agent.buildkite.com:build_branch": "BRANCH_NAME"
    }
...
```

where `BRANCH_NAME` is usually replaced with `main` to initially restrict the IAM role's access to the `main` branch. If neither this condition nor the `sub` condition restricts the branch, the role can initially be assumed by a build on any branch.

## Using AWS session tags

Session tags are optional, and are not needed to restrict which pipelines can assume a role. Use them when you need Buildkite claim values after the role has been assumed:

- **Permissions within the role session:** the [direct claim condition keys](#restricting-access-with-buildkite-oidc-claims) are only evaluated when the role is assumed. To use claim values in the role's permission policies, for example, in `aws:PrincipalTag/pipeline_slug` conditions for [attribute-based access control (ABAC)](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction_attribute-based-access-control.html), pass these values as session tags.
- **Auditing:** session tag values are recorded in the [AWS CloudTrail](#using-aws-session-tags-aws-cloudtrail) event for the role assumption.

To use session tags:

1. Add `sts:TagSession` to the `Action` section of your [trust policy](#step-2-create-a-new-or-update-an-existing-iam-role-to-use-with-your-pipelines). If session tags are passed and the trust policy doesn't allow this action, [AWS denies the role assumption](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_session-tags.html#id_session-tags_permissions-required).

    ```json
    "Action": [
        "sts:AssumeRoleWithWebIdentity",
        "sts:TagSession"
    ],
    ```

1. Add the claims to pass as session tags to the [AWS assume-role-with-web-identity](https://buildkite.com/resources/plugins/buildkite-plugins/aws-assume-role-with-web-identity-buildkite-plugin) plugin's `session-tags` configuration:

    ```yaml
    plugins:
      - aws-assume-role-with-web-identity#v1.8.0:
          role-arn: arn\:aws\:iam::012345678910:role/example-pipeline-oidc-for-ssm
          session-tags:
            - organization_slug
            - organization_id
            - pipeline_slug
    ```

    Any [Buildkite OIDC claim](/docs/agent/cli/reference/oidc#claims) can be passed as a session tag, including `build_branch`. Learn more in [AWS session tags](/docs/agent/cli/reference/oidc#aws-session-tags).

### AWS CloudTrail

A Buildkite job that successfully assumes an AWS IAM role leaves a record in AWS CloudTrail. That record includes details like the IP address of the agent that ran the job, plus the values of any session tags listed in the plugin's `session-tags` configuration.

Here is a fragment of an AWS CloudTrail event with the relevant tags:

```json
{
    "eventVersion": "1.08",
    "userIdentity": {
        "type": "WebIdentityUser",
        "principalId": "arn\:aws\:iam::AWS_ACCOUNT_ID:oidc-provider/agent.buildkite.com:sts.amazonaws.com\:organization\:example-org\:pipeline\:example-pipeline\:ref\:refs/heads/main\:commit\:1da177e4c3f41524e886b7f1b8a0c1fc7321cac2\:step\:",
        "userName": "organization\:example-org\:pipeline\:example-pipeline\:ref:refs/heads/main\:commit\:1da177e4c3f41524e886b7f1b8a0c1fc7321cac2\:step\:",
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
            "organization_slug": "example-org"
        },
        "roleArn": "arn\:aws\:iam::AWS_ACCOUNT_ID:role/example-pipeline-oidc-for-ssm",
        "roleSessionName": "buildkite-job-01951944-87df-428f-ad92-90709ee78a59"
    },
    ...
}
```
