# BuildKit container builds

[BuildKit](https://docs.docker.com/build/buildkit/) is Docker's next-generation build system that provides improved performance, better caching, parallel build execution, and efficient layer management. The Elastic CI Stack for AWS includes [Docker Buildx](https://docs.docker.com/build/concepts/overview/#buildx) ([BuildKit](https://docs.docker.com/build/buildkit/)) pre-installed on recent Linux AMI versions. BuildKit runs as part of the Docker daemon on EC2 instances.

> 📘
> Docker Buildx comes pre-installed on recent Elastic CI Stack for AWS AMI versions (starting with version `5.4.0`). If you're using an older AMI version and Buildx is not available, you can either upgrade to the latest AMI version or manually install Buildx following the [Docker Buildx installation documentation](https://docs.docker.com/build/install-buildx/).

## Using BuildKit with Elastic CI Stack for AWS

BuildKit is available through the `docker buildx build` command, which provides the same interface as `docker build`, while leveraging BuildKit's advanced features. The Elastic CI Stack for AWS supports multiple build configurations to match your security and performance requirements.

### Basic BuildKit build

You can use BuildKit through Docker Buildx with default settings, without any additional configuration. For example:

```yaml
steps:
  - label: "\:docker\: BuildKit container build"
    agents:
      queue: elastic
    command: |
      docker buildx build \
        --progress=plain \
        --file Dockerfile \
        .
```

### BuildKit with build cache

BuildKit supports efficient layer caching to speed up subsequent builds. By default, BuildKit caches layers in the Docker daemon's data directory (`/var/lib/docker` or `/mnt/ephemeral/docker` if instance storage is enabled).

For explicit local cache management within a single job or on long-running agents, you can use the local cache type:

```yaml
steps:
  - label: "\:docker\: BuildKit build with cache"
    agents:
      queue: elastic
    command: |
      docker buildx build \
        --progress=plain \
        --file Dockerfile \
        --cache-from type=local,src=/tmp/buildkit-cache \
        --cache-to type=local,dest=/tmp/buildkit-cache,mode=max \
        .
```

The `mode=max` setting exports all build layers to the cache, providing maximum cache reuse for subsequent builds.

> 📘
> Local cache directories like `/tmp/buildkit-cache` do not persist across instance terminations in autoscaling environments. For persistent cache across builds on different instances, use AWS S3 or registry's [remote cache backends](#customizing-builds-using-remote-cache-backends) instead.

### BuildKit with instance storage

When [instance storage is enabled](/docs/agent/v3/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/configuration-parameters) through the `EnableInstanceStorage` parameter in AWS CloudFormation, Docker stores images and build cache in high-performance NVMe storage at `/mnt/ephemeral/docker`. This significantly improves build performance for I/O-intensive operations.

No configuration changes are required in your pipeline YAML for using BuildKit with the instance's storage. BuildKit automatically uses the configured Docker data directory.

### BuildKit with multi-platform builds

The Elastic CI Stack for AWS supports building container images for multiple architectures. BuildKit can build images for platforms different from the host architecture (through QEMU emulation). As a result, you can build ARM64 images on x86 instances and vice versa without additional setup. Here is an example of a multi-platform build configuration:

```yaml
steps:
  - label: "\:docker\: Multi-platform build"
    agents:
      queue: elastic
    command: |
      docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --progress=plain \
        --file Dockerfile \
        .
```

For production multi-platform builds, consider using separate agents with native architecture support to avoid emulation overhead as it can significantly impact build performance.

## Building and pushing to Buildkite Package Registries

Buildkite Package Registries provide secure OCI-compliant container image storage integrated with your Buildkite organization. The registry URL format is `packages.buildkite.com/{org.slug}/{registry.slug}`.

### Authentication with OIDC

The recommended authentication method for CI/CD pipelines is [Open ID Connect (OIDC) tokens](/docs/pipelines/security/oidc). OIDC tokens are short-lived, automatically issued by the Buildkite Agent, and more secure than static API tokens.

```yaml
steps:
  - label: "\:docker\: Build and push to Package Registries"
    agents:
      queue: elastic
    env:
      REGISTRY: "packages.buildkite.com/my-org/my-registry"
    command: |
      # Authenticate using OIDC
      buildkite-agent oidc request-token \
        --audience "https://${REGISTRY}" \
        --lifetime 300 | docker login ${REGISTRY} \
        --username buildkite \
        --password-stdin

      # Build and push
      docker buildx build \
        --tag ${REGISTRY}/myapp:${BUILDKITE_BUILD_NUMBER} \
        --tag ${REGISTRY}/myapp:latest \
        --push \
        --progress=plain \
        .
```

> 📘
> OIDC authentication requires configuring an OIDC policy in your registry settings. See the [Package Registries OIDC documentation](/docs/package_registries/security/oidc) for setup instructions.

### Multi-platform builds

Build and push images for multiple architectures to Package Registries:

```yaml
steps:
  - label: "\:docker\: Multi-platform build and push"
    agents:
      queue: elastic
    env:
      REGISTRY: "packages.buildkite.com/my-org/my-registry"
    command: |
      # Authenticate
      buildkite-agent oidc request-token \
        --audience "https://${REGISTRY}" \
        --lifetime 300 | docker login ${REGISTRY} \
        --username buildkite \
        --password-stdin

      # Build for multiple platforms
      docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --tag ${REGISTRY}/myapp:${BUILDKITE_BUILD_NUMBER} \
        --push \
        --progress=plain \
        .
```

### Using Package Registries as cache backend

You can store BuildKit cache layers in Package Registries alongside your images:

```yaml
steps:
  - label: "\:docker\: Build with registry cache"
    agents:
      queue: elastic
    env:
      REGISTRY: "packages.buildkite.com/my-org/my-registry"
    command: |
      # Authenticate
      buildkite-agent oidc request-token \
        --audience "https://${REGISTRY}" \
        --lifetime 300 | docker login ${REGISTRY} \
        --username buildkite \
        --password-stdin

      # Build with cache
      docker buildx build \
        --cache-from type=registry,ref=${REGISTRY}/myapp:cache \
        --cache-to type=registry,ref=${REGISTRY}/myapp:cache,mode=max \
        --tag ${REGISTRY}/myapp:${BUILDKITE_BUILD_NUMBER} \
        --push \
        --progress=plain \
        .
```

## Building and pushing to Amazon ECR

The Elastic CI Stack for AWS includes the [ECR Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/ecr-buildkite-plugin/) for seamless Amazon ECR authentication. The plugin automatically authenticates with ECR before your build runs, allowing you to push images directly.

### Basic ECR push

This example shows a basic ECR push. Replace the placeholder values with your values.

```yaml
steps:
  - label: "\:docker\: Build and push to ECR"
    agents:
      queue: elastic
    env:
      REGISTRY: "123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp"
    command: |
      docker buildx build \
        --tag ${REGISTRY}:${BUILDKITE_BUILD_NUMBER} \
        --tag ${REGISTRY}:latest \
        --push \
        --progress=plain \
        .
```

### ECR push with build arguments

You can pass build arguments to customize your build based on Buildkite [metadata](/docs/agent/v3/cli-meta-data) or [environment variables](/docs/pipelines/configure/environment-variables#buildkite-environment-variables).

```yaml
steps:
  - label: "\:docker\: Build with args and push to ECR"
    agents:
      queue: elastic
    command: |
      docker buildx build \
        --build-arg NODE_ENV=production \
        --build-arg VERSION=${BUILDKITE_BUILD_NUMBER} \
        --build-arg BUILD_URL=$BUILDKITE_BUILD_URL \
        --tag 123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:${BUILDKITE_BUILD_NUMBER} \
        --push \
        --progress=plain \
        .
```

### Cross-account ECR push

For pushing to ECR repositories in different AWS accounts, use the [ECR plugin](https://buildkite.com/resources/plugins/buildkite-plugins/ecr-buildkite-plugin/)'s role assumption feature.

```yaml
steps:
  - label: "\:docker\: Build and push to cross-account ECR"
    agents:
      queue: elastic
    plugins:
      - ecr#v2.11.0:
          login: true
          account-ids: "999888777666"
          region: us-west-2
          assume_role:
            role_arn: "arn\:aws\:iam::999888777666:role/BuildkiteECRAccess"
    command: |
      docker buildx build \
        --tag 999888777666.dkr.ecr.us-west-2.amazonaws.com/myapp:${BUILDKITE_BUILD_NUMBER} \
        --push \
        --progress=plain \
        .
```

## Customizing builds

BuildKit provides extensive customization options through the `docker buildx build` command.

### Targeting specific build stages

Multi-stage Dockerfiles can build specific stages using the `--target` flag. For example:

```bash
docker buildx build \
  --target production \
  --tag myapp:production \
  --progress=plain \
  .
```

### Exporting build artifacts

BuildKit can export build outputs beyond container images, such as compiled binaries or [build artifacts](/docs/pipelines/configure/artifacts). For example:

```yaml
steps:
  - label: "\:docker\: Export build artifacts"
    agents:
      queue: elastic
    command: |
      docker buildx build \
        --target builder \
        --output type=local,dest=./dist \
        --progress=plain \
        .
    artifact_paths:
      - "dist/**/*"
```

This example demonstrates exporting the contents of the `builder` stage to the local `./dist` directory, which can then be uploaded as artifacts.

### Using remote cache backends

Remote cache backends provide persistent cache storage across builds to speed up container builds across agents running in the Elastic CI Stack for AWS.

#### Registry cache backend

Build cache layers can also be stored in a container registry alongside your images.

```yaml
steps:
  - label: "\:docker\: Build with registry cache"
    agents:
      queue: elastic
    plugins:
      - ecr#v2.11.0:
          login: true
    command: |
      docker buildx build \
        --cache-from type=registry,ref=123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp-cache:latest \
        --cache-to type=registry,ref=123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp-cache:latest,mode=max \
        --tag 123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:latest \
        --push \
        --progress=plain \
        .
```

#### AWS S3 cache backend

AWS S3 buckets can be used to store build cache layers between builds.

> 📘 Experimental feature
> The S3 cache backend is an [experimental Docker BuildKit feature](https://docs.docker.com/build/cache/backends/s3/). It requires creating a custom buildx builder with a non-default driver (such as `docker-container`), as the default Docker driver does not support AWS S3 cache.

```yaml
steps:
  - label: "\:docker\: Build with S3 cache"
    agents:
      queue: elastic
    command: |
      # Create builder with docker-container driver if it doesn't exist
      # This can also be added as a custom `pre-command` hook
      if ! docker buildx ls | grep -q "^my-custom-builder"; then
        docker buildx create --name my-custom-builder --driver=docker-container --use --bootstrap
      else
        docker buildx use my-custom-builder
      fi

      # Build with S3 cache
      docker buildx build \
        --cache-from type=s3,region=us-east-1,bucket=my-buildkit-cache-bucket,name=myapp \
        --cache-to type=s3,region=us-east-1,bucket=my-buildkit-cache-bucket,name=myapp,mode=max \
        --progress=plain \
        .

      # Clean up builder after build
      # This can also be added as a custom `post-command` hook
      docker buildx rm my-custom-builder
```

Ensure your Elastic CI Stack for AWS IAM role has appropriate AWS S3 permissions for the cache bucket. AWS credentials are automatically available to the builder through the instance's IAM role.

## Security considerations

BuildKit builds run with the privileges of the Docker daemon on the EC2 instance. Consider these security practices when using BuildKit on the Elastic CI Stack for AWS.

### Docker user namespace remapping

Enable [Docker user namespace remapping](/docs/agent/v3/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/configuration-parameters) through the `EnableDockerUserNamespaceRemap` parameter in AWS CloudFormation. This maps the containers to the non-root `buildkite-agent` user, reducing the attack surface if a container is compromised.

When user namespace remapping is enabled, Docker containers run as user `100000-165535` (mapped from container UID `0-65535`) on the host, preventing container processes from accessing host resources as root.

### Secret management

Never include secrets directly in Dockerfiles or build arguments, as they may be persisted in image layers or build history. Instead, use BuildKit's `--secret` flag with secrets retrieved from [Buildkite Secrets](/docs/pipelines/security/secrets/buildkite-secrets) or the Buildkite environment.

The Elastic CI Stack for AWS provides isolated Docker configurations per job through the `DOCKER_CONFIG` environment variable, ensuring Docker credentials are not leaked between jobs.

### Build isolation

Each Buildkite job on the Elastic CI Stack for AWS creates its own isolated Docker configuration directory (`$DOCKER_CONFIG`). This isolation prevents credentials and configurations from one job accessing another job's resources, even when multiple jobs run on the same instance.

After each job completes, the isolated Docker configuration is automatically cleaned up.

### Image scanning

Integrate container image scanning into your pipeline to detect vulnerabilities before deployment.

```yaml
steps:
  - label: "\:docker\: Build image"
    agents:
      queue: elastic
    plugins:
      - ecr#v2.11.0:
          login: true
    command: |
      docker buildx build \
        --tag 123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:${BUILDKITE_BUILD_NUMBER} \
        --push \
        --progress=plain \
        .

  - label: "\:shield\: Scan image"
    agents:
      queue: elastic
    plugins:
      - ecr#v2.11.0:
          login: true
    command: |
      # Use AWS ECR image scanning
      aws ecr start-image-scan \
        --repository-name myapp \
        --image-id imageTag=${BUILDKITE_BUILD_NUMBER}

      # Or use third-party scanners like Trivy
      docker run --rm \
        aquasec/trivy:latest image \
        123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:${BUILDKITE_BUILD_NUMBER}
```

## Performance optimization

BuildKit provides several features to improve build performance on the Elastic CI Stack for AWS.

### Enable instance storage

Configure the `EnableInstanceStorage` parameter in AWS CloudFormation to use high-performance NVMe storage for Docker data. This provides significantly faster I/O for image pulls, layer extraction, and build cache operations compared to EBS volumes.

Instance storage is ephemeral and cleared when instances terminate, making it ideal for temporary build artifacts and cache data.

### Optimize Dockerfile layer caching

Structure Dockerfiles to maximize layer cache reuse:

```dockerfile
# syntax=docker/dockerfile:1
FROM node:18-alpine

# Install dependencies first (changes infrequently)
COPY package.json package-lock.json ./
RUN npm ci --production

# Copy application code (changes frequently)
COPY . .

# Build application
RUN npm run build

CMD ["node", "dist/index.js"]
```

This ordering ensures dependency installation layers are cached and reused across builds, with only the application code layers rebuilding when source files change.

### Use build cache effectively

Configure cache backends appropriate for your build frequency:

- _Local cache_: fastest access, suitable for long-running instances or within a single job.
- _S3 cache_: persistent across instance terminations, good for high-frequency builds.
- _Registry cache_: persistent and no additional infrastructure required, leverages existing container registry.

For autoscaling environments where instances terminate frequently, use S3 or registry cache backends to maintain cache between builds. Registry cache performance depends on your registry location and network configuration. When using ECR in the same region as your instances, performance is comparable to S3.

### Parallel multi-stage builds

BuildKit automatically parallelizes independent build stages. Structure Dockerfiles with multiple independent stages to maximize parallelism, for example:

```dockerfile
# syntax=docker/dockerfile:1
FROM node:18 AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

FROM golang:1.23 AS backend-builder
WORKDIR /app/backend
COPY backend/go.mod backend/go.sum ./
RUN go mod download
COPY backend/ ./
RUN go build -o server

FROM alpine:latest
RUN apk add --no-cache ca-certificates
COPY --from=frontend-builder /app/frontend/dist /app/static
COPY --from=backend-builder /app/backend/server /app/server
CMD ["/app/server"]
```

The `frontend-builder` and `backend-builder` stages run in parallel, reducing the total build time.

## Troubleshooting

This section describes common issues with BuildKit on the Elastic CI Stack for AWS and how to resolve them.

### BuildKit not available

If `docker buildx` commands fail with "buildx command not found" message, your instance is running an older AMI version without Buildx pre-installed.
Update to the latest Elastic CI Stack for AWS AMI version to get the Buildx support.

### Out of disk space

BuildKit builds can consume significant disk space for layers and cache. The Elastic CI Stack for AWS automatically monitors disk usage and prunes Docker resources when space is low. When disk space becomes critically low, the stack fails the current job by default.

Additional AWS CloudFormation parameters are available to handle how the Stack instance responds when disk space management issues are encountered:

- `BuildkitePurgeBuildsOnDiskFull` - set to `true` to automatically purge build directories when disk space is critically low (default: `false`).
- `BuildkiteTerminateInstanceOnDiskFull` - set to `true` to terminate the instance when disk space is critically low, allowing autoscaling to provision a fresh instance (default: `false`).

To prevent disk space issues, consider enabling instance storage or increasing the root volume size through the `RootVolumeSize` parameter in AWS CloudFormation.

### Build cache not working

If builds don't reuse cache layers as expected, start by verifying your local/remote cache configuration.

For local cache, ensure the cache directory persists between builds:

```bash
ls -la /tmp/buildkit-cache
```

For remote cache (AWS S3 or registry), verify authentication and network access:

```bash
# Test S3 access
aws s3 ls s3://my-buildkit-cache-bucket/

# Test registry access
docker login 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

### Multi-platform build failures

Multi-platform builds are supported out-of-the-box on Elastic CI Stack for AWS through pre-configured QEMU emulation. If multi-platform builds fail, common causes include:

- _Memory constraints_: cross-architecture emulation requires additional memory. Ensure your instance type has sufficient memory for emulated builds.
- _Build script compatibility_: some build operations may not work correctly under emulation. Test your build scripts with the target architecture.
- _Performance timeouts_: emulated builds are significantly slower than native builds. Consider increasing timeouts or using native architecture agents for production workloads.

To verify the build works for a specific platform without emulation overhead, use separate agent queues with native architecture instances for each target platform.

### Secret mount failures

If secrets are not accessible during builds, verify the secret file exists and has correct permissions:

```bash
ls -la /tmp/npmtoken
```

Ensure the Dockerfile uses correct BuildKit secret syntax:

```dockerfile
# syntax=docker/dockerfile:1
RUN --mount=type=secret,id=npmtoken \
  cat /run/secrets/npmtoken
```

The `# syntax=docker/dockerfile:1` directive at the beginning of the Dockerfile is required for BuildKit features like secrets.
