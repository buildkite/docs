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

Deployment to Kubernetes with Argo CD with the help of Buildkite consists of the following stages:

Step 1: You trigger the deployments to ArgoCD. For example:

```yaml
...
- label ":rocket: Trigger Argo CD Sync (Optional)"
    command: |
      echo "Triggering Argo CD application sync..."
      argocd app sync myapp --auth-token ${ARGOCD_TOKEN} --server ${ARGOCD_SERVER}
    env:
      ARGOCD_TOKEN: ${ARGOCD_AUTH_TOKEN}
      ARGOCD_SERVER: "argocd.example.com"
    if: build.branch == "main"
```

You could also use Argo CD API to [sync an application](https://cd.apps.argoproj.io/swagger-ui#tag/ApplicationService/operation/ApplicationService_Sync) or to [rollback a synchroization](https://cd.apps.argoproj.io/swagger-ui#tag/ApplicationService/operation/ApplicationService_Rollback).

Step 2: In your Buildkite pipeline configuration, add a command step that triggers the sync and monitors the deployment until completion:

[example]

Step 3: Argo CD will then unblock the step through the API and add the deployment link in Argo CD's UI as well as in the Buildkite's build [annotations](/docs/agent/v3/cli-annotate).

[example]
