# Pre-installed packages

The [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws) AMIs include pre-installed system packages and tools that your builds may depend on. When migrating to Agent Stack for Kubernetes, you need to ensure the required tools are available in your container images.

This guide covers the differences between the pre-installed packages in the Elastic CI Stack for AWS and the default Buildkite agent container image, and how to handle missing packages.

## Package comparison

The Elastic CI Stack for AWS AMI includes the following packages:

| Package | Available in `buildkite/agent:latest` | Notes |
| ------- | ------------------------------------- | ----- |
| `git` | Yes | Core functionality |
| `git-lfs` | No | Required for repositories using Git LFS |
| `jq` | Yes | JSON processing |
| `python` | Yes | Python runtime |
| `unzip` | Yes | Archive extraction |
| `wget` | Yes | File downloads |
| `lsof` | Yes | Process diagnostics |
| `docker` | Yes | Container builds |
| `zip` | No | Archive creation |
| `pigz` | No | Parallel compression |
| `aws-cli` | No | AWS operations |
| `amazon-ecr-credential-helper` | No | ECR authentication |
| `amazon-cloudwatch-agent` | No | AWS-specific monitoring |
| `amazon-ssm-agent` | No | AWS-specific management |
| `aws-cfn-bootstrap` | No | AWS CloudFormation |
| `ec2-instance-connect` | No | AWS-specific SSH |
| `mdadm` | No | RAID management |
| `nvme-cli` | No | NVMe disk management |
| `python-pip` | No | Python package management |
| `python-setuptools` | No | Python package building |
| `bind-utils` | No | DNS utilities (`dig`, `nslookup`) |
| `rsyslog` | No | System logging |
| `gnupg2` | No | GPG signing and verification |
{: class="responsive-table"}

## Handling missing packages

When a package your builds require is not available in the default agent image, you have three options:

- Use a [Buildkite plugin](#using-plugins) that provides the functionality
- Create a [custom container image](#using-custom-container-images) with the required packages
- Install packages at runtime using an [agent hook](#using-agent-hooks)

### Using plugins

Plugins can provide tool functionality without modifying your container image. This approach works well for tools with existing plugin support.

For AWS CLI operations, use the [`aws-assume-role-with-web-identity` plugin](https://github.com/buildkite-plugins/aws-assume-role-with-web-identity-buildkite-plugin) with OIDC, or provide AWS credentials to a container that includes the AWS CLI.

Browse the [plugins directory](/docs/pipelines/integrations/plugins/directory) for plugins that may provide the functionality you need.

### Using custom container images

For packages used frequently across many pipelines, create a custom container image based on the Buildkite agent image or another base image.

Create a Dockerfile with the additional packages:

```dockerfile
FROM buildkite/agent:latest

USER root

RUN apt-get update && apt-get install -y \
    git-lfs \
    zip \
    pigz \
    python3-pip \
    dnsutils \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*

USER buildkite-agent
```

For AWS CLI, install using pip or download the official installer:

```dockerfile
FROM buildkite/agent:latest

USER root

RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws \
    && rm -rf /var/lib/apt/lists/*

USER buildkite-agent
```

Build and push the image to your container registry:

```bash
docker build -t my-registry/buildkite-agent-custom:latest .
docker push my-registry/buildkite-agent-custom:latest
```

Use the custom image in your pipeline:

```yaml
steps:
  - label: "Build"
    command: "make build"
    agents:
      queue: kubernetes
    image: my-registry/buildkite-agent-custom:latest
```

### Using agent hooks

For packages needed occasionally or for testing, install them at runtime using an agent hook. This approach adds latency to job startup but avoids maintaining custom images.

Create a `pre-command` hook that installs the required packages:

```bash
#!/bin/bash
set -euo pipefail

if ! command -v zip &> /dev/null; then
  apt-get update && apt-get install -y zip
fi
```

Create a ConfigMap with the hook:

```bash
kubectl create configmap buildkite-hooks \
  --from-file=pre-command=pre-command \
  --namespace buildkite
```

Configure the controller to use the hook:

```yaml
config:
  agent-config:
    hooks-path: /buildkite/hooks
    hooksVolume:
      name: buildkite-hooks
      configMap:
        name: buildkite-hooks
        defaultMode: 493
```

> 🚧 Runtime installation limitations
> Installing packages at runtime requires root access in your container and adds latency to every job. This approach works for testing but is not recommended for production workloads.

## AWS-specific packages

Several packages in the Elastic CI Stack for AWS are AWS-specific and may not be needed when running on Kubernetes:

- `amazon-ssm-agent`: Provides AWS Systems Manager access. Not applicable in Kubernetes.
- `aws-cfn-bootstrap`: Used for CloudFormation stack signaling. Not applicable in Kubernetes.
- `ec2-instance-connect`: Provides SSH access to EC2 instances. Use `kubectl exec` for pod access instead.
- `amazon-cloudwatch-agent`: For CloudWatch metrics and logs. Use Kubernetes-native observability tools or configure container logging to forward to CloudWatch if required.
- `mdadm` and `nvme-cli`: Low-level disk management tools. Kubernetes manages storage through PersistentVolumes.

If your builds use the AWS CLI for operations like S3 uploads or ECR authentication, include it in a custom container image or use the appropriate Buildkite plugins. See [Amazon ECR authentication](/docs/agent/v3/self-hosted/agent-stack-k8s/migrate-from-elastic-ci-stack-for-aws/ecr) for ECR-specific guidance.
