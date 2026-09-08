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

  describe "#breadcrumb_trail" do
    let(:data) do
      [
        {
          name: "Pipelines",
          path: "pipelines",
          children: [
            {
              name: "Configure",
              children: [
                {
                  name: "Environment variables",
                  path: "pipelines/configure/environment-variables",
                }.stringify_keys
              ]
            }.stringify_keys
          ]
        }.stringify_keys
      ]
    end

    it "returns the trail of nav nodes from the top-level section to the page" do
      trail = nav.breadcrumb_trail("pipelines/configure/environment-variables")

      expect(trail.map { |node| node["name"] }).to eq(
        ["Pipelines", "Configure", "Environment variables"]
      )
      expect(trail.map { |node| node["path"] }).to eq(
        ["pipelines", nil, "pipelines/configure/environment-variables"]
      )
    end

    it "returns an empty array for an unknown path" do
      expect(nav.breadcrumb_trail("does/not/exist")).to eq([])
    end
  end
end
