require 'rails_helper'

RSpec.describe Page do
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

  describe "#landing_page?" do
    context "when page's path is defined in LandingPages" do
      it "returns true" do
        allow(LandingPages).to receive(:all).and_return(["integrations"])
        page = Page.new(double, "integrations")

        expect(page).to be_landing_page
      end
    end

    context "when page's path is not defined in the LandingPages" do
      it "returns false" do
        allow(LandingPages).to receive(:all).and_return([])
        page = Page.new(double, "apis/agent-api")

        expect(page).not_to be_landing_page
      end
    end
  end
end
