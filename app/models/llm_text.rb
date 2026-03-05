# frozen_string_literal: true

class LLMText
  attr_reader :nav

  def initialize(nav)
    @nav = nav
  end

  class << self
    def generate
      new(Rails.application.config.default_nav).generate
    end
  end

  def generate
    content = [
      "# Buildkite Documentation",
      "",
      "> Buildkite is a platform for running fast, secure, and scalable continuous integration pipelines on your own infrastructure.",
      ""
    ]

    # Process each top-level navigation section
    nav.data.each do |section|
      next unless section["children"] # Skip sections without children

      # Check if this section has any valid children after filtering
      temp_content = []
      process_nav_children(section["children"], temp_content, 3)

      # Only add the section if there's actual content
      if temp_content.any? { |line| line.start_with?("- ") || line.start_with?("#") }
        content << "## #{section['name']}"
        content << ""

        content.concat(temp_content)
        content << ""
      end
    end

    # Add topic-specific guide index at the end
    topics = LLMTopicText.topics
    if topics.any?
      content << "## Topic guides"
      content << ""
      content << "Focused subsets of this documentation are available for specific topics:"
      content << ""
      topics.each do |slug, topic|
        url = "https://buildkite.com/docs/llms-#{slug}.txt"
        content << "- [#{topic['name']}](#{url}): #{topic['description']}"
      end
      content << ""
    end

    content.join("\n")
  end

  private

  def process_nav_children(children, content, heading_level)
    children.each_with_index do |child, index|
      next if child["type"] == "divider"
      next if should_skip_item?(child)

      if child["path"]
        # This is a leaf node with a path - add it as a link
        url = "https://buildkite.com/docs/#{child['path']}.md"
        description = descriptions[child["path"]]
        if description
          content << "- [#{child['name']}](#{url}): #{description}"
        else
          content << "- [#{child['name']}](#{url})"
        end
      elsif child["children"]
        # Check if this section has any valid children after filtering
        temp_content = []
        process_nav_children(child["children"], temp_content, heading_level + 1)

        # Only add the heading if there's actual content
        if temp_content.any? { |line| line.start_with?("- ") || line.start_with?("#") }
          # Add spacing before heading if there's previous content
          content << "" unless content.empty? || content.last == ""

          heading_prefix = "#" * [heading_level, 6].min # Max heading level is H6
          content << "#{heading_prefix} #{child['name']}"
          content << ""

          content.concat(temp_content)
        end
      end
    end
  end

  def should_skip_item?(item)
    item["path"]&.include?("apis/graphql/schemas/") ||
      item["path"]&.include?("pipelines/announcements/")
  end

  def descriptions
    @descriptions ||= YAML.load_file(Rails.root.join("data", "llm_descriptions.yml")) || {}
  end
end
