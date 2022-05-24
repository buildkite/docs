require 'rails_helper'

RSpec.describe Page::Button do
  describe "#render" do
    context "when the button has children, url, and has_right_arrow" do
      it "renders correctly with children, url and right arrow" do
        button_html = Page::Button.new(":hammer: Test", "https://buildkite.com", "has_right_arrow").render()

        expect(button_html).to eq('<a class="Button" href="https://buildkite.com">:hammer: Test<span aria-hidden class="Button__right-arrow"></span></a>')
      end
    end

    context "when the button has children, url but no right arrow" do
      it "renders the button without right arrow" do
        button_html = Page::Button.new(":hammer: Test", "https://buildkite.com").render()

        expect(button_html).to eq('<a class="Button" href="https://buildkite.com">:hammer: Test</a>')
      end
    end
  end
end
