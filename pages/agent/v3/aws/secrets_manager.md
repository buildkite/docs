# Storing your Buildkite Agent token in AWS Secrets Manager

The Elastic CI Stack for AWS supports reading a Buildkite Agent token from
the AWS Systems Manager Parameter Store. The token can be stored in a plaintext
parameter, or encrypted with a KMS Key for access control purposes. It is also
possible to store your Buildkite Agent token using AWS Secrets Manager should
you need to make use of the advanced functionality it offers over the Parameter
Store.

For example, AWS Secrets Manager can be configured to automatically rotate and
revoke secrets using Lambda functions, and replicate secrets across multiple
regions in your account.

If you would prefer to store your Buildkite Agent token as an AWS Secrets
Manager secret, you can configure the Elastic CI Stack’s
`BuildkiteAgentTokenParameterStorePath` parameter to reference your secret with
the special `/aws/reference/secretsmanager/your_Secrets_Manager_secret_ID`
parameter path which will transparently fetch the secret from AWS Secrets
Manager.

See the AWS documentation on [Referencing AWS Secrets Manager secrets from Parameter Store parameters](https://docs.aws.amazon.com/systems-manager/latest/userguide/integration-ps-secretsmanager.html)
for more details.

To ensure your Elastic CI Stack instance IAM role has access to the secret:

- Provide the Key ID (not the alias) used to encrypt the Secrets Manager secret to the `BuildkiteAgentTokenParameterStoreKMSKey` parameter.
	- The CloudFormation template includes an IAM policy with `kms:Decrypt` permission for this key.
- Use the Secret Manager secret’s resource policy to grant `secretsmanager:GetSecretValue` permission to the Elastic CI Stack’s IAM role.
	- Secret Manager will capture the role’s Unique ID when saving the resource
  policy, if you re-create the IAM role you will need to save the resource
  policy again to grant access.

```
{
  "Version" : "2012-10-17",
  "Statement" : [ {
    "Effect" : "Allow",
    "Principal" : {
      "AWS" : [
        "arn\:aws\:iam::[redacted]:role/buildkite-secretsmanager-test-Role”
      ]
    },
    "Action" : "secretsmanager:GetSecretValue",
    "Resource" : "*"
  } ]
}
```

## Multi Region Replication

It is also possible to replicate your Buildkite Agent token to multiple regions
using AWS Secret Manager’s [multi-region replication](https://docs.aws.amazon.com/secretsmanager/latest/userguide/create-manage-multi-region-secrets.html). You
can then deploy an Elastic CI Stack to each region and use the Parameter Store
reference path to read the secret from the regionally replicated secret.

Some additional points to keep in mind when using multi-region replication:

- Ensure each region’s IAM role has `ssm:GetParameter` permission for the region
it will be retrieving the secret from.
    - By default, the template will grant permission to only the region it is
    deployed to, limiting the role’s utility to the stack’s region. This isn’t a
    problem just a caveat to be aware of. Don’t expect to use the same role in
    multiple regions.
- Ensure each region’s IAM role has `kms:Decrypt` permission for the key used to
encrypt the secret in that region.
    - I used the AWS Secrets Manager key e.g. aws/secretsmanager in Secrets
    Manager and then looked up the underlying CMK ID of that key alias in each
    region I deployed the stack template to. Provide that value for the
    `BuildkiteAgentTokenParameterStoreKMSKey` parameter for the stack in that
    region.
- Apply a resource policy to the primary Secrets Manager secret that grants
`secretsmanager:GetSecretValue` for each region’s IAM role and wait for that to
be replicated.

Now, changes to the agent token secret (either made by hand or using Automatic
Secret Rotation) will be replicated from the primary region to each replia
region.

The Elastic CI Stack will only retrieve the Buildkite Agent token once when the
instance boots. You should [refresh your Auto Scaling Group instances](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-instance-refresh.html)
after rotating and replicating the secret, and before revoking the old token.
