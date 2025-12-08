---
toc_include_h3: false
---

# Container builds with Depot

You can use [Depot](https://depot.dev/) remote builders to build container images in your Buildkite pipelines on agents that are auto-scaled by the [Buildkite Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws). Depot runs Docker builds on dedicated build infrastructure, offloading build workloads from your EC2 agents.

> 🚧 Warning!
> The Depot installation method uses `curl | sh`, which executes scripts directly. Review the installation script before use in production environments. Consider downloading and verifying the script separately, or installing Depot CLI in your agent bootstrap script for better security control.

## Special considerations regarding Elastic CI Stack for AWS

When using Depot with the Buildkite Elastic CI Stack for AWS, consider the following requirements and best practices for successful container builds.

### Depot remote builders

Depot provides remote build infrastructure that runs Docker builds on dedicated hardware, eliminating the need for Docker daemons on your EC2 agents. This approach offers several advantages:

- **No Docker daemon required**: Builds run on Depot's infrastructure, not on your EC2 agents
- **Faster builds**: Dedicated build hardware with optimized caching and parallelization
- **Reduced agent load**: Build workloads are offloaded from your EC2 instances
- **Better isolation**: Each build runs in isolated Depot environments
- **Multi-platform support**: Build for multiple architectures without additional configuration
- **Cost efficiency**: Smaller EC2 instances can be used since they don't need to run Docker builds

### Depot project configuration

Depot requires a project ID to route builds to the correct infrastructure. You can configure your Depot project in two ways, with the following precedence order (highest to lowest):

1. **Environment variable**: `DEPOT_PROJECT_ID` (highest precedence)
2. **Configuration file**: `depot.json` file in your repository (lowest precedence)

#### Environment variable (recommended for AWS)

Set `DEPOT_PROJECT_ID` in your Buildkite pipeline environment variables or in your Elastic CI Stack agent environment hooks. This approach is recommended for AWS environments as it's easier to manage via AWS Secrets Manager and doesn't require repository changes:

```yaml
steps:
  - label: "\:docker\: Build with Depot"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      docker build -t your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER} .
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

You can also set `DEPOT_PROJECT_ID` globally in your Elastic CI Stack configuration using agent environment hooks:

```bash
# In your agent bootstrap script or environment hook
export DEPOT_PROJECT_ID="your-project-id"
```

#### Configuration file (depot.json)

Use `depot init` to create a `depot.json` file in your repository. Before running `depot init`, you must authenticate with Depot:

```bash
# First, authenticate with Depot
depot login

# Then initialize the project configuration
depot init
```

The `depot init` command creates a `depot.json` file in the current directory with the following format:

```json
{
  "project": "your-project-id"
}
```

This file is automatically detected by the Depot CLI when present in your repository root. The `depot.json` file should be committed to your repository.

#### Precedence order

When multiple methods are specified, Depot uses the following precedence (highest to lowest):

1. `DEPOT_PROJECT_ID` environment variable
2. `depot.json` configuration file

For AWS environments, using the environment variable approach is recommended as it provides the most flexibility and doesn't require repository changes.

### Depot CLI installation

Depot integrates with Docker via a CLI plugin. The Depot CLI must be installed on your EC2 agents to enable remote builds. You can install it in your agent bootstrap script or as part of your build steps.

Install the Depot CLI in your agent bootstrap script:

```bash
# In your Elastic CI Stack agent bootstrap script
curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
```

Alternatively, install it at runtime in your Buildkite pipeline steps:

```yaml
steps:
  - label: "Install Depot and build"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      docker build -t my-image .
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

### Authentication

Depot requires authentication to access your projects. Depot supports OIDC trust relationships with Buildkite, which is the recommended authentication method as it provides ephemeral tokens without managing static credentials.

#### OIDC trust relationships (recommended)

Configure an OIDC trust relationship between Buildkite and Depot to use ephemeral tokens automatically. This eliminates the need to manage static tokens and improves security.

Set up the OIDC trust relationship in your Depot project settings. The Depot CLI automatically detects Buildkite's OIDC credentials from the Elastic CI Stack agents and uses them for authentication when an OIDC trust relationship is configured.

No additional configuration is needed in your pipeline, simply set `DEPOT_PROJECT_ID`. According to the [Depot Buildkite integration documentation](https://depot.dev/docs/container-builds/integrations/buildkite), the CLI supports OIDC authentication by default in Buildkite when you have a trust relationship configured:

```yaml
steps:
  - label: "\:docker\: Build with Depot (OIDC)"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot build -t your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER} .
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      # OIDC authentication is handled automatically by Depot CLI
      # No DEPOT_TOKEN needed when using OIDC trust relationships
```

#### Static token authentication (alternative)

For environments where OIDC is not available, you can use static project tokens. Store your Depot token in AWS Secrets Manager and reference it in your pipeline:

Create a secret in AWS Secrets Manager:

```bash
aws secretsmanager create-secret \
  --name buildkite/depot-token \
  --secret-string "your-depot-token"
```

Ensure your Elastic CI Stack agents have IAM permissions to read the secret. Add the following policy to your agent IAM role:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "arn:aws:secretsmanager:region:account-id:secret:buildkite/depot-token-*"
    }
  ]
}
```

Configure your Buildkite pipeline to retrieve the secret and use it:

```yaml
steps:
  - label: "\:docker\: Build with Depot"
    command: |
      export DEPOT_TOKEN=$(aws secretsmanager get-secret-value --secret-id buildkite/depot-token --query SecretString --output text)
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      docker build -t your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER} .
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
```

> 🚧 Warning!
> Static tokens persist until rotated. OIDC trust relationships provide ephemeral tokens that automatically expire, reducing the risk of credential exposure. Use OIDC when possible.

### Build context and file access

Depot builds require access to your build context, which is typically the checked-out repository on the EC2 agent's filesystem. Ensure your build context is accessible and includes all necessary files for the build.

For large build contexts, Depot efficiently handles context uploads and can optimize transfers. However, consider using `.depotignore` files to exclude unnecessary files from the build context, similar to `.dockerignore`.

### Resource allocation

Since builds run on Depot's infrastructure, your EC2 agents don't need to allocate resources for Docker daemons or build processes. This allows you to use smaller, more cost-effective EC2 instances that primarily handle:

- Repository checkout
- Build orchestration
- Artifact handling
- Post-build steps

Configure your Elastic CI Stack agent instance types accordingly:

- **Smaller instance types**: Agents only need resources for agent operations, not builds
- **Network bandwidth**: Ensure sufficient bandwidth for context uploads and image pulls
- **Storage**: Minimal ephemeral storage needed since builds run remotely

## Configuration approaches with Depot

Depot supports different workflow patterns for building container images in your Buildkite pipelines, each suited to specific use cases when using the Elastic CI Stack for AWS.

> **Note**: The examples below include `DEPOT_TOKEN` in the environment variables. If you're using OIDC trust relationships (recommended), you can omit `DEPOT_TOKEN` as authentication is handled automatically. Only include `DEPOT_TOKEN` when using static token authentication.

### Basic Docker build with Depot

Build images in your Buildkite pipeline using Depot's remote builders. According to the [Depot Buildkite integration documentation](https://depot.dev/docs/container-builds/integrations/buildkite), you can use `depot build` directly:

```yaml
steps:
  - label: "\:docker\: Build with Depot"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot build -t your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER} .
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

Alternatively, you can use `depot configure-docker` to configure Docker CLI to use Depot, then use standard `docker build` commands:

```yaml
steps:
  - label: "\:docker\: Build with Depot (Docker CLI)"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      docker build -t your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER} .
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```


### Building and pushing with Depot

Build and push images in your Buildkite pipeline using Depot's remote builders. According to the [Depot Buildkite integration documentation](https://depot.dev/docs/container-builds/integrations/buildkite), you can use `depot build` with the `--push` flag. For private registries, authenticate before building:

```yaml
steps:
  - label: "\:docker\: Build and push with Depot"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot build -t your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER} --push .
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

If you're using a private repository, authenticate before pushing:

```yaml
steps:
  - label: "\:docker\: Build and push with Depot"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      echo "${REGISTRY_PASSWORD}" | docker login your-registry.example.com -u "${REGISTRY_USERNAME}" --password-stdin
      docker build -t your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER} .
      docker push your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER}
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
      REGISTRY_USERNAME: "${REGISTRY_USERNAME}"
      REGISTRY_PASSWORD: "${REGISTRY_PASSWORD}"
```

### Building and pushing to AWS ECR with Depot

For AWS ECR, authenticate using AWS CLI as shown in the [Depot Buildkite integration documentation](https://depot.dev/docs/container-builds/integrations/buildkite):

```yaml
steps:
  - label: "\:docker\: Build and push to ECR with Depot"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      # AWS CLI is pre-installed on Elastic CI Stack for AWS agents
      aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-west-2.amazonaws.com
      depot build -t 123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app:${BUILDKITE_BUILD_NUMBER} --push .
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

Alternatively, you can use the [ECR plugin](https://github.com/buildkite-plugins/ecr-buildkite-plugin) for authentication, which works seamlessly with Depot builds:

```yaml
steps:
  - label: "\:docker\: Build and push to ECR with Depot (ECR plugin)"
    plugins:
      - ecr#v2.11.0:
          login: true
          account-ids: "123456789012"
          region: us-west-2
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      docker build -t 123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app:${BUILDKITE_BUILD_NUMBER} .
      docker push 123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app:${BUILDKITE_BUILD_NUMBER}
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

The [ECR plugin](https://github.com/buildkite-plugins/ecr-buildkite-plugin) handles authentication automatically using the Elastic CI Stack agent's IAM role, so no manual credentials are needed.

### Using Depot with Docker Compose

Depot works seamlessly with Docker Compose builds in your Buildkite pipelines. Configure Depot before running compose builds:

```yaml
steps:
  - label: "\:docker\: Build with Depot and Docker Compose"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      docker compose build
      docker compose push
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

## Customizing builds with Depot

Customize your Depot builds in Buildkite pipelines by using Depot-specific features and configuration options.

### Multi-platform builds

Build for multiple architectures in your Buildkite pipeline using Depot's multi-platform support. According to the [Depot Buildkite integration documentation](https://depot.dev/docs/container-builds/integrations/buildkite), use the `--platform` flag with `depot build`:

```yaml
steps:
  - label: "\:docker\: Multi-platform build"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot build --platform linux/amd64,linux/arm64 -t your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER} -t your-registry.example.com/app:latest --push .
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

### Using Depot cache

Depot provides native caching that works automatically when you use `depot configure-docker`—no additional configuration is required. Depot manages cache layers on its infrastructure, which persist across builds within the same project.

## Troubleshooting

This section can help you to identify and solve the issues that most commonly arise when using Depot with Buildkite Pipelines on Elastic CI Stack for AWS.

### Depot authentication failures

Builds fail with authentication errors when Depot cannot access your project.

**Problem**: Missing or invalid authentication credentials or project ID.

**Solution**: 

For OIDC trust relationships (recommended), ensure the trust relationship is configured in your Depot project settings and that `DEPOT_PROJECT_ID` is set in your pipeline:

```yaml
steps:
  - label: "\:docker\: Build with Depot"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      docker build -t my-image .
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      # OIDC authentication handled automatically, no DEPOT_TOKEN needed
```

For static token authentication, ensure your Depot token and project ID are correctly configured. Verify the token is accessible from your EC2 agents:

```yaml
steps:
  - label: "\:docker\: Build with Depot"
    command: |
      export DEPOT_TOKEN=$(aws secretsmanager get-secret-value --secret-id buildkite/depot-token --query SecretString --output text)
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      docker build -t my-image .
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
```

Verify authentication by checking your Depot dashboard. For OIDC, ensure the trust relationship is active. For static tokens, verify the token has access to the specified project and that your EC2 agents have IAM permissions to access AWS Secrets Manager.

### Depot CLI not found

Builds fail with "depot: command not found" errors.

**Problem**: Depot CLI is not installed on the EC2 agent.

**Solution**: Install Depot CLI before using it:

```yaml
steps:
  - label: "Install Depot CLI"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

Alternatively, include Depot CLI installation in your Elastic CI Stack agent bootstrap script to install it once for all builds.

### Build context upload failures

Builds fail when uploading build context to Depot.

**Problem**: Network issues or build context too large.

**Solution**: 
- Check network connectivity from your EC2 agents to Depot
- Verify security group rules allow outbound HTTPS traffic to `depot.dev`
- Verify VPC routing and internet gateway configuration
- Use `.depotignore` files to reduce build context size
- Check Depot service status

### Docker not configured for Depot

Builds run locally on the EC2 agent instead of on Depot infrastructure.

**Problem**: Depot Docker plugin not configured.

**Solution**: Run `depot configure-docker` before building:

```yaml
steps:
  - label: "Configure and build"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      docker build -t my-image .
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

You can confirm builds are using Depot by looking for `[depot]` prefixed log lines in the build output.

### Registry push failures

Pushing images to registries fails after Depot builds.

**Problem**: Authentication or network issues when pushing from Depot infrastructure.

**Solution**: Ensure registry credentials are properly configured. For private registries, authenticate before pushing:

```yaml
steps:
  - label: "\:docker\: Build and push with Depot"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      echo "${REGISTRY_PASSWORD}" | docker login your-registry.example.com -u "${REGISTRY_USERNAME}" --password-stdin
      docker build -t your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER} .
      docker push your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER}
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
      REGISTRY_USERNAME: "${REGISTRY_USERNAME}"
      REGISTRY_PASSWORD: "${REGISTRY_PASSWORD}"
```

In this example, the build runs on Depot's infrastructure (via `depot configure-docker`), but the `docker push` command runs on the agent, so authentication is configured on the agent. When using `depot build --push` instead, Depot reads registry credentials from the agent's Docker configuration and performs the push from Depot's infrastructure.

### AWS Secrets Manager access issues

Builds fail when trying to retrieve `DEPOT_TOKEN` from AWS Secrets Manager.

**Problem**: EC2 agent IAM role lacks permissions or secret doesn't exist.

**Solution**: 

1. Verify the secret exists:
```bash
aws secretsmanager describe-secret --secret-id buildkite/depot-token
```

2. Ensure your Elastic CI Stack agent IAM role has the necessary permissions:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "arn:aws:secretsmanager:region:account-id:secret:buildkite/depot-token-*"
    }
  ]
}
```

3. Test secret access from an agent:
```bash
aws secretsmanager get-secret-value --secret-id buildkite/depot-token --query SecretString --output text
```

## Debugging builds

When builds fail or behave unexpectedly with Depot in your Buildkite pipelines, use these debugging approaches to diagnose issues.

### Enable verbose output

Use Docker's build output to see detailed build information. Depot builds will show `[depot]` prefixed log lines indicating Depot is handling the build:

```yaml
steps:
  - label: "\:docker\: Debug build with Depot"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      docker build --progress=plain -t my-image .
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

The `--progress=plain` flag shows detailed build output, and you can verify Depot is being used by looking for `[depot]` prefixed lines in the build logs.

### Check Depot build logs

View build logs in the Depot dashboard to see detailed information about build execution, including:

- Build context upload progress
- Layer build steps
- Cache hit/miss information
- Error details

Access your Depot dashboard to view build history and logs for troubleshooting.

### Verify Depot configuration

Test Depot configuration before running builds:

```yaml
steps:
  - label: "Verify Depot setup"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      depot projects list
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

This verifies authentication and project access before attempting builds.

### Test builds locally

Test your Dockerfile and build configuration locally before running on Elastic CI Stack:

```bash
# Install Depot CLI locally
curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh

# Configure Depot
depot configure-docker

# Test build
docker build -t my-image .

# Verify build uses Depot (look for [depot] in output)
```

This helps identify issues with build configuration before running on Elastic CI Stack agents.

### Inspect build logs in AWS

SSH into your EC2 agent to inspect build logs and verify Depot configuration:

```bash
# Find your agent instance
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=buildkite-agent" \
  --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress,State.Name]' \
  --output table

# SSH into the agent (user may be 'ec2-user', 'ubuntu', or 'admin' depending on AMI)
ssh -i your-key.pem ec2-user@<agent-ip>

# Check Depot CLI installation
which depot
depot --version

# Verify Docker configuration
docker info | grep -i depot
```

This helps diagnose issues with Depot CLI installation or Docker configuration on the agent.

