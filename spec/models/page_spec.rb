require 'rails_helper'

RSpec.describe Page do
  describe ".all" do
    it "ignores partial templates" do
      allow(File).to receive(:mtime).and_return(Time.now)

      allow(Dir).to receive(:glob).and_return([
        "docs/agent-api.md",
        "docs/_apt_configuration.md"
      ])

      expect(Page.all.size).to eql(1)
    end
  end

  describe "#beta?" do
    context "when page's path is defined in the BETA_PAGES constant" do
      it "returns true" do
        allow(BetaPages).to receive(:all).and_return(["apis/agent-api"])
        page = Page.new(double, "apis/agent-api")

        expect(page).to be_beta
      end
    end

    context "when page's path is not defined in the BETA_PAGES constant" do
      it "returns false" do
        allow(BetaPages).to receive(:all).and_return([])
        page = Page.new(double, "apis/agent-api")

        expect(page).not_to be_beta
      end
    end
  end

  describe "#keywords" do
    context "when page has keywords defined in frontmatter" do
      it "returns the keywords" do
        page = Page.new(double, "tutorials/2fa")

        expect(page.keywords).to eql("docs, pipelines, tutorials, 2fa")
      end
    end

    context "when keywords are not defined in frontmatter" do
      it "returns nil" do
        page = Page.new(double, "apis/agent-api")

        expect(page.keywords).to eql(nil)
      end
    end
  end
end
