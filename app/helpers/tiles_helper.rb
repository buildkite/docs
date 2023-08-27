module TilesHelper

  def tiles(name)
    file_path = File.join(Rails.root, 'data', 'tiles.yml')
    items = YAML.load_file(file_path)[name] || []

    if !items.empty?
      tiles_html = items.inject("".html_safe) do |prev_items, current_item|
        prev_items + tile(current_item)
      end
      content_tag(:section, tiles_html, class: "Tiles")
    end
  end

  def tile(item)
    title = item["title"]
    url = item["url"]
    image_path = item["image_path"]
    desc = item["desc"]
    links = item["links"]

    title_html = if title
      content_tag(
        :h2,
        if url
          link_to(title, url, class: "TileItem__title-link")
        else
          title
        end,
        class: "TileItem__title"
      )
    end

    image_html = if image_path
      image_tag(vite_asset_path(image_path), alt: title, class: "TileItem__image")
    end

    desc_html = if desc
      content_tag(:p, desc, class: "TileItem__desc")
    end

    links_html = if links && !links.empty?
      content_tag(
        :ul,
        links.inject("".html_safe) do |prev_links, current_link|
          if current_link["text"]
            inner_html =
              current_link["text"].html_safe +
              (current_link["is_coming_soon"] && content_tag(:span, "Coming soon", class: "pill pill--coming-soon pill--small"))

            prev_links +
            content_tag(
              :li,
              button(
                inner_html,
                current_link["url"],
                { type: "link", has_right_arrow: !!current_link["url"] }
              ),
              class: "TileItem__list-item"
            )
          end
        end,
        class: "TileItem__list"
      )
    end

    learn_more_html = if url
      link_to("Learn more", url, class: "TileItem__learn-more")
    end

    content_tag(
      :article,
      [
        image_html,
        title_html,
        desc_html,
        links_html,
        learn_more_html
      ].inject("".html_safe) do |prev_htmls, current_html|
        prev_htmls + current_html
      end,
      class: "TileItem"
    )
  end

end
