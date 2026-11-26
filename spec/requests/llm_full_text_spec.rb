require "rails_helper"

RSpec.describe "The full documentation bundle" do
  it "publishes the same rendered Markdown as each page, including generated scope rows" do
    get "/docs/llms-full.txt"

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("text/plain")
    bundle = response.body
    expect(bundle).to start_with("# Buildkite Documentation\n")
    expect(bundle).not_to include("URL: https://buildkite.com/docs/apis/graphql/schemas/")

    paths = %w[
      /docs/pipelines
      /docs/agent
      /docs/apis/managing-api-tokens
      /docs/platform/security/checklist
      /docs/platform/security/tokens
    ]
    paths.each do |path|
      get "#{path}.md"

      expect(response).to have_http_status(:ok)
      expect(bundle).to include("URL: https://buildkite.com#{path}.md\n\n#{response.body.strip}\n\n---\n")
    end

    expect(bundle).to include(
      "### Organization and users\n",
      "| Feature and scopes | Description | Read | Write | Delete |",
      "| **Rules**<br>`read_rules`, `write_rules` | List and retrieve details of rules—create or delete rules. | ✅ | ✅ |  |",
      "[agent token](https://buildkite.com/docs/agent/self-hosted/tokens.md)",
      "### Audit this area\n",
      "- Prefix: `bkua_`"
    )
  end
end
