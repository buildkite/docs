require "rails_helper"

RSpec.describe LLMText do
  let(:nav_data) do
    [
      {
        name: "Pipelines",
        children: [
          {
            name: "Getting Started",
            path: "pipelines/getting-started"
          },
          {
            name: "Configuration",
            children: [
              {
                name: "Step types",
                path: "pipelines/configuration/step-types"
              },
              {
                name: "Environment variables",
                path: "pipelines/configuration/environment-variables"
              }
            ]
          }
        ]
      },
      {
        name: "APIs",
        children: [
          {
            name: "REST API",
            path: "apis/rest-api"
          },
          {
            name: "GraphQL Schema",
            path: "apis/graphql/schemas/query"
          }
        ]
      }
    ].map(&:deep_stringify_keys)
  end

  let(:descriptions) do
    {
      "pipelines/getting-started" => "Step-by-step tutorial for creating your first pipeline.",
      "apis/rest-api" => "REST API overview: authentication, pagination, and endpoints."
    }
  end

  let(:nav) { double("Nav", data: nav_data) }
  subject(:llm_text) { described_class.new(nav) }

  before do
    allow(YAML).to receive(:load_file)
      .with(Rails.root.join("data", "llm_descriptions.yml"))
      .and_return(descriptions)

    # LLMText#generate now calls LLMTopicText.topics for the topic index
    allow(LLMTopicText).to receive(:topics).and_return({})
  end

  describe ".generate" do
    it "creates a new instance with Rails default_nav and calls generate" do
      default_nav = double("DefaultNav")
      allow(Rails.application.config).to receive(:default_nav).and_return(default_nav)

      instance = double("LLMText")
      allow(LLMText).to receive(:new).with(default_nav).and_return(instance)
      allow(instance).to receive(:generate).and_return("generated content")

      expect(LLMText.generate).to eq("generated content")
    end
  end

  describe "#initialize" do
    it "stores the nav object" do
      expect(llm_text.nav).to eq(nav)
    end
  end

  describe "#generate" do
    let(:result) { llm_text.generate }

    it "generates llms.txt format with proper structure" do
      expect(result).to include("# Buildkite Documentation")
      expect(result).to include("> Buildkite is a platform for running fast, secure")
      expect(result).to include("## Pipelines")
      expect(result).to include("## APIs")
    end

    it "includes navigation links with descriptions when available" do
      expect(result).to include(
        "- [Getting Started](https://buildkite.com/docs/pipelines/getting-started.md): Step-by-step tutorial for creating your first pipeline."
      )
      expect(result).to include(
        "- [REST API](https://buildkite.com/docs/apis/rest-api.md): REST API overview: authentication, pagination, and endpoints."
      )
    end

    it "includes navigation links without descriptions when not available" do
      step_types_line = result.lines.find { |l| l.include?("Step types") }
      expect(step_types_line.strip).to eq("- [Step types](https://buildkite.com/docs/pipelines/configuration/step-types.md)")
    end

    it "creates nested headings for sections with children" do
      expect(result).to include("### Configuration")
      expect(result).to include("[Step types](https://buildkite.com/docs/pipelines/configuration/step-types.md)")
      expect(result).to include("[Environment variables](https://buildkite.com/docs/pipelines/configuration/environment-variables.md)")
    end

    it "filters out GraphQL schema documentation" do
      expect(result).not_to include("GraphQL Schema")
      expect(result).not_to include("apis/graphql/schemas/query")
    end

    it "includes proper line breaks between sections" do
      lines = result.split("\n")

      # Should have empty lines between major sections
      pipelines_index = lines.index("## Pipelines")
      apis_index = lines.index("## APIs")

      expect(pipelines_index).to be > 0
      expect(apis_index).to be > pipelines_index

      # Should have empty line before APIs section
      expect(lines[apis_index - 1]).to eq("")
    end

    context "when sections have no valid children after filtering" do
      let(:nav_data) do
        [
          {
            name: "GraphQL Only",
            children: [
              {
                name: "Schema",
                path: "apis/graphql/schemas/query"
              }
            ]
          }
        ].map(&:deep_stringify_keys)
      end

      it "does not include empty sections" do
        expect(result).not_to include("## GraphQL Only")
        expect(result).not_to include("Schema")
      end
    end

    context "with dividers in navigation" do
      let(:nav_data) do
        [
          {
            name: "Test Section",
            children: [
              {
                name: "Valid Page",
                path: "test/valid"
              },
              {
                type: "divider"
              },
              {
                name: "Another Page",
                path: "test/another"
              }
            ]
          }
        ].map(&:deep_stringify_keys)
      end

      it "skips dividers and includes valid pages" do
        expect(result).to include("- [Valid Page](https://buildkite.com/docs/test/valid.md)")
        expect(result).to include("- [Another Page](https://buildkite.com/docs/test/another.md)")
        expect(result).not_to include("divider")
      end
    end

    context "with deep nesting" do
      let(:nav_data) do
        [
          {
            name: "Level 1",
            children: [
              {
                name: "Level 2",
                children: [
                  {
                    name: "Level 3",
                    children: [
                      {
                        name: "Level 4",
                        path: "deep/nested/page"
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ].map(&:deep_stringify_keys)
      end

      it "handles multiple levels of nesting with appropriate headings" do
        expect(result).to include("## Level 1")
        expect(result).to include("### Level 2")
        expect(result).to include("#### Level 3")
        expect(result).to include("- [Level 4](https://buildkite.com/docs/deep/nested/page.md)")
      end
    end

    context "with empty descriptions file" do
      let(:descriptions) { {} }

      it "still generates valid output without descriptions" do
        expect(result).to include("- [Getting Started](https://buildkite.com/docs/pipelines/getting-started.md)")
        getting_started_line = result.lines.find { |l| l.include?("Getting Started") }
        expect(getting_started_line.strip).to eq("- [Getting Started](https://buildkite.com/docs/pipelines/getting-started.md)")
      end
    end
  end
end
