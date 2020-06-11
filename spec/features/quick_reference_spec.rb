require 'rails_helper'

RSpec.feature "Quick Reference" do
  describe "pipelines" do
    it "should render valid json" do
      visit "/docs/quick-reference/pipelines.json"

      body = JSON.parse(page.body)

      expect(body).to be_a Hash
      expect(body["steps"]).to be_an Array
    end
  end
end
