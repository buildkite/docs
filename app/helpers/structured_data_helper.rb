# frozen_string_literal: true

# Builds schema.org JSON-LD structured data for documentation pages.
#
# JSON-LD helps search engines and answer engines (LLM-based assistants)
# understand what each page is, who publishes it, and how it fits into the
# wider documentation site. It complements the llms.txt endpoints and Markdown
# alternates that already expose the docs to machine readers.
module StructuredDataHelper
  ORGANIZATION_ID = "https://buildkite.com/#organization"
  WEBSITE_ID = "https://buildkite.com/docs#website"

  # Renders a <script type="application/ld+json"> tag for the given data.
  # Returns nil (no tag) when there's nothing to render.
  def render_json_ld(data)
    return if data.blank?

    content_tag(
      :script,
      json_ld_payload(data).html_safe,
      type: "application/ld+json"
    )
  end

  # Structured data graph for an individual documentation page. Always includes
  # the WebSite and Organization the page belongs to, a TechArticle describing
  # the page itself, and a BreadcrumbList reflecting its place in the
  # navigation.
  def docs_page_structured_data(page, nav)
    graph = [organization_node, website_node, tech_article_node(page)]

    if (breadcrumb = breadcrumb_list(nav))
      graph << breadcrumb
    end

    { "@context" => "https://schema.org", "@graph" => graph }
  end

  # Structured data graph for the documentation home page. Defines the
  # Organization and WebSite that page-level graphs reference by @id.
  def docs_home_structured_data
    {
      "@context" => "https://schema.org",
      "@graph" => [organization_node, website_node]
    }
  end

  private

  # Serializes structured data to JSON and escapes the characters that could
  # otherwise break out of the surrounding <script> element. The escaped
  # sequences are valid JSON, so consumers parse the data unchanged.
  def json_ld_payload(data)
    JSON.generate(data).gsub(/[<>&\u2028\u2029]/) { |char| format('\\u%04x', char.ord) }
  end

  def tech_article_node(page)
    node = {
      "@type" => "TechArticle",
      "@id" => "#{seo_canonical_url}#article",
      "headline" => page.title,
      "name" => page.title,
      "url" => seo_canonical_url,
      "inLanguage" => "en",
      "isPartOf" => { "@id" => WEBSITE_ID },
      "publisher" => { "@id" => ORGANIZATION_ID }
    }
    node["description"] = page.description if page.description.present?
    node
  end

  def organization_node
    {
      "@type" => "Organization",
      "@id" => ORGANIZATION_ID,
      "name" => "Buildkite",
      "url" => "https://buildkite.com",
      "logo" => "https://buildkite.com#{image_path('logo.svg')}",
      "sameAs" => [
        "https://github.com/buildkite",
        "https://x.com/buildkite",
        "https://www.linkedin.com/company/buildkite"
      ]
    }
  end

  def website_node
    {
      "@type" => "WebSite",
      "@id" => WEBSITE_ID,
      "name" => "Buildkite Documentation",
      "url" => "https://buildkite.com/docs",
      "publisher" => { "@id" => ORGANIZATION_ID }
    }
  end

  def breadcrumb_list(nav)
    return nil unless nav.respond_to?(:breadcrumb_trail)

    trail = nav.breadcrumb_trail(request.path.sub("/docs/", ""))

    # Search engines require every ListItem to have an `item` URL. Nav sections
    # without a page of their own link to their "Overview" child instead.
    # Sections without one are left out, as is the Overview page itself when it
    # repeats its section's URL.
    crumbs = trail.filter_map do |node|
      path = node["path"].presence || section_overview_path(node)
      [node["name"].to_s.strip, "https://buildkite.com/docs/#{path}"] if path
    end.uniq { |_name, url| url }
    return nil if crumbs.empty?

    {
      "@type" => "BreadcrumbList",
      "itemListElement" => crumbs.each_with_index.map do |(name, url), index|
        { "@type" => "ListItem", "position" => index + 1, "name" => name, "item" => url }
      end
    }
  end

  def section_overview_path(node)
    node["children"]&.find { |child| child["name"] == "Overview" }&.dig("path")
  end
end
