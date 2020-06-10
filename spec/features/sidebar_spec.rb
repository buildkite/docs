require 'rails_helper'

RSpec.feature "sidebar" do
  it "should render valid json" do
    visit "/sidebar.json"

    body = JSON.parse(page.body)

    expect(body).to be_a Hash
    expect(body["steps"]).to be_an Array
  end
end
