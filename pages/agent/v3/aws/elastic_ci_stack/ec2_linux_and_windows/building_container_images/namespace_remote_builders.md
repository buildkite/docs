# Namespace remote builder container builds

[Namespace](https://namespace.so) provides [remote Docker builders](https://namespace.so/docs/solutions/docker-builders) that execute builds on dedicated infrastructure outside of your Kubernetes cluster.

Unlike [Buildah](/docs/agent/v3/agent-stack-k8s/buildah-container-builds) or [BuildKit](/docs/agent/v3/agent-stack-k8s/buildkit-container-builds) which run builds inside Kubernetes pods, Namespace executes builds on remote compute instances. This eliminates the need for privileged containers, security context configuration, or storage driver setup in your cluster.

## How it works

When using Namespace remote Docker builders with the [Elastic CI Stack for AWS](/docs/agent/v3/aws/elastic_ci_stack/ec2_linux_and_windows/setup):

1. The stack instance authenticates with Namespace using Buildkite OIDC or AWS Cognito (see [Authentication](/docs/agent/v3/aws/elastic_ci_stack/ec2_linux_and_windows/building_container_images/namespace_remote_builders#authentication)).
1. The Namespace CLI (`nsc`) configures [Docker Buildx](https://docs.docker.com/reference/cli/docker/buildx/) on the instance to target the remote builders.
1. Namespace runs the build workload remotely while the Buildkite agent continues orchestrating the pipeline.
1. Built images are pushed to Namespace's registry (`nscr.io`) or any other registry you configure.

## Prerequisites

- Namespace account with a workspace ([sign up](https://cloud.namespace.so/signin) if you do not have one)
- Elastic CI Stack for AWS agents running Amazon Linux 2023 or Windows Server 2019 with outbound access to `namespaceapis.com`
- Buildkite Agent v3.63.0 or later (earlier releases do not include `buildkite-agent oidc request-token`)
- Properly configured authentication

## Install Namespace CLI on a custom AMI

Elastic CI Stack agents revert any runtime changes when instances recycle, so bake the Namespace CLI into the AMI that your Elastic CI Stack uses. Follow the [custom image guide](/docs/agent/v3/aws/elastic_ci_stack/ec2_linux_and_windows/setup#custom-images) and add these commands to your image build workflow:

```bash
curl -fsSL https://get.namespace.so/cloud/install.sh | sh

if [ ! -f /root/.ns/bin/nsc ]; then
  echo "Namespace CLI install failed" >&2
  exit 1
fi

install -m 755 /root/.ns/bin/nsc /usr/local/bin/nsc
install -m 755 /root/.ns/bin/docker-credential-nsc /usr/local/bin/docker-credential-nsc
install -m 755 /root/.ns/bin/bazel-credential-nsc /usr/local/bin/bazel-credential-nsc
chown buildkite-agent:buildkite-agent /usr/local/bin/nsc /usr/local/bin/docker-credential-nsc /usr/local/bin/bazel-credential-nsc
```

> 📘 Windows instances
> Use PowerShell during image build to download the installer and append `C:\Users\buildkite-agent\.ns\bin` to the PATH. The Namespace CLI provides the same commands on Windows.

## Authentication

Namespace supports multiple authentication [methods](https://namespace.so/docs/federation).

[Buildkite OIDC](/docs/pipelines/security/oidc) is recommended for most environments. To be able to start using it with Namespace, you will need to contact [support@namespace.so](mailto:support@namespace.so) to register `https://agent.buildkite.com` as a trusted issuer for your Namespace tenant.

Alternatively, you can use [AWS Cognito federation](https://namespace.so/docs/federation/aws) for your [instance IAM profile](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html). The instance profiles needs the following to both authenticate to Namespace:

- `cognito-identity:GetOpenIdTokenForDeveloperIdentity`
- `cognito-identity:GetId`

If pushing to ECR, the instance profile also needs the following permissions:

- `ecr:GetAuthorizationToken`
- `ecr:BatchCheckLayerAvailability`
- `ecr:BatchGetImage`
- `ecr:CompleteLayerUpload`
- `ecr:InitiateLayerUpload`
- `ecr:PutImage`
- `ecr:UploadLayerPart`

### Buildkite OIDC authentication (recommended)

Use this option when your Elastic CI Stack agents are configured with Buildkite OIDC authentication. The build step exchanges the OIDC token for a Namespace token and authenticates to your Namespace workspace.

```yaml
    command: |
      # Authenticate using Buildkite OIDC
      OIDC_TOKEN=$$(buildkite-agent oidc request-token --audience federation.namespaceapis.com)
      /usr/local/bin/nsc auth exchange-oidc-token \
        --token "$$OIDC_TOKEN" \
        --tenant_id <workspace-id>
```

### AWS Cognito authentication

Use this option after configuring an AWS Cognito identity pool for Namespace federation. Configure the Elastic CI Stack instance profile with `cognito-identity:GetOpenIdTokenForDeveloperIdentity` and the related read permissions described in the [Namespace AWS federation guide](https://namespace.so/docs/federation/aws). The build step exchanges the instance profile credentials for a Cognito token and authenticates to your Namespace workspace.

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

## Using Namespace remote builders

Namespace integrates with Buildkite pipeline steps through the Namespace CLI. Select the authentication flow that matches the environment, then run the standard Docker Buildx commands against the remote builders.

### Buildkite OIDC authentication (recommended)

Use this option when [support@namespace.so](mailto:support@namespace.so) has been contacted to register `https://agent.buildkite.com` as a trusted issuer.

```yaml
    command: |
      # Authenticate using Buildkite OIDC
      OIDC_TOKEN=$$(buildkite-agent oidc request-token --audience federation.namespaceapis.com)
      /root/.ns/bin/nsc auth exchange-oidc-token \
        --token "$$OIDC_TOKEN" \
        --tenant_id <workspace-id>
```

### AWS Cognito authentication

Use this option to use AWS Cognito federation for your Elastic CI Stack instance IAM profile. The instance profile authenticates using Cognito, then Namespace provisions the remote builders for the pipeline.

```yaml
    command: |
      # Authenticate using AWS Cognito
      /root/.ns/bin/nsc auth exchange-aws-cognito-token \
        --aws_region <your-region> \
        --identity_pool <pool-guid> \
        --tenant_id <workspace-id>
```

## Pushing to external registries

Namespace handles authentication to its own registry when you run `/usr/local/bin/nsc docker login`.

The Elastic CI Stack for AWS also includes an `environment` hook that can sign in to Docker Hub or Amazon ECR when you configure docker and ECR credentials in the stack secrets bucket.

When your build targets a different registry, add an explicit login step. Use the [`docker-login`](https://github.com/buildkite-plugins/docker-login-buildkite-plugin) plugin for Docker Hub or the [ECR Buildkite plugin](https://github.com/buildkite-plugins/ecr-buildkite-plugin) for Amazon ECR before `docker buildx build --push`.

### Docker Hub

Use the [docker-login Buildkite plugin](https://github.com/buildkite-plugins/docker-login-buildkite-plugin) to authenticate with Docker Hub before pushing images.

```yaml
    plugins:
      - docker-login#v2.1.0:
          registry: https://index.docker.io/v1/
          username: "${DOCKER_USERNAME}"
          password-env: DOCKER_PASSWORD
```

### Amazon ECR

Use the [ECR Buildkite plugin](https://github.com/buildkite-plugins/ecr-buildkite-plugin) to authenticate with Amazon ECR before pushing images.

```yaml
    plugins:
      - ecr#v3.3.0:
          login: true
          account-ids:
            - <account-id>
          region: <your-region>
```

## Complete pipeline example

Uncomment the authentication flow and registry plugin that match your environment.

```yaml
agents:
  queue: default

steps:
  - label: ":docker: Build with Namespace"
    plugins:
      # Uncomment the registry plugin that matches your destination.
      # - ecr#v3.3.0:
      #     login: true
      #     account-ids:
      #       - <account-id>
      #     region: <region>

      # - docker-login#v2.1.0:
      #     registry: https://index.docker.io/v1/
      #     username: "${DOCKER_HUB_USERNAME}"
      #     password-env: DOCKER_HUB_PASSWORD

    command: |
      # Option A: Authenticate using Buildkite OIDC (recommended)
      OIDC_TOKEN=$$(buildkite-agent oidc request-token --audience federation.namespaceapis.com)
      /usr/local/bin/nsc auth exchange-oidc-token \
        --token "$$OIDC_TOKEN" \
        --tenant_id <workspace-id>

      # Option B: Authenticate using AWS Cognito
      # /usr/local/bin/nsc auth exchange-aws-cognito-token \
      #   --aws_region <your-region> \
      #   --identity_pool <pool-guid> \
      #   --tenant_id <workspace-id>

      # Configure Namespace Buildx builder and push a multi-platform image
      /usr/local/bin/nsc docker buildx setup --background --use
      /usr/local/bin/nsc docker login
      docker buildx build \
        --builder nsc-remote \
        --platform linux/amd64,linux/arm64 \
        -t <registry>/<image-name>:latest \
        --push \
        .

      # Alternative registry example (uncomment if pushing elsewhere)
      # docker buildx build \
      #   --builder nsc-remote \
      #   --platform linux/amd64,linux/arm64 \
      #   -t <registry>/<image-name>:latest \
      #   --push \
      #   .
```

## Troubleshooting

- Authentication failures: contact Namespace to register the OIDC issuer or verify AWS Cognito permissions for the stack’s IAM role.
- Builder not found: rerun `nsc docker buildx setup --background --use` before building.
- Registry authentication fails: run `nsc docker login` or enable the appropriate registry plugin block.
- Shell execution errors: ensure the stack is using the default `#!/bin/bash -e -c` shell in step commands.
