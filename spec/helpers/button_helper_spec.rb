require 'rails_helper'

RSpec.describe ButtonHelper do
  describe "#button" do
    context "when the button has children, url, and has_right_arrow" do
      it "renders correctly with children, url and right arrow" do
        button_html = button(":hammer: Test", "https://buildkite.com", true)

        expect(button_html).to eq('<a class="Button" href="https://buildkite.com">:hammer: Test<span class="Button__right-arrow" aria-hidden="true"></span></a>')
      end
    end

    context "when the button has children, url but no right arrow" do
      it "renders the button without right arrow" do
        button_html = button(":hammer: Test", "https://buildkite.com", false)

        expect(button_html).to eq('<a class="Button" href="https://buildkite.com">:hammer: Test</a>')
      end
    end
  end

end
