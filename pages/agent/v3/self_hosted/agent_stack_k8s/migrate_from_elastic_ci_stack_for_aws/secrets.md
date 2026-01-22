# Migrating secrets

When migrating from the [Elastic CI Stack for AWS](/docs/agent/v3/self-hosted/aws/elastic-ci-stack) to the Buildkite Agent Stack for Kubernetes ([agent-stack-k8s](https://github.com/buildkite/agent-stack-k8s)), you need to establish a new approach for managing secrets that were previously stored in S3 buckets. The Elastic CI Stack for AWS automatically retrieves secrets from S3 and makes them available to jobs. This functionality needs to be replaced when moving to Kubernetes.

This guide covers three approaches for migrating secrets when moving to Kubernetes and provides detailed examples for each.

## S3 secrets in Elastic CI Stack for AWS

The Elastic CI Stack for AWS uses an S3 bucket to store secrets that are automatically retrieved by agents and made available to your builds. The stack supports several types of secrets stored at specific paths:

- SSH private keys for repository access (`/private_ssh_key`)
- Environment variable files (`/env` or `/environment`)
- Git credentials for HTTPS cloning (`/git-credentials`)
- Individual secret files (`/secret-files/*`)
- Pipeline-specific variants of the above (`/{pipeline-slug}/...`)

For complete details about S3 secrets in the Elastic CI Stack for AWS, refer to the [S3 secrets bucket](/docs/agent/v3/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security#s3-secrets-bucket) documentation.

## Migration approaches

When migrating to the Buildkite Agent Stack for Kubernetes, here are three approaches to consider for handling secrets:

- Keeping your existing S3 bucket and using the `elastic-ci-stack-s3-secrets-hooks` repository to retrieve secrets
- Moving secrets into [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/) and exposing them through controller configuration
- Moving secrets into [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets) and referencing them in your pipeline YAML or through the [agent CLI](/docs/agent/v3/cli/reference)

Each approach has different characteristics:

| Consideration | S3 with Hooks | Kubernetes Secrets | Buildkite secrets |
|--------------|---------------|-------------------|-------------------|
| **Migration effort** | Low (reuse existing S3 bucket) | Medium (requires secret extraction and creation) | Medium (requires secret migration to Buildkite Pipelines) |
| **Operational complexity** | Medium (requires AWS credentials, hook configuration) | Low (native Kubernetes) | Low (managed by Buildkite Pipelines) |
| **Access control** | AWS IAM policies | Kubernetes RBAC | Buildkite access policies |
| **Cross-platform** | AWS-specific | Kubernetes-specific | Platform-agnostic |
| **Cost** | S3 storage + data transfer | Included with Kubernetes | Included with Buildkite |

## Continue using S3 secrets bucket

This approach uses the [`elastic-ci-stack-s3-secrets-hooks`](https://github.com/buildkite/elastic-ci-stack-s3-secrets-hooks) repository to continue retrieving secrets from your existing S3 bucket. The hooks run in the checkout and command containers to fetch secrets from S3 during job execution. This minimizes migration effort because your secrets remain in S3.

### Prerequisites

- Existing S3 secrets bucket from Elastic CI Stack for AWS
- AWS credentials with read access to the S3 bucket
- Kubernetes cluster with [Agent Stack for Kubernetes](https://github.com/buildkite/agent-stack-k8s) version 0.16.0 or later installed
  + For earlier versions, see the [agent hooks documentation](/docs/agent/v3/self-hosted/agent-stack-k8s/agent-hooks-and-plugins#agent-hooks-in-earlier-versions) for alternative configuration

### Implementation

The hooks depend on the `s3secrets-helper` binary and the `git-credential-s3-secrets` script. You will need to obtain the required files:

```bash
# Download the hooks repository
git clone https://github.com/buildkite/elastic-ci-stack-s3-secrets-hooks.git
cd elastic-ci-stack-s3-secrets-hooks

# Option 1: Download pre-built binary from GitHub releases
RELEASE_VERSION="v2.8.0"  # Check https://github.com/buildkite/elastic-ci-stack-s3-secrets-hooks/releases for latest version
curl -Lo s3secrets-helper \
  "https://github.com/buildkite/elastic-ci-stack-s3-secrets-hooks/releases/download/${RELEASE_VERSION}/s3secrets-helper-linux-amd64"
chmod +x s3secrets-helper

# Option 2: Build the binary from source (requires Go)
# cd s3secrets-helper
# go build -o ../s3secrets-helper
# cd ..
```

Create a ConfigMap for the hook scripts:

```bash
kubectl create configmap buildkite-agent-hooks \
  --from-file=environment=hooks/environment \
  --from-file=pre-exit=hooks/pre-exit \
  --namespace buildkite
```

Create a separate ConfigMap for the helper binary and git credential script:

```bash
kubectl create configmap s3-secrets-helpers \
  --from-file=git-credential-s3-secrets=git-credential-s3-secrets \
  --from-file=s3secrets-helper=s3secrets-helper \
  --namespace buildkite
```

Create a Kubernetes Secret with AWS credentials:

```bash
kubectl create secret generic aws-credentials \
  --from-literal=AWS_ACCESS_KEY_ID='YOUR_AWS_ACCESS_KEY' \
  --from-literal=AWS_SECRET_ACCESS_KEY='YOUR_AWS_SECRET_KEY' \
  --from-literal=AWS_DEFAULT_REGION='us-east-1' \
  --namespace buildkite
```

Configure the Agent Stack for Kubernetes controller to mount the hooks, binaries, and provide AWS credentials. Add this to your `values.yaml`:

> 📘 Version requirement
> The `agent-config` configuration requires Agent Stack for Kubernetes version 0.16.0 or later. For earlier versions, see the [agent hooks documentation](/docs/agent/v3/self-hosted/agent-stack-k8s/agent-hooks-and-plugins#agent-hooks-in-earlier-versions).

```yaml
# values.yaml
config:
  agent-config:
    hooks-path: /buildkite/hooks
    hooksVolume:
      name: buildkite-hooks
      configMap:
        defaultMode: 493  # This is 0755 in octal
        name: buildkite-agent-hooks
  default-checkout-params:
    extraVolumeMounts:
    - name: s3-helpers
      mountPath: /usr/local/bin/s3secrets-helper
      subPath: s3secrets-helper
    - name: s3-helpers
      mountPath: /usr/local/bin/git-credential-s3-secrets
      subPath: git-credential-s3-secrets
  default-command-params:
    extraVolumeMounts:
    - name: s3-helpers
      mountPath: /usr/local/bin/s3secrets-helper
      subPath: s3secrets-helper
    - name: s3-helpers
      mountPath: /usr/local/bin/git-credential-s3-secrets
      subPath: git-credential-s3-secrets
  pod-spec-patch:
    containers:
    - name: checkout
      env:
      - name: BUILDKITE_PLUGIN_S3_SECRETS_BUCKET
        value: "example-secrets-bucket"
      envFrom:
      - secretRef:
          name: aws-credentials
    - name: container-0
      env:
      - name: BUILDKITE_PLUGIN_S3_SECRETS_BUCKET
        value: "example-secrets-bucket"
      envFrom:
      - secretRef:
          name: aws-credentials
    volumes:
    - name: s3-helpers
      configMap:
        name: s3-secrets-helpers
        defaultMode: 0755
```

Apply the configuration:

```bash
helm upgrade agent-stack-k8s oci://ghcr.io/buildkite/helm/agent-stack-k8s \
  --namespace buildkite \
  --values values.yaml
```

### Considerations

This approach maintains your existing S3 secret management but requires:

- Agent Stack for Kubernetes version 0.16.0 or newer (for the `agent-config` configuration method explained above)
- AWS credentials accessible from Kubernetes pods
- Network connectivity to AWS S3
- The `s3secrets-helper` binary and `git-credential-s3-secrets` script
- Maintenance of hook scripts, binaries, and AWS credential lifecycle
- Potential latency from S3 API calls during job startup
- Regular updates to binaries when new versions are released

This approach works well as a temporary migration step or when you need to maintain consistency with remaining Elastic CI Stack for AWS deployments.

## Migrate to Kubernetes secrets

This approach provides a Kubernetes-native secrets management solution as it migrates secrets from S3 into native Kubernetes Secrets and exposes them to jobs using controller configuration or the [`kubernetes` plugin](/docs/agent/v3/self-hosted/agent-stack-k8s/running-builds#defining-steps-kubernetes-plugin).

### Prerequisites

- Access to existing S3 secrets bucket
- `kubectl` configured for your Kubernetes cluster
- AWS CLI (for downloading secrets from S3)
- [Agent Stack for Kubernetes](https://github.com/buildkite/agent-stack-k8s) installed

### Migrating SSH keys

SSH keys stored in S3 at `/private_ssh_key` can be migrated to Kubernetes Secrets.

Start the migration with downloading the SSH key from S3:

```bash
# Download the SSH key from S3
aws s3 cp "s3://${SECRETS_BUCKET}/private_ssh_key" ./id_rsa
chmod 600 ./id_rsa
```

Create a Kubernetes Secret:

```bash
kubectl create secret generic git-ssh-credentials \
  --from-file=SSH_PRIVATE_RSA_KEY=./id_rsa \
  --namespace buildkite

# Clean up the local key file
rm ./id_rsa
```

Configure the controller to mount the SSH key in the checkout container. Add to your `values.yaml`:

```yaml
# values.yaml
config:
  default-checkout-params:
    envFrom:
    - secretRef:
        name: git-ssh-credentials
```

Alternatively, configure it per-pipeline using the `kubernetes` plugin:

```yaml
# pipeline.yaml
steps:
- label: "Build"
  command: "make build"
  agents:
    queue: kubernetes
  plugins:
  - kubernetes:
      gitEnvFrom:
      - secretRef:
          name: git-ssh-credentials
```

For complete details on Git credentials, refer to the [Git credentials](/docs/agent/v3/self-hosted/agent-stack-k8s/git-credentials) documentation.

### Migrating environment variables

Environment variable files stored in S3 at `/env` or `/environment` can be migrated to Kubernetes Secrets.

Start the migration with downloading the environment file from S3:

```bash
# Download the environment file
aws s3 cp "s3://${SECRETS_BUCKET}/env" ./env

# View the contents (format: KEY=VALUE)
cat ./env
```

Create a Kubernetes Secret from the environment file:

```bash
kubectl create secret generic build-env-vars \
  --from-env-file=./env \
  --namespace buildkite

# Clean up the local file
rm ./env
```

Expose environment variables to all containers:

```yaml
# values.yaml
config:
  default-checkout-params:
    envFrom:
    - secretRef:
        name: build-env-vars
  default-command-params:
    envFrom:
    - secretRef:
        name: build-env-vars
```

Or configure per-pipeline:

```yaml
# pipeline.yaml
steps:
- label: "Deploy"
  command: "deploy.sh"
  agents:
    queue: kubernetes
  plugins:
  - kubernetes:
      podSpecPatch:
        containers:
        - name: checkout
          envFrom:
          - secretRef:
              name: build-env-vars
        - name: container-0
          envFrom:
          - secretRef:
              name: build-env-vars
```

To expose specific environment variables individually:

```yaml
# values.yaml
config:
  pod-spec-patch:
    containers:
    - name: container-0
      env:
      - name: API_KEY
        valueFrom:
          secretKeyRef:
            name: build-env-vars
            key: API_KEY
      - name: DATABASE_URL
        valueFrom:
          secretKeyRef:
            name: build-env-vars
            key: DATABASE_URL
```

### Migrating Git credentials

Git credentials files stored in S3 at `/git-credentials` can be migrated to Kubernetes Secrets for HTTPS repository cloning.

Start the migration with downloading the Git credentials file from S3:

```bash
# Download the git-credentials file
aws s3 cp "s3://${SECRETS_BUCKET}/git-credentials" ./.git-credentials
chmod 600 ./.git-credentials
```

Create a Kubernetes Secret:

```bash
kubectl create secret generic git-https-credentials \
  --from-file=.git-credentials=./.git-credentials \
  --namespace buildkite

# Clean up the local file
rm ./.git-credentials
```

Configure the controller to use Git credentials:

```yaml
# values.yaml
config:
  default-checkout-params:
    gitCredentialsSecret:
      secretName: git-https-credentials
```

Or configure per-pipeline:

```yaml
# pipeline.yaml
steps:
- label: "Build"
  command: "make build"
  agents:
    queue: kubernetes
  plugins:
  - kubernetes:
      checkout:
        gitCredentialsSecret:
          secretName: git-https-credentials
```

### Migrating individual secret files

Individual secret files stored in S3 at `/secret-files/*` can be migrated to Kubernetes Secrets. These files become environment variables with names derived from their filenames.

Start the migration with downloading secret files from S3:

```bash
# Download all secret files
aws s3 sync "s3://${SECRETS_BUCKET}/secret-files/" ./secret-files/

# View downloaded files
ls ./secret-files/
```

Create Kubernetes Secrets for each file:

```bash
# Create a secret for DATABASE_PASSWORD
kubectl create secret generic database-password \
  --from-file=DATABASE_PASSWORD=./secret-files/DATABASE_PASSWORD \
  --namespace buildkite

# Create a secret for API_TOKEN
kubectl create secret generic api-token \
  --from-file=API_TOKEN=./secret-files/API_TOKEN \
  --namespace buildkite

# Clean up local files
rm -rf ./secret-files
```

Expose individual secrets as environment variables:

```yaml
# values.yaml
config:
  default-checkout-params:
    envFrom:
    - secretRef:
        name: database-password
    - secretRef:
        name: api-token
  default-command-params:
    envFrom:
    - secretRef:
        name: database-password
    - secretRef:
        name: api-token
```

Alternatively, create a single Secret containing multiple files:

```bash
kubectl create secret generic app-secrets \
  --from-file=./secret-files/ \
  --namespace buildkite

# Clean up local files
rm -rf ./secret-files
```

Expose all secrets from the single Secret:

```yaml
# values.yaml
config:
  default-checkout-params:
    envFrom:
    - secretRef:
        name: app-secrets
  default-command-params:
    envFrom:
    - secretRef:
        name: app-secrets
```

### Migrating pipeline-specific secrets

Pipeline-specific secrets stored in S3 at `/{pipeline-slug}/...` can be migrated to pipeline-specific Kubernetes Secrets.

Start the migration with downloading pipeline-specific secrets:

```bash
# Download pipeline-specific environment file
aws s3 cp "s3://${SECRETS_BUCKET}/my-pipeline/env" ./my-pipeline-env

# Download pipeline-specific SSH key
aws s3 cp "s3://${SECRETS_BUCKET}/my-pipeline/private_ssh_key" ./my-pipeline-key
```

Create pipeline-specific Kubernetes Secrets:

```bash
# Create Secret for pipeline environment variables
kubectl create secret generic my-pipeline-env-vars \
  --from-env-file=./my-pipeline-env \
  --namespace buildkite

# Create Secret for pipeline SSH key
kubectl create secret generic my-pipeline-ssh-key \
  --from-file=SSH_PRIVATE_RSA_KEY=./my-pipeline-key \
  --namespace buildkite

# Clean up local files
rm ./my-pipeline-env ./my-pipeline-key
```

Configure pipeline-specific secrets in pipeline YAML:

```yaml
# pipeline.yaml
steps:
- label: "Build my-pipeline"
  command: "make build"
  agents:
    queue: kubernetes
  plugins:
  - kubernetes:
      gitEnvFrom:
      - secretRef:
          name: my-pipeline-ssh-key
      podSpecPatch:
        containers:
        - name: container-0
          envFrom:
          - secretRef:
              name: my-pipeline-env-vars
```

### Considerations

Kubernetes Secrets provide native integration with your cluster but require:

- Initial migration effort to extract and create all secrets
- Kubernetes RBAC configuration for secret access control
- Process for secret rotation and updates in Kubernetes
- Separate secrets management for each Kubernetes cluster

This approach works well when committing fully to Kubernetes-native tooling and when secrets are environment-specific.

## Migrate to Buildkite secrets

This approach migrates S3 secrets to [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets), which provides centralized secrets storage accessible across different agent platforms.

### Prerequisites

- Buildkite organization with Secrets feature enabled
- Cluster configured with Buildkite secrets access
- [Agent Stack for Kubernetes](https://github.com/buildkite/agent-stack-k8s) installed

### Migrating secrets to Buildkite

For each secret in S3, create a corresponding Buildkite Secret. Learn how to [create a secret](/docs/pipelines/security/secrets/buildkite-secrets#create-a-secret) in the Buildkite secrets documentation.

### Using secrets in pipeline YAML

Reference Buildkite secrets directly in your pipeline YAML using the `secrets` key:

```yaml
# pipeline.yaml
steps:
- label: "Deploy"
  command: "deploy.sh"
  agents:
    queue: kubernetes
  secrets:
  - API_KEY
  - DATABASE_PASSWORD
```

The secrets are injected as environment variables with the same name as the secret key. You can also specify custom environment variable names:

```yaml
# pipeline.yaml
steps:
- label: "Deploy"
  command: "deploy.sh"
  agents:
    queue: kubernetes
  secrets:
    MY_API_KEY: API_KEY
    MY_DB_PASSWORD: DATABASE_PASSWORD
```

### Using secrets with the agent CLI

Retrieve secrets using the `buildkite-agent secret` [CLI command](/docs/agent/v3/cli/reference/secret) within your build steps:

```yaml
# pipeline.yaml
steps:
- label: "Deploy with CLI"
  command: |
    # Retrieve secret and use it
    API_KEY=$(buildkite-agent secret get api-key)
    DATABASE_PASSWORD=$(buildkite-agent secret get database-password)

    # Use secrets in deployment
    deploy.sh --api-key="$$API_KEY" --db-password="$$DATABASE_PASSWORD"
  agents:
    queue: kubernetes
```

### Migrating SSH keys

For SSH keys, store the private key content as a Buildkite Secret, and configure it using an agent hook. Create a Kubernetes ConfigMap with a `pre-checkout` hook:

```bash
cat > pre-checkout <<'EOF'
#!/bin/bash
set -euo pipefail

if [[ -n "${BUILDKITE_REPO:-}" ]] && [[ "${BUILDKITE_REPO}" =~ ^git@ ]]; then
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh

  buildkite-agent secret get ssh-private-key > ~/.ssh/id_rsa
  chmod 600 ~/.ssh/id_rsa

  eval $(ssh-agent -s)
  ssh-add ~/.ssh/id_rsa
fi
EOF

kubectl create configmap buildkite-hooks \
  --from-file=pre-checkout=pre-checkout \
  --namespace buildkite
```

Configure the hook in your controller:

```yaml
# values.yaml
config:
  agent-config:
    hooks-path: /buildkite/hooks
    hooksVolume:
      name: buildkite-hooks
      configMap:
        name: buildkite-hooks
        defaultMode: 493  # This is 0755 in octal
```

### Considerations

Buildkite secrets provide centralized management but require:

- Buildkite secrets feature enabled for your organization
- Migration of all secrets to Buildkite platform
- Configuration of access policies for secret access control
- Pipeline updates to reference secrets using the `secrets:` key or `buildkite-agent secret get` command

This approach works well when using multiple agent platforms (Kubernetes, AWS, on-premises) and when centralized secrets management is preferred.

## Related resources

- [S3 secrets bucket in Elastic CI Stack for AWS](/docs/agent/v3/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security#s3-secrets-bucket)
- [Git credentials in agent-stack-k8s](/docs/agent/v3/self-hosted/agent-stack-k8s/git-credentials)
- [Kubernetes PodSpec in agent-stack-k8s](/docs/agent/v3/self-hosted/agent-stack-k8s/podspec)
- [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets)
- [Using secrets in jobs](/docs/pipelines/security/secrets/buildkite-secrets#use-a-buildkite-secret-in-a-job)
- [`buildkite-agent secret` CLI](/docs/agent/v3/cli/reference/secret)
- [`elastic-ci-stack-s3-secrets-hooks` repository](https://github.com/buildkite/elastic-ci-stack-s3-secrets-hooks)
