require 'rails_helper'

RSpec.describe Nav do
  let(:data) { YAML.load_file("#{Rails.root}/data/nav.yml") }
  let(:nav) { Nav.new(data) }

  describe '#current_item' do
    it 'returns the nav data' do
      request = double('request', path: '/docs/tutorials/getting-started')
      expect(nav.current_item(request)).to eq({
        parents: ["Pipelines"],
        path: "tutorials/getting-started",
      })
    end
  end
end
