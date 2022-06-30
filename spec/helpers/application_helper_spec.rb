require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#logo_image_url' do
    context "when it's not June" do
      it 'renders the default green logo' do
        travel_to Time.zone.local(2021, 1, 1)

        expect(logo_image_url).to eq('/images/logo.svg')
      end
    end

    context "when it's June" do
      it 'renders the Pride logo' do
        travel_to Time.zone.local(2021, 6, 1)

        expect(logo_image_url).to eq('/images/logo-pride.svg')
      end
    end
  end
end
