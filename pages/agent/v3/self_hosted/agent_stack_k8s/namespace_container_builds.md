# Namespace remote builder container builds

[Namespace](https://namespace.so) provides [remote Docker builders](https://namespace.so/docs/solutions/docker-builders) that execute builds on dedicated infrastructure outside of your Kubernetes cluster.

Unlike [Buildah](/docs/agent/v3/self-hosted/agent-stack-k8s/buildah-container-builds) or [BuildKit](/docs/agent/v3/self-hosted/agent-stack-k8s/buildkit-container-builds) which run builds inside Kubernetes pods, Namespace executes builds on remote compute instances. This eliminates the need for privileged containers, security context configuration, or storage driver setup in your cluster.

## How it works

When using Namespace remote Docker builders with the [Buildkite Agent Stack for Kubernetes](/docs/agent/v3/self-hosted/agent-stack-k8s):

1. The [Buildkite Agent Stack for Kubernetes](/docs/agent/v3/self-hosted/agent-stack-k8s) pod authenticates with Namespace (see [Authentication](/docs/agent/v3/self-hosted/agent-stack-k8s/namespace-container-builds#authentication)).
1. The Namespace CLI (`nsc`) configures [Docker Buildx](https://docs.docker.com/reference/cli/docker/buildx/) to use remote builders.
1. Namespace runs the actual build workloads remotely while Buildkite continues orchestrating the pipeline.
1. Built images are pushed to Namespace's container registry or any other registry.

## Prerequisites

- Namespace account with a workspace (you can [sign up for it](https://cloud.namespace.so/signin) if you don't have one).
- Custom agent image with Docker CLI, Buildx, and Namespace CLI.
- Properly configured authentication.

## Authentication

Namespace supports multiple authentication [methods](https://namespace.so/docs/federation).

[Buildkite OIDC](/docs/pipelines/security/oidc) is recommended for most environments. To be able to start using it with Namespace, you will need to contact [support@namespace.so](mailto:support@namespace.so) to register `https://agent.buildkite.com` as a trusted issuer for your Namespace tenant.

Alternatively, you can use [AWS Cognito federation](https://namespace.so/docs/federation/aws) for EKS clusters using [IAM Roles for Service Accounts (IRSA)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html).

## AWS Cognito setup (for EKS)

> 📘
> When using Buildkite OIDC (recommended), skip to [Building a custom agent image](/docs/agent/v3/self-hosted/agent-stack-k8s/namespace-container-builds#building-a-custom-agent-image).

### Setup

First, create a [Cognito Identity Pool](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-identity.html) and establish trust with Namespace:

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

Next, enable the [EKS OIDC provider](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) and create an IAM role:

```bash
# Enable OIDC
eksctl utils associate-iam-oidc-provider --cluster <your-cluster-name> --approve

# Create role with Cognito permissions (check the official AWS documentation for policy details)
aws iam create-role \
  --role-name <your-agent-stack-k8s-service-account> \
  --assume-role-policy-document file://trust-policy.json

# Annotate service account
kubectl annotate serviceaccount <your-agent-stack-k8s-service-account> \
  -n <your-agent-stack-k8s-namespace> \
  eks.amazonaws.com/role-arn=arn\:aws\:iam::<account-id>:role/<your-agent-stack-k8s-service-account>
```

For the detailed IAM policy configuration, see [Namespace AWS federation documentation](https://namespace.so/docs/federation/aws).

## Building a custom agent image

Create a Dockerfile that includes Docker CLI, Buildx, and Namespace CLI:

```dockerfile
# Use the official Buildkite Agent Alpine Kubernetes image as base
FROM buildkite/agent:alpine-k8s

# Switch to root
USER root

# Install bash, Docker CLI, and Buildx from the Alpine repositories
RUN apk add --no-cache \
    bash \
    docker-cli \
    docker-cli-buildx \
    curl

# Install Namespace CLI
RUN curl -fsSL https://get.namespace.so/cloud/install.sh | sh

# Add nsc to PATH
ENV PATH="/root/.ns/bin:$PATH"

# Verify installations
RUN docker --version && \
    docker buildx version && \
    test -f /root/.ns/bin/nsc && echo "nsc installed successfully"

WORKDIR /workspace
```

Build and push the image to your container registry:

```bash
docker build -t <registry>/<image-name>:latest -f Dockerfile.buildkite-namespace .
docker push <registry>/<image-name>:latest
```

## Configure Agent Stack for Kubernetes

Update Helm values to use the custom image:

```yaml
config:
  agent-config:
    shell: /bin/bash -e -c
  image: <registry>/<image-name>:latest
  tags:
  - queue=kubernetes
  pod-spec-patch:
    serviceAccountName: <your-agent-stack-k8s-service-account>
    containers: []
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

Use this option to use AWS Cognito federation for EKS clusters with IAM Roles for Service Accounts (IRSA). The Buildkite Agent pod authenticates using Cognito, then Namespace provisions the remote builders for the pipeline.

```yaml
    command: |
      # Authenticate using AWS Cognito
      /root/.ns/bin/nsc auth exchange-aws-cognito-token \
        --aws_region <your-region> \
        --identity_pool <pool-guid> \
        --tenant_id <workspace-id>
```

## Pushing to external registries

Use Buildkite's registry plugins to handle authentication so the step from the [Complete pipeline example](#complete-pipeline-example) stays focused on the Namespace build. Add the relevant plugin block beneath the step's `agents` definition.

### Docker Hub

Use the [Docker Login Buildkite plugin](https://github.com/buildkite-plugins/docker-login-buildkite-plugin) to authenticate with Docker Hub before pushing images.

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

The following example shows a complete step with Namespace authentication, Buildx setup, and a registry plugin. Uncomment the authentication option and registry plugin that match the environment.

```yaml
agents:
  queue: kubernetes

steps:
  - label: ":docker: Build with Namespace"
    plugins:
      # Uncomment the registry plugin that matches your destination.
      # Docker Hub:
      # - docker-login#v2.1.0:
      #     registry: https://index.docker.io/v1/
      #     username: "${DOCKER_USERNAME}"
      #     password-env: DOCKER_PASSWORD

      # Amazon ECR:
      # - ecr#v3.3.0:
      #     login: true
      #     account-ids:
      #       - <account-id>
      #     region: <your-region>

    command: |
      # Option A: Authenticate using Buildkite OIDC (recommended)
      OIDC_TOKEN=$$(buildkite-agent oidc request-token --audience federation.namespaceapis.com)
      /root/.ns/bin/nsc auth exchange-oidc-token \
        --token "$$OIDC_TOKEN" \
        --tenant_id <workspace-id>

      # Option B: Authenticate using AWS Cognito
      # /root/.ns/bin/nsc auth exchange-aws-cognito-token \
      #   --aws_region <your-region> \
      #   --identity_pool <pool-guid> \
      #   --tenant_id <workspace-id>

      # Configure Namespace Buildx builder and push multi-platform image
      /root/.ns/bin/nsc docker buildx setup --background --use
      /root/.ns/bin/nsc docker login
      docker buildx build \
        --builder nsc-remote \
        --platform linux/amd64,linux/arm64 \
        -t nscr.io/<workspace-id>/<your-image-name>:latest \
        --push \
        .

      # Alternative: push to another registry (same one that was configured above with plugin)
      # docker buildx build \
      #   --builder nsc-remote \
      #   --platform linux/amd64,linux/arm64 \
      #   -t <registry>/<image-name>:latest \
      #   --push \
      #   .
```

## Troubleshooting

This section covers the possible issues that might arise when using Namespace remote builder container builds and how to fix them.

### Authentication fails

- OIDC "nothing matched" error: Contact [Namespace support](https://namespace.so/support) to register `https://agent.buildkite.com` as the OIDC issuer, or verify AWS Cognito setup.
- Pod using node role: Verify that the EKS OIDC provider is enabled and the service account has IAM role annotation.
- Cognito permission denied: Ensure that the IAM role policy includes `cognito-identity:GetOpenIdTokenForDeveloperIdentity`.

### Registry authentication fails

Run `nsc docker login` before building.

### Builder not found

Run `nsc docker buildx setup --background --use` before building.

### Shell execution errors

Configure agent to use bash in Helm values:

```yaml
config:
  agent-config:
    shell: /bin/bash -e -c
```
