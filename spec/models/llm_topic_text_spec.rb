require "rails_helper"

RSpec.describe LLMTopicText do
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
            name: "Configure pipelines",
            children: [
              {
                name: "Overview",
                path: "pipelines/configure"
              },
              {
                name: "Step types",
                path: "pipelines/configure/step-types"
              },
              {
                name: "Dynamic pipelines",
                children: [
                  {
                    name: "Overview",
                    path: "pipelines/configure/dynamic-pipelines"
                  },
                  {
                    name: "Using if_changed",
                    path: "pipelines/configure/dynamic-pipelines/if-changed"
                  }
                ]
              }
            ]
          },
          {
            name: "Integrations",
            children: [
              {
                name: "Plugins",
                path: "pipelines/integrations/plugins"
              }
            ]
          }
        ]
      },
      {
        name: "Agent",
        children: [
          {
            name: "Overview",
            path: "agent"
          },
          {
            name: "Self-hosted agents",
            children: [
              {
                name: "Overview",
                path: "agent/self-hosted"
              },
              {
                name: "Security",
                children: [
                  {
                    name: "Overview",
                    path: "agent/self-hosted/security"
                  }
                ]
              }
            ]
          }
        ]
      }
    ].map(&:deep_stringify_keys)
  end

  let(:descriptions) do
    {
      "pipelines/getting-started" => "Step-by-step tutorial for creating your first pipeline.",
      "pipelines/configure" => "Overview of pipeline configuration.",
      "pipelines/configure/step-types" => "Index of available step types.",
      "pipelines/configure/dynamic-pipelines" => "Generating pipeline steps at runtime.",
      "pipelines/configure/dynamic-pipelines/if-changed" => "Conditionally run steps based on file changes.",
      "agent" => "Overview of the Buildkite agent.",
      "agent/self-hosted" => "Running agents on your own infrastructure.",
      "agent/self-hosted/security" => "Security hardening for self-hosted agents."
    }
  end

  let(:topics) do
    {
      "pipeline-configurations" => {
        "name" => "Buildkite Pipeline Configuration Documentation",
        "description" => "Documentation for configuring pipelines.",
        "paths" => ["pipelines/configure"],
        "exact_paths" => []
      },
      "agent" => {
        "name" => "Buildkite Agent Documentation",
        "description" => "Documentation for the Buildkite agent.",
        "paths" => ["agent"],
        "exact_paths" => []
      },
      "security" => {
        "name" => "Buildkite Security Documentation",
        "description" => "Documentation for security.",
        "paths" => ["agent/self-hosted/security"],
        "exact_paths" => ["pipelines/configure/dynamic-pipelines/if-changed"]
      }
    }
  end

  let(:nav) { double("Nav", data: nav_data) }

  before do
    allow(YAML).to receive(:load_file)
      .with(Rails.root.join("data", "llm_descriptions.yml"))
      .and_return(descriptions)
    allow(YAML).to receive(:load_file)
      .with(Rails.root.join("data", "llm_topics.yml"))
      .and_return(topics)
    # Clear cached topics between tests
    described_class.instance_variable_set(:@topics, nil)
  end

  describe ".valid_topic?" do
    it "returns true for known topics" do
      expect(described_class.valid_topic?("agent")).to be true
    end

    it "returns false for unknown topics" do
      expect(described_class.valid_topic?("nonexistent")).to be false
    end
  end

  describe ".generate" do
    it "creates a new instance with Rails default_nav and calls generate" do
      default_nav = double("DefaultNav")
      allow(Rails.application.config).to receive(:default_nav).and_return(default_nav)

      instance = double("LLMTopicText")
      allow(LLMTopicText).to receive(:new).with(default_nav, "agent").and_return(instance)
      allow(instance).to receive(:generate).and_return("generated content")

      expect(LLMTopicText.generate("agent")).to eq("generated content")
    end
  end

  describe "#generate" do
    context "with pipeline-configurations topic" do
      subject(:result) { described_class.new(nav, "pipeline-configurations").generate }

      it "includes the topic title and description" do
        expect(result).to include("# Buildkite Pipeline Configuration Documentation")
        expect(result).to include("> Documentation for configuring pipelines.")
      end

      it "includes pages matching the prefix" do
        expect(result).to include("[Overview](https://buildkite.com/docs/pipelines/configure.md)")
        expect(result).to include("[Step types](https://buildkite.com/docs/pipelines/configure/step-types.md)")
        expect(result).to include("[Overview](https://buildkite.com/docs/pipelines/configure/dynamic-pipelines.md)")
        expect(result).to include("[Using if_changed](https://buildkite.com/docs/pipelines/configure/dynamic-pipelines/if-changed.md)")
      end

      it "excludes pages not matching the prefix" do
        expect(result).not_to include("pipelines/getting-started")
        expect(result).not_to include("pipelines/integrations")
        expect(result).not_to include("agent")
      end

      it "includes descriptions for matching pages" do
        expect(result).to include("Overview of pipeline configuration.")
        expect(result).to include("Index of available step types.")
      end
    end

    context "with agent topic" do
      subject(:result) { described_class.new(nav, "agent").generate }

      it "includes all agent pages" do
        expect(result).to include("[Overview](https://buildkite.com/docs/agent.md)")
        expect(result).to include("[Overview](https://buildkite.com/docs/agent/self-hosted.md)")
        expect(result).to include("[Overview](https://buildkite.com/docs/agent/self-hosted/security.md)")
      end

      it "excludes non-agent pages" do
        expect(result).not_to include("pipelines/getting-started")
        expect(result).not_to include("pipelines/configure")
      end
    end

    context "with exact_paths matching" do
      subject(:result) { described_class.new(nav, "security").generate }

      it "includes pages matching exact paths" do
        expect(result).to include("[Using if_changed](https://buildkite.com/docs/pipelines/configure/dynamic-pipelines/if-changed.md)")
      end

      it "includes pages matching path prefixes" do
        expect(result).to include("[Overview](https://buildkite.com/docs/agent/self-hosted/security.md)")
      end

      it "excludes pages matching neither" do
        expect(result).not_to include("pipelines/getting-started")
        expect(result).not_to include("pipelines/configure/step-types")
      end
    end

    context "with an invalid topic" do
      it "returns nil" do
        expect(described_class.new(nav, "nonexistent").generate).to be_nil
      end
    end

    context "when sections have no matching children" do
      subject(:result) { described_class.new(nav, "agent").generate }

      it "does not include empty sections" do
        # Pipelines section should not appear in agent topic
        lines = result.split("\n")
        expect(lines).not_to include("## Pipelines")
      end
    end
  end
end
