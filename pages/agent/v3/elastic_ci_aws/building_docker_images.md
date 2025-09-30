---
toc_include_h3: false
---

# Building Docker Images

This guide shows how to build & push a container image to **Amazon ECR** using **Kaniko** from a **Buildkite Elastic CI Stack for AWS** agent.

## 1. One-time ECR setup

```bash
export AWS_REGION=ca-central-1
export ECR_ACCOUNT_ID=123456789012     # CHANGE ME
export ECR_REPO=example/hello-kaniko    # CHANGE ME

chmod +x scripts/setup-ecr.sh
./scripts/setup-ecr.sh
```

## 2. Configure your Buildkite pipeline env

Set these env vars in the pipeline settings (or keep defaults in `.buildkite/pipeline.yml`):
- `AWS_REGION` (for example, `ca-central-1`)
- `ECR_ACCOUNT_ID` (your 12-digit account)
- `ECR_REPO` (your repository name, for example, `example/hello-kaniko`)

## 3. Push using Kaniko

Commit and push. The step in `.buildkite/pipeline.yml` will:
- generate a Docker config pointing to the **ECR credential helper**,
- run the **Chainguard Kaniko** container to build,
- push to ECR (with optional layer cache at `<repo>-cache`).

> If your Git repository uses **SSH**, make sure your Elastic CI Stack for AWS **S3 secrets** bucket contains a `private_ssh_key` at the correct prefix (or switch to HTTPS + `git-credentials`).

## Running Kaniko in Docker

The Elastic CI Stack for AWS supports running [Kaniko](https://github.com/GoogleContainerTools/kaniko) for building container images without requiring Docker daemon privileges. This is useful for building images in environments where Docker-in-Docker is not available or desired.

Kaniko executes your Dockerfile inside a container and pushes the resulting image to a registry. It doesn't depend on a Docker daemon and executes each command in the Dockerfile completely in user space, making it more secure and suitable for environments where privileged access is not available.

### Example pipeline

Here's a complete example of using Kaniko to build and push a container image:

```yaml
steps:
  - label: ":whale: Kaniko"
    env:
      AWS_REGION: "us-east-1"          # your region
      ECR_ACCOUNT_ID: "111122223333"   # your account
      ECR_REPO: "hello-kaniko"         # repo NAME only
    commands:
      - bash .buildkite/steps/kaniko.sh
```
{: codeblock-file="pipeline.yml"}

```dockerfile
FROM public.ecr.aws/docker/library/node:20-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev || npm i --omit=dev
COPY app.js ./
CMD ["node","app.js"]
```
{: codeblock-file="dockerfile"}

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
{: codeblock-file="package.json"}

```javascript
// app.js
console.log("Hello from Kaniko on Buildkite Elastic CI Stack for AWS!");
```
{: codeblock-file="app.js"}

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

# ---- Build & push with Kaniko, AND write a tar we can run locally ----
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
{: codeblock-file=" Buildkite Step Script ".buildkite/steps/kaniko.sh""}

### Key benefits

- **No Docker daemon required**: Kaniko runs as a container and doesn't need Docker-in-Docker
- **Secure**: No privileged access required for building images
- **Registry agnostic**: Works with any container registry (Docker Hub, ECR, GCR, etc.)
- **Caching support**: Built-in support for registry-based caching to speed up builds
- **Flexible authentication**: Supports Docker config and credential helpers
- **Local testing**: Exports built images as tar files for immediate local testing
- **Robust error handling**: Proper validation of required environment variables
- **Smart tagging**: Uses commit SHA and build number for unique image tags

**Note**: This example uses ECR, but Kaniko works with any container registry. Adjust the authentication and destination URL accordingly for other registries like Docker Hub, GCR, or Azure Container Registry.

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
- Uses the official Kaniko public key from their [GitHub repository](https://github.com/GoogleContainerTools/kaniko#verifying-signed-kaniko-images)
- Ensures the Kaniko image hasn't been tampered with
- Runs before your build process to catch any security issues early

For alternative verification methods (like keyless verification with Chainguard images), see the [Kaniko documentation](https://github.com/GoogleContainerTools/kaniko#verifying-signed-kaniko-images).

### Debugging with Kaniko debug image

When troubleshooting build issues, you can use the Kaniko debug image which includes additional debugging tools. The debug image contains utilities like `busybox` and `sh` for interactive debugging.

To enable debug mode, set the `KANIKO_DEBUG` environment variable in your pipeline:

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

Example debug script configuration:

```bash
# Enable debug mode
KANIKO_DEBUG=1
KANIKO_VERBOSITY=debug
# Optional: Interactive shell for troubleshooting
KANIKO_SHELL=1
# Optional: Build without pushing
KANIKO_NO_PUSH=1
```

The debug image is particularly useful for:
- Investigating build failures
- Examining the build context and Dockerfile
- Testing different Kaniko parameters
- Debugging authentication issues

For more information about the debug image capabilities, see the [Chainguard Kaniko documentation](https://github.com/chainguard-dev/kaniko?tab=readme-ov-file#debug-image).
