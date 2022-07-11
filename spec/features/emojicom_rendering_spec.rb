require 'rails_helper'

RSpec.feature "Emojicom rendering" do
  context "home page" do
    scenario "does not display emojicom widget" do
      visit "/docs"

      expect(page).not_to have_text "#emojicom-widget-inline"
    end
  end

  context "landing page" do
    scenario "does not display emojicom widget" do
      visit "/docs/test-analytics"

      expect(page).not_to have_css "#emojicom-widget-inline"
    end
  end

  context "standard docs page" do
    scenario "displays emojicom widget" do
      visit "/docs/tutorials/getting-started"

      expect(page).to have_css "#emojicom-widget-inline"
    end
  end
end
