require 'rails_helper'

RSpec.feature "toc rendering" do
  describe "/docs/tutorials/getting-started" do
    it "has a TOC" do
      visit "/docs/tutorials/getting-started"
      
      expect(page).to have_css(".Toc")
    end
  end
  
  describe "/docs/agent/v3/self-hosted/installing" do
    it "does not have a TOC" do
      expect(page).to have_no_css(".Toc")
    end
  end
end
