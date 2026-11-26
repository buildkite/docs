Rails.application.routes.draw do
  # Pages and guides that have been renamed (and we don't want to break old URLs)

  moved_namespaces = {
    "/docs/agent/v3/v3" => "/docs/agent",
    "/docs/agent/v3" => "/docs/agent",
    "/docs/api/analytics" => "/docs/apis/rest-api/test-engine",
    "/docs/rest-api/analytics" => "/docs/apis/rest-api/test-engine",
    "/docs/apis/rest-api/analytics" => "/docs/apis/rest-api/test-engine",
    "/docs/api/packages" => "/docs/apis/rest-api/package-registries",
    "/docs/rest-api/packages" => "/docs/apis/rest-api/package-registries",
    "/docs/apis/rest-api/packages" => "/docs/apis/rest-api/package-registries",
    "/docs/api" => "/docs/apis/rest-api",
    "/docs/rest-api" => "/docs/apis/rest-api",
    "/docs/builds" => "/docs/pipelines",
    "/docs/cli" => "/docs/platform/cli",
    "/docs/integrations/sso" => "/docs/platform/sso",
    "/docs/packages" => "/docs/package-registries",
    "/docs/team-management" => "/docs/platform/team-management",
    "/docs/quickstart" => "/docs/tutorials",
    "/docs/webhooks" => "/docs/apis/webhooks"
  }

  # Share exact destinations with former namespaces, without letting generated
  # aliases take precedence over explicitly defined exceptions.
  moved_pages = {}
  moved_page = ->(source, target) do
    get source, to: redirect(target)
    moved_pages[source] ||= target
  end

  moved_page.call("/docs/agent/buildkite-hosted/linux/custom-base-images", "/docs/agent/buildkite-hosted/linux/custom-agent-images")
  moved_page.call("/docs/agent/clusters", "/docs/pipelines/security/clusters")
  moved_page.call("/docs/agent/elastic-ci-stack-for-aws", "/docs/agent/self-hosted/aws/elastic-ci-stack")
  moved_page.call("/docs/agent/v3", "/docs/agent")
  moved_page.call("/docs/agent/v3/agent-stack-k8s", "/docs/agent/self-hosted/agent-stack-k8s")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/agent-configuration", "/docs/agent/self-hosted/agent-stack-k8s/agent-configuration")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/agent-hooks-and-plugins", "/docs/agent/self-hosted/agent-stack-k8s/agent-hooks-and-plugins")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/buildah-container-builds", "/docs/agent/self-hosted/agent-stack-k8s/buildah-container-builds")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/buildkit-container-builds", "/docs/agent/self-hosted/agent-stack-k8s/buildkit-container-builds")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/container-resource-limits", "/docs/agent/self-hosted/agent-stack-k8s/container-resource-limits")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/controller-configuration", "/docs/agent/self-hosted/agent-stack-k8s/controller-configuration")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/default-parameters", "/docs/agent/self-hosted/agent-stack-k8s/default-parameters")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/depot-agent-kubernetes-container-builds", "/docs/agent/self-hosted/agent-stack-k8s/depot-agent-kubernetes-container-builds")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/dind-container-builds", "/docs/agent/self-hosted/agent-stack-k8s/dind-container-builds")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/docker-compose-container-builds", "/docs/agent/self-hosted/agent-stack-k8s/docker-compose-container-builds")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/git-credentials", "/docs/agent/self-hosted/agent-stack-k8s/git-credentials")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/git-settings", "/docs/agent/self-hosted/agent-stack-k8s/git-settings")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/installation", "/docs/agent/self-hosted/agent-stack-k8s/installation")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/job-metadata", "/docs/agent/self-hosted/agent-stack-k8s/job-metadata")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/kaniko-container-builds", "/docs/agent/self-hosted/agent-stack-k8s/kaniko-container-builds")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/long-running-jobs", "/docs/agent/self-hosted/agent-stack-k8s/long-running-jobs")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/namespace-container-builds", "/docs/agent/self-hosted/agent-stack-k8s/namespace-container-builds")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/overriding-commands", "/docs/agent/self-hosted/agent-stack-k8s/overriding-commands")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/pipeline-signing", "/docs/agent/self-hosted/agent-stack-k8s/pipeline-signing")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/pipeline-validation", "/docs/agent/self-hosted/agent-stack-k8s/pipeline-validation")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/pod-template", "/docs/agent/self-hosted/agent-stack-k8s/pod-template")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/podspec", "/docs/agent/self-hosted/agent-stack-k8s/podspec")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/prometheus-metrics", "/docs/agent/self-hosted/agent-stack-k8s/prometheus-metrics")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/running-builds", "/docs/agent/self-hosted/agent-stack-k8s/running-builds")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/securing-the-stack", "/docs/agent/self-hosted/agent-stack-k8s/securing-the-stack")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/setting-up-hooks-and-plugins", "/docs/agent/self-hosted/agent-stack-k8s/agent-hooks-and-plugins")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/sidecars", "/docs/agent/self-hosted/agent-stack-k8s/sidecars")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/troubleshooting", "/docs/agent/self-hosted/agent-stack-k8s/troubleshooting")
  moved_page.call("/docs/agent/v3/agent-stack-k8s/volume-mounts", "/docs/agent/self-hosted/agent-stack-k8s/volume-mounts")
  moved_page.call("/docs/agent/v3/aws", "/docs/agent/self-hosted/aws")
  moved_page.call("/docs/agent/v3/aws/architecture/recommendations", "/docs/agent/self-hosted/aws/architecture/recommendations")
  moved_page.call("/docs/agent/v3/aws/architecture/securing-your-setup", "/docs/agent/self-hosted/aws/architecture/securing-your-setup")
  moved_page.call("/docs/agent/v3/aws/architecture/vpc", "/docs/agent/self-hosted/aws/architecture/vpc")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack", "/docs/agent/self-hosted/aws/elastic-ci-stack")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack-architecture", "/docs/agent/self-hosted/aws/elastic-ci-stack/architecture")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/buildah-container-builds", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/buildah-container-builds")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/buildkit-container-builds", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/buildkit-container-builds")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/cloudformation-service-role", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/setup#cloudformation-service-role")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/configuration-parameters", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/configuration-parameters")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/creating-custom-amis", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/creating-custom-amis")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/depot-elastic-ci-container-builds", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/depot-elastic-ci-container-builds")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/docker-compose-container-builds", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/docker-compose-container-builds")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/kaniko-container-builds", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/kaniko-container-builds")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/managing-elastic-ci-stack", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/managing-elastic-ci-stack")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/namespace-remote-builders", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/namespace-remote-builders")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/remote-buildkit-ec2", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/remote-buildkit-ec2")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/secrets-bucket", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security#s3-secrets-bucket")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/secrets-manager", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security#using-aws-secrets-manager-in-the-elastic-ci-stack-for-aws")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/security", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/setup", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/setup")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/template-parameters", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/configuration-parameters")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/terraform", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/terraform")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/troubleshooting", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/troubleshooting")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack/ec2-mac/setup", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-mac/setup")
  moved_page.call("/docs/agent/v3/aws/elastic-ci-stack/ec2-mac/troubleshooting", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-mac/troubleshooting")
  moved_page.call("/docs/agent/v3/aws/secrets-manager", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security#using-aws-secrets-manager-in-the-elastic-ci-stack-for-aws")
  moved_page.call("/docs/agent/v3/aws/self-serve-installation/ec2-mac", "/docs/agent/self-hosted/aws/self-serve-install/ec2-mac")
  moved_page.call("/docs/agent/v3/aws/vpc", "/docs/agent/self-hosted/aws/architecture/vpc")
  moved_page.call("/docs/agent/v3/buildkite-hosted/remote-docker-builders", "/docs/agent/buildkite-hosted/linux/remote-docker-builders")
  moved_page.call("/docs/agent/v3/agent-meta-data", "/docs/agent/cli/reference/start#setting-metadata")
  moved_page.call("/docs/agent/v3/cli-annotate", "/docs/agent/cli/reference/annotate")
  moved_page.call("/docs/agent/v3/cli-annotation", "/docs/agent/cli/reference/annotation")
  moved_page.call("/docs/agent/v3/cli-artifact", "/docs/agent/cli/reference/artifact")
  moved_page.call("/docs/agent/v3/cli-bootstrap", "/docs/agent/cli/reference/bootstrap")
  moved_page.call("/docs/agent/v3/cli-build", "/docs/agent/cli/reference/build")
  moved_page.call("/docs/agent/v3/cli-env", "/docs/agent/cli/reference/env")
  moved_page.call("/docs/agent/v3/cli-lock", "/docs/agent/cli/reference/lock")
  moved_page.call("/docs/agent/v3/cli-meta-data", "/docs/agent/cli/reference/meta-data")
  moved_page.call("/docs/agent/v3/cli-oidc", "/docs/agent/cli/reference/oidc")
  moved_page.call("/docs/agent/v3/cli-pause", "/docs/agent/cli/reference/pause")
  moved_page.call("/docs/agent/v3/cli-pipeline", "/docs/agent/cli/reference/pipeline")
  moved_page.call("/docs/agent/v3/cli-redactor", "/docs/agent/cli/reference/redactor")
  moved_page.call("/docs/agent/v3/cli-reference", "/docs/agent/cli/reference")
  moved_page.call("/docs/agent/v3/cli-resume", "/docs/agent/cli/reference/resume")
  moved_page.call("/docs/agent/v3/cli-secret", "/docs/agent/cli/reference/secret")
  moved_page.call("/docs/agent/v3/cli-start", "/docs/agent/cli/reference/start")
  moved_page.call("/docs/agent/v3/cli-step", "/docs/agent/cli/reference/step")
  moved_page.call("/docs/agent/v3/cli-stop", "/docs/agent/cli/reference/stop")
  moved_page.call("/docs/agent/v3/cli-tool", "/docs/agent/cli/reference/tool")
  moved_page.call("/docs/agent/v3/configuration", "/docs/agent/self-hosted/configure")
  moved_page.call("/docs/agent/v3/debian", "/docs/agent/self-hosted/install/debian")
  moved_page.call("/docs/agent/v3/docker", "/docs/agent/self-hosted/install/docker")
  moved_page.call("/docs/agent/v3/elastic-ci-stack-for-aws", "/docs/agent/self-hosted/aws/elastic-ci-stack")
  moved_page.call("/docs/agent/v3/elastic-ci-stack-for-ec2-mac/autoscaling-mac-metal", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-mac/setup")
  moved_page.call("/docs/agent/v3/elastic-ci-stack-for-ec2-mac/troubleshooting", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-mac/troubleshooting")
  moved_page.call("/docs/agent/v3/elastic-ci-aws", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/setup")
  moved_page.call("/docs/agent/v3/elastic-ci-aws/cloudformation-service-role", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/setup#cloudformation-service-role")
  moved_page.call("/docs/agent/v3/elastic-ci-aws/elastic-ci-stack-overview", "/docs/agent/self-hosted/aws/elastic-ci-stack")
  moved_page.call("/docs/agent/v3/elastic-ci-aws/managing-elastic-ci-stack", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/managing-elastic-ci-stack")
  moved_page.call("/docs/agent/v3/elastic-ci-aws/parameters", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/configuration-parameters")
  moved_page.call("/docs/agent/v3/elastic-ci-aws/secrets-bucket", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security#s3-secrets-bucket")
  moved_page.call("/docs/agent/v3/elastic-ci-aws/security", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security")
  moved_page.call("/docs/agent/v3/elastic-ci-aws/troubleshooting", "/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/troubleshooting")
  moved_page.call("/docs/agent/v3/freebsd", "/docs/agent/self-hosted/install/freebsd")
  moved_page.call("/docs/agent/v3/github-ssh-keys", "/docs/agent/self-hosted/code-access#managing-ssh-keys-on-agent-machines-ssh-keys-for-github")
  moved_page.call("/docs/agent/v3/gcp", "/docs/agent/self-hosted/gcp")
  moved_page.call("/docs/agent/v3/gcp/architecture/vpc", "/docs/agent/self-hosted/gcp/architecture/vpc")
  moved_page.call("/docs/agent/v3/gcp/elastic-ci-stack/configuration-parameters", "/docs/agent/self-hosted/gcp/elastic-ci-stack/configuration-parameters")
  moved_page.call("/docs/agent/v3/gcp/elastic-ci-stack/elastic-ci-stack", "/docs/agent/self-hosted/gcp/elastic-ci-stack")
  moved_page.call("/docs/agent/v3/gcp/elastic-ci-stack/terraform", "/docs/agent/self-hosted/gcp/elastic-ci-stack/terraform")
  moved_page.call("/docs/agent/v3/gcp/elastic-ci-stack/troubleshooting", "/docs/agent/self-hosted/gcp/elastic-ci-stack/troubleshooting")
  moved_page.call("/docs/agent/v3/git-mirrors", "/docs/agent/self-hosted/configure/git-mirrors")
  moved_page.call("/docs/agent/v3/installation", "/docs/agent/self-hosted/install")
  moved_page.call("/docs/agent/v3/linux", "/docs/agent/self-hosted/install/linux")
  moved_page.call("/docs/agent/v3/macos", "/docs/agent/self-hosted/install/macos")
  moved_page.call("/docs/agent/v3/monitoring", "/docs/agent/self-hosted/monitoring-and-observability")
  moved_page.call("/docs/agent/v3/osx", "/docs/agent/self-hosted/install/macos")
  moved_page.call("/docs/agent/v3/prioritization", "/docs/agent/self-hosted/prioritization")
  moved_page.call("/docs/agent/v3/queues/managing/pausing-and-resuming", "/docs/agent/self-hosted/pausing-and-resuming")
  moved_page.call("/docs/agent/v3/redhat", "/docs/agent/self-hosted/install/redhat")
  moved_page.call("/docs/agent/v3/securing", "/docs/agent/self-hosted/security")
  moved_page.call("/docs/agent/v3/self-hosted/hooks", "/docs/agent/hooks")
  moved_page.call("/docs/agent/v3/self-hosted/monitoring", "/docs/agent/self-hosted/monitoring-and-observability")
  moved_page.call("/docs/agent/v3/self-hosted/signed-pipelines", "/docs/agent/self-hosted/security/signed-pipelines")
  moved_page.call("/docs/agent/v3/self-hosted/unclustered-tokens", "/docs/agent/self-hosted/tokens#working-with-unclustered-agent-tokens")
  moved_page.call("/docs/agent/v3/self-hosted/tracing", "/docs/agent/self-hosted/monitoring-and-observability/tracing")
  moved_page.call("/docs/agent/v3/signed-pipelines", "/docs/agent/self-hosted/security/signed-pipelines")
  moved_page.call("/docs/agent/v3/tracing", "/docs/agent/self-hosted/monitoring-and-observability/tracing")
  moved_page.call("/docs/agent/v3/ubuntu", "/docs/agent/self-hosted/install/ubuntu")
  moved_page.call("/docs/agent/v3/windows", "/docs/agent/self-hosted/install/windows")
  moved_page.call("/docs/agent/v3/build-artifacts", "/docs/agent/cli/reference/artifact")
  moved_page.call("/docs/agent/v3/pausing-and-resuming", "/docs/agent/self-hosted/pausing-and-resuming")
  moved_page.call("/docs/agent/v3/plugins", "/docs/pipelines/integrations/plugins")
  moved_page.call("/docs/agent/v3/self-hosted/github-ssh-keys", "/docs/agent/self-hosted/code-access#managing-ssh-keys-on-agent-machines-ssh-keys-for-github")
  moved_page.call("/docs/agent/v3/self-hosted/ssh-keys", "/docs/agent/self-hosted/code-access")
  moved_page.call("/docs/agent/v3/ssh-keys", "/docs/agent/self-hosted/code-access")
  moved_page.call("/docs/agent/v3/tokens", "/docs/agent/self-hosted/tokens")
  moved_page.call("/docs/agent/v3/unclustered-tokens", "/docs/agent/self-hosted/tokens#working-with-unclustered-agent-tokens")
  moved_page.call("/docs/agent/v3/upgrading", "/docs/agent/self-hosted/install#upgrade-agents")
  moved_page.call("/docs/agent/v3/upgrading-to-v3", "/docs/agent/self-hosted/install#upgrade-agents")
  get "/docs/api",                                                                                   to: redirect("/docs/apis/rest-api")
  get "/docs/api/accounts",                                                                          to: redirect("/docs/apis/rest-api/organizations")
  get "/docs/api/organizations",                                                                     to: redirect("/docs/apis/rest-api/organizations")
  get "/docs/api/projects",                                                                          to: redirect("/docs/apis/rest-api/pipelines")

  # Resolve moved REST API namespaces before the broader legacy prefix redirects.
  %w[/docs/api /docs/rest-api /docs/apis/rest-api].each do |prefix|
    get "#{prefix}/analytics/flaky-tests",   to: redirect("/docs/apis/rest-api/test-engine/tests#list-tests")
    get "#{prefix}/limits",                 to: redirect("/docs/apis/rest-api/rate-limits")
    get "#{prefix}/test-engine/flaky-tests", to: redirect("/docs/apis/rest-api/test-engine/tests#list-tests")
  end

  get "/docs/apis/graphql/cookbooks/packages",                                                       to: redirect("/docs/apis/graphql/cookbooks/registries")
  get "/docs/apis/graphql-tutorial",                                                                 to: redirect("/docs/apis/graphql/graphql-tutorial")
  get "/docs/apis/graphql",                                                                          to: redirect("/docs/apis/graphql-api")
  get "/docs/apis/graphql/schemas",                                                                  to: redirect("/docs/apis/graphql-api")
  get "/docs/apis/graphql/schemas/query",                                                            to: redirect("/docs/apis/graphql-api")
  get "/docs/apis/graphql/schemas/mutation",                                                         to: redirect("/docs/apis/graphql-api")
  get "/docs/apis/graphql/schemas/object",                                                           to: redirect("/docs/apis/graphql-api")
  get "/docs/apis/graphql/schemas/scalar",                                                           to: redirect("/docs/apis/graphql-api")
  get "/docs/apis/graphql/schemas/interface",                                                        to: redirect("/docs/apis/graphql-api")
  get "/docs/apis/graphql/schemas/enum",                                                             to: redirect("/docs/apis/graphql-api")
  get "/docs/apis/graphql/schemas/input-object",                                                     to: redirect("/docs/apis/graphql-api")
  get "/docs/apis/graphql/schemas/union",                                                            to: redirect("/docs/apis/graphql-api")
  get "/docs/apis/mcp-server/toolsets",                                                              to: redirect("/docs/apis/mcp-server/tools/toolsets")
  get "/docs/apis/portals",                                                                          to: redirect("/docs/apis/graphql/portals")
  get "/docs/apis/portals/ephemeral-portal-tokens",                                                  to: redirect("/docs/apis/graphql/portals/ephemeral-portal-tokens")
  get "/docs/apis/portals/limits",                                                                   to: redirect("/docs/apis/graphql/portals/limits")
  get "/docs/apis/portals/user-invoked-portals",                                                     to: redirect("/docs/apis/graphql/portals/user-invoked-portals")
  %w[agent-events agent-token-events build-events integrations job-events ping-events].each do |page|
    get "/docs/apis/webhooks/#{page}", to: redirect("/docs/apis/webhooks/pipelines/#{page}")
    get "/docs/webhooks/#{page}",      to: redirect("/docs/apis/webhooks/pipelines/#{page}")
  end

  get "/docs/basics/pipelines",                                                                      to: redirect("/docs/pipelines")
  get "/docs/builds",                                                                                to: redirect("/docs/pipelines/getting-started")
  get "/docs/builds/artifacts",                                                                      to: redirect("/docs/pipelines/configure/artifacts")
  get "/docs/builds/parallelizing-builds",                                                           to: redirect("/docs/pipelines/best-practices/parallel-builds")
  get "/docs/builds/scheduled-builds",                                                               to: redirect("/docs/pipelines/configure/workflows/scheduled-builds")
  get "/docs/builds/build-status-badges",                                                            to: redirect("/docs/pipelines/integrations/other/build-status-badges")
  get "/docs/builds/cc-menu",                                                                        to: redirect("/docs/pipelines/integrations/notifications/cc-menu")
  get "/docs/builds/docker-containerized-builds",                                                    to: redirect("/docs/pipelines/best-practices/docker-containerized-builds")
  get "/docs/cli",                                                                                   to: redirect("/docs/platform/cli")
  get "/docs/clusters/overview",                                                                     to: redirect("/docs/pipelines/security/clusters")
  get "/docs/clusters/manage-clusters",                                                              to: redirect("/docs/pipelines/security/clusters/manage")
  get "/docs/clusters/manage-queues",                                                                to: redirect("/docs/agent/queues/managing")
  get "/docs/clusters/queue-metrics",                                                                to: redirect("/docs/pipelines/insights/queue-metrics")
  get "/docs/deployments",                                                                           to: redirect("/docs/pipelines/deployments")
  get "/docs/deployments/deploying-to-heroku",                                                       to: redirect("/docs/pipelines/deployments/with-heroku")
  get "/docs/deployments/deploying-to-kubernetes",                                                   to: redirect("/docs/pipelines/deployments/to-kubernetes")
  get "/docs/guides/artifacts",                                                                      to: redirect("/docs/pipelines/configure/artifacts")
  get "/docs/guides/branch-configuration",                                                           to: redirect("/docs/pipelines/configure/workflows/branch-configuration")
  get "/docs/guides/build-meta-data",                                                                to: redirect("/docs/pipelines/configure/build-meta-data")
  get "/docs/guides/build-status-badges",                                                            to: redirect("/docs/pipelines/integrations/other/build-status-badges")
  get "/docs/guides/cc-menu",                                                                        to: redirect("/docs/pipelines/integrations/notifications/cc-menu")
  get "/docs/guides/collapsing-build-output",                                                        to: redirect("/docs/pipelines/configure/managing-log-output#grouping-log-output-collapsed-groups")
  get "/docs/guides/controlling-concurrency",                                                        to: redirect("/docs/pipelines/configure/workflows/controlling-concurrency")
  get "/docs/guides/deploying-to-heroku",                                                            to: redirect("/docs/pipelines/deployments/with-heroku")
  get "/docs/guides/docker-containerized-builds",                                                    to: redirect("/docs/pipelines/best-practices/docker-containerized-builds")
  get "/docs/guides/elastic-ci-stack-aws",                                                           to: redirect("/docs/agent/self-hosted/aws/elastic-ci-stack")
  get "/docs/guides/environment-variables",                                                          to: redirect("/docs/pipelines/configure/environment-variables")
  get "/docs/guides/getting-started",                                                                to: redirect("/docs/pipelines/getting-started")
  get "/docs/guides/github-enterprise",                                                              to: redirect("/docs/pipelines/source-control/github-enterprise")
  get "/docs/guides/github-repo-access",                                                             to: redirect("/docs/agent/self-hosted/code-access#managing-ssh-keys-on-agent-machines-ssh-keys-for-github")
  get "/docs/guides/gitlab",                                                                         to: redirect("/docs/pipelines/source-control/gitlab")
  get "/docs/guides/images-in-build-output",                                                         to: redirect("/docs/pipelines/configure/links-and-images-in-log-output")
  get "/docs/guides/managing-log-output",                                                            to: redirect("/docs/pipelines/configure/managing-log-output")
  get "/docs/guides/migrating-from-bamboo",                                                          to: redirect("/docs/pipelines/migration/from-bamboo")
  get "/docs/guides/parallelizing-builds",                                                           to: redirect("/docs/pipelines/best-practices/parallel-builds")
  get "/docs/guides/skipping-a-build",                                                               to: redirect("/docs/pipelines/configure/skipping#ignore-a-commit")
  get "/docs/guides/uploading-pipelines",                                                            to: redirect("/docs/pipelines/configure/defining-steps")
  get "/docs/guides/writing-build-scripts",                                                          to: redirect("/docs/pipelines/configure/writing-build-scripts")
  get "/docs/graphql-api",                                                                           to: redirect("/docs/apis/graphql-api")
  get "/docs/graphql",                                                                               to: redirect("/docs/apis/graphql-api")
  get "/docs/how-tos",                                                                               to: redirect("/docs/pipelines/getting-started")
  get "/docs/how-tos/bitbucket",                                                                     to: redirect("/docs/pipelines/source-control/bitbucket")
  get "/docs/how-tos/github-enterprise",                                                             to: redirect("/docs/pipelines/source-control/github-enterprise")
  get "/docs/how-tos/gitlab",                                                                        to: redirect("/docs/pipelines/source-control/gitlab")
  get "/docs/how-tos/deploying-to-heroku",                                                           to: redirect("/docs/pipelines/deployments/with-heroku")
  get "/docs/how-tos/migrating-from-bamboo",                                                         to: redirect("/docs/pipelines/migration/from-bamboo")
  get "/docs/integrations",                                                                          to: redirect("/docs/pipelines/integrations")
  get "/docs/integrations/amazon-eventbridge",                                                       to: redirect("/docs/pipelines/integrations/observability/amazon-eventbridge")
  get "/docs/integrations/artifactory",                                                              to: redirect("/docs/pipelines/integrations/artifacts-and-packages/artifactory")
  get "/docs/integrations/bitbucket",                                                                to: redirect("/docs/pipelines/source-control/bitbucket")
  get "/docs/integrations/bitbucket-server",                                                         to: redirect("/docs/pipelines/source-control/bitbucket-server")
  get "/docs/integrations/build-status-badges",                                                      to: redirect("/docs/pipelines/integrations/other/build-status-badges")
  get "/docs/integrations/cc-menu",                                                                  to: redirect("/docs/pipelines/integrations/notifications/cc-menu")
  get "/docs/integrations/docker-hub",                                                               to: redirect("/docs/pipelines/integrations/other/docker-hub")
  get "/docs/integrations/git",                                                                      to: redirect("/docs/pipelines/source-control/git")
  get "/docs/integrations/github",                                                                   to: redirect("/docs/pipelines/source-control/github")
  get "/docs/integrations/github-enterprise",                                                        to: redirect("/docs/pipelines/source-control/github-enterprise")
  get "/docs/integrations/gitlab",                                                                   to: redirect("/docs/pipelines/source-control/gitlab")
  get "/docs/integrations/pagerduty",                                                                to: redirect("/docs/pipelines/integrations/notifications/pagerduty")
  get "/docs/integrations/phabricator",                                                              to: redirect("/docs/pipelines/source-control/phabricator")
  get "/docs/integrations/slack",                                                                    to: redirect("/docs/pipelines/integrations/notifications/slack")
  get "/docs/integrations/slack-workspace",                                                          to: redirect("/docs/pipelines/integrations/notifications/slack-workspace")
  get "/docs/integrations/source-control",                                                           to: redirect("/docs/pipelines/source-control")
  get "/docs/integrations/sso",                                                                      to: redirect("/docs/platform/sso")
  get "/docs/integrations/sso/google-oauth",                                                         to: redirect("/docs/platform/sso/google-workspace")
  get "/docs/integrations/sso/g-suite",                                                              to: redirect("/docs/platform/sso/google-workspace")
  get "/docs/integrations/sso/cloud-identity",                                                       to: redirect("/docs/platform/sso/google-workspace-saml")
  get "/docs/integrations/sso/g-cloud-identity",                                                     to: redirect("/docs/platform/sso/google-workspace-saml")
  moved_page.call("/docs/package-registries/alpine", "/docs/package-registries/ecosystems/alpine")
  moved_page.call("/docs/package-registries/container", "/docs/package-registries/ecosystems/oci")
  moved_page.call("/docs/package-registries/debian", "/docs/package-registries/ecosystems/debian")
  moved_page.call("/docs/package-registries/ecosystems/container", "/docs/package-registries/ecosystems/oci")
  moved_page.call("/docs/package-registries/files", "/docs/package-registries/ecosystems/files")
  moved_page.call("/docs/package-registries/gradle-groovy", "/docs/package-registries/ecosystems/gradle-groovy")
  moved_page.call("/docs/package-registries/gradle-kotlin", "/docs/package-registries/ecosystems/gradle-kotlin")
  moved_page.call("/docs/package-registries/gradle", "/docs/package-registries/ecosystems/gradle-groovy")
  moved_page.call("/docs/package-registries/helm-oci", "/docs/package-registries/ecosystems/helm-oci")
  moved_page.call("/docs/package-registries/helm", "/docs/package-registries/ecosystems/helm")
  moved_page.call("/docs/package-registries/hugging-face", "/docs/package-registries/ecosystems/hugging-face")
  moved_page.call("/docs/package-registries/javascript", "/docs/package-registries/ecosystems/javascript")
  moved_page.call("/docs/package-registries/manage-registries", "/docs/package-registries/registries/manage")
  moved_page.call("/docs/package-registries/maven", "/docs/package-registries/ecosystems/maven")
  moved_page.call("/docs/package-registries/private-storage", "/docs/package-registries/registries/private-storage-link")
  moved_page.call("/docs/package-registries/private-storage-link", "/docs/package-registries/registries/private-storage-link")
  moved_page.call("/docs/package-registries/private-storage-link/amazon-s3", "/docs/package-registries/registries/private-storage-link/amazon-s3")
  moved_page.call("/docs/package-registries/private-storage-link/google-cloud-storage", "/docs/package-registries/registries/private-storage-link/google-cloud-storage")
  moved_page.call("/docs/package-registries/python", "/docs/package-registries/ecosystems/python")
  moved_page.call("/docs/package-registries/red-hat", "/docs/package-registries/ecosystems/red-hat")
  moved_page.call("/docs/package-registries/ruby", "/docs/package-registries/ecosystems/ruby")
  moved_page.call("/docs/package-registries/terraform", "/docs/package-registries/ecosystems/terraform")
  get "/docs/packages",                                                                              to: redirect("/docs/package-registries")
  get "/docs/packages/manage-repositories",                                                          to: redirect("/docs/package-registries/registries/manage")
  get "/docs/packages/nodejs",                                                                       to: redirect("/docs/package-registries/ecosystems/javascript")
  get "/docs/packages/permissions",                                                                  to: redirect("/docs/package-registries/security/permissions")
  get "/docs/packages/python",                                                                       to: redirect("/docs/package-registries/ecosystems/python")
  moved_page.call("/docs/pipelines/advantages/pipelines-advantages", "/docs/pipelines/advantages/buildkite-pipelines")
  moved_page.call("/docs/pipelines/archiving-and-deleting-pipelines", "/docs/pipelines/configure/workflows/archiving-and-deleting-pipelines")
  moved_page.call("/docs/pipelines/artifacts", "/docs/pipelines/configure/artifacts")
  moved_page.call("/docs/pipelines/audit-log", "/docs/platform/audit-log")
  moved_page.call("/docs/pipelines/best-practices/overview", "/docs/pipelines/best-practices")
  moved_page.call("/docs/pipelines/best-practices/secrets-management", "/docs/platform/security/checklist#secrets-management")
  moved_page.call("/docs/pipelines/best-practices/security-controls", "/docs/platform/security/checklist")
  moved_page.call("/docs/pipelines/block-step", "/docs/pipelines/configure/step-types/block-step")
  moved_page.call("/docs/pipelines/block-step-example", "/docs/pipelines/configure/step-types/block-step")
  moved_page.call("/docs/pipelines/buildkite-sdk", "/docs/pipelines/configure/dynamic-pipelines/sdk")
  moved_page.call("/docs/pipelines/branch-configuration", "/docs/pipelines/configure/workflows/branch-configuration")
  moved_page.call("/docs/pipelines/build-exports", "/docs/pipelines/governance/build-exports")
  moved_page.call("/docs/pipelines/build-matrix", "/docs/pipelines/configure/workflows/build-matrix")
  moved_page.call("/docs/pipelines/build-meta-data", "/docs/pipelines/configure/build-meta-data")
  moved_page.call("/docs/pipelines/build-retention", "/docs/pipelines/configure/build-retention")
  moved_page.call("/docs/pipelines/build-timeouts", "/docs/pipelines/configure/build-timeouts")
  moved_page.call("/docs/pipelines/clusters", "/docs/pipelines/security/clusters")
  moved_page.call("/docs/pipelines/clusters/manage-clusters", "/docs/pipelines/security/clusters/manage")
  moved_page.call("/docs/pipelines/clusters/migrate-from-unclustered-to-clustered-agents", "/docs/pipelines/security/clusters/migrate-from-unclustered-to-clustered-agents")
  moved_page.call("/docs/pipelines/clusters/queue-metrics", "/docs/pipelines/insights/queue-metrics")
  moved_page.call("/docs/pipelines/cluster-queue-metrics", "/docs/pipelines/insights/queue-metrics")
  moved_page.call("/docs/pipelines/clusters/manage-queues", "/docs/agent/queues/managing")
  moved_page.call("/docs/pipelines/command-step", "/docs/pipelines/configure/step-types/command-step")
  moved_page.call("/docs/pipelines/conditionals", "/docs/pipelines/configure/conditionals")
  moved_page.call("/docs/pipelines/configuration-overview", "/docs/pipelines/configure")
  moved_page.call("/docs/pipelines/configure/dependencies", "/docs/pipelines/configure/depends-on")
  moved_page.call("/docs/pipelines/configure/job-minutes", "https://buildkite.com/pricing/")
  moved_page.call("/docs/pipelines/controlling-concurrency", "/docs/pipelines/configure/workflows/controlling-concurrency")
  moved_page.call("/docs/pipelines/defining-steps", "/docs/pipelines/configure/defining-steps")
  moved_page.call("/docs/pipelines/dependencies", "/docs/pipelines/configure/depends-on")
  moved_page.call("/docs/pipelines/deployments/deployment-plugins", "https://buildkite.com/resources/plugins/category/deploy/")
  moved_page.call("/docs/pipelines/deployments/to-heroku", "/docs/pipelines/deployments/with-heroku")
  moved_page.call("/docs/pipelines/emoji", "/docs/platform/emojis")
  moved_page.call("/docs/pipelines/emojis", "/docs/platform/emojis")
  moved_page.call("/docs/pipelines/example-pipelines", "/docs/pipelines/configure/example-pipelines")
  moved_page.call("/docs/pipelines/environment-variables", "/docs/pipelines/configure/environment-variables")
  moved_page.call("/docs/pipelines/group-step", "/docs/pipelines/configure/step-types/group-step")
  moved_page.call("/docs/pipelines/hosted-agents", "/docs/agent/buildkite-hosted")
  moved_page.call("/docs/pipelines/hosted-agents/cache-volumes", "/docs/agent/buildkite-hosted/cache-volumes")
  moved_page.call("/docs/pipelines/hosted-agents/code-access", "/docs/agent/buildkite-hosted/code-access")
  moved_page.call("/docs/pipelines/hosted-agents/configure-networking", "/docs/agent/buildkite-hosted/network-security")
  moved_page.call("/docs/pipelines/hosted-agents/internal-container-registries", "/docs/agent/buildkite-hosted/internal-container-registry")
  moved_page.call("/docs/pipelines/hosted-agents/internal-container-registry", "/docs/agent/buildkite-hosted/internal-container-registry")
  moved_page.call("/docs/pipelines/hosted-agents/linux", "/docs/agent/buildkite-hosted/linux")
  moved_page.call("/docs/pipelines/hosted-agents/mac", "/docs/agent/buildkite-hosted/macos")
  moved_page.call("/docs/pipelines/hosted-agents/macos", "/docs/agent/buildkite-hosted/macos")
  moved_page.call("/docs/pipelines/hosted-agents/macos/getting-started-with-ios", "/docs/agent/buildkite-hosted/macos/getting-started-with-ios")
  moved_page.call("/docs/pipelines/hosted-agents/macos/troubleshooting-fastlane", "/docs/agent/buildkite-hosted/macos/troubleshooting-fastlane")
  moved_page.call("/docs/pipelines/hosted-agents/mobile-delivery-cloud", "/docs/agent/buildkite-hosted/macos")
  moved_page.call("/docs/pipelines/hosted-agents/mobile-delivery-cloud/getting-started", "/docs/agent/buildkite-hosted/macos/getting-started-with-ios")
  moved_page.call("/docs/pipelines/hosted-agents/mobile-delivery-cloud/troubleshooting-fastlane", "/docs/agent/buildkite-hosted/macos/troubleshooting-fastlane")
  moved_page.call("/docs/pipelines/hosted-agents/network-security", "/docs/agent/buildkite-hosted/network-security")
  moved_page.call("/docs/pipelines/hosted-agents/overview", "/docs/agent/buildkite-hosted")
  moved_page.call("/docs/pipelines/hosted-agents/pipeline-migration", "/docs/agent/buildkite-hosted/pipeline-migration")
  moved_page.call("/docs/pipelines/hosted-agents/remote-docker-builders", "/docs/agent/buildkite-hosted/linux/remote-docker-builders")
  moved_page.call("/docs/pipelines/hosted-agents/terminal-access", "/docs/agent/buildkite-hosted/terminal-access")
  moved_page.call("/docs/pipelines/ignoring-a-commit", "/docs/pipelines/configure/skipping#ignore-a-commit")
  moved_page.call("/docs/pipelines/images-in-log-output", "/docs/pipelines/configure/links-and-images-in-log-output")
  moved_page.call("/docs/pipelines/incoming-webhooks", "/docs/pipelines/security/incoming-webhooks")
  moved_page.call("/docs/pipelines/input-step", "/docs/pipelines/configure/step-types/input-step")
  moved_page.call("/docs/pipelines/integrations/artifacts-and-packages/artifact-plugins", "https://buildkite.com/resources/plugins/category/artifacts/")
  moved_page.call("/docs/pipelines/integrations/artifacts-and-packages/package-plugins", "https://buildkite.com/resources/plugins/category/packages/")
  moved_page.call("/docs/pipelines/integrations/notifications/plugins", "https://buildkite.com/resources/plugins/category/notify/")
  moved_page.call("/docs/pipelines/integrations/observability/plugins", "https://buildkite.com/resources/plugins/category/observability/")
  moved_page.call("/docs/pipelines/integrations/security-and-compliance/plugins", "https://buildkite.com/resources/plugins/category/security-compliance/")
  moved_page.call("/docs/pipelines/integrations/secrets/plugins", "https://buildkite.com/resources/plugins/category/secrets/")
  moved_page.call("/docs/pipelines/integrations/other/amazon-eventbridge", "/docs/pipelines/integrations/observability/amazon-eventbridge")
  moved_page.call("/docs/pipelines/integrations/other/cc-menu", "/docs/pipelines/integrations/notifications/cc-menu")
  moved_page.call("/docs/pipelines/integrations/other/artifactory", "/docs/pipelines/integrations/artifacts-and-packages/artifactory")
  moved_page.call("/docs/pipelines/integrations/other/pagerduty", "/docs/pipelines/integrations/notifications/pagerduty")
  moved_page.call("/docs/pipelines/integrations/other/slack", "/docs/pipelines/integrations/notifications/slack")
  moved_page.call("/docs/pipelines/integrations/other/slack-workspace", "/docs/pipelines/integrations/notifications/slack-workspace")
  moved_page.call("/docs/pipelines/job-minutes", "https://buildkite.com/pricing/")
  moved_page.call("/docs/pipelines/links-and-images-in-log-output", "/docs/pipelines/configure/links-and-images-in-log-output")
  moved_page.call("/docs/pipelines/managing-log-output", "/docs/pipelines/configure/managing-log-output")
  moved_page.call("/docs/pipelines/managing-priorities", "/docs/pipelines/configure/workflows/job-priority")
  moved_page.call("/docs/pipelines/configure/workflows/managing-priorities", "/docs/pipelines/configure/workflows/job-priority")
  moved_page.call("/docs/pipelines/model-providers", "/docs/apis/model-providers")
  moved_page.call("/docs/pipelines/migrate-from-jenkins", "/docs/pipelines/migration/from-jenkins")
  moved_page.call("/docs/pipelines/migration/converter", "/docs/pipelines/converter")
  moved_page.call("/docs/pipelines/migration/converter/bitbucket-pipelines", "/docs/pipelines/converter/bitbucket-pipelines")
  moved_page.call("/docs/pipelines/migration/converter/circleci", "/docs/pipelines/converter/circleci")
  moved_page.call("/docs/pipelines/migration/converter/github-actions", "/docs/pipelines/converter/github-actions")
  moved_page.call("/docs/pipelines/migration/converter/jenkins", "/docs/pipelines/converter/jenkins")
  moved_page.call("/docs/pipelines/migration/pipeline-converter", "/docs/pipelines/converter")
  moved_page.call("/docs/pipelines/migration/tool", "/docs/pipelines/converter")
  moved_page.call("/docs/pipelines/migration/tool/bitbucket-pipelines", "/docs/pipelines/converter/bitbucket-pipelines")
  moved_page.call("/docs/pipelines/migration/tool/circleci", "/docs/pipelines/converter/circleci")
  moved_page.call("/docs/pipelines/migration/tool/github-actions", "/docs/pipelines/converter/github-actions")
  moved_page.call("/docs/pipelines/migration/tool/jenkins", "/docs/pipelines/converter/jenkins")
  moved_page.call("/docs/pipelines/migration-overview", "/docs/pipelines/migration")
  moved_page.call("/docs/pipelines/my-builds", "/docs/pipelines/dashboard-walkthrough")
  moved_page.call("/docs/pipelines/notifications", "/docs/pipelines/configure/notify")
  moved_page.call("/docs/pipelines/configure/notifications", "/docs/pipelines/configure/notify")
  moved_page.call("/docs/pipelines/parallel-builds", "/docs/pipelines/best-practices/parallel-builds")
  moved_page.call("/docs/pipelines/permissions", "/docs/pipelines/security/permissions")
  moved_page.call("/docs/pipelines/pipelines", "/docs/pipelines")
  moved_page.call("/docs/pipelines/plugins", "/docs/pipelines/integrations/plugins")
  moved_page.call("/docs/pipelines/public-pipelines", "/docs/pipelines/configure/public-pipelines")
  moved_page.call("/docs/pipelines/rules", "/docs/pipelines/security/clusters/rules")
  moved_page.call("/docs/pipelines/rules/manage", "/docs/pipelines/security/clusters/rules/manage")
  moved_page.call("/docs/pipelines/scheduled-builds", "/docs/pipelines/configure/workflows/scheduled-builds")
  moved_page.call("/docs/pipelines/secrets", "/docs/pipelines/security/secrets/managing")
  moved_page.call("/docs/pipelines/security", "/docs/platform/security")
  moved_page.call("/docs/pipelines/security/overview", "/docs/platform/security")
  moved_page.call("/docs/pipelines/security-overview", "/docs/platform/security")
  moved_page.call("/docs/pipelines/security/audit-log", "/docs/platform/audit-log")
  moved_page.call("/docs/pipelines/security/enforcing-security-controls", "/docs/platform/security/checklist")
  moved_page.call("/docs/pipelines/security/managing-secrets", "/docs/pipelines/security/secrets/managing")
  get "/docs/platform/security/best-practices",                                                       to: redirect("/docs/platform/security/checklist")
  moved_page.call("/docs/pipelines/skipping", "/docs/pipelines/configure/skipping")
  moved_page.call("/docs/pipelines/step-reference", "/docs/pipelines/configure/step-types")
  moved_page.call("/docs/pipelines/tags", "/docs/pipelines/configure/tags")
  moved_page.call("/docs/pipelines/templates", "/docs/pipelines/governance/templates")
  moved_page.call("/docs/pipelines/tutorials/customizing-slack-notifications", "/docs/pipelines/integrations/notifications/slack-workspace#customizing-notifications")
  moved_page.call("/docs/pipelines/tutorials/parallel-builds", "/docs/pipelines/best-practices/parallel-builds")
  moved_page.call("/docs/pipelines/tutorials/docker-containerized-builds", "/docs/pipelines/best-practices/docker-containerized-builds")
  moved_page.call("/docs/pipelines/trigger-step", "/docs/pipelines/configure/step-types/trigger-step")
  moved_page.call("/docs/pipelines/triggers", "/docs/apis/webhooks/incoming/pipeline-triggers")
  moved_page.call("/docs/pipelines/uploading-pipelines", "/docs/pipelines/configure/defining-steps")
  moved_page.call("/docs/pipelines/wait-step", "/docs/pipelines/configure/step-types/wait-step")
  moved_page.call("/docs/pipelines/waterfall", "/docs/pipelines/insights/waterfall")
  moved_page.call("/docs/pipelines/writing-build-scripts", "/docs/pipelines/configure/writing-build-scripts")
  get "/docs/platform/service-quotas",                                                               to: redirect("/docs/platform/limits")
  get "/docs/plugins",                                                                               to: redirect("/docs/pipelines/integrations/plugins")
  get "/docs/plugins/using",                                                                         to: redirect("/docs/pipelines/integrations/plugins/using")
  get "/docs/plugins/directory",                                                                     to: redirect("/docs/pipelines/integrations/plugins/directory")
  get "/docs/plugins/tools",                                                                         to: redirect("/docs/pipelines/integrations/plugins/writing#plugin-tools")
  get "/docs/plugins/writing",                                                                       to: redirect("/docs/pipelines/integrations/plugins/writing")
  get "/docs/projects",                                                                              to: redirect("/docs/pipelines")
  get "/docs/rest-api",                                                                              to: redirect("/docs/apis/rest-api")
  get "/docs/team-management",                                                                       to: redirect("/docs/platform/team-management")
  get "/docs/test-analytics/js-collectors",                                                          to: redirect("/docs/pipelines/configure/tests/test-collection/javascript-collectors")

  %w[/docs/quickstart /docs/tutorials].each do |prefix|
    get "#{prefix}/2fa",                          to: redirect("/docs/platform/tutorials/2fa")
    get "#{prefix}/custom-saml",                  to: redirect("/docs/platform/sso/custom-saml")
    get "#{prefix}/deploying-to-heroku",          to: redirect("/docs/pipelines/deployments/with-heroku")
    get "#{prefix}/elastic-ci-stack-aws",         to: redirect("/docs/agent/self-hosted/aws/elastic-ci-stack")
    get "#{prefix}/getting-started",              to: redirect("/docs/pipelines/getting-started")
    get "#{prefix}/migrating-from-bamboo",        to: redirect("/docs/pipelines/migration/from-bamboo")
    get "#{prefix}/sso-setup-with-graphql",       to: redirect("/docs/platform/sso/sso-setup-with-graphql")

    %w[bazel github-actions github-merge-queue pipeline-upgrade].each do |page|
      get "#{prefix}/#{page}", to: redirect("/docs/pipelines/tutorials/#{page}")
    end
    %w[bitbucket github-enterprise gitlab].each do |page|
      get "#{prefix}/#{page}", to: redirect("/docs/pipelines/source-control/#{page}")
    end
    %w[docker-containerized-builds parallel-builds].each do |page|
      get "#{prefix}/#{page}", to: redirect("/docs/pipelines/best-practices/#{page}")
    end
  end

  get "/docs/webhooks/setup",                                                                        to: redirect("/docs/apis/webhooks")
  get "/docs/webhooks",                                                                              to: redirect("/docs/apis/webhooks")

  # Doc sections that don't have overview/index pages, so need redirecting
  get "/docs/tutorials",                 to: redirect("/docs/pipelines/getting-started"), status: 302

  # The old un-versioned URLs redirect to the current agent docs paths.
  moved_page.call("/docs/agent/installation", "/docs/agent/self-hosted/install")
  moved_page.call("/docs/agent/ubuntu", "/docs/agent/self-hosted/install/ubuntu")
  moved_page.call("/docs/agent/debian", "/docs/agent/self-hosted/install/debian")
  moved_page.call("/docs/agent/redhat", "/docs/agent/self-hosted/install/redhat")
  moved_page.call("/docs/agent/freebsd", "/docs/agent/self-hosted/install/freebsd")
  moved_page.call("/docs/agent/osx", "/docs/agent/self-hosted/install/macos")
  moved_page.call("/docs/agent/windows", "/docs/agent/self-hosted/install/windows")
  moved_page.call("/docs/agent/linux", "/docs/agent/self-hosted/install/linux")
  moved_page.call("/docs/agent/docker", "/docs/agent/self-hosted/install/docker")
  moved_page.call("/docs/agent/aws", "/docs/agent/self-hosted/aws")
  moved_page.call("/docs/agent/gcloud", "/docs/agent/self-hosted/gcp")
  moved_page.call("/docs/agent/configuration", "/docs/agent/self-hosted/configure")
  moved_page.call("/docs/agent/ssh-keys", "/docs/agent/self-hosted/code-access")
  moved_page.call("/docs/agent/github-ssh-keys", "/docs/agent/self-hosted/code-access#managing-ssh-keys-on-agent-machines-ssh-keys-for-github")
  moved_page.call("/docs/agent/prioritization", "/docs/agent/self-hosted/prioritization")
  moved_page.call("/docs/agent/plugins", "/docs/pipelines/integrations/plugins")
  moved_page.call("/docs/agent/securing", "/docs/agent/self-hosted/security")
  moved_page.call("/docs/agent/cli-start", "/docs/agent/cli/reference/start")
  moved_page.call("/docs/agent/cli-meta-data", "/docs/agent/cli/reference/meta-data")
  moved_page.call("/docs/agent/cli-artifact", "/docs/agent/cli/reference/artifact")
  moved_page.call("/docs/agent/cli-pipeline", "/docs/agent/cli/reference/pipeline")
  moved_page.call("/docs/agent/agent-meta-data", "/docs/agent/cli/reference/start#setting-metadata")
  moved_page.call("/docs/agent/artifacts", "/docs/agent/cli/reference/artifact")
  moved_page.call("/docs/agent/build-artifacts", "/docs/agent/cli/reference/artifact")
  moved_page.call("/docs/agent/build-meta-data", "/docs/agent/cli/reference/meta-data")
  moved_page.call("/docs/agent/build-pipelines", "/docs/agent/cli/reference/pipeline")
  moved_page.call("/docs/agent/uploading-pipelines", "/docs/agent/cli/reference/pipeline")
  moved_page.call("/docs/agent/upgrading", "/docs/agent/self-hosted/install#upgrade-agents")
  moved_page.call("/docs/agent/upgrading-to-v3", "/docs/agent/self-hosted/install#upgrade-agents")
  get "/docs/clusters/queue-metrics",    to: redirect("/docs/pipelines/insights/queue-metrics",                  status: 301)

  # Old docs routes that we changed around during the development of the v3 agent docs
  moved_page.call("/docs/agent/upgrading-to-v2", "/docs/agent")
  moved_page.call("/docs/agent/v2/plugins", "/docs/pipelines/integrations/plugins")
  moved_page.call("/docs/agent/v2/agent-meta-data", "/docs/agent/cli/reference/start#setting-tags")
  get "/docs/agent/v2(/*path)",         to: redirect("/docs/agent",                                    status: 301)

  # Both former Test Engine namespaces lead directly to the same current pages.
  tests_path = "/docs/pipelines/configure/tests"
  %w[/docs/test-analytics /docs/test-engine].each do |prefix|
    get prefix, to: redirect(tests_path)
    get "#{prefix}/usage-and-billing",      to: redirect(tests_path)
    get "#{prefix}/glossary",               to: redirect("/docs/pipelines/glossary")
    get "#{prefix}/integrations/linear",    to: redirect("/docs/pipelines/integrations/notifications/linear")
    get "#{prefix}/notifications/email",   to: redirect("#{tests_path}/notifications/email")
    get "#{prefix}/notifications/slack",   to: redirect("#{tests_path}/workflows/actions#send-slack-notification")
    get "#{prefix}/permissions",           to: redirect("/docs/platform/team-management/permissions")
    get "#{prefix}/test-suites/permissions", to: redirect("/docs/platform/team-management/permissions")
    get "#{prefix}/webhooks",              to: redirect("/docs/apis/webhooks/test-engine")

    %w[getting-started manage-test-suites test-suites/manage tutorials/setting-up-a-ruby-project].each do |page|
      get "#{prefix}/#{page}", to: redirect("/docs/pipelines/getting-started#add-a-test-suite")
    end
    %w[flaky-test-management test-suite/flaky-test-management reduce-flaky-tests].each do |page|
      get "#{prefix}/#{page}", to: redirect("/docs/pipelines/reduce-flaky-tests")
    end
    %w[test-splitting speed-up-builds-with-bktec].each do |page|
      get "#{prefix}/#{page}", to: redirect("/docs/pipelines/speed-up-builds-with-bktec")
    end
    %w[bktec/configuring bktec/installing-the-client bktec/installing-and-using-the-client test-splitting/client-installation test-splitting/configuring].each do |page|
      get "#{prefix}/#{page}", to: redirect("#{tests_path}/bktec/installing-and-using-the-client")
    end
    %w[test-collection test-suites workflows workflows/monitors workflows/actions].each do |page|
      get "#{prefix}/#{page}", to: redirect("#{tests_path}/#{page}")
    end
    %w[android-collectors ci-environments dotnet-collectors elixir-collectors golang-collectors importing-json importing-junit-xml javascript-collectors other-collectors python-collectors ruby-collectors rust-collectors swift-collectors your-own-collectors].each do |page|
      get "#{prefix}/#{page}",                 to: redirect("#{tests_path}/test-collection/#{page}")
      get "#{prefix}/test-collection/#{page}", to: redirect("#{tests_path}/test-collection/#{page}")
    end
    %w[labels saved-views tags test-ownership test-state-and-quarantine].each do |page|
      get "#{prefix}/#{page}",             to: redirect("#{tests_path}/test-suites/#{page}")
      get "#{prefix}/test-suites/#{page}", to: redirect("#{tests_path}/test-suites/#{page}")
    end
    get "#{prefix}/flaky-test-assignment", to: redirect("#{tests_path}/test-suites/test-ownership")
    get "#{prefix}/java",                  to: redirect("#{tests_path}/test-collection/importing-junit-xml")
    get "#{prefix}/public-test-suites",    to: redirect("#{tests_path}/test-suites")
    get "#{prefix}/test-suites/public",    to: redirect("#{tests_path}/test-suites")
    get "#{prefix}/quarantine",            to: redirect("#{tests_path}/test-suites/test-state-and-quarantine")
  end

  # Pre GA test analytics
  get "/docs/test-analytics/integrations", to: redirect(tests_path, status: 301)

  moved_page.call("/docs/pipelines/test-engine-getting-started", "/docs/pipelines/getting-started#add-a-test-suite")
  moved_page.call("/docs/pipelines/create-your-own", "/docs/pipelines/getting-started#create-your-own-pipeline")
  get "/docs/platform/integrations/slack-workspace",                                               to: redirect("/docs/pipelines/integrations/notifications/slack-workspace")
  moved_page.call("/docs/pipelines/configure/tests/tutorials/setting-up-a-ruby-project", "/docs/pipelines/getting-started#add-a-test-suite")

  # Quick Reference JSON
  get "/docs/quick-reference/pipelines", to: "quick_reference#pipelines", as: :pipelines_quick_reference

  # LLMs.txt
  get "/docs/llms.txt", to: "llm_text#index", defaults: { format: "txt" }
  get "/docs/llms-full.txt", to: "llm_full_text#index", defaults: { format: "txt" }
  get "/docs/llms-:topic.txt", to: "llm_topic_text#show", defaults: { format: "txt" }, constraints: { topic: /[a-z][a-z0-9-]+/ }

  # Homepage
  get "/docs" => "pages#index", as: :home_page, constraints: { format: /html|md/ }

  moved_pages.each do |source, target|
    moved_namespaces.each do |older, newer|
      next unless source.start_with?("#{newer}/")

      # Preserve existing nested v3 aliases, preferring a version-specific move.
      if older == "/docs/agent/v3/v3"
        next if source.start_with?("/docs/agent/v3/")
        next if moved_pages.key?(source.sub(newer, "/docs/agent/v3"))
      end

      get source.sub(newer, older), to: redirect(target)
    end
  end

  # Agent v2 was retired; keep its intentional fallback to the Agent overview.
  get "/docs/agent/v3/v2(/*path)", to: redirect("/docs/agent")

  moved_namespaces.each do |older, newer|
    get "#{older}/*path", to: "pages#show", defaults: { moved_to: newer.delete_prefix("/docs/") }, constraints: { format: /html|md/ }
  end

  # All other standard docs pages
  get "/docs/*path" => "pages#show", as: :docs_page, constraints: { format: /html|md/ }

  # Content Security Policy violations are sent here, and in production the path is handled by buildkite/buildkite. This is a stub response so CSP violations in development don't generate extra noise in the development log
  post "/_csp-violation-reports", to: proc { [201, {}, ['']] }

  # Take us straight to the docs when running standalone
  root to: redirect("/docs")

  # Ensure 404s for unmatched routes are logged by lograge
  get '*unmatched_route', to: 'application#route_not_found'
end
