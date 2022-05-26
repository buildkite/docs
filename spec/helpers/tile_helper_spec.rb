require 'rails_helper'

RSpec.describe TilesHelper do
  describe "#tile" do
    context "has url" do
      it "links the title and appends a learn more link" do
        tile_item_html = tile({
          "title" => "Title",
          "url" => "https://buildkite.com",
          "image_url" => "/placeholder.jpg",
          "desc" => "Placeholder TileItem",
          "links" => [
            {
              "text" => "Link 1",
              "url" => "https://buildkite.com"
            },
            {
              "text" => "Link 2",
              "url" => "https://buildkite.com/docs"
            }
          ]
        })
        
        expect(tile_item_html).to eq(
          '<article class="TileItem">' +
            '<img alt="Title" class="TileItem__image" src="/placeholder.jpg" />' +
            '<h2 class="TileItem__title"><a class="TileItem__title-link" href="https://buildkite.com">Title</a></h2>' +
            '<p class="TileItem__desc">Placeholder TileItem</p>' +
            '<ul class="TileItem__list">' +
              '<li class="TileItem__list-item"><a class="TileItem__list-item-link" href="https://buildkite.com">Link 1</a></li>' +
              '<li class="TileItem__list-item"><a class="TileItem__list-item-link" href="https://buildkite.com/docs">Link 2</a></li>' +
            '</ul>' +
            '<a class="TileItem__learn-more" href="https://buildkite.com">Learn more</a>' +
          '</article>'
        )
      end
    end

    context "doesn't have url" do
      it "doesn't link the heading nor render learn more link" do
        tile_item_html = tile({
          "title" => "Title",
          "image_url" => "/placeholder.jpg",
          "desc" => "Placeholder TileItem",
          "links" => [
            {
              "text" => "Link 1",
              "url" => "https://buildkite.com"
            },
            {
              "text" => "Link 2",
              "url" => "https://buildkite.com/docs"
            }
          ]
        })

        expect(tile_item_html).to eq(
          '<article class="TileItem">' +
            '<img alt="Title" class="TileItem__image" src="/placeholder.jpg" />' +
            '<h2 class="TileItem__title">Title</h2>' +
            '<p class="TileItem__desc">Placeholder TileItem</p>' +
            '<ul class="TileItem__list">' +
              '<li class="TileItem__list-item"><a class="TileItem__list-item-link" href="https://buildkite.com">Link 1</a></li>' +
              '<li class="TileItem__list-item"><a class="TileItem__list-item-link" href="https://buildkite.com/docs">Link 2</a></li>' +
            '</ul>' +
          '</article>'
        )
      end
    end

  end
end
