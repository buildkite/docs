require "rails_helper"

RSpec.feature "Page rating widget rendering" do
  context "home page" do
    scenario "does not display page rating widget" do
      visit "/docs"

      expect(page).not_to have_css "#page-rating-widget"
    end
  end

  context "landing page" do
    scenario "does display page rating widget" do
      visit "/docs/test-engine"

      expect(page).to have_css "#page-rating-widget"
    end
  end

  context "standard docs page" do
    scenario "displays page rating widget" do
      visit "/docs/tutorials/getting-started"

      expect(page).to have_css "#page-rating-widget"
    end
  end

  context "graphql page" do
    scenario "does display page rating widget" do
      visit "/docs/apis/graphql-api"

      expect(page).to have_css "#page-rating-widget"
    end
  end
end
