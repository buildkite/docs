require 'rails_helper'

RSpec.describe "Legacy documentation redirects" do
  it "sends an old guide URL straight to the current page" do
    get "/docs/guides/deploying-to-heroku"

    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/docs/pipelines/deployments/with-heroku")

    follow_redirect!
    expect(response).to have_http_status(:ok)
  end

  it "preserves the Markdown extension and section when bypassing intermediate aliases" do
    get "/docs/guides/skipping-a-build.md"

    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/docs/pipelines/configure/skipping.md#ignore-a-commit")

    follow_redirect!
    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("text/markdown")
  end

  it "keeps an exact exception ahead of a legacy namespace redirect" do
    get "/docs/rest-api/analytics/flaky-tests.md"

    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/docs/apis/rest-api/test-engine/tests.md#list-tests")
  end

  it "redirects paths under a moved namespace without dropping the path suffix" do
    get "/docs/rest-api/analytics/runs.md"

    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/docs/apis/rest-api/test-engine/runs.md")
  end

  it "sends renamed pages under former namespaces straight to their final destinations" do
    {
      "/docs/agent/v3/artifacts" => "/docs/agent/cli/reference/artifact",
      "/docs/builds/ignoring-a-commit.md" => "/docs/pipelines/configure/skipping.md#ignore-a-commit",
      "/docs/packages/ruby" => "/docs/package-registries/ecosystems/ruby"
    }.each do |old_path, current_path|
      get old_path

      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to(current_path)
      follow_redirect!
      expect(response).to have_http_status(:ok)
    end
  end

  it "returns a Markdown 404 directly for an unknown page under a moved namespace" do
    get "/docs/packages/non-existent-page.md"

    expect(response).to have_http_status(:not_found)
    expect(response.media_type).to eq("text/markdown")
    expect(response.location).to be_nil
  end

  it "keeps the intentional landing redirect for retired Agent v2 documentation" do
    get "/docs/agent/v2/upgrading-to-v2.md"

    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/docs/agent.md")
  end

  it "redirects a Test Analytics alias past both previous Test Engine paths" do
    get "/docs/test-analytics/notifications/slack.md"

    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/docs/pipelines/configure/tests/workflows/actions.md#send-slack-notification")
  end

  it "keeps the pre-GA Test Analytics entry point without redirecting unknown paths" do
    get "/docs/test-analytics/integrations"
    expect(response).to redirect_to("/docs/pipelines/configure/tests")

    get "/docs/test-analytics/non-existent-page"
    expect(response).to have_http_status(:not_found)
  end
end
