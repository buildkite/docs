require 'rails_helper'

RSpec.describe Nav do
  let(:data) { YAML.load_file("#{Rails.root}/data/nav.yml") }
  let(:nav) { Nav.new(data) }

  describe '#nav_tree' do
    it 'returns the nav data' do
      expect(nav.data).to eq([])
    end
  end

  describe '#route_map' do
    it 'returns a hash of routes' do
      expect(nav.route_map).to eq({})
    end
  end
end
