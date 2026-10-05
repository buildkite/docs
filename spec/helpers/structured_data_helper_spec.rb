require 'rails_helper'

RSpec.describe StructuredDataHelper do
  let(:request_double) { double("Request", path: "/docs/pipelines/advantages/faq") }

  before do
    allow(helper).to receive(:request).and_return(request_double)
    allow(helper).to receive(:seo_canonical_url)
      .and_return("https://buildkite.com/docs/pipelines/advantages/faq")
    allow(helper).to receive(:image_path).with("logo.svg").and_return("/docs/vite/assets/logo.svg")
  end

  def graph_types(data)
    data.fetch("@graph").map { |node| node["@type"] }
  end

  describe "#docs_page_structured_data" do
    let(:nav) do
      double("Nav").tap do |nav|
        allow(nav).to receive(:breadcrumb_trail).with("pipelines/advantages/faq").and_return(
          [
            { "name" => "Pipelines", "path" => "pipelines" },
            { "name" => "Introduction", "children" => [{ "name" => "Background", "path" => "pipelines/background" }] },
            {
              "name" => "Advantages",
              "children" => [
                { "name" => "Overview", "path" => "pipelines/advantages" },
                { "name" => "FAQ", "path" => "pipelines/advantages/faq" }
              ]
            },
            { "name" => "FAQ", "path" => "pipelines/advantages/faq" }
          ]
        )
      end
    end

    def breadcrumb_items(data)
      data.fetch("@graph").find { |node| node["@type"] == "BreadcrumbList" }["itemListElement"]
    end

    context "for a regular page" do
      let(:page) do
        double("Page", title: "Some page", description: "A description")
      end

      it "always includes Organization, WebSite, and TechArticle nodes" do
        data = helper.docs_page_structured_data(page, nav)

        expect(graph_types(data)).to include("Organization", "WebSite", "TechArticle")
        expect(graph_types(data)).not_to include("FAQPage")
      end

      it "includes a BreadcrumbList where every item has a URL" do
        items = breadcrumb_items(helper.docs_page_structured_data(page, nav))

        # Sections link to their Overview page; sections without one are skipped.
        expect(items).to eq(
          [
            { "@type" => "ListItem", "position" => 1, "name" => "Pipelines", "item" => "https://buildkite.com/docs/pipelines" },
            { "@type" => "ListItem", "position" => 2, "name" => "Advantages", "item" => "https://buildkite.com/docs/pipelines/advantages" },
            { "@type" => "ListItem", "position" => 3, "name" => "FAQ", "item" => "https://buildkite.com/docs/pipelines/advantages/faq" }
          ]
        )
      end

      it "doesn't repeat a section's URL for its Overview page" do
        allow(request_double).to receive(:path).and_return("/docs/pipelines/advantages")
        allow(nav).to receive(:breadcrumb_trail).with("pipelines/advantages").and_return(
          [
            { "name" => "Pipelines", "path" => "pipelines" },
            { "name" => "Advantages", "children" => [{ "name" => "Overview", "path" => "pipelines/advantages" }] },
            { "name" => "Overview", "path" => "pipelines/advantages" }
          ]
        )

        items = breadcrumb_items(helper.docs_page_structured_data(page, nav))

        expect(items.map { |item| [item["name"], item["item"]] }).to eq(
          [
            ["Pipelines", "https://buildkite.com/docs/pipelines"],
            ["Advantages", "https://buildkite.com/docs/pipelines/advantages"]
          ]
        )
      end
    end
  end

  describe "#docs_home_structured_data" do
    it "defines the Organization and WebSite referenced by page graphs" do
      data = helper.docs_home_structured_data

      expect(graph_types(data)).to eq(["Organization", "WebSite"])
    end
  end

  describe "#render_json_ld" do
    it "returns nil for blank data" do
      expect(helper.render_json_ld(nil)).to be_nil
      expect(helper.render_json_ld({})).to be_nil
    end

    it "renders a script tag with the application/ld+json type" do
      html = helper.render_json_ld("@type" => "Thing")

      expect(html).to include('<script type="application/ld+json">')
      expect(html).to include('</script>')
    end

    it "escapes characters that could break out of the script element" do
      html = helper.render_json_ld("name" => "</script><img src=x onerror=alert(1)> & friends")

      # The literal closing tag and ampersand must not survive in the output.
      expect(html).not_to include("</script><img")
      expect(html).not_to include("x onerror=alert(1)> &")
      expect(html).to include('\u003c')
      expect(html).to include('\u003e')
      expect(html).to include('\u0026')
    end

    it "still produces valid JSON after escaping" do
      payload = helper.render_json_ld("name" => "a < b & c > d")
      json = payload[/<script[^>]*>(.*)<\/script>/m, 1]

      expect(JSON.parse(json)).to eq("name" => "a < b & c > d")
    end
  end
end
