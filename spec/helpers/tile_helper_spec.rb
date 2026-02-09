require 'rails_helper'

RSpec.describe TilesHelper, type: 'helper' do
  describe "#tile" do
    context "has url" do
      it "links the title and appends a learn more link" do
        logo_asset_path = helper.vite_asset_path("images/logo.svg")

        tile_item_html = helper.tile({
          "title" => "Title",
          "url" => "https://buildkite.com",
          "image_path" => "images/logo.svg",
          "desc" => "Placeholder TileItem"
        })

        expect(tile_item_html).to eq(
          '<article class="TileItem">' +
            "<img alt=\"Title\" class=\"TileItem__image\" src=\"#{logo_asset_path}\" />" +
            '<h2 class="TileItem__title"><a class="TileItem__title-link" href="https://buildkite.com">Title</a></h2>' +
            '<p class="TileItem__desc">Placeholder TileItem</p>' +
            '<a class="TileItem__learn-more" href="https://buildkite.com">Learn more</a>' +
          '</article>'
        )
      end
    end

    context "doesn't have url" do
      it "doesn't link the heading nor render learn more link" do
        logo_asset_path = helper.vite_asset_path("images/logo.svg")

        tile_item_html = helper.tile({
          "title" => "Title",
          "image_path" => "images/logo.svg",
          "desc" => "Placeholder TileItem"
        })

        expect(tile_item_html).to eq(
          '<article class="TileItem">' +
            "<img alt=\"Title\" class=\"TileItem__image\" src=\"#{logo_asset_path}\" />" +
            '<h2 class="TileItem__title">Title</h2>' +
            '<p class="TileItem__desc">Placeholder TileItem</p>' +
          '</article>'
        )
      end
    end

    context "has links" do
      it "renders an array of links" do
        tile_item_html = helper.tile({
          "title" => "Title",
          "links" => [
            {
              "text" => "Link 1",
              "url" => "https://buildkite.com"
            },
            {
              "text" => "Link 2",
              "url" => "https://buildkite.com/docs"
            },
            {
              "text" => "Link 3",
              "is_coming_soon" => true
            }
          ]
        })

        expect(tile_item_html).to eq(
          '<article class="TileItem">' +
            '<h2 class="TileItem__title">Title</h2>' +
            '<ul class="TileItem__list">' +
              '<li class="TileItem__list-item"><a class="Button Button--link" href="https://buildkite.com">Link 1<span class="Button__right-arrow" aria-hidden="true"></span></a></li>' +
              '<li class="TileItem__list-item"><a class="Button Button--link" href="https://buildkite.com/docs">Link 2<span class="Button__right-arrow" aria-hidden="true"></span></a></li>' +
              '<li class="TileItem__list-item"><span class="Button Button--link">Link 3<span class="pill pill--coming-soon pill--small">Coming soon</span></span></li>' +
            '</ul>' +
          '</article>'
        )
      end
    end

  end
end
