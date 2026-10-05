require 'rails_helper'

RSpec.feature "JSON-LD structured data rendering" do
  # Parses the schema.org JSON-LD embedded in the current page and returns its
  # @graph nodes. Returns an empty array when the page has no JSON-LD.
  def json_ld_graph
    script = Nokogiri::HTML(page.html).at_css('script[type="application/ld+json"]')
    return [] unless script

    data = JSON.parse(script.content)
    data.fetch("@graph", [])
  end

  def graph_types
    json_ld_graph.map { |node| node["@type"] }
  end

  describe "the documentation home page" do
    it "embeds a valid JSON-LD script with Organization and WebSite nodes" do
      visit "/docs"

      expect(graph_types).to eq(["Organization", "WebSite"])
    end
  end

  describe "a regular documentation page" do
    it "embeds Organization, WebSite, TechArticle, and BreadcrumbList nodes" do
      visit "/docs/pipelines/getting-started"

      expect(graph_types).to include("Organization", "WebSite", "TechArticle", "BreadcrumbList")
    end

    it "describes the page in the TechArticle node" do
      visit "/docs/pipelines/getting-started"

      article = json_ld_graph.find { |node| node["@type"] == "TechArticle" }
      expect(article["url"]).to eq("https://buildkite.com/docs/pipelines/getting-started")
      expect(article["headline"]).to be_present
      expect(article["isPartOf"]).to eq("@id" => "https://buildkite.com/docs#website")
      expect(article["publisher"]).to eq("@id" => "https://buildkite.com/#organization")
    end

    it "builds a BreadcrumbList from the page's navigation trail" do
      visit "/docs/pipelines/configure/depends-on"

      breadcrumb = json_ld_graph.find { |node| node["@type"] == "BreadcrumbList" }
      items = breadcrumb["itemListElement"]

      expect(items.map { |item| [item["position"], item["name"], item["item"]] }).to eq(
        [
          [1, "Pipelines", "https://buildkite.com/docs/pipelines"],
          [2, "Configure pipelines", "https://buildkite.com/docs/pipelines/configure"],
          [3, "Depends on", "https://buildkite.com/docs/pipelines/configure/depends-on"]
        ]
      )
    end
  end
end
