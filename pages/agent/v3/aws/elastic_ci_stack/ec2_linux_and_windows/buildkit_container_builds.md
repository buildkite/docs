# BuildKit container builds

[BuildKit](https://docs.docker.com/build/buildkit/) is Docker's next-generation build system that provides advanced features including improved performance, better caching, parallel build execution, and efficient layer management. BuildKit is available through Docker BuildX, which comes pre-installed on all Elastic CI Stack for AWS Linux instances.

## BuildKit on Elastic CI Stack for AWS

The Elastic CI Stack for AWS includes Docker BuildX (BuildKit) pre-installed on all Linux instances, providing a modern container build experience without additional setup. BuildKit runs as part of the Docker daemon on EC2 instances, offering improved build performance and advanced features compared to the legacy Docker builder.

## Using BuildKit with Elastic CI Stack for AWS

BuildKit is available through the `docker buildx build` command, which provides the same interface as `docker build` while leveraging BuildKit's advanced features. The Elastic CI Stack for AWS supports multiple build configurations to match your security and performance requirements.

### Basic BuildKit build

You can use BuildKit through Docker BuildX with default settings. This approach works immediately without any special configuration.

```yaml
steps:
  - label: ":docker: BuildKit container build"
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

```yaml
steps:
  - label: ":docker: BuildKit build with cache"
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

### BuildKit with instance storage

When [instance storage is enabled](/docs/agent/v3/aws/elastic_ci_stack/ec2_linux_and_windows/configuration/docker_configuration#using-instance-storage-for-docker-data) through the `EnableInstanceStorage` CloudFormation parameter, Docker stores images and build cache on high-performance NVMe storage at `/mnt/ephemeral/docker`. This significantly improves build performance for I/O-intensive operations.

No configuration changes are required in your pipeline YAML—BuildKit automatically uses the configured Docker data directory.

### BuildKit with multi-platform builds

The Elastic CI Stack for AWS supports building container images for multiple architectures through QEMU emulation (using `binfmt_misc`). This allows building ARM64 images on x86 instances and vice versa.

```yaml
steps:
  - label: ":docker: Multi-platform build"
    agents:
      queue: elastic
    command: |
      docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --progress=plain \
        --file Dockerfile \
        .
```

For production multi-platform builds, consider using separate agents with native architecture support to avoid emulation overhead.

## Building and pushing to Amazon ECR

The Elastic CI Stack for AWS includes the [ECR plugin](/docs/agent/v3/aws/elastic_ci_stack/ec2_linux_and_windows/plugins/ecr) for seamless Amazon ECR authentication. The plugin automatically authenticates with ECR before your build runs, allowing you to push images directly.

### Basic ECR push

```yaml
steps:
  - label: ":docker: Build and push to ECR"
    agents:
      queue: elastic
    plugins:
      - ecr#v2.9.1:
          login: true
    command: |
      export IMAGE_TAG="$BUILDKITE_BUILD_NUMBER"
      docker buildx build \
        --tag 123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:${IMAGE_TAG} \
        --tag 123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:latest \
        --push \
        --progress=plain \
        .
```

### ECR push with build arguments

Pass build arguments to customize your build based on Buildkite metadata or environment variables.

```yaml
steps:
  - label: ":docker: Build with args and push to ECR"
    agents:
      queue: elastic
    plugins:
      - ecr#v2.9.1:
          login: true
    command: |
      export IMAGE_TAG="$BUILDKITE_BUILD_NUMBER"
      docker buildx build \
        --build-arg NODE_ENV=production \
        --build-arg VERSION=${IMAGE_TAG} \
        --build-arg BUILD_URL=$BUILDKITE_BUILD_URL \
        --tag 123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:${IMAGE_TAG} \
        --push \
        --progress=plain \
        .
```

### Cross-account ECR push

For pushing to ECR repositories in different AWS accounts, use the ECR plugin's role assumption feature.

```yaml
steps:
  - label: ":docker: Build and push to cross-account ECR"
    agents:
      queue: elastic
    plugins:
      - ecr#v2.9.1:
          login: true
          account-ids: "999888777666"
          region: us-west-2
          assume_role:
            role_arn: "arn:aws:iam::999888777666:role/BuildkiteECRAccess"
    command: |
      export IMAGE_TAG="$BUILDKITE_BUILD_NUMBER"
      docker buildx build \
        --tag 999888777666.dkr.ecr.us-west-2.amazonaws.com/myapp:${IMAGE_TAG} \
        --push \
        --progress=plain \
        .
```

## Customizing builds

BuildKit provides extensive customization options through the `docker buildx build` command.

### Targeting specific build stages

Multi-stage Dockerfiles can build specific stages using the `--target` flag.

```bash
docker buildx build \
  --target production \
  --tag myapp:production \
  --progress=plain \
  .
```

### Using build secrets

BuildKit supports secure secret injection without leaking secrets into the image layers. Secrets are mounted during the build but never persisted in the final image.

First, update your Dockerfile to use BuildKit secret syntax:

```dockerfile
# syntax=docker/dockerfile:1
FROM alpine

RUN --mount=type=secret,id=npmtoken \
  npm config set //registry.npmjs.org/:_authToken=$(cat /run/secrets/npmtoken)
```

Then pass the secret during the build:

```yaml
steps:
  - label: ":docker: Build with secrets"
    agents:
      queue: elastic
    plugins:
      - ecr#v2.9.1:
          login: true
    command: |
      # Retrieve secret from environment or secrets manager
      echo "$NPM_TOKEN" > /tmp/npmtoken

      docker buildx build \
        --secret id=npmtoken,src=/tmp/npmtoken \
        --tag 123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:latest \
        --push \
        --progress=plain \
        .

      # Clean up secret file
      rm /tmp/npmtoken
```

For production use, integrate with the [AWS Secrets Manager plugin](/docs/agent/v3/aws/elastic_ci_stack/ec2_linux_and_windows/plugins/secrets) to securely retrieve secrets.

### Exporting build artifacts

BuildKit can export build outputs beyond container images, such as compiled binaries or build artifacts.

```yaml
steps:
  - label: ":docker: Export build artifacts"
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

This exports the contents of the `builder` stage to the local `./dist` directory, which can then be uploaded as Buildkite artifacts.

### Using remote cache backends

For distributed teams or frequently terminated EC2 instances, remote cache backends provide persistent cache storage across builds.

#### S3 cache backend

```yaml
steps:
  - label: ":docker: Build with S3 cache"
    agents:
      queue: elastic
    command: |
      export S3_CACHE="s3://my-buildkit-cache-bucket/myapp"

      docker buildx build \
        --cache-from type=s3,region=us-east-1,bucket=my-buildkit-cache-bucket,name=myapp \
        --cache-to type=s3,region=us-east-1,bucket=my-buildkit-cache-bucket,name=myapp,mode=max \
        --progress=plain \
        .
```

Ensure your Elastic CI Stack for AWS IAM role has appropriate S3 permissions for the cache bucket.

#### Registry cache backend

Store build cache layers in a container registry alongside your images.

```yaml
steps:
  - label: ":docker: Build with registry cache"
    agents:
      queue: elastic
    plugins:
      - ecr#v2.9.1:
          login: true
    command: |
      export CACHE_IMAGE="123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp-cache"

      docker buildx build \
        --cache-from type=registry,ref=${CACHE_IMAGE}:latest \
        --cache-to type=registry,ref=${CACHE_IMAGE}:latest,mode=max \
        --tag 123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:latest \
        --push \
        --progress=plain \
        .
```

## Security considerations

BuildKit builds run with the privileges of the Docker daemon on the EC2 instance. Consider these security practices when using BuildKit on the Elastic CI Stack for AWS.

### Docker user namespace remapping

Enable [Docker user namespace remapping](/docs/agent/v3/aws/elastic_ci_stack/ec2_linux_and_windows/configuration/docker_configuration#enabling-docker-user-namespace-remapping) through the `EnableDockerUserNamespaceRemap` CloudFormation parameter. This maps containers to the non-root `buildkite-agent` user, reducing the attack surface if a container is compromised.

When user namespace remapping is enabled, Docker containers run as user `100000-165535` (mapped from container UID 0-65535) on the host, preventing container processes from accessing host resources as root.

### Secret management

Never include secrets directly in Dockerfiles or build arguments, as they may be persisted in image layers or build history. Instead, use BuildKit's `--secret` flag with secrets retrieved from AWS Secrets Manager or the Buildkite environment.

The Elastic CI Stack for AWS provides isolated Docker configurations per job through the `DOCKER_CONFIG` environment variable, ensuring Docker credentials are not leaked between jobs.

### Build isolation

Each Buildkite job on the Elastic CI Stack for AWS runs with its own isolated Docker configuration directory (`$DOCKER_CONFIG`). This isolation prevents credentials and configurations from one job accessing another job's resources, even when multiple jobs run on the same instance.

After each job completes, the isolated Docker configuration is automatically cleaned up.

### Network security

BuildKit builds can make network requests during the build process. Use [Docker network configuration](/docs/agent/v3/aws/elastic_ci_stack/ec2_linux_and_windows/configuration/docker_configuration#configuring-docker-networking) to control network access:

- Configure custom Docker network pools to avoid IP conflicts
- Use AWS security groups to restrict outbound network access from EC2 instances
- Consider using VPC endpoints for AWS service access to avoid internet routing

### Image scanning

Integrate container image scanning into your pipeline to detect vulnerabilities before deployment.

```yaml
steps:
  - label: ":docker: Build image"
    agents:
      queue: elastic
    plugins:
      - ecr#v2.9.1:
          login: true
    command: |
      export IMAGE_TAG="$BUILDKITE_BUILD_NUMBER"
      docker buildx build \
        --tag 123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:${IMAGE_TAG} \
        --push \
        --progress=plain \
        .

  - label: ":shield: Scan image"
    agents:
      queue: elastic
    plugins:
      - ecr#v2.9.1:
          login: true
    command: |
      export IMAGE_TAG="$BUILDKITE_BUILD_NUMBER"
      # Use AWS ECR image scanning
      aws ecr start-image-scan \
        --repository-name myapp \
        --image-id imageTag=${IMAGE_TAG}

      # Or use third-party scanners like Trivy
      docker run --rm \
        aquasec/trivy:latest image \
        123456789012.dkr.ecr.us-east-1.amazonaws.com/myapp:${IMAGE_TAG}
```

## Performance optimization

BuildKit provides several features to improve build performance on the Elastic CI Stack for AWS.

### Enable instance storage

Configure the `EnableInstanceStorage` CloudFormation parameter to use high-performance NVMe storage for Docker data. This provides significantly faster I/O for image pulls, layer extraction, and build cache operations compared to EBS volumes.

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

Configure cache backends appropriate to your build frequency:

- _Local cache_: fastest access, suitable for long-running instances
- _S3 cache_: persistent across instance terminations, moderate access speed
- _Registry cache_: persistent and no additional S3 bucket required, but slower than S3

For autoscaling environments where instances frequently terminate, use S3 or registry cache backends to maintain cache between builds.

### Parallel multi-stage builds

BuildKit automatically parallelizes independent build stages. Structure Dockerfiles with multiple independent stages to maximize parallelism:

```dockerfile
# syntax=docker/dockerfile:1
FROM node:18 AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

FROM golang:1.21 AS backend-builder
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

The `frontend-builder` and `backend-builder` stages run in parallel, reducing total build time.

## Troubleshooting

This section describes common issues with BuildKit on the Elastic CI Stack for AWS and how to resolve them.

### BuildKit not available

If `docker buildx` commands fail with "buildx command not found", verify the instance is running a recent AMI version with BuildX pre-installed.

Check BuildX installation:

```bash
docker buildx version
```

For older AMIs, manually install BuildX following the [Docker BuildX installation documentation](https://docs.docker.com/build/install-buildx/).

### Permission denied errors

Permission errors during builds typically indicate Docker daemon connectivity issues or file permission problems.

Check Docker daemon status:

```bash
sudo systemctl status docker
```

Verify the `buildkite-agent` user is in the `docker` group:

```bash
groups buildkite-agent
```

For user namespace remapping issues, review the configuration in `/etc/docker/daemon.json` and verify `/etc/subuid` and `/etc/subgid` are correctly configured.

### Out of disk space

BuildKit builds can consume significant disk space for layers and cache. The Elastic CI Stack for AWS automatically monitors disk usage and prunes Docker resources when space is low.

Check available disk space:

```bash
df -h /var/lib/docker
# or for instance storage
df -h /mnt/ephemeral/docker
```

Manually prune Docker resources if needed:

```bash
docker system prune --all --volumes --force
docker builder prune --all --force
```

Consider enabling instance storage or increasing the root volume size through the `RootVolumeSize` CloudFormation parameter.

### Build cache not working

If builds don't reuse cache layers as expected, verify cache configuration:

For local cache, ensure the cache directory persists between builds:

```bash
ls -la /tmp/buildkit-cache
```

For remote cache (S3 or registry), verify authentication and network access:

```bash
# Test S3 access
aws s3 ls s3://my-buildkit-cache-bucket/

# Test registry access
docker login 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

Enable verbose output to debug cache behavior:

```bash
docker buildx build \
  --progress=plain \
  --cache-from type=registry,ref=myapp:cache \
  --cache-to type=registry,ref=myapp:cache,mode=max \
  . 2>&1 | tee build.log
```

### Multi-platform build failures

Multi-platform builds using QEMU emulation can fail if the `binfmt_misc` handlers are not properly configured.

Verify QEMU registration:

```bash
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

For production multi-platform builds, use native architecture agents rather than emulation to avoid performance and compatibility issues.

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

### Debugging builds

Increase BuildKit output verbosity for debugging:

```bash
docker buildx build \
  --progress=plain \
  --no-cache \
  . 2>&1 | tee build.log
```

The `--no-cache` flag forces rebuilding all layers, useful for diagnosing cache-related issues.

For even more detailed output, enable Docker daemon debug logging by setting `"debug": true` in `/etc/docker/daemon.json` (requires sudo access and daemon restart).
