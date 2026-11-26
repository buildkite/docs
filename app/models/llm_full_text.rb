# frozen_string_literal: true

class LLMFullText
  def initialize(nav, view)
    @nav = nav
    @view = view
  end

  def generate
    content = [
      "# Buildkite Documentation",
      "",
      "> Buildkite is a platform for running fast, secure, and scalable continuous integration pipelines on your own infrastructure.",
      "",
      "---",
      ""
    ]

    @nav.data.each do |section|
      next unless section["children"]

      pages = []
      pages << section if section["path"] && !should_skip_item?(section)
      collect_pages(section["children"], pages)
      next if pages.empty?

      # Use labels for bundle metadata so each page keeps its authored heading hierarchy.
      content.push("**#{section['name']}**", "")

      pages.each do |item|
        path = item.fetch("path")
        page = Page.new(@view, path)
        next unless page.exists?

        url = "https://buildkite.com/docs/#{path}.md"
        markdown = Page::MarkdownExport.format(page.markdown_body, "/docs/#{path}")
        content.push("**#{item['name']}**", "", "URL: #{url}", "", markdown.strip, "", "---", "")
      end
    end

    content.join("\n")
  end

  private

  def collect_pages(children, pages)
    children.each do |child|
      next if child["type"] == "divider" || should_skip_item?(child)

      if child["path"]
        pages << child
      elsif child["children"]
        collect_pages(child["children"], pages)
      end
    end
  end

  def should_skip_item?(item)
    path = item["path"]
    path && (!path.match?(%r{\A[\w/-]+\z}) || path.start_with?("apis/graphql/schemas/", "pipelines/announcements/"))
  end
end
