# frozen_string_literal: true

class Page::Renderer
  require "rouge/plugins/redcarpet"

  def self.render(text, options = {})
    new.render(text, options)
  end

  def render(text, options = {})
    markdown(options).render(Emoji.parse(text, sanitize: false))
  end

  private

  def markdown(options)
    Redcarpet::Markdown.new(HTMLWithSyntaxHighlighting.new(options), autolink: true,
                                                                     space_after_headers: true,
                                                                     fenced_code_blocks: true)
  end

  class HTMLWithSyntaxHighlighting < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet

    def initialize(options = {})
      @options = options
      super()
    end

    def image(link, title, alt)
      url = Camo::UrlBuilder.build(link) unless link.nil?

      %{<img src="#{EscapeUtils.escape_html(url || '')}" alt="#{EscapeUtils.escape_html(alt || '')}" class="#{@options[:img_classes]}"/>}
    end

    def codespan(code)
      %{<code class="dark-gray border border-gray rounded" style="padding: .1em .25em; font-size: 85%">#{EscapeUtils.escape_html(code)}</code>}
    end
  end
end
