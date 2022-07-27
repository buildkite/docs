require 'rails_helper'

RSpec.describe PillHelper do
  describe "#pill" do
    context "when no size is passed" do
      it "renders a medium size pill" do
        pill_medium = pill("Medium pill", "new")
        expect(pill_medium).to eq("<span class=\"pill pill--new pill--medium\">Medium pill</span>")
      end
    end

    context "when size is small" do
      it "renders a small size pill" do
        pill_small = pill("Small pill", "new", "small")
        expect(pill_small).to eq("<span class=\"pill pill--new pill--small\">Small pill</span>")
      end
    end
  end
end
