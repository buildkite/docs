# Remote BuildKit builders on Elastic CI Stack for AWS

[BuildKit](https://docs.docker.com/reference/buildkit/) supports running container builds on a remote daemon. This guide shows how to provision an Amazon EC2 instance as a dedicated BuildKit builder and connect Elastic CI Stack for AWS agents to it.

Running builds on a separate instance provides faster CPU, persistent cache storage, and isolation from your pipeline agents. The Buildkite agent coordinates the build while BuildKit executes it on the remote node.

> 📘 Local BuildKit builds
> If you want to run BuildKit builds directly on your Elastic CI Stack for AWS agents instead of a remote instance, see [BuildKit container builds](/docs/agent/v3/aws/elastic_ci_stack/ec2_linux_and_windows/buildkit_container_builds).

## How it works

1. A dedicated EC2 instance runs the BuildKit daemon (`buildkitd`) and exposes the gRPC listener on TCP port 1234.
1. Elastic CI Stack for AWS agents install the BuildKit client (`buildctl`) and configure environment variables to target the remote builder.
1. Pipelines call `buildctl build` to build and push container images.

The remote EC2 instance retains the BuildKit cache, so subsequent builds reuse cached layers. Multiple pipelines can share the same builder if you size the instance appropriately.

> 📘 TLS configuration
> This guide configures BuildKit without TLS for simplicity. The BuildKit instance runs in a private VPC with security group rules that restrict access to only your Elastic CI Stack for AWS agents. For additional security guidance, see the [BuildKit TLS documentation](https://github.com/moby/buildkit#expose-buildkit-as-a-tcp-service).

## Prerequisites

- Elastic CI Stack for AWS deployed with agents in the same VPC and security group access to the BuildKit instance.
- Amazon EC2 instance to run BuildKit (for example, `c5a.large` with gp3 EBS volume for cache).
- IAM permissions for the instance profile to access ECR (if pushing images).

## Provision the BuildKit instance

Use Terraform, CloudFormation, or another provisioning tool to launch an EC2 instance with the following characteristics:

- Amazon Linux 2023 (or another supported Linux distribution)
- Attached EBS volume sized for your layer cache (100 GB or more)
- Same VPC as your Elastic CI Stack for AWS instances
- Security group allowing inbound TCP connections on the BuildKit port (default `tcp/1234`) from your Elastic CI Stack for AWS security group

> 🚧
> The BuildKit instance and Elastic CI Stack for AWS must be in the same VPC. Security group rules that reference other security groups only work within a single VPC.

Install BuildKit and Docker CLI on the instance:

```bash
sudo yum update -y
sudo yum install -y docker

export BUILDKIT_VERSION="v0.13.2"
curl -LO "https://github.com/moby/buildkit/releases/download/${BUILDKIT_VERSION}/buildkit-${BUILDKIT_VERSION}.linux-amd64.tar.gz"
sudo tar -C /usr/local -xzvf "buildkit-${BUILDKIT_VERSION}.linux-amd64.tar.gz"

sudo mkdir -p /var/lib/buildkit
```

Create a systemd unit to manage the BuildKit daemon:

```bash
sudo tee /etc/systemd/system/buildkitd.service <<'EOF'
[Unit]
Description=BuildKit daemon
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/buildkitd \
  --addr tcp://0.0.0.0:1234 \
  --root /var/lib/buildkit
Restart=always

[Install]
WantedBy=multi-user.target
EOF
```

Load the systemd unit and start the daemon:

```bash
sudo systemctl daemon-reload
sudo systemctl enable buildkitd.service
sudo systemctl start buildkitd.service
sudo systemctl status buildkitd.service
```

## Configuring Elastic CI Stack for AWS agents

Install `buildctl` on each Elastic CI Stack for AWS instance so your pipelines can connect to the remote builder. Bake the binary into your custom AMI using the [custom image guide](/docs/agent/v3/aws/elastic_ci_stack/ec2_linux_and_windows/setup#custom-images):

```bash
export BUILDKIT_VERSION="v0.13.2"
curl -LO "https://github.com/moby/buildkit/releases/download/${BUILDKIT_VERSION}/buildkit-${BUILDKIT_VERSION}.linux-amd64.tar.gz"
sudo tar -C /usr/local -xzvf "buildkit-${BUILDKIT_VERSION}.linux-amd64.tar.gz" bin/buildctl
sudo chmod 755 /usr/local/bin/buildctl
```

Create an environment hook in your Elastic CI Stack for AWS secrets bucket to configure the BuildKit connection. Upload a file named `env` to `s3://<your-secrets-bucket>/env` with the following content:

```bash
#!/bin/bash
set -euo pipefail

# Configure BuildKit connection
export BUILDKIT_HOST="tcp://<buildkit-private-ip>:1234"

echo "BuildKit connection configured"
```

Replace `<buildkit-private-ip>` with the private IP address of your BuildKit EC2 instance. The Elastic CI Stack for AWS automatically sources scripts from the `env` path in the secrets bucket during agent startup.

## Pipeline example

The following example runs a build using the remote BuildKit instance and pushes to Amazon ECR, using the [`ecr`](https://github.com/buildkite-plugins/ecr-buildkite-plugin) plugin.

For docker, use the [`docker-login`](https://github.com/buildkite-plugins/docker-login-buildkite-plugin) or [`docker-image-push`](https://github.com/buildkite-plugins/docker-image-push-buildkite-plugin) plugins:

```yaml
steps:
  - label: ":docker: Build with BuildKit"
    plugins:
      - ecr#v2.10.0: 
          login: true
          account-ids:
            - <account-id>
          region: <region>
    command: |
      set -euo pipefail
      buildctl build \
        --frontend dockerfile.v0 \
        --local context=. \
        --local dockerfile=. \
        --output type=image,name=<account-id>.dkr.ecr.<region>.amazonaws.com/<image-name>:latest,push=true
```

Replace the registry URL and image name with your target repository. The `buildctl` command uses the `BUILDKIT_HOST` environment variable set by the bootstrap hook to connect to the remote daemon.

For multi-platform builds, add the `--opt platform=linux/amd64,linux/arm64` flag to the `buildctl build` command.

## Security considerations

- **Network isolation (required):** Configure the BuildKit security group to only allow inbound TCP 1234 from your Elastic CI Stack for AWS security group.
- **VPC placement (required):** Run the BuildKit instance in a private subnet with no public IP address. Use VPC endpoints or NAT gateways for outbound internet access if needed.
- **Monitoring:** Use Amazon CloudWatch Logs and metrics to monitor CPU, memory, and disk usage. Set alarms to detect resource exhaustion or unusual activity.
- **Access control:** Limit which pipelines can use the remote builder by restricting the `BUILDKIT_HOST` environment variable to specific pipeline configurations.

## Troubleshooting

This section covers common issues when setting up remote BuildKit builders.

### Connection errors

- Error `connection error: desc = "error reading server preface: read tcp ... connection reset by peer"`: Network connectivity issue or TLS configuration mismatch. Verify the BuildKit instance is running (`sudo systemctl status buildkitd`), confirm security group allows inbound TCP 1234 from the agent security group, test connectivity from an agent (`buildctl debug workers`), and check BuildKit logs (`sudo journalctl -u buildkitd -n 50`).

### Bootstrap hook errors

- Error `mkdir: cannot create directory '/etc/buildkit': Permission denied`: The `env` hook runs as the `buildkite-agent` user and cannot write to `/etc`. Use agent-writable directories like `${HOME}/.buildkit` or configure certificates in the secrets bucket.

### Build errors

- Error `exporter "registry" could not be found`: The `registry` exporter is not available in this BuildKit version. Use `type=image,push=true` instead of `type=registry` in the `--output` flag:

  ```bash
  buildctl build \
    --output type=image,name=<registry>/<image>:tag,push=true
  ```

### Cache not reused

- BuildKit root directory is not on the persistent EBS volume: Ensure the BuildKit root directory (`/var/lib/buildkit`) is on the attached EBS volume and that the daemon service uses the directory using `--root`.

### Version mismatch

- Builds fail with protocol or feature errors: The `buildctl` binary on agents doesn't match the BuildKit daemon version. Confirm both use the same version:

  ```bash
  # On agent
  buildctl --version

  # On BuildKit instance
  buildkitd --version
  ```

With this setup, Elastic CI Stack for AWS can run remote BuildKit builds on dedicated EC2 infrastructure, providing faster builds and shared caching across pipelines.
