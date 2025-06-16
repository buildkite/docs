# Deploying with Argo CD

[Argo CD](https://argoproj.github.io/cd/) is a continuous delivery tool specifically designed for Kubernetes. It focuses on deploying applications to Kubernetes clusters using GitOps principles, where the desired state of your applications is declaratively defined in Git repositories and automatically synchronized to your clusters.

Buildkite and Argo CD complement each other in modern CI/CD workflows. Buildkite takes care of the CI tasks like building, testing, and packaging applications, while Argo CD specializes in continuous deployment using GitOps methodology.

An example workflow for Buildkite plus Argo CD would look as follows:

1. Buildkite receives a code commit and triggers a build. 
1. The build process in Buildkite might include steps like packaging, testing, and creating Kubernetes manifests. 
1. Buildkite pushes the generated manifests to a GitOps repo, which is monitored by Argo CD. 
1. Argo CD detects the changes in the GitOps repo and automatically deploys the application to the target Kubernetes cluster. 

This approach allows for a clear separation of concerns: Buildkite handles the build and test processes, while Argo CD handles the deployment to Kubernetes. This simplifies the overall CI/CD pipeline and makes it easier to manage deployments. 

## Using Argo CD with Buildkite

There are various ways Argo CD could be used with Buildkite. The most common one include:

* Buildkite agent pushes some Kubernetes Manifests to a GitOps repo and then waits for the GitOps Engine to reconcile the change to a target cluster.
* Buildkite triggers Argo CD to deploy to Kubernetes.
* Buildkite triggers Argo CD via Argo API to [sync an application](https://cd.apps.argoproj.io/swagger-ui#tag/ApplicationService/operation/ApplicationService_Sync) or to [rollback a synchronization](https://cd.apps.argoproj.io/swagger-ui#tag/ApplicationService/operation/ApplicationService_Rollback) and monitors the deployment until completion.

## Deployment to Kubernetes with Argo CD triggered by Buildkite

You can trigger the deployments to Argo CD through a command defined in your Buildkite pipeline definition. For example:

```yaml
...
- label "Trigger Argo CD sync"
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
  - if: "build.branch = \"main\""
    key: "block-step-condition-for-deploy"
    block: "Deploy this to Dev?"
  - key: "deploy-to-dev"
    label: "Buildkite Agent to Argo CD CLI Manifest for Dev"
    command: |
      echo "--- :rocket: Deploying to Dev via Argo CD"
      argocd app sync my-app-dev --server $MYARGOCD_SERVER --auth-token $MYARGOCD_TOKEN
...
```

>
> With the help of Buildkite's build [annotations](/docs/agent/v3/cli-annotate), you can include a deployment link to the Argo CD UI after the build has finished running to review the deployment status.
