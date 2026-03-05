# frozen_string_literal: true

class LLMTopicText
  attr_reader :nav, :topic_slug

  def initialize(nav, topic_slug)
    @nav = nav
    @topic_slug = topic_slug
  end

  class << self
    def generate(topic_slug)
      new(Rails.application.config.default_nav, topic_slug).generate
    end

    def topics
      @topics ||= YAML.load_file(Rails.root.join("data", "llm_topics.yml")) || {}
    end

    def valid_topic?(slug)
      topics.key?(slug)
    end
  end

  def generate
    topic = self.class.topics[topic_slug]
    return nil unless topic

    content = [
      "# #{topic['name']}",
      "",
      "> #{topic['description']}",
      ""
    ]

    nav.data.each do |section|
      next unless section["children"]

      temp_content = []
      process_nav_children(section["children"], temp_content, 3)

      if temp_content.any? { |line| line.start_with?("- ") || line.start_with?("#") }
        content << "## #{section['name']}"
        content << ""
        content.concat(temp_content)
        content << ""
      end
    end

    # Add related topics footer
    related = topic["related_topics"] || []
    valid_related = related.select { |slug| self.class.topics.key?(slug) }
    if valid_related.any?
      content << "## See also"
      content << ""
      valid_related.each do |slug|
        related_topic = self.class.topics[slug]
        url = "https://buildkite.com/docs/llms-#{slug}.txt"
        content << "- [#{related_topic['name']}](#{url}): #{related_topic['description']}"
      end
      content << ""
    end

    content.join("\n")
  end

  private

  def process_nav_children(children, content, heading_level)
    children.each do |child|
      next if child["type"] == "divider"
      next if should_skip_item?(child)

      if child["path"] && matches_topic?(child["path"])
        url = "https://buildkite.com/docs/#{child['path']}.md"
        description = descriptions[child["path"]]
        if description
          content << "- [#{child['name']}](#{url}): #{description}"
        else
          content << "- [#{child['name']}](#{url})"
        end
      elsif child["children"]
        temp_content = []
        process_nav_children(child["children"], temp_content, heading_level + 1)

        if temp_content.any? { |line| line.start_with?("- ") || line.start_with?("#") }
          content << "" unless content.empty? || content.last == ""

          heading_prefix = "#" * [heading_level, 6].min
          content << "#{heading_prefix} #{child['name']}"
          content << ""
          content.concat(temp_content)
        end
      end
    end
  end

  def matches_topic?(path)
    topic = self.class.topics[topic_slug]
    return false unless topic

    prefixes = topic["paths"] || []
    exact = topic["exact_paths"] || []

    exact.include?(path) || prefixes.any? { |prefix| path.start_with?(prefix) }
  end

  def should_skip_item?(item)
    item["path"]&.include?("apis/graphql/schemas/") ||
      item["path"]&.include?("pipelines/announcements/")
  end

  def descriptions
    @descriptions ||= YAML.load_file(Rails.root.join("data", "llm_descriptions.yml")) || {}
  end
end
