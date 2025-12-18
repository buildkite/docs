# Namespace remote builder container builds

[Namespace](https://namespace.so) provides [remote Docker builders](https://namespace.so/docs/solutions/docker-builders) that execute container image builds on dedicated infrastructure outside of your Elastic CI Stack instances.

Namespace remote builders offload the CPU and memory-intensive container build workloads to Namespace's infrastructure, freeing your Elastic CI Stack instances to continue running pipeline steps.

## How it works

When using Namespace remote Docker builders with the [Elastic CI Stack for AWS](/docs/agent/v3/aws/elastic_ci_stack/ec2_linux_and_windows/setup):

1. The stack instance authenticates with Namespace using Buildkite OIDC or AWS Cognito (see [Authentication](/docs/agent/v3/aws/elastic_ci_stack/ec2_linux_and_windows/building_container_images/namespace_remote_builders#authentication)).
1. The Namespace CLI (`nsc`) configures [Docker Buildx](https://docs.docker.com/reference/cli/docker/buildx/) on the instance to target the remote builders.
1. Namespace runs the build workload remotely while the Buildkite agent continues orchestrating the pipeline.
1. Built images are pushed to Namespace's registry (`nscr.io`) or any other registry you configure.

## Prerequisites

- Namespace account with a workspace ([sign up](https://cloud.namespace.so/signin) if you do not have one)
- Recent release of the Elastic CI Stack for AWS with outbound access to `namespaceapis.com`
- Properly configured authentication

## Install the Namespace CLI

> 📘
> The Namespace CLI is only available for Linux. Windows instances are not currently supported.

Use a [bootstrap script](/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/managing-elastic-ci-stack#customizing-instances-with-a-bootstrap-script) to install the Namespace CLI on your Elastic CI Stack instances.

Create the script with the following content and upload it to an S3 bucket, then set the `BootstrapScriptUrl` Elastic CI Stack parameter to the S3 URI.

```bash
#!/bin/bash
set -eo pipefail

DOWNLOAD_URL="https://get.namespace.so/packages/nsc/latest?arch=amd64&os=linux"
TEMP_TAR=$(mktemp)

if curl --fail --location --silent --show-error \
    --connect-timeout 30 --max-time 120 \
    --output "${TEMP_TAR}" "${DOWNLOAD_URL}"; then

    tar -xzf "${TEMP_TAR}" -C /usr/local/bin nsc docker-credential-nsc
    chmod 755 /usr/local/bin/nsc /usr/local/bin/docker-credential-nsc
    chown buildkite-agent:buildkite-agent /usr/local/bin/nsc /usr/local/bin/docker-credential-nsc
    rm -f "${TEMP_TAR}"
fi
```

## Authentication

Namespace supports multiple authentication [methods](https://namespace.so/docs/federation).

### Buildkite OIDC authentication (recommended)

[Buildkite OIDC](/docs/pipelines/security/oidc) is recommended for most environments. To be able to start using it with Namespace, you will need to contact [support@namespace.so](mailto:support@namespace.so) to register `https://agent.buildkite.com` as a trusted issuer for your Namespace tenant.

The build step exchanges the OIDC token for a Namespace token and authenticates to your Namespace workspace.

```yaml
    command: |
      # Authenticate using Buildkite OIDC
      OIDC_TOKEN=$$(buildkite-agent oidc request-token --audience federation.namespaceapis.com)
      /usr/local/bin/nsc auth exchange-oidc-token \
        --token "$$OIDC_TOKEN" \
        --tenant_id <workspace-id>
```

### AWS Cognito authentication

Alternatively, you can use [AWS Cognito federation](https://namespace.so/docs/federation/aws) for your [instance IAM profile](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html). The instance profile needs the following permissions to authenticate to Namespace:

- `cognito-identity:GetOpenIdTokenForDeveloperIdentity`
- `cognito-identity:GetId`

```bash
# Create pool
aws cognito-identity create-identity-pool \
  --identity-pool-name namespace-buildkite-federation \
  --no-allow-unauthenticated-identities \
  --developer-provider-name namespace.so \
  --region <your-region>

# Trust the pool (note the pool ID from output)
nsc auth trust-aws-cognito-identity-pool \
  --aws_region <your-region> \
  --identity_pool <pool-guid> \
  --tenant_id <workspace-id>
```

Once configured, the build step exchanges the instance profile credentials for a Cognito token and authenticates to your Namespace workspace.

```yaml
    command: |
      # Authenticate using AWS Cognito
      /usr/local/bin/nsc auth exchange-aws-cognito-token \
        --aws_region <your-region> \
        --identity_pool <pool-guid> \
        --tenant_id <workspace-id>
```

## Pushing to external registries

Namespace handles authentication to its own registry when you run `/usr/local/bin/nsc docker login`.

The Elastic CI Stack for AWS includes an `environment` hook that can sign in to [Docker Hub](https://docs.docker.com/docker-hub/) or [Amazon ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html) when you configure Docker and ECR credentials in the stack secrets bucket. See [Managing the Elastic CI Stack](/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/managing-elastic-ci-stack#docker-registry-support) for more information.

## Complete pipeline examples

The following examples show complete pipeline configurations for building and pushing container images with Namespace remote builders.

### Pushing to Namespace registry

This example authenticates with Buildkite OIDC and pushes to the Namespace registry.

```yaml
steps:
  - label: ":docker: Build with Namespace"
    command: |
      OIDC_TOKEN=$$(buildkite-agent oidc request-token --audience federation.namespaceapis.com)
      /usr/local/bin/nsc auth exchange-oidc-token \
        --token "$$OIDC_TOKEN" \
        --tenant_id <workspace-id>

      /usr/local/bin/nsc docker buildx setup --background --use
      /usr/local/bin/nsc docker login
      docker buildx build \
        --builder nsc-remote \
        --platform linux/amd64,linux/arm64 \
        -t nscr.io/<workspace>/<image-name>:latest \
        --push \
        .
```

### Pushing to Amazon ECR

This example authenticates with Buildkite OIDC and pushes to Amazon ECR.

```yaml
steps:
  - label: ":docker: Build with Namespace"
    command: |
      OIDC_TOKEN=$$(buildkite-agent oidc request-token --audience federation.namespaceapis.com)
      /usr/local/bin/nsc auth exchange-oidc-token \
        --token "$$OIDC_TOKEN" \
        --tenant_id <workspace-id>

      /usr/local/bin/nsc docker buildx setup --background --use
      docker buildx build \
        --builder nsc-remote \
        --platform linux/amd64,linux/arm64 \
        -t <account-id>.dkr.ecr.<your-region>.amazonaws.com/<image-name>:latest \
        --push \
        .
```

### Pushing to Docker Hub

This example authenticates with AWS Cognito and pushes to Docker Hub.

```yaml
steps:
  - label: ":docker: Build with Namespace"
    command: |
      /usr/local/bin/nsc auth exchange-aws-cognito-token \
        --aws_region <your-region> \
        --identity_pool <pool-guid> \
        --tenant_id <workspace-id>

      /usr/local/bin/nsc docker buildx setup --background --use
      docker buildx build \
        --builder nsc-remote \
        --platform linux/amd64,linux/arm64 \
        -t <dockerhub-username>/<image-name>:latest \
        --push \
        .
```

## Troubleshooting

- Authentication failures: contact Namespace to register the OIDC issuer or verify AWS Cognito permissions for the stack’s IAM role.
- Builder not found: rerun `nsc docker buildx setup --background --use` before building.
- Registry authentication fails: run `nsc docker login` before building.
- Shell execution errors: ensure the stack is using the default `#!/bin/bash -e -c` shell in step commands.
