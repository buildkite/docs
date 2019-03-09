require 'rails_helper'

RSpec.feature "reading pages" do
  describe "/docs/agent" do
    it "is viewable" do
      visit "/docs/agent"
      expect(page).to have_content("How it Works")

      visit "/docs/agent/ubuntu"
      expect(page).to have_content("apt repository")

      visit "/docs/unknown"
      expect(page.status_code).to eql(404)
      expect(page).to have_content("Page not found")
      expect(page).to have_content("Sorry, the page you’re trying to access could not be found")
    end

    it "adds the agent version number to the title" do
      visit "/docs/agent/v3"
      expect(page.title).to include("The Buildkite Agent (v3)")

      visit "/docs/agent/v2"
      expect(page.title).to include("The Buildkite Agent (v2)")
    end
  end

  describe "clicking links" do
    class Check < Struct.new(:path, :source_link, :fragment, keyword_init: true)
    end

    it "doesn't lead to 404s" do
      checks = [Check.new(path: "/docs")]
      checks_completed = []
      errors = []

      while check = checks.shift do
        # Uncomment this out to see each request happen
        puts "Visiting #{check.path}#{check.fragment && "##{check.fragment}"}"
        visit check.path

        # Pages either need to return okay, or show the login page. Everything
        # else we consider busted, which helps to detect accidental URLs that
        # don't match the Rails router for example.
        if !page.status_code.in?([200, 403])
          errors << { error: "Page returned #{page.status_code}", page: check.path, source_link: check.source_link }
        end

        if check.fragment
          if all("##{check.fragment}").empty?
            errors << { error: 'Section not found', page: check.path, section: "##{check.fragment}", source_link: check.source_link }
          end
        end

        checks_completed << check

        # For docs pages, we follow all the links
        if check.path =~ /\A\/docs/
          all('a').each do |a|
            uri = URI.parse(a[:href])

            # Don't follow links to other servers
            next if uri.host && uri.host != 'buildkite.localhost'

            # Ignore emails
            next if uri.is_a?(URI::MailTo)

            # We have to resolve paths relative to the current page, so that both
            # '/docs/tutorials/getting-started' and 'getting-started' (from
            # '/docs/tutorials/other') work okay, similarly to in the browser.
            # Luckily, URI.join does exactly that.
            resolved_path = URI.join('http://buildkite.localhost', check.path, uri.path).path

            next if checks_completed.any? {|check| check.path == resolved_path && check.fragment == uri.fragment }
            next if checks.any?           {|check| check.path == resolved_path && check.fragment == uri.fragment }

            checks << Check.new(path: resolved_path, fragment: uri.fragment, source_link: { text: a.text, href: check.path })
          end
        end
      end

      expect(errors).to eql([])
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
