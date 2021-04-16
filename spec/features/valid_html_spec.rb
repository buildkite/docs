require 'rails_helper'

RSpec.feature "Validate HTML" do
  scenario "visit landing page" do
    visit "/"
    page.body.should be_valid_html
  end
  scenario "visit pipelines page" do
    visit "/pipelines"
    page.body.should be_valid_html
  end
end