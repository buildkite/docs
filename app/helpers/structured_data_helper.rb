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
  # the WebSite and Organization the page belongs to and a BreadcrumbList
  # reflecting its place in the navigation. The main entity is a FAQPage when
  # the page opts in to FAQ structured data, otherwise a TechArticle.
  def docs_page_structured_data(page, nav)
    main_entity =
      if page.faq? && (faq_items = page.faq_items).present?
        faq_page_node(page, faq_items)
      else
        tech_article_node(page)
      end

    graph = [organization_node, website_node, main_entity]

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

  def faq_page_node(page, faq_items)
    node = {
      "@type" => "FAQPage",
      "@id" => "#{seo_canonical_url}#faq",
      "name" => page.title,
      "url" => seo_canonical_url,
      "inLanguage" => "en",
      "isPartOf" => { "@id" => WEBSITE_ID },
      "publisher" => { "@id" => ORGANIZATION_ID },
      "mainEntity" => faq_items.map do |item|
        {
          "@type" => "Question",
          "name" => item["question"],
          "acceptedAnswer" => {
            "@type" => "Answer",
            "text" => item["answer"]
          }
        }
      end
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
    return nil if trail.blank?

    items = trail.each_with_index.map do |node, index|
      element = {
        "@type" => "ListItem",
        "position" => index + 1,
        "name" => node["name"].to_s.strip
      }
      element["item"] = "https://buildkite.com/docs/#{node['path']}" if node["path"].present?
      element
    end

    {
      "@type" => "BreadcrumbList",
      "itemListElement" => items
    }
  end
end
