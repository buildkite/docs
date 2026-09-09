require 'rails_helper'
require 'yaml'

RSpec.describe "hosted agent image examples" do
  %w[
    agent/buildkite_hosted/linux/custom_agent_images.md
    agent/buildkite_hosted/internal_container_registry.md
  ].each do |path|
    it "uses image references outside agent query rules in #{path}" do
      markdown = File.read(Rails.root.join("pages", path))
      # Validate the copyable YAML after rendering escaped emoji shortcodes.
      document = Nokogiri::HTML.fragment(Page::Renderer.render(markdown))
      snippets = document.css("pre.highlight.yaml code").map(&:text)
      expect(snippets).not_to be_empty

      snippets.each do |snippet|
        pipeline = YAML.safe_load(snippet)
        expect(pipeline.fetch("steps")).not_to be_empty

        # Image selection belongs to the pipeline or command step, not agents.
        scopes = [pipeline, *pipeline.fetch("steps")]
        scopes.each do |scope|
          expect(scope.fetch("agents", {})).not_to have_key("image")
        end

        references = scopes.filter_map { |scope| scope["image"] }
        expect(references).not_to be_empty
        references.each do |reference|
          # These examples use registry/image references, not UI display names.
          expect(reference).to match(/\A\S+\/\S+\z/)
        end
      end
    end
  end
end
