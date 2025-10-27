# Namespace remote builder container builds

[Namespace](https://namespace.so) provides [remote Docker builders](https://namespace.so/docs/solutions/docker-builders) that execute builds on dedicated infrastructure outside your Kubernetes cluster.

Unlike [Buildah](/docs/agent/v3/agent-stack-k8s/buildah-container-builds) and [BuildKit](/docs/agent/v3/agent-stack-k8s/buildkit-container-builds) which run builds inside Kubernetes pods, Namespace executes builds on remote compute instances. This eliminates the need for privileged containers, security context configuration, or storage driver setup in your cluster.

## How it works

When using Namespace remote Docker builders with Agent Stack for Kubernetes:

1. The Buildkite agent pod authenticates with Namespace (see [Authentication](#authentication)).
2. The Namespace CLI (`nsc`) configures Docker BuildX to use remote builders.
3. Build commands execute on Namespace's infrastructure, not in your cluster.
4. Built images are pushed to Namespace's container registry (`nscr.io`) or any other registry.

## Authentication

Namespace supports multiple authentication methods:

- AWS Cognito federation for EKS clusters using IAM Roles for Service Accounts (IRSA). This guide covers this approach.
- Buildkite OIDC - contact [support@namespace.so](mailto:support@namespace.so) to register `https://agent.buildkite.com` as a trusted issuer.

For more information, see [Namespace federation documentation](https://namespace.so/docs/federation).

## Prerequisites

- **Namespace account** with a workspace ([sign up](https://namespace.so))
- **Custom agent image** with Docker CLI, BuildX, and Namespace CLI
- **Authentication configured** (AWS Cognito for EKS, or OIDC federation)

## AWS Cognito setup (for EKS)

> 📘
> If using Buildkite OIDC or another authentication method, skip to [Build custom agent image](#build-custom-agent-image).

### Quick setup

1. Create Cognito Identity Pool and establish trust with Namespace:

```bash
# Create pool
aws cognito-identity create-identity-pool \
  --identity-pool-name namespace-buildkite-federation \
  --no-allow-unauthenticated-identities \
  --developer-provider-name namespace.so \
  --region us-east-1

# Trust the pool (note the pool ID from output)
nsc auth trust-aws-cognito-identity-pool \
  --aws_region us-east-1 \
  --identity_pool <pool-guid> \
  --tenant_id <workspace-id>
```

2. Enable EKS OIDC provider and create IAM role:

```bash
# Enable OIDC
eksctl utils associate-iam-oidc-provider --cluster <cluster-name> --approve

# Create role with Cognito permissions (see AWS documentation for policy details)
aws iam create-role \
  --role-name <your-agent-stack-k8s-service-account> \
  --assume-role-policy-document file://trust-policy.json

# Annotate service account
kubectl annotate serviceaccount <your-agent-stack-k8s-service-account> \
  -n <your-agent-stack-k8s-namespace> \
  eks.amazonaws.com/role-arn=arn:aws:iam::<account-id>:role/<your-agent-stack-k8s-service-account>
```

For detailed IAM policy configuration, see [Namespace AWS federation documentation](https://namespace.so/docs/federation/aws).

## Build custom agent image

Create a Dockerfile that includes Docker CLI, BuildX, and Namespace CLI:

```dockerfile
# Use the official Buildkite agent Alpine K8s image as base
FROM buildkite/agent:alpine-k8s

# Switch to root to install packages
USER root

# Install bash, Docker CLI and buildx from Alpine repositories
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
    serviceAccountName: <your-agent-stack-k8s-service-account>  # For AWS Cognito/IRSA
    containers: []
```

## Using Namespace remote builders

### AWS Cognito authentication

```yaml
steps:
  - label: ":docker: Build with Namespace"
    agents:
      queue: kubernetes
    command: |
      # Authenticate via AWS Cognito
      /root/.ns/bin/nsc auth exchange-aws-cognito-token \
        --aws_region us-east-1 \
        --identity_pool <pool-guid> \
        --tenant_id <workspace-id>

      # Configure BuildX
      /root/.ns/bin/nsc docker buildx setup --background --use
      /root/.ns/bin/nsc docker login

      # Build multi-platform image
      docker buildx build \
        --builder nsc-remote \
        --platform linux/amd64,linux/arm64 \
        -t nscr.io/<workspace-id>/myapp:$${BUILDKITE_BUILD_NUMBER} \
        --push \
        .
```

### Buildkite OIDC authentication

```yaml
steps:
  - label: ":docker: Build with Namespace"
    agents:
      queue: kubernetes
    command: |
      # Authenticate via Buildkite OIDC
      OIDC_TOKEN=$$(buildkite-agent oidc request-token --audience federation.namespaceapis.com)
      /root/.ns/bin/nsc auth exchange-oidc-token \
        --token "$$OIDC_TOKEN" \
        --tenant_id <workspace-id>

      # Configure BuildX and build
      /root/.ns/bin/nsc docker buildx setup --background --use
      /root/.ns/bin/nsc docker login

      docker buildx build \
        --builder nsc-remote \
        --platform linux/amd64,linux/arm64 \
        -t nscr.io/<workspace-id>/myapp:$${BUILDKITE_BUILD_NUMBER} \
        --push \
        .
```

## Pushing to external registries

Authenticate with the target registry before building:

```bash
# Docker Hub
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# Amazon ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Then build and push
docker buildx build --builder nsc-remote -t <registry>/myapp:latest --push .
```

## Troubleshooting

### Authentication fails

- **OIDC "nothing matched"**: Contact Namespace support to register your OIDC issuer, or verify AWS Cognito setup.
- **Pod using node role**: Verify EKS OIDC provider is enabled and service account has IAM role annotation.
- **Cognito permission denied**: Ensure IAM role policy includes `cognito-identity:GetOpenIdTokenForDeveloperIdentity`.

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
