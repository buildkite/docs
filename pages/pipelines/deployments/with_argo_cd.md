# Deploying with Argo CD

[Argo CD](https://argoproj.github.io/cd/):

- Is a continuous delivery tool specifically designed for Kubernetes.
- Focuses on deploying applications to Kubernetes clusters using GitOps principles, where the desired state of your applications is declaratively defined in Git repositories and automatically synchronized to your Kubernetes clusters.

Buildkite Pipelines and Argo CD complement each other in modern CI/CD workflows, where you can allow Pipelines to handle the CI tasks, such as building, testing, and packaging applications, and allow Argo CD to specialize in handling continuous deployment.

The following example workflow outlines how Buildkite would work with Argo CD:

1. Buildkite Pipelines receives a code commit and triggers a build.
1. The build process in Pipelines might include steps to package, test, and create Kubernetes manifests.
1. Buildkite Pipelines pushes the generated manifests to a GitOps repository, which is monitored by Argo CD.
1. Argo CD detects the changes in the GitOps repo and automatically deploys the application to the target Kubernetes cluster.

This approach allows for a clear separation of concerns—Pipelines handles the build and test processes, while Argo CD handles the deployment to Kubernetes. This simplifies the overall CI/CD pipeline and makes it easier to manage deployments.

## Using Argo CD with Buildkite Pipelines

There are various ways Argo CD could be used with Buildkite Pipelines. The most common ones include:

- The Buildkite agent pushes Kubernetes manifests to a GitOps repository and then waits for the GitOps engine to [reconcile](http://argo-cd.readthedocs.io/en/stable/operator-manual/reconcile/) the change to a target Kubernetes cluster.
- Buildkite Pipelines triggers Argo CD to deploy to Kubernetes.
- Buildkite Pipelines triggers Argo CD via Argo API to either [sync an application](https://cd.apps.argoproj.io/swagger-ui#tag/ApplicationService/operation/ApplicationService_Sync), or [roll back a synchronization](https://cd.apps.argoproj.io/swagger-ui#tag/ApplicationService/operation/ApplicationService_Rollback), and monitors the deployment until completion.

## Deploying to Kubernetes with Argo CD triggered by Buildkite Pipelines

You can trigger the deployments to Argo CD through a command defined in your Buildkite pipeline definition. For example:

```yaml
...
- key: "deploy-to-dev"
  label: "Trigger Argo CD sync"
  command: |
    echo "Triggering Argo CD application sync..."
    argocd app sync myapp --auth-token ${MYARGOCD_TOKEN} --server ${MYARGOCD_SERVER}
  env:
      MYARGOCD_TOKEN: ${MYARGOCD_AUTH_TOKEN}
      MYARGOCD_SERVER: "argocd.example.com"
  if: build.branch == "main"
```

You can insert a [block step](/docs/pipelines/configure/step-types/block-step) before triggering Argo CD for deployment to make sure a condition for deployment is met. For example:

```yaml
...
  - if: build.branch == "main"
    key: "block-step-condition-for-deploy"
    block: "Deploy this to Dev?"
  - key: "deploy-to-dev"
    label: "Buildkite Agent to Argo CD CLI Manifest for Dev"
    command: |
      echo "--- :rocket: Deploying to Dev via Argo CD"
      argocd app sync my-app-dev --server $MYARGOCD_SERVER --auth-token $MYARGOCD_TOKEN
    env:
      MYARGOCD_TOKEN: ${MYARGOCD_AUTH_TOKEN}
      MYARGOCD_SERVER: "argocd.example.com"
...
```

> 🚧
> Bear in mind that these examples are aimed at providing you with a basic understanding of how to use Argo CD with Buildkite. For production-ready implementations, as discussed in [Risk considerations](/docs/pipelines/security/secrets/risk-considerations), it is _strongly recommended_ that you avoid using your secrets in plaintext pipeline files. Instead, you can use a [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets)-based approach.

## Using annotations to link to Argo CD

With the help of Buildkite's build [annotations](/docs/agent/v3/cli-annotate), you can include a deployment link to the Argo CD interface after the build has finished running to review the deployment status. For example:

```yaml
steps:
  - label: "Deploy"
    command: |
      buildkite-agent annotate "🚀 [View Deployment in Argo CD](https://argocd.myorg.com/applications/default/myapp)" --style info --context "deployment"
```

## Deploying with the Argo CD deployment plugin

The approaches above follow a "fire-and-forget" pattern — they trigger Argo CD operations but don't actively monitor or respond to deployment outcomes. The [Argo CD Deployment Buildkite Plugin](https://github.com/buildkite-plugins/argocd-deployment-buildkite-plugin) provides a fundamentally different "deploy-monitor-respond" process.

In the traditional "fire-and-forget" approach, you would trigger either Argo CD's sync command (used in deploy operations) or rollback command (used in rollback operations), and the command would complete immediately. This approach doesn't include health monitoring or failure detection and manual intervention will be required if issues arise.

The plugin-based approach automatically performs the following out of the box:

1. Deploy: Triggers Argo CD sync operation
1. Monitor: Continuously monitors application health via Argo CD API
1. Respond: Automatically detects failures and can roll back to last known good state
1. Report: Collects logs, creates annotations, and sends notifications

### Key advantages of the plugin-based approach

- Unlike Argo CD's basic rollback, the plugin can automatically detect deployment failures and roll back to the last known good state, or provide interactive rollback decisions with detailed context.
- The plugin allows performing real-time continuous health monitoring during deployment with configurable intervals and timeouts. This is something  that would not available with basic CLI commands.
- Deployment observability such as automatic log collection, artifact upload, and detailed [Buildkite annotations](/docs/agent/v3/cli-annotate) that provide deployment visibility.
- Production-ready safety features**: atomic deployments, configurable timeouts, and Slack notifications for deployment events.

### Key features

The plugin offers several advantages over manual CLI usage:

- **Deploy and Rollback**: Support for both deployment and rollback operations
- **Health Monitoring**: Real-time application health checks via Argo CD API
- **Log Collection**: Automatic collection of Argo CD application and pod logs
- **Artifact Upload**: Upload deployment logs and artifacts to Buildkite
- **Notifications**: Slack notifications via Buildkite integration
- **Auto Rollback**: Automatic rollback on deployment failures
- **Manual Rollback Workflow**: Interactive block steps for manual rollback decisions
- **Comprehensive Annotations**: Automatic creation of detailed success/failure annotations

### Requirements for using the plugin

The plugin requires the Argo CD CLI to be installed on your Buildkite Agents, as it leverages the CLI for Argo CD operations while adding the enhanced monitoring and rollback logic on top.

### Authentication setup

The plugin requires the following Argo CD authentication environment variables:

- `ARGOCD_SERVER` - Argo CD server URL (can also be set in plugin configuration)
- `ARGOCD_USERNAME` - Argo CD username (can also be set in plugin configuration)
- `ARGOCD_PASSWORD` - Argo CD password (must be set via environment variable)

For production deployments, use a secure secret management solution like [Buildkite Secrets](/docs/pipelines/security/secrets/buildkite-secrets), HashiCorp Vault, or AWS Secrets Manager to fetch the `ARGOCD_PASSWORD` before your deployment steps.

### Production deployment with auto-rollback

For production environments, use automatic rollback on health check failures:

```yaml
steps:
  - label: "🚀 Deploy to Production"
    plugins:
      - secrets#v1.0.0:
          env:
            ARGOCD_PASSWORD: argocd-production-password
      - argocd_deployment#v1.0.0:
          app: "my-app"
          argocd_server: "https://argocd.example.com"
          argocd_username: "admin"
          mode: "deploy"
          rollback_mode: "auto"  # Automatic rollback on failure; default if not specified
          collect_logs: true
          upload_artifacts: true
          log_lines: 1000
          health_check_interval: 30
          timeout: 600
          health_check_timeout: 300
          notifications:
            slack_channel: "#deployments"
```
{: codeblock-file="pipeline.yml"}

### Development deployment with manual rollback

For development environments, use manual rollback control with interactive decisions:

```yaml
steps:
  - label: "🚫 Deploy to Development"
    plugins:
      - aws-sm#v1.0.0:
          secrets:
            - name: ARGOCD_PASSWORD
              key: argocd/development/password
      - argocd_deployment#v1.0.0:
          app: "my-app-dev"
          argocd_server: "argocd-server.argocd.svc.cluster.local:443"
          argocd_username: "admin"
          mode: "deploy"
          rollback_mode: "manual"  # Interactive rollback decision; must be specified
          collect_logs: true
          log_lines: 2000
          upload_artifacts: true
          notifications:
            slack_channel: "#dev-deployments"
```
{: codeblock-file="pipeline.yml"}

### Manual rollback operations

You can also perform explicit rollbacks to specific revisions:

```yaml
steps:
  - label: "🔄 Manual Rollback"
    plugins:
      - vault-secrets#v2.2.1:
          server: ${VAULT_ADDR}
          secrets:
            - path: secret/argocd/password
              field: ARGOCD_PASSWORD
      - argocd_deployment#v1.0.0:
          app: "my-app"
          argocd_server: "argocd.example.com:443"
          argocd_username: "admin"
          mode: "rollback"
          rollback_mode: "manual" # Or "auto"; either must be specified
          target_revision: "370"  # Argo CD History ID or Git commit SHA
          collect_logs: true
          log_lines: 3000
          upload_artifacts: true
```
{: codeblock-file="pipeline.yml"}

Note that by default, Argo CD only returns the last 10 entries from the deployment history. For manual rollbacks, use recent History IDs (visible in `argocd app history <app-name>`) or commit SHA values from the recent deployments.
