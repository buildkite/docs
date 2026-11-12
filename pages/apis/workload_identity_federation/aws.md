# Working with AWS

An AWS workload, such as an AWS Lambda function or an Amazon EC2 instance, can use [workload identity federation](/docs/apis/workload-identity-federation) to exchange an OIDC token for its IAM role for a short-lived Buildkite API access token. The workload doesn't need a stored API access token.

## Set up outbound identity federation

1. [Enable outbound identity federation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_outbound_getting_started.html) for the AWS account.
1. Allow the workload's IAM role to call `sts:GetWebIdentityToken`.
1. Copy the account's issuer URL from the account settings in the IAM console.

## Create the workload identity

Create a workload identity as described in [Create a workload identity](/docs/apis/workload-identity-federation#create-a-workload-identity), and select **AWS** as its **Provider**. Then set the following:

- **OIDC issuer:** The issuer URL that you copied from the IAM console. Each AWS account has its own issuer, so the preset leaves this field empty.
- **OIDC subject:** The ARN of the workload's IAM role, for example, `arn:aws:iam::123456789012:role/deploy`. Replace the `<account-id>` and `<role-name>` placeholders that the preset fills in.
- **Claims:** Leave empty. AWS puts its account, organization, and tag [claims](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_outbound_token_claims.html) in a nested `https://sts.amazonaws.com/` claim, which **Claims** can't reach.
- **Claim conditions** (optional): To check a nested claim, such as a tag on the IAM role, read it by name, for example, `claims["https://sts.amazonaws.com/"].principal_tags.environment == "production"`.

## Exchange the token

The workload requests an OIDC token with the AWS STS [`GetWebIdentityToken`](https://docs.aws.amazon.com/STS/latest/APIReference/API_GetWebIdentityToken.html) API, using the workload identity's **OIDC audience**, then exchanges it for an API access token:

```bash
OIDC_TOKEN="$(aws sts get-web-identity-token \
  --region "$AWS_REGION" \
  --endpoint-url "https://sts.$AWS_REGION.amazonaws.com" \
  --audience "$BUILDKITE_AUDIENCE" \
  --signing-algorithm ES384 \
  --duration-seconds 300 \
  --query WebIdentityToken \
  --output text)"

BUILDKITE_API_TOKEN="$(curl -sSf https://buildkite.com/oauth/token \
  -d "grant_type=client_credentials" \
  -d "client_id=$BUILDKITE_CLIENT_ID" \
  -d "client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer" \
  -d "client_assertion=$OIDC_TOKEN" | jq -r .access_token)"
```

Set `BUILDKITE_CLIENT_ID` and `BUILDKITE_AUDIENCE` to the workload identity's **Client ID** and **OIDC audience**, and `AWS_REGION` to the workload's AWS Region. The command uses a regional STS endpoint, because `GetWebIdentityToken` isn't available on the global endpoint.

Call `GetWebIdentityToken` again before each exchange, including retries, because a workload identity accepts each OIDC token only once. Learn more in [Get a new OIDC token for each exchange](/docs/apis/workload-identity-federation#exchange-an-oidc-token-get-a-new-oidc-token-for-each-exchange).

The API access token expires no later than the OIDC token, so set `--duration-seconds` to how long the workload needs the API access token, up to 3600.

Buildkite accepts both AWS signing algorithms, `ES384` and `RS256`.
