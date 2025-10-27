---
toc_include_h3: false
---

# Building Docker images

[Kaniko](https://github.com/GoogleContainerTools/kaniko) builds container images from a Dockerfile without requiring a Docker daemon, making it ideal for CI/CD environments that lack or don't need privileged access. This guide shows you how to use Kaniko on [Buildkite Elastic CI Stack for AWS](/docs/agent/v3/aws/elastic_ci_stack) to build and push images directly to [Buildkite Package Registries](/docs/package_registries).

Unlike traditional Docker builds, Kaniko runs as a container itself and executes each command in your Dockerfile in userspace. This approach eliminates the need for Docker-in-Docker or privileged mode while maintaining full compatibility with standard Dockerfiles. You can authenticate using short-lived OIDC tokens, leverage registry-based caching to speed up builds, and push to any OCI-compliant container registry.

> 📘 Note about Kaniko support
> Google has deprecated support for the Kaniko project and no longer publishes new images to `gcr.io/kaniko-project/`. However, [Chainguard has forked the project](https://github.com/chainguard-dev/kaniko) and continues to provide support and create new releases. See the [Kaniko image availability](#running-kaniko-in-docker-kaniko-image-availability) section below for your options.

## One-time package registry setup

Create a Package Registry for container images through the Buildkite web interface:

1. Navigate to your Buildkite organization and select **Package Registries** from the global navigation.
2. Click **New registry**.
3. Provide a name (for example, `my-container-registry`) and optional description.
4. Select **OCI Image (Docker)** as the ecosystem type.
5. Assign appropriate team access permissions (select teams that need access to the registry).
6. Click **Create Registry**.

For detailed instructions, see [Manage registries](/docs/package_registries/registries/manage).

> 📘 Registry compatibility
> While this example uses Buildkite Package Registries, Kaniko works with any OCI-compliant container registry. To use a different registry like Docker Hub, ECR, GCR, or Azure Container Registry, adjust the authentication method and destination URL accordingly.

## Push using Kaniko

Commit your changes. The step in `.buildkite/pipeline.yml` will:

- Build the Docker image using [Kaniko](https://github.com/GoogleContainerTools/kaniko) (no Docker daemon required)
- Push the image directly to [Buildkite Package Registries](/docs/package_registries) using a short-lived OIDC token retrieved by the Buildkite agent

> 📘 SSH repository requirements
> If your Git repository uses SSH, make sure your S3 secrets bucket for Elastic CI Stack for AWS contains a `private_ssh_key` at the correct prefix (or switch to HTTPS + `git-credentials`).

## Running Kaniko in Docker

Kaniko runs inside a Docker container on the Elastic CI Stack for AWS agent—no Docker-in-Docker or privileged mode and no Docker daemon for the build.

### Kaniko image availability

Google has deprecated support for the Kaniko project and no longer publishes new images to `gcr.io/kaniko-project/`. However, [Chainguard has forked the project](https://github.com/chainguard-dev/kaniko) and continues to provide support and create new releases.

#### Option 1: use Google's final published images (recommended)

You can use Google's final published Kaniko images (these are publicly available):
- `gcr.io/kaniko-project/executor:v1.24.0`
- `gcr.io/kaniko-project/executor:v1.24.0-debug`

#### Option 2: use Chainguard-maintained images

Chainguard images may require authentication depending on availability, policy, and version:
- `cgr.dev/chainguard/kaniko:latest`
- `cgr.dev/chainguard/kaniko:latest-debug`

> 📘 Image directory reference
> See their [image directory](https://images.chainguard.dev/directory/image/kaniko/versions) for versions and access details.

#### Option 3: build your own images from the Chainguard fork

If you need a specific version or custom configuration, you can build and publish Kaniko images to your own container registry:

```bash
# Build the latest Kaniko image from the Chainguard fork
git clone https://github.com/chainguard-dev/kaniko.git
cd kaniko
docker build --target kaniko-executor -t your-registry/kaniko:latest --file deploy/Dockerfile .
docker push your-registry/kaniko:latest

# Build the debug image
docker build --target kaniko-debug -t your-registry/kaniko:debug --file deploy/Dockerfile .
docker push your-registry/kaniko:debug
```

Then update the image references in your pipeline to use your registry.

Kaniko executes your Dockerfile inside a container and pushes the resulting image to a registry. It doesn't depend on a Docker daemon and runs without elevated privileges, making it more secure and suitable for environments where privileged access is not available.

### Example pipeline

Here's a complete example of using Kaniko to build and push a container image to Buildkite Package Registries:

```text
project-root/
├── .buildkite/
│   ├── pipeline.yml
│   └── steps/
│       └── kaniko.sh
├── Dockerfile
├── package.json
└── app.js
```

```yaml
steps:
  - label: ":whale: Build and Push with Kaniko"
    env:
      PACKAGE_REGISTRY_NAME: "my-container-registry"
    commands:
      - bash .buildkite/steps/kaniko.sh
```
{: codeblock-file=".buildkite/pipeline.yml"}

```bash
#!/bin/bash
set -euo pipefail

TAG="$(echo "${BUILDKITE_COMMIT:-local}" | cut -c1-12)-${BUILDKITE_BUILD_NUMBER:-0}"
IMG="packages.buildkite.com/${BUILDKITE_ORGANIZATION_SLUG}/${PACKAGE_REGISTRY_NAME}/hello-kaniko:${TAG}"

# Use debug image if KANIKO_DEBUG is set
if [ "${KANIKO_DEBUG:-}" = "1" ]; then
  KANIKO="${KANIKO_IMAGE:-gcr.io/kaniko-project/executor:v1.24.0-debug}"
else
  KANIKO="${KANIKO_IMAGE:-gcr.io/kaniko-project/executor:v1.24.0}"
fi

ORG="${BUILDKITE_ORGANIZATION_SLUG}"
REG="${PACKAGE_REGISTRY_NAME}"
REG_URL="packages.buildkite.com/${ORG}/${REG}"

echo "~~~ Configure OIDC token"

# 1) Request a short-lived OIDC token (aud must be the registry URL)
OIDC_TOKEN="$(buildkite-agent oidc request-token \
  --audience "https://packages.buildkite.com/${ORG}/${REG}" \
  --lifetime 300)"

# 2) Write Kaniko's Docker config with the OIDC token
#    Username must be "buildkite" for OIDC auth.
cat > config.json <<JSON
{
  "auths": {
    "${REG_URL}": {
      "username": "buildkite",
      "password": "${OIDC_TOKEN}"
    }
  }
}
JSON

echo "~~~ Building image using kaniko: ${IMG}"

# 3) Run Kaniko and push directly
docker run --rm \
  -v "$PWD":/workspace \
  -v "$PWD/config.json":/kaniko/.docker/config.json:ro \
  "${KANIKO}" \
  --dockerfile=/workspace/Dockerfile.kaniko-example \
  --context=dir:///workspace \
  --destination="${IMG}" \
  --verbosity=info \
  --log-timestamp \
  --cache=true \
  --cache-repo="packages.buildkite.com/${ORG}/${REG}/hello-kaniko-cache"

# 4) Pull and run image built by Kaniko using the same OIDC token
echo "~~~ :docker: Pulling image: ${IMG}"
DOCKER_CONFIG="$PWD" docker pull "${IMG}"
echo "~~~ :docker: Running image: ${IMG}"
DOCKER_CONFIG="$PWD" docker run --rm "${IMG}"
set -euo pipefail

TAG="$(echo "${BUILDKITE_COMMIT:-local}" | cut -c1-12)-${BUILDKITE_BUILD_NUMBER:-0}"
IMG="packages.buildkite.com/${BUILDKITE_ORGANIZATION_SLUG}/${PACKAGE_REGISTRY_NAME}/hello-kaniko:${TAG}"

# Use debug image if KANIKO_DEBUG is set
if [ "${KANIKO_DEBUG:-}" = "1" ]; then
  KANIKO="${KANIKO_IMAGE:-gcr.io/kaniko-project/executor:v1.24.0-debug}"
else
  KANIKO="${KANIKO_IMAGE:-gcr.io/kaniko-project/executor:v1.24.0}"
fi

ORG="${BUILDKITE_ORGANIZATION_SLUG}"
REG="${PACKAGE_REGISTRY_NAME}"
REG_URL="packages.buildkite.com/${ORG}/${REG}"

echo "Building image: ${IMG}"

# 1) Request a short-lived OIDC token (aud must be the registry URL)
OIDC_TOKEN="$(buildkite-agent oidc request-token \
  --audience "https://packages.buildkite.com/${ORG}/${REG}" \
  --lifetime 300)"

# 2) Write Kaniko's Docker config with the OIDC token
#    Username must be "buildkite" for OIDC auth.
cat > docker-config.json <<JSON
{
  "auths": {
    "${REG_URL}": {
      "username": "buildkite",
      "password": "${OIDC_TOKEN}"
    }
  }
}
JSON

# 3) Run Kaniko and push directly
docker run --rm \
  -v "$PWD":/workspace \
  -v "$PWD/docker-config.json":/kaniko/.docker/config.json:ro \
  "${KANIKO}" \
  --dockerfile=/workspace/Dockerfile \
  --context=dir:///workspace \
  --destination="${IMG}" \
  --verbosity=info --log-timestamp \
  --cache=true \
  --cache-repo="packages.buildkite.com/${ORG}/${REG}/hello-kaniko-cache"

echo "Pushed ${IMG}"

# ---- Pull & run using the same OIDC auth ----
DOCKER_CONFIG="$PWD" docker pull "${IMG}"
DOCKER_CONFIG="$PWD" docker run --rm "${IMG}"
```
{: codeblock-file=".buildkite/steps/kaniko.sh"}

```dockerfile
FROM public.ecr.aws/docker/library/node:20-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev || npm i --omit=dev
COPY app.js ./
CMD ["node","app.js"]
```
{: codeblock-file="Dockerfile"}

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

> 📘 Docker login not required
> You don't need `docker login`. The step requests a short-lived OIDC token and passes it to Kaniko using a Docker config file.

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

KANIKO_IMG="gcr.io/kaniko-project/executor:v1.24.0"
echo "Verifying signature of ${KANIKO_IMG} ..."
docker run --rm -v "$PWD:/work" -w /work cgr.dev/chainguard/cosign \
  verify -key cosign.pub "${KANIKO_IMG}"
echo "Signature verified OK for ${KANIKO_IMG}"
```

This verification uses Google's official public key and only applies to their deprecated images.

#### Signing and verifying custom-built images

If you build your own Kaniko images from the Chainguard fork, you can sign them for enhanced security. This process involves generating a key pair, signing your images, and verifying them before use.

Generate a key pair and store in Buildkite Secrets:

```bash
# Generate signing key pair
cosign generate-key-pair
```

Then [create the secrets](/docs/pipelines/security/secrets/buildkite-secrets#create-a-secret) using the Buildkite web interface:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select your cluster.
1. Select **Secrets** to access the **Secrets** page, then select **New Secret**.
1. Create a secret with key `kaniko-signing-private-key` and the contents of `cosign.key` as the value.
1. Create another secret with key `kaniko-signing-public-key` and the contents of `cosign.pub` as the value.

1. Sign your custom image after building:

    ```bash
    # Pull the private key from Buildkite Secrets
    buildkite-agent secret get "kaniko-signing-private-key" > cosign.key

    # Sign your custom image and push signature to registry
    docker run --rm -v "$PWD:/work" -w /work cgr.dev/chainguard/cosign \
      sign -key cosign.key your-registry/kaniko:latest
    ```

1. Verify your custom image before use:

    ```bash
    # Pull the public key from Buildkite Secrets
    buildkite-agent secret get "kaniko-signing-public-key" > cosign.pub

    # Verify your custom image
    docker run --rm -v "$PWD:/work" -w /work cgr.dev/chainguard/cosign \
      verify -key cosign.pub your-registry/kaniko:latest
    ```

#### Alternative: Keyless signing with OIDC

For a more modern approach, you can use keyless signing with OIDC (OpenID Connect) instead of managing key pairs. This method uses [sigstore.dev](https://sigstore.dev/) as a third-party service to handle the signing process:

> 🚧 Important
> Keyless signing requires authenticating with an OAuth provider (like Google, GitHub, or Microsoft) through sigstore.dev. This means your OAuth identity will be used to create a temporary signing certificate that's stored in the sigstore public transparency log. Consider your organization's security policies before using this approach.

```bash
# Keyless signing (requires OIDC authentication with sigstore.dev)
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

For interactive debugging, you can run the debug image directly on your EC2 instance:

```bash
docker run -it --entrypoint=/busybox/sh gcr.io/kaniko-project/executor:v1.24.0-debug
```

> 🚧 Prerequisites for interactive debugging
> To run interactive debugging commands on your Elastic CI Stack for AWS EC2 instances, you must have configured the `KeyName` CloudFormation stack parameter during stack deployment. This allows you to SSH into the instances as the `ec2-user` to run local Docker commands.

> 📘 Interactive debugging limitation
> Interactive debugging with `KANIKO_SHELL=1` only works when running Docker commands directly on the EC2 instance, not when set as pipeline environment variables. Pipeline builds run non-interactively and cannot provide shell access.

To enable debug mode in your pipeline, set the `KANIKO_DEBUG` environment variable:

```yaml
steps:
  - label: ":whale: Build and Push with Kaniko Debug"
    env:
      KANIKO_DEBUG: "1"  # Use debug image with additional tools
      PACKAGE_REGISTRY_NAME: "my-container-registry"
    commands:
      - bash .buildkite/steps/kaniko.sh
```

When `KANIKO_DEBUG=1` is set, the pipeline will use the Kaniko debug image instead of the standard image. The debug image includes additional utilities like `busybox`, `sh`, and other debugging tools that can help with troubleshooting build issues, even though interactive shell access is not available in pipeline environments.

The debug image provides several debugging options:

- Verbose logging: Use `KANIKO_VERBOSITY=debug` for detailed build logs
- No-push mode: Set `KANIKO_NO_PUSH=1` to build without pushing to registry
- Interactive shell access: Set `KANIKO_SHELL=1` to get an interactive shell inside the Kaniko container (only works with local Docker commands, not in pipeline environment variables)

The debug image is particularly useful for:

- Investigating build failures
- Examining the build context and Dockerfile
- Testing different Kaniko parameters
- Debugging authentication issues

## Using the published images

After the pipeline completes successfully, your Docker image will be available in your Buildkite Package Registry:

### Pull and run the image

```bash
# Pull the image from your Package Registry
docker pull packages.buildkite.com/acme-inc/my-container-registry/hello-kaniko:abc123-1

# Run the image
docker run --rm packages.buildkite.com/acme-inc/my-container-registry/hello-kaniko:abc123-1
```

### Push to other registries

If you need to push the image to other registries (Docker Hub, ECR, and so on):

```bash
# Tag for your target registry
docker tag packages.buildkite.com/acme-inc/my-container-registry/hello-kaniko:abc123-1 your-registry.example.com/hello-kaniko:abc123-1

# Push to your registry
docker push your-registry.example.com/hello-kaniko:abc123-1
```

## Troubleshooting

### Common issues and solutions

- "Invalid 'aud' claim" error

    * Cause: OIDC policy not configured correctly.
    * Solution: Check your Package Registry's OIDC configuration in Buildkite (ensure it's configured for correct ecosystem).

- 401/403 on push

    * Cause: OIDC audience mismatch.
    * Solution: Check that the audience exactly matches `https://packages.buildkite.com/${ORG}/${REG}` and your registry's OIDC settings allow that audience.

- Image push fails

    * Cause: Authentication or registry configuration issues.
    * Solution: Check your Package Registry configuration and OIDC policy.
