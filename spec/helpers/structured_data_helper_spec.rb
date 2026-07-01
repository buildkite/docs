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
            { "name" => "Advantages", "path" => nil },
            { "name" => "FAQ", "path" => "pipelines/advantages/faq" }
          ]
        )
      end
    end

    context "for a regular page" do
      let(:page) do
        double("Page", title: "Some page", description: "A description", faq?: false)
      end

      it "always includes Organization, WebSite, and TechArticle nodes" do
        data = helper.docs_page_structured_data(page, nav)

        expect(graph_types(data)).to include("Organization", "WebSite", "TechArticle")
      end

      it "does not include a FAQPage node" do
        data = helper.docs_page_structured_data(page, nav)

        expect(graph_types(data)).not_to include("FAQPage")
      end

      it "includes a BreadcrumbList built from the nav trail" do
        data = helper.docs_page_structured_data(page, nav)

        breadcrumb = data.fetch("@graph").find { |node| node["@type"] == "BreadcrumbList" }
        expect(breadcrumb).to be_present

        items = breadcrumb["itemListElement"]
        expect(items.map { |item| item["name"] }).to eq(["Pipelines", "Advantages", "FAQ"])
        expect(items.map { |item| item["position"] }).to eq([1, 2, 3])
        # Nodes without a path are listed but not linked.
        expect(items[1]).not_to have_key("item")
        expect(items[2]["item"]).to eq("https://buildkite.com/docs/pipelines/advantages/faq")
      end
    end

    context "for an FAQ page" do
      let(:faq_items) do
        [{ "question" => "Why is it fast?", "answer" => "Unlimited concurrency." }]
      end
      let(:page) do
        double("Page", title: "FAQ", description: "Common questions", faq?: true, faq_items: faq_items)
      end

      it "includes both a TechArticle and a FAQPage node" do
        data = helper.docs_page_structured_data(page, nav)

        expect(graph_types(data)).to include("TechArticle", "FAQPage")
      end

      it "maps each FAQ item to a Question with an accepted Answer" do
        data = helper.docs_page_structured_data(page, nav)

        faq_node = data.fetch("@graph").find { |node| node["@type"] == "FAQPage" }
        question = faq_node["mainEntity"].first

        expect(question["@type"]).to eq("Question")
        expect(question["name"]).to eq("Why is it fast?")
        expect(question["acceptedAnswer"]).to eq(
          "@type" => "Answer", "text" => "Unlimited concurrency."
        )
      end
    end

    context "when the page opts in to FAQ but has no extractable items" do
      let(:page) do
        double("Page", title: "FAQ", description: nil, faq?: true, faq_items: [])
      end

      it "falls back to TechArticle only" do
        data = helper.docs_page_structured_data(page, nav)

        expect(graph_types(data)).to include("TechArticle")
        expect(graph_types(data)).not_to include("FAQPage")
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
