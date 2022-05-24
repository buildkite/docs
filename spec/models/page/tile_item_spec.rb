require 'rails_helper'

RSpec.describe Page::TileItem do
  describe "#render" do
    context "has title and url" do
      it "links the title and appends a learn more link" do
        tile_item_html =
          Page::TileItem.new(
            "Title",
            "https://buildkite.com",
            "/placeholder.jpg",
            "Placeholder TileItem"
          )
          .render().gsub(/\s+/, "").strip
        
        expect(tile_item_html).to eq(
          %{
            <article class="TileItem">
              <img alt="Title" class="TileItem__image" src="/placeholder.jpg" />
              <h2 class="TileItem__title"><a class="TileItem__title-link" href="https://buildkite.com">Title</a></h2>
              <p class="TileItem__desc">Placeholder TileItem</p>
              <a href="https://buildkite.com" class="TileItem__learn-more">Learn more</a>
            </article>
          }.gsub(/\s+/, "").strip
        )
      end
    end

    context "has title but no url" do
      it "title as text only and does not append a learn more link" do
        tile_item_html =
          Page::TileItem.new(
            "Title",
            "",
            "/placeholder.jpg",
            "Placeholder TileItem"
          )
          .render().gsub(/\s+/, " ").strip

        expect(tile_item_html).to eq(
          %{
            <article class="TileItem">
              <img alt="Title" class="TileItem__image" src="/placeholder.jpg" />
              <h2 class="TileItem__title">Title</h2>
              <p class="TileItem__desc">Placeholder TileItem</p>
            </article>
          }.gsub(/\s+/, " ").strip
        )
      end
    end

    context "has links" do
      it "renders list of links" do
        tile_item_html =
          Page::TileItem.new(
            "Title",
            "",
            "",
            "",
            [
              {
                "text" => "Uploading JSON data",
                "url" => "/docs/test-analytics/importing-json"
              },
              {
                "text" => "Uploading JUnit XML results",
                "url" => "/docs/test-analytics/importing-junit-xml"
              },
              {
                "text" => "Build your own collector",
                "url" => "/docs/test-analytics/your-own-collectors"
              }
            ]
          )
          .render

          expect(tile_item_html).to include('<ul class="TileItem__list">').once
          expect(tile_item_html).to include('<li class="TileItem__list-item">')
      end
    end
  end
end

# expect(tile_item_html).to eq(
          #   %{
          #     <article class="TileItem">
          #       <h2 class="TileItem__title">Title</h2>
          #       <ul class="TileItem__list">
          #         <li class="TileItem__list-item"><a href="/docs/test-analytics/importing-json" class="TileItem__list-item-link">Uploading JSON data</a></li>
          #         <li class="TileItem__list-item"><a href="/docs/test-analytics/importing-junit-xml" class="TileItem__list-item-link">Uploading JUnit XML results</a></li>
          #         <li class="TileItem__list-item"><a href="/docs/test-analytics/your-own-collectors" class="TileItem__list-item-link">Build your own collector</a></li>
          #       </ul>
          #     </article>
          #   }.gsub(/\s+/, "").strip
          # )