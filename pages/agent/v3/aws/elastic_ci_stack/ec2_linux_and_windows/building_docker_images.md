---
toc: false
---

# Building Docker images

This guide shows how to build and push a container image to [Amazon Elastic Container Registry (ECR)](https://aws.amazon.com/ecr/) using [Kaniko](https://github.com/chainguard-dev/kaniko) from a [Buildkite Elastic CI Stack for AWS](/docs/agent/v3/aws/elastic_ci_stack) agent.

## 1. One-time ECR setup

```bash
export AWS_REGION={your-region}
export ECR_ACCOUNT_ID={your-account-id}
export ECR_REPO={your-repository-name}

chmod +x scripts/setup-ecr.sh
./scripts/setup-ecr.sh
```

## 2. Configure your Buildkite pipeline environment

Set these environment variables in the [Pipeline Settings](/docs/pipelines/configure/environment_variables) (or keep the defaults in `.buildkite/pipeline.yml`):

- [`AWS_REGION`](/docs/pipelines/configure/environment_variables#aws-region) (for example, `ca-central-1`)
- `ECR_ACCOUNT_ID` (your 12-digit AWS account ID for [Amazon ECR](https://aws.amazon.com/ecr/))
- `ECR_REPO` (your ECR repository name, for example, `example/hello-kaniko`)

## 3. Push using Kaniko

Commit and push. The step in `.buildkite/pipeline.yml` will:

- Generate a Docker config pointing to the [Amazon ECR credential helper](https://github.com/awslabs/amazon-ecr-credential-helper),
- Run the [Chainguard Kaniko](https://github.com/chainguard-dev/kaniko) container to build,
- Push to the Amazon ECR (with optional layer cache at `<repo>-cache`).

> If your Git repository uses SSH, make sure your S3 secrets bucket for Elastic CI Stack for AWS contains a `private_ssh_key` at the correct prefix (or switch to HTTPS + `git-credentials`).

## Running Kaniko in Docker

The Elastic CI Stack for AWS supports running [Kaniko](https://github.com/chainguard-dev/kaniko) for building Docker container images without requiring Docker daemon privileges. This is useful for building images in environments where the "Docker-in-Docker" option is not available or desired.

### Kaniko image availability

Google has deprecated support for the Kaniko project and no longer publishes new images to `gcr.io/kaniko-project/`. However, [Chainguard has forked the project](https://github.com/chainguard-dev/kaniko) and continues to provide support and create new releases.

**Option 1: Use Google's final published images**
You can continue using the last published images from Google:
- `gcr.io/kaniko-project/executor:v1.24.0`
- `gcr.io/kaniko-project/executor:v1.24.0-debug`

**Option 2: Build your own images from the Chainguard fork**
Since Chainguard requires a subscription for their published images, you can build and publish Kaniko images to your own container registry:

```bash
# Build the latest Kaniko image from the Chainguard fork
git clone https://github.com/chainguard-dev/kaniko.git
cd kaniko
docker build -t your-registry/kaniko:latest .
docker push your-registry/kaniko:latest

# Build the debug image
docker build -f debug.Dockerfile -t your-registry/kaniko:debug .
docker push your-registry/kaniko:debug
```

Then update the image references in your pipeline to use your registry.

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
    plugins:
      - ecr#v2.10.0:
          account-ids: "{your-account-id}"
          region: "{your-region}"
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
#!/bin/bash

# ---- Required env from the step ----
AWS_REGION="${AWS_REGION:?missing AWS_REGION}"
ECR_ACCOUNT_ID="${ECR_ACCOUNT_ID:?missing ECR_ACCOUNT_ID}"
ECR_REPO="${ECR_REPO:?missing ECR_REPO}"

# ---- Derived refs ----
ECR_HOST="${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
SHORT_SHA="$(echo "${BUILDKITE_COMMIT:-local}" | cut -c1-12)"
BUILD_NUM="${BUILDKITE_BUILD_NUMBER:-0}"
IMAGE_TAG="${SHORT_SHA}-${BUILD_NUM}"
IMAGE_REPO="${ECR_HOST}/${ECR_REPO}"
IMAGE_URI="${IMAGE_REPO}:${IMAGE_TAG}"

echo "ECR_HOST=${ECR_HOST}"
echo "IMAGE_URI=${IMAGE_URI}"

# ---- Prepare outputs ----
mkdir -p out

# ---- Build & push with Kaniko ----
# Note: ECR authentication is handled by the ecr plugin
docker run --rm \
  -v "$PWD":/workspace \
  -v "$PWD/out":/out \
  -v "$HOME/.docker/config.json:/kaniko/.docker/config.json:ro" \
  gcr.io/kaniko-project/executor:v1.24.0 \
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

# ---- Run the just-built image locally ----
ls -lh out
docker load -i out/image.tar
docker run --rm "${IMAGE_URI}"
```

### Key benefits

- **No Docker daemon required**: Kaniko runs as a container and doesn't need Docker-in-Docker
- **Secure**: No privileged access required for building images
- **Registry agnostic**: Works with any container registry (Docker Hub, ECR, GCR, etc.)
- **Caching support**: Built-in support for registry-based caching to speed up builds
- **Simple authentication**: Uses the [ECR Buildkite plugin](https://github.com/buildkite-plugins/ecr-buildkite-plugin) for automatic credential management
- **Local testing**: Exports built images as tar files for immediate local testing
- **Robust error handling**: Proper validation of required environment variables
- **Smart tagging**: Uses commit SHA and build number for unique image tags

> 📘
> The example on this page uses ECR, but Kaniko works with any container registry. Adjust the authentication and destination URL accordingly for other registries like Docker Hub, GCR, or Azure Container Registry.

### Verifying signed Kaniko images

#### Verifying Google's deprecated images

If you're using Google's final published images (`gcr.io/kaniko-project/executor:v1.24.0`), you can verify their signatures:

```bash
# Verify the Google Kaniko image signature with cosign (public key)
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

This verification uses Google's official public key and only applies to their deprecated images.

#### Signing and verifying custom-built images

If you build your own Kaniko images from the Chainguard fork, you can sign them for enhanced security. This process involves generating a key pair, signing your images, and verifying them before use.

**1. Generate a key pair and store in Buildkite Secrets:**

```bash
# Generate signing key pair
cosign generate-key-pair

# Store the private key in Buildkite Secrets
buildkite-agent secret set "kaniko-signing-private-key" < cosign.key

# Store the public key in Buildkite Secrets  
buildkite-agent secret set "kaniko-signing-public-key" < cosign.pub
```

**2. Sign your custom image after building:**

```bash
# Pull the private key from Buildkite Secrets
buildkite-agent secret get "kaniko-signing-private-key" > cosign.key

# Sign your custom image and push signature to registry
docker run --rm -v "$PWD:/work" -w /work cgr.dev/chainguard/cosign \
  sign -key cosign.key your-registry/kaniko:latest
```

**3. Verify your custom image before use:**

```bash
# Pull the public key from Buildkite Secrets
buildkite-agent secret get "kaniko-signing-public-key" > cosign.pub

# Verify your custom image
docker run --rm -v "$PWD:/work" -w /work cgr.dev/chainguard/cosign \
  verify -key cosign.pub your-registry/kaniko:latest
```

**Alternative: Keyless signing with OIDC**

For a more modern approach, you can use keyless signing with OIDC (OpenID Connect) instead of managing key pairs:

```bash
# Keyless signing (requires OIDC authentication)
docker run --rm -v "$PWD:/work" -w /work cgr.dev/chainguard/cosign \
  sign your-registry/kaniko:latest

# Keyless verification (requires certificate identity and issuer)
docker run --rm -v "$PWD:/work" -w /work cgr.dev/chainguard/cosign \
  verify \
  --certificate-identity="your-email@example.com" \
  --certificate-oidc-issuer="https://accounts.google.com" \
  your-registry/kaniko:latest
```

This approach ensures your custom-built Kaniko images are authentic and haven't been tampered with. For more details on Cosign signing and verification, see the [Chainguard Cosign documentation](https://edu.chainguard.dev/open-source/sigstore/cosign/how-to-sign-a-container-with-cosign/).

### Debugging with Kaniko debug image

When troubleshooting build issues, you can use the [Kaniko debug image](https://github.com/chainguard-dev/kaniko#debug-image) which includes additional debugging tools. The debug image contains utilities like `busybox` and `sh` for interactive debugging.

For interactive debugging, you can run the debug image directly:

```bash
docker run -it --entrypoint=/busybox/sh gcr.io/kaniko-project/executor:v1.24.0-debug
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

- **Interactive shell access**: Set `KANIKO_SHELL=1` to get an interactive shell inside the Kaniko container
- **Verbose logging**: Use `KANIKO_VERBOSITY=debug` for detailed build logs
- **No-push mode**: Set `KANIKO_NO_PUSH=1` to build without pushing to registry

The debug image is particularly useful for:

- Investigating build failures
- Examining the build context and Dockerfile
- Testing different Kaniko parameters
- Debugging authentication issues
