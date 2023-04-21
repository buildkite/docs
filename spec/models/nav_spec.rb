require 'rails_helper'

RSpec.describe Nav do
  let(:data) do
    [
      {
          name: "Pipelines",
          path: "pipelines",
          children: [
            {
              name: "Getting Started",
              path: "tutorials/getting-started",
            }.stringify_keys
          ]
        }.stringify_keys
      ]
  end

  let(:nav) { Nav.new(data) }

  describe "#route_map" do
    it "returns a hash of routes, indexed by path" do
      expect(nav.route_map).to eq({
        "tutorials/getting-started" => {
          path: "tutorials/getting-started",
          parents: ["Pipelines"]
        }
      })
    end
  end


  describe '#current_item_root' do
    it 'returns a nav tree' do
      request = double('request', path: '/docs/tutorials/getting-started')
      expect(nav.current_item_root(request)).to eq(data[0])
    end
  end

  describe '#current_item' do
    it 'returns a nav item' do
      request = double('request', path: '/docs/tutorials/getting-started')
      expect(nav.current_item(request)).to eq({
        parents: ["Pipelines"],
        path: "tutorials/getting-started",
      })
    end
  end
end
