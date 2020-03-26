Rails.application.routes.draw do
  # Pages and guides that have been renamed (and we don't want to break old URLs)
  get "/docs/api",                                to: redirect("/docs/rest-api")
  get "/docs/api/accounts",                       to: redirect("/docs/rest-api/organizations")
  get "/docs/api/projects",                       to: redirect("/docs/rest-api/pipelines")
  get "/docs/api/*page",                          to: redirect("/docs/rest-api/%{page}")
  get "/docs/basics/pipelines",                   to: redirect("/docs/pipelines")
  get "/docs/builds",                             to: redirect("/docs/tutorials")
  get "/docs/builds/parallelizing-builds",        to: redirect("/docs/tutorials/parallel-builds")
  get "/docs/builds/scheduled-builds",            to: redirect("/docs/pipelines/scheduled-builds")
  get "/docs/builds/build-status-badges",         to: redirect("/docs/integrations/build-status-badges")
  get "/docs/builds/cc-menu",                     to: redirect("/docs/integrations/cc-menu")
  get "/docs/builds/docker-containerized-builds", to: redirect("/docs/tutorials/docker-containerized-builds")
  get "/docs/builds/*page",                       to: redirect("/docs/pipelines/%{page}")
  get "/docs/graphql-api",                        to: redirect("/docs/apis/graphql-api")
  get "/docs/guides/artifacts",                   to: redirect("/docs/pipelines/artifacts")
  get "/docs/guides/branch-configuration",        to: redirect("/docs/pipelines/branch-configuration")
  get "/docs/guides/build-meta-data",             to: redirect("/docs/pipelines/build-meta-data")
  get "/docs/guides/build-status-badges",         to: redirect("/docs/integrations/build-status-badges")
  get "/docs/guides/cc-menu",                     to: redirect("/docs/integrations/cc-menu")
  get "/docs/guides/collapsing-build-output",     to: redirect("/docs/pipelines/managing-log-output#collapsing-output")
  get "/docs/guides/controlling-concurrency",     to: redirect("/docs/pipelines/controlling-concurrency")
  get "/docs/guides/deploying-to-heroku",         to: redirect("/docs/deployments/deploying-to-heroku")
  get "/docs/guides/docker-containerized-builds", to: redirect("/docs/tutorials/docker-containerized-builds")
  get "/docs/guides/elastic-ci-stack-aws",        to: redirect("/docs/tutorials/elastic-ci-stack-aws")
  get "/docs/guides/environment-variables",       to: redirect("/docs/pipelines/environment-variables")
  get "/docs/guides/getting-started",             to: redirect("/docs/tutorials")
  get "/docs/guides/github-enterprise",           to: redirect("/docs/integrations/github-enterprise")
  get "/docs/guides/github-repo-access",          to: redirect("/docs/agent/github-ssh-keys")
  get "/docs/guides/gitlab",                      to: redirect("/docs/integrations/gitlab")
  get "/docs/guides/images-in-build-output",      to: redirect("/docs/pipelines/links-and-images-in-log-output")
  get "/docs/pipelines/images-in-log-output",     to: redirect("/docs/pipelines/links-and-images-in-log-output")
  get "/docs/guides/managing-log-output",         to: redirect("/docs/pipelines/managing-log-output")
  get "/docs/guides/migrating-from-bamboo",       to: redirect("/docs/tutorials/migrating-from-bamboo")
  get "/docs/guides/parallelizing-builds",        to: redirect("/docs/tutorials/parallel-builds")
  get "/docs/guides/skipping-a-build",            to: redirect("/docs/pipelines/ignoring-a-commit")
  get "/docs/guides/uploading-pipelines",         to: redirect("/docs/pipelines/defining-steps")
  get "/docs/guides/writing-build-scripts",       to: redirect("/docs/pipelines/writing-build-scripts")
  get "/docs/how-tos",                            to: redirect("/docs/tutorials")
  get "/docs/how-tos/bitbucket",                  to: redirect("/docs/integrations/bitbucket")
  get "/docs/how-tos/github-enterprise",          to: redirect("/docs/integrations/bitbucket")
  get "/docs/how-tos/gitlab",                     to: redirect("/docs/integrations/gitlab")
  get "/docs/how-tos/deploying-to-heroku",        to: redirect("/docs/deployments/deploying-to-heroku")
  get "/docs/how-tos/migrating-from-bamboo",      to: redirect("/docs/tutorials/migrating-from-bamboo")
  get "/docs/projects",                           to: redirect("/docs/pipelines")
  get "/docs/pipelines/pipelines",                to: redirect("/docs/pipelines")
  get "/docs/pipelines/parallel-builds",          to: redirect("/docs/tutorials/parallel-builds")
  get "/docs/pipelines/uploading-pipelines",      to: redirect("/docs/pipelines/defining-steps")
  get "/docs/webhooks/setup",                     to: redirect("/docs/apis/webhooks")
  get "/docs/webhooks",                           to: redirect("/docs/apis/webhooks")
  get "/docs/webhooks/*page",                     to: redirect("/docs/apis/webhooks/%{page}")
  get "/docs/rest-api",                           to: redirect("/docs/apis/rest-api")
  get "/docs/rest-api/*page",                     to: redirect("/docs/apis/rest-api/%{page}")
  get "/docs/quickstart/*page",                   to: redirect("/docs/tutorials/%{page}")
  get "/docs/agent/v3/plugins",                   to: redirect("/docs/pipelines/plugins")
  get "/docs/tutorials/gitlab",                   to: redirect("/docs/integrations/gitlab")
  get "/docs/tutorials/github-enterprise",        to: redirect("/docs/integrations/github-enterprise")
  get "/docs/tutorials/bitbucket",                to: redirect("/docs/integrations/bitbucket")
  get "/docs/tutorials/custom-saml",              to: redirect("/docs/integrations/sso/custom-saml")
  get "/docs/tutorials/sso-setup-with-graphql",   to: redirect("/docs/integrations/sso/sso-setup-with-graphql")
  get "/docs/tutorials/deploying-to-heroku",      to: redirect("/docs/deployments/deploying-to-heroku")
  get "/docs/integrations/sso/google-oauth",      to: redirect("/docs/integrations/sso/g-suite")
  get "/docs/integrations/sso/cloud-identity",    to: redirect("/docs/integrations/sso/g-cloud-identity")

  # Doc sections that don't have overview/index pages, so need redirecting
  get "/docs/tutorials",    to: redirect("/docs/tutorials/getting-started",      status: 302)
  get "/docs/integrations", to: redirect("/docs/integrations/github-enterprise", status: 302)
  get "/docs/apis",         to: redirect("/docs/apis/webhooks",                  status: 302)

  # The old un-versioned URLs have a lot of Google juice, so we redirect them to
  # the current version. But these are also linked from within the v2 agent
  # command help, so we may add a notice saying 'Hey, maybe you're looking for
  # v2?' after redirecting.
  get "/docs/agent",                     to: redirect("/docs/agent/v3",                            status: 301)
  get "/docs/agent/installation",        to: redirect("/docs/agent/v3/installation",               status: 301)
  get "/docs/agent/ubuntu",              to: redirect("/docs/agent/v3/ubuntu",                     status: 301)
  get "/docs/agent/debian",              to: redirect("/docs/agent/v3/debian",                     status: 301)
  get "/docs/agent/redhat",              to: redirect("/docs/agent/v3/redhat",                     status: 301)
  get "/docs/agent/freebsd",             to: redirect("/docs/agent/v3/freebsd",                    status: 301)
  get "/docs/agent/osx",                 to: redirect("/docs/agent/v3/osx",                        status: 301)
  get "/docs/agent/windows",             to: redirect("/docs/agent/v3/windows",                    status: 301)
  get "/docs/agent/linux",               to: redirect("/docs/agent/v3/linux",                      status: 301)
  get "/docs/agent/docker",              to: redirect("/docs/agent/v3/docker",                     status: 301)
  get "/docs/agent/aws",                 to: redirect("/docs/agent/v3/aws",                        status: 301)
  get "/docs/agent/gcloud",              to: redirect("/docs/agent/v3/gcloud",                     status: 301)
  get "/docs/agent/configuration",       to: redirect("/docs/agent/v3/configuration",              status: 301)
  get "/docs/agent/ssh-keys",            to: redirect("/docs/agent/v3/ssh-keys",                   status: 301)
  get "/docs/agent/github-ssh-keys",     to: redirect("/docs/agent/v3/github-ssh-keys",            status: 301)
  get "/docs/agent/hooks",               to: redirect("/docs/agent/v3/hooks",                      status: 301)
  get "/docs/agent/queues",              to: redirect("/docs/agent/v3/queues",                     status: 301)
  get "/docs/agent/prioritization",      to: redirect("/docs/agent/v3/prioritization",             status: 301)
  get "/docs/agent/plugins",             to: redirect("/docs/agent/v3/plugins",                    status: 301)
  get "/docs/agent/securing",            to: redirect("/docs/agent/v3/securing",                   status: 301)
  get "/docs/agent/cli-start",           to: redirect("/docs/agent/v3/cli-start",                  status: 301)
  get "/docs/agent/cli-meta-data",       to: redirect("/docs/agent/v3/cli-meta-data",              status: 301)
  get "/docs/agent/cli-artifact",        to: redirect("/docs/agent/v3/cli-artifact",               status: 301)
  get "/docs/agent/cli-pipeline",        to: redirect("/docs/agent/v3/cli-pipeline",               status: 301)
  get "/docs/agent/agent-meta-data",     to: redirect("/docs/agent/v3/cli-start#setting-metadata", status: 301)
  get "/docs/agent/artifacts",           to: redirect("/docs/agent/v3/cli-artifact",               status: 301)
  get "/docs/agent/build-artifacts",     to: redirect("/docs/agent/v3/cli-artifact",               status: 301)
  get "/docs/agent/build-meta-data",     to: redirect("/docs/agent/v3/cli-meta-data",              status: 301)
  get "/docs/agent/build-pipelines",     to: redirect("/docs/agent/v3/cli-pipeline",               status: 301)
  get "/docs/agent/uploading-pipelines", to: redirect("/docs/agent/v3/cli-pipeline",               status: 301)
  get "/docs/agent/upgrading",           to: redirect("/docs/agent/v3/upgrading",                  status: 301)
  get "/docs/agent/upgrading-to-v3",     to: redirect("/docs/agent/v3/upgrading",                  status: 301)

  # Old docs routes that we changed around during the development of the v3 agent docs
  get "/docs/agent/upgrading-to-v2",    to: redirect("/docs/agent/v2/upgrading-to-v2",            status: 301)
  get "/docs/agent/v3/upgrading-to-v3", to: redirect("/docs/agent/v3/upgrading",                  status: 301)
  get "/docs/agent/v2/plugins",         to: redirect("/docs/agent/v3/plugins",                    status: 301)
  get "/docs/agent/v2/agent-meta-data", to: redirect("/docs/agent/v2/cli-start#setting-metadata", status: 301)
  get "/docs/agent/v3/agent-meta-data", to: redirect("/docs/agent/v3/cli-start#setting-tags",     status: 301)

  # All other standard docs pages
  # While testing this on fargate, we're temporarily supporting two prefixes so we can load
  # the fargate-hosted docs at https://buildkite.com/docs-fargate
  # After moving /docs/ to be served by the fargate-hosted app, we can revert support
  # for the docs-fargate prefix
  scope ":prefix", constraints: { prefix: /docs|docs-fargate/}, defaults: { prefix: "docs" } do
    get "*path" => "pages#show", as: :docs_page
  end
  #get "/doc/*path" => "pages#show", as: :docs_page

  # Top level redirect. Needs to be at the end so it doesn't match /docs/sub-page
  get "/docs", to: redirect("/docs/tutorials/getting-started", status: 302), as: :docs

  # Take us straight to the docs when running standalone
  root to: redirect("/docs")
end
