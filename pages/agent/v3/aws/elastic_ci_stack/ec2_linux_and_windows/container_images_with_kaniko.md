---
toc_include_h3: false
---

# Building container images using Kaniko

This guide explains how to build and push a container image to [Amazon Elastic Container Registry (ECR)](https://aws.amazon.com/ecr/) using [Kaniko](https://github.com/chainguard-dev/kaniko) from a [Buildkite Elastic CI Stack for AWS](/docs/agent/v3/aws/elastic-ci-stack) agent.

## 1. One-time ECR setup

Run this script to create your ECR repository and configure the necessary AWS permissions for Kaniko to push images.

```bash
export AWS_REGION={your-region}
export ECR_ACCOUNT_ID={your-account-id}
export ECR_REPO={your-repository-name}

chmod +x scripts/setup-ecr.sh
./scripts/setup-ecr.sh
```

## 2. Configure your Buildkite pipeline environment

Set the following environment variables in the [Pipeline Settings](/docs/pipelines/configure/environment-variables) (or keep the defaults in `.buildkite/pipeline.yml`):

- `AWS_REGION` (for example, `ca-central-1`)
- `ECR_ACCOUNT_ID` (your 12-digit AWS account ID for [Amazon ECR](https://aws.amazon.com/ecr/))
- `ECR_REPO` (your ECR repository name, for example, `example/hello-kaniko`)

## 3. Push using Kaniko

Commit your changes (including the `.buildkite/pipeline.yml` file and your Dockerfile) and push them to your repository. The step in `.buildkite/pipeline.yml` will:

- Generate a Docker config pointing to the [Amazon ECR credential helper](https://github.com/awslabs/amazon-ecr-credential-helper),
- Run the [Chainguard Kaniko](https://github.com/chainguard-dev/kaniko) container to build your Docker image,
- Push to the Amazon ECR (with optional layer cache at `<repo>-cache`).

> 📘
> If your Git repository uses SSH, make sure your [S3 secrets bucket for Elastic CI Stack for AWS](/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/secrets-bucket) contains a `private_ssh_key` at the correct prefix (otherwise, use HTTPS + `git-credentials` for managing authentication).

## Running Kaniko in Docker

The Elastic CI Stack for AWS supports running [Kaniko](https://github.com/GoogleContainerTools/kaniko) for building Docker container images without requiring Docker daemon privileges. This is useful for building images in environments where the [Docker-in-Docker (DIND)](https://www.docker.com/resources/docker-in-docker-containerized-ci-workflows-dockercon-2023/) option is not available or desired.

Kaniko executes your Dockerfile inside a container and pushes the resulting image to a registry. It doesn't depend on a Docker daemon and runs without requiring elevated privileges, making it more secure and suitable for environments where privileged access is not available.

### Example pipeline

Here's a complete example of using Kaniko to build and push a container image to ECR:

**pipeline.yml:**

```yaml
steps:
  - label: ":whale: Kaniko"
    env:
      AWS_REGION: "{your-region}"
      ECR_ACCOUNT_ID: "{your-account-id}"
      ECR_REPO: "{your-repository-name}"
    commands:
      - bash .buildkite/steps/kaniko.sh
```

**Dockerfile:**

```dockerfile
FROM public.ecr.aws/docker/library/node:20-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev || npm i --omit=dev
COPY app.js ./
CMD ["node","app.js"]
```

**package.json:**

```json
{
  "name": "hello-kaniko",
  "version": "1.0.0",
  "private": true,
  "license": "MIT",
  "description": "Hello world app to demo Kaniko on Buildkite Elastic CI Stack for AWS",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  }
}
```

**app.js:**

```javascript
// app.js
console.log("Hello from Kaniko on Buildkite Elastic CI Stack for AWS!");
```

**Buildkite Step Script (.buildkite/steps/kaniko.sh):**

```bash
# ---- Required env from the step ----
AWS_REGION="${AWS_REGION:?missing AWS_REGION}"
ECR_ACCOUNT_ID="${ECR_ACCOUNT_ID:?missing ECR_ACCOUNT_ID}"
ECR_REPO="${ECR_REPO:?missing ECR_REPO}"

# ---- Derived refs (no ${...} in YAML; we're in bash now) ----
ECR_HOST="${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
SHORT_SHA="$(echo "${BUILDKITE_COMMIT:-local}" | cut -c1-12)"
BUILD_NUM="${BUILDKITE_BUILD_NUMBER:-0}"
IMAGE_TAG="${SHORT_SHA}-${BUILD_NUM}"
IMAGE_REPO="${ECR_HOST}/${ECR_REPO}"
IMAGE_URI="${IMAGE_REPO}:${IMAGE_TAG}"

echo "ECR_HOST=${ECR_HOST}"
echo "IMAGE_URI=${IMAGE_URI}"

# Optional sanity
aws sts get-caller-identity --output text || true

# ---- Prepare outputs & auth mounts ----
mkdir -p out /tmp/kaniko/.docker

AUTH_ARGS=()
if [[ -f "$HOME/.docker/config.json" ]]; then
  echo "Using host Docker auth (~/.docker/config.json) for Kaniko"
  AUTH_ARGS+=(-v "$HOME/.docker/config.json:/kaniko/.docker/config.json:ro")
else
  echo "No host Docker auth found; using ECR credential helper with AWS creds"
  # Tell Kaniko to use ECR helper; give it AWS config so helper can auth using instance role or profile
  printf '{ "credHelpers": { "%s": "ecr-login" } }\n' "$ECR_HOST" > /tmp/kaniko/.docker/config.json
  AUTH_ARGS+=(-v /tmp/kaniko/.docker:/kaniko/.docker:ro -v "$HOME/.aws:/root/.aws:ro" -e AWS_REGION -e AWS_SDK_LOAD_CONFIG=true)
fi

# ---- Build & push with Kaniko, AND write a tar that can be run locally ----
docker run --rm \
  -v "$PWD":/workspace \
  -v "$PWD/out":/out \
  "${AUTH_ARGS[@]}" \
  gcr.io/kaniko-project/executor:v1.23.2 \
  --dockerfile=/workspace/Dockerfile \
  --context=dir:///workspace \
  --destination="${IMAGE_URI}" \
  --cache=true \
  --cache-repo="${IMAGE_REPO}-cache" \
  --tar-path=/out/image.tar \
  --push-retry=3 \
  --verbosity=info \
  --log-timestamp

echo "Pushed ${IMAGE_URI}"

# ---- Run the just-built image
ls -lh out
docker load -i out/image.tar
docker run --rm "${IMAGE_URI}"
```

### Key benefits of using Kaniko

- **No Docker daemon required**: Kaniko runs as a container and doesn't need Docker-in-Docker.
- **Secure**: no privileged access is required for building images.
- **Registry agnostic**: works with any container registry (Docker Hub, ECR, GCR, etc.).
- **Caching support**: built-in support for registry-based caching to speed up builds.
- **Flexible authentication**: supports Docker config and credential helpers.
- **Local testing**: exports built images as `tar` files for immediate local testing.
- **Robust error handling**: proper validation of required environment variables.
- **Smart tagging**: uses commit SHA and build number for unique image tags.

> 📘
> The example on this page uses ECR, but Kaniko can work with any container registry. Adjust the authentication and destination URL accordingly for other registries like Docker Hub, GCR, or Azure Container Registry.

### Verifying signed Kaniko images

For enhanced security, you can verify the signature of the Kaniko image before using it. This ensures you're running the authentic, unmodified Kaniko executor.

Add this verification step to your script before running Kaniko:

```bash
# Verify the Kaniko image signature with cosign (public key)
cat > cosign.pub <<'EOF'
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE9aAfAcgAxIFMTstJUv8l/AMqnSKw
P+vLu3NnnBDHCfREQpV/AJuiZ1UtgGpFpHlJLCNPmFkzQTnfyN5idzNl6Q==
-----END PUBLIC KEY-----
EOF

echo "Verifying signature of ${KANIKO_IMG} ..."
docker run --rm -v "$PWD:/work" -w /work cgr.dev/chainguard/cosign \
  verify -key cosign.pub "${KANIKO_IMG}"
echo "Signature verified OK for ${KANIKO_IMG}"
```

This verification:

- Uses the official Kaniko public key from the [Kaniko GitHub repository](https://github.com/GoogleContainerTools/kaniko#verifying-signed-kaniko-images),
- Ensures the Kaniko image hasn't been tampered with,
- Runs before your build process to catch any security issues early.

For alternative verification methods (like keyless verification with Chainguard images), see the Kaniko documentation on [verifying signed Kaniko images](https://github.com/GoogleContainerTools/kaniko#verifying-signed-kaniko-images).

### Debugging with Kaniko debug image

When troubleshooting build issues, you can use the [Kaniko debug image](https://github.com/GoogleContainerTools/kaniko#debug-image) which includes additional debugging tools. The debug image contains utilities like `busybox` and `sh` for interactive debugging.

For interactive debugging, you can run the debug image directly:

```bash
docker run -it --entrypoint=/busybox/sh gcr.io/kaniko-project/executor:debug
```

To enable debug mode in your pipeline, set the `KANIKO_DEBUG` environment variable:

```yaml
steps:
  - label: ":whale: Kaniko Debug"
    env:
      AWS_REGION: "us-east-1"
      ECR_ACCOUNT_ID: "111122223333"
      ECR_REPO: "hello-kaniko"
      KANIKO_DEBUG: "1"  # Enable debug image
    commands:
      - bash .buildkite/steps/kaniko.sh
```

The debug image provides several debugging options:

- **Interactive shell access**: set `KANIKO_SHELL=1` to get an interactive shell inside the Kaniko container.
- **Verbose logging**: use `KANIKO_VERBOSITY=debug` for detailed build logs.
- **No-push mode**: set `KANIKO_NO_PUSH=1` to build without pushing to registry.

The debug image is particularly useful for:

- Investigating build failures,
- Examining the build context and Dockerfile,
- Testing different Kaniko parameters,
- Debugging authentication issues.
