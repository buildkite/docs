require 'rails_helper'

RSpec.feature "reading pages" do
  describe "/docs/agent" do
    it "is viewable" do
      visit "/docs/agent"
      expect(page).to have_content("How it works")

      visit "/docs/agent/ubuntu"
      expect(page).to have_content("apt repository")

      visit "/docs/unknown"
      expect(page).to have_content("Routing Error")
      expect(page).to have_content("The documentation page `unknown` does not exist")
    end

    it "has appropriate meta tags" do
      visit "/docs/agent"
      expect(page.find(%{meta[property="og:title"]}, visible: false)[:content]).to eql("The Buildkite agent")
    end

    it "has the correct title" do
      visit "/docs/agent"
      expect(page.title).to include("The Buildkite agent")
    end

    it "links to the GitHub source files" do
      visit "/docs/pipelines/getting-started"
      expect(page).to have_css("a[href='https://github.com/buildkite/docs/edit/main/pages/pipelines/getting_started.md']", text: 'Edit this page')
    end
  end

  describe "/docs/pipelines/configure/environment-variables" do
    it "identifies where environment variable values can be modified" do
      visit "/docs/pipelines/configure/environment-variables"

      %w[
        BUILDKITE_BUILD_CHECKOUT_PATH BUILDKITE_CLEAN_CHECKOUT
        BUILDKITE_GIT_LFS_ENABLED BUILDKITE_GIT_SKIP_FETCH_EXISTING_COMMITS
        BUILDKITE_GIT_SPARSE_CHECKOUT_PATHS BUILDKITE_GIT_SUBMODULES
        BUILDKITE_PLUGIN_VALIDATION BUILDKITE_S3_ACCESS_KEY_ID
        BUILDKITE_S3_ACCESS_URL BUILDKITE_S3_ACL BUILDKITE_S3_DEFAULT_REGION
        BUILDKITE_S3_SECRET_ACCESS_KEY BUILDKITE_S3_SSE_ENABLED
      ].each do |name|
        expect(page.find("tr[id='#{name}'] th")).not_to have_css("small")
      end

      %w[BUILDKITE BUILDKITE_BRANCH BUILDKITE_BUILD_ID BUILDKITE_COMMAND CI].each do |name|
        expect(page.find("tr[id='#{name}'] th small")).to have_text("Set by Buildkite", exact: true)
      end

      %w[BUILDKITE_AGENT_ACCESS_TOKEN BUILDKITE_AGENT_PID BUILDKITE_BIN_PATH].each do |name|
        expect(page.find("tr[id='#{name}'] th small")).to have_text("This value cannot be modified", exact: true)
      end

      %w[BUILDKITE_AGENT_DEBUG BUILDKITE_COMMAND_EVAL BUILDKITE_GIT_MIRRORS_PATH].each do |name|
        expect(page.find("tr[id='#{name}'] th small")).to have_text("This value cannot be modified except in the agent configuration", exact: true)
      end

      expect(page.find("tr[id='BUILDKITE_CONFIG_PATH'] th small")).to have_text("This value cannot be modified except when selecting the agent configuration file", exact: true)
      expect(page.find("tr[id='BUILDKITE_GIT_REMOTE_MIRROR_URL'] th small")).to have_text("This value cannot be modified except in the pipeline settings", exact: true)
    end
  end

  describe "markdown format" do
    # Capybara resets the session only after examples that call visit or a finder,
    # so without this, Accept headers from examples that only call page.driver.get
    # make later examples receive Markdown instead of HTML
    after { page.driver.header "Accept", nil }

    it "serves pages as HTML by default" do
      visit "/docs/platform"
      expect(page.response_headers["Content-Type"]).to include("text/html")
      expect(page.html).to include("<html")
      expect(page).to have_content("The Buildkite platform")
    end

    it "serves pages as markdown when .md extension is used" do
      page.driver.get("/docs/platform.md")
      expect(page.status_code).to eq(200)
      expect(page.response_headers["Content-Type"]).to include("text/markdown")
      expect(page.html).to include("# The Buildkite platform")
      expect(page.html).not_to include("<html")
    end

    it 'returns 404 for non-existent markdown pages' do
      page.driver.get('/docs/non-existent-page.md')
      expect(page.status_code).to eq(404)
      expect(page.html).to include('The documentation page `non_existent_page` does not exist')
    end

    it "serves markdown when Accept header lists text/markdown (Claude Code style)" do
      page.driver.header "Accept", "text/markdown, text/html, */*"
      page.driver.get("/docs/platform")
      expect(page.status_code).to eq(200)
      expect(page.response_headers["Content-Type"]).to include("text/markdown")
      expect(page.html).to include("# The Buildkite platform")
      expect(page.html).not_to include("<html")
    end

    it "serves HTML when Accept header is a typical browser default" do
      page.driver.header "Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8"
      page.driver.get("/docs/platform")
      expect(page.status_code).to eq(200)
      expect(page.response_headers["Content-Type"]).to include("text/html")
      expect(page.html).to include("<html")
    end

    it "serves markdown when Accept header is only text/markdown" do
      page.driver.header "Accept", "text/markdown"
      page.driver.get("/docs/platform")
      expect(page.status_code).to eq(200)
      expect(page.response_headers["Content-Type"]).to include("text/markdown")
    end
  end

  describe "all pages" do
    around do |example|
      # Render the optional Datadog and Plain scripts too
      original = ENV.to_h.slice("DD_RUM_ENABLED", "PLAIN_CHAT_APP_ID")
      ENV["DD_RUM_ENABLED"] = "true"
      ENV["PLAIN_CHAT_APP_ID"] = "liveChatApp_example"
      example.run
    ensure
      ENV.delete("DD_RUM_ENABLED")
      ENV.delete("PLAIN_CHAT_APP_ID")
      ENV.update(original)
    end

    example "render with nonced inline scripts only in the head" do
      inline_scripts = 'script:not([src]):not([type="application/ld+json"])'
      first_head_scripts = nil

      root = Rails.root.join("pages")
      root.glob("**/*.md").each do |path|
        # Skip partials
        next if path.to_s.include?("/_")
        # Published only as Markdown, so it has no navigation entry or HTML page
        next if path.to_s.end_with?("/agent_setup/prompt.md")

        url = "/docs" + path.to_s.delete_prefix(root.to_s).delete_suffix(".md")
        puts "Visiting #{url}"
        visit url
        if !page.status_code.in?([200, 403])
          raise "#{url} returned #{page.status_code}"
        end

        csp = page.response_headers.fetch("Content-Security-Policy")
        nonce = csp[/(?:\A|;\s*)script-src [^;]*'nonce-([^']+)'/, 1]
        expect(nonce).to be_present, "expected script-src on #{url} to include a nonce"

        head_scripts = page.all("head #{inline_scripts}", visible: false)
        expect(head_scripts.map { |script| script[:nonce] }.uniq).to eql([nonce]), "expected inline scripts on #{url} to have the CSP nonce"

        # After a Turbo visit, the browser blocks inline scripts in the body and
        # head scripts that differ from the first page, because Turbo adds them
        # without a nonce
        expect(page).to have_no_css("body #{inline_scripts}", visible: false), "expected no inline scripts in the body of #{url}"
        head_script_texts = head_scripts.map { |script| script.native.text }
        first_head_scripts ||= head_script_texts
        expect(head_script_texts).to eql(first_head_scripts), "expected inline head scripts on #{url} to match other pages"
      end
    end
  end

  describe "valid, but non-canonical versions of URLs" do
    it "permanently redirect to the canonical version" do
      visit "/docs/pipelines/gettingStarted"
      expect(page.current_path).to eql("/docs/pipelines/getting-started"), "expected gettingStarted to redirect to getting-started"

      visit "/docs/pipelines/getting_started"
      expect(page.current_path).to eql("/docs/pipelines/getting-started"), "expected getting_started to redirect to getting-started"
    end
  end

  describe "old URLs" do
    it "keeps old data flow links with the shared responsibility diagram" do
      visit "/docs/pipelines/security#data-flow"

      expect(page.current_path).to eq("/docs/platform/security")
      within("section#shared-responsibility") do
        expect(page).to have_css("h2", text: "Shared responsibility")
        expect(page).to have_css("a#data-flow", visible: :all)
        expect(page).to have_css("img")
      end
      expect(page).to have_link("Security at Buildkite", href: "https://buildkite.com/about/security/")
    end

    it "preserves security control section links at their replacement sections" do
      visit "/docs/pipelines/best-practices/security-controls"

      expect(page.current_path).to eq("/docs/platform/security/checklist")

      within(".Toc") do
        expect(page).to have_link("Authentication and access control", href: "#authentication-and-access-control")
        expect(page).to have_link("Incident readiness", href: "#incident-readiness")
      end

      {
        "authentication-and-session-security-in-the-buildkite-interface-apis-and-cli" => "Authentication and access control",
        "source-code-security-and-version-control-integrity" => "Pipeline and supply chain integrity",
        "dependencies-and-package-management" => "Pipeline and supply chain integrity",
        "api-access-token-compromise" => "Authentication and access control",
        "network-and-transport-security" => "Network and data exposure",
        "artifact-storage-and-integrity" => "Network and data exposure",
        "consistent-pipeline-as-code-approach" => "Governance and configuration management",
        "monitoring-anomaly-detection-logging" => "Monitoring and detection",
        "incident-response-and-recovery" => "Incident readiness"
      }.each do |anchor, heading|
        target = page.find("a[id='#{anchor}']", visible: :all)
        expect(target.find(:xpath, "following::h2[1]").text).to eq(heading)
      end

      %w[secrets-management buildkite-agent-security further-questions].each do |anchor|
        expect(page).to have_css("h2[id='#{anchor}']")
      end
    end

    old_paths = %w{
      /docs/agent/agent-meta-data
      /docs/agent/artifacts
      /docs/agent/build-artifacts
      /docs/agent/build-meta-data
      /docs/agent/build-pipelines
      /docs/agent/self-hosted/aws/elastic-ci-stack
      /docs/agent/self-hosted/code-access#ssh-keys-for-github
      /docs/agent/uploading-pipelines
      /docs/agent/upgrading
      /docs/agent/plugins
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
      /docs/guides/environment-variables
      /docs/guides/getting-started
      /docs/guides/github-enterprise
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
      /docs/pipelines/best-practices/secrets-management
      /docs/pipelines/best-practices/security-controls
      /docs/pipelines/emoji
      /docs/pipelines/pipelines
      /docs/pipelines/security
      /docs/platform/security/best-practices
      /docs/pipelines/security/enforcing-security-controls
      /docs/pipelines/tutorials/docker-containerized-builds
      /docs/pipelines/tutorials/parallel-builds
      /docs/pipelines/uploading-pipelines
      /docs/projects
      /docs/rest-api
      /docs/tutorials/docker-containerized-builds
      /docs/tutorials/parallel-builds
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
