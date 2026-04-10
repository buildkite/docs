# Network requirements

Self-hosted [Buildkite agents](/docs/agent) only make outbound HTTPS connections. No inbound ports need to be opened. This page lists the hosts and ports your network must allow agents to reach.

## Required hosts

Every self-hosted agent must be able to reach the following hosts over HTTPS (port 443):

Host | Purpose
---- | -------
`agent.buildkite.com` | The [Agent API](/docs/apis/agent-api) endpoint. Used for agent registration, job polling, log uploads, [artifact](/docs/pipelines/configure/artifacts) coordination, [metadata](/docs/pipelines/configure/build-meta-data), [secrets](/docs/pipelines/security/secrets), [OIDC token](/docs/pipelines/security/oidc) requests, [pipeline uploads](/docs/pipelines/configure/dynamic-pipelines), and cache operations.
`buildkiteartifacts.com` | Default artifact storage. When using the built-in artifact storage, the Agent API provides upload and download URLs on this domain.
{: class="two-column"}

> 📘
> All agent-to-Buildkite communication uses TLS encryption. The agent connects to `agent.buildkite.com` on port 443 using HTTPS. There is no need to open any inbound ports on your firewall or security groups. For more detail on how the agent communicates with Buildkite, see [Buildkite architectures](/docs/pipelines/architecture).

## Optional hosts

Depending on your agent configuration, agents may also need to reach the following hosts.

### Customer-managed artifact storage

If you configure a custom [artifact upload destination](/docs/pipelines/configure/artifacts#storage-providers-encryption-and-retention), agents need access to the relevant storage provider instead of, or in addition to, `buildkiteartifacts.com`:

Storage provider | Hosts
---------------- | -----
Amazon S3 | `*.s3.amazonaws.com` (port 443)
Google Cloud Storage | `storage.googleapis.com`, `www.googleapis.com` (port 443)
Azure Blob Storage | `*.blob.core.windows.net` (port 443)
Artifactory | Your Artifactory server's hostname (port 443)
{: class="two-column"}

### Cloud instance metadata

When running on a cloud provider, agents can automatically detect instance metadata to populate [agent tags](/docs/agent/cli/reference/start#tags). These metadata endpoints are instance-local and do not require internet-routable firewall rules:

Cloud provider | Endpoint | Purpose
-------------- | -------- | -------
AWS (EC2 and ECS) | `169.254.169.254` (port 80, HTTP) | [EC2 instance metadata](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html) and [ECS task metadata](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-metadata-endpoint.html)
Google Cloud | `metadata.google.internal` (port 80, HTTP) | [GCP instance metadata](https://cloud.google.com/compute/docs/metadata/overview)
{: class="responsive-table"}

## Hosts your build jobs may need

In addition to the hosts the agent itself connects to, your build scripts and [plugins](/docs/pipelines/integrations/plugins) may require access to other services. These depend on what your pipelines do, but common examples include:

- **Source control:** your Git host, such as `github.com`, `gitlab.com`, or an internal Git server
- **Package registries:** for example, `registry.npmjs.org`, `pypi.org`, `registry.yarnpkg.com`, or Docker Hub (`registry-1.docker.io`, `auth.docker.io`, `production.cloudflare.docker.com`)
- **Buildkite Package Registries:** `api.buildkite.com` (port 443) if you use [Buildkite Package Registries](/docs/package-registries) from your build scripts
- **Other external services:** deployment targets, notification endpoints, code analysis tools, or any other services your builds interact with

## Buildkite platform egress IPs

If your internal services need to accept inbound connections from the Buildkite platform (for example, [webhooks](/docs/apis/webhooks) or commit status updates to a self-hosted source control system), use the [Meta API](/docs/apis/rest-api/meta) to obtain the current set of platform egress IP addresses.
