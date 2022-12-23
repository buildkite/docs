require 'rails_helper'

RSpec.feature "reading pages" do
  describe "/docs/agent" do
    it "is viewable" do
      visit "/docs/agent"
      expect(page).to have_content("How it works")

      visit "/docs/agent/ubuntu"
      expect(page).to have_content("apt repository")

      expect { visit "/docs/unknown" }.to raise_error(ActionController::RoutingError)
    end

    it "has appropriate meta tags" do
      visit "/docs/agent"
      expect(page.find(%{meta[property="og:title"]}, visible: false)[:content]).to eql("The Buildkite Agent v3")
      expect(page.find(%{meta[property="og:description"]}, visible: false)[:content]).to eql("The Buildkite agent is a small, reliable and cross-platform build runner that makes it easy to run automated builds on your own infrastructure. Its main responsibilities are polling buildkite.com for work, running build jobs, reporting back the status code and output log of the job, and uploading the job's artifacts.")
    end

    it "adds the agent version number to the title" do
      visit "/docs/agent/v3"
      expect(page.title).to include("The Buildkite Agent v3")

      visit "/docs/agent/v2"
      expect(page.title).to include("The Buildkite Agent v2")
    end

    it "links to the GitHub source files" do
      visit "/docs/tutorials/getting-started"
      expect(page).to have_css("a[href='https://github.com/buildkite/docs/edit/main/pages/tutorials/getting_started.md.erb']", text: 'Contribute an update')
    end
  end

  describe "all pages" do
    example "render" do
      root = Rails.root.join("pages")
      root.glob("**/*.md{,.erb}").each do |path|
        url = "/docs" + path.to_s.delete_prefix(root.to_s).delete_suffix(".erb").delete_suffix(".md")
        puts "Visiting #{url}"
        visit url
        if !page.status_code.in?([200, 403])
          raise "#{url} returned #{page.status_code}"
        end
      end
    end
  end

  describe "valid, but non-canonical versions of URLs" do
    it "permanently redirect to the canonical version" do
      visit "/docs/tutorials/gettingStarted"
      expect(page.current_path).to eql("/docs/tutorials/getting-started"), "expected gettingStarted to redirect to getting-started"

      visit "/docs/tutorials/getting_started"
      expect(page.current_path).to eql("/docs/tutorials/getting-started"), "expected getting_started to redirect to getting-started"
    end
  end

  describe "old URLs" do
    old_paths = %w{
      /docs/agent/agent-meta-data
      /docs/agent/artifacts
      /docs/agent/build-artifacts
      /docs/agent/build-meta-data
      /docs/agent/build-pipelines
      /docs/agent/uploading-pipelines
      /docs/agent/upgrading
      /docs/agent/v3/plugins
      /docs/api
      /docs/api/accounts
      /docs/api/builds
      /docs/api/projects
      /docs/basics/pipelines
      /docs/builds
      /docs/builds/parallelizing-builds
      /docs/graphql-api
      /docs/graphql
      /docs/apis/graphql
      /docs/apis/graphql/schemas
      /docs/apis/graphql/schemas/query
      /docs/apis/graphql/schemas/mutation
      /docs/apis/graphql/schemas/object
      /docs/apis/graphql/schemas/scalar
      /docs/apis/graphql/schemas/interface
      /docs/apis/graphql/schemas/enum
      /docs/apis/graphql/schemas/input-object
      /docs/apis/graphql/schemas/union
      /docs/guides/artifacts
      /docs/guides/branch-configuration
      /docs/guides/build-meta-data
      /docs/guides/build-status-badges
      /docs/guides/cc-menu
      /docs/guides/collapsing-build-output
      /docs/guides/controlling-concurrency
      /docs/guides/deploying-to-heroku
      /docs/guides/docker-containerized-builds
      /docs/guides/elastic-ci-stack-aws
      /docs/guides/environment-variables
      /docs/guides/getting-started
      /docs/guides/github-enterprise
      /docs/guides/github-repo-access
      /docs/guides/gitlab
      /docs/guides/images-in-build-output
      /docs/guides/managing-log-output
      /docs/guides/migrating-from-bamboo
      /docs/guides/parallelizing-builds
      /docs/guides/skipping-a-build
      /docs/guides/uploading-pipelines
      /docs/guides/writing-build-scripts
      /docs/how-tos
      /docs/how-tos/bitbucket
      /docs/how-tos/deploying-to-heroku
      /docs/how-tos/github-enterprise
      /docs/how-tos/gitlab
      /docs/how-tos/migrating-from-bamboo
      /docs/pipelines/emoji
      /docs/pipelines/pipelines
      /docs/pipelines/uploading-pipelines
      /docs/projects
      /docs/rest-api
      /docs/tutorials/sso-setup-with-graphql
      /docs/webhooks/setup
      /docs/webhooks
    }

    old_paths.each do |path|
      it "redirects #{path} to a current doc page" do
        visit path

        expect(page.status_code).to_not eql(404), "expected #{path} to not return 404"
      end
    end
  end
end
