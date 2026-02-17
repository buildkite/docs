require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#logo_image_path' do
    context "when it's not June" do
      it 'renders the default green logo' do
        travel_to Time.zone.local(2021, 1, 1)

        expect(logo_image_path).to eq('/images/logo.svg')
      end
    end

    context "when it's June" do
      it 'renders the Pride logo' do
        travel_to Time.zone.local(2021, 6, 1)

        expect(logo_image_path).to eq('/images/logo-pride.svg')
      end
    end
  end

  describe "#top_level_nav_item_name" do
    it "returns the top level nav item name correctly" do
      path = "integrations/sso/google-workspace-saml"

      expect(top_level_nav_item_name(path)).to eq("Integrations")
    end

    context "when the top level nav item is APIs" do
      it "returns APIs with the correct casing" do
        path = "apis/rest-api/access-token"

        expect(top_level_nav_item_name(path)).to eq("APIs")
      end
    end

    context "when the path contains dashes" do
      it "replaces dashes with spaces" do
        path = "test-engine/importing-junit-xml"

        expect(top_level_nav_item_name(path)).to eq("Test Engine")
      end

      it "titleizes" do
        path = "test-engine/importing-junit-xml"

        expect(top_level_nav_item_name(path)).to eq("Test Engine")
      end
    end
  end

  describe "#seo_canonical_url" do
    it "returns the correct canonical URL" do
      # Mocking the request object's path method
      allow(helper).to receive_message_chain(:request, :path).and_return("/docs/agent")

      expect(helper.seo_canonical_url).to eq("https://buildkite.com/docs/agent")
    end
  end
end
