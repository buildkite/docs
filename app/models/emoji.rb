# frozen_string_literal: true

class Emoji
  EMOJI_HOST = "https://buildkiteassets.com/emojis"

  CATALOGUES = {
    apple: Emoji::Catalogue.load(:apple, EMOJI_HOST, Rails.root.join("vendor/emojis/img-apple-64.json").to_s),
    buildkite: Emoji::Catalogue.load(:buildkite, EMOJI_HOST, Rails.root.join("vendor/emojis/img-buildkite-64.json").to_s)
  }.freeze

  # Parses text and converts emojis to images
  def self.parse(text, options = {})
    html_attributes = options.delete(:html_attributes)
    Emoji::Parser.parse(CATALOGUES.values, text, options) do |match, emoji|
      # Replace shortcode emojis with unicode if possible
      if unicode = emoji.unicode
        unicode
      elsif html_attributes.present?
        tag = +%(<img title="#{emoji.name}" alt="#{match}" src="#{emoji.url}" draggable="false")
        tag << %( width="#{html_attributes[:width]}") if html_attributes[:width]
        tag << %( height="#{html_attributes[:height]}") if html_attributes[:height]
        tag << %( style="#{html_attributes[:style]}") if html_attributes[:style]
        tag << %( />)
        tag.html_safe
      else
        %(<img class="emoji" title="#{emoji.name}" alt="#{match}" src="#{emoji.url}" draggable="false" />).html_safe
      end
    end
  end
end
