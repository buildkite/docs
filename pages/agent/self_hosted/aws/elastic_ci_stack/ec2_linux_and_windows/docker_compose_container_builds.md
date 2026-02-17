---
toc_include_h3: false
---

# Docker Compose builds

The [Docker Compose plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-compose-buildkite-plugin/) helps you build and run multi-container Docker applications. You can build and push container images using the Docker Compose plugin on agents that are auto-scaled by the [Buildkite Elastic CI Stack for AWS](/docs/agent/aws).

## Special considerations regarding Elastic CI Stack for AWS

When running the [Docker Compose plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-compose-buildkite-plugin/) within the Buildkite Elastic CI Stack for AWS, consider the following requirements and best practices for successful container builds.

### Docker daemon access

The Elastic CI Stack for AWS provides EC2 instances with Docker pre-installed and running. Each agent has its own Docker daemon, providing complete isolation between builds without the complexity of Docker-in-Docker or socket mounting.

### Build context and file access

In Elastic CI Stack for AWS, the build context is the checked-out repository on the EC2 agent's filesystem. By default, the [Docker Compose plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-compose-buildkite-plugin/) uses the current working directory as the build context.

If your `docker-compose.yml` references files outside the repository directory, ensure they are:

- Included in your repository
- Available through [Buildkite artifact uploads](/docs/agent/cli/reference/artifact#uploading-artifacts) from previous steps
- Accessible via network mounts or external storage

For build caching or sharing artifacts across builds, use:

- Container registry for build cache layers
- Buildkite artifacts for build outputs
- AWS S3 for large artifacts or dependencies

### Registry authentication

Set up proper authentication for pushing to container registries:

- Use the `docker-login` plugin for standard Docker registries
- Use the `ecr` plugin for AWS ECR (recommended for AWS environments)
- Use the `gcp-workload-identity-federation` plugin for Google Artifact Registry

When pushing services, ensure the `image:` field is set in `docker-compose.yml` to specify the full registry path.

For AWS ECR, the Elastic CI Stack for AWS agents can use IAM roles for authentication, eliminating the need to manage credentials manually.

### Resource allocation

Building container images can be resource-intensive, especially for large applications or when building multiple services. Configure your Elastic CI Stack for AWS agent instance types and other required resources accordingly. Without appropriate resources, builds may fail with Out of Memory (OOM) errors or timeouts

## Configuration approaches with the Docker Compose plugin

The Docker Compose plugin supports different workflow patterns for building and pushing container images, each suited to specific use cases in Elastic CI Stack for AWS environments.

### Push to Buildkite Package Registries

You can push a built image directly to Buildkite Package Registries by using the following example configuration:

```yaml
steps:
  - label: "\:docker\: Build and push to Buildkite Package Registries"
    agents:
      queue: default
    plugins:
      - docker-login#v3.0.0:
          server: packages.buildkite.com/{org.slug}/{registry.slug}
          username: "${REGISTRY_USERNAME}"
          password-env: "REGISTRY_PASSWORD"
      - docker-compose#v5.12.1:
          build: app
          push:
            - app:packages.buildkite.com/{org.slug}/{registry.slug}/image-name:${BUILDKITE_BUILD_NUMBER}
          cache-from:
            - app:packages.buildkite.com/{org.slug}/{registry.slug}/image-name:cache
          buildkit: true
          buildkit-inline-cache: true
```

### Basic Docker Compose build

Build the services defined in your `docker-compose.yml` file:

```yaml
steps:
  - label: "Build with Docker Compose"
    agents:
      queue: default
    plugins:
      - docker-compose#v5.12.1:
          build: app
          config: docker-compose.yml
```

This is what a sample `docker-compose.yml` file would look like:

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: your-registry.example.com/your-team/app:bk-${BUILDKITE_BUILD_NUMBER}
```

### Building and pushing with the Docker Compose plugin

Build and push images in a single step:

```yaml
steps:
  - label: "\:docker\: Build and push"
    agents:
      queue: default
    plugins:
      - docker-compose#v5.12.1:
          build: app
          push: app
```

If you're using a private repository, add authentication:

```yaml
steps:
  - label: "\:docker\: Build and push"
    agents:
      queue: default
    plugins:
      - docker-login#v3.0.0:
          server: your-registry.example.com
          username: "${REGISTRY_USERNAME}"
          password-env: "REGISTRY_PASSWORD"
      - docker-compose#v5.12.1:
          build: app
          push: app
```

### Build and push to AWS ECR

Build and push images to AWS ECR using IAM role authentication:

```yaml
steps:
  - label: "\:docker\: Build and push to ECR"
    agents:
      queue: default
    plugins:
      - ecr#v2.11.0:
          login: true
          account-ids: "123456789012"
          region: us-west-2
      - docker-compose#v5.12.1:
          build: app
          push:
            - app:123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app:${BUILDKITE_BUILD_NUMBER}
            - app:123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app:latest
          cache-from:
            - app:123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app:cache
          buildkit: true
          buildkit-inline-cache: true
```

Corresponding `docker-compose.yml`:

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: 123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app:${BUILDKITE_BUILD_NUMBER}
```

### Multi-service build with ECR

You can build multiple services and push them to ECR with proper tagging:

```yaml
steps:
  - label: "\:docker\: Build microservices"
    agents:
      queue: default
    plugins:
      - ecr#v2.11.0:
          login: true
          account-ids: "123456789012"
          region: us-west-2
      - docker-compose#v5.12.1:
          build:
            - frontend
            - backend
            - api
          push:
            - frontend:123456789012.dkr.ecr.us-west-2.amazonaws.com/frontend:${BUILDKITE_BUILD_NUMBER}
            - backend:123456789012.dkr.ecr.us-west-2.amazonaws.com/backend:${BUILDKITE_BUILD_NUMBER}
            - api:123456789012.dkr.ecr.us-west-2.amazonaws.com/api:${BUILDKITE_BUILD_NUMBER}
          cache-from:
            - frontend:123456789012.dkr.ecr.us-west-2.amazonaws.com/frontend:cache
            - backend:123456789012.dkr.ecr.us-west-2.amazonaws.com/backend:cache
            - api:123456789012.dkr.ecr.us-west-2.amazonaws.com/api:cache
          buildkit: true
          buildkit-inline-cache: true
```

## Customizing the build

Customize your Docker Compose builds by using the Docker Compose plugin's configuration options to control build behavior, manage credentials, and optimize performance.

### Using build arguments

Pass build arguments to customize image builds at build time. You can add parameters to Dockerfiles without directly embedding values in the file by using build arguments:

```yaml
steps:
  - label: "\:docker\: Build with arguments"
    agents:
      queue: default
    plugins:
      - docker-compose#v5.12.1:
          build: app
          args:
            - NODE_ENV=production
            - BUILD_NUMBER=${BUILDKITE_BUILD_NUMBER}
            - API_URL=${API_URL}
```

### Building specific services

When your `docker-compose.yml` defines multiple services, you are able to build only the services you need rather than building everything:

```yaml
steps:
  - label: "\:docker\: Build frontend only"
    agents:
      queue: default
    plugins:
      - docker-compose#v5.12.1:
          build: frontend
          push: frontend
```

### Using BuildKit features with cache optimization

[BuildKit](https://docs.docker.com/build/buildkit/) provides advanced build features including build cache optimization. BuildKit's inline cache stores cache metadata in the image itself, enabling cache reuse across different build agents. Here is an example configuration:

```yaml
steps:
  - label: "\:docker\: Build with BuildKit cache"
    agents:
      queue: default
    plugins:
      - ecr#v2.11.0:
          login: true
          account-ids: "123456789012"
          region: us-west-2
      - docker-compose#v5.12.1:
          build: app
          cache-from:
            - app:123456789012.dkr.ecr.us-west-2.amazonaws.com/app:cache
          buildkit: true
          buildkit-inline-cache: true
          push:
            - app:123456789012.dkr.ecr.us-west-2.amazonaws.com/app:${BUILDKITE_BUILD_NUMBER}
            - app:123456789012.dkr.ecr.us-west-2.amazonaws.com/app:cache
```

### Using multiple compose files

Combine multiple compose files to create layered configurations. This pattern works well for separating base configuration from environment-specific overrides:

```yaml
steps:
  - label: "\:docker\: Build with compose file overlay"
    agents:
      queue: default
    plugins:
      - docker-compose#v5.12.1:
          config:
            - docker-compose.yml
            - docker-compose.production.yml
          build: app
          push: app
```

### Custom image tagging on push

You can push the same image with multiple tags to support different deployment strategies. This is useful for maintaining both immutable version tags and mutable environment tags:

```yaml
steps:
  - label: "\:docker\: Push with multiple tags"
    agents:
      queue: default
    plugins:
      - ecr#v2.11.0:
          login: true
          account-ids: "123456789012"
          region: us-west-2
      - docker-compose#v5.12.1:
          build: app
          push:
            - app:123456789012.dkr.ecr.us-west-2.amazonaws.com/app:${BUILDKITE_BUILD_NUMBER}
            - app:123456789012.dkr.ecr.us-west-2.amazonaws.com/app:${BUILDKITE_COMMIT}
            - app:123456789012.dkr.ecr.us-west-2.amazonaws.com/app:latest
            - app:123456789012.dkr.ecr.us-west-2.amazonaws.com/app:${BUILDKITE_BRANCH}
          cache-from:
            - app:123456789012.dkr.ecr.us-west-2.amazonaws.com/app:cache
          buildkit: true
          buildkit-inline-cache: true
```

### Using SSH agent for private repositories

If you enable SSH agent forwarding, you will be able to access private Git repositories or packages during the build. Use this when Dockerfiles need to clone private dependencies. Example configuration:

```yaml
steps:
  - label: "\:docker\: Build with SSH access"
    agents:
      queue: default
    plugins:
      - docker-compose#v5.12.1:
          build: app
          ssh: true
```

Your Dockerfile needs to use BuildKit's SSH mount feature:

```dockerfile
# syntax=docker/dockerfile:1
FROM node:18

# Install dependencies from private repository
RUN --mount=type=ssh git clone git@github.com:yourorg/private-lib.git
```

## Troubleshooting

This section can help you to identify and solve the issues that might arise when using Docker Compose container builds with Buildkite Pipelines on Elastic CI Stack for AWS.

### Network connectivity

Network policies, security groups, or DNS configuration issues can restrict EC2 agent networking. As a result, builds may fail with errors like "could not resolve host," "connection timeout," or "unable to pull image" when trying to pull base images from Docker Hub or push to your private registry.

To resolve these issues:

- Verify that your Elastic CI Stack security groups allow outbound HTTPS traffic (port `443`) for registry access
- Check VPC routing and internet gateway configuration
- Verify DNS resolution in your VPC
- Ensure NAT gateway is configured if agents are in private subnets
- Test registry connectivity from an agent instance using `docker pull` or `docker login`

### Resource constraints

Docker builds may fail with errors like "signal: killed," "build container exited with code 137," or builds that hang indefinitely and timeout. These usually signal insufficient memory or CPU resources allocated to your EC2 agent instances, causing the Linux kernel to kill processes (Out of Memory or OOM).

To resolve these issues:

- Check CloudWatch metrics for agent instance CPU and memory utilization
- Upgrade to larger instance types (e.g., from `c5.large` to `c5.xlarge` or `c5.2xlarge`)
- Monitor build logs for memory-related errors
- Optimize Dockerfiles to reduce resource requirements
- Use multi-stage builds to reduce final image size
- Consider building smaller, more focused images

### Build cache not working

Docker builds rebuild all layers even when source files haven't changed. This happens when build cache is not preserved between builds or when cache keys don't match.

To enable build caching with BuildKit:

```yaml
plugins:
  - ecr#v2.11.0:
      login: true
      account-ids: "123456789012"
      region: us-west-2
  - docker-compose#v5.12.1:
      build: app
      cache-from:
        - app:123456789012.dkr.ecr.us-west-2.amazonaws.com/app:cache
      buildkit: true
      buildkit-inline-cache: true
      push:
        - app:123456789012.dkr.ecr.us-west-2.amazonaws.com/app:${BUILDKITE_BUILD_NUMBER}
        - app:123456789012.dkr.ecr.us-west-2.amazonaws.com/app:cache
```

Ensure that the cache image exists in your registry before running the first build, or accept that the initial build will be slower. Subsequent builds will use the cached layers.

### Environment variables not available during build

Environment variables from your Buildkite pipeline aren't accessible inside your Dockerfile during the build process. Docker builds are isolated and don't automatically inherit environment variables.

To pass environment variables to the build, use build arguments:

```yaml
plugins:
  - docker-compose#v5.12.1:
      build: app
      args:
        - API_URL=${API_URL}
        - BUILD_NUMBER=${BUILDKITE_BUILD_NUMBER}
        - COMMIT_SHA=${BUILDKITE_COMMIT}
```

Then reference the passed environment variables in your Dockerfile:

```dockerfile
ARG API_URL
ARG BUILD_NUMBER
ARG COMMIT_SHA
RUN echo "Building version ${BUILD_NUMBER} from commit ${COMMIT_SHA}"
```

Note that the `args` option in the Docker Compose plugin passes variables at build time, while the `environment` option passes variables at runtime (for running containers, not building images).

### Image push failures

Pushing images to registries fails with authentication errors or timeout errors.

For authentication failures, ensure credentials are properly configured. Use the [Docker Login Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-login-buildkite-plugin/) before the [Docker Compose Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-compose-buildkite-plugin/):

```yaml
plugins:
  - docker-login#v3.0.0:
      server: your-registry.example.com
      username: "${REGISTRY_USERNAME}"
      password-env: "REGISTRY_PASSWORD"
  - docker-compose#v5.12.1:
      build: app
      push: app
```

For AWS ECR, use the ECR plugin which handles authentication automatically:

```yaml
plugins:
  - ecr#v2.11.0:  # For AWS ECR
      login: true
      account-ids: "123456789012"
      region: us-west-2
  - docker-compose#v5.12.1:
      build: app
      push: app
```

Ensure the Elastic CI Stack agent IAM role has the necessary ECR permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ecr:GetAuthorizationToken"],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "arn:aws:ecr:region:123456789012:repository/name"
    }
  ]
}
```

For timeout or network failures, enable push retries:

```yaml
plugins:
  - docker-compose#v5.12.1:
      build: app
      push: app
      push-retries: 3
```

### Agent startup and scaling issues

Builds may fail due to agent startup problems or scaling limitations:

- Agent startup failures - check AWS CloudWatch logs for agent initialization errors.
- Instance availability issues - verify sufficient instance capacity in your AWS region and availability zones.
- IAM permissions issues - ensure the Elastic CI Stack has permissions to launch and manage EC2 instances.
- VPC configuration issues - verify that VPC, subnets, and security groups are correctly configured.

## Debugging builds

When builds fail or behave in unexpected manner, you need to enable verbose output and disable caching to diagnose the issue.

### Enable verbose output

Use the `verbose` option in the Docker Compose plugin to see detailed output from Docker Compose operations:

```yaml
steps:
  - label: "\:docker\: Debug build"
    agents:
      queue: default
    plugins:
      - docker-compose#v5.12.1:
          build: app
          verbose: true
```

The detailed output shows all Docker Compose commands being executed and their full output, helping identify where failures occur.

### Disable build cache

Disable caching to ensure builds run from scratch, which can reveal caching-related issues:

```yaml
steps:
  - label: "\:docker\: Build without cache"
    agents:
      queue: default
    plugins:
      - docker-compose#v5.12.1:
          build: app
          no-cache: true
```

### Test docker-compose locally

Test your `docker-compose.yml` configuration locally before running in the pipeline:

```bash
# Validate compose file syntax
docker compose config

# Build without the Docker Compose plugin
docker compose build

# Check what images were created
docker images
```

Local execution helps identify issues with the compose configuration itself, separate from pipeline or Elastic CI Stack concerns.
