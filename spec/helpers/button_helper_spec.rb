require 'rails_helper'

RSpec.describe ButtonHelper do
  describe "#button" do
    context "when the button has children, url, and has_right_arrow" do
      it "renders correctly with children, url and right arrow" do
        button_html = button(":hammer: Test", "https://buildkite.com", has_right_arrow: true)

        expect(button_html).to eq('<a class="Button Button--default" href="https://buildkite.com">:hammer: Test<span class="Button__right-arrow" aria-hidden="true"></span></a>')
      end
    end

    context "when the button has children, url but no right arrow" do
      it "renders the button without right arrow" do
        button_html = button(":hammer: Test", "https://buildkite.com")

        expect(button_html).to eq('<a class="Button Button--default" href="https://buildkite.com">:hammer: Test</a>')
      end
    end

    context "when the button is a link button" do
      it "renders a naked link button" do
        button_html = button(":hammer: Test", "https://buildkite.com", { type: "link"})

        expect(button_html).to eq('<a class="Button Button--link" href="https://buildkite.com">:hammer: Test</a>')
      end
    end

    context "when the button doesn't have a url" do
      it "is not linked" do
        button_html = button(":hammer: Test")

        expect(button_html).to eq('<span class="Button Button--default">:hammer: Test</span>')
      end
    end

    it "renders an inline button" do
      button_html = button("Inline button", "http://www.buildkite.com", { inline: true })

      expect(button_html).to eq('<a class="Button Button--default Button--inline" href="http://www.buildkite.com">Inline button</a>')
    end
  end

end
